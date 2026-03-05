# Hotwire（TurboとStimulus）

LaravelでのLivewire (Turbo) / Alpine.js (Stimulus) に相当する技術。
JavaScriptをほとんど書かずに、SPA（＝シングルページアプリケーション）のようなサクサク感を出す

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

## Stimulus Targets のルール

* 定義: static targets = ["name"] と書くと、JS側で this.nameTarget として参照できる。
* 複数要素: 同じターゲット名が複数ある場合は this.nameTargets (複数形) で配列として取得できる。
* Alpine.jsの this.$refs.name に近いが、Stimulusは「ターゲットがDOMに存在するか？」を this.hasNameTarget でチェックできるなど、より堅牢な設計になっている。

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