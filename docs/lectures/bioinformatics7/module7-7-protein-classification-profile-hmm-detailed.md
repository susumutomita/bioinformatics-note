# プロファイルHMMによるタンパク質の分類（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**プロファイルHMMを使って、未知のタンパク質が「家族」に属するか判定する方法を完全マスター**

でも、ちょっと待ってください。前回作ったプロファイルHMM、どうやって実際に使うの？
実は、これから学ぶビタビグラフという「判定装置」を使って、タンパク質の「家族証明書」を発行できるんです。

## 🤔 ステップ0：なぜこの分類が革命的なのか

### 0-1. そもそもの問題を考えてみよう

想像してください。新しく発見されたタンパク質があります。
このタンパク質の機能を知りたい！でも、実験には数ヶ月かかる...

```python
def traditional_approach():
    """
    従来の方法：一つずつ実験
    """
    new_protein = "ACDEFGHIKLMNPQRSTV"

    # 数ヶ月の実験...
    # 数百万円のコスト...
    # それでも機能がわからないかも...

    return "機能不明"  # よくある結果😢
```

### 0-2. 驚きの解決策

**プロファイルHMMを使えば、数秒で判定可能！**

```python
def hmm_approach():
    """
    HMMの方法：既知の家族と比較
    """
    new_protein = "ACDEFGHIKLMNPQRSTV"

    # 既知の家族のプロファイルHMMと比較
    probability = profile_hmm.evaluate(new_protein)

    if probability > threshold:
        return "キナーゼファミリー！酵素活性があります"

    # たった数秒で機能予測完了！
```

## 📖 ステップ1：判定の基本戦略

### 1-1. まず素朴な疑問から

「プロファイルHMMがあるとして、どうやって新しいタンパク質を判定するの？」

答え：**ビタビアルゴリズムで「最適な通り道」を見つける！**

```python
def classification_strategy():
    """
    分類の3ステップ戦略
    """

    # ステップ1: プロファイルHMMを準備（前回作った）
    profile_hmm = build_from_family_alignment()

    # ステップ2: 新しいタンパク質の最適経路を探す
    best_path = viterbi_algorithm(new_protein, profile_hmm)

    # ステップ3: その経路の確率で判定
    path_probability = calculate_probability(best_path)

    if path_probability > threshold:
        print("🎉 家族の一員です！")
    else:
        print("👤 この家族ではないようです")
```

### 1-2. ここがポイント

**確率の閾値**が判定の鍵！

```python
def threshold_meaning():
    """
    閾値の意味を理解しよう
    """

    # 高い確率 = このHMMをスムーズに通過できる
    # = 家族の特徴をよく持っている

    probabilities = {
        "完全一致のメンバー": 0.95,
        "典型的なメンバー": 0.70,
        "境界線上": 0.50,  # <- 閾値をここに設定？
        "違う家族": 0.10
    }

    return "閾値の設定が分類の精度を決める！"
```

## 📖 ステップ2：ビタビグラフの謎

### 2-1. 最初の試み（でも問題あり）

「ビタビグラフを作ろう！列の数は...えっと...」

```python
def naive_viterbi_graph():
    """
    素朴なアプローチ：訪問した状態の数だけ列を作る？
    """

    # 問題：事前に何個の状態を訪問するかわからない！

    protein = "ACDEFG"
    # この配列が何個の削除状態を通るか予測できない
    # → グラフのサイズが決められない！

    print("これでは実装できない...")
```

### 2-2. なぜ列数が問題なのか

ここで重要な観察をしてみましょう：

```python
def column_count_problem():
    """
    列数の問題を具体例で理解
    """

    # ケース1: 削除なし
    path1 = ["S", "M1", "M2", "M3", "E"]
    protein1 = "ABC"  # 3文字 = 3列必要

    # ケース2: 削除あり
    path2 = ["S", "M1", "D2", "M3", "E"]  # D2は削除状態
    protein2 = "AC"  # 2文字だけど、4状態を通る！

    print("文字数と状態数が一致しない！")
    print("これが混乱の原因")
```

## 📖 ステップ3：サイレント状態という天才的発想

### 3-1. サイレント状態って何？

「でも待って、削除状態は何も出力しない...」

```python
def silent_states_concept():
    """
    サイレント状態の概念
    """

    states = {
        "マッチ状態M": "文字を出力する（音を出す）",
        "挿入状態I": "文字を出力する（音を出す）",
        "削除状態D": "何も出力しない（沈黙）"  # ← サイレント！
    }

    print("削除状態は『沈黙の部屋』")
    print("通過するけど、何も生まない")
```

### 3-2. ここで天才的な解決策

**列数 = 出力される文字数**にすればいい！

