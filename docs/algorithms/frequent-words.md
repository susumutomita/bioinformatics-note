---
sidebar_position: 1
title: 頻出語問題（Frequent Words Problem）
---

# 頻出語問題（Frequent Words Problem）

## 📝 問題定義

### 入力

- 文字列 `Text`
- 整数 `k`

### 出力

- `Text`中で最も頻度の高いすべての`k-mer`（長さ`k`の部分文字列）

## 🎯 なぜこの問題が重要か

DNA複製において、複製起点（OriC）にはDnaAボックスと呼ばれる短い配列が複数回出現します。
これらの頻出パターンを見つけることで、複製起点を特定できる可能性があります。

## 💻 実装

### Python実装（基本版）

```python
def FrequentWords(Text, k):
    """
    Text中で最も頻度の高いk-merをすべて見つける

    Args:
        Text: DNA配列を表す文字列
        k: k-merの長さ

    Returns:
        最も頻度の高いk-merのリスト
    """
    frequent_patterns = []
    count = {}

    # すべてのk-merをカウント
    for i in range(len(Text) - k + 1):
        pattern = Text[i:i+k]
        if pattern in count:
            count[pattern] += 1
        else:
            count[pattern] = 1

    # 最大頻度を見つける
    if count:
        max_count = max(count.values())

        # 最大頻度のパターンを収集
        for pattern, freq in count.items():
            if freq == max_count:
                frequent_patterns.append(pattern)

    return frequent_patterns
```

### 改良版（関数分割）

```python
def PatternCount(Text, Pattern):
    """
    Text中でPatternが出現する回数を数える

    Args:
        Text: 検索対象の文字列
        Pattern: 検索するパターン

    Returns:
        Patternの出現回数
    """
    count = 0
    for i in range(len(Text) - len(Pattern) + 1):
        if Text[i:i+len(Pattern)] == Pattern:
            count += 1
    return count


def FrequentWordsWithCounting(Text, k):
    """
    PatternCountを使用した頻出語探索

    Args:
        Text: DNA配列を表す文字列
        k: k-merの長さ

    Returns:
        最も頻度の高いk-merのリスト
    """
    frequent_patterns = []
    count = []

    # 各位置のk-merの出現回数を計算
    for i in range(len(Text) - k + 1):
        pattern = Text[i:i+k]
        count.append(PatternCount(Text, pattern))

    # 最大頻度を見つける
    max_count = max(count)

    # 最大頻度のパターンを収集（重複を避ける）
    for i in range(len(Text) - k + 1):
        if count[i] == max_count:
            pattern = Text[i:i+k]
            if pattern not in frequent_patterns:
                frequent_patterns.append(pattern)

    return frequent_patterns
```

### 効率的な実装（辞書を使用）

```python
def FrequentWordsOptimized(Text, k):
    """
    辞書を使用した効率的な頻出語探索

    Args:
        Text: DNA配列を表す文字列
        k: k-merの長さ

    Returns:
        最も頻度の高いk-merのリスト
    """
    from collections import defaultdict

    # defaultdictを使用してコードを簡潔に
    count = defaultdict(int)

    # すべてのk-merをカウント
    for i in range(len(Text) - k + 1):
        pattern = Text[i:i+k]
        count[pattern] += 1

    # 最大頻度を見つける
    max_count = max(count.values()) if count else 0

    # 最大頻度のパターンを返す
    return [pattern for pattern, freq in count.items() if freq == max_count]
```

## 📊 計算量分析

### 基本版

- 時間計算量: O(n²k)
  - n = |Text|
  - 各k-merについて全体をスキャン
- 空間計算量: O(n)

### 辞書を使用した版

- 時間計算量: O(nk)
  - 各k-merを一度だけ処理
- 空間計算量: O(n)

## 🧪 使用例

```python
# 例1：単純なケース
text1 = "ACAACTATGCATACTATCGGGAACTATCCT"
k1 = 5
result1 = FrequentWords(text1, k1)
print(f"Text: {text1}")
print(f"k = {k1}")
print(f"最頻出{k1}-mer: {result1}")
# 出力: 最頻出5-mer: ['ACTAT']

# 例2：複数の最頻出パターン
text2 = "ATGATGATG"
k2 = 3
result2 = FrequentWords(text2, k2)
print(f"Text: {text2}")
print(f"k = {k2}")
print(f"最頻出{k2}-mer: {result2}")
# 出力: 最頻出3-mer: ['ATG', 'TGA', 'GAT']
```

## 🔬 生物学的応用

### DnaAボックスの発見

```python
def FindDnaABoxes(oriC, box_length=9):
    """
    複製起点（OriC）中のDnaAボックス候補を見つける

    Args:
        oriC: 複製起点の配列
        box_length: DnaAボックスの長さ（通常9）

    Returns:
        DnaAボックス候補のリスト
    """
    candidates = FrequentWords(oriC, box_length)

    # 追加のフィルタリング（例：出現回数が3回以上）
    filtered = []
    for pattern in candidates:
        if PatternCount(oriC, pattern) >= 3:
            filtered.append(pattern)

    return filtered
```

## 🎮 インタラクティブな実験

```python
def experiment_with_frequent_words():
    """
    頻出語問題を対話的に実験する
    """
    import random

    # ランダムDNA配列を生成
    def generate_random_dna(length, pattern, insertions):
        """パターンを含むランダムDNA配列を生成"""
        nucleotides = ['A', 'C', 'G', 'T']
        dna = ''.join(random.choices(nucleotides, k=length))

        # パターンを複数箇所に挿入
        dna_list = list(dna)
        for _ in range(insertions):
            pos = random.randint(0, length - len(pattern))
            for i, base in enumerate(pattern):
                dna_list[pos + i] = base

        return ''.join(dna_list)

    # 実験
    test_dna = generate_random_dna(100, "ATGATG", 4)
    k = 6

    print(f"DNA配列（長さ{len(test_dna)}）:")
    print(test_dna)
    print(f"\n{k}-merの頻出パターン:")
    print(FrequentWords(test_dna, k))
```

## 📈 拡張と改良

### 1. 近似マッチングへの拡張

```python
def FrequentWordsWithMismatches(Text, k, d):
    """
    最大d個のミスマッチを許容した頻出語探索

    Args:
        Text: DNA配列
        k: k-merの長さ
        d: 許容するミスマッチ数

    Returns:
        最頻出k-merのリスト（ミスマッチを考慮）
    """
    # 実装は複雑になるため、ここでは概要のみ
    pass
```

### 2. 逆相補鎖の考慮

```python
def ReverseComplement(Pattern):
    """DNA配列の逆相補鎖を返す"""
    complement = {'A': 'T', 'T': 'A', 'C': 'G', 'G': 'C'}
    return ''.join(complement[base] for base in Pattern[::-1])

def FrequentWordsWithRC(Text, k):
    """逆相補鎖も考慮した頻出語探索"""
    # パターンとその逆相補鎖の両方をカウント
    pass
```

## 🚀 次のステップ

1. Clump Finding Problem - 局所的な頻出パターンの探索（準備中）
2. Pattern Matching - パターン探索（準備中）
3. Approximate Pattern Matching - ミスマッチを許容した探索（準備中）

## 📚 参考資料

- [Rosalind Problem BA1A](http://rosalind.info/problems/ba1a/)
- [Bioinformatics Algorithms Course](https://www.coursera.org/learn/dna-analysis)
- [Python for Bioinformatics](https://pythonforbiologists.com/)
