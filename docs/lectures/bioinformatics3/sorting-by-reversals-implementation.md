---
title: リバーサルによるソート - 実装詳細
sidebar_label: 実装とアルゴリズム
---

# リバーサルによるソート：アルゴリズムの実装

## 🎯 完全なGreedyアルゴリズムの実装

### 基本的なリバーサル操作

```python
def apply_reversal(permutation, i, j):
    """
    位置iからjまでの要素を逆転させる

    Args:
        permutation: 順列（リスト）
        i: 開始位置（0-indexed）
        j: 終了位置（0-indexed）

    Returns:
        リバーサル後の順列
    """
    result = permutation.copy()
    # 部分配列を逆転
    result[i:j+1] = result[i:j+1][::-1]
    # 符号も反転
    result[i:j+1] = [-x for x in result[i:j+1]]
    return result


def print_permutation(permutation, prefix=""):
    """
    順列を見やすく表示
    """
    elements = []
    for x in permutation:
        if x > 0:
            elements.append(f"+{x}")
        else:
            elements.append(str(x))
    print(f"{prefix}[{' '.join(elements)}]")
```

### 完全なGreedyソートアルゴリズム

```python
class GreedySorting:
    def __init__(self, permutation):
        """
        Greedyソーティングアルゴリズムの初期化

        Args:
            permutation: 初期順列（符号付き整数のリスト）
        """
        self.original = permutation.copy()
        self.permutation = permutation.copy()
        self.reversals = []
        self.steps = []

    def find_element_position(self, element):
        """
        要素の位置を探す（絶対値で比較）
        """
        for i, x in enumerate(self.permutation):
            if abs(x) == abs(element):
                return i
        return -1

    def apply_reversal(self, i, j):
        """
        リバーサルを適用し、記録する
        """
        # リバーサル前の状態を記録
        before = self.permutation.copy()

        # リバーサルを適用
        self.permutation[i:j+1] = self.permutation[i:j+1][::-1]
        self.permutation[i:j+1] = [-x for x in self.permutation[i:j+1]]

        # リバーサル情報を記録
        self.reversals.append((i+1, j+1))  # 1-indexedで記録
        self.steps.append({
            'before': before,
            'after': self.permutation.copy(),
            'reversal': (i, j)
        })

    def sort(self, verbose=False):
        """
        Greedyアルゴリズムで順列をソート

        Args:
            verbose: 詳細な出力を表示するか

        Returns:
            リバーサルの回数
        """
        n = len(self.permutation)

        if verbose:
            print("初期順列:")
            print_permutation(self.permutation, "  ")
            print()

        for k in range(n):
            target = k + 1  # 現在配置すべき要素

            # targetの位置を探す
            position = self.find_element_position(target)

            # 正しい位置にない場合は移動
            if position != k:
                if verbose:
                    print(f"ステップ {len(self.reversals)+1}: +{target}を位置{k+1}に移動")
                    print(f"  リバーサル({k+1}, {position+1})")

                self.apply_reversal(k, position)

                if verbose:
                    print_permutation(self.permutation, "  結果: ")

            # 符号が負の場合は修正
            if self.permutation[k] < 0:
                if verbose:
                    print(f"ステップ {len(self.reversals)+1}: 位置{k+1}の符号を修正")
                    print(f"  リバーサル({k+1}, {k+1})")

                self.permutation[k] = -self.permutation[k]
                self.reversals.append((k+1, k+1))
                self.steps.append({
                    'before': self.permutation.copy(),
                    'after': self.permutation.copy(),
                    'reversal': (k, k)
                })

                if verbose:
                    print_permutation(self.permutation, "  結果: ")

            if verbose and k < n-1:
                print()

        if verbose:
            print(f"\n完了！合計{len(self.reversals)}回のリバーサル")

        return len(self.reversals)

    def get_reversal_sequence(self):
        """
        リバーサルの系列を取得
        """
        return self.reversals
```

## 🧪 実装のテスト

### テストケース1：講義の例

```python
# 講義で使用された例
def test_lecture_example():
    # マウスの順列
    mouse = [+1, -7, +6, -10, +9, -8, +2, -11, -3, +5, +4]

    sorter = GreedySorting(mouse)
    reversal_count = sorter.sort(verbose=True)

    print(f"\n結果:")
    print(f"  リバーサル回数: {reversal_count}")
    print(f"  リバーサル系列: {sorter.get_reversal_sequence()}")

# 実行
test_lecture_example()
```

### テストケース2：シンプルな例

```python
def test_simple_example():
    # より単純な例
    simple = [-3, +4, +1, +5, -2]

    print("シンプルな例のテスト:")
    print_permutation(simple, "初期: ")

    sorter = GreedySorting(simple)
    count = sorter.sort(verbose=False)

    print_permutation(sorter.permutation, "最終: ")
    print(f"リバーサル回数: {count}")
    print(f"リバーサル: {sorter.get_reversal_sequence()}")

test_simple_example()
```

## 📊 ブレークポイントの計算

### ブレークポイント検出アルゴリズム

