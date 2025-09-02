# 小パーシモニーアルゴリズム（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**系統樹の形が決まっているとき、祖先のDNA配列を最も合理的に推定する動的プログラミング法をマスター**

でも、ちょっと待ってください。祖先の配列なんて、もう絶滅してしまって見ることができないはず...どうやって推定するの？
実は、これは**現在の生物のDNAから過去を読み解く、時間を遡る推理ゲーム**なんです！

## 🤔 ステップ0：なぜ小パーシモニーアルゴリズムが必要なの？

### 0-1. そもそもの問題を考えてみよう

想像してください。あなたの前に4種類の生物のDNA配列があります：

```
ヒト:        ACGT
チンパンジー: ACGT
ゴリラ:      TCGT
オランウータン: TCGA
```

これらの共通祖先はどんな配列を持っていたのでしょうか？

### 0-2. 驚きの事実

実は、**変異は稀なイベント**という進化の原理を使えば、最も可能性の高い祖先配列を数学的に導き出せるんです！

## 📖 ステップ1：パーシモニースコアという天才的な発想

### 1-1. まず素朴な疑問から

「パーシモニー（Parsimony）」って何？実は「節約」という意味なんです。

### 1-2. なぜそうなるのか

進化では**変異は最小限に抑えられる**という仮定。つまり、最も「節約的」な説明が最も可能性が高い！

### 1-3. 具体例で確認

```python
def calculate_parsimony_score():
    """
    パーシモニースコアの計算例
    エッジごとの変異数を合計
    """
    print("系統樹のパーシモニースコア計算:")
    print("=" * 40)

    # 簡単な例：1つの位置での塩基
    print("\n     祖先(?)")
    print("      /    \\")
    print("     /      \\")
    print("  内部1(?)  内部2(?)")
    print("   /  \\      /  \\")
    print("  A    C    T    G")
    print("  (種1)(種2)(種3)(種4)")

    print("\n仮に祖先を'C'と推定すると:")
    print("祖先(C) → 内部1(A): 1変異")
    print("祖先(C) → 内部2(T): 1変異")
    print("内部1(A) → 種1(A): 0変異")
    print("内部1(A) → 種2(C): 1変異")
    print("内部2(T) → 種3(T): 0変異")
    print("内部2(T) → 種4(G): 1変異")
    print("\n合計スコア: 4変異")

calculate_parsimony_score()
```

### 1-4. ここがポイント

パーシモニースコア = **系統樹の全エッジでの変異数の合計**

## 📖 ステップ2：小パーシモニー問題の定式化

### 2-1. 問題の正確な定義

```python
def small_parsimony_problem():
    """
    小パーシモニー問題の定義
    """
    print("小パーシモニー問題:")
    print("=" * 40)
    print("\n入力:")
    print("• 根付き二分木（形は固定）")
    print("• 葉ノードのDNA配列")

    print("\n出力:")
    print("• 内部ノードの最適な配列")
    print("• 最小パーシモニースコア")

    print("\n目標:")
    print("パーシモニースコアを最小化する祖先配列を見つける")

small_parsimony_problem()
```

### 2-2. でも待って、これって難しそう

そうなんです！全ての可能な祖先配列を試すと、指数関数的な計算量になってしまいます。

### 2-3. 魔法のような解法：動的プログラミング

でも実は、**各塩基位置を独立に処理できる**という性質を使えば、効率的に解けるんです！

## 📖 ステップ3：フィッチのアルゴリズム - 動的プログラミングの威力

### 3-1. 核心となるアイデア

```python
def fitch_algorithm_idea():
    """
    フィッチのアルゴリズムの核心
    """
    print("フィッチのアルゴリズムの天才的アイデア:")
    print("=" * 50)

    print("\n1. ボトムアップフェーズ（葉→根）")
    print("   各ノードで「どの塩基にしたら最小スコアか」を記録")

    print("\n2. トップダウンフェーズ（根→葉）")
    print("   最適な塩基を選びながら下っていく")

    print("\n重要な観察:")
    print("• 各位置（列）は独立に処理可能")
    print("• 部分問題の解を再利用（動的プログラミング）")

fitch_algorithm_idea()
```

