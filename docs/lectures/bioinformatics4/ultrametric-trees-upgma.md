---
sidebar_position: 6
title: UPGMA法：分子時計で時を刻む系統樹の魔法
---

# UPGMA法：分子時計で時を刻む系統樹の魔法（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**すべての生物が同じ速度で進化すると仮定して、美しく整った系統樹を効率的に構築する技術を習得する**

でも、ちょっと待ってください。そもそも「同じ速度で進化」って本当にあり得るの？
実は、これは大胆な仮定ですが、驚くほど実用的な結果を生み出す魔法なんです。

## 🤔 ステップ0：なぜウルトラメトリック木が必要なのか

### 0-1. そもそもの問題を考えてみよう

```
現実の進化：
- 種によって進化速度が違う
- 環境によって進化速度が変わる
- でも、系統関係は知りたい

理想の世界：
- すべての種が一定速度で進化
- 分子時計が正確に時を刻む
- 根から葉までの距離が全て等しい
```

### 0-2. 驚きの事実

```
実は多くの遺伝子では、
分子時計仮説が成り立つ！

例：ヘモグロビン遺伝子
- 100万年あたり約1塩基が変化
- どの生物でもほぼ一定速度
```

## 📖 ステップ1：ウルトラメトリック木の不思議

### 1-1. ウルトラメトリックって何？

```
定義：根から全ての葉までの
     距離（経路長）が等しい木

視覚的イメージ：
      根（33百万年前）
      /            \
   内部1(23)      内部2(15)
   /    \         /    \
  葉A   葉B     葉C    葉D
  (0)   (0)     (0)    (0)

根→葉A: 33-23 + 23-0 = 33
根→葉B: 33-23 + 23-0 = 33
根→葉C: 33-15 + 15-0 = 33
根→葉D: 33-15 + 15-0 = 33

全部同じ！これがウルトラメトリック！
```

### 1-2. なぜこれが重要？

```python
def is_ultrametric(tree):
    """
    ウルトラメトリック性のチェック
    すべての葉への距離が等しいか確認
    """
    root = tree.root
    distances = []

    for leaf in tree.leaves:
        dist = distance_from_root_to_leaf(root, leaf)
        distances.append(dist)

    # 全ての距離が等しければTrue
    return len(set(distances)) == 1
```

## 🕐 ステップ2：分子時計モデル

### 2-1. 分子時計の基本概念

```
分子時計 = DNAの変化が時計のように一定

例：時計の針のように
1時間 → 60分
100万年 → 1塩基変異

これで進化の時間が測れる！
```

### 2-2. ノードに年齢を割り当てる

```python
class TreeNode:
    def __init__(self):
        self.age = None  # 百万年単位
        self.children = []

    def compute_edge_weight(self, child):
        """
        エッジの重み = 親の年齢 - 子の年齢
        """
        return self.age - child.age

# 例：
# 親ノード（年齢33） → 子ノード（年齢23）
# エッジの重み = 33 - 23 = 10百万年
```

## 🎪 ステップ3：UPGMA登場

### 3-1. UPGMAって何の略？

```
UPGMA = Unweighted Pair Group Method with Arithmetic Mean
      = 算術平均を用いた非加重ペアグループ法

でも名前は覚えなくていい！
重要なのは「何をするか」
```

### 3-2. 基本的な考え方

```
料理のレシピのように：

1. 材料（種）を用意
2. 一番近い2つを選ぶ
3. 合体させて新しいグループを作る
4. 材料が1つになるまで繰り返す

これで系統樹の完成！
```

## 📊 ステップ4：UPGMAアルゴリズムの詳細

### 4-1. 初期状態

```python
# 距離行列（例）
#      i   j   k   l
# i    0   3   4   3
# j    3   0   4   5
# k    4   4   0   2
# l    3   5   2   0

# 最初は全員が独立したクラスター
clusters = [{i}, {j}, {k}, {l}]
```

### 4-2. ステップ1：最も近いペアを見つける

```python
def find_closest_pair(distance_matrix):
    """
    距離行列から最小値を探す
    """
    min_dist = float('inf')
    closest_pair = None

    for i in range(n):
        for j in range(i+1, n):
            if distance_matrix[i][j] < min_dist:
                min_dist = distance_matrix[i][j]
                closest_pair = (i, j)

    return closest_pair, min_dist

# 例：k-l間の距離2が最小
# → kとlをマージ！
```

