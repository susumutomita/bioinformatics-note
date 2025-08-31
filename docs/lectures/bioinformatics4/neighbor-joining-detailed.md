---
sidebar_position: 7
title: 近隣結合法：全科学分野トップ20の魔法のアルゴリズム
---

# 近隣結合法：全科学分野トップ20の魔法のアルゴリズム（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**3万回以上引用された、進化速度の違いも考慮できる究極の系統樹構築アルゴリズムを完全マスターする**

でも、ちょっと待ってください。そもそもなぜこのアルゴリズムがそんなに引用されるの？
実は、1987年に発表されたこの方法は、非加法的な距離行列からも正確な系統樹を作れる「黒魔術」のような技術なんです！

## 🤔 ステップ0：なぜ近隣結合法が必要だったのか

### 0-1. これまでの方法の限界

```
加法的系統学：
✅ 加法的行列なら完璧
❌ 非加法的行列で完全失敗

UPGMA：
✅ 必ず木が作れる
❌ 進化速度の違いを無視
❌ 正確性に欠ける

私たちが欲しいもの：
両方の良いところ取り！
```

### 0-2. 驚きの事実

```
近隣結合法の論文（Saitou & Nei, 1987）は：
- 引用回数：30,000回以上！
- 全科学分野でトップ20に入る
- バイオインフォマティクスの基礎中の基礎

でも定理の証明は10年後（1997年）！
```

## 📖 ステップ1：最初の失敗から学ぼう

### 1-1. 素朴なアプローチの問題

```python
# 失敗例：最小距離のペアを選ぶ
def naive_approach(distance_matrix):
    """
    最小値を持つペアが近隣？
    → 残念！これは間違い
    """
    min_pair = find_minimum(distance_matrix)
    # jとkが最小でも、近隣とは限らない！
```

### 1-2. 具体例で確認

```
距離行列：
     i  j  k  l
i    0  3  4  3
j    3  0  1  5  ← j-k間が最小（1）
k    4  1  0  2
l    3  5  2  0

でも実際の系統樹では：
j と k は近隣じゃない！
```

## 🎪 ステップ2：魔法の変換 - 近隣結合行列D\*

### 2-1. なぜ変換が必要？

```
問題：距離が小さい ≠ 近隣
理由：他の種との関係を考慮していない

解決策：全体のバランスを見る！
→ これがD*の発想
```

### 2-2. 合計距離の計算

```python
def total_distance(matrix, i):
    """
    種iから他の全種への距離の合計
    「どれだけ離れた存在か」の指標
    """
    return sum(matrix[i][j] for j in range(n) if j != i)

# 例：kの合計距離
# k→i: 4
# k→j: 1
# k→l: 2
# 合計: 7
```

### 2-3. 魔法の式：D\*の計算

```python
def compute_neighbor_joining_matrix(D, n):
    """
    近隣結合行列D*を計算
    これが「黒魔術」と呼ばれる核心！
    """
    D_star = []

    for i in range(n):
        for j in range(i+1, n):
            # 魔法の式
            D_star[i][j] = (n - 2) * D[i][j] - total_dist[i] - total_dist[j]

    return D_star
```

### 2-4. 実際に計算してみよう

```
元の距離D(k,l) = 2
kの合計距離 = 7
lの合計距離 = 8
n = 4（種の数）

D*(k,l) = (4-2) × 2 - 7 - 8
        = 4 - 15
        = -11

負の値！？これが重要！
```

## 😮 ステップ3：近隣結合定理の威力

### 3-1. 驚くべき保証

```
近隣結合定理（1997年証明）：

D*の最小要素に対応するペアは
必ず近隣である！

つまり：
D*を計算 → 最小値を探す → 確実に近隣ペア発見！
```

### 3-2. なぜこれが「黒魔術」なのか

