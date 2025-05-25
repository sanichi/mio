module Shortenable
  def short_version(cmd, max)
    version = case cmd
      when nil                                                                    then nil
      when /\APassenger AppPreloader: \/var\/www\/([a-z]+\.)?([a-z]+)\/current/   then "#{$2} preloader"
      when /\APassenger RubyApp: \/var\/www\/([a-z]+\.)?([a-z]+)\/current/        then "#{$2} app"
      when /\APassenger core\z/                                                   then "passenger core"
      when /\Apostgres: sanichi ([a-z]+)_production/                              then "#{$1} db"
      when /\Apostgres:(\s\w+){1,2}\z/                                            then cmd
      when /\Asshd: (\w+\s)?\[(\w+)\]\z/                                          then "sshd: #{$1}#{$2}[#{$3}]"
      when /\A\/usr\/bin\/python\d\.\d \/usr\/bin\/dnf makecache/                 then "dnf makecache"
      when /\A\/usr\/lib\/systemd\/systemd --switched-root/                       then "systemd (init)"
      when /\A\/usr\/lib\/systemd\/systemd --user/                                then "systemd (user)"
      when /\A\/usr\/sbin\/httpd -DFOREGROUND\z/                                  then "httpd"
      when /\A\/usr\/sbin\/NetworkManager --no-daemon/                            then "network manager"
      else nil
    end
    version = version.truncate(max) if version.present? && version.length > max
    version
  end
end

#######################################################################################
# Dump of the top (by %mem) commands found over a 2 week period with frequency.       #
#######################################################################################

# 69979 /usr/sbin/httpd -DFOREGROUND
# 16364 Passenger core
# 12305 /usr/lib/systemd/systemd --user
# 10139 /usr/sbin/rsyslogd -n
#  8275 /usr/lib/systemd/systemd --switched-root --system --deserialize 31 rhgb
#  8222 Passenger RubyApp: /var/www/step/current (production)
#  7368 postgres: checkpointer
#  6527 Passenger RubyApp: /var/www/me.mio/current (production)
#  6193 Passenger RubyApp: /var/www/wd/current (production)
#  6127 Passenger RubyApp: /var/www/smd/current (production)
#  5834 Passenger RubyApp: /var/www/me.hou/current (production)
#  5426 Passenger RubyApp: /var/www/rek/current (production)
#  4603 /usr/sbin/NetworkManager --no-daemon
#  4485 postgres: sanichi mio_production [local] idle
#  3886 /usr/libexec/pcp/bin/pmlogger -N -P -d "/var/log/pcp/pmlogger/LOCALHOSTNAME" -r -T24h10m -c config.d
#  2732 /usr/sbin/CROND -n
#  1645 sshd: [accepted]
#   937 Passenger watchdog
#   396 /usr/lib/systemd/systemd-journald
#   339 /usr/lib/systemd/systemd-logind
#   310 Passenger AppPreloader: /var/www/me.mio/current
#   309 postgres: background writer
#   300 sshd: root [priv]
#   223 (sd-pam)
#   204 postgres: sanichi wd_production [local] idle
#   140 Passenger AppPreloader: /var/www/me.sj/current
#   139 Passenger RubyApp: /var/www/me.sj/current (production)
#   115 sshd: sanichi [priv]
#   101 Passenger AppPreloader: /var/www/me.hou/current
#    93 Passenger RubyApp: /var/www/me.chess/current (production)
#    90 Passenger AppPreloader: /var/www/me.chess/current
#    85 sshd: unknown [priv]
#    65 Passenger AppPreloader: /var/www/me.tmp/current
#    63 Passenger RubyApp: /var/www/me.tmp/current (production)
#    60 Passenger AppPreloader: /var/www/wd/current
#    52 /usr/libexec/nm-dispatcher
#    50 sshd: [net]
#    50 Passenger AppPreloader: /var/www/me.bid/current
#    50 Passenger AppPreloader: /var/www/me.api/current
#    49 postgres: sanichi rek_production [local] idle
#    48 /usr/bin/python3 -s /usr/sbin/firewalld --nofork --nopid
#    42 gawk -f /home/sanichi/bin/toppu.awk
#    41 Passenger RubyApp: /var/www/me.bid/current (production)
#    41 Passenger RubyApp: /var/www/me.api/current (production)
#    31 Passenger AppPreloader: /var/www/me.sta/current
#    30 Passenger RubyApp: /var/www/me.sta/current (production)
#    30 Passenger AppPreloader: /var/www/smd/current
#    26 /usr/bin/python3.9 /usr/bin/dnf makecache --timer
#    25 /usr/libexec/sssd/sssd_kcm --uid 0 --gid 0 --logger=files
#    15 Passenger AppPreloader: /var/www/step/current
#    11 sshd: sanichi@pts/0
#    11 postgres: sanichi smd_production [local] idle
#    10 Passenger AppPreloader: /var/www/rek/current
#    10 bash /home/sanichi/bin/kanshi.sh -bmp
#     7 sshd: root [net]
#     7 postgres: sanichi hou_production [local] idle
#     6 /usr/bin/sh /usr/libexec/pcp/bin/pmlogger_check --skip-primary
#     5 ps -eo pid,rss,args --sort -rss
#     5 postgres: walwriter
#     5 /usr/lib/systemd/systemd-hostnamed
#     3 sshd: unknown [net]
#     3 ruby bin/rails messages:get
#     3 -bash
#     2 sshd: postgres [priv]
#     2 ruby bin/rails c
#     2 /usr/pgsql-17/bin/postgres -D /var/lib/pgsql/17/data/
#     2 /usr/bin/python3 -s /usr/bin/certbot renew --noninteractive --no-random-sleep-on-renew
#     1 sshd: ftp [priv]
#     1 postgres: sanichi rek_production [local] idle in transaction
#     1 postgres: autovacuum launcher
#     1 /usr/lib/polkit-1/polkitd --no-debug
#     1 /usr/bin/systemctl -s HUP kill rsyslog.service
#     1 /usr/bin/sh /usr/libexec/pcp/bin/pmlogger_daily -K
#     1 /home/sanichi/.rbenv/versions/3.4.2/bin/ruby /home/sanichi/.rbenv/versions/3.4.2/bin/bundle install
#  
