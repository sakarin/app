class Excel < ActiveRecord::Base

  validates_attachment_content_type :attachment, :content_type => 'application/vnd.ms-excel'
  has_attached_file :attachment, :path => ":rails_root/public/assets/excel/:id/:basename.:extension"

end