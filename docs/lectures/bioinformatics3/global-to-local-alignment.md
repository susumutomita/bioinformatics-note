---
sidebar_position: 6
title: グローバルからローカルへ：配列アライメントの高度な手法
---

# グローバルからローカルへ：配列アライメントの高度な手法

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：配列全体の比較（グローバルアライメント）から、類似した部分領域の発見（ローカルアライメント）へと発展させ、生物学的に意味のある配列比較を実現します。

でも、ちょっと待ってください。そもそも...

## 🤔 ステップ0：なぜ単純なスコアリングでは不十分なの？

### 最長共通部分列の問題点

```
最初のアプローチ：
マッチした文字数を数える
→ 単純すぎる！

例：アデニル化ドメインのアライメント
生物学的に正しい：短いが意味のある一致
数学的に最適：長いが無意味な一致

どちらを選ぶべき？
```

### 生物学的現実

```python
# ナイーブなスコアリング
def naive_score(alignment):
    return sum(1 for a, b in alignment if a == b)

# 問題：生物学的に無意味な「偶然の一致」も高得点に！
```

### なぜこれが問題？

```
DNA配列の特徴：
- たった4文字（A, T, G, C）
- 偶然の一致が頻繁に起こる
- 保存された領域こそが重要

→ より洗練されたスコアリングが必要！
```

## 📊 ステップ1：スコアリングマトリックスの導入

### 1-1. 基本的な考え方

```
新しいスコアリング：
- マッチ：プレミアムボーナス（＋）
- ミスマッチ：ペナルティ（−μ）
- インデル：ペナルティ（−σ）

例：
ATCG
AT-G

旧スコア：3（マッチ数）
新スコア：3×(+1) + 0×(-μ) + 1×(-σ) = 3 - σ
```

### 1-2. スコアリングマトリックスの設計

```python
# ヌクレオチドのスコアリングマトリックス
scoring_matrix = {
    ('A', 'A'): +1, ('A', 'T'): -1, ('A', 'G'): -1, ('A', 'C'): -1,
    ('T', 'A'): -1, ('T', 'T'): +1, ('T', 'G'): -1, ('T', 'C'): -1,
    ('G', 'A'): -1, ('G', 'T'): -1, ('G', 'G'): +1, ('G', 'C'): -1,
    ('C', 'A'): -1, ('C', 'T'): -1, ('C', 'G'): -1, ('C', 'C'): +1,
    ('-', 'X'): -2,  # ギャップペナルティ
    ('X', '-'): -2   # ギャップペナルティ
}
```

### 1-3. アミノ酸配列の場合

```
アミノ酸の変異傾向を反映：

例：
Y（チロシン）→ F（フェニルアラニン）：+7（頻繁に起こる）
P（プロリン）→ E（グルタミン酸）：-5（ほぼ起こらない）

生物学的根拠：
- 化学的性質が似ている → 高スコア
- 機能が保存されやすい → 高スコア
- 進化的に置換されやすい → 高スコア
```

## 🧬 ステップ2：グローバルアライメントの改良

### 2-1. 動的計画法の更新

```python
def global_alignment_with_scoring(v, w, scoring_matrix):
    """スコアリングマトリックスを使用したグローバルアライメント"""
    m, n = len(v), len(w)
    S = [[0] * (n+1) for _ in range(m+1)]

    # 再帰的計算
    for i in range(1, m+1):
        for j in range(1, n+1):
            # 3つの選択肢
            match = S[i-1][j-1] + scoring_matrix[(v[i-1], w[j-1])]
            delete = S[i-1][j] + scoring_matrix[(v[i-1], '-')]
            insert = S[i][j-1] + scoring_matrix[('-', w[j-1])]

            S[i][j] = max(match, delete, insert)

    return S[m][n]
```

### 2-2. エッジの重み付け

```
アライメントグラフのエッジ：
→ 水平エッジ：削除（重み = -σ）
↓ 垂直エッジ：挿入（重み = -σ）
↘ 対角エッジ：マッチ/ミスマッチ（重み = スコアリングマトリックス値）
```

### 2-3. グローバルアライメント問題の定式化

```
入力：
- 文字列 v, w
- スコアリングマトリックス

出力：
- v と w のアライメントで、スコアが最大のもの

目的：
配列全体の最適な対応付けを見つける
```

## 🔍 ステップ3：グローバルアライメントの限界

### 3-1. ホメオボックス遺伝子の例

```
ホメオボックス遺伝子：
全長：約1000塩基対
ホメオドメイン：約180塩基対（高度に保存）

問題：
グローバルアライメントでは、
短い保存領域が見逃される！

理由：
全体の類似度は低いが、
部分的に重要な類似性がある
```

### 3-2. 2つのアライメントの比較

```
アライメント1（グローバル最適）：
ATCGATCGATCGATCG
||||  ||  ||  ||
ATCG--CG--CG--CG
スコア：高い（全体的な一致）

アライメント2（局所的に優れる）：
----ATCGATCG----
    ||||||||
----ATCGATCG----
スコア：低い（でも生物学的に重要！）
```

### 3-3. なぜローカルアライメントが必要？

```
生物学的現実：
1. 機能ドメインは部分的
2. 進化的に保存された領域は限定的
3. 遺伝子の融合・分裂が起こる

→ 配列の一部だけを比較したい！
```

## 🚕 ステップ4：無料タクシーのアイデア

### 4-1. 概念の導入

```
アイデア：
「保存された領域まで無料で移動し、
そこだけをスコアリングする」

イメージ：
出発点 ━━🚕━━> 保存領域開始
         （無料）

保存領域 ━━━━━> 保存領域終了
      （スコア計算）

保存領域終了 ━━🚕━━> 終点
           （無料）
```

