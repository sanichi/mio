module Shortenable
  def short_version(cmd, max)
    version = case cmd
      when nil                                                                    then nil
      when /\APassenger AppPreloader: \/var\/www\/([a-z]+\.)?([a-z]+)\/current/   then "#{$2} preloader"
      when /\APassenger RubyApp: \/var\/www\/([a-z]+\.)?([a-z]+)\/current/        then "#{$2} app"
      when /\APassenger core\z/                                                   then "passenger core"
      when /\APassenger watchdog\z/                                               then "passenger watchdog"
      when /\Apostgres: sanichi ([a-z]+)_production/                              then "#{$1} db"
      when /\Apostgres:(\s\w+){1,2}\z/                                            then cmd
      when /\Asshd: (\w+\s)?\[(\w+)\]\z/                                          then "sshd: #{$1}#{$2}[#{$3}]"
      when /\A\/usr\/bin\/python\d\.\d \/usr\/bin\/dnf makecache/                 then "dnf makecache"
      when /\A\/usr\/lib\/systemd\/systemd --switched-root/                       then "systemd (init)"
      when /\A\/usr\/lib\/systemd\/systemd --user/                                then "systemd (user)"
      when /\A\/usr\/libexec\/pcp\/bin\/pmlogger/                                 then "pmlogger"
      when /\A\/usr\/sbin\/CROND/                                                 then "CROND"
      when /\A\/usr\/sbin\/httpd -DFOREGROUND\z/                                  then "httpd"
      when /\A\/usr\/sbin\/NetworkManager --no-daemon/                            then "network manager"
      when /\A\/usr\/sbin\/rsyslogd/                                              then "rsyslogd"
      else nil
    end
    version = version.truncate(max) if version.present? && version.length > max
    version
  end
end
