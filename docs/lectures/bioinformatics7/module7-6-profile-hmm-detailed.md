# 配列アライメントのためのプロファイルHMM（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**タンパク質の「家族判定」を自動化する賢いモデル（プロファイルHMM）を作る**

でも、ちょっと待ってください。そもそもタンパク質に「家族」があるって、どういうこと？
実は、タンパク質の世界は、まるで人間社会のように「家系図」があって、似た機能を持つタンパク質は同じ「家族」に属しているんです。

この家族判定ができると、新しく発見されたタンパク質の機能が「家族の特徴」から予測できる！
これは、まるで「この人は○○家の人だから、きっと音楽が得意」と予測するようなものです。

## 🤔 ステップ0：なぜプロファイルHMMが重要なの？

### 0-1. そもそもの問題を考えてみよう

想像してください。あなたは探偵で、ある人物がどの家族に属するか調べています。

```python
# 普通の方法：一人ずつ比較
def naive_family_check(new_person, family_members):
    """
    新しい人を家族の各メンバーと比較
    でも、これだと微妙な類似点を見逃しやすい...
    """
    for member in family_members:
        if similarity(new_person, member) > threshold:
            return "家族の可能性あり"
    return "家族ではない"
```

**問題点**：

- 家族の中には「変わり者」もいる
- 一人一人と比較すると、全体的な特徴を見逃す
- 「この家族はみんな音楽が得意」みたいな共通パターンが見えない

### 0-2. 驚きの事実

実は、タンパク質の配列の類似性は**氷山の一角**！

```
表面的な類似性：30%
↓
でも、構造的・機能的には同じ家族！
```

これは、方言が違っても同じ言語を話しているようなものです。
「おおきに」と「ありがとう」は全然違って見えるけど、同じ意味ですよね？

## 📖 ステップ1：家族の「共通パターン」を見つける

### 1-1. まず素朴な疑問から

「家族の共通パターンって、どうやって見つけるの？」

答え：**全員を並べて、共通点を探す！**

```python
def find_family_pattern():
    """
    まるで家族写真を撮るように、
    全員を並べて共通の特徴を探す
    """
    # 例：5つのタンパク質配列を並べる
    family_alignment = [
        "ACDEFGHIK",
        "AC-EFGHIK",  # Dが欠失
        "ACDEFGHIK",
        "ACIEFGHIK",  # Dが挿入Iに置換
        "AC-EFGHIK"   # Dが欠失
    ]

    # 各位置で何が起きているか確認
    for position in range(len(family_alignment[0])):
        print(f"位置{position}: {count_characters_at_position(position)}")
```

### 1-2. ここがポイント

**重要な観察**：家族の特徴には3種類ある

1. **保存領域**（みんな同じ）→ 家族の「顔」のような特徴
2. **挿入領域**（一部の人だけ余分に持つ）→ 個性的な特徴
3. **欠失領域**（一部の人が持たない）→ 省略された特徴

## 📖 ステップ2：挿入の多い列を削除する賢い戦略

### 2-1. なぜ挿入の多い列を削除？

ここで重要な観察をしてみましょう：

```python
def why_remove_insertion_columns():
    """
    挿入が多い列 = ノイズの可能性が高い
    これは、家族写真で「たまたま写り込んだ人」を除外するようなもの
    """

    alignment_with_insertions = [
        "AC-D-EFGH",
        "AC-D-EFGH",
        "AC-DAEFGH",  # 位置4にAを挿入
        "AC-D-EFGH",
        "AC-D-EFGH"
    ]

    # θ（シータ）= 0.3 (30%以上挿入があったら削除)
    theta = 0.3

    for col in range(len(alignment_with_insertions[0])):
        insertion_rate = count_insertions(col) / len(alignment_with_insertions)
        if insertion_rate > theta:
            print(f"列{col}は削除候補（挿入率: {insertion_rate:.1%}）")
```

### 2-2. 実験してみましょう

