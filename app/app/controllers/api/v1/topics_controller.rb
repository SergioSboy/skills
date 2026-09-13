module Api
  module V1
    class TopicsController < V1Controller
      before_action :set_topic, only: :show

      def index
        @topics = Kaminari
          .paginate_array(topics)
          .page(params.fetch(:page, 1))
          .per(params.fetch(:per_page, 20))
      end

      def show
      end

      private

      def set_topic
        @topic = topics.find do |topic|
          topic.id.to_s == params[:id].to_s
        end

        raise ActiveRecord::RecordNotFound, "Topic not found" unless @topic
      end

      def topics
        [
          OpenStruct.new(id: 1, name: "Ruby"),
          OpenStruct.new(id: 2, name: "Rails"),
          OpenStruct.new(id: 3, name: "JavaScript"),
          OpenStruct.new(id: 4, name: "PostgreSQL"),
          OpenStruct.new(id: 5, name: "Docker")
        ]
      end
    end
  end
end
