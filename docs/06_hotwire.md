# Hotwire（TurboとStimulus）

LaravelでのLivewire (Turbo) / Alpine.js (Stimulus) に相当する技術。
JavaScriptをほとんど書かずに、SPA（＝シングルページアプリケーション）のようなサクサク感を出す。

ただし「Livewire」の場合は、コンポーネントの状態（PHP）とViewが強固に結びついている（＝双方向データバインディング）が、
「Rails (Hotwire)」はあくまでも独立している技術をHTMLの属性（data-）で繋いでいるだけの疎結合な状態。

## Turbo
「ページ全体のリロード」を阻止し、**「変更が必要な部分だけを差し替える」**仕組み

* Turbo Drive: リンクをクリックした際に、ページ全体を読み直さず、中身だけをAjaxで取得して入れ替える。
* Turbo Frames: ページの一部（例：タスク一覧の1行だけ）を独立したパーツとして扱い、その中だけで更新を完結させる。
* Turbo Streams: サーバーから「このHTML要素を削除」「これを追加」という命令を送り、リアルタイムに画面を書き換える。

* 「status: :see_other」は Rails 7 で Turbo を使う際の推奨ステータス（HTTP 303）

## Stimulus
HTMLに「動き」をつける
Turboでカバーできない「クリックしたら色を変える」「入力文字数をカウントする」といったクライアント側の動きを担当。
（Laravelで Alpine.js を使う感覚に非常に近い）

jsファイル（hello_controller.js）
```
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "test" ] // Laravelの x-ref に相当

  greet() {
    this.testTarget.textContent = "Hello, Stimulus!"
  }
}
```

view
```
<div data-controller="hello">
  <button data-action="click->hello#greet">クリック</button>
  <span data-hello-target="test"></span>
</div>
```

### Laravelとの定義方法の比較
* Alpine.js: x-ref="xxx" と書き、JS側で this.$refs.xxx で操作する。
* Stimulus: data-[controller名]-target="xxx" と書き、JS側で this.xxxTarget で操作する。

## 構造の理解：Stimulus と Turbo の連携

1. Stimulus (x_controller.js) = リモコン
例：ユーザーの操作（入力）をトリガーに、RailsのURLへリクエスト（requestSubmit）を投げる。

2. Rails Controller (x_controller.rb) = 窓口
例：検索クエリを受け取り、結果のHTML（Turbo Stream）を返す。

3. Turbo Stream (index.turbo_stream.erb) = 指示書
例：ブラウザに対し、「#x の中身をこのHTMLで更新せよ」と命令。

## Stimulus Targets のルール

* 定義: static targets = ["name"] と書くと、JS側で this.nameTarget として参照できる。
* 複数要素: 同じターゲット名が複数ある場合は this.nameTargets (複数形) で配列として取得できる。
* Alpine.jsの this.$refs.name に近いが、Stimulusは「ターゲットがDOMに存在するか？」を this.hasNameTarget でチェックできるなど、より堅牢な設計になっている。

1. this.xxxTarget
最初の1つを返し、存在しない場合はエラーを投げる。

2. this.hasXxxTarget
ターゲットがDOM上に存在するかどうかを `Boolean` で返すため、エラー回避に便利。

3. this.xxxTargets
合致するすべての要素を配列で返す（`querySelectorAll` に相当）。

## 違い

| 機能 | Laravel (Livewire/Alpine) | Rails (Hotwire) |
| 画面遷移の高速化 | Livewire (Navigate) | Turbo Drive |
| 部分更新 | Livewire Component | Turbo Frames |
| DOM操作命令 | wire:click など | Turbo Streams |
| JSでの小細工 | Alpine.js (x-data) | Stimulus (data-controller) |

## JS管理 (Importmaps)

* node_modules や webpack を使わずに、ブラウザの import 機能を直接使う Importmap がデフォルト。
* app/javascript がない場合は bin/rails stimulus:install などで再生成可能。
* Turbo Stream の命名規則: >   destroy アクションに対応するレスポンスは destroy.turbo_stream.erb というファイル名にする（.html が入ると Rails が混乱することがあるので、基本は filename.turbo_stream.erb）。

```
docker compose exec web bin/rails importmap:install
docker compose exec web bin/rails turbo:install stimulus:install
```

app/javascript/controllers/...などが生成

## DOM IDの管理

* 重複を避けるため、dom_id は原則として Partial (_task.html.erb) のルート要素 に付与する。
* show.html.erb や index.html.erb で render する際は、外側でIDを振らずに、Partial内のIDをそのまま利用する。

→ Turbo Stream から remove "task_#{@task.id}" と命令した際に、どの画面でも正確に対象要素を特定できる。

## 検索機能の例

Laravel（Livewire）の `wire:model.debounce` は便利だが、
Railsのこの方式は「標準的なHTMLフォーム送信」の延長線上にあるため、
デバッグがしやすい（NetworkタブでHTMLが返ってくるのが見える）。

* View: 検索フォームを form_with で作り、Stimulusコントローラーを紐付ける。
 * index.html.erb に書いたから index アクションが呼ばれるのではなく、form_with url: tasks_path と書いたから TasksController#index にリクエストが飛ぶ。
* Stimulus: 入力（input）があるたびに、フォームを自動送信（requestSubmit）する。
* Controller: 検索ワードでフィルタリングし、Turbo Stream 形式でレスポンスを返す。
* Turbo Stream: 一覧部分（id="result_tasks"）だけを検索結果で書き換える。

* 役割分担
 * Stimulus：クライアント側の「入力イベント」を拾って「送信」するだけ。
 * Turbo Stream：サーバー側で「どのHTMLを、どこに差し替えるか」を指示する。

### JSファイルへの内容について

* requestSubmit()
 * JSで form.submit() を呼ぶとTurboが無視されることがあるが、
 requestSubmit() を使うとTurboが正しくリクエストをインターセプトして非同期にしてくれる。