# 大規模パーシモニーアルゴリズム（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**系統樹の「形」そのものを最適化して、最も進化を説明しやすい樹形を発見する方法をマスター**

でも、ちょっと待ってください。前回学んだ小パーシモニー問題では系統樹の形は与えられていたはず...今度は形も自分で見つけるの？
実は、これは**膨大な可能性の中から最適な答えを探す、計算機科学最難関クラスの問題**なんです！

## 🤔 ステップ0：なぜ大規模パーシモニーが必要なの？

### 0-1. そもそもの問題を考えてみよう

あなたは4種類の生物のDNA配列を持っています：

- ヒト
- チンパンジー
- アザラシ
- クジラ

これらをどう系統樹にまとめるのが最も自然でしょうか？

### 0-2. 驚きの事実

4種類の生物でも、可能な系統樹の形は**3通り**もあるんです！
10種類なら？なんと**3,400万通り以上**！
20種類なら？**2×10^20通り**（宇宙の星の数より多い！）

## 📖 ステップ1：小パーシモニー vs 大規模パーシモニー

### 1-1. まず素朴な疑問から

「小」と「大規模」って何が違うの？サイズの問題？

### 1-2. なぜそうなるのか

実は、扱う問題の「レベル」が違うんです：

```python
def compare_parsimony_problems():
    """
    小パーシモニーと大規模パーシモニーの違いを理解
    """
    print("小パーシモニー問題:")
    print("=" * 40)
    print("入力: 系統樹の形（トポロジー）+ 葉のデータ")
    print("出力: 内部ノードの最適な状態")
    print("難易度: 多項式時間で解ける（簡単）")

    print("\n大規模パーシモニー問題:")
    print("=" * 40)
    print("入力: 葉のデータのみ")
    print("出力: 最適な系統樹の形 + 内部ノードの状態")
    print("難易度: NP完全（超難しい！）")

    print("\n例えば4種の場合:")
    print("小パーシモニー: 1つの樹形を評価")
    print("大規模パーシモニー: 3つ全ての樹形を試す必要あり")

compare_parsimony_problems()
```

### 1-3. 具体例で確認

```python
def all_possible_trees_4_species():
    """
    4種の生物で可能な全ての系統樹
    """
    species = ["ヒト", "チンパンジー", "アザラシ", "クジラ"]

    print("可能な系統樹パターン:")
    print("=" * 40)

    print("\nパターン1: (ヒト,チンパンジー) vs (アザラシ,クジラ)")
    print("     ┌─ヒト")
    print("   ┌─┤")
    print("   │ └─チンパンジー")
    print("───┤")
    print("   │ ┌─アザラシ")
    print("   └─┤")
    print("     └─クジラ")
    print("パーシモニースコア: 11")

    print("\nパターン2: (ヒト,アザラシ) vs (チンパンジー,クジラ)")
    print("     ┌─ヒト")
    print("   ┌─┤")
    print("   │ └─アザラシ")
    print("───┤")
    print("   │ ┌─チンパンジー")
    print("   └─┤")
    print("     └─クジラ")
    print("パーシモニースコア: 11（偶然同じ！）")

    print("\nパターン3: (ヒト,クジラ) vs (チンパンジー,アザラシ)")
    print("     ┌─ヒト")
    print("   ┌─┤")
    print("   │ └─クジラ")
    print("───┤")
    print("   │ ┌─チンパンジー")
    print("   └─┤")
    print("     └─アザラシ")
    print("パーシモニースコア: 15（最悪）")

all_possible_trees_4_species()
```

### 1-4. ここがポイント

複数の樹形が同じスコアを持つことがある！これが系統樹推定を難しくする要因の一つです。

## 📖 ステップ2：系統樹の数が爆発的に増える理由

### 2-1. 数学的な恐怖

```python
def count_unrooted_trees(n):
    """
    n種の生物に対する無根系統樹の数を計算
    これがいかに恐ろしい数になるか実感しよう
    """
    import math

    if n < 3:
        return 1

    # 無根二分木の数の公式: (2n-5)!!
    # !! は二重階乗（1つ飛ばしの階乗）
    count = 1
    for i in range(3, n + 1):
        count *= (2 * i - 5)

    print(f"{n}種の生物の無根系統樹の数:")
    print("=" * 40)
    print(f"数式: (2×{n}-5)!! = ", end="")

    if n <= 6:
        factors = []
        for i in range(3, n + 1):
            factors.append(str(2 * i - 5))
        print(" × ".join(factors))
    else:
        print(f"とても大きな数...")

    print(f"合計: {count:,}通り")

    # 時間の見積もり
    if count > 1000000:
        seconds = count * 0.001  # 1つの樹を1ミリ秒で評価
        years = seconds / (365 * 24 * 3600)
        print(f"\n全て評価するのに必要な時間（1樹1ミリ秒）:")
        print(f"約{years:,.0f}年！")

    return count

# 実験してみよう
for n in [4, 5, 6, 10, 20]:
    count_unrooted_trees(n)
    print()
```

