require "rails_helper"

RSpec.describe "API V2 Articles", type: :request do
  describe "GET /api/v2/articles" do
    it "returns V2 article representation" do
      get "/api/v2/articles"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      article = json["data"].first

      expect(article).to include(
        "id",
        "type",
        "attributes"
      )

      expect(article["attributes"]).to include(
        "title",
        "body",
        "published",
        "topic",
        "author"
      )
    end
  end
end
