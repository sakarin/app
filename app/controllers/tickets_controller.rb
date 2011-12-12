class TicketsController < Spree::BaseController
  before_filter :load_object, :only => [:index, :show, :edit, :update]
  before_filter :load_ticket, :only => [:show, :edit, :update]
  helper :users


  respond_to :html


  def index
    unless current_user.nil?
      @tickets = Ticket.find_all_by_user_id(current_user.id)
      @ticket = Ticket.new(:user_id => current_user.id, :question_category_id => QuestionCategory.first.id)
      respond_with(@tickets)
    else
      redirect_to :root
    end
  end


  def create
    @ticket = Ticket.new(params[:ticket])
    if @ticket.save

    else

    end

    redirect_to tickets_url
  end


  def update

    if @ticket.update_attributes(params[:ticket])
      flash.notice = t('purchase_update')
      redirect_to edit_ticket_url(@ticket)
    else
      flash[:error] = t('cannot_perform_operation')
      redirect_to edit_ticket_url(@ticket)
    end
  end


  private
  def load_object
    @user ||= current_user
    #authorize! params[:action].to_sym, @user
  end

  def load_ticket
    @ticket = Ticket.find(params[:id])
  end

end