### 2-2. でも待って、なぜこの公式？

```python
def explain_tree_counting():
    """
    なぜ(2n-5)!!なのか、ステップバイステップで理解
    """
    print("系統樹の数の増え方を追跡:")
    print("=" * 40)

    print("\n3種: 1通り（これが基本）")
    print("  A")
    print(" / \\")
    print("B   C")

    print("\n4種: 3通り = 1 × 3")
    print("4種目Dをどこに追加する？3つのエッジのどれか")

    print("\n5種: 15通り = 3 × 5")
    print("5種目Eをどこに追加する？5つのエッジのどれか")

    print("\n6種: 105通り = 15 × 7")
    print("6種目Fをどこに追加する？7つのエッジのどれか")

    print("\nパターンが見えてきた！")
    print("n種: (n-1)種の数 × (2n-5)")
    print("これが(2n-5)!!の意味")

explain_tree_counting()
```

## 📖 ステップ3：なぜNP完全問題なの？

### 3-1. 魔法のような解法はない

```python
def why_np_complete():
    """
    大規模パーシモニーがNP完全である理由
    """
    print("NP完全問題の特徴:")
    print("=" * 40)

    print("\n1. 答えの検証は簡単")
    print("   → 与えられた樹のスコアは多項式時間で計算可能")

    print("\n2. 最適解を見つけるのは超困難")
    print("   → 全ての可能性を試す以外に確実な方法がない")

    print("\n3. 他のNP完全問題に変換可能")
    print("   → 巡回セールスマン問題などと同じ難しさ")

    print("\n現実的な意味:")
    print("• 10種程度: 全探索可能")
    print("• 20種程度: ヒューリスティックが必要")
    print("• 100種以上: 近似解で妥協")

why_np_complete()
```

## 📖 ステップ4：最近傍交換（NNI）- 天才的な発想

### 4-1. そもそも最近傍交換って何？

系統樹を「少しだけ」変形する操作です。まるで**ルービックキューブを1手だけ回す**ような感じ！

### 4-2. 内部エッジを中心に考える

```python
def visualize_nni():
    """
    最近傍交換（NNI）の仕組みを可視化
    """
    print("最近傍交換（Nearest Neighbor Interchange）")
    print("=" * 50)

    print("\n元の樹（内部エッジa-bに注目）:")
    print("     W   X")
    print("      \\ /")
    print("       a")
    print("       |")
    print("       |  ← この内部エッジ")
    print("       |")
    print("       b")
    print("      / \\")
    print("     Y   Z")

    print("\nこのエッジを中心に4つの部分木W,X,Y,Zを再配置")
    print("\n可能な3つの配置:")

    print("\n配置1（元の形）:")
    print("  (W,X) - (Y,Z)")

    print("\n配置2（NNI操作1）:")
    print("  (W,Y) - (X,Z)")
    print("  XとYを交換")

    print("\n配置3（NNI操作2）:")
    print("  (W,Z) - (X,Y)")
    print("  XとZを交換")

visualize_nni()
```

### 4-3. 具体例で理解を深める

```python
def nni_example():
    """
    実際の種でNNIを実演
    """
    print("実例：4種の生物でNNI")
    print("=" * 40)

    print("\n元の樹:")
    print("   ヒト    チンパンジー")
    print("     \\    /")
    print("      \\  /")
    print("       \\/")
    print("       /\\")
    print("      /  \\")
    print("     /    \\")
    print("  アザラシ  クジラ")

    print("\nNNI操作1: チンパンジーとアザラシを交換")
    print("   ヒト    アザラシ")
    print("     \\    /")
    print("      \\  /")
    print("       \\/")
    print("       /\\")
    print("      /  \\")
    print("     /    \\")
    print("チンパンジー クジラ")

    print("\nNNI操作2: チンパンジーとクジラを交換")
    print("   ヒト     クジラ")
    print("     \\     /")
    print("      \\   /")
    print("       \\ /")
    print("       / \\")
    print("      /   \\")
    print("     /     \\")
    print("チンパンジー アザラシ")

    print("\nポイント: 1つの内部エッジから2つの新しい樹が生成される！")

nni_example()
```

## 📖 ステップ5：貪欲ヒューリスティック - 現実的な解法

### 5-1. なぜ貪欲（Greedy）？

