---
sidebar_position: 4
---

# Week 3 クイズ：解答と解説

## 📝 概要

Week 3で学んだモチーフ発見に関する理解度を確認するクイズです。各問題の解答と詳しい解説を提供します。

## 問題1：アルゴリズムの種類

**質問：** 各ステップで最も魅力的な選択肢を選ぶのはどのタイプのアルゴリズムですか？

**選択肢：**

- 機械学習アルゴリズム
- ブルートフォースサーチ
- 動的計画法アルゴリズム
- 組み合わせアルゴリズム
- **貪欲なアルゴリズム** ✅
- ランダム化アルゴリズム

### 解説

正解：**貪欲なアルゴリズム（Greedy Algorithm）**

貪欲アルゴリズムは、各ステップで局所的に最適な選択を行うアルゴリズムです。グリーディモチーフ探索では、各ステップで最も確率の高いk-merを選択していきます。

- **特徴**：高速だが、必ずしも大域的最適解を保証しない
- **Week 3での例**：GreedyMotifSearchアルゴリズム

## 問題2：モチーフの性質

**質問：** 真か偽か：文字列の集合に関して最もスコアが低いモチーフは、文字列の1つの部分文字列として現れる必要はありません。

**解答：正解（True）** ✅

### 解説

モチーフのコンセンサス文字列は、各位置で最も頻出するヌクレオチドを選んで構成されるため、元の文字列のどれとも完全には一致しない可能性があります。

例：

```
モチーフ:
ATGC
ATCC
AGGC

コンセンサス: ATGC（最もスコアが低い）
```

この例では、コンセンサス「ATGC」は最初の文字列と同じですが、必ずしもそうなるとは限りません。

## 問題3：エントロピーの順序

**質問：** 次の確率分布をエントロピーの小さい方から大きい方へ並べなさい：

- A: (0.5, 0, 0, 0.5)
- B: (0.25, 0.25, 0.25, 0.25)
- C: (0, 0, 0, 1)
- D: (0.25, 0, 0.5, 0.25)

**正解：C, A, D, B** ✅

### 解説

エントロピーの計算式：

```
H = -Σ p(i) × log₂(p(i))
```

各分布のエントロピー計算：

```python
import math

def entropy(probs):
    """確率分布のエントロピーを計算"""
    H = 0
    for p in probs:
        if p > 0:
            H -= p * math.log2(p)
    return H

# A: (0.5, 0, 0, 0.5)
H_A = entropy([0.5, 0, 0, 0.5])  # = 1.0

# B: (0.25, 0.25, 0.25, 0.25)
H_B = entropy([0.25, 0.25, 0.25, 0.25])  # = 2.0

# C: (0, 0, 0, 1)
H_C = entropy([0, 0, 0, 1])  # = 0.0

# D: (0.25, 0, 0.5, 0.25)
H_D = entropy([0.25, 0, 0.5, 0.25])  # ≈ 1.5
```

結果：

- C: 0.0（最小 - 完全に決定的）
- A: 1.0
- D: 1.5
- B: 2.0（最大 - 最も不確実）

## 問題4：コンセンサス文字列

**質問：** 次のプロファイル行列から、コンセンサス文字列を求めてください：

```
位置:  1    2    3    4    5    6
A:   0.4  0.3  0.0  0.1  0.0  0.9
C:   0.2  0.3  0.0  0.4  0.0  0.1
G:   0.1  0.3  1.0  0.1  0.5  0.0
T:   0.3  0.1  0.0  0.4  0.5  0.0
```

**正解：ACGCGA, ACGTGA, AAGTGA, AGGTGA** ✅

### 解説

各位置で最大の確率を持つヌクレオチドを選択：

1. 位置1: A (0.4) が最大
2. 位置2: A, C, G (各0.3) が同率最大
3. 位置3: G (1.0) が最大
4. 位置4: C, T (各0.4) が同率最大
5. 位置5: G, T (各0.5) が同率最大
6. 位置6: A (0.9) が最大

同率の場合、すべての組み合わせが有効なコンセンサス文字列：

