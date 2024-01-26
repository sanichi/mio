module StarLink
  extend ActiveSupport::Concern

  PATTERN = /
    \{
    ([^}|]+)
    (?:\|([^}|]+))?
    \}
  /x

  included do
    def link_stars(text)
      return text unless text.present?
      text.gsub(PATTERN) do |match|
        display = $1
        name = $2 || display
        if star = Star.find_by(name: name)
          star.to_markdown(display, self)
        elsif constellation = Constellation.find_by(name: name)
          constellation.to_markdown(display, self)
        else
          match
        end
      end
    end
  end
end
