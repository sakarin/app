class Ticket < ActiveRecord::Base

  acts_as_commentable


  belongs_to :question_category
  belongs_to :user

  scope :by_customer, lambda {|customer| joins(:user).where("users.email =?", customer)}

end