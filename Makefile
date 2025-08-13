# Bioinformatics講義ノート Makefile
# ========================================

# 変数定義
# --------
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# 設定
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
NODE_VERSION := $(shell node --version 2>/dev/null || echo "not installed")
BUN_VERSION := $(shell bun --version 2>/dev/null || echo "not installed")

# 色付き出力用
GREEN := \033[32m
RED := \033[31m
YELLOW := \033[33m
RESET := \033[0m

# デフォルトターゲット
# --------------------
.DEFAULT_GOAL := help

# Phonyターゲット宣言
# ------------------
.PHONY: help
.PHONY: install install-ci
.PHONY: dev build serve
.PHONY: lint lint-text lint-text-fix lint-markdown lint-markdown-fix
.PHONY: format format-check
.PHONY: typecheck
.PHONY: clean clean-all
.PHONY: before-commit setup-husky

# ヘルプ
# ------
help:
	@echo "Bioinformatics 講義ノート - Make コマンド一覧"
	@echo "=================================================="
	@echo ""
	@printf "$(GREEN)開発:$(RESET)\n"
	@echo "  make dev           - 開発サーバーを起動"
	@echo "  make build         - プロダクションビルド"
	@echo "  make serve         - ビルド済みサイトをプレビュー"
	@echo ""
	@printf "$(GREEN)インストール:$(RESET)\n"
	@echo "  make install       - 依存パッケージをインストール"
	@echo "  make install-ci    - CI用の依存パッケージをインストール"
	@echo ""
	@printf "$(GREEN)品質管理:$(RESET)\n"
	@echo "  make lint          - すべてのリントチェックを実行"
	@echo "  make lint-text     - textlintでドキュメントをチェック"
	@echo "  make lint-text-fix - textlintで自動修正"
	@echo "  make lint-markdown - markdownlintでチェック"
	@echo "  make lint-markdown-fix - markdownlintで自動修正"
	@echo ""
	@printf "$(GREEN)フォーマット:$(RESET)\n"
	@echo "  make format        - コードをフォーマット"
	@echo "  make format-check  - フォーマットチェック（CIで使用）"
	@echo ""
	@printf "$(GREEN)型チェック:$(RESET)\n"
	@echo "  make typecheck     - TypeScriptの型チェック"
	@echo ""
	@printf "$(GREEN)その他:$(RESET)\n"
	@echo "  make before-commit - コミット前チェック"
	@echo "  make setup-husky   - Git フックのセットアップ"
	@echo "  make clean         - ビルド成果物を削除"
	@echo "  make clean-all     - node_modulesを含むすべてをクリーン"

# インストール関連
# ----------------
install: check-bun
	@echo "依存パッケージをインストールしています..."
	@bun install
	@$(MAKE) setup-husky
	@printf "$(GREEN)✅ インストール完了$(RESET)\n"

install-ci:
	@echo "CI環境用の依存パッケージをインストールしています..."
	@bun install --frozen-lockfile
	@printf "$(GREEN)✅ CI用インストール完了$(RESET)\n"

check-bun:
	@echo "bunのインストールを確認しています..."
	@if [ "$(BUN_VERSION)" = "not installed" ]; then \
		printf "$(RED)❌ bun がインストールされていません$(RESET)\n"; \
		echo "curl -fsSL https://bun.sh/install | bash を実行してインストールしてください"; \
		exit 1; \
	else \
		printf "$(GREEN)✅ bun $(BUN_VERSION) がインストールされています$(RESET)\n"; \
	fi

# 開発関連
# --------
dev:
	@echo "開発サーバーを起動しています..."
	@echo "http://localhost:3000 でアクセスできます"
	@bun run start

build:
	@echo "プロダクションビルドを実行しています..."
	@bun run build
	@printf "$(GREEN)✅ ビルド完了$(RESET)\n"

serve:
	@echo "ビルド済みサイトをプレビューしています..."
	@bun run serve

# リント関連
# ----------
lint: lint-text lint-markdown typecheck
	@printf "$(GREEN)✅ すべてのリントチェック完了$(RESET)\n"

lint-text:
	@echo "textlintでドキュメントをチェックしています..."
	@bun run textlint || (printf "$(YELLOW)⚠️  textlintの警告があります$(RESET)\n")
	@printf "$(GREEN)✅ textlint完了$(RESET)\n"

lint-text-fix:
	@echo "textlintで自動修正しています..."
	@bun run textlint:fix
	@printf "$(GREEN)✅ textlint自動修正完了$(RESET)\n"

lint-markdown:
	@echo "markdownlintでチェックしています..."
	@bun run markdownlint || (printf "$(RED)❌ markdownlintエラーがあります$(RESET)\n" && exit 1)
	@printf "$(GREEN)✅ markdownlint完了$(RESET)\n"

lint-markdown-fix:
	@echo "markdownlintで自動修正しています..."
	@bun run markdownlint:fix
	@printf "$(GREEN)✅ markdownlint自動修正完了$(RESET)\n"

# フォーマット関連
# ----------------
format:
	@echo "コードをフォーマットしています..."
	@bun run prettier --write .
	@printf "$(GREEN)✅ フォーマット完了$(RESET)\n"

format-check:
	@echo "フォーマットをチェックしています..."
	@bun run prettier --check . || (printf "$(RED)❌ フォーマットが必要なファイルがあります$(RESET)\n" && exit 1)
	@printf "$(GREEN)✅ フォーマットチェック完了$(RESET)\n"

# 型チェック
# ----------
typecheck:
	@echo "TypeScriptの型チェックを実行しています..."
	@bun run typecheck || (printf "$(RED)❌ TypeScriptの型エラーがあります$(RESET)\n" && exit 1)
	@printf "$(GREEN)✅ 型チェック完了$(RESET)\n"

# クリーン関連
# ------------
clean:
	@echo "ビルド成果物を削除しています..."
	@rm -rf build/
	@rm -rf .docusaurus/
	@printf "$(GREEN)✅ クリーン完了$(RESET)\n"

clean-all: clean
	@echo "すべての生成物を削除しています..."
	@rm -rf node_modules/
	@rm -f bun.lock
	@rm -f pnpm-lock.yaml
	@printf "$(GREEN)✅ 完全クリーン完了$(RESET)\n"

# Git フック関連
# --------------
before-commit:
	@echo "コミット前チェックを実行しています..."
	@$(MAKE) format-check
	@$(MAKE) lint
	@printf "$(GREEN)✅ すべてのチェックが完了しました$(RESET)\n"

setup-husky:
	@echo "Git フックをセットアップしています..."
	@if [ ! -d .husky ]; then \
		bun run husky; \
		echo "make before-commit" > .husky/pre-commit; \
		chmod +x .husky/pre-commit; \
		printf "$(GREEN)✅ Huskyセットアップ完了$(RESET)\n"; \
	else \
		printf "$(YELLOW)⚠️  Huskyは既にセットアップされています$(RESET)\n"; \
	fi