### 3-2. スコア配列の定義

```python
def score_array_definition():
    """
    各ノードで管理するスコア配列
    """
    print("スコア配列 S_k(v):")
    print("=" * 40)
    print("ノードvに塩基kを割り当てたときの、")
    print("vを根とする部分木の最小パーシモニースコア")

    print("\n例：ノードvでのスコア配列")
    print("S_A(v) = 2  # Aを割り当てたら最小2変異")
    print("S_C(v) = 1  # Cを割り当てたら最小1変異 ← 最適！")
    print("S_G(v) = 3  # Gを割り当てたら最小3変異")
    print("S_T(v) = 2  # Tを割り当てたら最小2変異")

score_array_definition()
```

## 📖 ステップ4：再帰関係式 - アルゴリズムの心臓部

### 4-1. 美しい再帰式

```python
def recursion_formula():
    """
    動的プログラミングの再帰関係式
    """
    print("再帰関係式:")
    print("=" * 40)

    print("\n葉ノードvの場合:")
    print("S_k(v) = 0 if k = 葉の塩基")
    print("S_k(v) = ∞ otherwise")

    print("\n内部ノードvの場合:")
    print("S_k(v) = Σ[子ノードc] min_i[S_i(c) + δ(k,i)]")
    print("\nここで:")
    print("δ(k,i) = 0 if k = i （変異なし）")
    print("δ(k,i) = 1 if k ≠ i （変異あり）")

    print("\n直感的な意味:")
    print("「vにkを割り当てたときの最小スコア」は")
    print("「各子ノードでの最適選択」の合計")

recursion_formula()
```

### 4-2. 具体例で理解を深める

```python
def concrete_example():
    """
    具体的な計算例
    """
    print("具体例：2つの子ノードからスコアを計算")
    print("=" * 50)

    # 子ノード1のスコア
    child1_scores = {"A": 0, "C": float('inf'), "G": float('inf'), "T": float('inf')}
    # 子ノード2のスコア
    child2_scores = {"A": float('inf'), "C": 0, "G": float('inf'), "T": float('inf')}

    print("子ノード1: A固定（葉）")
    print(f"  スコア: {child1_scores}")
    print("\n子ノード2: C固定（葉）")
    print(f"  スコア: {child2_scores}")

    print("\n親ノードのスコア計算:")
    parent_scores = {}

    for parent_base in ["A", "C", "G", "T"]:
        score = 0

        # 子ノード1への最小コスト
        min_cost1 = float('inf')
        for child_base, child_score in child1_scores.items():
            cost = child_score + (0 if parent_base == child_base else 1)
            min_cost1 = min(min_cost1, cost)

        # 子ノード2への最小コスト
        min_cost2 = float('inf')
        for child_base, child_score in child2_scores.items():
            cost = child_score + (0 if parent_base == child_base else 1)
            min_cost2 = min(min_cost2, cost)

        parent_scores[parent_base] = min_cost1 + min_cost2

    for base, score in parent_scores.items():
        print(f"  S_{base}(親) = {score}")

    print("\n結論: AまたはCが最適（スコア1）")

concrete_example()
```

## 📖 ステップ5：完全な実装例

### 5-1. ボトムアップフェーズ

```python
def fitch_bottom_up():
    """
    フィッチアルゴリズムのボトムアップフェーズ
    """
    print("ボトムアップフェーズの実装:")
    print("=" * 40)

    class Node:
        def __init__(self, name, is_leaf=False, sequence=None):
            self.name = name
            self.is_leaf = is_leaf
            self.sequence = sequence
            self.children = []
            self.scores = {}  # 各塩基のスコア

    def compute_scores(node, position):
        """
        指定位置でのスコアを計算
        """
        if node.is_leaf:
            # 葉ノード：固定された塩基
            leaf_base = node.sequence[position]
            for base in "ACGT":
                if base == leaf_base:
                    node.scores[base] = 0
                else:
                    node.scores[base] = float('inf')
        else:
            # 内部ノード：子ノードから計算
            for base in "ACGT":
                score = 0
                for child in node.children:
                    # 再帰的に子のスコアを計算
                    compute_scores(child, position)

                    # この塩基を選んだときの最小コスト
                    min_cost = float('inf')
                    for child_base in "ACGT":
                        cost = child.scores[child_base]
                        if base != child_base:
                            cost += 1
                        min_cost = min(min_cost, cost)

                    score += min_cost

                node.scores[base] = score

    print("実装のポイント:")
    print("1. 葉から始めて上に向かって計算")
    print("2. 各ノードで4つのスコアを保持")
    print("3. 親のスコア = 子への最小コストの合計")

fitch_bottom_up()
```