```python
class BreakpointAnalyzer:
    def __init__(self, permutation):
        """
        ブレークポイント分析器

        Args:
            permutation: 分析する順列
        """
        self.permutation = permutation
        self.n = len(permutation)

    def count_breakpoints(self):
        """
        順列中のブレークポイント数を計算

        Returns:
            ブレークポイントの数
        """
        # 拡張順列を作成（0とn+1を追加）
        extended = [0] + self.permutation + [self.n + 1]
        breakpoints = 0

        for i in range(len(extended) - 1):
            # 隣接要素が連続していない場合
            if extended[i+1] - extended[i] != 1:
                breakpoints += 1

        return breakpoints

    def find_breakpoint_positions(self):
        """
        ブレークポイントの位置をリストで返す

        Returns:
            ブレークポイントの位置のリスト
        """
        extended = [0] + self.permutation + [self.n + 1]
        positions = []

        for i in range(len(extended) - 1):
            if extended[i+1] - extended[i] != 1:
                positions.append(i)

        return positions

    def visualize_breakpoints(self):
        """
        ブレークポイントを視覚的に表示
        """
        extended = [0] + self.permutation + [self.n + 1]

        print("拡張順列とブレークポイント:")

        # 要素を表示
        elements = []
        for x in extended:
            if x >= 0:
                elements.append(f"{x:3}")
            else:
                elements.append(f"{x:3}")
        print(" ".join(elements))

        # ブレークポイントをマーク
        markers = []
        for i in range(len(extended) - 1):
            if extended[i+1] - extended[i] != 1:
                markers.append("  ^")
            else:
                markers.append("   ")
        print(" ".join(markers))

        print(f"\nブレークポイント数: {self.count_breakpoints()}")
```

### ブレークポイント分析の実行

```python
def analyze_breakpoints_example():
    # いくつかの順列でブレークポイントを分析
    examples = [
        [1, 2, 3, 4, 5],           # 完全にソート済み
        [5, 4, 3, 2, 1],           # 完全に逆順
        [1, 3, 2, 4, 5],           # 部分的に乱れている
        [2, 4, 1, 3, 5],           # より複雑な例
    ]

    for perm in examples:
        print(f"\n順列: {perm}")
        analyzer = BreakpointAnalyzer(perm)
        analyzer.visualize_breakpoints()
        print(f"ブレークポイント位置: {analyzer.find_breakpoint_positions()}")

analyze_breakpoints_example()
```

## 🔄 リバーサルとブレークポイントの関係

### リバーサルがブレークポイントに与える影響

```python
def analyze_reversal_effect_on_breakpoints(permutation, i, j):
    """
    リバーサルがブレークポイント数に与える影響を分析

    Args:
        permutation: 元の順列
        i, j: リバーサル区間（0-indexed）

    Returns:
        ブレークポイント数の変化
    """
    # リバーサル前のブレークポイント数
    before_analyzer = BreakpointAnalyzer(permutation)
    before_count = before_analyzer.count_breakpoints()

    # リバーサルを適用
    after = apply_reversal(permutation, i, j)

    # リバーサル後のブレークポイント数
    after_analyzer = BreakpointAnalyzer(after)
    after_count = after_analyzer.count_breakpoints()

    print(f"リバーサル({i+1}, {j+1})の効果:")
    print(f"  前: {permutation} -> ブレークポイント数: {before_count}")
    print(f"  後: {after} -> ブレークポイント数: {after_count}")
    print(f"  変化: {after_count - before_count}")

    return after_count - before_count

# 例
test_perm = [1, 3, 2, 4, 5]
analyze_reversal_effect_on_breakpoints(test_perm, 1, 2)
```

## 🎯 パフォーマンス分析

### 時間計算量の比較

```python
import time
import random

def generate_random_permutation(n):
    """
    ランダムな符号付き順列を生成
    """
    perm = list(range(1, n + 1))
    random.shuffle(perm)
    # ランダムに符号を反転
    for i in range(n):
        if random.random() < 0.5:
            perm[i] = -perm[i]
    return perm

def performance_analysis():
    """
    異なるサイズの順列でパフォーマンスを測定
    """
    sizes = [10, 20, 50, 100, 200]
    results = []

    print("パフォーマンス分析:")
    print("-" * 50)
    print(f"{'サイズ':>8} | {'時間(秒)':>10} | {'リバーサル数':>12}")
    print("-" * 50)

    for n in sizes:
        perm = generate_random_permutation(n)

        start_time = time.time()
        sorter = GreedySorting(perm)
        reversal_count = sorter.sort(verbose=False)
        end_time = time.time()

        elapsed = end_time - start_time
        results.append({
            'size': n,
            'time': elapsed,
            'reversals': reversal_count
        })

        print(f"{n:8} | {elapsed:10.6f} | {reversal_count:12}")

    return results

# パフォーマンステストの実行
# performance_results = performance_analysis()
```

## 📝 まとめと考察

### Greedyアルゴリズムの特徴

**長所:**

- 実装が簡単
- 直感的で理解しやすい
- 必ず終了する（最大2n回のリバーサル）

**短所:**

- 最適ではない
- 実際の生物学的進化経路とは異なる可能性
- ブレークポイントを効率的に減らさない

### 改善の方向性

次回学習する **ブレークポイントグラフ** を使用することで：

- より効率的なリバーサル選択
- 最適解への近似
- 生物学的により妥当な経路の発見

## 🔗 参考実装

完全なコードは[GitHubリポジトリ](https://github.com/susumutomita/bioinformatics-note)で確認できます。
