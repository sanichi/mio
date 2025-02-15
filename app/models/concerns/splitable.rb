module Splitable
  FEN1 = /\n*\s*(FEN\s*"[^"]*")\s*\n*/
  FEN2 = /\AFEN\s*"([^"]*)"\z/

  def split(notes)
    html = []
    parts = notes.present? ? notes.split(FEN1) : []
    parts.each do |p|
      if p.present?
        if p.match(FEN2)
          html.push "FEN__#{$1}"
        else
          html.push to_html(p)
        end
      end
    end
    html
  end
end