```python
def clean_alignment(alignment, theta=0.3):
    """
    挿入の多い列を削除してクリーンなアラインメントを作る
    """
    cleaned_positions = []

    for position in range(alignment_length):
        insertion_count = 0
        for sequence in alignment:
            if sequence[position] != '-':
                insertion_count += 1

        insertion_rate = insertion_count / len(alignment)
        if insertion_rate <= theta:
            cleaned_positions.append(position)

    return cleaned_positions

# 実際に試してみる
print("削除前：ノイズが多い")
print("削除後：家族の本質的な特徴が見える！")
```

## 📖 ステップ3：HMMの基本構造を作る（まだ確率なし）

### 3-1. そもそもHMMって何？

でも、ちょっと待ってください。HMM（隠れマルコフモデル）って何でしょう？

**アナロジー**：HMMは「迷路ゲーム」のようなもの

```python
def hmm_as_maze_game():
    """
    HMMを迷路ゲームとして理解する
    """
    # 各部屋（状態）でサイコロを振る
    # 出た目によって次の部屋が決まる
    # 各部屋で「お土産」（アミノ酸）をもらう

    maze = {
        "部屋M1": {
            "お土産の種類": {"A": 0.7, "C": 0.3},
            "次の部屋": {"部屋M2": 0.8, "部屋I1": 0.2}
        },
        # ... 続く
    }

    return "この迷路を通った軌跡がタンパク質配列になる！"
```

### 3-2. なぜ最初は確率が1なの？

ここで驚きの事実！最初のHMMは**決定的**（確率が全部1）です。

```python
def deterministic_hmm():
    """
    最初は単純に「必ず次の状態へ」というモデル
    """
    states = ["M1", "M2", "M3", "M4", "M5"]

    # 全員が同じ道を通る（確率1.0）
    for i in range(len(states)-1):
        transition_probability[states[i]][states[i+1]] = 1.0

    print("これだと柔軟性がない...")
    print("挿入や欠失を表現できない！")
```

## 📖 ステップ4：挿入状態の追加（ここで天才的な発想が）

### 4-1. 挿入をどう表現する？

「普通はこう考えるけど...」

```python
def naive_insertion_approach():
    """
    素朴なアプローチ：そのまま挿入を追加
    でも、これだと複雑すぎる！
    """
    # 挿入があるたびに新しい道を作る？
    # → 道が爆発的に増えてしまう！
```

「だから、こういう工夫が必要」

```python
def smart_insertion_states():
    """
    天才的な発想：挿入専用の「待機所」を作る！
    """

    # 各マッチ状態の間に「挿入状態」を配置
    hmm_with_insertions = {
        "M1": {"next": ["M2", "I1"]},  # M2に進むか、I1で待機
        "I1": {"next": ["M2", "I1"]},  # 自分自身にループできる！
        "M2": {"next": ["M3", "I2"]},
        # ... 続く
    }

    print("なんと！挿入状態は自分自身にループできる")
    print("これで複数の挿入も表現できる！")
```

### 4-2. 実際の例で確認

```python
def insertion_example():
    """
    実際のタンパク質でどう動くか見てみよう
    """
    protein_with_insertion = "ACXXDEFGH"  # XXが挿入

    path = ["S", "M1", "M2", "I2", "I2", "M3", "M4", "M5", "M6", "M7", "E"]
    #            A    C    X    X    D    E    F    G    H

    print("挿入状態I2を2回通ることで、XXを表現！")
```

## 📖 ステップ5：欠失状態の追加（もう一つの天才的発想）

### 5-1. 欠失の問題

「でも待って、文字が欠けている場合はどうするの？」

```python
def deletion_problem():
    """
    欠失の問題：一部のアミノ酸が抜けている
    """
    normal_protein = "ACDEFGH"
    protein_with_deletion = "AC--FGH"  # DEが欠失

    print("どうやってDEを飛ばす？")
```

### 5-2. 最初のアイデア（でもこれは問題あり）

