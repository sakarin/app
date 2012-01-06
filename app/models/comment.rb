class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  belongs_to :comment_type

  has_attached_file :attachment, :path => ":rails_root/public/assets/comments/:id/:basename.:extension"

  # NOTE: Comments belong to a user
  belongs_to :user


end
