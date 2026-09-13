json.data @articles do |article|
  json.partial! "api/v1/articles/article", article: article
end

json.partial! "api/pagination", collection: @articles
