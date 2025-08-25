---
sidebar_position: 8
title: 空間効率の良い配列アライメント：Hirschbergアルゴリズム
---

# 空間効率の良い配列アライメント：Hirschbergアルゴリズム

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：数万塩基の長い配列でも、メモリ不足にならずにアライメントを計算できる魔法のような分割統治法を習得します。

でも、ちょっと待ってください。そもそも..。

## 🤔 ステップ0：なぜメモリが問題になるの？

### 現実のボトルネック

```
10,000塩基の配列比較：
必要メモリ = 10,000 × 10,000 × 4バイト
         = 400MB

100,000塩基の配列比較：
必要メモリ = 100,000 × 100,000 × 4バイト
         = 40GB！

→ 普通のPCでは無理！
```

### CPUとメモリの違い

```python
# CPUは速い
def cpu_intensive():
    """1秒間に数十億回の計算が可能"""
    for i in range(1_000_000_000):
        result = i * 2  # 超高速

# メモリは限界がある
def memory_intensive():
    """数GBのメモリはすぐに枯渇"""
    huge_matrix = [[0] * 100000 for _ in range(100000)]
    # MemoryError!
```

### 重要な観察

```
実行時間：待てばいい（数秒〜数分）
メモリ不足：どうしようもない！

→ メモリこそが真のボトルネック
```

## 📐 ステップ1：中間ノードという発想

### 1-1. 中央の列の定義

```
マンハッタングリッド：
○───○───○───○───○
│ ╲ │ ╲ │ ╲ │ ╲ │
○───○───○───○───○
│ ╲ │ ╲ │ ╲ │ ╲ │
○───○───○───○───○
        ↑
    中央の列
```

### 1-2. 中間ノードとは

```python
# 中間ノード = 最適経路が中央の列を通る点

def find_middle_node(grid):
    """最適経路が必ず通る中間ノードを見つける"""
    middle_column = len(grid[0]) // 2

    # この列のどこかを最適経路が通る
    # でも、どのノード？
```

### 1-3. 分割統治の考え方

```
アイデア：
1. 中間ノードを見つける
2. 問題を2つに分割：
   - ソース → 中間ノード
   - 中間ノード → シンク
3. 再帰的に解く

天才的！でも、どうやって中間ノードを見つける？
```

## 💡 ステップ2：線形空間でスコアを計算

### 2-1. 従来の方法の問題

```python
# 従来：全ノードのスコアを保存
def naive_alignment(v, w):
    m, n = len(v), len(w)
    # O(mn)のメモリが必要！
    scores = [[0] * (n+1) for _ in range(m+1)]

    for i in range(1, m+1):
        for j in range(1, n+1):
            scores[i][j] = max(...)

    return scores[m][n]
```

### 2-2. 画期的な観察

```
重要な発見：
列jのスコアを計算するには、
列j-1のスコアだけあればいい！

過去の列は忘れていい！
```

### 2-3. 線形空間の実装

```python
def linear_space_score(v, w):
    """O(min(m,n))のメモリでスコアを計算"""
    m, n = len(v), len(w)

    # 2列分のメモリだけ！
    previous_column = [0] * (m+1)
    current_column = [0] * (m+1)

    # 初期化
    for i in range(m+1):
        previous_column[i] = -i * gap_penalty

    # 列ごとに処理
    for j in range(1, n+1):
        current_column[0] = -j * gap_penalty

        for i in range(1, m+1):
            match = previous_column[i-1] + score(v[i-1], w[j-1])
            delete = previous_column[i] + gap_penalty
            insert = current_column[i-1] + gap_penalty

            current_column[i] = max(match, delete, insert)

        # 列を入れ替え（メモリ再利用）
        previous_column, current_column = current_column, previous_column

    return previous_column[m]  # スコアだけ
```

## 🔍 ステップ3：中間ノードの発見

### 3-1. i-パスの定義

```
i-path：中央の列のi番目のノードを通る最長経路

例：中央の列の各ノード
ノード0: i-pathの長さ = 2
ノード1: i-pathの長さ = 3
ノード2: i-pathの長さ = 3
ノード3: i-pathの長さ = 4 ← 最大！（中間ノード）
ノード4: i-pathの長さ = 3
ノード5: i-pathの長さ = 1
```

### 3-2. 長さの計算方法