```python
def explain_greedy():
    """
    貪欲法の考え方
    まるで山登りのよう！
    """
    print("貪欲ヒューリスティックの哲学:")
    print("=" * 40)

    print("\n山登りのアナロジー:")
    print("1. 今いる場所から見える範囲を探索")
    print("2. より高い場所が見つかったら移動")
    print("3. どこを見ても高い場所がなければ頂上（局所最適）")

    print("\n系統樹の場合:")
    print("1. 現在の樹から全てのNNI操作を試す")
    print("2. よりスコアの良い樹が見つかったら移動")
    print("3. どのNNIも改善しなければ終了")

    print("\n⚠️ 注意: 局所最適に陥る可能性あり！")

explain_greedy()
```

### 5-2. アルゴリズムの実装

```python
def nni_heuristic_pseudocode():
    """
    最近傍交換ヒューリスティックの疑似コード
    """
    print("大規模パーシモニーの貪欲アルゴリズム:")
    print("=" * 50)

    code = '''
    def large_parsimony_nni(sequences):
        """
        NNIヒューリスティックによる大規模パーシモニー
        """
        # ステップ1: ランダムな初期樹を生成
        current_tree = generate_random_tree(sequences)
        current_score = small_parsimony(current_tree, sequences)

        improved = True
        iteration = 0

        while improved:
            iteration += 1
            improved = False
            best_tree = current_tree
            best_score = current_score

            # ステップ2: 全ての内部エッジでNNIを試す
            for edge in current_tree.internal_edges():
                # 各エッジで2つのNNI操作
                for neighbor in nni_neighbors(current_tree, edge):
                    score = small_parsimony(neighbor, sequences)

                    # より良い樹が見つかった？
                    if score < best_score:
                        best_tree = neighbor
                        best_score = score
                        improved = True

            # ステップ3: 改善があれば更新
            if improved:
                current_tree = best_tree
                current_score = best_score
                print(f"反復{iteration}: スコア改善 → {current_score}")
            else:
                print(f"局所最適に到達（スコア: {current_score}）")

        return current_tree, current_score
    '''

    print(code)

nni_heuristic_pseudocode()
```

## 📖 ステップ6：実装の詳細

### 6-1. NNI操作の実装

```python
def implement_nni():
    """
    NNI操作の具体的な実装
    エッジの周りで部分木を入れ替える
    """
    class TreeNode:
        def __init__(self, name=None):
            self.name = name
            self.children = []
            self.parent = None

    def perform_nni(tree, edge):
        """
        指定されたエッジでNNI操作を実行
        2つの新しい樹を返す
        """
        # エッジの両端のノード
        node_a, node_b = edge

        # 4つの部分木を特定
        subtrees_a = [child for child in node_a.children if child != node_b]
        subtrees_b = [child for child in node_b.children if child != node_a]

        W, X = subtrees_a[0], subtrees_a[1]
        Y, Z = subtrees_b[0], subtrees_b[1]

        # NNI操作1: XとYを交換
        tree1 = copy.deepcopy(tree)
        # 実装の詳細...

        # NNI操作2: XとZを交換
        tree2 = copy.deepcopy(tree)
        # 実装の詳細...

        return tree1, tree2

    print("NNI操作の実装ポイント:")
    print("1. 内部エッジを特定")
    print("2. 4つの部分木を識別")
    print("3. 2通りの交換を実行")
    print("4. 新しい樹を返す")

implement_nni()
```

### 6-2. 効率化のテクニック

```python
def optimization_tricks():
    """
    計算を高速化するテクニック
    """
    print("大規模パーシモニーの高速化:")
    print("=" * 40)

    print("\n1. スコアの差分計算")
    print("   全体を再計算せず、変更部分だけ更新")

    print("\n2. 並列処理")
    print("   複数のNNI操作を同時に評価")

    print("\n3. 早期終了")
    print("   改善が小さくなったら打ち切り")

    print("\n4. 賢い初期樹")
    print("   ランダムではなく、距離法などで初期樹を構築")

    print("\n5. タブーリスト")
    print("   最近訪れた樹を記憶し、ループを防ぐ")

optimization_tricks()
```

## 📖 ステップ7：局所最適の罠

### 7-1. 山登り法の限界

```python
def local_optimum_problem():
    """
    局所最適の問題を可視化
    """
    print("局所最適の罠:")
    print("=" * 40)

    print("\nスコアの地形（1次元で簡略化）:")
    print()
    print("スコア")
    print("  ↑")
    print("  │     真の最適解")
    print("  │         ↓")
    print("  │    ╱\\   ╱\\")
    print("  │   ╱  \\ ╱  \\")
    print("  │  ╱    V    \\  ← 局所最適（ここで止まる！）")
    print("  │ ╱            \\")
    print("  │╱              \\")
    print("  └─────────────────→ 樹の空間")
    print("        ↑")
    print("    開始地点")

    print("\n問題: NNIでは谷を越えられない！")
    print("解決策:")
    print("• 複数の開始点から試す")
    print("• より大きな変更を許す（SPR、TBRなど）")
    print("• シミュレーテッドアニーリング")
    print("• 遺伝的アルゴリズム")

local_optimum_problem()
```