- A(A/C/G)G(C/T)(G/T)A

可能な組み合わせ：

- AAGCGA
- AAGCTA
- AAGTGA ✅
- AAGTTA
- ACGCGA ✅
- ACGCTA
- ACGTGA ✅
- ACGTTA
- AGGCGA
- AGGCTA
- AGGTGA ✅
- AGGTTA

## 問題5：メディアン文字列

**質問：** 以下のモチーフマトリックスのメディアン文字列（7-mer）を選んでください：

```
ctcgatgagtaggaaagtagtttcactgggcgaaccaccccggcgctaatcctagtgccc
gcaatcctacccgaggccacatatcagtaggaactagaaccacggtggctagtttctagg
ggtgttgaaccacggggttagtttcatctattgtaggaatcggcttcaaatcctacacag
```

**候補：**

- GTAGGAA
- GTCAGCG
- TCTGAAG
- AACGCTG
- GATGAGT
- AATCCTA

### 解答 : GTAGGAA, AATCCTA

### 解説

メディアン文字列は、すべての配列への総距離を最小化する7-merです。各候補について、3つの配列それぞれとの最小ハミング距離を計算し、その合計が最小となるものを選びます。

```python
def find_median_string(sequences, candidates):
    """候補の中からメディアン文字列を見つける"""
    best_pattern = None
    best_distance = float('inf')

    for pattern in candidates:
        total_dist = 0
        for seq in sequences:
            min_dist = float('inf')
            # 各配列内で最小距離を見つける
            for i in range(len(seq) - len(pattern) + 1):
                dist = hamming_distance(pattern, seq[i:i+len(pattern)])
                min_dist = min(min_dist, dist)
            total_dist += min_dist

        if total_dist < best_distance:
            best_distance = total_dist
            best_pattern = pattern

    return best_pattern
```

**注意：** 実際の計算には各配列を詳細に分析する必要があります。

## 問題6：確率計算

**質問：** 次のプロファイル行列を使って、Pr(AAGTTC|Profile)を計算してください：

```
位置:  1    2    3    4    5    6
A:   0.4  0.3  0.0  0.1  0.0  0.9
C:   0.2  0.3  0.0  0.4  0.0  0.1
G:   0.1  0.3  1.0  0.1  0.5  0.0
T:   0.3  0.1  0.0  0.4  0.5  0.0
```

### 解説

文字列「AAGTTC」の確率計算：

```python
# AAGTTC の各位置での確率
# 位置1: A → 0.4
# 位置2: A → 0.3
# 位置3: G → 1.0
# 位置4: T → 0.4
# 位置5: T → 0.5
# 位置6: C → 0.1

Pr(AAGTTC|Profile) = 0.4 × 0.3 × 1.0 × 0.4 × 0.5 × 0.1
                   = 0.4 × 0.3 × 1.0 × 0.4 × 0.5 × 0.1
                   = 0.0024
```

正解：**0.0024**

## 📊 重要な概念の復習

### エントロピーと情報量

- **低エントロピー**：高い保存度、少ない不確実性
- **高エントロピー**：低い保存度、多くの不確実性

### モチーフ発見アルゴリズムの比較

| アルゴリズム     | 計算量     | 最適性 | 特徴         |
| ---------------- | ---------- | ------ | ------------ |
| ブルートフォース | 指数的     | 最適   | 遅い         |
| グリーディ       | 多項式時間 | 近似   | 高速         |
| ランダム化       | 確率的     | 近似   | バランス良好 |

## 🎯 学習のポイント

1. **貪欲アルゴリズム**は局所最適解を選ぶが、大域最適解を保証しない
2. **コンセンサス文字列**は元の配列に存在しない可能性がある
3. **エントロピー**は配列の保存度を測る重要な指標
4. **プロファイル行列**を使った確率計算は、モチーフ探索の基礎

## 📚 参考文献

- Coursera: Bioinformatics Specialization - Week 3
- Jones, N.C. and Pevzner, P.A. (2004) An Introduction to Bioinformatics Algorithms
