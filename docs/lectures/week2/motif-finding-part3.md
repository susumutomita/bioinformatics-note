---
sidebar_position: 3
---

# 移植パターンから規制モチーフへ（パート3）

## 📖 概要

この講義では、メディアン文字列問題の詳細な定義と解法、そしてプロファイル行列を使った確率的アプローチによるグリーディモチーフ探索アルゴリズムについて学びます。

## 🎯 学習目標

- パターンと文字列間の距離の定義
- メディアン文字列問題の理解と解法
- プロファイル行列の構築と活用
- 確率的アプローチの導入
- グリーディモチーフ探索アルゴリズム

## 📏 パターンと文字列間の距離

### k-merと長い文字列の距離

異なる長さの文字列間の距離を定義する必要があります。

```python
def distance_between_pattern_and_string(pattern, text):
    """
    パターン（k-mer）とテキスト間の最小ハミング距離

    Args:
        pattern: k-mer文字列
        text: 長いDNA文字列

    Returns:
        最小ハミング距離
    """
    k = len(pattern)
    min_distance = float('inf')

    # テキスト内のすべてのk-merと比較
    for i in range(len(text) - k + 1):
        kmer = text[i:i+k]
        distance = hamming_distance(pattern, kmer)
        min_distance = min(min_distance, distance)

    return min_distance
```

### 例：距離の計算過程

```
パターン: AAA
テキスト: TTACCTTAAC

位置0: TTA vs AAA → 距離 = 2
位置1: TAC vs AAA → 距離 = 2
位置2: ACC vs AAA → 距離 = 2
位置3: CCT vs AAA → 距離 = 3
位置4: CTT vs AAA → 距離 = 3
位置5: TTA vs AAA → 距離 = 2
位置6: TAA vs AAA → 距離 = 1  ← 最小
位置7: AAC vs AAA → 距離 = 1  ← 最小

結果: Distance(AAA, TTACCTTAAC) = 1
```

### k-merと文字列集合の距離

パターンと複数の文字列の集合との距離は、各文字列との距離の総和：

```python
def distance_between_pattern_and_strings(pattern, dna_list):
    """
    パターンと文字列集合間の総距離

    Args:
        pattern: k-mer文字列
        dna_list: DNA文字列のリスト

    Returns:
        総距離
    """
    total_distance = 0
    for dna in dna_list:
        total_distance += distance_between_pattern_and_string(pattern, dna)
    return total_distance

# 例
dna_list = [
    "TTACCTTAAC",
    "GATATCTGTC",
    "ACGGCGTTCG",
    "CCCTAAAGAG",
    "CGTCAGAGGT"
]
pattern = "AAA"
# 各文字列との距離: 1 + 1 + 2 + 0 + 1 = 5
```

## 🎯 メディアン文字列問題

### 定義

**メディアン文字列**：すべての可能なk-merの中で、文字列集合への総距離を最小化するパターン

### 問題の定式化

**入力：**

- 整数k
- DNA文字列の集合

**出力：**

- Distance(Pattern, Dna)を最小化するk-mer Pattern

### ブルートフォース解法

```python
def median_string(dna_list, k):
    """
    メディアン文字列を見つける

    Args:
        dna_list: DNA文字列のリスト
        k: パターンの長さ

    Returns:
        メディアン文字列
    """
    import itertools

    best_pattern = None
    best_distance = float('inf')

    # すべての可能な k-mer (4^k 通り) を生成
    for pattern in generate_all_kmers(k):
        distance = distance_between_pattern_and_strings(pattern, dna_list)
        if distance < best_distance:
            best_distance = distance
            best_pattern = pattern

    return best_pattern

def generate_all_kmers(k):
    """すべての可能なk-merを生成"""
    import itertools
    nucleotides = ['A', 'C', 'G', 'T']
    for kmer in itertools.product(nucleotides, repeat=k):
        yield ''.join(kmer)
```

### 計算量の改善

- **元のモチーフ発見問題**：O((n-k+1)^t × k × t)
- **メディアン文字列問題**：O(4^k × n × t × k)

:::info実用性の向上
k = 15の場合：

- 元の問題：約10^30通り（n=1000, t=10）
- メディアン文字列：4^15 ≈ 10^9通り（計算可能！）。
  :::

## 📊 プロファイル行列（Profile Matrix）

### カウント行列からプロファイル行列へ

```python
def create_profile_matrix(motifs):
    """
    モチーフ集合からプロファイル行列を作成

    Args:
        motifs: モチーフ文字列のリスト

    Returns:
        プロファイル行列（各位置の各ヌクレオチドの頻度）
    """
    t = len(motifs)
    k = len(motifs[0])
    profile = []

    for j in range(k):
        column = {'A': 0, 'C': 0, 'G': 0, 'T': 0}
        for motif in motifs:
            column[motif[j]] += 1

        # カウントを頻度に変換
        for nucleotide in column:
            column[nucleotide] = column[nucleotide] / t

        profile.append(column)

    return profile
```

