# distroless-builder-image

## 概要
- distroless 指向のランタイムベース用 Docker イメージ成果物をビルドするリポジトリです。
- ビルド定義は `docker-bake.hcl` と `Makefile` で管理されています。
- Dockerfile はランタイム・バージョン別に `dockerfiles/` 配下に配置されています。
- `Makefile` は `.env` が存在する場合に自動で読み込みます。

## 技術スタック
- Docker Buildx Bake（`docker buildx bake`）
- ローカルビルド・Push 用の GNU Make ワークフロー
- ランタイム実行ファイルと依存共有ライブラリを収集するマルチステージ構成
- 脆弱性比較用の Trivy + `jq` フロー（`make trivy-*` ターゲット）

## 主要パス
- `docker-bake.hcl`
- `Makefile`
- `.env.example`
- `dockerfiles/httpd/2.4/Dockerfile`
- `dockerfiles/nginx/latest/Dockerfile`
- `dockerfiles/nginx/stable/Dockerfile`
- `dockerfiles/php/8.3/Dockerfile`
- `dockerfiles/php/8.4/Dockerfile`
- `dockerfiles/php/8.5/Dockerfile`
- `dockerfiles/perl/5.40/Dockerfile`
- `dockerfiles/perl/5.40/README-DBD-mysql.md`
- `dockerfiles/wordpress/cli/Dockerfile`

## ビルドターゲット
`docker-bake.hcl` で定義されているターゲット:
- `httpd`（`dockerfiles/httpd/2.4/Dockerfile`）
- `nginx`（`dockerfiles/nginx/latest/Dockerfile`）
- `nginx-stable`（`dockerfiles/nginx/stable/Dockerfile`）
- `php83`（`dockerfiles/php/8.3/Dockerfile`）
- `php84`（`dockerfiles/php/8.4/Dockerfile`）
- `php85`（`dockerfiles/php/8.5/Dockerfile`）
- `perl`（`dockerfiles/perl/5.40/Dockerfile`）
- `wp-cli`（`dockerfiles/wordpress/cli/Dockerfile`）

`docker-bake.hcl` の変数に基づくタグ形式:
- `${NAMESPACE}/${PROJECT}-httpd:${TAG}`
- `${NAMESPACE}/${PROJECT}-nginx:${TAG}`
- `${NAMESPACE}/${PROJECT}-nginx:stable`
- `${NAMESPACE}/${PROJECT}-php8.3:${TAG}`
- `${NAMESPACE}/${PROJECT}-php8.4:${TAG}`
- `${NAMESPACE}/${PROJECT}-php8.5:${TAG}`
- `${NAMESPACE}/${PROJECT}-perl:${TAG}`
- `${NAMESPACE}/${PROJECT}-wp-cli:${TAG}`

## 設定
主要な変数（`.env.example` / `Makefile` / `docker-bake.hcl`）:
- `DOCKERHUB_NAMESPACE`（namespace の既定ソース）
- `NAMESPACE`（既定値は `DOCKERHUB_NAMESPACE`、未設定時は `local`）
- `PROJECT`（既定値: `distroless-builder`）
- `TAG`（既定値: `latest`）
- `PLATFORMS`（既定値: `linux/amd64,linux/arm64`）
- `LOCAL_TAG_WITH_ARCH`（`Makefile` の既定値: `1`）
- `BAKE_FILE`（既定値: `docker-bake.hcl`）
- `TRIVY_OUT_DIR`（既定値: `/tmp/trivy-distroless-compare`）
- `TIME_ZONE`、`WP_VERSION`（任意。特定ターゲット用に `.env` で設定可能。`make config` で表示）

## ローカル開発
1. 環境変数ファイルを作成:
   ```bash
   cp .env.example .env
   ```

2. Make ターゲットと解決済み変数を表示:
   ```bash
   make help
   make config
   ```

3. bake ターゲット一覧を表示:
   ```bash
   make list
   ```

4. 単体ターゲットをローカルビルド:
   ```bash
   make build IMAGE=nginx TAG=latest
   ```

5. 全ターゲットをローカルビルド:
   ```bash
   make build-all TAG=latest
   ```

6. 単体ターゲットを Push:
   ```bash
   make login
   make push IMAGE=nginx TAG=latest
   ```

7. 全ターゲットを Push:
   ```bash
   make login
   make push-all TAG=latest
   ```

`PLATFORMS` に複数プラットフォームを指定したローカルビルドでは、`LOCAL_TAG_WITH_ARCH=1` のとき `--load` 時に `-amd64` / `-arm64` などの接尾辞が付き、タグの上書きを防ぎます。

## Trivy 比較フロー
1. 比較用参照イメージを Pull:
   ```bash
   make trivy-pull
   ```

2. スキャンして生 JSON を保存:
   ```bash
   make trivy-scan
   ```

3. 重大度サマリ表を表示:
   ```bash
   make trivy-summary
   ```

スキャンとサマリを一括実行:
   ```bash
   make trivy-compare
   ```

## 補足
- `make push` / `make push-all` は `NAMESPACE=local` のときに意図的に失敗します。
- `dockerfiles/perl/5.40/README-DBD-mysql.md` に、`DBD::mysql` ビルドで Oracle MySQL クライアントライブラリを用いる理由を記載しています。