### 5-2. トップダウンフェーズ（バックトラッキング）

```python
def fitch_top_down():
    """
    フィッチアルゴリズムのトップダウンフェーズ
    """
    print("トップダウンフェーズ（バックトラッキング）:")
    print("=" * 50)

    def backtrack(node, parent_base=None):
        """
        最適な塩基を選びながら下っていく
        """
        if node.is_leaf:
            return node.sequence

        if parent_base is None:
            # ルート：最小スコアの塩基を選択
            best_base = min(node.scores, key=node.scores.get)
        else:
            # 内部ノード：親との関係を考慮
            best_base = None
            best_score = float('inf')

            for base in "ACGT":
                # このノードでbaseを選んだときのコスト
                cost = node.scores[base]
                if parent_base != base:
                    cost += 1

                if cost < best_score:
                    best_score = cost
                    best_base = base

        # 選択した塩基を記録
        node.selected_base = best_base

        # 子ノードに対して再帰
        for child in node.children:
            backtrack(child, best_base)

    print("バックトラッキングのポイント:")
    print("1. ルートで最適な塩基を選択")
    print("2. 親の選択を考慮して子の塩基を決定")
    print("3. タイブレーク時は任意に選択可能")

fitch_top_down()
```

## 📖 ステップ6：実例で完全理解

### 6-1. ステップバイステップの実行例

```python
def complete_example():
    """
    4種の生物での完全な実行例
    """
    print("完全な実行例：1つの塩基位置")
    print("=" * 50)

    print("\n系統樹構造:")
    print("        root")
    print("       /    \\")
    print("    int1     int2")
    print("    /  \\     /  \\")
    print("   C    C   T    T")
    print(" (sp1)(sp2)(sp3)(sp4)")

    print("\n=== ボトムアップフェーズ ===")

    print("\n葉ノード（固定）:")
    print("sp1: {A:∞, C:0, G:∞, T:∞}")
    print("sp2: {A:∞, C:0, G:∞, T:∞}")
    print("sp3: {A:∞, C:∞, G:∞, T:0}")
    print("sp4: {A:∞, C:∞, G:∞, T:0}")

    print("\n内部ノードint1の計算:")
    print("子はC,C → 最適はC（スコア0）")
    print("int1: {A:2, C:0, G:2, T:2}")

    print("\n内部ノードint2の計算:")
    print("子はT,T → 最適はT（スコア0）")
    print("int2: {A:2, C:2, G:2, T:0}")

    print("\nルートノードの計算:")
    print("子の最適はC,T → AまたはGが最適（スコア2）")
    print("root: {A:2, C:1, G:2, T:1}")

    print("\n最小パーシモニースコア: 1")

    print("\n=== トップダウンフェーズ ===")
    print("root: CまたはTを選択（スコア1）")
    print("→ Cを選んだ場合:")
    print("  int1: C（変異なし）")
    print("  int2: T（1変異）")

complete_example()
```

## 📖 ステップ7：複数列への拡張

### 7-1. 独立性の活用

