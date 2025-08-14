# Bioinformatics Note

バイオインフォマティクス講義ノート

## 📚 概要

このリポジトリは、バイオインフォマティクスの講義ノートをDocusaurusで管理するプロジェクトです。

- 講義ノート: https://www.coursera.org/specializations/bioinformatics
- デプロイ先: https://susumutomita.github.io/bioinformatics-note/

## 🚀 セットアップ

### 必要要件

- Node.js 18以上
- Bun

### インストール

```bash
# bunのインストール
curl -fsSL https://bun.sh/install | bash

# 依存関係のインストール
make install
```

## 📝 使い方

### 開発

```bash
# 開発サーバー起動
make dev
# または
bun run start
```

### ビルド

```bash
make build
# または
bun run build
```

### リント・フォーマット

```bash
# すべてのチェック
make before-commit

# フォーマット
make format

# リント修正
make lint-text-fix
make lint-markdown-fix
```

## 🌐 GitHub Pagesへのデプロイ

このプロジェクトはGitHub Actionsを使用して自動デプロイされます。

### セットアップ手順

1. **GitHubリポジトリの設定**
   - リポジトリの`Settings` > `Pages`へ移動
   - Source: `GitHub Actions`を選択

2. **デプロイ**

   ```bash
   # mainブランチにプッシュすると自動デプロイ
   git push origin main
   ```

3. **確認**
   - Actions タブでデプロイ状況を確認
   - デプロイ完了後: https://susumutomita.github.io/bioinformatics-note/

### 手動デプロイ

GitHub Actionsのワークフローは手動実行も可能です：

1. Actions タブへ移動
2. "Deploy to GitHub Pages"を選択
3. "Run workflow"をクリック

## 📂 ディレクトリ構成

```
.
├── docs/           # ドキュメントファイル
├── src/            # カスタムコンポーネント・CSS
├── static/         # 静的ファイル
├── .github/        # GitHub Actions
│   └── workflows/
│       ├── ci.yml      # CI/CDワークフロー
│       └── deploy.yml  # デプロイワークフロー
├── Makefile        # ビルドコマンド
└── docusaurus.config.ts  # Docusaurus設定
```

## 🛠️ Makeコマンド一覧

```bash
make help           # ヘルプを表示
make dev            # 開発サーバー起動
make build          # プロダクションビルド
make lint           # リントチェック
make format         # コードフォーマット
make before-commit  # コミット前チェック
make deploy-gh-pages # デプロイ手順を表示
```

## 📄 ライセンス

MIT
