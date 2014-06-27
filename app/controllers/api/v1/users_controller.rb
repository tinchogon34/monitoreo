class UsersController < ApiController
  # GET /users
  # GET /users.json
  def index
    @users = User.all

    render json: @users
  end

  def show
    @user = User.find(params[:name])

    render json: @user
  end

  def tasks
    @tasks = Task.all_by_user params[:name]

    render json: @tasks
  end
end
