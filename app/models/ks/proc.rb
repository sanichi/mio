module Ks
  class Proc < ActiveRecord::Base
    MAX_COMMAND = 100
    MAX_SHORT = 32

    belongs_to :top, class_name: "Ks::Top", foreign_key: :ks_top_id

    validates :pid, numericality: { only_integer: true, greater_than: 0 }
    validates :mem, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :command, presence: true, length: { maximum: MAX_COMMAND }
    validates :command, length: { maximum: MAX_COMMAND }, allow_nil: true

    default_scope { order(mem: :desc) }
  end
end

# -bash
# (sd-pam)
# /home/sanichi/.rbenv/versions/3.4.2/bin/ruby /home/sanichi/.rbenv/versions/3.4.2/bin/bundle install
# /usr/bin/python3 -s /usr/bin/certbot renew --noninteractive --no-random-sleep-on-renew
# /usr/bin/python3 -s /usr/sbin/firewalld --nofork --nopid
# /usr/bin/python3.9 /usr/bin/dnf makecache --timer
# /usr/bin/sh /usr/libexec/pcp/bin/pmlogger_check --skip-primary
# /usr/bin/sh /usr/libexec/pcp/bin/pmlogger_daily -K
# /usr/bin/systemctl -s HUP kill rsyslog.service
# /usr/lib/polkit-1/polkitd --no-debug
# /usr/lib/systemd/systemd --switched-root --system --deserialize 31 rhgb
# /usr/lib/systemd/systemd --user
# /usr/lib/systemd/systemd-hostnamed
# /usr/lib/systemd/systemd-journald
# /usr/lib/systemd/systemd-logind
# /usr/libexec/nm-dispatcher
# /usr/libexec/pcp/bin/pmlogger -N -P -d "/var/log/pcp/pmlogger/LOCALHOSTNAME" -r -T24h10m -c config.d
# /usr/libexec/sssd/sssd_kcm --uid 0 --gid 0 --logger=files
# /usr/pgsql-17/bin/postgres -D /var/lib/pgsql/17/data/
# /usr/sbin/CROND -n
# /usr/sbin/httpd -DFOREGROUND
# /usr/sbin/NetworkManager --no-daemon
# /usr/sbin/rsyslogd -n
# bash /home/sanichi/bin/kanshi.sh -bmp
# gawk -f /home/sanichi/bin/toppu.awk
# Passenger AppPreloader: /var/www/me.api/current
# Passenger AppPreloader: /var/www/me.bid/current
# Passenger AppPreloader: /var/www/me.chess/current
# Passenger AppPreloader: /var/www/me.hou/current
# Passenger AppPreloader: /var/www/me.mio/current
# Passenger AppPreloader: /var/www/me.sj/current
# Passenger AppPreloader: /var/www/me.sta/current
# Passenger AppPreloader: /var/www/me.tmp/current
# Passenger AppPreloader: /var/www/rek/current
# Passenger AppPreloader: /var/www/smd/current
# Passenger AppPreloader: /var/www/step/current
# Passenger AppPreloader: /var/www/wd/current
# Passenger core
# Passenger RubyApp: /var/www/me.api/current (production)
# Passenger RubyApp: /var/www/me.bid/current (production)
# Passenger RubyApp: /var/www/me.chess/current (production)
# Passenger RubyApp: /var/www/me.hou/current (production)
# Passenger RubyApp: /var/www/me.mio/current (production)
# Passenger RubyApp: /var/www/me.sj/current (production)
# Passenger RubyApp: /var/www/me.sta/current (production)
# Passenger RubyApp: /var/www/me.tmp/current (production)
# Passenger RubyApp: /var/www/rek/current (production)
# Passenger RubyApp: /var/www/smd/current (production)
# Passenger RubyApp: /var/www/step/current (production)
# Passenger RubyApp: /var/www/wd/current (production)
# Passenger watchdog
# postgres: autovacuum launcher
# postgres: background writer
# postgres: checkpointer
# postgres: sanichi hou_production [local] idle
# postgres: sanichi mio_production [local] idle
# postgres: sanichi rek_production [local] idle
# postgres: sanichi rek_production [local] idle in transaction
# postgres: sanichi smd_production [local] idle
# postgres: sanichi wd_production [local] idle
# postgres: walwriter
# ps -eo pid,rss,args --sort -rss
# ruby bin/rails c
# ruby bin/rails messages:get
# sshd: [accepted]
# sshd: [net]
# sshd: ftp [priv]
# sshd: postgres [priv]
# sshd: root [net]
# sshd: root [priv]
# sshd: sanichi [priv]
# sshd: sanichi@pts/0
# sshd: unknown [net]
# sshd: unknown [priv]
