# k-Meansクラスタリングの Lloyd アルゴリズム（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**Lloyd アルゴリズムの仕組みを理解し、酵母遺伝子のクラスタリングで生物学的発見につなげる**

でも、ちょっと待ってください。そもそもなぜ「Lloyd アルゴリズム」という名前なの？実は、この手法は1957年にStuart Lloyd が発明した、k-means クラスタリングを実際に解く最も基本的なアルゴリズムなんです。

## 🤔 ステップ0：なぜ Lloyd アルゴリズムが重要なの？

### 0-1. そもそもの問題を考えてみよう

前回の講義で「k-means クラスタリングは NP困難」という衝撃的な事実を学びました。

でも待って...NP困難なのに、なぜ私たちは k-means クラスタリングを日常的に使えているの？

**答え：Lloyd アルゴリズムがあるから！**

NP困難だからといって「解けない」わけではありません。「最適解を保証して効率的に解くのが困難」なだけです。Lloyd アルゴリズムは、**実用的な時間で、十分良い解を見つけてくれる**のです。

### 0-2. 驚きの事実

Lloyd アルゴリズムは：

- **必ず収束する**（無限ループしない）
- **毎回、解が改善される**（悪くなることはない）
- **実装が驚くほどシンプル**（わずか数行のコード）

まるで魔法のような性質を持っています。でも実は、しっかりとした数学的根拠があるんです。

## 📖 ステップ1：Lloyd アルゴリズムの基本アイデア

### 1-1. まずは具体例で理解しよう

簡単なデータセットを使って説明します：

```
データポイント：
A(1,2), B(2,3), C(7,8), D(8,9), E(3,1)

目標：これを k=2 のクラスターに分けたい
```

**質問：どうやって分けるのが最適でしょう？**

人間の目で見ると：

- クラスター1：A, B, E（左下のグループ）
- クラスター2：C, D（右上のグループ）

これが直感的に「良いクラスタリング」に見えますよね？

### 1-2. でも、コンピューターはどう考える？

コンピューターには「直感」がありません。数学的に厳密な手順が必要です。

**Lloyd アルゴリズムの基本戦略：**

1. まずは適当に中心点を決める
2. 各点を最も近い中心に割り当てる
3. 各クラスターの重心を新しい中心にする
4. 2と3を繰り返す

「適当に始めて、だんだん改善していく」というアプローチです。

## 📖 ステップ2：Lloyd アルゴリズムの詳細手順

### 2-1. ステップ0：初期中心の選択

```python
import numpy as np
import matplotlib.pyplot as plt

# データポイント
points = np.array([[1,2], [2,3], [7,8], [8,9], [3,1]])

# k=2 なので、2つの中心をランダムに選択
# 例：center1 = (2,1), center2 = (6,7)
centers = np.array([[2,1], [6,7]])

print("初期中心:", centers)
```

**重要な観察：**
初期中心は「適当」に選んでいます。最終結果に影響しますが、それでも良い解が得られる不思議があります。

### 2-2. ステップ1：Centers-to-Clusters（中心からクラスターへ）

各データポイントを、**最も近い中心に割り当て**します：

```python
def assign_to_nearest_center(points, centers):
    clusters = []
    for point in points:
        distances = [np.linalg.norm(point - center) for center in centers]
        nearest_center = np.argmin(distances)
        clusters.append(nearest_center)
    return clusters

# 実行
clusters = assign_to_nearest_center(points, centers)
print("各点の所属クラスター:", clusters)
```

**なぜ「最も近い中心」なのか？**

これは k-means の目的関数（二乗誤差歪み）を最小化するための合理的選択です。遠い中心に割り当てると、誤差が大きくなってしまいます。

### 2-3. ステップ2：Clusters-to-Centers（クラスターから中心へ）

各クラスターの**重心**を新しい中心にします：

```python
def update_centers(points, clusters, k):
    new_centers = []
    for i in range(k):
        cluster_points = points[np.array(clusters) == i]
        if len(cluster_points) > 0:
            centroid = np.mean(cluster_points, axis=0)
            new_centers.append(centroid)
        else:
            # 空のクラスターの場合
            new_centers.append(centers[i])
    return np.array(new_centers)

# 実行
new_centers = update_centers(points, clusters, 2)
print("新しい中心:", new_centers)
```

**なぜ重心なの？**

前回学んだ**重心定理**から：「クラスター内の全点との二乗距離和を最小化するのは重心」

これで誤差が確実に減少します！

## 📖 ステップ3：反復プロセスの実装

### 3-1. 完全な Lloyd アルゴリズム

