---
sidebar_position: 1
slug: /
---

# バイオインフォマティクス講義ノート

## 📚 このサイトについて

Courseraの[Bioinformatics Specialization](https://www.coursera.org/specializations/bioinformatics)の講義ノートをまとめたサイトです。

バイオインフォマティクスの基礎から応用まで、アルゴリズムと生物学の両面から学習していきます。

## 🌟 初めての方へ

プログラミングは分かるけど生物学は初めてという方は、まずこちらから。

→ [生物学の基礎知識](./basics/biology-fundamentals) - DNAとは何かから始める超入門。
→ [バイオインフォマティクスと合成生物学の違い](./basics/bioinformatics-vs-synthetic-biology) - 解析と創造の違い。
→ [mRNAとは何か](./basics/what-is-mrna) - セントラルドグマから理解する。
→ [なぜ大腸菌がこんなに使われるのか](./basics/e-coli-why-so-important) - 生物学研究の主役、大腸菌の秘密。

## 🧬 学習内容

### Week 1: DNA複製の基礎

- [DNA複製はゲノムのどこで始まるのか（前編）](./lectures/week1/dna-replication-part1)
  - 複製起点（OriC）の探索
  - 頻出語問題（Frequent Words Problem）
  - DnaAボックスの発見
  - 📘 [超詳細版もあります](./lectures/week1/dna-replication-part1-detailed) - 細野真宏先生スタイルの丁寧な解説

- [DNA複製はゲノムのどこで始まるのか（後編）](./lectures/week1/dna-replication-part2)
  - 塊探し問題（Clump Finding Problem）
  - 逆相補鎖の考慮
  - 実際のゲノムへの適用

- [DNA複製はゲノムのどこで始まるのか（その3：GCスキュー）](./lectures/week1/dna-replication-part3)
  - DNA複製の非対称性
  - リーディング鎖とラギング鎖
  - GCスキュー分析

- [DNA複製はゲノムのどこで始まるのか（その4：実践と課題）](./lectures/week1/dna-replication-part4)
  - 大腸菌での実践
  - ミスマッチの重要性
  - 現実世界の複雑性

### Week 2: モチーフ発見

- [モチーフ発見問題（基礎）](./lectures/week2/motif-finding-part1)
  - 遺伝子制御とモチーフ
  - (k,d)モチーフの概念
  - モチーフ列挙アルゴリズム
  - 📘 [超詳細版](./lectures/week2/motif-finding-part1-detailed) - 遺伝子のON/OFFスイッチを探す

- [ランダム化モチーフ探索](./lectures/week2/randomized-motif-search-detailed)
  - なぜランダムが正解を導くのか
  - プロファイルとモチーフの相互変換
  - 結核菌の冬眠メカニズム

- [ギブスサンプラー](./lectures/week2/gibbs-sampler-detailed)
  - より賢いサイコロの振り方
  - 擬似カウントの重要性
  - クロムウェルの法則

- [ラプラスの法則とChIP-seq](./lectures/week2/laplace-and-chip-seq-detailed)
  - ゼロ確率問題の解決
  - 実験技術との融合
  - アルゴリズムの限界と突破

- [モチーフ発見から創薬へ](./lectures/week2/understanding-motif-and-drug-discovery)
  - MEME実習で学んだこと
  - DNA配列の無効化メカニズム
  - 実際の薬の作り方

### Week 3: ゲノムアセンブリ

- [ゲノムシーケンシングとは](./lectures/week3/genome-sequencing-intro)
  - DNAを読む技術の革命
  - 個別化医療への道
  - 1000ドルゲノムの時代

- [ゲノムアセンブリ入門](./lectures/week3/genome-assembly-intro)
  - ショットガン法の原理
  - アセンブリの課題

- [オイラー経路によるアセンブリ](./lectures/week3/genome-assembly-euler)
  - グラフ理論の応用
  - de Bruijnグラフ

- [ハミルトン経路問題](./lectures/week3/hamiltonian-path-problem)
  - NP完全問題の理解

- [文字列再構成問題](./lectures/week3/string-reconstruction-problem)
  - k-merからの再構成

### Week 4: 抗生物質の発見とペプチド配列決定

- [抗生物質の発見](./lectures/week4/antibiotic-discovery)
  - ペプチド系抗生物質の仕組み

- [細菌による抗生物質生産](./lectures/week4/bacterial-antibiotic-production)
  - 非リボソーム性ペプチド合成

- [質量分析によるペプチド配列決定](./lectures/week4/mass-spectrometry-sequencing)
  - スペクトルからの配列再構成

- [de Bruijnグラフの応用](./lectures/week4/de-bruijn-graph)
  - ゲノムアセンブリの実践

### Bioinformatics III: 配列比較

- [コース紹介](./lectures/bioinformatics3/course-introduction)
  - 配列比較の重要性

- [マンハッタン観光客問題](./lectures/bioinformatics3/manhattan-tourist-problem)
  - 動的計画法の基礎

- [配列アラインメントゲーム](./lectures/bioinformatics3/alignment-game-and-lcs)
  - LCS（最長共通の部分列）問題

- [グローバルからローカルアラインメントへ](./lectures/bioinformatics3/global-to-local-alignment)
  - Smith-Watermanアルゴリズム

- [ゲノム再配列](./lectures/bioinformatics3/genome-rearrangements-man-to-mouse)
  - ヒトとマウスの比較

- [ブレークポイントグラフ](./lectures/bioinformatics3/breakpoint-graph-detailed)
  - ゲノム再配列の数学

### Bioinformatics IV: 分子進化

- [分子進化入門](./lectures/bioinformatics4/course-introduction-molecular-evolution)
  - 進化の分子時計

- [距離行列から系統樹へ](./lectures/bioinformatics4/distance-matrix-to-tree)
  - 系統樹構築の基礎

- [加法系統樹](./lectures/bioinformatics4/additive-phylogeny)
  - 距離の加法性

- [最小二乗法による系統樹](./lectures/bioinformatics4/least-squares-phylogeny)
  - 最適化アプローチ

- [UPGMA法](./lectures/bioinformatics4/ultrametric-trees-upgma)
  - ウルトラメトリック木の構築

## 🔧 アルゴリズム

- [頻出語問題](./algorithms/frequent-words)
- [GCスキュー分析](./algorithms/gc-skew)
- [ミスマッチを許容する頻出語問題](./algorithms/frequent-words-mismatches)
- パターンマッチング（準備中）
- グラフアルゴリズム（準備中）
- 動的計画法（準備中）

## 🚀 先端技術

- [STATE - AIが細胞を理解する時代](./advanced/state-and-ai-in-biology)
  - Arc InstituteのAIモデル
  - LLMと生物学の融合
- [mRNAワクチンはどう作られたか](./advanced/mrna-vaccine-development)
  - 2日で設計された理由
  - バイオインフォマティクスの貢献
- [創薬の限界と合成生物学の突破](./advanced/drug-discovery-limits-and-synthetic-biology)
  - 既存の改善vs抜本的変革
  - CAR-T療法などの成功例

## 📖 参考資料

- [用語集](./resources/glossary)
- 推奨図書（準備中）
- 関連リンク（準備中）

## 🚀 はじめ方

1. 基礎知識の確認
   - 基本的な生物学の知識
   - プログラミングの基礎（Python推奨）

2. 週ごとの学習
   - 各週の講義ノートを順番に読む
   - アルゴリズムの実装を試す
   - 練習問題を解く

3. 実践
   - Rosalindの問題を解く
   - 実際のゲノムデータで分析を試す

## 📝 注意事項

- このノートは個人的な学習記録である
- 内容の正確性については保証しない
- 最新の情報は公式のCourseraコースを参照すること
