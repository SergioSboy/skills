module Api
  module V1
    class  MeController < V1Controller
        def show
          render json: current_user
        end
    end
  end
end