```python
def correct_column_count():
    """
    正しい列数の決め方
    """

    protein = "ACDEFG"  # 6文字

    # ビタビグラフの列数 = 6（文字数と同じ）
    # 削除状態への遷移は「縦のエッジ」で表現！

    graph_structure = {
        "列数": len(protein),
        "行数": "HMMの全状態数",
        "削除状態への遷移": "同じ列内の垂直エッジ"
    }

    print("これで明確にグラフが定義できる！")
```

## 📖 ステップ4：垂直エッジの魔法

### 4-1. 垂直エッジとは？

```python
def vertical_edge_magic():
    """
    垂直エッジの仕組み
    """

    # 通常のエッジ：次の列へ（文字を消費）
    normal_edge = {
        "from": ("M1", "列2"),
        "to": ("M2", "列3"),
        "effect": "文字'C'を消費"
    }

    # 垂直エッジ：同じ列内（文字を消費しない）
    vertical_edge = {
        "from": ("M1", "列2"),
        "to": ("D2", "列2"),  # 同じ列！
        "effect": "文字を消費せず、状態だけ変更"
    }

    print("垂直エッジ = サイレント状態への近道")
```

### 4-2. 実際のビタビグラフ

```python
def build_viterbi_graph():
    """
    実際のビタビグラフ構築
    """

    protein = "ACF"

    # グラフの構造
    graph = {
        "列0": ["S"],  # 開始（ゼロ列）
        "列1": ["M1", "I0", "D1"],  # 'A'の処理
        "列2": ["M2", "I1", "D2"],  # 'C'の処理
        "列3": ["M3", "I2", "D3"],  # 'F'の処理
        "列4": ["E"]   # 終了（ゼロ列）
    }

    # 垂直エッジの例
    vertical_edges = [
        ("M1@列1", "D2@列1"),  # M1からD2へ（同じ列）
        ("D2@列1", "D3@列1"),  # D2からD3へ（連続削除）
    ]

    return graph
```

## 📖 ステップ5：ゼロ列という特別な存在

### 5-1. ゼロ列って何？

```python
def zero_column_concept():
    """
    ゼロ列の概念
    """

    # ゼロ列 = サイレント状態だけを含む特別な列

    zero_columns = {
        "開始列": {
            "位置": "最初",
            "状態": ["S"],  # 開始状態のみ
            "役割": "HMMのスタート地点"
        },
        "終了列": {
            "位置": "最後",
            "状態": ["E"],  # 終了状態のみ
            "役割": "HMMのゴール地点"
        }
    }

    print("ゼロ列は『準備』と『片付け』の場所")
```

### 5-2. 完全なビタビグラフの構造

```python
def complete_viterbi_graph():
    """
    完全なビタビグラフ
    """

    protein = "AC"

    # 完全な構造（ゼロ列を含む）
    complete_graph = """
    列0    列1     列2     列3
    [S] -> [M1] -> [M2] -> [E]
           [I0]    [I1]
           [D1] -> [D2]

    文字:    A       C
    """

    # 重要：列数 = 文字数 + 2（開始と終了のゼロ列）
    total_columns = len(protein) + 2

    print(f"総列数: {total_columns}")
    print("うち、ゼロ列: 2")
    print(f"文字処理列: {len(protein)}")
```

## 📖 ステップ6：アライメント問題への帰着

### 6-1. プロファイルアライメント問題の定式化

```python
def profile_alignment_problem():
    """
    プロファイルアライメント問題
    """

    # 入力
    inputs = {
        "マルチプルアライメント": "家族の配列",
        "新しい配列": "分類したいタンパク質",
        "θ（シータ）": "挿入列の閾値",
        "σ（シグマ）": "擬似カウント"
    }

    # 処理
    process = """
    1. マルチプルアライメント → プロファイルHMM
    2. プロファイルHMM + 新配列 → ビタビアルゴリズム
    3. 最適パス → 確率計算 → 判定
    """

    # 出力
    output = {
        "最適パス": "HMMを通る最も確率の高い経路",
        "アライメント": "家族配列との対応関係"
    }

    return output
```

### 6-2. 実際の計算例

```python
def viterbi_calculation_example():
    """
    ビタビアルゴリズムの実際の計算
    """

    # 新しいタンパク質
    new_protein = "ACF"

    # 動的計画法のテーブル
    viterbi_table = {}

    # 初期化
    viterbi_table[("S", 0)] = 1.0  # 開始確率

    # 再帰的計算
    for col in range(1, len(new_protein) + 1):
        char = new_protein[col - 1]

        for state in ["M", "I", "D"]:
            # 前の状態からの最大確率を計算
            max_prob = 0
            for prev_state in ["M", "I", "D"]:
                trans_prob = transition[prev_state][state]
                emit_prob = emission[state][char] if state != "D" else 1
                prev_prob = viterbi_table[(prev_state, col-1)]

                prob = prev_prob * trans_prob * emit_prob
                if prob > max_prob:
                    max_prob = prob

            viterbi_table[(state, col)] = max_prob

    return viterbi_table
```

