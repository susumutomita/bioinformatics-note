---
sidebar_position: 7
title: アフィンギャップペナルティ：より現実的な配列アライメント
---

# アフィンギャップペナルティ：より現実的な配列アライメント

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：なぜ連続したギャップは単一のギャップより起こりやすいのかを理解し、生物学的に現実的なギャップペナルティモデルを実装できるようになります。

でも、ちょっと待ってください。そもそも..。

## 🤔 ステップ0：なぜ固定ペナルティでは不十分なの？

### 現実の生物学的イベント

```
単純なモデル：
各インデル = -2ペナルティ
5個の連続インデル = -10ペナルティ

でも現実は...
```

### 実際の進化イベント

```python
# ナイーブなペナルティ
def naive_gap_penalty(gap_length):
    return gap_length * fixed_penalty  # 例: 5 * (-2) = -10

# 問題：5個の独立した変異イベント？
# 現実：おそらく1回の大きな挿入/削除イベント！
```

### 生物学的根拠

```
連続したギャップが起こる理由：

1. DNAポリメラーゼのスリッページ
   → 一度に複数塩基の挿入/削除

2. トランスポゾンの挿入
   → 数百塩基が一度に挿入

3. 組換えエラー
   → 大きな領域の欠失

結論：連続ギャップ = 単一イベント
```

## 📐 ステップ1：アフィンギャップペナルティの導入

### 1-1. 基本的な考え方

```
新しいペナルティモデル：
- ギャップ開始ペナルティ：σ（大きい）
- ギャップ拡張ペナルティ：ε（小さい）

通常：σ > ε

理由：
最初の変異 = 難しい（大きなペナルティ）
継続 = 比較的簡単（小さなペナルティ）
```

### 1-2. 数式での表現

```python
def affine_gap_penalty(gap_length):
    """アフィンギャップペナルティの計算"""
    if gap_length == 0:
        return 0
    else:
        # 開始ペナルティ + 拡張ペナルティ×(長さ-1)
        return -σ - ε * (gap_length - 1)

# 例：σ=10, ε=1
# 長さ1のギャップ: -10
# 長さ2のギャップ: -11
# 長さ5のギャップ: -14
# （線形増加、急激ではない）
```

### 1-3. 固定ペナルティとの比較

```
ギャップ長  固定(-2×長さ)  アフィン(-10-1×(長さ-1))
    1          -2              -10
    2          -4              -11
    3          -6              -12
    5          -10             -14
    10         -20             -19

→ 長いギャップがより許容される！
```

## 🏗️ ステップ2：グラフへの実装（単純だが非効率）

### 2-1. エッジの追加

```
元のグラフ：
○───○───○
│ ╲ │ ╲ │
○───○───○
│ ╲ │ ╲ │
○───○───○

新しいエッジを追加：
○═══○═══○  （長さ2のギャップ）
║ ╲ ║ ╲ ║
○═══○═══○  （長さ3のギャップ）
║ ╲ ║ ╲ ║
○═══○═══○  （すべての長さ）
```

### 2-2. エッジ数の爆発

```python
# 追加されるエッジ数
def count_new_edges(n, m):
    """n×mグリッドでの新しいエッジ数"""
    total = 0

    # 水平方向の長いエッジ
    for gap_length in range(2, m+1):
        total += n * (m - gap_length + 1)

    # 垂直方向の長いエッジ
    for gap_length in range(2, n+1):
        total += m * (n - gap_length + 1)

    return total
    # 結果：O(n³)のエッジ！
```

### 2-3. 計算量の問題

```
時間計算量：O(n³)
空間計算量：O(n³)

→ 実用的でない！

10,000塩基の配列：
1兆回の計算が必要...
```

## 🎨 ステップ3：3層マンハッタングリッドの魔法

### 3-1. レベルの分離

```
革新的アイデア：
グラフを3つのレベルに分離！

上層：削除のみ（水平移動）
    ○───○───○───○

中層：マッチ/ミスマッチ（対角移動）
    ○ ╲ ○ ╲ ○ ╲ ○
      ╲   ╲   ╲

下層：挿入のみ（垂直移動）
    ○
    │
    ○
    │
    ○
```

