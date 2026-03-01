# ActiveRecord（ORM）について

ORM＝raw SQLを書かずとも、RDBの間でやり取りを行い、データ取得ができる技術。

Laravelでは「Eloquent」を用いて、DBからデータ取得を行い（QueryBuilder）、
便利なメソッドを多く持つCollection（取得後のデータ整形）を行なって、直感的なデータ操作を可能としている。

対して、Railsの「ActiveRecord」については、「ORM（Object-Relational Mapping）」の名称であり、ライブラリそのものを指す。
Active Record のライフサイクルでは、**「Rubyのオブジェクトが生まれてから、データベースに保存され、消えるまでの流れ」**のことである。

* new / build: オブジェクトがメモリ上に作られる（まだDBにはいない）
* valid?: バリデーションの実行
* before_save: 保存直前のフック（例：データを加工する）
* INSERT / UPDATE: 実際のSQL発行（トランザクション開始）
* after_save: 保存直後のフック（例：ログを残す）
* after_commit: DBへの書き込みが完全に確定した後のフック（例：通知メールを送る）

# Model
## リレーション（単数形と複数形の規約）

定義例

* Task モデル（子）: belongs_to :user (単数形)
* User モデル（親）: has_many :tasks (複数形)

生成

```
bin/rails g migration AddUserToTasks user:references
```

→これで user_id と index が自動生成される。

※ N+1対策: Task.includes(:user) （Laravelの Task::with('user')）

記述方法

Laravel
```
class Task extends Model
{
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
```

Rails
```
class Task < ActiveRecord
  belongs_to :user
end
```

## scope
Laravelより簡潔に記載可能。

Rails例
```
scope :active, -> { where(active: true) }
scope :recent, -> { order(created_at: :desc) }
```
↓以下のように使える
```
@tasks = Task.active.recent
```

※Laravelの場合、モデルに以下のようにscopeメソッドで記載
　public function scopeActive($query) { return $query->where('active', true); }

## enum
メソッドの自動生成がある

Rails例
```
enum :status, { todo: 0, doing: 1, done: 2 }
```

上記の記述だけで以下が使える。

* task.todo?  -> Booleanで判定 (Laravel: $task->status === Status::Todo)
* task.doing! -> その場でUPDATE
* Task.done   -> Scopeとして機能 (Task::where('status', 2)->get())

# バリデーション

## バリデーションの場所

* Laravelは FormRequest
* Railsは Model に書く (validates :title, presence: true)。

## データの守り方

* Laravel: $fillable で一括代入を許可する
* Rails: Strong Parameters。Controllerの private メソッドで params.require(:task).permit(...) しないと、データが保存されない。エラー取得: @task.errors.full_messages で配列として取得可能。