```python
def naive_deletion_approach():
    """
    素朴なアプローチ：全部つなぐ
    """
    # M1 → M2, M3, M4, M5... 全部につなぐ？
    # → エッジが爆発的に増える！O(n²)の複雑さ

    print("これだと計算が重すぎる...")
```

### 5-3. ここで天才的な解決策

```python
def smart_deletion_states():
    """
    欠失専用の「高速道路」を作る！
    """

    hmm_with_deletions = {
        "M1": {"next": ["M2", "D2"]},  # D2は「M2をスキップする道」
        "D2": {"next": ["M3", "D3"]},  # さらにスキップも可能
        "M2": {"next": ["M3", "D3"]},
        # ... 続く
    }

    print("欠失状態は何も出力しない（沈黙状態）")
    print("でも、状態遷移の履歴は残る！")
```

## 📖 ステップ6：3層構造の美しいHMM

### 6-1. 完成形の構造

ここで、完成したHMMの美しい3層構造を見てみましょう：

```python
def three_layer_hmm():
    """
    3層構造のプロファイルHMM
    まるで3階建ての建物のよう！
    """

    layers = {
        "3階（挿入層）": ["I0", "I1", "I2", "I3", "..."],  # 追加の部屋
        "2階（マッチ層）": ["M1", "M2", "M3", "M4", "..."],  # メインの部屋
        "1階（欠失層）": ["D1", "D2", "D3", "D4", "..."],  # ショートカット
    }

    print("各層の役割：")
    print("- マッチ層：家族の共通特徴")
    print("- 挿入層：個人の追加特徴")
    print("- 欠失層：省略された特徴")

    return layers
```

### 6-2. 実際に動かしてみる

```python
def trace_protein_path():
    """
    実際のタンパク質がどう通るか追跡
    """

    proteins = [
        ("ACDEFGH", ["S", "M1", "M2", "M3", "M4", "M5", "M6", "M7", "E"]),
        ("AC-EFGH", ["S", "M1", "M2", "D3", "M4", "M5", "M6", "M7", "E"]),
        ("ACXDEFGH", ["S", "M1", "M2", "I2", "M3", "M4", "M5", "M6", "M7", "E"])
    ]

    for protein, path in proteins:
        print(f"配列: {protein}")
        print(f"経路: {' → '.join(path)}")
        print()
```

## 📖 ステップ7：遷移確率の計算（統計の魔法）

### 7-1. どうやって確率を決める？

「ここで重要な観察をしてみましょう」

```python
def calculate_transition_probabilities():
    """
    家族のアラインメントから確率を学習する
    これは「統計」という魔法！
    """

    # 5つの配列の状態M5からの遷移を観察
    observations_from_M5 = [
        "M5 → I5",  # 配列1
        "M5 → I5",  # 配列2
        "M5 → I5",  # 配列3
        "M5 → M6",  # 配列4
        "M5 → M6",  # 配列5（D6ではなかった！）
    ]

    # 統計を取る
    transitions = {
        "M5→I5": 3,  # 3回観察
        "M5→M6": 2,  # 2回観察
        "M5→D6": 0   # 0回観察
    }

    # 確率に変換
    total = sum(transitions.values())
    for transition, count in transitions.items():
        probability = count / total
        print(f"{transition}: {probability:.1%}")
```

### 7-2. なぜこの方法が最適？

「実は、これは最尤推定という統計学の基本原理！」

```python
def why_maximum_likelihood():
    """
    なぜ頻度を確率にするのが最適か
    """
    print("サイコロの例で考えてみよう：")
    print("100回振って、1が20回出た")
    print("→ 1が出る確率の最良の推定は20/100 = 0.2")
    print()
    print("これと同じ原理をHMMの遷移に適用！")
```

## 📖 ステップ8：放出確率の計算（各状態の個性）

### 8-1. 各状態が「何を出力するか」