## 📖 ステップ8：より高度な樹の再配置操作

### 8-1. SPRとTBR

```python
def advanced_rearrangements():
    """
    NNIより強力な再配置操作
    """
    print("樹の再配置操作の比較:")
    print("=" * 40)

    print("\n1. NNI (Nearest Neighbor Interchange)")
    print("   範囲: 隣接する部分木を交換")
    print("   1回で到達可能な樹: 2(n-3)個")

    print("\n2. SPR (Subtree Pruning and Regrafting)")
    print("   範囲: 部分木を切り取って別の場所に接ぎ木")
    print("   1回で到達可能な樹: 2(n-3)(2n-7)個")

    print("\n3. TBR (Tree Bisection and Reconnection)")
    print("   範囲: 樹を2つに分割して再結合")
    print("   1回で到達可能な樹: (2n-5)(n-3)個")

    print("\n探索能力: TBR > SPR > NNI")
    print("計算コスト: TBR > SPR > NNI")

    print("\n使い分け:")
    print("• 初期探索: NNI（高速）")
    print("• 精密化: SPR")
    print("• 最終調整: TBR")

advanced_rearrangements()
```

## 📖 ステップ9：実際の生物データへの応用

### 9-1. 実例：霊長類の系統

```python
def primate_phylogeny():
    """
    実際の霊長類データでの解析例
    """
    print("霊長類の系統解析:")
    print("=" * 40)

    primates = [
        "ヒト",
        "チンパンジー",
        "ゴリラ",
        "オランウータン",
        "テナガザル",
        "ニホンザル",
        "ヒヒ"
    ]

    print(f"種数: {len(primates)}")

    # 可能な樹の数を計算
    n = len(primates)
    num_trees = 1
    for i in range(3, n + 1):
        num_trees *= (2 * i - 5)

    print(f"可能な無根系統樹: {num_trees:,}通り")

    print("\nNNIヒューリスティックの実行:")
    print("反復1: スコア 1234 → 1198")
    print("反復2: スコア 1198 → 1156")
    print("反復3: スコア 1156 → 1142")
    print("反復4: スコア 1142 → 1142（収束）")

    print("\n最終的な系統樹:")
    print("              ┌─ヒト")
    print("          ┌───┤")
    print("      ┌───┤   └─チンパンジー")
    print("      │   └─────ゴリラ")
    print("  ────┤")
    print("      │   ┌─────オランウータン")
    print("      └───┤")
    print("          │ ┌───テナガザル")
    print("          └─┤")
    print("            │ ┌─ニホンザル")
    print("            └─┤")
    print("              └─ヒヒ")

primate_phylogeny()
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- 大規模パーシモニーは樹の形も探索する
- 可能な樹の数は爆発的に増加
- NNI操作で樹を少しずつ改良
- 貪欲法で実用的な解を見つける

### レベル2：本質的理解（ここまで来たら素晴らしい）

- NP完全問題で厳密解は現実的に不可能
- NNIは内部エッジ周りの部分木交換
- 局所最適に陥るリスクがある
- SPR、TBRなどより強力な操作も存在

### レベル3：応用的理解（プロレベル）

- 複数の開始点からの探索で局所最適を回避
- スコアの差分計算で高速化
- メタヒューリスティックスとの組み合わせ
- ブートストラップによる信頼性評価

## 🔍 練習問題

```python
def practice_exercises():
    """
    理解を深める練習問題
    """
    print("練習問題:")
    print("=" * 40)

    print("\n問題1: 5種の生物で可能な無根系統樹は何通り？")
    print("ヒント: (2n-5)!!を使う")

    print("\n問題2: 以下の樹でNNI操作を全て列挙せよ")
    print("    A   B")
    print("     \\ /")
    print("      X")
    print("      |")
    print("      Y")
    print("     / \\")
    print("    C   D")

    print("\n問題3: なぜ全探索が現実的でないか説明せよ")
    print("ヒント: 20種で1樹1ミクロ秒でも...")

practice_exercises()
```

## 🚀 次回予告

次回は「**最尤法による系統樹推定**」を学びます！

- 確率モデルを使った洗練されたアプローチ
- なぜパーシモニーより正確なのか
- 計算の高速化テクニック

驚くべきことに、DNAの変異には「偏り」があり、それを考慮することでより正確な系統樹が得られます。その秘密に迫ります！

## 参考文献

- Felsenstein, J. (2004). "Inferring Phylogenies" - 系統学のバイブル
- Swofford, D.L. et al. (1996). "Phylogenetic inference" - NNIの詳細
- Robinson, D.F. (1971). "Comparison of labeled trees" - SPR距離の定義
