module Wk
  class Group < ApplicationRecord
    include Constrainable
    include Pageable

    CATEGORIES = %w/synonyms antonyms sounds_like related_to/
    MAX_CATEGORY = 20
    MAX_VOCAB_LIST = 200

    has_and_belongs_to_many :vocabs

    before_validation :clean_up
    after_save :update_vocabs

    validates :category, inclusion: { in: CATEGORIES }
    validates :vocab_list, presence: true, length: { maximum: MAX_VOCAB_LIST }
    validate :check_list, :check_size, :check_duplication

    scope :by_updated_at, -> { order(updated_at: :desc) }

    def self.search(params, path, opt={})
      matches = by_updated_at
      if CATEGORIES.include?(params[:category])
        matches = matches.where(category: params[:category])
      end
      if sql = cross_constraint(params[:query], %w{vocab_list})
        matches = matches.where(sql)
      end
      paginate(matches, params, path, opt)
    end

    def to_markdown(bold: nil)
      "%s: %s.\n\n" % [I18n.t("wk.group.categories.#{category}"), vocabs.map{ |v| v.to_markdown(bold: bold) }.join(", ")]
    end

    private

    def clean_up
      self.vocab_list = vocab_list.to_s.squish.split(" ").uniq.join(" ")
    end

    def check_list
      unknown = []
      vocab_list.split(" ").each do |characters|
        unless Wk::Vocab.find_by(characters: characters)
          unknown.push characters
        end
      end
      errors.add(:vocab_list, "unknown vocabs#{unknown.size == 1 ? '' : 's'} for #{unknown.join(', ')}") unless unknown.empty?
    end

    def check_size
      errors.add(:vocab_list, "must have at least two vocabs") unless vocab_list.split(" ").size > 1
    end

    def check_duplication
      if CATEGORIES.include?(category)
        dups = []
        vocab_list.split(" ").each do |characters|
          if self.class.where.not(id: id).where(category: category).where("vocab_list ~ '(^| )#{characters}( |$)'").count > 0
            dups.push characters
          end
        end
        errors.add(:vocab_list, "duplicate group#{dups.size == 1 ? '' : 's'} for #{dups.join(', ')}") unless dups.empty?
      end
    end

    def update_vocabs
      self.vocabs = vocab_list.split(" ").map do |characters|
        Vocab.find_by(characters: characters)
      end.compact
    end
  end
end
