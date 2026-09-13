module Api
  module V2
    class ArticlesController < V2Controller
      before_action :set_article, only: [ :show, :update, :destroy ]

      def index
        @articles = Kaminari
          .paginate_array(articles)
          .page(params.fetch(:page, 1))
          .per(params.fetch(:per_page, 20))
      end

      def show
      end

      def create
        @article = OpenStruct.new(
          id: 4,
          title: article_params[:title],
          body: article_params[:body],
          topic: topic_for(article_params[:topic_id]),
          author: author_for(article_params[:author_id]),
          published: article_params[:published] || false,
          created_at: Time.current,
          updated_at: Time.current
        )

        render :show, status: :created
      end

      def update
        @article.title = article_params[:title] if article_params.key?(:title)
        @article.body = article_params[:body] if article_params.key?(:body)

        if article_params.key?(:topic_id)
          @article.topic = topic_for(article_params[:topic_id])
        end

        if article_params.key?(:author_id)
          @article.author = author_for(article_params[:author_id])
        end

        if article_params.key?(:published)
          @article.published = article_params[:published]
        end

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
            title: "Getting started with Rails",
            body: "Rails is a web framework...",
            topic: OpenStruct.new(
              id: 2,
              name: "Rails"
            ),
            author: OpenStruct.new(
              id: 1,
              name: "John"
            ),
            published: true,
            created_at: 2.days.ago,
            updated_at: 1.day.ago
          ),

          OpenStruct.new(
            id: 2,
            title: "Jbuilder in Rails",
            body: "Jbuilder allows you to build JSON responses...",
            topic: OpenStruct.new(
              id: 2,
              name: "Rails"
            ),
            author: OpenStruct.new(
              id: 2,
              name: "Alice"
            ),
            published: true,
            created_at: 1.day.ago,
            updated_at: 1.day.ago
          ),

          OpenStruct.new(
            id: 3,
            title: "Ruby basics",
            body: "Ruby is a dynamic programming language...",
            topic: OpenStruct.new(
              id: 1,
              name: "Ruby"
            ),
            author: OpenStruct.new(
              id: 1,
              name: "John"
            ),
            published: false,
            created_at: 3.hours.ago,
            updated_at: 2.hours.ago
          )
        ]
      end

      def topic_for(id)
        {
          "1" => OpenStruct.new(id: 1, name: "Ruby"),
          "2" => OpenStruct.new(id: 2, name: "Rails")
        }[id.to_s]
      end

      def author_for(id)
        {
          "1" => OpenStruct.new(id: 1, name: "John"),
          "2" => OpenStruct.new(id: 2, name: "Alice")
        }[id.to_s]
      end

      def article_params
        params.require(:article).permit(
          :title,
          :body,
          :topic_id,
          :author_id,
          :published
        )
      end
    end
  end
end
