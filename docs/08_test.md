# RSpecのテストの種類

| テストの種類 | Laravelでの相当 | 役割 |
| ---- | ---- | ---- |
| Model Spec | Unit Test (Model) | バリデーション、スコープ、メソッドのロジックを検証 |
| Request Spec | Feature Test (API/Integration) | HTTPメソッド、ステータスコード、レスポンス内容を検証 |
| System Spec | Laravel Dusk (Browser Test) | 実際にブラウザを動かし、JavaScriptを含めたUIを検証 |

# Gem（ライブラリ）

1. 必要なgemをGemfileに追記
```
group :development, :test do
  gem 'rspec-rails'       # RSpec本体
  gem 'factory_bot_rails' # テストデータ作成（LaravelのFactory）
  gem 'faker'             # ダミーデータ生成
end

group :test do
  gem 'capybara'          # System Spec用ブラウザ操作
  gem 'selenium-webdriver'
end

group :development do
  gem 'rubocop-rails', require: false # Rails用の静的解析
  gem 'rubocop-rspec', require: false # RSpec用の静的解析
end
```

2. インストールとRSpecの初期化
```
bundle install
bin/rails generate rspec:install
```

# FactoryBotの設定
LaravelのFactory（database/factories）、Railsではspec/factories