## 📖 ステップ7：従来手法との決定的な違い

### 7-1. 「時間を無駄にした？」という疑問

ここで重要な疑問が生じます：

```python
def comparison_with_traditional():
    """
    従来のアライメント vs HMMアライメント
    """

    # 見た目は似ている...
    traditional_dp = """
    score[i][j] = max(
        score[i-1][j-1] + match,
        score[i-1][j] + gap,
        score[i][j-1] + gap
    )
    """

    hmm_viterbi = """
    prob[state][j] = max(
        prob[prev_state][j-1] * transition * emission
    )
    """

    print("形式は似ている...")
    print("でも、決定的な違いがある！")
```

### 7-2. HMMの真の力

**位置特異的なスコアリング**こそがHMMの強み！

```python
def hmm_true_power():
    """
    HMMの真の力：文脈を理解する
    """

    # 従来法：どの位置でも同じスコア
    traditional = {
        "A→C": 2,  # どこでも同じ
        "A→D": 1,  # どこでも同じ
    }

    # HMM：位置ごとに異なるスコア
    hmm_scoring = {
        "位置1": {"A→C": 0.9, "A→D": 0.1},  # 位置1ではCが好まれる
        "位置2": {"A→C": 0.2, "A→D": 0.8},  # 位置2ではDが好まれる
        "位置3": {"A→C": 0.5, "A→D": 0.5},  # 位置3では中立
    }

    print("HMMは『文脈』を理解している！")
    print("これが微妙な類似性を検出できる理由")
```

## 📖 ステップ8：実装例 - 完全なタンパク質分類システム

### 8-1. プロファイルHMM分類器の実装

```python
class ProteinFamilyClassifier:
    """
    プロファイルHMMによるタンパク質分類器
    """

    def __init__(self, family_alignment, theta=0.3, sigma=0.01):
        """
        家族のアライメントからプロファイルHMMを構築
        """
        self.profile_hmm = self.build_profile_hmm(
            family_alignment, theta, sigma
        )
        self.threshold = self.calculate_threshold(family_alignment)

    def classify(self, new_protein):
        """
        新しいタンパク質を分類
        """
        # ステップ1: ビタビグラフを構築
        viterbi_graph = self.build_viterbi_graph(new_protein)

        # ステップ2: ビタビアルゴリズムを実行
        best_path, probability = self.viterbi_algorithm(
            new_protein, viterbi_graph
        )

        # ステップ3: 判定
        is_member = probability > self.threshold

        return {
            "is_member": is_member,
            "probability": probability,
            "path": best_path,
            "confidence": self.calculate_confidence(probability)
        }

    def build_viterbi_graph(self, protein):
        """
        ビタビグラフを構築
        """
        n_cols = len(protein) + 2  # +2 for start/end zero columns
        n_rows = len(self.profile_hmm.states)

        graph = {
            "nodes": {},
            "edges": {},
            "vertical_edges": {}
        }

        # ゼロ列（開始）
        graph["nodes"][(0, "S")] = {"type": "start"}

        # 文字処理列
        for col in range(1, len(protein) + 1):
            for state in self.profile_hmm.states:
                if state.startswith("M") or state.startswith("I"):
                    # 放出状態
                    graph["nodes"][(col, state)] = {
                        "type": "emit",
                        "char": protein[col - 1]
                    }
                elif state.startswith("D"):
                    # サイレント状態（垂直エッジで接続）
                    graph["nodes"][(col, state)] = {
                        "type": "silent"
                    }

        # ゼロ列（終了）
        graph["nodes"][(n_cols - 1, "E")] = {"type": "end"}

        return graph

    def viterbi_algorithm(self, protein, graph):
        """
        ビタビアルゴリズムの実行
        """
        # 動的計画法テーブル
        dp = {}
        backtrack = {}

        # 初期化
        dp[(0, "S")] = 1.0

        # 前向き計算
        for col in range(1, len(protein) + 2):
            for node in graph["nodes"]:
                if node[0] == col:
                    state = node[1]

                    # 最大確率を計算
                    max_prob = 0
                    best_prev = None

                    # すべての前状態を検討
                    for prev_node in graph["nodes"]:
                        if self.can_transition(prev_node, node):
                            trans_prob = self.get_transition_prob(
                                prev_node[1], state
                            )
                            emit_prob = self.get_emission_prob(
                                state, protein, col - 1
                            )

                            prob = dp.get(prev_node, 0) * trans_prob * emit_prob

                            if prob > max_prob:
                                max_prob = prob
                                best_prev = prev_node

                    dp[node] = max_prob
                    backtrack[node] = best_prev

        # バックトラック
        path = []
        current = (len(protein) + 1, "E")

        while current:
            path.append(current[1])
            current = backtrack.get(current)

        path.reverse()

        return path, dp[(len(protein) + 1, "E")]
```

