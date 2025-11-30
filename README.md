# Supermarket Backend

**Clean Architecture**、**Shelf**、**PostgreSQL**、**Docker** を使用して構築された、オンラインスーパーマーケット向けの実用グレードのDartバックエンドサービスです。
このバックエンドは、**SwiftUI iOSアプリ**のフロントエンドと連携するように設計されています。

## 機能

- **ユーザー管理**: ユーザープロファイルの作成と表示。
- **在庫システム**:
  - 有効期限に基づいて価格が変動する商品のリスト表示。
  - **割引**:
    - 残り1日: 50% OFF
    - 残り2日: 30% OFF
    - 残り3日: 10% OFF
- **サブスクリプション**: ユーザーは特定の商品を購読し、特定の有効期限のしきい値に達したときにアラートを受け取ることができます。
- **通知**: アラートが必要なサブスクリプションを特定するロジック（例：「牛乳の期限が残り1日です」）。

## 技術スタック

- **言語**: Dart
- **フレームワーク**: Shelf (サーバー), Shelf Router
- **データベース**: PostgreSQL 15
- **アーキテクチャ**: クリーンアーキテクチャ (ハンドラ -> サービス -> リポジトリ -> データソース)
- **依存性注入**: `get_it`
- **コンテナ化**: Docker & Docker Compose

## はじめに (Getting Started)

プロジェクトのセットアップから実行までの手順です。

### 前提条件

- **Git** がインストールされていること。
- **Docker** および **Docker Compose** がインストールされ、起動していること。

### インストールと実行手順

1.  **リポジトリのクローン**:
    ```bash
    git clone <repository_url>
    cd 10x-project
    ```

2.  **サービスの起動**:
    Docker Composeを使用して、データベースとバックエンドサーバーを構築・起動します。
    ```bash
    docker-compose up --build
    ```
    *   初回起動時はデータベースの初期化に数秒かかる場合があります。
    *   サーバーはポート `8080` で待機します。

3.  **動作確認 (ヘルスチェック)**:
    別のターミナルウィンドウを開き、以下のコマンドを実行してサーバーが稼働しているか確認します。
    ```bash
    curl http://localhost:8080/health
    ```
    `{"status":"ok"}` のようなレスポンスが返ってくれば成功です。

## API エンドポイント

### ユーザー (Users)
- `POST /api/v1/users` - ユーザーの作成 (`{ "email": "..." }`)
- `GET /api/v1/users/<id>` - ユーザー詳細の取得

### 在庫 (Inventory)
- `GET /api/v1/inventory/` - 計算された割引を含むすべての商品のリスト表示。

### サブスクリプション (Subscriptions)
- `POST /api/v1/subscriptions/` - 商品の購読 (`{ "user_id": "...", "inventory_id": "...", "alert_threshold": 1 }`)
- `GET /api/v1/subscriptions/user/<user_id>` - ユーザーのサブスクリプションのリスト表示。

## 通知のトリガー方法 (How to Trigger Notifications)

このシステムでは、定期的なバッチ処理（Cronジョブなど）によって通知条件をチェックすることを想定しています。手動、またはスケジューラから通知チェックを実行するには、以下のエンドポイントを使用します。

### トリガーエンドポイント
- **メソッド**: `POST`
- **URL**: `/api/v1/subscriptions/trigger-check`

### 実行方法 (cURL)
```bash
curl -X POST http://localhost:8080/api/v1/subscriptions/trigger-check
```

### 動作の仕組み
1.  このエンドポイントが叩かれると、バックエンドはデータベースをスキャンします。
2.  「商品の有効期限（`expiry_in`）」と「ユーザーが設定した通知しきい値（`alert_threshold`）」が一致するサブスクリプションを検索します。
3.  一致するものが見つかった場合、通知対象リストをレスポンスとして返します（将来的にはここで実際のプッシュ通知やメール送信処理が行われます）。

## プロジェクト構造

- `bin/` - エントリーポイント。
- `lib/api/` - ハンドラ、ルーター、ミドルウェア。
- `lib/services/` - ビジネスロジック（割引、通知ルール）。
- `lib/data/` - リポジトリとDB接続。
- `lib/domain/` - モデル。
- `lib/config/` - 依存性注入と環境設定。
- `db/` - SQLマイグレーション/シード。

## 今後の作業
- `auth_middleware.dart` に Firebase Admin SDK を統合。
- 在庫のキャッシュのために Redis を統合。
- `trigger-check` を実際のメール/プッシュサービス (FCM/APNs) に接続し、SwiftUIアプリへ通知を送信。
