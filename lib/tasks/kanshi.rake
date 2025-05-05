##########################################################################################################
# Normally meant to be run from cron on a regular (e.g. every hour) basis.                               #
#                                                                                                        #
#   0 * * * * cd /var/www/me.mio/current; RAILS_ENV=production bin/rails kanshi:import >> log/cron.log 2 #
#                                                                                                        #
# However, can be run by hand as well in which case the print flag should be used.                       #
#                                                                                                        #
#   $ RAILS_ENV=production bin/rails kanshi:import\[p\]                                                  #
#                                                                                                        #
# Can also be run by hand in development but, in that case, setup some data first.                        #
#                                                                                                        #
#   ❯ lnx                                                                                                #
#   ❯ ./atsumeri -d                                                                                      #
#   ❯ ./atsumeri -gnt                                                                                    #
#   ❯ mio                                                                                                #
#   ❯ bin/rails kanshi:import\[p\]                                                                       #
##########################################################################################################
namespace :kanshi do
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
end