```python
def find_middle_node(v, w):
    """中間ノードを見つける"""
    m, n = len(v), len(w)
    middle_col = n // 2

    # fromSource[i] = ソースから(i, middle_col)までの最長経路
    fromSource = compute_forward(v[:], w[:middle_col])

    # toSink[i] = (i, middle_col)からシンクまでの最長経路
    toSink = compute_backward(v[:], w[middle_col:])

    # i-pathの長さ = fromSource[i] + toSink[i]
    max_length = float('-inf')
    middle_row = 0

    for i in range(m+1):
        length = fromSource[i] + toSink[i]
        if length > max_length:
            max_length = length
            middle_row = i

    return middle_row, middle_col
```

### 3-3. 逆方向の計算

```python
def compute_backward(v, w):
    """シンクから逆方向に計算"""
    m, n = len(v), len(w)

    # 逆向きに動的計画法
    previous_column = [0] * (m+1)
    current_column = [0] * (m+1)

    # 右下から開始
    for j in range(n-1, -1, -1):
        for i in range(m-1, -1, -1):
            # 逆方向のエッジを辿る
            match = previous_column[i+1] + score(v[i], w[j])
            delete = previous_column[i] + gap_penalty
            insert = current_column[i+1] + gap_penalty

            current_column[i] = max(match, delete, insert)

        previous_column, current_column = current_column, previous_column

    return previous_column
```

## 🎯 ステップ4：分割統治法

### 4-1. 再帰的分割

```
初回：面積 = mn
  ↓ 中間ノードを見つける
2分割：各面積 = mn/2
  ↓ それぞれの中間ノードを見つける
4分割：各面積 = mn/4
  ↓ さらに分割
8分割：各面積 = mn/8
  ...
```

### 4-2. 実行時間の分析

```python
# 各レベルでの計算量
def time_complexity_analysis():
    """
    レベル0: mn     （全体を1回走査）
    レベル1: mn/2×2 = mn （半分を2回走査）
    レベル2: mn/4×4 = mn （1/4を4回走査）
    レベル3: mn/8×8 = mn （1/8を8回走査）
    ...

    合計: mn × log(mn) ≈ 2mn
    """
    # つまり、ほぼ線形時間！
```

### 4-3. なぜこれが効率的？

```
通常のアルゴリズム：
時間: O(mn)
空間: O(mn) ← 問題！

Hirschbergアルゴリズム：
時間: O(mn) × 2 ← わずかに遅い
空間: O(m+n) ← 劇的に改善！
```

## 💻 ステップ5：完全な実装

### 5-1. メインアルゴリズム

```python
class HirschbergAligner:
    def align(self, v, w):
        """線形空間での配列アライメント"""
        if len(v) == 0:
            return [('-', c) for c in w]
        if len(w) == 0:
            return [(c, '-') for c in v]
        if len(w) == 1:
            return self.align_with_single_char(v, w[0])

        # 中間ノードを見つける
        mid_row, mid_col = self.find_middle_node(v, w)

        # 再帰的に前半と後半を解く
        alignment1 = self.align(v[:mid_row], w[:mid_col])
        alignment2 = self.align(v[mid_row:], w[mid_col:])

        return alignment1 + alignment2
```

### 5-2. 中間ノード探索

```python
    def find_middle_node(self, v, w):
        """最適経路が通る中間ノードを見つける"""
        m, n = len(v), len(w)
        mid_col = n // 2

        # 前半のスコア（ソースから中央列まで）
        forward_scores = self.forward_scores(v, w[:mid_col])

        # 後半のスコア（中央列からシンクまで）
        backward_scores = self.backward_scores(v, w[mid_col:])

        # 最適な行を見つける
        max_score = float('-inf')
        best_row = 0

        for i in range(m + 1):
            score = forward_scores[i] + backward_scores[m - i]
            if score > max_score:
                max_score = score
                best_row = i

        return best_row, mid_col
```

### 5-3. メモリ効率の実証

```python
def memory_comparison():
    """メモリ使用量の比較"""

    # 配列長
    lengths = [100, 1000, 10000, 100000]

    for n in lengths:
        # 通常のアルゴリズム
        naive_memory = n * n * 4  # バイト

        # Hirschbergアルゴリズム
        hirschberg_memory = 2 * n * 4  # バイト

        ratio = naive_memory / hirschberg_memory

        print(f"配列長 {n}:")
        print(f"  通常: {naive_memory / 1e6:.1f} MB")
        print(f"  Hirschberg: {hirschberg_memory / 1e6:.4f} MB")
        print(f"  削減率: {ratio:.0f}倍")

# 出力：
# 配列長 100:
#   通常: 0.0 MB
#   Hirschberg: 0.0008 MB
#   削減率: 50倍
#
# 配列長 10000:
#   通常: 400.0 MB
#   Hirschberg: 0.08 MB
#   削減率: 5000倍！
```