### 4-3. ステップ2：クラスターをマージ

```python
def merge_clusters(cluster1, cluster2, distance):
    """
    2つのクラスターを1つに統合
    新しい内部ノードを作成
    """
    new_node = TreeNode()
    new_node.age = distance / 2  # 年齢は距離の半分
    new_node.children = [cluster1, cluster2]

    return new_node

# k-l間の距離が2
# → 新ノードの年齢は1
```

### 4-4. ステップ3：距離行列を更新

```python
def update_distance_matrix(dist_matrix, merged_cluster, other_clusters):
    """
    マージ後の距離を再計算
    算術平均を使用（これがUPGMAの特徴！）
    """
    for other in other_clusters:
        # 新クラスターと他クラスターの距離
        # = 元の2クラスターからの距離の平均
        new_distance = average(
            dist_to_cluster1(other),
            dist_to_cluster2(other)
        )
```

## 🔬 ステップ5：具体例で完全理解

### 5-1. 実際にやってみよう

```
初期距離行列：
     i  j  k  l
i    0  3  4  3
j    3  0  4  5
k    4  4  0  2  ← 最小値！
l    3  5  2  0

ステップ1：kとlをマージ
→ 新ノード(k,l)の年齢 = 2/2 = 1
```

### 5-2. 距離行列の更新

```
更新後の距離行列：
      i    j   (k,l)
i     0    3    3.5   ← (4+3)/2
j     3    0    4.5   ← (4+5)/2
(k,l) 3.5  4.5   0

次の最小値：i-j間の3
```

### 5-3. 最終ステップ

```python
# 全ステップの実行
def upgma_algorithm(distance_matrix):
    """
    完全なUPGMAアルゴリズム
    """
    n = len(distance_matrix)
    clusters = initialize_singleton_clusters(n)
    tree_nodes = []

    while len(clusters) > 1:
        # 1. 最も近いペアを見つける
        i, j, min_dist = find_closest_pair(distance_matrix)

        # 2. 新しい内部ノードを作成
        new_node = create_internal_node(
            clusters[i], clusters[j],
            age=min_dist/2
        )

        # 3. クラスターをマージ
        merged = merge_clusters(clusters[i], clusters[j])

        # 4. 距離行列を更新
        distance_matrix = update_matrix(
            distance_matrix, merged, i, j
        )

        # 5. クラスターリストを更新
        clusters = update_clusters(clusters, merged, i, j)

    return build_tree(tree_nodes)
```

## 😮 ステップ6：UPGMAの強みと弱み

### 6-1. 強み

```
✅ 必ず木が作れる（失敗しない）
✅ 計算が速い（O(n²)）
✅ ウルトラメトリック木が保証される
✅ 実装が簡単
```

### 6-2. 弱み

```
❌ 分子時計仮説が必要
❌ 非加法的行列でも正確とは限らない
❌ 進化速度の違いを無視

例：実際のi-l間距離 = 3
    UPGMA木での距離 = 4
    → ズレが生じる！
```

## 💡 ステップ7：実装してみよう

### 7-1. Pythonでの完全実装