### 4-2. グラフへの実装

```python
# 無料タクシー = 重み0のエッジ

def add_free_rides(graph):
    """グラフに無料タクシーエッジを追加"""

    # ソースから全ノードへ
    for node in all_nodes:
        add_edge(source, node, weight=0)

    # 全ノードからシンクへ
    for node in all_nodes:
        add_edge(node, sink, weight=0)

    return graph
```

### 4-3. エッジ数の増加

```
元のグラフ：
エッジ数 = O(mn)（m×nグリッド）

無料タクシー追加後：
追加エッジ = O(mn)（ソースから）+ O(mn)（シンクへ）
合計 = O(mn)

→ 計算量は変わらない！
```

## 🎮 ステップ5：ローカルアライメントの実装

### 5-1. 動的計画法の修正

```python
def local_alignment(v, w, scoring_matrix):
    """ローカルアライメントアルゴリズム"""
    m, n = len(v), len(w)
    S = [[0] * (n+1) for _ in range(m+1)]

    for i in range(1, m+1):
        for j in range(1, n+1):
            # 4つの選択肢（無料タクシーを追加）
            match = S[i-1][j-1] + scoring_matrix[(v[i-1], w[j-1])]
            delete = S[i-1][j] + scoring_matrix[(v[i-1], '-')]
            insert = S[i][j-1] + scoring_matrix[('-', w[j-1])]
            free_ride = 0  # 新しい選択肢！

            S[i][j] = max(match, delete, insert, free_ride)

    # 最大スコアを持つセルを探す
    max_score = 0
    max_i, max_j = 0, 0
    for i in range(m+1):
        for j in range(n+1):
            if S[i][j] > max_score:
                max_score = S[i][j]
                max_i, max_j = i, j

    return max_score, max_i, max_j
```

### 5-2. バックトラッキングの変更

```python
def backtrack_local(S, v, w, max_i, max_j):
    """ローカルアライメントのバックトラッキング"""
    alignment = []
    i, j = max_i, max_j

    # スコアが0になるまで逆向きにたどる
    while i > 0 and j > 0 and S[i][j] > 0:
        if S[i][j] == S[i-1][j-1] + score(v[i-1], w[j-1]):
            alignment.append((v[i-1], w[j-1]))
            i -= 1
            j -= 1
        elif S[i][j] == S[i-1][j] + gap_penalty:
            alignment.append((v[i-1], '-'))
            i -= 1
        else:
            alignment.append(('-', w[j-1]))
            j -= 1

    return reversed(alignment)
```

### 5-3. 計算の最適化

```
重要な観察：
- 負のスコアは無視できる（0でリセット）
- 最大スコアのセルが終点
- 複数の最適解が存在可能

時間計算量：O(mn)
空間計算量：O(mn)
```

## 🌟 ステップ6：実用例

### 6-1. BLAST検索の基礎

```python
# BLASTの簡略版
def simple_blast(query, database):
    """データベース内で類似配列を検索"""
    hits = []

    for sequence in database:
        score, start, end = local_alignment(query, sequence)
        if score > threshold:
            hits.append({
                'sequence': sequence,
                'score': score,
                'region': (start, end)
            })

    return sorted(hits, key=lambda x: x['score'], reverse=True)
```

### 6-2. ドメイン検索

```
タンパク質ドメイン検索：

入力配列：長いタンパク質配列（1000アミノ酸）
検索対象：既知のドメイン（100アミノ酸）

ローカルアライメント結果：
位置 234-334：キナーゼドメイン（スコア: 89）
位置 567-667：DNAバインディングドメイン（スコア: 76）

→ 機能予測が可能に！
```

### 6-3. 進化的関係の解析

```python
def find_conserved_regions(sequences):
    """複数配列から保存領域を発見"""
    conserved = []

    for i in range(len(sequences)):
        for j in range(i+1, len(sequences)):
            score, region = local_alignment(sequences[i], sequences[j])
            if score > conservation_threshold:
                conserved.append(region)

    return merge_overlapping_regions(conserved)
```

## 💡 ステップ7：まとめ

### レベル1：基礎理解

```
学んだこと：
1. スコアリングマトリックスの必要性
2. グローバルvsローカルアライメント
3. 無料タクシーの概念
```

### レベル2：応用理解

```
できるようになったこと：
1. 生物学的に意味のあるアライメント
2. 保存領域の発見
3. 機能ドメインの検出
```

### レベル3：実装理解

```python
# 完全なローカルアライメント実装
def complete_local_alignment(v, w, match=2, mismatch=-1, gap=-1):
    """完全なローカルアライメントアルゴリズム"""
    m, n = len(v), len(w)

    # スコアマトリックスの初期化
    S = [[0] * (n+1) for _ in range(m+1)]

    # 動的計画法
    max_score = 0
    max_pos = (0, 0)

    for i in range(1, m+1):
        for j in range(1, n+1):
            diagonal = S[i-1][j-1] + (match if v[i-1] == w[j-1] else mismatch)
            vertical = S[i-1][j] + gap
            horizontal = S[i][j-1] + gap

            S[i][j] = max(0, diagonal, vertical, horizontal)

            if S[i][j] > max_score:
                max_score = S[i][j]
                max_pos = (i, j)

    # バックトラッキング
    alignment = backtrack_local(S, v, w, max_pos[0], max_pos[1])

    return alignment, max_score
```

## 🚀 次回予告

次回は「アフィンギャップペナルティ」について学びます。なぜ連続したギャップは単一のギャップより起こりやすいのか？より現実的なギャップモデルを探求します！

---

_配列比較の深淵へ、さらに潜っていきましょう！_
