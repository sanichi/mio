module ApplicationHelper
  def pagination_links(pager)
    links = Array.new
    links.push(link_to t("pagination.frst"), pager.frst_page, remote: pager.remote) if pager.after_start?
    links.push(link_to t("pagination.next"), pager.next_page, remote: pager.remote) if pager.before_end?
    links.push(link_to t("pagination.prev"), pager.prev_page, remote: pager.remote) if pager.after_start?
    links.push(link_to t("pagination.last"), pager.last_page, remote: pager.remote) if pager.before_end?
    raw "#{pager.min_and_max} #{t('pagination.of')} #{pager.count} #{links.size > 0 ? '∙' : ''} #{links.join(' ∙ ')}"
  end
  
  def nobr(str)
    str.to_s.gsub(/-/, "&#8209;").html_safe
  end
end
