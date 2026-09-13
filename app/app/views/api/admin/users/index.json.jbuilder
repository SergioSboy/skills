json.data @users do |user|
  json.partial! "api/admin/users/user", user: user
end

json.partial! "api/pagination", collection: @users
