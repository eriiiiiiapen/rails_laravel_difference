# Deviseのインストール
LaravelでいうところのBreeze。
php artisan breeze:installでビューまで一気に作るが、Deviseの場合はまず 「認証機能を持ったモデル」 を作る。

1. Gemfileの末尾に追加

```
gem "devise"
```

2. bundle install

```
docker compose exec web bundle install
```

* config/initializers/devise.rb
* config/locales/devise.en.yml

3. 初期設定ファイルの生成

```
docker compose exec web bin/rails generate devise:install
```

# 認証機能の紐付け
1. UserモデルにDeviseを適用

```
docker compose exec web bin/rails generate devise User
```

* db/migrate/202XXXXXXX_add_devise_to_users.rb
* app/models/user.rb
* routeへ「devise_for :users」

2. マイグレーションの実行

```
docker compose exec web bin/rails db:migrate
```
※すでにemailカラムを持っているusersテーブルを作成している場合は、コメントアウト

3. dockerのrestart

```
docker compose restart web
```

4. viewの書き出し
devise関連のviewファイルが作成される

```
docker compose exec web bin/rails generate devise:views
```

# 共通メソッド

| 機能 | Laravel | Rails (Devise) |
| ---- | ---- | ---- |
| ログイン中のユーザー | Auth::user() | current_user |
| ログイン済みか判定 | Auth::check() | user_signed_in? |
| 未ログインならリダイレクト | $this->middleware('auth') | before_action :authenticate_user! |
| ログイン画面パス | route('login') | new_user_session_path |
| 新規登録画面パス | route('register') | new_user_registration_path |

# Laravel Breezeとの違い

## 設定の場所

* Laravelは「Fortify」や「Breeze」のサービスプロバイダーで設定する。
* Railsの「Devise」は config/initializers/devise.rb と Userモデル内の devise :database_authenticatable, :registerable... という記述で機能をオンオフする。

## ルーティング

* config/routes.rb に書かれる devise_for :users の一行で、ログイン・ログアウト・パスワードリセット等の全ルートが自動生成される
* Laravelの「php artisan route:list」に相当するルーティング一覧は、Railsの場合は「bin/rails routes」で確認可能。

## フィルター

* コントローラーで before_action :authenticate_user! と書くだけで、そのクラス内の全アクションに auth ミドルウェアがかかる。

## 認証後のデータ操作 (Laravel 比較)

* ログイン必須化: before_action :authenticate_user! をコントローラーに追記する。
* スコープ制限: Task.all ではなく current_user.tasks を使う。
* 関連データの作成: current_user.tasks.build(params) を使うことで、外部キー (user_id) の代入を自動化・隠蔽できる。
* セキュリティ: データの検索を current_user.tasks.find(id) で行うことで、Laravel の Policy を個別に書かなくても「他人のデータへの不正アクセス」を物理的に防げる。

## ログアウト例（turbo_methodについて）

```
<%= link_to "ログアウト", destroy_user_session_path, data: { turbo_method: :delete } %>
```

* Laravel: ログアウトは通常 POST ＋　<form> タグを作って CSRF トークンを送るのが一般的（Breezeもそう）。
* Rails: Deviseのデフォルト設定では、ログアウトは DELETE メソッドを期待。
* Turbo: Rails 7以降、標準搭載されている Turbo というライブラリが、ただの <a> タグ（GET）を DELETE リクエストに変換してくれる。

## viewでの認証出しわけ＋リンクヘルパー

* 認証判定: user_signed_in? ヘルパーを使用（Laravelの @auth 相当）
* リンク生成: link_to "表示名", パス名。
* パスの確認: bin/rails routes で Prefix を確認し、それに _path をつける（例: tasks → tasks_path）
* Turboの役割: Rails 7以降、DELETE や PATCH をリンクで行うには data: { turbo_method: :xxx } が必須。
 * Laravelのように手動で <form> を書く必要がほとんどない。