### 8-2. 実際の使用例

```python
def real_world_example():
    """
    実際のタンパク質分類例
    """

    # キナーゼファミリーの既知メンバー
    kinase_family = [
        "ARDKLYEAG",
        "ARDKLFEAG",
        "ARDKLYDAG",
        "ARDKLYEAG",
        "ARDKLYE-G"
    ]

    # 分類器を作成
    classifier = ProteinFamilyClassifier(kinase_family)

    # 新しいタンパク質を分類
    test_proteins = [
        ("ARDKLYEAG", "完全一致"),
        ("ARDKLFEAG", "1文字違い"),
        ("ARD-LYEAG", "1文字欠失"),
        ("ARDXLYEAG", "1文字挿入"),
        ("MNPQRSTVW", "全然違う")
    ]

    for protein, description in test_proteins:
        result = classifier.classify(protein)

        print(f"\n配列: {protein} ({description})")
        print(f"判定: {'家族' if result['is_member'] else '非家族'}")
        print(f"確率: {result['probability']:.2e}")
        print(f"確信度: {result['confidence']:.1%}")
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- **プロファイルHMM** = タンパク質家族の判定機
- **ビタビグラフ** = 列数は文字数で決まる
- **垂直エッジ** = 削除状態への特別な道

### レベル2：本質的理解（ここまで来たら素晴らしい）

- **サイレント状態** = 文字を消費しない状態の扱い方
- **位置特異的スコア** = HMMが従来法より優れる理由
- **ゼロ列** = グラフの技術的な工夫

### レベル3：応用的理解（プロレベル）

- **グラフ構築の最適化** = 列数を最小限に抑える
- **閾値の自動調整** = ROC曲線による最適化
- **信頼度の計算** = 単なるYes/Noではない判定

## 🚀 実践演習：自分で分類器を作ってみよう

```python
def practice_exercise():
    """
    実践演習：簡単な分類器を作る
    """

    # ステップ1: 家族を定義
    my_family = [
        "ABC",
        "A-C",
        "ABC"
    ]

    # ステップ2: 分類器を作成
    classifier = ProteinFamilyClassifier(my_family, theta=0.3)

    # ステップ3: テスト
    test_cases = ["ABC", "A-C", "AXC", "DEF"]

    for test in test_cases:
        result = classifier.classify(test)
        print(f"{test}: {result['is_member']}")

    # 期待される結果：
    # ABC: True (完全一致)
    # A-C: True (既知のパターン)
    # AXC: True (許容される挿入)
    # DEF: False (全然違う)
```

## 🔬 次回予告：さらに高度な応用へ

次回は、プロファイルHMMのさらに高度な応用を学びます：

- **複数家族の同時判定**（マルチクラス分類）
- **新規家族の自動発見**（クラスタリング）
- **進化的距離の推定**（系統解析への応用）

まるで探偵が複数の事件を同時に解決するように、
複雑なタンパク質の関係性を解き明かしていきます！

## 🎓 発展的な話題

### 実際の研究での応用

```python
def advanced_applications():
    """
    実際の研究での高度な応用
    """

    applications = {
        "創薬": "標的タンパク質の家族特定",
        "進化研究": "種間のタンパク質比較",
        "機能予測": "構造から機能を推定",
        "疾患研究": "変異の影響評価"
    }

    # 実際のツール
    tools = {
        "HMMER": "最も広く使われるプロファイルHMMツール",
        "Pfam": "3万以上のタンパク質ファミリーデータベース",
        "InterPro": "統合タンパク質シグネチャデータベース"
    }

    print("プロファイルHMMは現代生物学の基盤技術！")
```

### パフォーマンスの最適化

```python
def performance_optimization():
    """
    実装の最適化テクニック
    """

    optimizations = {
        "ログ空間での計算": "アンダーフロー防止",
        "ビームサーチ": "計算量削減",
        "並列化": "複数配列の同時処理",
        "GPUアクセラレーション": "大規模解析"
    }

    # 実際のコード例
    import numpy as np

    def log_space_viterbi():
        """ログ空間でのビタビアルゴリズム"""
        # 確率の積 → ログの和
        log_prob = np.log(prob1) + np.log(prob2) + np.log(prob3)
        # アンダーフローを防ぐ
        return np.exp(log_prob)
```

---

_この講義ノートは、プロファイルHMMによるタンパク質分類の実装を段階的に理解できるよう設計されています。ビタビグラフの構築から実際の分類まで、すべてのステップを詳細に解説しました。_