### 3-2. レベル間の移動

```python
# レベル間の移動ルール
class ThreeLevelGraph:
    def transition_cost(from_level, to_level):
        if from_level == "middle" and to_level == "lower":
            return -σ  # ギャップ開始（挿入）
        elif from_level == "lower" and to_level == "lower":
            return -ε  # ギャップ継続
        elif from_level == "lower" and to_level == "middle":
            return 0   # ギャップ終了
        # 同様に上層（削除）も定義
```

### 3-3. なぜこれが効率的？

```
各ノードの接続数：
- 元のアプローチ：O(n)個の隣接ノード
- 3層アプローチ：最大3個の隣接ノード！

エッジ総数：
- 元：O(n³)
- 新：O(n²)

劇的な改善！
```

## 💻 ステップ4：動的計画法の実装

### 4-1. 3つの再帰式

```python
def affine_alignment(v, w, match_score, mismatch_score, σ, ε):
    """アフィンギャップペナルティを使用したアライメント"""
    m, n = len(v), len(w)

    # 3つのレベルのスコア行列
    lower = [[float('-inf')] * (n+1) for _ in range(m+1)]   # 挿入
    middle = [[float('-inf')] * (n+1) for _ in range(m+1)]  # マッチ
    upper = [[float('-inf')] * (n+1) for _ in range(m+1)]   # 削除

    # 初期化
    middle[0][0] = 0
```

### 4-2. 更新規則

```python
    for i in range(1, m+1):
        for j in range(1, n+1):
            # 下層（挿入）の更新
            lower[i][j] = max(
                lower[i-1][j] - ε,      # ギャップ継続
                middle[i-1][j] - σ      # ギャップ開始
            )

            # 上層（削除）の更新
            upper[i][j] = max(
                upper[i][j-1] - ε,      # ギャップ継続
                middle[i][j-1] - σ      # ギャップ開始
            )

            # 中層（マッチ/ミスマッチ）の更新
            score = match_score if v[i-1] == w[j-1] else mismatch_score
            middle[i][j] = max(
                lower[i][j],            # 挿入から戻る
                middle[i-1][j-1] + score,  # マッチ/ミスマッチ
                upper[i][j]             # 削除から戻る
            )
```

### 4-3. バックトラッキング

```python
def backtrack_affine(lower, middle, upper, v, w):
    """3層グラフでのバックトラッキング"""
    i, j = len(v), len(w)
    alignment = []
    current_level = "middle"  # 終点は中層

    while i > 0 or j > 0:
        if current_level == "middle":
            if i > 0 and j > 0 and middle[i][j] == middle[i-1][j-1] + score(v[i-1], w[j-1]):
                alignment.append((v[i-1], w[j-1]))
                i -= 1
                j -= 1
            elif middle[i][j] == lower[i][j]:
                current_level = "lower"
            else:
                current_level = "upper"

        elif current_level == "lower":
            alignment.append((v[i-1], '-'))
            i -= 1
            if lower[i][j] == middle[i][j] - σ:
                current_level = "middle"

        else:  # upper
            alignment.append(('-', w[j-1]))
            j -= 1
            if upper[i][j] == middle[i][j] - σ:
                current_level = "middle"

    return reversed(alignment)
```

## 🧬 ステップ5：生物学的応用

### 5-1. タンパク質配列での利用

```python
# 実際のパラメータ例（BLOSUM62）
def protein_alignment_params():
    return {
        'gap_open': -11,      # σ
        'gap_extend': -1,     # ε
        'matrix': 'BLOSUM62'
    }

# DNAの場合
def dna_alignment_params():
    return {
        'gap_open': -5,
        'gap_extend': -2,
        'match': +2,
        'mismatch': -3
    }
```

### 5-2. イントロン・エクソン境界の検出

