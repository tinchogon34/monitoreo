class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  def index
    @users = User.all

    render json: @users
  end

  def tasks
    @tasks = Task.all.select{|task| task.owner == params[:name]}

    render json: @tasks
  end
end