```python
def multiple_columns():
    """
    複数の塩基位置を処理
    """
    print("複数列の処理:")
    print("=" * 40)

    sequences = {
        "ヒト":     "ACGT",
        "チンパンジー": "ACGT",
        "ゴリラ":    "TCGT",
        "オランウータン": "TCGA"
    }

    print("重要な性質：各列は独立！")
    print("\n各列のスコア:")
    print("列1 (A,A,T,T): スコア1")
    print("列2 (C,C,C,C): スコア0")
    print("列3 (G,G,G,G): スコア0")
    print("列4 (T,T,T,A): スコア1")

    print("\n全体のパーシモニースコア: 1+0+0+1 = 2")

    print("\n計算量:")
    print("• 1列あたり: O(nk²) [n:ノード数, k:アルファベットサイズ]")
    print("• m列全体: O(mnk²)")

multiple_columns()
```

## 📖 ステップ8：無根系統樹への応用

### 8-1. 根の位置は関係ない

```python
def unrooted_tree_parsimony():
    """
    無根系統樹でのパーシモニー
    """
    print("無根系統樹での小パーシモニー:")
    print("=" * 40)

    print("\n驚きの事実:")
    print("どこに根を置いても、最小パーシモニースコアは同じ！")

    print("\n理由:")
    print("• パーシモニースコア = 全エッジの変異数の合計")
    print("• 根の位置を変えてもエッジは変わらない")
    print("• したがってスコアも変わらない")

    print("\n実用的な手順:")
    print("1. 任意の内部エッジに根を追加")
    print("2. 根付き木として小パーシモニーを解く")
    print("3. 根を削除して無根木に戻す")

unrooted_tree_parsimony()
```

## 📖 ステップ9：コロナウイルスへの応用

### 9-1. 実際のウイルス解析

```python
def coronavirus_application():
    """
    コロナウイルスの祖先配列推定
    """
    print("COVID-19変異株の祖先推定:")
    print("=" * 40)

    print("\n実際の応用例:")
    print("• 武漢株、アルファ株、デルタ株、オミクロン株")
    print("• 29,903塩基のゲノム配列")

    print("\n小パーシモニーで分かること:")
    print("1. 各変異株の共通祖先の配列")
    print("2. どの位置でいつ変異が起きたか")
    print("3. 変異のホットスポット")

    print("\n例：スパイクタンパク質のN501Y変異")
    print("• 複数の系統で独立に出現")
    print("• 祖先配列ではN（アスパラギン）")
    print("• 感染力増強に関与")

coronavirus_application()
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- 小パーシモニーは系統樹の形が決まっているときの問題
- パーシモニースコア = 全エッジの変異数の合計
- 動的プログラミングで効率的に解ける
- 各塩基位置は独立に処理可能

### レベル2：本質的理解（ここまで来たら素晴らしい）

- フィッチのアルゴリズムは2フェーズ（ボトムアップ＋トップダウン）
- 各ノードで塩基ごとのスコア配列を管理
- 再帰関係式で部分問題を解決
- 無根系統樹でも同じ手法が使える

### レベル3：応用的理解（プロレベル）

- 重み付きパーシモニーへの拡張
- 曖昧塩基（N等）の扱い
- ギャップの考慮
- ブートストラップによる信頼性評価

## 🔍 練習問題

```python
def practice_problems():
    """
    理解を深める練習問題
    """
    print("練習問題:")
    print("=" * 40)

    print("\n問題1: 以下の樹で最小パーシモニースコアを計算せよ")
    print("      ?")
    print("     / \\")
    print("    ?   ?")
    print("   / \\ / \\")
    print("  A  T G  C")

    print("\n問題2: なぜ各列を独立に処理できるのか説明せよ")

    print("\n問題3: 計算量O(mnk²)を導出せよ")
    print("ヒント: n個のノード、m列、kサイズのアルファベット")

practice_problems()
```

## 🚀 次回予告

次回は「**大規模パーシモニー問題**」を学びます！

- 系統樹の形も同時に最適化
- NP完全問題への挑戦
- NNI操作による探索

今回は樹の形が決まっていましたが、次回はその形自体を見つける、さらに難しい問題に挑戦します！

## 参考文献

- Fitch, W.M. (1971). "Toward defining the course of evolution: Minimum change for a specific tree topology"
- Sankoff, D. (1975). "Minimal mutation trees of sequences" - 重み付きパーシモニー
- Hartigan, J.A. (1973). "Minimum mutation fits to a given tree"
