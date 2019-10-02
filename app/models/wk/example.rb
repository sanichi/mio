module Wk
  class Example < ApplicationRecord
    include Constrainable
    include Pageable

    MAX_EXAMPLE = 200
    PATTERN = /\{([^}|]+)(?:\|([^}|]+))?\}/

    has_and_belongs_to_many :vocabs

    before_validation :clean_up
    after_save :update_vocabs

    validates :english, :japanese, presence: true, length: { maximum: MAX_EXAMPLE }

    def self.search(params, path, opt={})
      matches = all
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
          if vocab
            "[#{display}](/wk/vocabs/#{characters})"
          else
            match
          end
        end
      end
    end

    def japanese_html(bold: nil)
      current = current_vocabs
      japanese.gsub(PATTERN) do |match|
        display = $1
        characters = $2 || display
        if bold && bold == characters
          %(<bold>#{display}</bold>)
        else
          vocab = current[characters]
          if vocab
            %(<a href="/wk/vocabs/#{characters}">#{display}</a>)
          else
            match
          end
        end
      end.html_safe
    end

    def to_markdown(bold: nil)
      "* #{japanese_markdown(bold: bold)}\n    * #{english}\n"
    end

    private

    def clean_up
      english&.squish!
      japanese&.squish!
    end

    def current_vocabs
      vocabs.each_with_object({}) { |v, h| h[v.characters] = v }
    end

    def update_vocabs
      current = current_vocabs
      japanese.scan(PATTERN) do |display, characters|
        characters = display if !characters
        next if current.delete(characters) # we have this association already
        vocab = Vocab.find_by(characters: characters)
        next unless vocab # we can't seem to find this Wk::Vocab
        vocabs << vocab
      end
      current.each_value { |vocab| vocabs.destroy(vocab) } # delete any that are no longer used
    end
  end
end