```python
def lloyd_algorithm(points, k, max_iterations=100):
    """Lloyd アルゴリズムの完全実装"""

    # 初期化：ランダムに中心を選択
    n, d = points.shape
    centers = points[np.random.choice(n, k, replace=False)]

    history = []  # 収束過程を記録

    for iteration in range(max_iterations):
        # ステップ1：Points-to-Centers
        clusters = assign_to_nearest_center(points, centers)

        # ステップ2：Centers-to-Points
        new_centers = update_centers(points, clusters, k)

        # 収束判定
        if np.allclose(centers, new_centers):
            print(f"収束しました（{iteration}回目）")
            break

        centers = new_centers
        history.append((centers.copy(), clusters.copy()))

    return centers, clusters, history

# 実行例
final_centers, final_clusters, history = lloyd_algorithm(points, 2)
print("最終的な中心:", final_centers)
print("最終的なクラスタリング:", final_clusters)
```

### 3-2. 驚きの結果

たった数回の反復で、驚くほど良いクラスタリングが得られます！

```
初期中心: [[2, 1], [6, 7]]
→ 反復1回目: [[2.0, 2.0], [7.5, 8.5]]
→ 反復2回目: [[2.0, 2.0], [7.5, 8.5]]  # 収束！
```

## 📖 ステップ4：収束性の証明

### 4-1. なぜ Lloyd アルゴリズムは必ず収束するの？

**証明の核心アイデア：**
各ステップで目的関数（二乗誤差歪み）が単調減少する

```python
def compute_distortion(points, centers, clusters):
    """二乗誤差歪みを計算"""
    total_error = 0
    for i, point in enumerate(points):
        center = centers[clusters[i]]
        error = np.sum((point - center) ** 2)
        total_error += error
    return total_error
```

**ステップ1での改善：**

- 各点を最も近い中心に割り当て直す
- → 距離が減少（等しいか小さくなる）
- → 二乗誤差歪みが減少

**ステップ2での改善：**

- 重心定理により、重心は最適な中心位置
- → 二乗誤差歪みがさらに減少

**結論：** 毎回改善 + 下界あり → 必ず収束

### 4-2. でも、魔法にはトリックがある

#### 重要な注意：Lloyd アルゴリズムは局所最適に収束する

```python
# 実験：異なる初期値での結果比較
def experiment_different_starts():
    results = []
    for seed in range(10):
        np.random.seed(seed)
        centers, clusters, _ = lloyd_algorithm(points, 2)
        distortion = compute_distortion(points, centers, clusters)
        results.append((seed, distortion, centers))

    # 結果を表示
    for seed, dist, centers in sorted(results, key=lambda x: x[1]):
        print(f"初期値{seed}: 歪み={dist:.2f}, 中心={centers}")

experiment_different_starts()
```

**驚きの発見：**
初期値によって、異なる局所最適に収束することがあります！

## 📖 ステップ5：実際の生物学データでの応用

### 5-1. 酵母のジオキシックシフト遺伝子

前回学んだ酵母のジオキシックシフト。実は、すべての遺伝子が関与するわけではありません。

**データの整理：**

- 全酵母遺伝子：約6000個
- ジオキシックシフトで発現変化：約200-300個
- → この200個をクラスタリングしたい

```python
# 模擬データ：酵母遺伝子の発現パターン
# 7つの時点での発現レベル
gene_expressions = {
    'YAL001C': [0.5, 0.6, 2.1, 3.2, 2.8, 1.2, 0.7],  # グルコース枯渇で上昇
    'YAL002W': [2.1, 1.8, 0.8, 0.3, 0.4, 0.6, 1.9],  # グルコース枯渇で下降
    'YAL003W': [1.0, 0.9, 1.1, 0.8, 1.2, 1.0, 0.9],  # 変化なし
    # ... (実際は200個)
}

# k=6 クラスターでクラスタリング
gene_names = list(gene_expressions.keys())
expression_matrix = np.array(list(gene_expressions.values()))

centers, clusters, history = lloyd_algorithm(expression_matrix, 6)
```

### 5-2. 生物学的に意味のあるクラスタリング結果

```python
# 各クラスターの平均発現パターンを可視化
def plot_cluster_patterns(expression_matrix, clusters, k):
    time_points = ['T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6']

    plt.figure(figsize=(12, 8))
    for cluster_id in range(k):
        cluster_genes = expression_matrix[np.array(clusters) == cluster_id]
        if len(cluster_genes) > 0:
            avg_pattern = np.mean(cluster_genes, axis=0)
            plt.subplot(2, 3, cluster_id + 1)
            plt.plot(time_points, avg_pattern, 'b-o', linewidth=2)
            plt.title(f'クラスター {cluster_id + 1}')
            plt.ylabel('相対発現レベル')
            plt.xticks(rotation=45)

    plt.tight_layout()
    plt.show()

plot_cluster_patterns(expression_matrix, clusters, 6)
```

**驚きの発見：**

1. **上昇パターン**：グルコース枯渇で発現が上がる遺伝子群
   - 糖新生、グルコース合成酵素など

2. **下降パターン**：グルコース枯渇で発現が下がる遺伝子群
   - 解糖系酵素、グルコース輸送体など

3. **一時的上昇**：ストレス応答後、正常に戻る遺伝子群
   - ストレス応答タンパク質など

### 5-3. 生物学的解釈

これらのクラスタリング結果は、酵母の**代謝切り替え戦略**を明確に示しています：