```python
def calculate_emission_probabilities():
    """
    各マッチ状態がどのアミノ酸を出力しやすいか
    """

    # 状態M2での観察
    emissions_at_M2 = [
        "C",  # 配列1
        "F",  # 配列2
        "C",  # 配列3
        "D",  # 配列4
        # 配列5は状態M2を通らない（欠失）
    ]

    # 統計を取る
    amino_acid_counts = {
        "C": 2,  # 50%
        "F": 1,  # 25%
        "D": 1,  # 25%
        # 他のアミノ酸: 0%
    }

    print("状態M2の「個性」が見えてきた！")
    print("Cを出しやすい状態なんだ")
```

### 8-2. 挿入状態の放出確率

```python
def insertion_emission_special():
    """
    挿入状態は特別：全アミノ酸を均等に出力
    """

    # 挿入状態は「何でもあり」
    insertion_emission = {
        amino_acid: 1/20  # 20種類のアミノ酸を均等に
        for amino_acid in "ACDEFGHIKLMNPQRSTVWY"
    }

    print("挿入状態は偏見を持たない！")
    print("どんなアミノ酸も受け入れる寛容な状態")
```

## 📖 ステップ9：ゼロ確率問題と擬似カウント

### 9-1. ゼロ確率の危険性

「でも待って、観察されなかった遷移の確率が0になっちゃう！」

```python
def zero_probability_problem():
    """
    ゼロ確率の問題：一度も見なかった = 絶対起きない？
    """

    # 問題のシナリオ
    training_data = ["赤", "赤", "赤", "赤", "青"]

    # 素朴な確率計算
    prob_green = 0 / 5  # 0%

    print("緑は絶対出ない？そんなはずない！")
    print("たまたま訓練データになかっただけかも")

    # 新しいタンパク質が「緑」的な特徴を持っていたら？
    # → 確率0なので、このHMMでは絶対に認識できない！
```

### 9-2. 擬似カウントという救世主

```python
def pseudocount_solution():
    """
    擬似カウント：すべての可能性に小さなチャンスを与える
    """

    # ラプラス平滑化（擬似カウント = 1）
    actual_counts = {
        "M5→M6": 3,
        "M5→I5": 1,
        "M5→D6": 0  # 観察されなかった
    }

    # 擬似カウントを追加
    pseudocount = 0.1
    smoothed_counts = {
        transition: count + pseudocount
        for transition, count in actual_counts.items()
    }

    total = sum(smoothed_counts.values())
    for transition, count in smoothed_counts.items():
        probability = count / total
        print(f"{transition}: {probability:.1%}")

    print("\n0%が消えた！すべての可能性が残された")
```

## 📖 ステップ10：プロファイルHMMの実装

### 10-1. 完全なプロファイルHMM構築

```python
class ProfileHMM:
    """
    プロファイルHMMの完全実装
    """

    def __init__(self, alignment, theta=0.3):
        self.alignment = alignment
        self.theta = theta
        self.states = []
        self.transitions = {}
        self.emissions = {}

    def build(self):
        """
        アラインメントからHMMを構築
        """
        # ステップ1: 挿入列を削除
        self.remove_insertion_columns()

        # ステップ2: 状態を作成
        self.create_states()

        # ステップ3: パスを追跡
        paths = self.trace_paths()

        # ステップ4: 確率を計算
        self.calculate_probabilities(paths)

        # ステップ5: 擬似カウントを追加
        self.add_pseudocounts()

        return self

    def remove_insertion_columns(self):
        """
        挿入の多い列を削除
        """
        kept_columns = []
        for col in range(len(self.alignment[0])):
            insertion_count = sum(
                1 for seq in self.alignment
                if seq[col] != '-'
            )
            insertion_rate = insertion_count / len(self.alignment)

            if insertion_rate <= self.theta:
                kept_columns.append(col)

        self.kept_columns = kept_columns
        print(f"保持された列: {len(kept_columns)}/{len(self.alignment[0])}")

    def create_states(self):
        """
        3層のHMM状態を作成
        """
        num_match_states = len(self.kept_columns)

        # 開始・終了状態
        self.states.append("S")  # Start
        self.states.append("E")  # End

        # 3層の状態
        for i in range(num_match_states + 1):
            if i > 0:
                self.states.append(f"M{i}")  # マッチ状態
                self.states.append(f"D{i}")  # 欠失状態
            self.states.append(f"I{i}")  # 挿入状態

        print(f"作成された状態数: {len(self.states)}")
```

