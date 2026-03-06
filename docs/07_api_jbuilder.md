
# Jsonの違い

| 機能 | Laravel (JsonResource) | Rails (jbuilder) |
| 定義場所 | app/Http/Resources/ | app/views/xxx/*.json.jbuilder |
| 配列の展開 | Resource::collection($data) | json.array! @data |
| ネスト | 配列を返すように書く | json.child_node do ... end |
| URLヘルパー | route('name') | task_url(@task) |
