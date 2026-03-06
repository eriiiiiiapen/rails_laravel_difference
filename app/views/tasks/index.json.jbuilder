json.array! @tasks do |task|
    json.id task.id
    json.title task.title
    json.url task_url(task, format: :json)
    json.image_url url_for(task.image) if task.image.attached?
end