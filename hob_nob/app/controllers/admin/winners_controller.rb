class Admin::WinnersController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role
  before_filter :find_winners

	def index
    if @winners.present? 
      @winners = Winner.search(params, @winners) if params[:search].present?
      #@winners = @winners.paginate(page: params[:page], per_page: 10)
    elsif @event.parent_id.present?
      @winners = @winners.paginate(page: params[:page], per_page: 10)
    else
      redirect_to new_admin_event_award_winner_path(:event_id => @award.event_id, :award_id => @award.id)
    end  
	end

	def new
		@winner = @award.winners.build
	end

	def create
		@winner = @award.winners.build(winner_params)
    if @winner.save
      redirect_to admin_event_award_winners_path(:event_id => @award.event_id, :award_id => @award.id)
    else
      render :action => 'new'
    end
	end

	def edit
	end

	def update
		if @winner.update_attributes(winner_params)
      redirect_to admin_event_award_winners_path(:event_id => @award.event_id, :award_id => @award.id)
    else
      render :action => "edit"
    end
	end

	def show
  end

  def destroy
    if @winner.destroy
      redirect_to admin_event_award_winners_path(:event_id => @award.event_id, :award_id => @award.id)
    end
  end

	protected

  def find_winners
  	@award = @event.awards.find_by_id(params[:award_id])
    if @award.present?  
      @winners = @award.winners
      @winner = @winners.find_by_id(params[:id]) if params[:id].present? and @winners.present?
    end  
  end

  def winner_params
    params.require(:winner).permit!
  end

end
