namespace :kanshi do
  #############################################################################################################
  # Normally meant to be run from cron on a regular (e.g. every hour) basis.                                  #
  #                                                                                                           #
  #   0 * * * * cd /var/www/me.mio/current; RAILS_ENV=production bin/rails kanshi:import >> log/cron.log 2>&1 #
  #                                                                                                           #
  # However, can be run by hand as well in which case the print flag should be used.                          #
  #                                                                                                           #
  #   $ RAILS_ENV=production bin/rails kanshi:import\[p\]                                                     #
  #                                                                                                           #
  # Can also be run by hand in development but, in that case, setup some data first.                          #
  #                                                                                                           #
  #   ❯ lnx                                                                                                   #
  #   ❯ ./atsumeri -d                                                                                         #
  #   ❯ ./atsumeri -gnt                                                                                       #
  #   ❯ mio                                                                                                   #
  #   ❯ bin/rails kanshi:import\[p\]                                                                          #
  #############################################################################################################
  desc "import kanshi data"
  task :import, [:print] => :environment do |task, args|
    # Do the import, get back a Ks::Journal.
    journal = Ks::import

    # Did that go okay?
    msg = "#{journal.okay? ? 'Successful' : '**Problematic**'} Kanshi import (jrnl #{journal.id})"

    # Give some feedback.
    if args[:print] == "p"
      puts msg
      puts journal.note
    else
      Rails.logger.info msg
      Rails.logger.info journal.note
    end
  end

  #############################################################################################################
  # Get short versions of ks_procs commands and store in the short column. Print stats about how many were    #
  # changed, unchanged, unchangable or skipped. Use option to force reconsidering those already with short    #
  # versions.                                                                                                 #
  #                                                                                                           #
  # Can be run on the development machine for testing purposes:                                               #
  #                                                                                                           #
  #   ❯ mio                                                                                                   #
  #   ❯ bin/rails kanshi:procs          # process only those without a short version already (fastest)        #
  #   ❯ bin/rails kanshi:procs \[a\]    # process all but don't update old ones if they've changed            #
  #   ❯ bin/rails kanshi:procs \[a,u\]  # process all and update old ones if they've changed                  #
  #                                                                                                           #
  # You could run this in production, for example:                                                            #
  #                                                                                                           #
  #   $ RAILS_ENV=production bin/rails kanshi:shorten                                                         #
  #                                                                                                           #
  # or as a cron job:                                                                                         #
  #                                                                                                           #
  #   0 1 * * * cd /var/www/me.mio/current; RAILS_ENV=production bin/rails kanshi:procs >> log/cron.log 2>&1  #
  #############################################################################################################
  desc "create short versions of commands"
  task :procs, [:all, :update] => :environment do |task, args|
    all = args[:all] == "a"
    update = args[:update] == "u"
    procs = (all ? Ks::Proc.all : Ks::Proc.where(short: nil)).to_a
    stats = Hash.new(0)
    stats["total"] = procs.size

    procs.each do |proc|
      version = proc.short_version
      if version.present?
        if version.length > Ks::Proc::MAX_SHORT
          stats["bad versions"] += 1
        else
          if proc.short.present?
            if proc.short == version
              stats["unchanged"] += 1
            else
              if update
                proc.update_column(:short, version)
                stats["updated"] += 1
              else
                stats["could have updated"] += 1
              end
            end
          else
            proc.update_column(:short, version)
            stats["created"] += 1
          end
        end
      else
        if proc.short.present?
          if update
            proc.update_column(:short, nil)
            stats["deleted"] += 1
          else
            stats["could have deleted"] += 1
          end
        else
          stats["still no version"] += 1
        end
      end
    end

    margin = 30
    stats.each_pair do |key, val|
      puts "%s%s %d" % [key, key.length >= margin ? '' : '.' * (margin - key.length), val]
    end
  end

  ##################################################################################################################
  # Delete old ks_journals (and everything that belongs to them) so that the data doesn't build up forever.        #
  #                                                                                                                #
  # Can be run on the development machine for testing purposes:                                                    #
  #                                                                                                                #
  #   ❯ mio                                                                                                        #
  #   ❯ bin/rails kanshi:prune\[80]      # dry-run, set cut-off in days, lists what it would do                    #
  #   ❯ bin/rails kanshi:prune\[-100\]   # the real-deal                                                           #
  #   ❯ bin/rails kanshi:prune\[-5_\]    # use an underscore to confirm a low (< 50) number of days                #
  #                                                                                                                #
  # You can run by hans in production, for example:                                                                #
  #                                                                                                                #
  #   $ RAILS_ENV=production bin/rails kanshi:prune\[50\]                                                          #
  #                                                                                                                #
  # or as a cron job:                                                                                              #
  #                                                                                                                #
  #   0 1 2 * * cd /var/www/me.mio/current; RAILS_ENV=production bin/rails kanshi:prune[-90] >> log/cron.log 2>&1  #
  ##################################################################################################################
  desc "prune old ks_journals"
  task :prune, [:count] => :environment do |task, args|
    count = args[:count].to_i
    min = args[:count].match?(/_\z/) ? 1 : 50
    if count == 0
      puts "please specify a cut-off in days (positive for dry-run, negative for actual deletions)"
    elsif count.abs < min
      puts "please specify a cut-off of at least #{min} days"
    else
      dry_run = count > 0
      cut_off = Date.today.days_ago(count.abs)
      if dry_run
        puts "dry-run (specify negative amount to actually delete)"
      else
        puts "starting ks_journals prune at #{Time.now.to_fs(:db)}"
      end
      puts "cut-off date: #{cut_off.to_fs(:db)}"
      journals = Ks::Journal.order(:created_at).where("created_at < ?", cut_off.to_fs(:db)).to_a
      puts "journals to delete (before protection): #{journals.size}"
      unprotected = journals.select { |j| !Ks::Journal::PROTECTED.include?(j.created_at.strftime("%Y-%m-%d")) }
      puts "journals to delete (after protection): #{unprotected.size}"
      if unprotected.size > 0
        puts "before:"
        puts "  journals... #{Ks::Journal.count}"
        puts "  boots...... #{Ks::Boot.count}"
        puts "  tops....... #{Ks::Top.count}"
        puts "  mems....... #{Ks::Mem.count}"
        puts "  procs...... #{Ks::Proc.count}"
        if !dry_run
          unprotected.each { it.destroy! }
          puts "after:"
          puts "  journals... #{Ks::Journal.count}"
          puts "  boots...... #{Ks::Boot.count}"
          puts "  tops....... #{Ks::Top.count}"
          puts "  mems....... #{Ks::Mem.count}"
          puts "  procs...... #{Ks::Proc.count}"
          puts "finished ks_journals prune at #{Time.now.to_fs(:db)}"
        end
      end
    end
  end
end
