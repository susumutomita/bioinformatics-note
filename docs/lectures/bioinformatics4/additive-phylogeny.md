---
sidebar_position: 5
title: 加法系統樹：完璧な進化の木を構築する究極アルゴリズム
---

# 加法系統樹：完璧な進化の木を構築する究極アルゴリズム（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**どんな加法距離行列からも、数学的に完璧な進化系統樹を構築できる「AdditivePhylogeny」という究極のアルゴリズムをマスターする**

でも、ちょっと待ってください。前回のアルゴリズムはうまくいかなかったのに、今度は本当に大丈夫？
実は、「四肢の長さ」という天才的なアイデアで、すべての問題が解決するんです！

## 😱 ステップ0：前回の失敗から学ぶ

### 0-1. 衝撃の真実

```
前回の仮定：
「距離行列の最小値 = 隣人」

でも...
     A  B  C  D
A    0  13  21  22
B    13  0  12  13
C    21  12  0  13
D    22  13  13  0

最小値：12（B-C）
```

### 0-2. 実際の木を見ると

```
真実の木：
      内部
     / 5  \ 8
    A      内部
          / 4  \ 4
         B      内部
               / 4  \ 5
              C      D

BとCは隣人じゃない！
```

### 0-3. なぜ失敗した？

```
教訓：
「見た目の近さ」≠「進化的な近さ」

例：
イルカとサメ
→ 見た目は似ている（流線形）
→ でも進化的には遠い！
```

## 🦵 ステップ1：「四肢の長さ」という天才的発想

### 1-1. 四肢（Limb）とは？

```
定義：
葉から最初の分岐点までの枝

イメージ：
    分岐点
      ↑
      ｜← これが四肢！
      ↓
     葉（現存種）
```

### 1-2. 四肢の長さの定理

```python
def limb_length(i, distance_matrix):
    """葉iの四肢の長さを計算する魔法の公式"""

    n = len(distance_matrix)
    min_length = float('inf')

    # すべてのj, kの組み合わせで計算
    for j in range(n):
        if j == i: continue
        for k in range(n):
            if k == i or k == j: continue

            # 魔法の公式！
            length = (distance_matrix[i][j] +
                     distance_matrix[i][k] -
                     distance_matrix[j][k]) / 2

            min_length = min(min_length, length)

    return min_length
```

### 1-3. なぜこれが正しい？

```
直感的理解：

i → j の距離 = 四肢_i + (内部経路) + 四肢_j
i → k の距離 = 四肢_i + (内部経路) + 四肢_k
j → k の距離 = 四肢_j + (内部経路) + 四肢_k

これらを組み合わせると...
四肢_i が求まる！
```

## 🎨 ステップ2：実例で理解する

### 2-1. チンパンジーの四肢の長さ

```
距離行列（前回の例）：
       チンパンジー  人間  アザラシ  クジラ
チンパンジー  0      3     6       5
人間         3      0     7       6
アザラシ      6      7     0       2
クジラ        5      6     2       0

計算：
j=人間, k=アザラシ: (3+6-7)/2 = 1
j=人間, k=クジラ: (3+5-6)/2 = 1
j=アザラシ, k=クジラ: (6+5-2)/2 = 4.5

最小値 = 1！
```

### 2-2. 四肢の長さの意味

```
チンパンジーの四肢の長さ = 1

つまり：
    親ノード
      ↑
      ｜1
      ↓
   チンパンジー

最初の分岐まで距離1！
```

## 🔄 ステップ3：AdditivePhylogenyアルゴリズム

### 3-1. アルゴリズムの概要

```python
def additive_phylogeny(distance_matrix, labels):
    """加法系統樹を構築する究極のアルゴリズム"""

    # ベースケース：2つの葉だけ
    if len(labels) == 2:
        return simple_tree(labels[0], labels[1],
                         distance_matrix[0][1])

    # 1. 任意の葉を選ぶ（例：最後の葉）
    target_leaf = labels[-1]

    # 2. その葉の四肢の長さを計算
    limb_len = limb_length(-1, distance_matrix)

    # 3. "ハゲ"行列を作る（四肢を削る）
    bald_matrix = make_bald(distance_matrix, -1, limb_len)

    # 4. ターゲットの葉を除いて再帰
    trimmed_matrix = remove_leaf(bald_matrix, -1)
    trimmed_labels = labels[:-1]

    # 5. 小さい問題を解く（再帰！）
    subtree = additive_phylogeny(trimmed_matrix, trimmed_labels)

    # 6. ターゲットの葉を適切な位置に追加
    attachment_point = find_attachment(bald_matrix, subtree)
    add_leaf(subtree, target_leaf, attachment_point, limb_len)

    return subtree
```

### 3-2. "ハゲ"行列の作成

```python
def make_bald(distance_matrix, leaf_index, limb_length):
    """四肢を削って"ハゲ"にする"""

    bald = copy.deepcopy(distance_matrix)
    n = len(distance_matrix)

    # 該当する行と列から四肢の長さを引く
    for i in range(n):
        if i != leaf_index:
            bald[leaf_index][i] -= limb_length
            bald[i][leaf_index] -= limb_length

    return bald
```

