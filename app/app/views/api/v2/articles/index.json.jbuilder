json.data @articles do |article|
  json.partial! "api/v2/articles/article", article: article
end

json.partial! "api/pagination", collection: @articles