```python
import numpy as np

class UPGMA:
    def __init__(self, distance_matrix):
        self.dist_matrix = np.array(distance_matrix)
        self.n = len(distance_matrix)
        self.labels = list(range(self.n))
        self.clusters = [{i} for i in range(self.n)]
        self.tree = {}
        self.ages = {}

    def find_minimum(self):
        """距離行列の最小値を見つける"""
        min_val = float('inf')
        min_i, min_j = -1, -1

        for i in range(len(self.clusters)):
            for j in range(i+1, len(self.clusters)):
                if self.dist_matrix[i][j] < min_val:
                    min_val = self.dist_matrix[i][j]
                    min_i, min_j = i, j

        return min_i, min_j, min_val

    def merge_clusters(self, i, j, distance):
        """クラスターiとjをマージ"""
        # 新しいクラスター名
        new_name = f"({self.labels[i]},{self.labels[j]})"

        # 年齢を記録
        self.ages[new_name] = distance / 2

        # ツリー構造を記録
        self.tree[new_name] = [self.labels[i], self.labels[j]]

        # クラスターを更新
        new_cluster = self.clusters[i] | self.clusters[j]

        return new_name, new_cluster

    def update_distances(self, i, j):
        """距離行列を更新"""
        new_row = []

        for k in range(len(self.clusters)):
            if k == i or k == j:
                continue

            # 算術平均を計算
            dist_ik = self.dist_matrix[min(i,k)][max(i,k)]
            dist_jk = self.dist_matrix[min(j,k)][max(j,k)]

            # クラスターサイズで重み付け
            size_i = len(self.clusters[i])
            size_j = len(self.clusters[j])

            new_dist = (size_i * dist_ik + size_j * dist_jk) / (size_i + size_j)
            new_row.append(new_dist)

        return new_row

    def build(self):
        """UPGMAアルゴリズムの実行"""
        while len(self.clusters) > 1:
            # 最小距離のペアを見つける
            i, j, min_dist = self.find_minimum()

            # クラスターをマージ
            new_label, new_cluster = self.merge_clusters(i, j, min_dist)

            # 距離行列を更新
            new_distances = self.update_distances(i, j)

            # 行列とクラスターリストを再構築
            self.rebuild_matrix(i, j, new_distances)
            self.labels[min(i,j)] = new_label
            self.clusters[min(i,j)] = new_cluster

            # 大きい方のインデックスを削除
            del self.labels[max(i,j)]
            del self.clusters[max(i,j)]

        return self.tree, self.ages
```

### 7-2. 使用例

```python
# コロナウイルスの例
distance_matrix = [
    [0, 3, 4, 3],
    [3, 0, 4, 5],
    [4, 4, 0, 2],
    [3, 5, 2, 0]
]

upgma = UPGMA(distance_matrix)
tree, ages = upgma.build()

print("構築された系統樹：")
for node, children in tree.items():
    print(f"{node} → {children}")
    print(f"  年齢: {ages[node]}百万年前")
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- UPGMAは近い種から順番にグループ化する
- 必ずウルトラメトリック木ができる
- 計算が速くて実用的

### レベル2：本質的理解（ここまで来たら素晴らしい）

- 分子時計仮説に基づいている
- 算術平均で新しい距離を計算
- O(n²)の時間計算量で効率的

### レベル3：応用的理解（プロレベル）

- 加法的行列でも正確とは限らない
- 進化速度の違いを考慮できない
- ヒューリスティックとしての価値と限界

## 🚀 次回予告

さらに驚くべき事実が！UPGMAの弱点を克服し、より正確な系統樹を構築する「**近隣結合法（Neighbor-Joining）**」の魔法に迫ります。進化速度の違いも考慮できる、革命的なアルゴリズムです！

## 🧬 生物学的な意味

### なぜUPGMAが今でも使われるのか

```
1. シンプルで理解しやすい
   - 初心者でも実装可能
   - 結果の解釈が容易

2. 特定の条件下では正確
   - 分子時計が成り立つ場合
   - 近縁種の解析

3. 高速処理が可能
   - 大規模データセットに対応
   - リアルタイム解析に適用
```

### 実例：インフルエンザの系統解析

```python
def analyze_flu_strains():
    """
    インフルエンザ株の系統解析
    """
    # HA遺伝子の配列から距離行列を作成
    sequences = load_flu_sequences()
    distance_matrix = compute_genetic_distances(sequences)

    # UPGMAで系統樹を構築
    upgma = UPGMA(distance_matrix)
    tree, ages = upgma.build()

    # ワクチン株の選定に利用
    vaccine_candidates = identify_dominant_strains(tree)

    return vaccine_candidates
```

## 🎓 練習問題

### 問題1：小さな例で練習

```
距離行列：
     A  B  C
A    0  4  6
B    4  0  6
C    6  6  0

Q: UPGMAアルゴリズムを手動で実行し、
   各ステップでの年齢を計算せよ
```

### 問題2：ウルトラメトリック性の確認

```python
def check_ultrametric(tree):
    """
    与えられた木がウルトラメトリックか判定
    """
    # あなたの実装
    pass

# テストケース
tree = build_sample_tree()
is_ultra = check_ultrametric(tree)
```

### 問題3：考察問題

```
Q: UPGMAと最小二乗法の違いは何か？
   それぞれの利点と欠点を比較せよ
```

---

_次回：「近隣結合法：進化速度の違いも考慮できる画期的アルゴリズム」でお会いしましょう！_
