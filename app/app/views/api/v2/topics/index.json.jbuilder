json.data @topics do |topic|
  json.partial! "api/v2/topics/topic", topic: topic
end

json.partial! "api/pagination", collection: @topics
