---
sidebar_position: 9
title: 複数配列アライメント：同時に多数の配列を比較する
---

# 複数配列アライメント：同時に多数の配列を比較する

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：2つではなく、数十〜数百の配列を同時に比較し、進化的に保存された領域を見つける方法を習得します。でも、計算量の爆発という壁にぶつかり、実用的な解決策を探ります。

でも、ちょっと待ってください。そもそも..。

## 🤔 ステップ0：なぜペアワイズでは不十分なの？

### 隠れた保存領域の問題

```
2つだけ比較：
配列A: ATCGATCG
配列B: ATCGATAG
類似度：87.5%（まあまあ）

でも、10個同時に比較すると...
配列A: ATCGATCG
配列B: ATCGATAG
配列C: ATCGATCG
配列D: ATCGATCG
...
位置5のG：10個中9個で保存！
→ 統計的に極めて有意！
```

### 進化的シグナルの増幅

```python
# ペアワイズの限界
def pairwise_significance(seq1, seq2):
    """2配列だけでは偶然の一致と区別しにくい"""
    similarity = calculate_similarity(seq1, seq2)
    # 偶然でも70%くらいは一致することがある
    return similarity > 0.7  # 弱い証拠

# 複数配列の威力
def multiple_significance(sequences):
    """多数で保存されていれば偶然ではない！"""
    conserved_positions = find_conserved_columns(sequences)
    # 10配列で90%保存なら偶然の確率は0.9^10 = 0.00000001%
    return len(conserved_positions)  # 強力な証拠！
```

### 実例：アデニル化ドメイン

```
3つのA-domain配列：
ペアワイズ比較では見えない
↓
3つ同時に比較
↓
共通のモチーフ発見！
→ 同じ機能を持つ証拠
```

## 📊 ステップ1：3次元への拡張

### 1-1. 2次元から3次元へ

```
2配列（2D）：
○───○───○
│ ╲ │ ╲ │
○───○───○
│ ╲ │ ╲ │
○───○───○

3配列（3D）：
    ○───○───○
   /│╲ /│╲ /│
  ○───○───○ │
 /│╲ /│╲ /│ │
○───○───○ │ │
│ │ │ │ │ │ │
│ ○───○───○ │
│/  │/  │/  │/
○───○───○───○
```

### 1-2. 座標での表現

```python
# 3配列のアライメント例
seq1 = "ATGC"
seq2 = "AATC"
seq3 = "ATGC"

# アライメント結果
# A-TGC
# AATC
# A-TGC

# 3次元座標として表現
path = [
    (0,0,0),  # 開始
    (1,1,1),  # A,A,A（3つとも進む）
    (1,2,1),  # -,A,-（seq2だけ進む）
    (2,3,2),  # T,T,T（3つとも進む）
    (3,3,3),  # G,-,G（seq2はギャップ）
    (4,4,4)   # C,C,C（3つとも進む）
]
```

### 1-3. エッジの増加

```
2次元での選択肢：3方向
- 水平（削除）
- 垂直（挿入）
- 対角（マッチ/ミスマッチ）

3次元での選択肢：7方向！
- (1,0,0), (0,1,0), (0,0,1)  # 1つだけ進む
- (1,1,0), (1,0,1), (0,1,1)  # 2つ進む
- (1,1,1)                     # 3つとも進む
```

## 😱 ステップ2：計算量の爆発

### 2-1. 恐ろしい現実

```python
def complexity_analysis(k, n):
    """k個の長さnの配列をアライメント"""

    # グリッドのサイズ
    grid_size = n ** k

    # 各ノードの隣接数
    neighbors = 2 ** k - 1

    # 総計算量
    total = grid_size * neighbors

    return total

# 例
print(complexity_analysis(2, 100))  # 10,000 × 3 = 30,000（実用的）
print(complexity_analysis(3, 100))  # 1,000,000 × 7 = 7,000,000（まだOK）
print(complexity_analysis(10, 100)) # 10^20 × 1023 = 10^23（不可能！）
```

### 2-2. 宇宙的な時間

