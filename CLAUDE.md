# バイオインフォマティクス講義ノート - プロジェクトコンテキスト

## 📝 プロジェクト概要

CourseraのBioinformatics Specializationの講義ノートをDocusaurusで管理するプロジェクト。
講義の内容を日本語でまとめ、アルゴリズムの実装例と共に学習できるサイトを構築中。

### 🌐 デプロイ情報

- URL: https://susumutomita.github.io/bioinformatics-note/
- GitHub Pages + GitHub ActionsでのCI/CD構築済み
- mainブランチへのプッシュで自動デプロイ

## 📚 現在の進捗

### 完了した講義

1. **DNA複製はゲノムのどこで始まるのか（前編）**
   - 複製起点（OriC）の概念
   - 頻出語問題（Frequent Words Problem）
   - DnaAボックスの役割

2. **DNA複製はゲノムのどこで始まるのか（後編）**
   - 実際のゲノムへの適用（コレラ菌、サーモトガ・ペトロフィラ）
   - 逆相補鎖の重要性
   - 塊探し問題（Clump Finding Problem）
   - 大腸菌での課題（候補が多すぎる問題）

### 実装済みアルゴリズム

- 頻出語問題（Frequent Words Problem）の実装とバリエーション
- PatternCount関数
- ReverseComplement関数

## 🎯 次回の作業予定

### 追加予定のコンテンツ

1. **塊探し問題（Clump Finding Problem）の詳細ページ**
   - アルゴリズムの実装
   - 計算量の改善
   - 実例での応用

2. **GCスキュー分析**
   - 複製起点特定の追加手法
   - 可視化の実装

3. **Week 2以降の講義**
   - ゲノムアセンブリ
   - 配列アラインメント
   - 系統樹構築

### 技術的改善点

- インタラクティブなコード実行環境の追加検討
- 可視化ツールの統合
- 練習問題セクションの追加

## 🛠️ 技術スタック

- **フレームワーク**: Docusaurus v3.8.1
- **パッケージマネージャー**: Bun
- **CI/CD**: GitHub Actions
- **デプロイ**: GitHub Pages
- **品質管理**:
  - textlint（日本語チェック）
  - markdownlint
  - prettier（フォーマット）
  - husky（pre-commitフック）

## 📂 ディレクトリ構造

```
docs/
├── intro.md                        # トップページ
├── lectures/                       # 講義フォルダ
│   └── week1/
│       ├── dna-replication-part1.md  # DNA複製（前編）
│       └── dna-replication-part2.md  # DNA複製（後編）
├── algorithms/                     # アルゴリズム
│   └── frequent-words.md          # 頻出語問題
└── resources/                      # 参考資料
    └── glossary.md                # 用語集
```

## ⚠️ 開発ルール（必須）

### 品質チェックの徹底

**すべてのコンテンツ追加・修正時に必ず実行**：

```bash
# 必ず実行して全てパスすること
make before-commit
```

エラーが出た場合は修正してから再度実行。
リント・フォーマットエラーは自動修正可能：

```bash
make lint-text-fix
make lint-markdown-fix
make format
```

### コンテンツ作成方針

1. **正確性の確保**
   - 情報の正確性を最優先
   - 不確かな情報は「推測」「仮説」と明記
   - 出典・参考文献を明記

2. **初学者への配慮**
   - ソフトウェアエンジニアがバイオインフォマティクスに取り組む際の視点を重視
   - 生物学の前提知識が必要な箇所は必ず説明
   - 躓きやすいポイントを省略せず丁寧に解説

3. **視覚的理解の促進**
   - 図・図解を積極的に使用（Mermaid図を活用）
   - コード例と実行結果を必ず示す
   - ステップバイステップの説明

4. **実用性の重視**
   - 理論だけでなく実装方法も詳細に説明
   - エラー処理やエッジケースも解説
   - 計算量や実行時間の考察を含める

## 💡 重要な設計判断

1. **日本語優先**
   - Courseraの英語講義を日本語で解説
   - 専門用語は英語併記

2. **コード例の充実**
   - Pythonでの実装例を豊富に提供
   - 段階的な改良版も掲載

3. **生物学的背景の重視**
   - アルゴリズムだけでなく、生物学的意味も詳しく説明
   - 実際のゲノムでの例を積極的に使用

## 🔧 便利なコマンド

```bash
# 開発サーバー起動
make dev

# ビルド
make build

# コミット前チェック
make before-commit

# デプロイ手順確認
make deploy-gh-pages

# リント修正
make lint-text-fix
make lint-markdown-fix
```

## 📝 注意事項

- 画像ファイルは`static/img/`に配置
- 新しい講義ページを追加したら`sidebars.ts`の更新を忘れずに
- コミット前に`make before-commit`でチェック
- デプロイはmainブランチへのプッシュで自動実行

## 🔗 関連リンク

- [Coursera - Bioinformatics Specialization](https://www.coursera.org/specializations/bioinformatics)
- [Rosalind - バイオインフォマティクス問題集](http://rosalind.info/)
- [GitHub リポジトリ](https://github.com/susumutomita/bioinformatics-note)

---

最終更新: 2025年1月
