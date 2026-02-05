# Petrol Prices rake tasks
#
# Usage:
#   bin/rake pp:stations_full        # Fetch all stations, filter by location and E10
#   bin/rake pp:stations_incremental # Fetch stations changed since last sync
#   bin/rake pp:prices_full          # Fetch all prices for known stations
#   bin/rake pp:prices_incremental   # Fetch prices changed since last sync
#   bin/rake pp:prune_stations       # Delete stations outside the bounding box

require 'net/http'
require 'json'
require 'uri'

namespace :pp do
  API_BASE_URL = 'https://www.fuel-finder.service.gov.uk/api/v1'
  BATCH_SIZE = 500

  desc "Fetch all stations from API"
  task stations_full: :environment do
    PetrolPricesFetcher.new.fetch_stations(incremental: false)
  end

  desc "Fetch stations changed since last sync"
  task stations_incremental: :environment do
    PetrolPricesFetcher.new.fetch_stations(incremental: true)
  end

  desc "Fetch all prices from API"
  task prices_full: :environment do
    PetrolPricesFetcher.new.fetch_prices(incremental: false)
  end

  desc "Fetch prices changed since last sync"
  task prices_incremental: :environment do
    PetrolPricesFetcher.new.fetch_prices(incremental: true)
  end

  desc "Delete stations outside the bounding box"
  task prune_stations: :environment do
    outside = Pp::Station.all.reject do |s|
      Pp::Station.in_bounds?(s.latitude, s.longitude)
    end

    if outside.empty?
      puts "No stations outside the bounding box."
      next
    end

    puts "Stations outside bounding box:"
    puts "-" * 70
    outside.each do |s|
      puts "#{s.display_name} (ID: #{s.id}, lat: #{s.latitude}, long: #{s.longitude})"
    end
    puts "-" * 70
    puts "Total: #{outside.size} station(s)"
    puts

    print "Delete all #{outside.size} station(s) and their prices? (yes/no): "
    response = $stdin.gets.chomp.downcase

    if response == 'yes'
      count = outside.size
      outside.each(&:destroy)
      puts "Deleted #{count} station(s) and their associated prices."
    else
      puts "Cancelled."
    end
  end

  class PetrolPricesFetcher
    def initialize
      @client_id = Rails.application.credentials.petrol_prices[:client_id]
      @client_secret = Rails.application.credentials.petrol_prices[:client_secret]
      @access_token = nil
    end

    def fetch_stations(incremental:)
      query_type = incremental ? 'stations_incremental' : 'stations_full'
      sync_log = start_sync(query_type)

      begin
        # For incremental, find the last successful sync timestamp
        since_timestamp = nil
        if incremental
          last_sync = Pp::SyncLog.last_successful_stations_sync
          if last_sync
            since_timestamp = last_sync.started_at
            puts "Incremental sync since: #{since_timestamp}"
          else
            puts "No previous successful sync found, falling back to full sync"
            sync_log.update!(query_type: 'stations_full')
          end
        end

        obtain_access_token
        all_stations = fetch_all_batches('/pfs', since_timestamp)
        sync_log.records_scanned = all_stations.size

        puts "Total records from API: #{all_stations.size}"

        # Filter and process stations
        all_stations.each do |station_data|
          process_station(station_data, sync_log)
        end

        complete_sync(sync_log)
      rescue => e
        fail_sync(sync_log, e)
        raise
      end
    end

    def fetch_prices(incremental:)
      query_type = incremental ? 'prices_incremental' : 'prices_full'
      sync_log = start_sync(query_type)

      begin
        # Check we have stations to fetch prices for
        station_node_ids = Pp::Station.pluck(:node_id).to_set
        if station_node_ids.empty?
          puts "No stations in database. Run pp:stations_full first."
          fail_sync(sync_log, StandardError.new("No stations in database"))
          return
        end
        puts "Looking for prices for #{station_node_ids.size} stations"

        # For incremental, find the last successful sync timestamp
        since_timestamp = nil
        if incremental
          last_sync = Pp::SyncLog.last_successful_prices_sync
          if last_sync
            since_timestamp = last_sync.started_at
            puts "Incremental sync since: #{since_timestamp}"
          else
            puts "No previous successful sync found, falling back to full sync"
            sync_log.update!(query_type: 'prices_full')
          end
        end

        obtain_access_token
        all_prices = fetch_all_batches('/pfs/fuel-prices', since_timestamp)
        sync_log.records_scanned = all_prices.size

        puts "Total records from API: #{all_prices.size}"

        # Filter and process prices
        all_prices.each do |price_data|
          process_price(price_data, station_node_ids, sync_log)
        end

        complete_sync(sync_log)
      rescue => e
        fail_sync(sync_log, e)
        raise
      end
    end

    private

    def start_sync(query_type)
      sync_log = Pp::SyncLog.create!(
        query_type: query_type,
        started_at: Time.current,
        records_scanned: 0,
        records_created: 0,
        records_updated: 0,
        records_unchanged: 0
      )
      puts
      puts "=" * 60
      puts "Starting #{query_type} at #{sync_log.started_at}"
      puts "=" * 60
      sync_log
    end

    def complete_sync(sync_log)
      duration = Time.current - sync_log.started_at
      sync_log.update!(duration_seconds: duration)
      puts
      puts "-" * 60
      puts "Completed successfully"
      puts "Records scanned: #{sync_log.records_scanned}"
      puts "Records created: #{sync_log.records_created}"
      puts "Records updated: #{sync_log.records_updated}"
      puts "Records unchanged: #{sync_log.records_unchanged}"
      puts "Duration: #{duration.round(2)}s"
      puts "-" * 60
    end

    def fail_sync(sync_log, error)
      duration = Time.current - sync_log.started_at
      error_message = "#{error.class}: #{error.message}"[0, 500]
      sync_log.update!(
        duration_seconds: duration,
        error_message: error_message
      )
      puts
      puts "!" * 60
      puts "FAILED: #{error_message}"
      puts "Duration: #{duration.round(2)}s"
      puts "!" * 60
    end

    def obtain_access_token
      puts "Requesting access token..."
      uri = URI("#{API_BASE_URL}/oauth/generate_access_token")
      response = Net::HTTP.post_form(uri, {
        'grant_type' => 'client_credentials',
        'client_id' => @client_id,
        'client_secret' => @client_secret,
        'scope' => 'fuelfinder.read'
      })

      if response.code != '200'
        raise "Failed to obtain access token: #{response.code} - #{response.body}"
      end

      token_data = JSON.parse(response.body)
      @access_token = token_data.dig('data', 'access_token') || token_data['access_token']
      expires_in = token_data.dig('data', 'expires_in') || token_data['expires_in']
      puts "Token obtained, expires in: #{expires_in} seconds"
    end

    def fetch_all_batches(api_path, since_timestamp = nil)
      all_records = []
      batch = 1

      loop do
        puts "Fetching batch #{batch}..."

        # Build URL with batch number and optional timestamp
        url = "#{API_BASE_URL}#{api_path}?batch-number=#{batch}"
        if since_timestamp
          # Format: YYYY-MM-DD HH:MM:SS (URL encoded)
          formatted_timestamp = since_timestamp.strftime('%Y-%m-%d %H:%M:%S')
          url += "&effective-start-timestamp=#{URI.encode_www_form_component(formatted_timestamp)}"
        end

        uri = URI(url)
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{@access_token}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 120, open_timeout: 30) do |http|
          http.request(request)
        end

        if response.code != '200'
          # Handle "no data available" as empty result, not error
          if response.code == '400' && response.body.include?('No more data available')
            puts "Batch #{batch}: no data available"
            break
          end
          raise "API error on batch #{batch}: #{response.code} - #{response.body}"
        end

        data = JSON.parse(response.body)
        all_records.concat(data)
        puts "Batch #{batch}: #{data.length} records (#{all_records.length} total)"

        # Stop if we got fewer records than the batch size
        break if data.length < BATCH_SIZE
        batch += 1
      end

      all_records
    end

    def process_station(station_data, sync_log)
      node_id = station_data['node_id']
      return unless node_id.is_a?(String) && node_id.length == 64

      # Check if station sells E10
      fuel_types = station_data['fuel_types']
      return unless fuel_types.is_a?(Array) && fuel_types.include?(Pp::Station::FUEL_TYPE)

      # Check if station is in our bounding box
      location = station_data['location']
      return unless location.is_a?(Hash)

      latitude = location['latitude'].to_f
      longitude = location['longitude'].to_f
      return unless Pp::Station.in_bounds?(latitude, longitude)

      # Find or create the station
      station = Pp::Station.find_by(node_id: node_id)
      is_new = station.nil?
      station ||= Pp::Station.new(node_id: node_id)

      # Update attributes
      station.name = station_data['trading_name'].to_s[0, 75]
      station.brand = station_data['brand_name'].to_s[0, 30].presence
      station.address = location['address_line_1'].to_s[0, 50].presence
      station.postcode = location['postcode'].to_s[0, 10].presence
      station.latitude = latitude
      station.longitude = longitude

      if station.changed?
        station.save!
        if is_new
          sync_log.records_created += 1
          puts "  Created: #{station.name} (#{station.postcode})"
        else
          sync_log.records_updated += 1
          puts "  Updated: #{station.name} (#{station.postcode})"
        end
      else
        sync_log.records_unchanged += 1
      end
    end

    def process_price(price_data, station_node_ids, sync_log)
      node_id = price_data['node_id']
      return unless station_node_ids.include?(node_id)

      # Find E10 price in fuel_prices array
      fuel_prices = price_data['fuel_prices']
      return unless fuel_prices.is_a?(Array)

      e10_price = fuel_prices.find { |fp| fp['fuel_type'] == Pp::Station::FUEL_TYPE }
      return unless e10_price

      price_value = e10_price['price'].to_s.to_f
      return unless price_value > 0

      price_last_updated = begin
        Time.parse(e10_price['price_last_updated'])
      rescue
        nil
      end
      return unless price_last_updated

      # Find the station
      station = Pp::Station.find_by(node_id: node_id)
      return unless station

      # Check if we already have this exact price point
      existing = station.prices.find_by(price_last_updated: price_last_updated)
      if existing
        sync_log.records_unchanged += 1
        return
      end

      # Create new price record
      station.prices.create!(
        price_pence: price_value,
        price_last_updated: price_last_updated
      )
      sync_log.records_created += 1
      puts "  Price: #{station.name} - #{price_value}p at #{price_last_updated}"
    end
  end
end
