module Wk
  class Example < ApplicationRecord
    include Constrainable
    include Pageable

    MAX_EXAMPLE = 200
    PATTERN = /\{([^}|]+)(?:\|([^}|]+))?\}/
    PPATTERN = /「([^」|]+)(?:\|([^」|]+))?」/

    has_and_belongs_to_many :vocabs
    has_one :test, as: :testable, dependent: :destroy

    after_create { create_test! }

    before_validation :clean_up
    after_save :update_vocabs

    validates :english, :japanese, presence: true, length: { maximum: MAX_EXAMPLE }

    scope :by_updated_at, -> { order(updated_at: :desc) }

    def self.search(params, path, opt={})
      matches = by_updated_at
      if sql = cross_constraint(params[:query], %w{english japanese})
        matches = matches.where(sql)
      end
      paginate(matches, params, path, opt)
    end

    def japanese_markdown(bold: nil)
      current = current_vocabs
      japanese.gsub(PATTERN) do |match|
        display = $1
        characters = $2 || display
        if bold && bold == characters
          "**#{display}**"
        else
          vocab = current[characters]
          vocab ? vocab.to_markdown(display: display) : match
        end
      end
    end

    def japanese_html(bold: nil, target: nil)
      current = current_vocabs
      target = %(target="#{target}") if target
      japanese.gsub(PATTERN) do |match|
        display = $1
        characters = $2 || display
        if bold && bold == characters
          %(<bold>#{display}</bold>)
        else
          vocab = current[characters]
          if vocab
            %(<a href="/wk/vocabs/#{characters}" #{target}>#{display}</a>)
          else
            match
          end
        end
      end.gsub(PPATTERN) do |match|
        display = $1
        jname = $2 || display
        if place = Place.find_by(jname: jname)
          %(<a href="/places/#{place.id}" #{target}>#{display}</a>)
        else
          match
        end
      end.html_safe
    end

    def to_markdown(bold: nil)
      "* #{japanese_markdown(bold: bold)}\n    * #{english}\n"
    end

    private

    def clean_up
      if english.blank? && japanese&.match(/\A\s*([\p{Any}]+[^\p{ASCII}])\s*([\p{ASCII}]+)\z/)
        self.japanese = $1
        self.english = $2
      end
      english&.squish!
      japanese&.gsub!(/\s|　/, "")
    end

    def current_vocabs
      vocabs.each_with_object({}) { |v, h| h[v.characters] = v }
    end

    def update_vocabs
      remaining = current_vocabs
      japanese.scan(PATTERN) do |display, characters|
        characters = display if !characters
        if vocabs.find_by(characters: characters)
          remaining.delete(characters)
          next
        end
        vocab = Vocab.find_by(characters: characters)
        vocabs << vocab if vocab
      end
      remaining.each_value { |vocab| vocabs.destroy(vocab) }
    end
  end
end
