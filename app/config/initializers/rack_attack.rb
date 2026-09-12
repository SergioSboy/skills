class Rack::Attack
  throttle("requests/ip", limit: 100, period: 60) do |req|
    req.ip
  end

  throttle("requests/user", limit: 1000, period: 60) do |req|
    req.env["current_user"]&.id
  end

  throttle("requests/token", limit: 1000, period: 60) do |req|
    req.get_header("HTTP_AUTHORIZATION")
  end

  throttle("login/ip", limit: 5, period: 60) do |req|
    req.ip if req.path == "/api/users/login" && req.post?
  end
end
