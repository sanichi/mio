namespace :session do
  desc "print stats about session stores"
  task :stats => :environment do |task|
    last_paths = Hash.new(0)
    user_ids = Hash.new(0)
    user_last_paths = Hash.new { |h, k| h[k] = Hash.new(0) }
    users = Hash.new
    max = 0

    ActiveRecord::SessionStore::Session.find_each do |session|
      data = session.data

      last_path = data["last_path"]
      if last_path
        last_path = "INVALID" unless last_path.is_a?(String)
        last_path = "EMPTY" unless last_path.present?
        last_path.sub!(/\/(%[A-F0-9][A-F0-9])+\z/, "/nnn")
        last_path.sub!(/\/(\d)+\z/, "/nnn")
        last_paths[last_path] += 1
        max = last_path.length if last_path.length > max
      end

      user_id = data["user_id"]
      if user_id
        if users[user_id]
          user = users[user_id]
        else
          if !user_id.is_a?(Integer)
            user = user_id.class.to_s
          elsif user_id < 0
            user = "NEGATIVE"
          elsif user_id == 0
            user = "ZERO"
          else
            u = User.find_by(id: user_id)
            if u
              user = "#{u.email}"
            else
              user = "UNKNOWN[#{user_id}]"
            end
          end
          users[user_id] = user
        end
        user_ids[user] += 1
        max = user.length if user.length > max
        user_last_paths[user][last_path] += 1 if last_path
      end
    rescue => e
      puts e.message
    end

    puts "last_path (#{last_paths.size})"
    last_paths.sort_by{|path, count| -count}.each do |path, count|
      puts "  #{path} #{'.' * (max - path.length + 2)} #{count}"
    end

    puts "user_id (#{user_ids.size})"
    user_ids.sort_by{|user, count| -count}.each do |user, count|
      puts "  #{user} #{'.' * (max - user.length + 2)} #{count}"
    end

    puts "user last_paths (#{user_last_paths.size})"
    user_last_paths.each do |user, path_counts|
      puts "  #{user} #{path_counts.size}"
      path_counts.each do |path, count|
        puts "    #{path} #{'.' * (max - path.length)} #{count}"
      end
    end
  end
end