```
18個の長さ18の配列：
計算時間 = 18^18 × (2^18 - 1) ステップ
        ≈ 10^30 ステップ

最速のコンピュータ（10^15 ステップ/秒）でも：
10^30 ÷ 10^15 = 10^15秒
              = 317億年
              > 宇宙の年齢（138億年）

絶望的...
```

### 2-3. なぜこんなに増えるの？

```
次元の呪い：
k次元 = 選択肢が2^k倍
      = 空間がn^k倍

例：10配列
各ステップで1024通りの選択
→ 完全探索は現実的に不可能
```

## 💡 ステップ3：プロファイルという発想

### 3-1. プロファイルとは

```
複数配列の統計的表現：

配列1: ATCG
配列2: ACCG
配列3: ATAG
配列4: ATCG
配列5: -TCG

プロファイル（各位置での頻度）：
位置:   1    2    3    4
A:     4/5  0/5  1/5  0/5
T:     0/5  4/5  0/5  0/5
C:     0/5  1/5  2/5  0/5
G:     0/5  0/5  0/5  5/5
-:     1/5  0/5  2/5  0/5
```

### 3-2. プロファイルの利点

```python
class Profile:
    """複数配列を1つのオブジェクトとして扱う"""

    def __init__(self, sequences):
        self.frequencies = self.calculate_frequencies(sequences)

    def score_with_sequence(self, seq, position):
        """配列との一致スコアを計算"""
        score = 0
        for i, char in enumerate(seq):
            score += self.frequencies[position + i][char]
        return score

    def merge_with_profile(self, other_profile):
        """2つのプロファイルを結合"""
        # 重み付き平均で新しいプロファイルを作成
        return merged_profile
```

### 3-3. プロファイル同士のアライメント

```
プロファイル1:     プロファイル2:
A: 0.8            A: 0.6
T: 0.2            T: 0.3
C: 0.0            C: 0.1
G: 0.0            G: 0.0

スコア = 0.8×0.6 + 0.2×0.3 = 0.54
（確率的な一致度）
```

## 🎯 ステップ4：貪欲アルゴリズム

### 4-1. 基本戦略

```
1. すべてのペアワイズアライメントを計算
2. 最も類似した2つを結合
3. 結合したものをプロファイルとして扱う
4. 1つになるまで繰り返す

天才的な単純化！
```

### 4-2. 具体例での実行

```python
def greedy_multiple_alignment(sequences):
    """貪欲法による複数配列アライメント"""

    # ステップ1：全ペアワイズスコア計算
    scores = {}
    for i in range(len(sequences)):
        for j in range(i+1, len(sequences)):
            scores[(i,j)] = pairwise_score(sequences[i], sequences[j])

    # 例：4配列の場合
    # GATTCA, GTCTGA, GATATT, GTCAGC
    #
    # ペアワイズスコア：
    # (0,1): -1
    # (0,2): 1
    # (0,3): 0
    # (1,2): -2
    # (1,3): 2  ← 最高スコア！
    # (2,3): -1

    # ステップ2：最も近い2つを結合
    best_pair = (1, 3)  # GTCTGA と GTCAGC
    profile_1_3 = create_profile([sequences[1], sequences[3]])

    # 新しい配列セット：
    # [GATTCA, GATATT, Profile(GTCTGA,GTCAGC)]

    # ステップ3：繰り返し
    # ... 最終的に1つのプロファイルに
```

### 4-3. 実行例の可視化

```
初期状態：
seq1: GATTCA
seq2: GTCTGA
seq3: GATATT
seq4: GTCAGC

ステップ1：seq2とseq4を結合
seq1: GATTCA
seq3: GATATT
prof2_4: GTC-TGA
         GTCAGC-

ステップ2：seq1とseq3を結合
prof1_3: GATTCA
         GATATT
prof2_4: (前のまま)

ステップ3：2つのプロファイルを結合
最終アライメント：
GA-TTCA
GA-TATT
GTC-TGA
GTCAGC-
```

## 🚀 ステップ5：改良と最適化

### 5-1. プログレッシブアライメント

