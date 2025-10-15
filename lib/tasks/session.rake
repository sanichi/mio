class SessionStat # abstract
  @@max = 0
  @@user = Hash.new

  def max = @@max
  def update_max(length)
    @@max = length if length > @@max
  end
  def indent = "  "

  def user(id)
    return "NIL" if id.nil?
    return "INVALID (#{id.class})" unless id.is_a?(Integer)
    return "ZERO" if id == 0
    return "NEGATIVE (#{id})" if id < 0
    return @@user[id] if @@user[id]
    user = User.find_by(id: id)
    if user
      user = "#{user.email}"
    else
      user = "UNKNOWN[#{id}]"
    end
    @@user[id] = user
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
    name = user(id)
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
    if created_at.nil? || !created_at.respond_to?(:to_date)
      days_ago = -id
    else
      days_ago = (Date.current - created_at.to_date).to_i
      days_ago = -id if days_ago < 0
      @days_ago_counts[days_ago] += 1
      if days_ago >= 0
        update_max(days_ago.to_s.length)
      else
        update_max(session_id_error(days_ago))
      end
      days_ago
    end
  end

  def list
    puts "created_at days ago (#{@days_ago_counts.size})"
    @days_ago_counts.sort_by{|days_ago, count| -days_ago}.each do |days_ago, count|
      days_ago = session_id_error(days_ago) if days_ago < 0
      puts "#{indent}#{days_ago} #{'.' * (max - days_ago.to_s.length + indent.length)} #{count}"
    end
    puts
  end
end

SESSION_STAT_TYPES = {
  ses: "session count",
  lps: "last_path counts",
  ups: "user counts and user's last_path counts",
  cre: "created_at day counts",
}.with_indifferent_access

def session_id_error(id) = "ID #{id.abs} ERROR"

namespace :session do
  desc "print stats about session stores"
  task :stats, [:stat] => :environment do |task, args|
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

    ActiveRecord::SessionStore::Session.find_each do |session|
      ses.add
      data = session.data
      path = lps.add(data["last_path"])
      ups.add(data["user_id"], path)
      cre.add(session.created_at, session.id)
    rescue => e
      puts e.message
    end

    list.each do |stat|
      case stat
      when :ses then ses.list
      when :lps then lps.list
      when :ups then ups.list
      when :cre then cre.list
      end
    end
  end

  desc "print the available stat codes"
  task :codes do |task|
    puts "use one or more (colon separated) of the 3-letter codes below as an optional parameter to session:stats, e.g."
    puts
    puts "  $ bin/rake sesson:stats # defaults to all"
    puts "  $ bin/rake sesson:stats\\[ups\\]"
    puts "  $ bin/rake sesson:stats\\[ses:ups\\]"
    puts
    SESSION_STAT_TYPES.each do |code, stat|
      puts "#{code}: #{stat}"
    end
  end
end
