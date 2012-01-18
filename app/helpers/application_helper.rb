module ApplicationHelper
  def site_title
    unless self.current_store.nil?
      self.current_store.seo_title
    else
      ""
    end
  end
end
