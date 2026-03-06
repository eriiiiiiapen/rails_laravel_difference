json.id @task.id
json.title @task.title
json.description @task.description
json.status @task.status
json.image_url url_for(@task.image) if @task.image.attached?

json.user do
  json.id @task.user.id
  json.email @task.user.email
end

json.extract! @task, :created_at, :updated_at