### 3-3. なぜ"ハゲ"にする？

```
イメージ：

元の木：              ハゲの木：
    親                  親
     ↑                  ↑
     ｜2                ｜0（葉が親に重なる）
     ↓                  ↓
    葉                  葉

四肢を削ることで
葉を親ノードまで引き上げる！
```

## 🎯 ステップ4：アタッチメントポイントの発見

### 4-1. 魔法の等式

```
ハゲ行列で四肢の長さ = 0

すると：
d_bald(i,j) + d_bald(j,k) = d_bald(i,k)

これは何を意味する？
→ jはiからkへの経路上にある！
```

### 4-2. 具体的な位置の特定

```python
def find_attachment(bald_matrix, tree, target_leaf):
    """葉を追加すべき正確な位置を見つける"""

    # 魔法の等式を満たすi, kを探す
    for i in tree.leaves:
        for k in tree.leaves:
            if i == k: continue

            # 等式チェック
            if (bald_matrix[target][i] +
                bald_matrix[i][k] ==
                bald_matrix[target][k]):

                # i→kの経路上で、iから
                # bald_matrix[target][i]の距離
                return find_point_on_path(tree, i, k,
                                        bald_matrix[target][i])
```

### 4-3. エッジ上 vs ノード上

```
2つのケース：

1. エッジ上に追加：
   A ---x--- B
       ↓
   新しい葉

2. 既存ノードに追加：
      ノード
       ↓
   新しい葉
```

## 🧪 ステップ5：完全な例題

### 5-1. 4×4行列を解く

```
距離行列：
     A  B  C  D
A    0  13  21  22
B    13  0  12  13
C    21  12  0  13
D    22  13  13  0

ステップ1：Dの四肢の長さ = 5
ステップ2：ハゲ行列を作成
ステップ3：Dを除いて再帰
...
```

### 5-2. 再帰の展開

```python
# 実行トレース
additive_phylogeny([A,B,C,D])
  → limb_length(D) = 5
  → additive_phylogeny([A,B,C])
      → limb_length(C) = 4
      → additive_phylogeny([A,B])
          → 基本ケース：A-B (距離13)
      ← Cを追加
  ← Dを追加
完成！
```

## 🦠 ステップ6：SARSの起源を突き止める

### 6-1. 実際のコロナウイルスデータ

```
問題：
実際の距離行列は非加法的！
（ノイズ、測定誤差、進化の複雑さ）

解決策：
少し調整して加法的に近づける
```

### 6-2. 衝撃の発見

```
調整後の距離行列で計算：

       人間  ハクビシン  コウモリ
人間    0      8        15
ハクビシン 8      0        12
コウモリ  15     12        0

結果：
ハクビシンが人間に最も近い！
```

### 6-3. ハクビシンの正体

```
ハクビシン（Palm Civet）：
- 中国南部に生息
- 食用として市場で売買
- SARS感染の中間宿主

感染経路：
コウモリ → ハクビシン → 人間

おまけ：
「コピ・ルアク」（猫糞コーヒー）
の原料を作る動物でもある！
```

## 🚀 ステップ7：アルゴリズムの分析

### 7-1. 計算量

```
時間計算量：O(n³)

理由：
- n回の再帰呼び出し
- 各呼び出しでO(n²)の四肢計算
- 合計：O(n³)

空間計算量：O(n²)
（距離行列のサイズ）
```

### 7-2. 加法的 vs 非加法的

```python
def is_additive(distance_matrix):
    """行列が加法的かチェック"""

    # 4点条件をチェック
    # すべての4つ組で検証

    if all_four_point_conditions_hold():
        return True  # AdditivePhylogenyが使える！
    else:
        return False  # 近似が必要
```

## 📚 まとめ：3つの理解レベル

### レベル1：表面的理解（これだけでもOK）

```
- 四肢の長さを計算
- 葉を一つずつ削って再帰
- 適切な位置に葉を追加
```

### レベル2：本質的理解（ここまで来たら素晴らしい）

```
- 四肢の長さ定理の数学的根拠
- ハゲ行列の役割と意味
- アタッチメントポイントの特定方法
```

### レベル3：応用的理解（プロレベル）

```
- 非加法行列への対処法
- 近似アルゴリズムの設計
- 実データへの適用と解釈
```

## 🎬 次回予告：UPGMA法

次回は「UPGMA法」。

非加法的な行列でも使える、
より実用的なアルゴリズムを学びます！

```python
# 予告編
def next_algorithm():
    """次回のアルゴリズム"""
    print("平均距離でクラスタリング")
    print("分子時計仮説")
    print("現実のデータに強い！")
    return "お楽しみに"
```

---

_完璧な進化の木を数学的に構築する、あなたも系統樹の達人になる準備はできましたか？_
