class Admin::CommentsController < Admin::BaseController
  #before_filter :load_comment

  respond_to :html

  def index

  end

  def create

    @comment = Comment.new(params[:comment])
    if @comment.save

    end

    @ticket = Ticket.find(@comment.commentable_id)
    if params[:ticket] == "Close"
      @ticket.update_attributes(:status => "close")
    end
    redirect_to admin_ticket_path(@ticket)

  end

  private
  def load_comment
    @comment = Comment.find(params[:id])
  end

end