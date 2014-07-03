module Api::V1
  class UsersController < ApiController
    # GET /users
    # GET /users.json
    def index
      @users = User.all

      render json: @users
    end

    def show
      @user = User.find(params[:name])

      if @user
        render json: @user
      else
        head :not_found
      end
    end

    def tasks
      @tasks = Task.all_by_user params[:name]

      if @tasks
        render json: @tasks
      else
        head :not_found
      end
    end
  end
end
