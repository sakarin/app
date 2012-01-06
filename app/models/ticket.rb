class Ticket < ActiveRecord::Base

  acts_as_commentable


  belongs_to :question_category
  belongs_to :user

  has_attached_file :attachment, :path => ":rails_root/public/assets/tickets/:id/:basename.:extension"

  validates_attachment_size :attachment, :less_than => 2.megabytes
  validates_attachment_content_type :attachment, :content_type => ['image/jpeg', 'image/png', 'image/gif']

  scope :by_customer, lambda {|customer| joins(:user).where("users.email =?", customer)}

  validates_presence_of :title

end