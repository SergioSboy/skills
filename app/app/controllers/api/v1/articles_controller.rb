module Api
  module V1
    class ArticlesController < V1Controller
      before_action :set_article, only: [ :show, :update, :destroy ]

      def index
        @articles = Kaminari
          .paginate_array(articles)
          .page(params.fetch(:page, 1))
          .per(params.fetch(:per_page, 10))
      end

      def show
      end

      def create
        @article = OpenStruct.new(
          id: 6,
          title: article_params[:title],
          body: article_params[:body],
          topic_id: article_params[:topic_id],
          created_at: Time.current,
          updated_at: Time.current
        )

        render :show, status: :created
      end

      def update
        @article.title = article_params[:title] if article_params.key?(:title)
        @article.body = article_params[:body] if article_params.key?(:body)
        @article.topic_id = article_params[:topic_id] if article_params.key?(:topic_id)
        @article.updated_at = Time.current

        render :show
      end

      def destroy
        head :no_content
      end

      private

      def set_article
        @article = articles.find do |article|
          article.id.to_s == params[:id].to_s
        end

        raise ActiveRecord::RecordNotFound, "Article not found" unless @article
      end

      def articles
        [
          OpenStruct.new(
            id: 1,
            title: "Getting started with Ruby",
            body: "Ruby is a programming language.",
            topic_id: 1,
            created_at: 2.days.ago,
            updated_at: 1.day.ago
          ),
          OpenStruct.new(
            id: 2,
            title: "Rails API",
            body: "Building APIs with Rails.",
            topic_id: 2,
            created_at: 1.day.ago,
            updated_at: 1.day.ago
          ),
          OpenStruct.new(
            id: 3,
            title: "Working with PostgreSQL",
            body: "PostgreSQL basics.",
            topic_id: 4,
            created_at: 3.hours.ago,
            updated_at: 2.hours.ago
          )
        ]
      end

      def article_params
        params.require(:article).permit(
          :title,
          :body,
          :topic_id
        )
      end
    end
  end
end
