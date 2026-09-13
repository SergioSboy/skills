json.data @topics do |topic|
  json.partial! "api/v1/topics/topic", topic: topic
end

json.partial! "api/pagination", collection: @topics
