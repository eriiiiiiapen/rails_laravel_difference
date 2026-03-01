# インストール手順

## 1.アプリケーションの作成
```
rails new app_name
```
Rails7.1以降ではデフォルトでDockerをサポートしており、上記コマンドだけでDockerfileも生成される。

```
run  bundle install --quiet
```
上記実行中にOpenTimeoutとなるため、本環境下においてはその時点で処理をCtrl+Cで中断。
代わりに、Dockerの立ち上げを進めた。

## 2.Dockerの立ち上げ

Dockerfileの書き換えと、docker-compose.ymlを作成。
docker-compose.ymlについては、特に環境に依らず使用できるように.env管理前提とすること、
他のアプリケーションに影響がないよう、volumeデータの設定やport設定を留意。

以下の通り、webコンテナの立ち上げの際にエラーとなるため、事前に先に空のGemfile.lockをルートフォルダに配置
```
=> ERROR [web build 3/7] COPY Gemfile Gemfile.lock ./
```

以下で立ち上げ
```
docker compose up -d
```

## 3.Laravelとの違い

1. ruby:3.3-slim-bullseye: PHP の php:8.3-fpm-bullseye のような軽量ベースイメージです。
2. libpq-dev: PostgreSQL に接続するためのドライバ（Laravel でいう php-pgsql のビルドに必要なやつ）
3. Node.js & Yarn: Rails 7 でも JS や CSS（Tailwind など）をコンパイルするために必要。Laravel Mix や Vite を動かす環境と同じ役割
4. Gemfile: composer.json
5. bundle install: composer install

## 4.Dockerビルドの壁とsleep作法

トラブル: docker build 時の bundle install がネットワークエラーで落ちる。
原因: Dockerビルド環境と実行環境のネットワーク制限の違い。

解決法（外科手術）
1. docker-compose.yml の command を sleep infinity にして無理やり起動。
2. docker compose exec web bundle install で実行環境からインストール。
3. bundle_data ボリュームでGemを永続化する。

教訓: コンテナが即落ちする時は、まず「落ちないようなコンテナ」にして中を覗く。
