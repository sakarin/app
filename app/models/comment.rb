class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  belongs_to :comment_type

  has_attached_file :attachment, :path => ":rails_root/public/assets/comments/:id/:basename.:extension"

  validates_attachment_size :attachment, :less_than => 2.megabytes
  validates_attachment_content_type :attachment, :content_type => ['image/jpeg', 'image/png', 'image/gif']

  # NOTE: Comments belong to a user
  belongs_to :user


end