## 🧬 ステップ6：実用的応用

### 6-1. ゲノム比較

```python
def compare_genomes(genome1, genome2):
    """巨大なゲノムを比較"""
    # 従来：メモリ不足でクラッシュ
    # Hirschberg：問題なく実行可能

    aligner = HirschbergAligner()
    alignment = aligner.align(genome1, genome2)

    return calculate_similarity(alignment)
```

### 6-2. リアルタイムアライメント

```
ストリーミングデータの処理：
- シーケンサーからのリアルタイムデータ
- メモリに全体を保持できない
- Hirschbergなら処理可能！
```

### 6-3. 組み込みシステム

```python
# メモリ制限のある環境
class EmbeddedAligner:
    """IoTデバイスやモバイルでも動作"""

    MAX_MEMORY = 1 * 1024 * 1024  # 1MB

    def can_align(self, seq1, seq2):
        required_memory = 2 * max(len(seq1), len(seq2)) * 4
        return required_memory <= self.MAX_MEMORY
```

## 🎨 ステップ7：視覚的理解

### 7-1. 分割の様子

```
ステップ1：全体を見る
■■■■■■■■
■■■■■■■■
■■■■■■■■
■■■■■■■■

ステップ2：中間ノード発見、分割
■■■■□□□□
■■■■□□□□
□□□□■■■■
□□□□■■■■

ステップ3：さらに分割
■■□□□□□□
□□■■□□□□
□□□□■■□□
□□□□□□■■

最終：パスが完成！
```

### 7-2. メモリ使用の推移

```python
def visualize_memory_usage():
    """メモリ使用量の可視化"""

    # 通常のアルゴリズム
    # ■■■■■■■■■■■■■■■■ (100%)

    # Hirschbergアルゴリズム
    # ■□□□□□□□□□□□□□□□ (6.25%)

    print("劇的な削減！")
```

## 💡 ステップ8：まとめ

### レベル1：基礎理解

```
学んだこと：
1. メモリがボトルネック
2. 中間ノードで分割統治
3. 線形空間でアライメント可能
```

### レベル2：応用理解

```
できるようになったこと：
1. 巨大配列の比較
2. メモリ制限環境での動作
3. 実用的な配列アライメント
```

### レベル3：実装理解

```python
# 完全なHirschbergアルゴリズム
def hirschberg_alignment(v, w):
    """
    時間計算量: O(mn)
    空間計算量: O(min(m,n))

    魔法のような効率性！
    """
    # 短い方を行に配置（さらなる最適化）
    if len(v) > len(w):
        v, w = w, v
        swap = True
    else:
        swap = False

    # Hirschbergアルゴリズムの実行
    alignment = hirschberg_recursive(v, w)

    # 必要なら結果を入れ替え
    if swap:
        alignment = [(b, a) for a, b in alignment]

    return alignment

def hirschberg_recursive(v, w):
    """再帰的な分割統治"""
    m, n = len(v), len(w)

    # ベースケース
    if m == 0:
        return [('-', w[j]) for j in range(n)]
    if n == 0:
        return [(v[i], '-') for i in range(m)]
    if m == 1 or n == 1:
        return simple_alignment(v, w)

    # 分割統治
    mid_col = n // 2

    # 前方スコアと後方スコアを計算
    score_left = nw_score(v, w[:mid_col], gap_penalty)
    score_right = nw_score(v[::-1], w[mid_col:][::-1], gap_penalty)[::-1]

    # 最適な分割点を見つける
    max_score = float('-inf')
    mid_row = 0
    for i in range(m + 1):
        score = score_left[i] + score_right[i]
        if score > max_score:
            max_score = score
            mid_row = i

    # 再帰的にアライメント
    align_left = hirschberg_recursive(v[:mid_row], w[:mid_col])
    align_right = hirschberg_recursive(v[mid_row:], w[mid_col:])

    return align_left + align_right
```

## 🚀 次回予告

次回は「多重配列アライメント」について学びます。2つではなく、数十〜数百の配列を同時に比較する方法とは？　計算複雑性の爆発とその対処法を探ります！

---

_メモリの壁を越えて、真に実用的なアライメントへ！_
