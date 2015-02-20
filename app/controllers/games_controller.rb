class GamesController < ApplicationController
  load_and_authorize_resource
  respond_to :html, :js

  def index
    @weeks = @games.includes(:user, :platforms).scheduled.display_order.group_by{|x| x.scheduled_at.beginning_of_week }.sort.reverse
  end

  def new
  end

  def create
    @game.user = current_user
    if @game.save
      flash[:notice] = "Thanks for submitting, your submission is under review. You'll be emailed if and when your submission is scheduled"
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @comment = Comment.new
    @video = Video.new
    @related_games = @game.find_related_platforms.first(3)
  end

  def upvote
    @game.upvote_by(current_user)
    respond_to do |format|
      format.js { render :vote }
      format.html {redirect_to :back}
    end
  end

  def unupvote
    @game.unvote_by(current_user)
    respond_to do |format|
      format.js { render :vote }
      format.html {redirect_to :back}
    end
  end

  def upload
    uploaded_io = params[:game][:thumbnail]
    File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end
  end

  private
  def game_params
    params.require(:game).permit(:title, :thumbnail, :description, :status, :link, platform_list: [])
  end
end
