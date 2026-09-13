module Api
  module V2
    class TopicsController < ApplicationController
      def index
        @topics = Kaminari.paginate_array([
          OpenStruct.new(id: 1, name: "Ruby"),
          OpenStruct.new(id: 2, name: "Rails"),
          OpenStruct.new(id: 3, name: "JavaScript"),
          OpenStruct.new(id: 4, name: "PostgreSQL"),
          OpenStruct.new(id: 5, name: "Docker")
        ]).page(1).per(20)
      end
    end
  end
end
