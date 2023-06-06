module Accentable
  extend ActiveSupport::Concern

  # pitch accent patterns
  HEIBAN = 0
  ATAMADAKA = 1
  NAKADAKA = 2
  ODAKA = 3

  # special accent_position which means we've looked but can‘t determine it
  # when accent_position is nil, it means we haven't even tried to find out yet
  UNKNOWN = -1

  MAX_CHARACTERS = 24
  MAX_ACCENT_PATTERN = ODAKA
  MIN_ACCENT_PATTERN = HEIBAN
  MIN_ACCENT_POSITION = UNKNOWN

  included do
    def accent_display
      case accent_position
      when nil     then "?"
      when UNKNOWN then "?"
      else accent_position.to_s
      end
    end

    def pattern_colour
      if accent_pattern.present?
        %w/secondary success warning info/[accent_pattern] || "danger"
      elsif accent_position == UNKNOWN
        "secondary"
      else
        "outline-secondary"
      end
    end

    # to be able to remove old color classes in quick_accent_update.js.erb
    def pattern_colours
      %w/secondary success warning info danger outline-secondary/
    end

    # this is what gets run when a quick_accent_update ajax request is procesed
    # note that save should cause validation by set_accent_pattern below
    def update_accent(new_accent)
      if new_accent == "?"
        self.accent_position = nil
      elsif new_accent == "-"
        self.accent_position = UNKNOWN
      else
        i = new_accent.to_i
        self.accent_position = i if i >= 0
      end
      save
    end

    private

    def set_accent_pattern
      if changes.has_key?("characters") || changes.has_key?("accent_position")
        if accent_position.is_a?(Integer)
          morae = count_morae
          self.accent_position = morae if accent_position > morae
          self.accent_position = UNKNOWN if accent_position < MIN_ACCENT_POSITION
          self.accent_pattern =
            case accent_position
            when UNKNOWN
              nil
            when 0
              HEIBAN
            when 1
              ATAMADAKA
            when morae
              ODAKA
            else
              NAKADAKA
            end
        else
          self.accent_pattern = nil
        end
      end
    end

    def count_morae
      # get a throwaway copy of the reading, handling the nil case
      string = characters.to_s.dup
      # make sure to get only the first reading if there's more than one
      string.sub!(/,.*/, "")
      # count 1 for all hiragana, katakana and the katakana elongation symbol
      full = string.each_char.map{ |c| c =~ /\A[ぁ-んァ-ンー]\z/ ? 1 : 0 }.sum
      # count 1 for all small hiragana and katakana (but not the っ or ッ)
      tiny = string.each_char.map{ |c| c =~ /\A[ぁァぃィぅゥぇェぉォゃャゅュょョ]\z/ ? 1 : 0 }.sum
      # the number of morae is the difference between these two
      full - tiny
    end
  end
end
