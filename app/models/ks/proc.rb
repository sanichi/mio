module Ks
  class Proc < ActiveRecord::Base
    MAX_COMMAND = 100
    MAX_SHORT = 32

    belongs_to :top, class_name: "Ks::Top", foreign_key: :ks_top_id, counter_cache: true

    validates :pid, numericality: { only_integer: true, greater_than: 0 }
    validates :mem, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :command, presence: true, length: { maximum: MAX_COMMAND }
    validates :command, length: { maximum: MAX_COMMAND }, allow_nil: true

    default_scope { order(mem: :desc) }
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
