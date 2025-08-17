---
sidebar_position: 2
title: GCスキュー分析
---

# GCスキュー分析（GC Skew Analysis）

## 📝 問題定義

### 入力

- DNA配列（文字列）

### 出力

- 各位置でのGCスキュー値のリスト
- スキューが最小となる位置

## 🎯 なぜGCスキューが重要か

DNA複製の非対称性により、ゲノムの異なる領域でG（グアニン）とC（シトシン）の頻度に偏りが生じます。
この偏りを追跡することで、複製起点を特定できます。

## 📊 GCスキューの定義

```
Skew[i] = #G[0:i]- #C[0:i]
```

- 位置0からiまでのGの個数からCの個数を引いた値
- Gに出会うと+1
- Cに出会うと-1
- AまたはTでは変化なし

## 💻 実装

### 基本的な実装

```python
def compute_gc_skew(genome):
    """
    ゲノム配列のGCスキューを計算

    Args:
        genome: DNA配列（文字列）

    Returns:
        各位置でのスキュー値のリスト
    """
    skew = [0]  # 位置0でのスキューは0

    for i in range(len(genome)):
        if genome[i] == 'G':
            skew.append(skew[-1] + 1)
        elif genome[i] == 'C':
            skew.append(skew[-1] - 1)
        else:  # A or T
            skew.append(skew[-1])

    return skew
```

### 最小スキュー位置の検出

```python
def find_minimum_skew_positions(genome):
    """
    GCスキューが最小となる位置を見つける

    Args:
        genome: DNA配列

    Returns:
        最小スキューを持つ位置のリスト
    """
    skew = compute_gc_skew(genome)
    min_skew = min(skew)

    # 最小値を持つすべての位置を返す
    positions = []
    for i in range(len(skew)):
        if skew[i] == min_skew:
            positions.append(i)

    return positions
```

### 効率的な実装（メモリ最適化）

```python
def find_minimum_skew_optimized(genome):
    """
    メモリ効率的にスキュー最小位置を見つける

    Args:
        genome: DNA配列

    Returns:
        最小スキューを持つ位置のリスト
    """
    current_skew = 0
    min_skew = 0
    min_positions = [0]

    for i, nucleotide in enumerate(genome, 1):
        if nucleotide == 'G':
            current_skew += 1
        elif nucleotide == 'C':
            current_skew -= 1

        if current_skew < min_skew:
            min_skew = current_skew
            min_positions = [i]
        elif current_skew == min_skew:
            min_positions.append(i)

    return min_positions
```

## 📈 可視化

### スキューダイアグラムの作成

```python
import matplotlib.pyplot as plt

def plot_gc_skew(genome, title="GC Skew Diagram"):
    """
    GCスキューを可視化

    Args:
        genome: DNA配列
        title: グラフのタイトル
    """
    skew = compute_gc_skew(genome)
    positions = list(range(len(skew)))

    plt.figure(figsize=(12, 6))
    plt.plot(positions, skew, 'b-', linewidth=1)

    # 最小値をマーク
    min_skew = min(skew)
    min_positions = [i for i, s in enumerate(skew) if s == min_skew]

    for pos in min_positions:
        plt.axvline(x=pos, color='r', linestyle='--', alpha=0.7)
        plt.plot(pos, min_skew, 'ro', markersize=8)

    plt.xlabel('ゲノム位置')
    plt.ylabel('GCスキュー')
    plt.title(title)
    plt.grid(True, alpha=0.3)

    # 最小値の位置を注釈
    for pos in min_positions[:3]:  # 最初の3つだけ表示
        plt.annotate(f'Min at {pos}',
                    xy=(pos, min_skew),
                    xytext=(pos, min_skew - abs(min_skew) * 0.1),
                    arrowprops=dict(arrowstyle='->', color='red'))

    plt.show()
```

## 🧪 実例

### 例1：シンプルなケース

```python
# 小さなゲノムでテスト
test_genome = "CATGGGCATCGGCCATACGCC"

# スキューを計算
skew = compute_gc_skew(test_genome)
print("位置:  ", list(range(len(test_genome) + 1)))
print("塩基:  ", list(test_genome))
print("スキュー:", skew)

# 最小位置を見つける
min_positions = find_minimum_skew_positions(test_genome)
print(f"\n最小スキュー位置: {min_positions}")

# 出力例:
# 位置:   [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, ...]
# 塩基:   ['C', 'A', 'T', 'G', 'G', 'G', 'C', ...]
# スキュー: [0, -1, -1, -1, 0, 1, 2, 1, ...]
# 最小スキュー位置: [3]
```

### 例2：実際のゲノムデータ

```python
def analyze_real_genome(genome_file):
    """
    実際のゲノムファイルを分析

    Args:
        genome_file: FASTAファイルのパス

    Returns:
        分析結果の辞書
    """
    # ゲノムを読み込む（簡略化）
    with open(genome_file, 'r') as f:
        lines = f.readlines()
        genome = ''.join(line.strip() for line in lines if not line.startswith('>'))

    # 分析
    min_positions = find_minimum_skew_optimized(genome)

    # 統計情報
    results = {
        'genome_length': len(genome),
        'min_skew_positions': min_positions,
        'number_of_minima': len(min_positions),
        'gc_content': (genome.count('G') + genome.count('C')) / len(genome)
    }

    return results
```

## 🔍 複製起点の検証

### スキュー最小値周辺でのDnaAボックス探索