```python
# Burrows-Wheeler変換のような魔法
# 一見無関係な変換が、隠れた構造を露わにする

def find_neighbors(D):
    """
    魔法のステップ：
    1. 普通の距離行列D
    2. 謎の変換でD*を作る
    3. 最小値が必ず近隣！
    """
    D_star = compute_D_star(D)
    min_i, min_j = find_minimum(D_star)
    # min_iとmin_jは保証された近隣！
    return min_i, min_j
```

## 🔧 ステップ4：完全なアルゴリズム

### 4-1. デルタ値の計算

```python
def compute_delta(D, i, j, n):
    """
    iとjの「バランス」を計算
    どちらが中心に近いか？
    """
    delta = (total_distance[i] - total_distance[j]) / (n - 2)
    return delta

# 例：delta(i,j) = (13 - 12) / 2 = 0.5
# → iの方がわずかに外側
```

### 4-2. 改良された四肢長の計算

```python
def compute_limb_lengths(D, i, j, delta):
    """
    UPGMAとは違う、より正確な式
    非加法的行列でも良い結果
    """
    limb_i = D[i][j]/2 + delta
    limb_j = D[i][j]/2 - delta

    return limb_i, limb_j

# 加法的なら元の式と同じ結果
# 非加法的でもベストな近似！
```

### 4-3. 親ノードとの距離

```python
def update_distance_to_parent(D, i, j, k):
    """
    新しい親ノードmと他の種kとの距離
    これも魔法の式！
    """
    D[m][k] = (D[i][k] + D[j][k] - D[i][j]) / 2

    # これ、どこかで見た式...
    # そう！加法的系統学と同じ！
```

### 4-4. 完全な実装

```python
class NeighborJoining:
    def __init__(self, distance_matrix):
        self.D = distance_matrix
        self.n = len(distance_matrix)
        self.tree = {}

    def build_tree(self):
        """
        近隣結合法の完全実装
        """
        active_nodes = list(range(self.n))

        while len(active_nodes) > 2:
            # 1. D*を計算
            D_star = self.compute_D_star()

            # 2. 最小要素 = 保証された近隣
            i, j = self.find_minimum(D_star)

            # 3. デルタとリムレングスを計算
            delta = self.compute_delta(i, j)
            limb_i, limb_j = self.compute_limbs(i, j, delta)

            # 4. 親ノードを作成
            parent = self.create_parent(i, j, limb_i, limb_j)

            # 5. 距離行列を更新
            self.update_matrix(i, j, parent)

            # 6. アクティブノードを更新
            active_nodes.remove(i)
            active_nodes.remove(j)
            active_nodes.append(parent)

        # 最後の2ノードを接続
        self.connect_final_nodes(active_nodes)

        return self.tree

    def compute_D_star(self):
        """近隣結合行列の計算"""
        D_star = {}
        total_dist = [sum(self.D[i]) for i in range(self.n)]

        for i in range(self.n):
            for j in range(i+1, self.n):
                if i in self.active and j in self.active:
                    D_star[(i,j)] = (
                        (self.n - 2) * self.D[i][j]
                        - total_dist[i]
                        - total_dist[j]
                    )

        return D_star
```

## 🎯 ステップ5：UPGMAとの決定的な違い

### 5-1. 同じ非加法的行列での比較

```
元の距離行列（非加法的）：
     i  j  k  l
i    0  3  4  3
j    3  0  4  5
k    4  4  0  2
l    3  5  2  0

UPGMA の結果：
- 機械的に平均を取る
- ウルトラメトリック木（根から葉まで等距離）
- 実際の距離と大きくズレる

近隣結合法の結果：
- 全体のバランスを考慮
- 非ウルトラメトリック（現実的）
- より正確な近似
```

### 5-2. なぜ近隣結合法が優れているか

```python
# UPGMAの問題
def upgma_problem():
    """
    進化速度が一定と仮定
    → 現実と乖離
    """
    # ネズミは進化が速い
    # カメは進化が遅い
    # でもUPGMAは無視！

# 近隣結合法の利点
def neighbor_joining_advantage():
    """
    進化速度の違いを自動的に考慮
    → より現実的
    """
    # D*の計算で自然に補正される
```

