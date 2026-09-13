json.id article.id
json.type "article"

json.attributes do
  json.title article.title
  json.body article.body
end

json.topic do
  json.id article.topic.id
  json.name article.topic.name
end