### プロファイル行列の例

```
モチーフ:
TCGGGGGTTTTT
CCGGTGACTTAC
ACGGGGATTTTC

プロファイル行列:
位置:  1    2    3    4    5    6    7    8    9   10   11   12
A:   0.33 0.00 0.00 0.00 0.00 0.00 0.33 0.00 0.00 0.00 0.33 0.00
C:   0.33 1.00 0.00 0.00 0.00 0.00 0.00 0.33 0.00 0.00 0.33 0.67
G:   0.00 0.00 1.00 1.00 0.67 1.00 0.33 0.00 0.00 0.00 0.00 0.00
T:   0.33 0.00 0.00 0.00 0.33 0.00 0.33 0.67 1.00 1.00 0.33 0.33
```

## 🎲 確率的アプローチ

### プロファイルに基づく確率計算

プロファイル行列を確率分布として扱い、文字列が生成される確率を計算：

```python
def probability_of_pattern(pattern, profile):
    """
    プロファイルに基づいてパターンが生成される確率

    Args:
        pattern: DNA文字列
        profile: プロファイル行列

    Returns:
        確率値
    """
    probability = 1.0
    for i, nucleotide in enumerate(pattern):
        probability *= profile[i][nucleotide]
    return probability

# 例：AAACCT の確率
# P(AAACCT) = P(A,位置1) × P(A,位置2) × ... × P(T,位置6)
```

### プロファイル最尤k-mer

文字列内で最も確率の高いk-merを見つける：

```python
def profile_most_probable_kmer(text, k, profile):
    """
    テキスト内でプロファイルに対して最も確率の高いk-mer

    Args:
        text: DNA文字列
        k: k-merの長さ
        profile: プロファイル行列

    Returns:
        最も確率の高いk-mer
    """
    best_kmer = text[0:k]
    best_probability = 0

    for i in range(len(text) - k + 1):
        kmer = text[i:i+k]
        prob = probability_of_pattern(kmer, profile)
        if prob > best_probability:
            best_probability = prob
            best_kmer = kmer

    return best_kmer
```

## 🔧 グリーディモチーフ探索

### アルゴリズムの概要

1. 最初の配列から全てのk-merを候補として試す
2. 各候補に対して：
   - プロファイル行列を構築
   - 次の配列から最尤k-merを選択
   - すべての配列を処理するまで繰り返す
3. 最もスコアの良いモチーフ集合を選択

```python
def greedy_motif_search(dna_list, k, t):
    """
    グリーディアルゴリズムでモチーフを探索

    Args:
        dna_list: DNA文字列のリスト
        k: モチーフの長さ
        t: 配列の数

    Returns:
        見つかったモチーフのリスト
    """
    best_motifs = [dna[0:k] for dna in dna_list]
    best_score = score(best_motifs)

    # 最初の配列の各k-merを試す
    for i in range(len(dna_list[0]) - k + 1):
        motifs = [dna_list[0][i:i+k]]

        # 残りの配列から最尤k-merを選択
        for j in range(1, t):
            profile = create_profile_matrix(motifs)
            motif = profile_most_probable_kmer(dna_list[j], k, profile)
            motifs.append(motif)

        # スコアを評価
        current_score = score(motifs)
        if current_score < best_score:
            best_score = current_score
            best_motifs = motifs

    return best_motifs
```

### グリーディアルゴリズムの特徴

**利点：**

- 高速（O(n × t^2 × k)）
- 実装が簡単
- 多くの場合、良い近似解を得られる

**欠点：**

- 局所最適解に陥る可能性
- 最適解を保証しない
- 初期値に依存

## 🔄 アルゴリズムの比較

| アルゴリズム                     | 計算量               | 最適性 | 実用性  |
| -------------------------------- | -------------------- | ------ | ------- |
| ブルートフォース（モチーフ発見） | O((n-k+1)^t × k × t) | 最適   | k < 10  |
| メディアン文字列                 | O(4^k × n × t × k)   | 最適   | k ≤ 15  |
| グリーディモチーフ探索           | O(n × t^2 × k)       | 近似   | 任意のk |

## 📝 まとめ

この講義では、モチーフ発見問題の実用的な解法を学びました：

1. **メディアン文字列問題**により計算量を大幅に削減
2. **プロファイル行列**による確率的モデリング
3. **グリーディアルゴリズム**による高速な近似解法
4. 各アプローチのトレードオフの理解

## 🚀 次回予告

次回は、より洗練されたモチーフ発見手法を学びます：

- ランダム化モチーフ探索
- ギブスサンプリング
- 期待値最大化（EM）アルゴリズム

## 📚 参考文献

- Coursera: Bioinformatics Specialization - Week 2
- Jones, N.C. and Pevzner, P.A. (2004) An Introduction to Bioinformatics Algorithms
