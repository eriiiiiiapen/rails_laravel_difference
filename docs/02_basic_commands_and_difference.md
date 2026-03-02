# 操作方法の違い

| 操作 | Laravel (artisan) | Rails (bin/rails) |
| ---- | ---- | ---- |
| サーバー起動 | php artisan serve | bin/rails s |
| インタラクティブ | php artisan tinker | bin/rails c |
| モデル作成 | make:model Task -m | g model Task title:string |
| 全部入り作成 | make:model Task -mcr | g scaffold Task ... |
| マイグレート | migrate | db:migrate |
| ロールバック | migrate:rollback | db:rollback |
| DBリセット | migrate:fresh | db:migrate:reset or db:reset |

# 違い

| 項目 | Laravel (PHP) | Rails (Ruby) | 備考 |
| ---- | ---- | ---- | ---- |
| Routing | Route::get('/path', [Ctrl::class, 'index']) | get '/path', to: 'ctrl#index' | Railsは config/routes.| rb に集約。|
| Route定義 | Route::resource('topics', TopicCtrl::class) | resources :topics | これだけで 7つの基本アクションが生成。 |
| URL生成 | route('topics.show', $topic) | topic_path(@topic) | Railsは「接頭辞 + path」のメソッド形式。 |
| データ取得 | Topic::findOrFail($id) | Topic.find(params[:id]) | find は見つからないと例外を出す（404）。 |
| 全件取得 | Topic::all() | Topic.all | Railsはメソッド呼び出しに () が不要。 |
| 条件絞り込み | Topic::where('status', 1)->get() | Topic.where(status: 1) | Railsは最後に .get() 相当を打たなくてもLazy| に評価。 |
| リンク作成 | <a href="{{ route(...) }}"> | <%= link_to "表示名", topic_path(@topic) %> | HTMLタグを書かず、ヘルパーメソッドを多用。 |
| NULLの表記 | null | nil |  |
| whereIn | ->where('column', [a, b]) | .where(column: [a, b]) |  |
| インスタンス生成 | build | new | 慣習的にリレーションを介すときは build を使う |

# 保存について

| Railsメソッド | 特徴 | Laravel相当 |
| save | 戻り値が true/false。バリデーション失敗で false。 | save() |
| save! | 失敗時に例外を投げる。一括処理などでよく使う。 | なし |
| update | 属性を更新して保存。 | update([]) |
| create | インスタンス化して保存。 | create([]) |
| update_column | バリデーションとコールバックを無視してDBを直接書き換える。 | forceFill([...])->save() |

# 例外について

| Laravel (PHP) | Rails (Ruby) | 役割 |
| try | begin | 監視の開始 |
| catch (Exception $e) | rescue => e | エラーの捕捉 |
| throw new Exception() | raise "error" | 例外を意図的に投げる |
| finally | ensure | 成功・失敗に関わらず最後に実行 |

# クエリの書き方

| 記法 | 意味 | SQLのイメージ |
| .joins(:topic) | Topicだけ結合 | JOIN topics ON ... |
| .joins(:topic, :user) | TopicとUserを両方結合（並列） | JOIN topics ... JOIN users ... |
| .joins(topic: :subject) | Topicを介してSubjectを結合（直列） | JOIN topics ... JOIN subjects ... |

# N+1問題の回避方法

## そもそもN+1問題とは

**N+1問題の本質は「通信回数」**
N+1は「回数そのものが多すぎる」問題。
1回の処理で済むはずのクエリが、データの件数（N）に依存して大量に増殖してしまう。
（インデックスの有無は「1回あたりのクエリの重さ」に関係）

たとえインデックスが貼ってあって「1回のクエリが0.001秒」で終わるとしても、
それが10000回繰り返されれば、通信の往復（オーバーヘッド）だけで数秒かかる。

例（Laravel）
```
//例えば10000データ
$users = User::all();

//10000回foreachが回る
foreach($users as $user){
    $format[] = $user->a . " " . $user->b
}
```

## Railsでの回避方法
| メソッド | 発行されるSQL | 特徴 | 関連テーブルでの絞り込み (where) |
| preload | 別々に実行 (2回〜) | 最もシンプル。各テーブルを個別に引く。 | 不可 (エラーになる) |
| eager_load | 1回の巨大なJOIN | LEFT OUTER JOIN で一気に取得。 | 可能 |
| includes | 自動切り替え | 基本は preload、必要なら eager_load になる。 | 条件付きで可能 |

※LaravelだとwithでEager loading（一括読み込み）したり、
loadでmodelに関連をloadしたり、withWhereHasで条件を持ったloadをする。