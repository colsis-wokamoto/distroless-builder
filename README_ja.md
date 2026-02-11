# distroless-image

## 概要
- distroless ベースイメージをビルドして公開するためのリポジトリです。
- ビルド定義は `docker-bake.hcl` と `Makefile` で管理されています。
- Dockerfile は `dockerfiles/` 配下で管理されています。

## 技術スタック
- Docker Buildx Bake（`docker buildx bake`）
- `gcr.io/distroless/base-debian13` を利用したマルチステージ Dockerfile
- 手動公開用の GitHub Actions（`workflow_dispatch`）

## 管理対象イメージ
`docker-bake.hcl` のビルドターゲット:
- `distroless-base-apache24`
- `distroless-base-movabletype`
- `distroless-base-nginx`
- `distroless-base-wordpress-cli`
- `distroless-base-wordpress-php83`
- `distroless-base-wordpress-php84`
- `distroless-base-wordpress-php85`

タグ形式:
- `${NAMESPACE}/distroless-base:<variant>-${TAG}`
- 例: `your-namespace/distroless-base:apache24-latest`

## 設定値
主な変数（`Makefile` / `.env.example`）:
- `DOCKERHUB_NAMESPACE`（デフォルトの namespace ソース）
- `NAMESPACE`（既定値は `DOCKERHUB_NAMESPACE`、未設定時は `local`）
- `TAG`（既定値: `latest`）
- `PLATFORMS`（既定値: `linux/amd64,linux/arm64`）
- `TIME_ZONE`（既定値: `Asia/Tokyo`）
- `WP_VERSION`（既定値: `latest`）

## 主要パス
- `docker-bake.hcl`
- `Makefile`
- `.env.example`
- `.github/workflows/dockerhub-publish.yml`
- `dockerfiles/apache24/Dockerfile`
- `dockerfiles/movabletype/Dockerfile`
- `dockerfiles/nginx/Dockerfile`
- `dockerfiles/wordpress/cli/Dockerfile`
- `dockerfiles/wordpress/php83/Dockerfile`
- `dockerfiles/wordpress/php84/Dockerfile`
- `dockerfiles/wordpress/php85/Dockerfile`

## ローカル開発
1. 環境変数ファイルを準備:
```bash
cp .env.example .env
```

2. 実行可能な Make ターゲットを確認:
```bash
make help
```

3. buildx bake のターゲット一覧を確認:
```bash
make list
```

4. 反映される設定値を確認:
```bash
make config
```

5. 単体イメージをローカルビルド:
```bash
make build IMAGE=distroless-base-nginx TAG=latest
```

6. 全イメージをローカルビルド:
```bash
make build-all TAG=latest
```

7. 単体イメージを push:
```bash
make login
make push IMAGE=distroless-base-nginx TAG=latest
```

8. 全イメージを push:
```bash
make login
make push-all TAG=latest
```

## GitHub Actions
手動公開は `.github/workflows/dockerhub-publish.yml`（`workflow_dispatch`）で定義されています。

入力パラメータ:
- `target`（`all` または単体ターゲット名）
- `tag`
- `platforms`
- `time_zone`
- `wp_version`

必要な GitHub Secrets:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

## 補足
- `dockerfiles/movabletype/Dockerfile` は Movable Type 本体ソースを含まないランタイムイメージを作成します。