## 🦠 ステップ6：実例 - コロナウイルスの系統解析

### 6-1. 2002-2003年SARS解析

```python
def analyze_sars_outbreak():
    """
    実際のSARS-CoVの系統解析
    """
    sequences = {
        'palm_civet': 'ATCG...',      # ヤシジャコウネコ
        'patient_1_guangdong': 'ATCG...', # 広東省患者1
        'patient_2_guangdong': 'ATCG...', # 広東省患者2
        'metropole_hotel_1': 'ATCG...',   # メトロポールホテル
        'toronto': 'ATCG...',          # トロント
        'singapore': 'ATCG...',        # シンガポール
        'vietnam': 'ATCG...',          # ベトナム
    }

    # ペアワイズアラインメントから距離行列
    D = compute_distance_matrix(sequences)

    # 近隣結合法で系統樹構築
    tree = NeighborJoining(D).build_tree()

    return tree
```

### 6-2. 感染経路の解明

```
構築された系統樹から判明したこと：

1. ヤシジャコウネコ → 中国南部住民（2002年末）
2. 地域内での感染拡大（2003年初頭）
3. メトロポールホテルが感染ハブに
4. ホテルから世界各地へ拡散

これが数学で感染経路を追跡する威力！
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- 近隣結合法は最も使われる系統樹構築法
- 魔法の行列D\*で近隣を確実に発見
- UPGMAより正確な結果

### レベル2：本質的理解（ここまで来たら素晴らしい）

- D\*は全体のバランスを考慮した距離指標
- 近隣結合定理が数学的保証を与える
- 非加法的行列でも良好な性能

### レベル3：応用的理解（プロレベル）

- O(n³)の計算量で実用的
- 進化速度の違いを自動補正
- 祖先配列は推定できない（距離情報のみ）

## 🚀 次回予告

さらに驚くべき事実が！距離ではなく配列そのものから系統樹を作る「**最大節約法**」と「**最尤法**」の世界へ。祖先の配列まで推定できる、究極の系統解析手法に迫ります！

## 🧬 生物学的な意味

### なぜ3万回も引用されるのか

```
1. 普遍的な適用性
   - DNA、タンパク質、形態データ
   - ウイルスから哺乳類まで

2. 計算効率と精度のバランス
   - 大規模データセット対応
   - リアルタイム系統追跡

3. 感染症対策への貢献
   - パンデミック解析
   - ワクチン開発支援
```

### 実用例：インフルエンザワクチン開発

```python
def select_vaccine_strain():
    """
    毎年のワクチン株選定
    """
    # 世界中のインフルエンザ株を収集
    global_strains = collect_flu_strains()

    # 近隣結合法で系統樹構築
    tree = NeighborJoining(global_strains).build()

    # 次シーズンの流行株を予測
    predicted_strain = predict_dominant_clade(tree)

    return predicted_strain
```

## 🎓 練習問題

### 問題1：D\*を手計算

```
距離行列：
     A  B  C  D
A    0  5  7  10
B    5  0  8  9
C    7  8  0  3
D    10 9  3  0

Q: D*(C,D)を計算せよ
```

### 問題2：実装課題

```python
def find_neighbors(distance_matrix):
    """
    与えられた距離行列から
    最初の近隣ペアを見つける
    """
    # あなたの実装
    pass
```

### 問題3：考察問題

```
Q: なぜ近隣結合定理の証明に10年かかったと思うか？
   D*の式のどこが「魔法的」なのか？
```

### 問題4：応用問題

```
Q: 近隣結合法の弱点は何か？
   どんな場合に他の手法を選ぶべきか？
```

---

_次回：「最大節約法と最尤法：配列から祖先を復元する究極の技術」でお会いしましょう！_