```python
def progressive_alignment(sequences):
    """系統樹ガイドによる改良版"""

    # 1. 系統樹を構築
    tree = build_guide_tree(sequences)

    # 2. 葉から根へ向かってアライメント
    def align_node(node):
        if node.is_leaf():
            return node.sequence
        else:
            left_align = align_node(node.left)
            right_align = align_node(node.right)
            return profile_align(left_align, right_align)

    return align_node(tree.root)
```

### 5-2. 反復改良

```
初期アライメント
↓
配列を1つ除外
↓
残りを再アライメント
↓
除外した配列を再挿入
↓
スコア改善があれば採用
↓
すべての配列で繰り返し
```

### 5-3. 実用ツール

```python
# 実際に使われているツール
tools = {
    'Clustal': 'プログレッシブ法の定番',
    'MUSCLE': '高速・高精度',
    'MAFFT': '大規模配列に強い',
    'T-Coffee': '複数の情報源を統合'
}

# 使用例（MUSCLE）
def run_muscle(sequences):
    """MUSCLEアルゴリズムの簡略版"""
    # 1. 高速な距離計算
    distances = fast_distance_matrix(sequences)

    # 2. UPGMA法で系統樹構築
    tree = upgma(distances)

    # 3. プログレッシブアライメント
    alignment = progressive_align(tree, sequences)

    # 4. 反復改良
    for iteration in range(max_iterations):
        alignment = refine(alignment)
        if not improved:
            break

    return alignment
```

## 💡 ステップ6：まとめ

### レベル1：基礎理解

```
学んだこと：
1. 複数配列の重要性（統計的有意性）
2. 次元の呪い（指数関数的増加）
3. ヒューリスティックの必要性
```

### レベル2：応用理解

```
できるようになったこと：
1. プロファイルベースのアライメント
2. 貪欲法による近似解
3. 実用的な多重配列アライメント
```

### レベル3：実装理解

```python
# 完全な貪欲アルゴリズム実装
class MultipleAligner:
    def __init__(self):
        self.sequences = []
        self.profiles = []

    def align(self, sequences):
        """貪欲法による多重配列アライメント"""
        n = len(sequences)

        # 初期化：各配列を単独のクラスタとする
        clusters = [[i] for i in range(n)]
        alignments = [[seq] for seq in sequences]

        while len(clusters) > 1:
            # 最も近いペアを見つける
            best_score = float('-inf')
            best_i, best_j = 0, 1

            for i in range(len(clusters)):
                for j in range(i+1, len(clusters)):
                    score = self.profile_score(
                        alignments[i],
                        alignments[j]
                    )
                    if score > best_score:
                        best_score = score
                        best_i, best_j = i, j

            # クラスタを結合
            merged = self.merge_alignments(
                alignments[best_i],
                alignments[best_j]
            )

            # リストを更新
            new_cluster = clusters[best_i] + clusters[best_j]
            clusters = [c for k, c in enumerate(clusters)
                       if k != best_i and k != best_j]
            clusters.append(new_cluster)

            alignments = [a for k, a in enumerate(alignments)
                         if k != best_i and k != best_j]
            alignments.append(merged)

        return alignments[0]

    def profile_score(self, align1, align2):
        """2つのアライメントのスコア"""
        profile1 = self.make_profile(align1)
        profile2 = self.make_profile(align2)

        # プロファイル同士のアライメントスコア
        return self.align_profiles(profile1, profile2)

    def make_profile(self, alignment):
        """アライメントからプロファイルを作成"""
        length = len(alignment[0])
        profile = []

        for pos in range(length):
            column = [seq[pos] for seq in alignment]
            frequencies = {}
            for char in 'ATCG-':
                frequencies[char] = column.count(char) / len(column)
            profile.append(frequencies)

        return profile
```

## 🚀 次回予告

次回は「ゲノム再配列」について学びます。進化の過程で起こる大規模な染色体の再編成をどうやって検出し、復元するのか？　ブレークポイントグラフの世界へ飛び込みます！

---

_2つから多数へ、配列比較の新たな次元へ！_
