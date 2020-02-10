module Splitable
  FEN1 = /\n*\s*(FEN\s*"[^"]*")\s*\n*/
  FEN2 = /\AFEN\s*"([^"]*)"\z/

  def split(notes)
    html = []
    fens = []
    fen_id = 0
    parts = notes.present? ? notes.split(FEN1) : []
    parts.each do |p|
      if p.present?
        if p.match(FEN2)
          html.push "FEN__#{fen_id}"
          fen_id += 1
          fens.push $1
        else
          html.push to_html(p)
        end
      end
    end
    [html, fens]
  end
end
