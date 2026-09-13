require "rails_helper"

RSpec.describe "API V1 Articles", type: :request do
  describe "GET /api/v1/articles" do
    it "returns articles" do
      get "/api/v1/articles"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json).to include("data", "meta")
      expect(json["data"]).to be_an(Array)
      expect(json["meta"]).to include(
        "total_count",
        "total_pages",
        "current_page",
        "per_page"
      )
    end

    it "supports pagination" do
      get "/api/v1/articles", params: {
        page: 1,
        per_page: 10
      }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["meta"]["current_page"]).to eq(1)
      expect(json["meta"]["per_page"]).to eq(10)
    end
  end

  describe "GET /api/v1/articles/:id" do
    it "returns an article" do
      article = Article.create!(
        title: "Test article",
        body: "Test body"
      )

      get "/api/v1/articles/#{article.id}"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["data"]["id"]).to eq(article.id)
      expect(json["data"]["type"]).to eq("article")
      expect(json["data"]["attributes"]["title"]).to eq("Test article")
    end

    it "returns 404 for missing article" do
      get "/api/v1/articles/999999"

      expect(response).to have_http_status(:not_found)

      json = JSON.parse(response.body)

      expect(json["data"]).to be_nil
      expect(json["errors"]).to be_an(Array)
      expect(json["errors"].first["code"]).to eq("not_found")
    end
  end

  describe "POST /api/v1/articles" do
    let(:valid_params) do
      {
        article: {
          title: "New article",
          body: "Article body"
        }
      }
    end

    it "creates an article" do
      expect {
        post "/api/v1/articles", params: valid_params
      }.to change(Article, :count).by(1)

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)

      expect(json["data"]["type"]).to eq("article")
      expect(json["data"]["attributes"]["title"]).to eq("New article")
    end

    it "returns validation errors" do
      post "/api/v1/articles", params: {
        article: {
          title: ""
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)

      json = JSON.parse(response.body)

      expect(json["data"]).to be_nil
      expect(json["errors"]).to be_an(Array)
    end
  end

  describe "PATCH /api/v1/articles/:id" do
    let!(:article) do
      Article.create!(
        title: "Old title",
        body: "Body"
      )
    end

    it "updates an article" do
      patch "/api/v1/articles/#{article.id}", params: {
        article: {
          title: "New title"
        }
      }

      expect(response).to have_http_status(:ok)

      expect(article.reload.title).to eq("New title")
    end

    it "returns 404 for missing article" do
      patch "/api/v1/articles/999999", params: {
        article: {
          title: "New title"
        }
      }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/articles/:id" do
    let!(:article) do
      Article.create!(
        title: "Article",
        body: "Body"
      )
    end

    it "deletes an article" do
      expect {
        delete "/api/v1/articles/#{article.id}"
      }.to change(Article, :count).by(-1)

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_blank
    end
  end
end