```
エクソン配列とゲノム配列のアライメント：

ゲノム：  ATCG--------------------GCTA
         エクソン1   イントロン   エクソン2

mRNA：    ATCG                    GCTA
         エクソン1              エクソン2

アフィンギャップ → 長いイントロンを1つのギャップとして扱える
```

### 5-3. 構造的変異の検出

```python
def detect_structural_variants(reference, sample):
    """構造的変異（大きな挿入/削除）を検出"""
    alignment = affine_alignment(
        reference,
        sample,
        gap_open=-50,    # 大きなペナルティ
        gap_extend=-0.5  # 小さな拡張ペナルティ
    )

    # 長いギャップを探す
    gaps = find_long_gaps(alignment)
    return classify_variants(gaps)
```

## 🎯 ステップ6：パフォーマンス分析

### 6-1. 計算量の比較

```
アプローチ          時間計算量  空間計算量
──────────────────────────────────
固定ペナルティ      O(mn)      O(mn)
ナイーブアフィン    O(mn²)     O(mn²)
3層グラフ          O(mn)      O(mn)

→ 3層グラフが最適！
```

### 6-2. 実装の最適化

```python
# メモリ最適化版（Hirschbergアルゴリズム）
def memory_efficient_affine(v, w):
    """空間計算量O(min(m,n))での実装"""
    # 短い方の配列を列に配置
    if len(v) > len(w):
        v, w = w, v

    # 2行分のメモリのみ使用
    current_row = [0] * (len(w) + 1)
    previous_row = [0] * (len(w) + 1)

    # 詳細は省略...
```

### 6-3. 並列化の可能性

```
並列化戦略：
1. 対角線に沿った並列計算
2. ブロック分割による並列化
3. GPUを使用した大規模並列化

→ 数万塩基の配列も実用的に！
```

## 💡 ステップ7：まとめ

### レベル1：基礎理解

```
学んだこと：
1. 連続ギャップ = 単一の進化イベント
2. アフィンペナルティ = より現実的
3. 3層グラフ = 効率的な実装
```

### レベル2：応用理解

```
できるようになったこと：
1. 生物学的に妥当なギャップペナルティ設定
2. 長いインデルの適切な扱い
3. 構造的変異の検出
```

### レベル3：実装理解

```python
# 完全な実装
class AffineAligner:
    def __init__(self, match=2, mismatch=-3, gap_open=-5, gap_extend=-2):
        self.match = match
        self.mismatch = mismatch
        self.gap_open = gap_open
        self.gap_extend = gap_extend

    def align(self, seq1, seq2):
        """アフィンギャップペナルティを使用した配列アライメント"""
        m, n = len(seq1), len(seq2)

        # 3層の動的計画法テーブル
        M = self._init_matrix(m, n)  # マッチ/ミスマッチ
        I = self._init_matrix(m, n)  # 挿入
        D = self._init_matrix(m, n)  # 削除

        # 境界条件の設定
        self._set_boundaries(M, I, D, m, n)

        # 動的計画法の実行
        self._fill_matrices(M, I, D, seq1, seq2)

        # バックトラッキング
        alignment = self._backtrack(M, I, D, seq1, seq2)

        return alignment

    def _fill_matrices(self, M, I, D, seq1, seq2):
        """3つの行列を埋める"""
        for i in range(1, len(seq1) + 1):
            for j in range(1, len(seq2) + 1):
                # 挿入行列
                I[i][j] = max(
                    M[i-1][j] + self.gap_open,
                    I[i-1][j] + self.gap_extend
                )

                # 削除行列
                D[i][j] = max(
                    M[i][j-1] + self.gap_open,
                    D[i][j-1] + self.gap_extend
                )

                # マッチ/ミスマッチ行列
                match_score = self.match if seq1[i-1] == seq2[j-1] else self.mismatch
                M[i][j] = max(
                    M[i-1][j-1] + match_score,
                    I[i][j],
                    D[i][j]
                )
```

## 🚀 次回予告

次回は「複数配列アライメント」について学びます。2つではなく、何十もの配列を同時に比較するには？　進化系統樹の構築への第一歩を踏み出します！

---

_より現実的な配列比較へ、一歩前進しました！_