### 10-2. 新しいタンパク質の評価

```python
def evaluate_new_protein(protein, profile_hmm):
    """
    新しいタンパク質が家族に属するか判定
    """

    # Viterbiアルゴリズムで最適パスを見つける
    best_path = viterbi_algorithm(protein, profile_hmm)

    # パスの確率を計算
    path_probability = calculate_path_probability(best_path, profile_hmm)

    # 閾値と比較
    if path_probability > threshold:
        print(f"✅ このタンパク質は家族の一員です！")
        print(f"   確率: {path_probability:.2e}")
        print(f"   パス: {' → '.join(best_path)}")
    else:
        print(f"❌ このタンパク質は家族ではないようです")
        print(f"   確率: {path_probability:.2e}")

    return path_probability
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- **プロファイルHMM** = タンパク質ファミリーの「判定機」
- マルチプルアラインメントから自動的に作られる
- 3層構造（マッチ・挿入・欠失）で柔軟に対応

### レベル2：本質的理解（ここまで来たら素晴らしい）

- **なぜ3層？** → 生物学的変異の3パターンに対応
- **確率の意味** → 家族の「らしさ」の定量化
- **擬似カウント** → 未知への備え

### レベル3：応用的理解（プロレベル）

- **計算量の工夫** → エッジ数をO(n²)からO(n)に削減
- **最尤推定** → 統計学的に最適な確率割り当て
- **Viterbiとの組み合わせ** → 効率的な配列解析

## 🚀 実践演習：自分でプロファイルHMMを作ってみよう

```python
def practice_exercise():
    """
    実際に手を動かしてみよう！
    """

    # サンプル配列（簡単な例）
    sample_alignment = [
        "ABC",
        "A-C",
        "ABC",
        "AXC",  # Xは挿入
        "A-C"
    ]

    # プロファイルHMMを構築
    hmm = ProfileHMM(sample_alignment, theta=0.3)
    hmm.build()

    # 新しい配列をテスト
    test_sequences = [
        "ABC",   # 完全一致
        "A-C",   # 欠失あり
        "AXYC",  # 挿入あり
        "DEF"    # 全然違う
    ]

    for seq in test_sequences:
        probability = evaluate_new_protein(seq, hmm)
        print(f"配列 {seq}: {probability:.2e}")
```

## 🔬 次回予告：さらに驚くべき展開が

次回は、このプロファイルHMMを使って：

- **実際のタンパク質データベース**での家族検索
- **進化的関係**の推定
- **機能予測**への応用

を学びます。まるで探偵が家系図から人物の特徴を推理するように、
タンパク質の機能を予測できるようになります！

## 🎓 発展的な話題

### より高度なプロファイルHMM

実際の研究では、さらに洗練された技術が使われています：

1. **位置特異的スコアリング行列（PSSM）**
2. **HMMER**（実用的なプロファイルHMMツール）
3. **Pfam**データベース（タンパク質ファミリーのカタログ）

```python
def advanced_topics():
    """
    実際の研究での応用例
    """

    # HMMERの使用例
    hmmer_command = "hmmsearch --tblout results.txt profile.hmm sequences.fasta"

    # Pfamデータベースの活用
    pfam_families = {
        "PF00001": "7回膜貫通型受容体",
        "PF00002": "GPCRファミリー",
        # ... 数万のファミリー
    }

    print("プロファイルHMMは現代のバイオインフォマティクスの基盤技術！")
```

---

_この講義ノートは、プロファイルHMMの概念を段階的に理解できるよう設計されています。各ステップで手を動かしながら学ぶことで、深い理解が得られます。_
