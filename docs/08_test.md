# RSpecのテストの種類

| テストの種類 | Laravelでの相当 | 役割 |
| ---- | ---- | ---- |
| Model Spec | Unit Test (Model) | バリデーション、スコープ、メソッドのロジックを検証 |
| Request Spec | Feature Test (API/Integration) | HTTPメソッド、ステータスコード、レスポンス内容を検証 |
| System Spec | Laravel Dusk (Browser Test) | 実際にブラウザを動かし、JavaScriptを含めたUIを検証 |

# 実行コマンド

| 実行対象 | コマンド |
| --- | --- |
| 全てのテストを実行 | bundle exec rspec |
| モデルテストだけ実行 | bundle exec rspec spec/models |
| リクエストテストだけ実行 | bundle exec rspec spec/requests |
| 特定のファイルのみ | bundle exec rspec spec/models/x_spec.rb |
| 特定の行（テストケース）のみ | bundle exec rspec spec/models/x_spec.rb:10 |

※便利なオプション

* 失敗したテストだけ再実行: bundle exec rspec --only-failures
* ドキュメント形式で表示: bundle exec rspec -f d
※Laravelの phpunit --testdox のように、テスト名を文章として表示してくれる

# Laravelとの違い

| 項目 | Rails (RSpec) | Laravel (PHPUnit/Pest) |
| ---- | ---- | ---- |
| テストデータ作成 | FactoryBot | Factory |
| 事前実行 | before(:each) | setUp() |
| 事後実行 | after(:each) | tearDown() |
| 共通化（Trait的な） | shared_examples | Traits または PestのHigher Order |
| モック/スタブ | allow(obj).to receive(...) | $this->mock(...) |

## let と let! の使い分け

1. let(:user) { ... }

遅延評価。
テストの中で user が呼ばれた瞬間に作成される。
（Laravelの変数代入に近いが、呼ばれない限り作成されない）

2. let!(:user) { ... }

即時評価。
it ブロックが始まる前に必ず作成され、一覧画面にデータが存在してほしい時などに使う。

## subject でDRYに書く

```
describe '#published?' do
  subject { x.published? } # テスト対象を定義
  
  context 'ステータスが完了の時' do
    let(:x) { create(:x, status: :done) }
    it { is_expected.to be true } # 文章のように読める
  end
end
```

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

```
# spec/factories/x.rb
FactoryBot.define do
  factory :x do
    title { "test" }
  end
end
```

# Rubocop

| 目的 | コマンド |
| ---- | ---- |
| 全ファイルの修正箇所を表示 | bundle exec rubocop |
| 特定のファイルだけチェック | bundle exec rubocop app/models/x.rb |
| 自動修正（安全なもののみ） | bundle exec rubocop -a |
| 自動修正（少し冒険的な修正も含む） | bundle exec rubocop -A |

1. 静的解析でコードを綺麗にする
```
bundle exec rubocop -A
```

2. テストを全件実行する
```
bundle exec rspec
```