```python
# 各クラスターの生物学的機能を分析
cluster_functions = {
    0: "グルコース輸送・解糖系（下降）",
    1: "糖新生・グルコース合成（上昇）",
    2: "エタノール代謝（後期上昇）",
    3: "ストレス応答（一時的上昇）",
    4: "リボソーム生合成（下降）",
    5: "ミトコンドリア呼吸（上昇）"
}

for cluster_id, function in cluster_functions.items():
    gene_count = sum(1 for c in clusters if c == cluster_id)
    print(f"クラスター {cluster_id}: {function} ({gene_count}個の遺伝子)")
```

まさに「データの中に生物学的真実が隠れている」ことを Lloyd アルゴリズムが明らかにしてくれました！

## 📖 ステップ6：Lloyd アルゴリズムの限界と対策

### 6-1. 局所最適問題への対策

```python
def multiple_runs_lloyd(points, k, num_runs=10):
    """複数回実行して最良の結果を選ぶ"""
    best_distortion = float('inf')
    best_result = None

    for run in range(num_runs):
        centers, clusters, history = lloyd_algorithm(points, k)
        distortion = compute_distortion(points, centers, clusters)

        if distortion < best_distortion:
            best_distortion = distortion
            best_result = (centers, clusters, distortion)

        print(f"Run {run}: 歪み = {distortion:.2f}")

    return best_result

# 実行
best_centers, best_clusters, best_distortion = multiple_runs_lloyd(points, 2, 10)
print(f"\n最良の結果: 歪み = {best_distortion:.2f}")
```

### 6-2. 初期化の改善：k-means++

```python
def kmeans_plus_plus_init(points, k):
    """k-means++ 初期化法"""
    n, d = points.shape
    centers = []

    # 最初の中心をランダムに選択
    centers.append(points[np.random.randint(n)])

    for _ in range(1, k):
        # 各点から最も近い中心までの距離を計算
        distances = []
        for point in points:
            min_dist = min([np.linalg.norm(point - center) for center in centers])
            distances.append(min_dist ** 2)

        # 距離の二乗に比例する確率で次の中心を選択
        probabilities = np.array(distances) / sum(distances)
        cumulative = np.cumsum(probabilities)
        r = np.random.random()
        next_center_idx = np.searchsorted(cumulative, r)
        centers.append(points[next_center_idx])

    return np.array(centers)

# 改良版 Lloyd アルゴリズム
def improved_lloyd_algorithm(points, k):
    # k-means++ 初期化を使用
    centers = kmeans_plus_plus_init(points, k)

    # 以下は通常の Lloyd アルゴリズムと同じ
    # ... (省略)

    return centers, clusters, history
```

## 📖 ステップ7：次なる挑戦 - ソフトクラスタリングへの道

### 7-1. ハードクラスタリングの限界

Lloyd アルゴリズムによる k-means は「ハードクラスタリング」です：

- 各点は**1つのクラスターにのみ所属**
- 境界付近の点も強制的にどちらかに割り当て

でも実際のデータでは：

```
遺伝子Aの発現パターン：[1.2, 1.8, 2.1, 1.9, 1.5, 1.3, 1.0]
遺伝子Bの発現パターン：[1.1, 1.9, 2.0, 1.8, 1.4, 1.2, 1.1]
```

この2つの遺伝子、どちらも似たようなパターンですが、異なるクラスターに分類されるかもしれません。

### 7-2. ソフトクラスタリングのアイデア

**新しいアイデア：**
各点が各クラスターに**所属する確率**を考える

```
遺伝子A:
- クラスター1に70%の確率で所属
- クラスター2に30%の確率で所属

遺伝子B:
- クラスター1に40%の確率で所属
- クラスター2に60%の確率で所属
```

これが「ソフトクラスタリング」の基本アイデアです！

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- Lloyd アルゴリズムは k-means クラスタリングの実用的解法
- 「中心→クラスター」「クラスター→中心」を交互に繰り返す
- 必ず収束するが、局所最適に陥る可能性がある

### レベル2：本質的理解（ここまで来たら素晴らしい）

- 各ステップで二乗誤差歪みが単調減少するから収束する
- 重心定理により、クラスターの重心が最適な中心位置
- 複数回実行や k-means++ 初期化で局所最適問題を軽減

### レベル3：応用的理解（プロレベル）

- 生物学データで意味のあるクラスタリングが得られる
- ソフトクラスタリングへの自然な拡張がある
- アルゴリズムの限界を理解し、適切な対策を講じられる

## 🔮 次回予告

次回は「**ソフトクラスタリングと期待値最大化（EM）アルゴリズム**」を学びます。

酵母遺伝子の例で見たように、現実の生物学的データでは「はっきりとしたクラスター境界」が存在しないことがあります。そこで登場するのが、確率的なクラスタリング手法です。

期待してお楽しみに！

---

_「データの中に隠された生物学的真実を、数学の力で明らかにする」_  
_— Lloyd アルゴリズムは、その第一歩を示してくれました —_