```python
def find_dnaa_boxes_near_skew_minimum(genome, box_length=9, window=1000):
    """
    スキュー最小値周辺でDnaAボックス候補を探す

    Args:
        genome: ゲノム配列
        box_length: DnaAボックスの長さ（通常9）
        window: 探索ウィンドウサイズ

    Returns:
        DnaAボックス候補のリスト
    """
    # スキュー最小位置を見つける
    min_positions = find_minimum_skew_optimized(genome)

    all_candidates = []

    for pos in min_positions:
        # ウィンドウを定義
        start = max(0, pos - window // 2)
        end = min(len(genome), pos + window // 2)
        region = genome[start:end]

        # 頻出パターンを探す
        pattern_count = {}
        for i in range(len(region) - box_length + 1):
            pattern = region[i:i + box_length]
            pattern_count[pattern] = pattern_count.get(pattern, 0) + 1

        # 逆相補鎖も考慮
        for pattern in list(pattern_count.keys()):
            rc = reverse_complement(pattern)
            if rc in pattern_count:
                # 両方向のカウントを合計
                total = pattern_count[pattern] + pattern_count[rc]
                pattern_count[pattern] = total
                pattern_count[rc] = total

        # 頻度の高いパターンを収集
        threshold = 3  # 最小出現回数
        candidates = [
            (pattern, count, pos)
            for pattern, count in pattern_count.items()
            if count >= threshold
        ]

        all_candidates.extend(candidates)

    # 重複を除去して頻度順にソート
    unique_candidates = list(set(all_candidates))
    unique_candidates.sort(key=lambda x: x[1], reverse=True)

    return unique_candidates

def reverse_complement(pattern):
    """逆相補鎖を計算"""
    complement = {'A': 'T', 'T': 'A', 'C': 'G', 'G': 'C'}
    return ''.join(complement[base] for base in pattern[::-1])
```

## 📊 統計的検証

### ランダムゲノムとの比較

```python
import random

def generate_random_genome(length, gc_content=0.5):
    """
    ランダムなゲノムを生成

    Args:
        length: ゲノムの長さ
        gc_content: GC含量（0-1）

    Returns:
        ランダムゲノム
    """
    nucleotides = []
    for _ in range(length):
        if random.random() < gc_content:
            nucleotides.append(random.choice(['G', 'C']))
        else:
            nucleotides.append(random.choice(['A', 'T']))

    return ''.join(nucleotides)

def compare_skew_patterns(real_genome, num_simulations=100):
    """
    実際のゲノムとランダムゲノムのスキューパターンを比較

    Args:
        real_genome: 実際のゲノム
        num_simulations: シミュレーション回数

    Returns:
        統計的有意性
    """
    real_skew = compute_gc_skew(real_genome)
    real_min = min(real_skew)

    # GC含量を計算
    gc_content = (real_genome.count('G') + real_genome.count('C')) / len(real_genome)

    # ランダムゲノムでのスキュー最小値を収集
    random_mins = []
    for _ in range(num_simulations):
        random_genome = generate_random_genome(len(real_genome), gc_content)
        random_skew = compute_gc_skew(random_genome)
        random_mins.append(min(random_skew))

    # 実際のスキューがどれだけ極端か評価
    more_extreme = sum(1 for rm in random_mins if rm <= real_min)
    p_value = more_extreme / num_simulations

    return {
        'real_minimum': real_min,
        'random_mean': sum(random_mins) / len(random_mins),
        'p_value': p_value,
        'significant': p_value < 0.05
    }
```

## 🚀 応用

### 複数の細菌ゲノムの分析

```python
def batch_analyze_genomes(genome_files):
    """
    複数のゲノムを一括分析

    Args:
        genome_files: ゲノムファイルのリスト

    Returns:
        分析結果のまとめ
    """
    results = []

    for file in genome_files:
        genome_name = file.split('/')[-1].replace('.fasta', '')

        # ゲノムを読み込む
        with open(file, 'r') as f:
            genome = ''.join(line.strip() for line in f if not line.startswith('>'))

        # GCスキュー分析
        min_positions = find_minimum_skew_optimized(genome)

        # DnaAボックス探索
        candidates = find_dnaa_boxes_near_skew_minimum(genome)

        # 結果を保存
        results.append({
            'genome': genome_name,
            'length': len(genome),
            'oriC_positions': min_positions[:5],  # 上位5つ
            'top_dnaa_boxes': candidates[:10]     # 上位10個
        })

    return results
```

## 📈 計算量分析

### 時間計算量

- GCスキュー計算: O(n)
- 最小値検出: O(n)
- 全体: O(n)

### 空間計算量

- 基本実装: O(n) - 全スキュー値を保存
- 最適化版: O(1) - 現在のスキューのみ保存

## 🎓 まとめ

1. GCスキューは複製起点の強力な指標
   - DNA複製の非対称性を反映
   - スキュー最小値が複製起点を示唆

2. 計算が可能
   - 線形時間で計算可能
   - メモリ使用量も最適化可能

3. 他の手法との組み合わせが重要
   - 頻出語問題と組み合わせて精度向上
   - 統計的検証で信頼性を確保

## 📚 参考資料

- [Wikipedia - GC-skew](https://en.wikipedia.org/wiki/GC_skew)
- [Rosalind - Minimum Skew Problem](http://rosalind.info/problems/ba1f/)
- Grigoriev, A. (1998) "Analyzing genomes with cumulative skew diagrams"
