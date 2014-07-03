module Api::V1
  class TasksController < ApiController
    # GET /tasks
    # GET /tasks.json
    def index
      @tasks = Task.all

      render json: @tasks
    end

    # GET /tasks/1
    # GET /tasks/1.json
    def show
      @task = Task.find(params[:pid])

      if @task
        render json: @task
      else
        head :not_found
      end
    end

    # POST /tasks
    # POST /tasks.json
    def create
      @task = Task.new(params[:task])

      if @task.save
        render json: @task, status: :created
      else
        render json: @task.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /tasks/1
    # PATCH/PUT /tasks/1.json
    def update
      @task = Task.find(params[:pid])

      if @task        
        if @task.update(params[:task])
          render json: @task
        else
          render json: @task.errors, status: :unprocessable_entity
        end
      else
        head :not_found
      end
    end

    # DELETE /tasks/1
    # DELETE /tasks/1.json
    def destroy
      @task = Task.find(params[:pid])

      if @task      
        if @task.destroy
          head :no_content
        else
          render json: @task.errors, status: :unprocessable_entity
        end
      else
        head :not_found
      end
    end
  end
end
