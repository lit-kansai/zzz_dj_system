# dj-system
音楽のリクエストを受け付けるフォームです。（iTunes APIを用いて曲の検索機能付き）  
[こちら](https://dj-system.herokuapp.com/)からデプロイ済のものを使用していただけます。

## Requirement
- Ruby 2.6.2

## Quick start
```
$ docker-compose up --build
```

## Routes
- ```/team/create```　新しいチームの作成
- ```/:team_id``` チーム曲リクエストフォーム（このURLをメンバーに渡せばOK）
- ```/:team_id/confirm``` メンバー自身がリクエストしたいと思った曲の確認とラジオネーム・お便りが投稿できるページ
- ```/:team_id/admin``` チームの追加された曲の一覧とコメントの一覧を見られる

## About TEAM
- URL NAME  
Routesの「team_id」に該当する部分。
- メンター名  
DJ 〇〇の〇〇に表示される。
- 説明  
ちょっとした説明文。DJ 〇〇の下に表示される。

## Future
- 管理者ページの権限
- TEAMの編集機能
- 非同期処理
- ちゃんとしたUI
