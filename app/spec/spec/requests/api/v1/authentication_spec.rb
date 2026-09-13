describe "authentication" do
  it "returns 401 without token" do
    get "/api/v1/articles"

    expect(response).to have_http_status(:unauthorized)
  end

  it "returns 401 with invalid token" do
    get "/api/v1/articles",
        headers: {
          "Authorization" => "Bearer invalid-token"
        }

    expect(response).to have_http_status(:unauthorized)
  end

  it "allows access with valid token" do
    user = create(:user)

    token = JwtService.encode(user_id: user.id)

    get "/api/v1/articles",
        headers: {
          "Authorization" => "Bearer #{token}"
        }

    expect(response).to have_http_status(:ok)
  end
end