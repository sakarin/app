class Admin::TicketsController < Admin::BaseController
  before_filter :load_object, :only => [:index, :show, :edit, :update]
  before_filter :load_ticket, :only => [:show, :edit, :update]
  #helper :users


  respond_to :html


  def index
    @tickets = Ticket.all
   # @ticket = Ticket.new(:user_id => current_user.id, :question_category_id => QuestionCategory.first.id)
    respond_with(@tickets)
  end



  def create
     @ticket = Ticket.new(params[:ticket])
     if @ticket.save

     else

     end

     redirect_to admin_tickets_url
  end

  #def show
  #  @ticket = Ticket.new(params[:ticket])
  #  respond_with(@ticket)
  #  #@ticket.user.email
  #end



  def update

    if @ticket.update_attributes(params[:ticket])
      flash.notice = t('purchase_update')
      redirect_to edit_admin_ticket_url(@ticket)
    else
      flash[:error] = t('cannot_perform_operation')
      redirect_to edit_admin_ticket_url(@ticket)
    end
  end







  private
    def load_object
      @user ||= current_user
      authorize! params[:action].to_sym, @user
    end

    def load_ticket
       @ticket = Ticket.find(params[:id])
    end

end
