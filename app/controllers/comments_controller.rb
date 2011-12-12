class CommentsController < Spree::BaseController
  #before_filter :load_comment

  respond_to :html

  def index

  end

  def create

    @comment = Comment.new(params[:comment])
    if @comment.save

    end

    @ticket = Ticket.find(@comment.commentable_id)
    redirect_to ticket_path(@ticket)

  end

  private
  def load_comment
    @comment = Comment.find(params[:id])
  end

end