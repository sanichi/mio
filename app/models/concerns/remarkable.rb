module Remarkable
  class CustomRenderer < Redcarpet::Render::HTML
    LINK_WITH_TARGET = /\A(.+)\|(\w+)\z/

    def link(link, title, alt_text)
      if link.match LINK_WITH_TARGET
        '<a href="%s" target="%s">%s</a>' % [$1, $2, alt_text]
      else
        '<a href="%s">%s</a>' % [link, alt_text]
      end
    end

    def autolink(link, link_type)
      if link.match LINK_WITH_TARGET
        '<a href="%s" target="%s">%s</a>' % [$1, $2, $1]
      else
        '<a href="%s">%s</a>' % [link, link]
      end
    end
  end

  def to_html(text, filter_html: false)
    return "" unless text.present?
    renderer = CustomRenderer.new(filter_html: filter_html)
    options =
    {
      autolink: true,
      fenced_code_blocks: true,
      no_intra_emphasis: true,
      strikethrough: true,
      tables: true,
      underline: true,
    }
    markdown = Redcarpet::Markdown.new(renderer, options)
    markdown.render(text).html_safe
  end
end
