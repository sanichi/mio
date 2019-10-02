module Wk
  class Example < ApplicationRecord
    include Constrainable
    include Pageable

    MAX_EXAMPLE = 200

    has_and_belongs_to_many :vocabs

    before_validation :clean_up

    validates :english, :japanese, presence: true, length: { maximum: MAX_EXAMPLE }

    def self.search(params, path, opt={})
      matches = all
      if sql = cross_constraint(params[:query], %w{english japanese})
        matches = matches.where(sql)
      end
      paginate(matches, params, path, opt)
    end

    private

    def clean_up
      english&.squish!
      japanese&.squish!
    end
  end
end
