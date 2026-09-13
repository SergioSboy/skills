require "rails_helper"

RSpec.describe "API V1 Article Topics", type: :request do
  describe "GET /api/v2/articles/:article_id/topics" do
    let!(:article) do
      Article.create!(
        title: "Rails",
        body: "Rails article"
      )
    end

    it "returns topics for an article" do
      get "/api/v2/articles/#{article.id}/topics"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json).to include("data", "meta")
      expect(json["data"]).to be_an(Array)
    end

    it "returns 404 when article does not exist" do
      get "/api/v2/articles/999999/topics"

      expect(response).to have_http_status(:not_found)
    end
  end
end
