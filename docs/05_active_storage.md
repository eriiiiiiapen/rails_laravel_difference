# Laravelとの違い

| 機能 | Laravel (Storage) | Rails (Active Storage) |
| カラム追加 | 必要（$table->string('image')） | 不要（専用の中間テーブルが管理） |
| 紐付け | Traitやmedialibrary | has_one_attached :name |
| 保存先 | config/filesystems.php | config/storage.yml |
| リサイズ | 手動でIntervention Imageなど | image.variant(...) で動的生成 |

Laravelでいう「テーブル作成（Migration）」「モデルとの紐付け（Trait）」「保存先設定（Filesystem）」が、
Railsでは Active Storage という一つのパッケージで統合される。

* Laravel: Media モデルを自分で管理したり（MediaLibraryを使うなど）、Intervention Image でリサイズ処理を書いたりする。
* Rails: Active Storageが裏側でDB管理し、ImageProcessing gem（裏側は libvips/ImageMagick）がリサイズを動的に行う。

# 生成される3テーブルについて

Active Storageのインストールを行うと生成される3テーブルについて
```
docker compose exec web bin/rails active_storage:install
docker compose exec web bin/rails db:migrate
```

| テーブル名 | 役割 |
| active_storage_blobs | ファイル本体のメタデータ。ファイル名、MIMEタイプ、サイズ、S3等の保存先URLなどを管理 |
| active_storage_attachments | 中間テーブル。どのモデル（Taskなど）のどのカラム（image）が、どのBlobに関連付いているかを繋ぐ |
| active_storage_variant_records | リサイズ画像の管理。一度生成したサムネイルなどの情報をキャッシュし、2回目以降の生成を速める |

上記をもっと簡単にまとめると

* Blob = データの本体情報。
* Attachment = モデルとBlobを結ぶ接着剤。
* Variant = 加工済み（リサイズ等）画像。

※ 注意: リサイズ機能 (variant) を使うには、Gemfileに gem "image_processing" が必要。

# 表示について

## 画像を表示する場合 (image_tag)

1. 普通に表示
Laravelの asset() / $media->getUrl() に相当
```
<%= image_tag task.image if task.image.attached? %>
```

※ 存在チェックについて（nilガード）

* object.image.attached? で存在確認ができる。
* Laravelの optional() ヘルパーに近い考え方、Railsでは attached? を使うのが標準。
* Rubyの「ぼっち演算子」（&.）も使用可能


2. 画像へのリンク（直リンク）

```
<%= link_to "画像をフルサイズで見る", url_for(task.image), target: "_blank" %>
```

3. ダウンロードリンクにする場合

```
<%= link_to "ダウンロード", rails_blob_path(task.image, disposition: "attachment")
```
