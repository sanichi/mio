require 'amazing_print'

module PrivateUserCache
  @@users = Hash.new

  def user(id)
    return nil unless id.is_a?(Integer) && id > 0
    return @@users[id] if @@users.has_key?(id)
    @@users[id] = User.find_by(id: id)
  end
end

class SessionStat # abstract
  include PrivateUserCache

  @@max = 0

  def max = @@max
  def update_max(length)
    @@max = length if length > @@max
  end
  def indent = "  "
  def id_error(id) = "ID #{id.abs} ERROR"

  def name(id)
    return "NIL" if id.nil?
    return "INVALID (#{id.class})" unless id.is_a?(Integer)
    return "ZERO" if id == 0
    return "NEGATIVE (#{id})" if id < 0
    user = user(id)
    user ? user.email : "UNKNOWN[#{id}]"
  end
end

class SesCountStat < SessionStat
  def initialize
    @count = 0
  end

  def add
    @count += 1
  end

  def list
    puts "sessions (#{@count})"
    puts
  end
end

class LastPathStat < SessionStat
  def initialize
    @path_counts = Hash.new(0)
  end

  def add(path)
    return if path.nil?
    path = "INVALID (#{path.class})" unless path.is_a?(String)
    path = "EMPTY" unless path.present?
    path.sub!(/\/(%[A-F0-9][A-F0-9])+\z/, "/nnn")
    path.sub!(/\/(\d)+\z/, "/nnn")
    path.gsub!(/\/(\d)+\//, "/nnn/")
    @path_counts[path] += 1
    update_max(path.length)
    path
  end

  def list
    puts "last_path (#{@path_counts.size})"
    @path_counts.sort_by{|path, count| -count}.each do |path, count|
      puts "#{indent}#{path} #{'.' * (max - path.length + indent.length)} #{count}"
    end
    puts
  end
end

class UserPathStat < SessionStat
  def initialize
    @user_path_counts = Hash.new { |h, k| h[k] = Hash.new(0) }
    @user_counts = Hash.new(0)
  end

  def add(id, last_path)
    return if id.nil?
    name = name(id)
    @user_counts[name] += 1
    @user_path_counts[name][last_path] += 1 if last_path
    update_max(name.length)
    name
  end

  def list
    puts "user_id (#{@user_counts.size})"
    @user_counts.sort_by{|user, count| -count}.each do |user, count|
      puts "#{indent}#{user} #{'.' * (max - user.length + indent.length)} #{count}"
    end
    puts

    puts "user last_paths (#{@user_path_counts.size})"
    @user_path_counts.each do |user, path_counts|
      puts "  #{user} #{path_counts.size}"
      path_counts.each do |path, count|
        puts "#{indent}#{indent}#{path} #{'.' * (max - path.length)} #{count}"
      end
    end
    puts
  end
end

class CreatedAtStat < SessionStat
  def initialize
    @days_ago_counts = Hash.new(0)
  end

  def add(created_at, id)
    if !created_at.respond_to?(:to_date)
      days_ago = -id
    else
      days_ago = (Date.current - created_at.to_date).to_i
      days_ago = -id if days_ago < 0
      @days_ago_counts[days_ago] += 1
      if days_ago >= 0
        update_max(days_ago.to_s.length)
      else
        update_max(id_error(days_ago))
      end
      days_ago
    end
  end

  def list
    puts "created_at days ago (#{@days_ago_counts.size})"
    @days_ago_counts.sort_by{|days_ago, count| -days_ago}.each do |days_ago, count|
      days_ago = id_error(days_ago) if days_ago < 0
      puts "#{indent}#{days_ago} #{'.' * (max - days_ago.to_s.length + indent.length)} #{count}"
    end
    puts
  end
end

class UpdatedAtStat < SessionStat
  def initialize
    @days_ago_counts = Hash.new(0)
  end

  def add(updated_at, id)
    if !updated_at.respond_to?(:to_date)
      days_ago = -id
    else
      days_ago = (Date.current - updated_at.to_date).to_i
      days_ago = -id if days_ago < 0
      @days_ago_counts[days_ago] += 1
      if days_ago >= 0
        update_max(days_ago.to_s.length)
      else
        update_max(id_error(days_ago))
      end
      days_ago
    end
  end

  def list
    puts "updated_at days ago (#{@days_ago_counts.size})"
    @days_ago_counts.sort_by{|days_ago, count| -days_ago}.each do |days_ago, count|
      days_ago = id_error(days_ago) if days_ago < 0
      puts "#{indent}#{days_ago} #{'.' * (max - days_ago.to_s.length + indent.length)} #{count}"
    end
    puts
  end
end

class AgeStat < SessionStat
  def initialize
    @age_counts = Hash.new(0)
  end

  def add(created_at, updated_at, id)
    if !created_at.respond_to?(:to_date) || !updated_at.respond_to?(:to_date)
      age = -id
    else
      age = (updated_at.to_date - created_at.to_date).to_i
      age = -id if age < 0
    end
    @age_counts[age] += 1
    if age >= 0
      update_max(age.to_s.length)
    else
      update_max(id_error(age).length)
    end
    age
  end

  def list
    puts "session age counts (#{@age_counts.size})"
    @age_counts.sort_by{|age, count| -age}.each do |age, count|
      age = id_error(age) if age < 0
      puts "#{indent}#{age} #{'.' * (max - age.to_s.length + indent.length)} #{count}"
    end
    puts
  end
end

class SessionLister # abstract
  include PrivateUserCache

  def initialize(max)
    @max = max
    @sessions = []
  end

  def add(session)
    if interesting?(session)
      @sessions << session
    end
  end

  def list
    order
    @sessions.first(@max).each_with_index do |s, i|
      before(s,i)
      ap s
      after(s,i)
    end
  end

  # print something before the session, may be overridden
  def before(s,i)
    puts "================================== session #{i+1} =================================="
  end

  # print something after the session, may be overridden
  def after(s,i)
  end
end

class UserSessionLister < SessionLister
  def order = @sessions.sort_by! { |s| -s.updated_at.to_i }
  def interesting?(s) = s.data["user_id"].is_a?(Integer)

  def before(s,i)
    super
    user = user(s.data["user_id"])
    if user
      puts "#{user.email} (#{user.id})"
    else
      puts "user (#{s.data["user_id"]}) UNKNOWN"
    end
  end
end

SESSION_STAT_TYPES = {
  ses: "session count",
  lps: "last_path counts",
  ups: "user counts and user's last_path counts",
  cre: "created_at days ago counts",
  upd: "updated_at days ago counts",
  age: "session age in days",
}.with_indifferent_access

SESSION_LIST_TYPES = {
  usr: "logged in sessions sorted by descending updated time",
}.with_indifferent_access

SESSION_LIST_NUM_DEFAULT = 5
SESSION_LIST_TYPE_DEFAULT = "usr"

namespace :session do
  desc "print stats about session stores"
  task :stat, [:stat] => :environment do |task, args|
    stat = args[:stat].present? ? args[:stat].gsub(/\s+/,"").downcase : "all"
    stat = SESSION_STAT_TYPES.keys.join(":") if stat == "all"
    list = stat.split(":").filter{ |s| SESSION_STAT_TYPES.has_key?(s) }.map(&:to_sym)
    if list.empty?
      puts "invalid stat code(s): #{args[:stat]}"
      exit
    end

    ses = SesCountStat.new
    lps = LastPathStat.new
    ups = UserPathStat.new
    cre = CreatedAtStat.new
    upd = UpdatedAtStat.new
    age = AgeStat.new

    ActiveRecord::SessionStore::Session.find_each do |session|
      ses.add
      data = session.data
      path = lps.add(data["last_path"])
      ups.add(data["user_id"], path)
      cre.add(session.created_at, session.id)
      upd.add(session.updated_at, session.id)
      age.add(session.created_at, session.updated_at, session.id)
    rescue => e
      puts e.message
    end

    list.each do |stat|
      case stat
      when :ses then ses.list
      when :lps then lps.list
      when :ups then ups.list
      when :cre then cre.list
      when :upd then upd.list
      when :age then age.list
      end
    end
  end

  desc "print the available stat codes"
  task :stat_codes do |task|
    puts "use one or more (colon separated) of the 3-letter codes below as an optional parameter to session:stat"
    puts
    puts "  $ bin/rake sesson:stat # defaults to all"
    puts "  $ bin/rake sesson:stat\\[ups\\]"
    puts "  $ bin/rake sesson:stat\\[ses:ups\\]"
    puts
    SESSION_STAT_TYPES.each do |code, stat|
      puts "#{code}: #{stat}"
    end
  end

  desc "list a number of session stores that match various criteria"
  task :list, [:code,:num] => :environment do |task, args|
    code = args[:code].present? ? args[:code].gsub(/\s+/,"").downcase : SESSION_LIST_TYPE_DEFAULT
    unless SESSION_LIST_TYPES.has_key?(code)
      puts "invalid list code: (#{args[:code]})"
      exit
    end
    num = args[:num].present? ? args[:num].to_i : SESSION_LIST_NUM_DEFAULT
    unless num > 0
      puts "invalid number of sessions to list: (#{args[:num]})"
      exit
    end

    lister =
      case code
      when "usr"
        UserSessionLister.new(num)
      end

    ActiveRecord::SessionStore::Session.find_each { |session| lister.add(session) }

    AmazingPrint.defaults = {
      indent: -2,
      sort_keys: true,
    }

    lister.list
  end

  desc "print the available top codes"
  task :list_codes do |task|
    puts "use one of the 3-letter codes below as a parameter to session:top"
    puts "provide the number of sessions to list or leave as default"
    puts
    puts "  $ bin/rake sesson:list             # code defaults to '#{SESSION_LIST_TYPE_DEFAULT}'"
    puts "  $ bin/rake sesson:list\\[usr\\]      # number defaults to #{SESSION_LIST_NUM_DEFAULT}"
    puts "  $ bin/rake sesson:list\\[usr,10\\]   # specify code and number"
    puts
    SESSION_LIST_TYPES.each do |code, top|
      puts "#{code}: #{top}"
    end
  end
end
