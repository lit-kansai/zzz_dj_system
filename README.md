# dj-system

音楽のリクエストを受け付けるフォームです。（iTunes API を用いて曲の検索機能付き）  
[こちら](https://dj-system.herokuapp.com/)からデプロイ済のものを使用していただけます。

## Requirement

- Ruby 2.6.2

## Quick start

```
$ docker-compose up --build
```

## Routes

- `/admin/all`　チーム一覧を表示
- `/admin/edit/new`　新しいチームの作成
- `/admin/edit/:team_id`　作成済のチームの情報編集
- `/admin/:team_id` チームの管理（追加された曲＆コメント一覧が見られる）
- `/:team_id` チーム曲リクエストフォーム（この URL をメンバーに渡せば OK）
- `/:team_id/confirm` メンバー自身がリクエストしたいと思った曲の確認とラジオネーム・お便りが投稿できるページ

## About TEAM

- URL NAME  
  Routes の「team_id」に該当する部分。
- メンター名  
  DJ 〇〇の〇〇に表示される。
- 説明  
  ちょっとした説明文。DJ 〇〇の下に表示される。

## Future

- URL NAME重ならないようにする
- 管理者ページの権限
- 完了しましたみたいな画面つけたい
- 非同期処理
- ちゃんとした UI
