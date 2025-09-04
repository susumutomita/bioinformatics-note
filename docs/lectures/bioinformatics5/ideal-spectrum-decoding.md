# 理想スペクトルの解読（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**質量分析のスペクトルから元のペプチド配列を完璧に復元するアルゴリズムをマスター**

でも、ちょっと待ってください。質量の数値の羅列からどうやって配列を復元するの？
実は、これは**暗号解読のようなパズル問題**で、グラフアルゴリズムで解けるんです！

## 🤔 ステップ0：なぜ理想スペクトルから始めるの？

### 0-1. そもそもの問題を考えてみよう

質量分析計からこんなデータが出てきたとします：
`[0, 71, 114, 131, 185, 202, 245, 316]`

これは何を意味しているのでしょうか？

### 0-2. 驚きの事実

これらの数値は、ペプチドを様々な位置で切断した**断片の質量**なんです！
そして、これらの質量の差から元のアミノ酸配列が分かる！

## 📖 ステップ1：理想スペクトルとは何か

### 1-1. まず素朴な疑問から

「理想」スペクトルって、現実には存在しないの？

### 1-2. なぜそうなるのか

理想スペクトルは**全てのプレフィックスとサフィックスの質量が完璧に測定された**状態。
現実にはノイズや欠損があるため、まず理想的な場合を理解することが重要！

### 1-3. 具体例で確認

```python
def generate_ideal_spectrum():
    """
    ペプチドGAPの理想スペクトルを生成
    """
    peptide = "GAP"
    masses = {'G': 57, 'A': 71, 'P': 97}

    print(f"ペプチド: {peptide}")
    print("=" * 40)

    # プレフィックス質量
    print("\nプレフィックス（N末端から）:")
    prefix_masses = [0]  # 空のプレフィックス
    total = 0
    for i, aa in enumerate(peptide):
        total += masses[aa]
        prefix_masses.append(total)
        print(f"  {peptide[:i+1]:3s}: {total:3d}")

    # サフィックス質量
    print("\nサフィックス（C末端から）:")
    suffix_masses = []
    for i in range(1, len(peptide) + 1):
        suffix = peptide[-i:]
        mass = sum(masses[aa] for aa in suffix)
        suffix_masses.append(mass)
        print(f"  {suffix:3s}: {mass:3d}")

    # 理想スペクトル
    ideal_spectrum = sorted(set(prefix_masses + suffix_masses))
    print(f"\n理想スペクトル: {ideal_spectrum}")

    return ideal_spectrum

generate_ideal_spectrum()
```

### 1-4. ここがポイント

理想スペクトルには**重複がない**（setを使用）、そして**ソートされている**！

## 📖 ステップ2：プレフィックスとサフィックスの魔法

### 2-1. なぜ両方必要なの？

```python
def why_both_fragments():
    """
    プレフィックスとサフィックス両方が必要な理由
    """
    print("なぜ両方の断片が必要か:")
    print("=" * 40)

    peptide = "NQEL"

    print(f"\nペプチド: {peptide}")
    print("\nプレフィックスだけの場合:")
    print("  N, NQ, NQE, NQEL")
    print("  → 最初からの情報しかない")

    print("\nサフィックスも含めると:")
    print("  L, EL, QEL も分かる")
    print("  → より多くの手がかり！")

    print("\n重要な観察:")
    print("プレフィックス質量 + サフィックス質量 = ペプチド全体の質量")
    print("これが重要な制約条件になる！")

why_both_fragments()
```

### 2-2. でも待って、どっちがプレフィックスか分からない

```python
def ambiguity_problem():
    """
    断片の種類が不明な問題
    """
    print("質量分析の根本的な問題:")
    print("=" * 40)

    print("\n質量114が測定されたとして...")
    print("これは：")
    print("  • プレフィックス「NQ」の質量？")
    print("  • サフィックス「EL」の質量？")
    print("  • 別のペプチドの断片？")

    print("\n答え：分からない！")
    print("→ だから全ての可能性を考慮する必要がある")

ambiguity_problem()
```

## 📖 ステップ3：スペクトルグラフ - 天才的な発想

### 3-1. グラフで表現するアイデア

```python
def spectrum_graph_concept():
    """
    スペクトルグラフの基本概念
    """
    print("スペクトルグラフの構築:")
    print("=" * 40)

    spectrum = [0, 57, 71, 128, 154, 185, 225, 242, 282, 299]

    print(f"\nスペクトル: {spectrum}")

    print("\n構築ルール:")
    print("1. 各質量値をノードにする")
    print("2. 質量差がアミノ酸の質量と一致したらエッジを張る")
    print("3. エッジにアミノ酸のラベルを付ける")

    print("\n例：")
    print("  57 - 0 = 57 → G（グリシン）")
    print("  128 - 57 = 71 → A（アラニン）")
    print("  225 - 128 = 97 → P（プロリン）")

spectrum_graph_concept()
```

### 3-2. 実際のグラフ構築

```python
def build_spectrum_graph():
    """
    スペクトルグラフの実装
    """
    import networkx as nx

    spectrum = [0, 57, 71, 128, 154, 185, 225, 242, 282, 299]

    # アミノ酸質量表
    aa_masses = {
        57: 'G', 71: 'A', 87: 'S', 97: 'P', 99: 'V',
        101: 'T', 103: 'C', 113: 'I/L', 114: 'N',
        115: 'D', 128: 'K/Q', 129: 'E', 131: 'M',
        137: 'H', 147: 'F', 156: 'R', 163: 'Y', 186: 'W'
    }

    print("スペクトルグラフのエッジ:")
    print("=" * 40)

    edges = []
    for i, mass1 in enumerate(spectrum):
        for j, mass2 in enumerate(spectrum):
            if mass2 > mass1:
                diff = mass2 - mass1
                if diff in aa_masses:
                    edges.append((mass1, mass2, aa_masses[diff]))
                    print(f"  {mass1:3d} → {mass2:3d}: {aa_masses[diff]} (差={diff})")

    return edges

build_spectrum_graph()
```

## 📖 ステップ4：パスから配列へ

### 4-1. ソースからシンクへの道

```python
def path_to_peptide():
    """
    グラフのパスからペプチド配列を復元
    """
    print("パスからペプチドへの変換:")
    print("=" * 40)

    # 仮想的なパス
    path = [(0, 57, 'G'), (57, 128, 'A'), (128, 225, 'P')]

    print("\nパス:")
    for start, end, aa in path:
        print(f"  {start} → {end}: {aa}")

    print("\nペプチド配列の構築:")
    peptide = ""
    for _, _, aa in path:
        peptide += aa
        print(f"  現在の配列: {peptide}")

    print(f"\n最終配列: {peptide}")

path_to_peptide()
```

## 📖 ステップ5：デコーディングアルゴリズム（単純版）

### 5-1. 最初の試み

```python
def simple_decoding_algorithm():
    """
    単純なデコーディングアルゴリズム
    """
    print("理想スペクトルデコーディング（単純版）:")
    print("=" * 50)

    print("""
    def decode_ideal_spectrum_simple(spectrum):
        # ステップ1: グラフを構築
        graph = build_spectrum_graph(spectrum)

        # ステップ2: 0から最大値へのパスを探索
        source = 0
        sink = max(spectrum)
        path = find_path(graph, source, sink)

        # ステップ3: パスからペプチドを構築
        peptide = path_to_peptide(path)

        return peptide
    """)

    print("\n問題点:")
    print("• 複数のパスが存在する可能性")
    print("• 正しいパスをどう選ぶ？")

simple_decoding_algorithm()
```

### 5-2. でも待って、これで本当に動く？

```python
def algorithm_problem():
    """
    単純アルゴリズムの問題点
    """
    print("単純アルゴリズムの失敗例:")
    print("=" * 40)

    print("\n未知のペプチドのスペクトル:")
    spectrum = [0, 71, 101, 113, 114, 128, 184, 185, 199, 214, 227,
                256, 271, 298, 327, 328, 341, 369, 399, 428, 470]

    print(f"{spectrum[:5]}...")

    print("\nグラフ内のあるパス: NTTAG")
    print("しかし、NTTAGの理想スペクトルを計算すると...")
    print("元のスペクトルと一致しない！")

    print("\n原因:")
    print("• グラフには多くのパスが存在")
    print("• その中の1つだけが正解")
    print("• どのパスが正しいか分からない")

algorithm_problem()
```

## 📖 ステップ6：改良版アルゴリズム

### 6-1. 全パス探索アプローチ

```python
def improved_decoding_algorithm():
    """
    改良版デコーディングアルゴリズム
    """
    print("理想スペクトルデコーディング（改良版）:")
    print("=" * 50)

    print("""
    def decode_ideal_spectrum_improved(spectrum):
        # ステップ1: グラフを構築
        graph = build_spectrum_graph(spectrum)

        # ステップ2: 全てのパスを探索
        all_paths = find_all_paths(graph, 0, max(spectrum))

        # ステップ3: 各パスを検証
        for path in all_paths:
            peptide = path_to_peptide(path)

            # ペプチドの理想スペクトルを計算
            computed_spectrum = compute_ideal_spectrum(peptide)

            # 元のスペクトルと比較
            if computed_spectrum == spectrum:
                return peptide  # 正解を発見！

        return None  # 解なし
    """)

improved_decoding_algorithm()
```

### 6-2. 計算量の問題

```python
def complexity_analysis():
    """
    アルゴリズムの計算量分析
    """
    print("計算量の分析:")
    print("=" * 40)

    print("\n問題のサイズ:")
    print("• n: スペクトル中の質量数")
    print("• m: 可能なアミノ酸の種類（約20）")

    print("\nグラフの性質:")
    print(f"• ノード数: O(n)")
    print(f"• エッジ数: O(n²)")
    print(f"• パス数: 指数関数的！")

    print("\n全パス探索の計算量:")
    print("最悪の場合: O(2^n)")
    print("→ 指数アルゴリズム！")

    print("\n朗報:")
    print("実は多項式時間アルゴリズムが存在する")
    print("（動的計画法を使用）")

complexity_analysis()
```

## 📖 ステップ7：理想から現実へ

### 7-1. 実際のスペクトルの問題

```python
def real_spectrum_challenges():
    """
    実際のスペクトルの課題
    """
    print("実際のスペクトルの問題:")
    print("=" * 40)

    print("\n1. 欠損質量:")
    print("   • 一部の断片が検出されない")
    print("   • 低強度のピークが消える")

    print("\n2. ノイズ質量:")
    print("   • 汚染物質のピーク")
    print("   • 機器のノイズ")
    print("   • 予期しない断片化")

    print("\n3. 質量誤差:")
    print("   • 測定の不正確さ")
    print("   • ±0.5 Da程度の誤差")

    print("\n結果:")
    print("理想スペクトルアルゴリズムは使えない！")
    print("→ より柔軟なアプローチが必要")

real_spectrum_challenges()
```

### 7-2. スコアリングの必要性

```python
def scoring_concept():
    """
    スコアリングによる解決策
    """
    print("スコアリングアプローチ:")
    print("=" * 40)

    print("\n理想スペクトル:")
    print("  完全一致を要求")
    print("  ○か×かの二択")

    print("\n実際のスペクトル:")
    print("  「どれくらい良く説明するか」をスコア化")
    print("  最高スコアのペプチドを選択")

    print("\nスコアリング基準の例:")
    print("  • 一致する質量の数")
    print("  • 質量誤差の合計")
    print("  • ピーク強度の考慮")
    print("  • 連続する断片の存在")

scoring_concept()
```

## 📖 ステップ8：実装例

### 8-1. 完全な実装

```python
def complete_implementation():
    """
    理想スペクトルデコーディングの完全実装
    """
    def compute_prefix_masses(peptide, masses):
        """プレフィックス質量を計算"""
        result = [0]
        total = 0
        for aa in peptide:
            total += masses.get(aa, 0)
            result.append(total)
        return result

    def compute_suffix_masses(peptide, masses):
        """サフィックス質量を計算"""
        result = []
        for i in range(1, len(peptide) + 1):
            suffix = peptide[-i:]
            mass = sum(masses.get(aa, 0) for aa in suffix)
            result.append(mass)
        return result

    def compute_ideal_spectrum(peptide, masses):
        """理想スペクトルを計算"""
        prefix = compute_prefix_masses(peptide, masses)
        suffix = compute_suffix_masses(peptide, masses)
        return sorted(set(prefix + suffix))

    # テスト
    masses = {'G': 57, 'A': 71, 'P': 97}
    peptide = "GAP"

    print(f"ペプチド: {peptide}")
    print(f"理想スペクトル: {compute_ideal_spectrum(peptide, masses)}")

complete_implementation()
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- 理想スペクトルは全断片の質量の集合
- プレフィックスとサフィックスの両方が含まれる
- グラフアルゴリズムで配列を復元できる
- 実際のスペクトルにはノイズがある

### レベル2：本質的理解（ここまで来たら素晴らしい）

- スペクトルグラフの構築方法
- パス探索による配列復元
- 全パス探索の必要性と検証
- 計算量の問題（指数的）

### レベル3：応用的理解（プロレベル）

- 動的計画法による多項式時間解法
- スコアリングによる実スペクトル対応
- 質量誤差の許容
- 統計的有意性の評価

## 🔍 練習問題

```python
def practice_problems():
    """
    理解を深める練習問題
    """
    print("練習問題:")
    print("=" * 40)

    print("\n問題1: ペプチドNQELの理想スペクトルを計算せよ")
    print("（N=114, Q=128, E=129, L=113）")

    print("\n問題2: スペクトル[0, 87, 101, 188]から")
    print("        可能なペプチドを全て求めよ")

    print("\n問題3: なぜ理想スペクトルでは")
    print("        複数の正解が存在しうるか説明せよ")

    print("\n問題4: 実際のスペクトルで欠損質量が")
    print("        発生する理由を3つ挙げよ")

practice_problems()
```

## 📖 ステップ9：実スペクトルとの出会い（現実の壁）

### 9-1. ティラノサウルスのスペクトルから学ぶ

でも、ちょっと待ってください。これまで理想的なケースばかり見てきましたが、実際の質量分析はどうなの？

```python
def real_world_example():
    """
    実際のティラノサウルスのスペクトル例
    """
    print("実世界での驚きの発見:")
    print("=" * 40)

    print("\nAsara博士の実験（2007年）:")
    print("• 6800万年前のティラノサウルスの骨化石から")
    print("• 質量分析でペプチド配列を特定")
    print("• 現代の鳥類との類似性を発見！")

    print("\nでも、実際のスペクトルはこんな感じ:")
    print("理想: [0, 57, 128, 225]  ← きれいで完璧")
    print("現実: [0.1, 56.9, 128.3, 150.2, 224.8, 240.1, ...]")
    print("      ↑ノイズ  ↑誤差  ↑不明ピーク")

    print("\nここで重要な疑問が...")

real_world_example()
```

### 9-2. 「どのペプチドが正解？」問題

```python
def peptide_candidate_problem():
    """
    複数のペプチド候補をどう比較するか
    """
    print("ペプチド候補の比較問題:")
    print("=" * 40)

    # 同じスペクトルに対する2つの候補
    spectrum_peaks = [0, 71, 114, 131, 185, 202, 245, 316]

    candidate_1 = "NQEL"  # 候補1
    candidate_2 = "NLQE"  # 候補2

    print(f"\n実際のスペクトル: {spectrum_peaks}")
    print(f"\n候補1のペプチド: {candidate_1}")
    print(f"候補2のペプチド: {candidate_2}")

    print("\nどちらが正解？")
    print("理想スペクトルでは「完全一致」で判定したけど...")
    print("実スペクトルでは「どれくらい良く説明するか」で判定！")

peptide_candidate_problem()
```

## 📖 ステップ10：共有ピーク数という天才的アイデア

### 10-1. まず素朴な疑問から

「どれくらい良く説明するか」って、具体的にはどう測るの？

### 10-2. なぜそうなるのか

実は、**共有ピーク数（Shared Peak Count）**という概念があります！

```python
def shared_peak_count_concept():
    """
    共有ピーク数の基本概念
    """
    print("共有ピーク数の魔法:")
    print("=" * 40)

    # 実スペクトル（ティラノサウルス由来）
    actual_spectrum = [0, 71, 114, 131, 185, 202, 245, 316, 400, 515]

    # 候補ペプチドの理論スペクトル
    candidate_peptide = "NQEL"
    theoretical_peaks = [0, 114, 242, 371, 484]  # NQELの理論値

    print(f"実際のスペクトル: {actual_spectrum}")
    print(f"候補ペプチドの理論スペクトル: {theoretical_peaks}")

    # 共有ピーク数を計算
    shared_peaks = []
    for peak in theoretical_peaks:
        if peak in actual_spectrum:
            shared_peaks.append(peak)

    print(f"\n共有ピーク: {shared_peaks}")
    print(f"共有ピーク数: {len(shared_peaks)}")

    print("\nこれは「ペプチドがスペクトルをどれだけ説明できるか」の指標！")

shared_peak_count_concept()
```

### 10-3. 具体例で確認

```python
def annotation_example():
    """
    スペクトル注釈の具体例
    """
    print("スペクトルの注釈付け:")
    print("=" * 40)

    print("実際のスペクトルのピーク → 説明方法:")
    print("")

    # ピークと対応する断片の例
    annotations = [
        (114, "長さ1のプレフィックス N", "✓"),
        (242, "長さ2のプレフィックス NQ", "✓"),
        (371, "長さ3のプレフィックス NQE", "✓"),
        (131, "長さ1のサフィックス L", "✓"),
        (260, "長さ2のサフィックス EL", "✓"),
        (388, "長さ3のサフィックス QEL", "✓")
    ]

    for mass, description, found in annotations:
        status = "説明可能" if found == "✓" else "説明不可"
        print(f"  質量 {mass:3d}: {description:20s} → {status}")

    print(f"\n注釈できたピーク数: 6個")
    print("共有ピーク数 = 6")

annotation_example()
```

### 10-4. ここがポイント

でも待って、共有ピーク数が多ければ多いほど良いペプチド候補？

## 📖 ステップ11：スコアリング方法の大論争

### 11-1. 2つの対立するアプローチ

```python
def scoring_methods_debate():
    """
    スコアリング方法の比較
    """
    print("スコアリング方法の大論争:")
    print("=" * 50)

    print("\n🥊 第1ラウンド：共有ピーク数 vs ピーク強度")
    print("")

    # 同じスペクトルの2つの候補例
    spectrum_data = [
        (114, 1000),    # 質量, 強度
        (242, 50),
        (371, 2000),
        (131, 800),
        (260, 30),
        (388, 1500)
    ]

    print("スペクトルデータ（質量, 強度）:")
    for mass, intensity in spectrum_data:
        print(f"  {mass:3d}: {intensity:4d}")

    print("\n方法1：共有ピーク数でスコアリング")
    print("  → 全てのピークを同等に扱う")
    print("  → スコア = 6（単純にピーク数）")

    print("\n方法2：強度の合計でスコアリング")
    print("  → 大きなピークほど重要")
    print(f"  → スコア = {sum(intensity for _, intensity in spectrum_data)}")

scoring_methods_debate()
```

### 11-2. それぞれの問題点

```python
def scoring_problems():
    """
    各スコアリング方法の問題点
    """
    print("各方法の問題点:")
    print("=" * 40)

    print("\n📊 共有ピーク数の問題:")
    print("  ✗ 強度を完全に無視")
    print("  ✗ 大きなピーク = 小さなピーク扱い")
    print("  ✗ ノイズピークの影響を受けやすい")

    print("\n🔥 強度合計の問題:")
    print("  ✗ 1つの巨大ピークが支配する")
    print("  ✗ 他の小さなピークが見えなくなる")
    print("  ✗ 機器の特性に依存しやすい")

    print("\n💡 理想的な解決策:")
    print("  • 大きなピークは重要だが、支配しすぎない")
    print("  • 小さなピークも考慮する")
    print("  • 確率的モデルによる統一的アプローチ")

    print("\n👉 これがスペクトルベクトルのアイデア！")

scoring_problems()
```

## 📖 ステップ12：スペクトルベクトル - 革命的発想

### 12-1. そもそもベクトル化って何？

でも、ちょっと待ってください。「スペクトルをベクトルに変換」って何のこと？

```python
def vector_concept_introduction():
    """
    ベクトル化の基本概念をソフトウェアエンジニア向けに説明
    """
    print("スペクトルベクトル化の革命:")
    print("=" * 40)

    print("\n🤔 なぜベクトル化？")
    print("問題：スペクトルは「ピーク位置と強度のペア」のリスト")
    print("      → 比較しにくい、計算しにくい")
    print("")
    print("解決：固定長ベクトルに変換")
    print("      → 線形代数の道具が使える！")

    print("\n📊 具体例:")
    print("スペクトル（従来）: [(114, 1000), (242, 50), (371, 2000)]")
    print("スペクトルベクトル: [0, 0, ..., 1000, ..., 50, ..., 2000, ...]")
    print("                      ↑質量0   ↑質量114    ↑質量242  ↑質量371")

vector_concept_introduction()
```

### 12-2. スペクトルベクトルの構築方法

```python
def spectrum_vector_construction():
    """
    スペクトルベクトルの詳細な構築方法
    """
    print("スペクトルベクトルの構築:")
    print("=" * 40)

    # 最大質量を決める（例：500 Da）
    max_mass = 500

    print(f"1. ベクトルの長さを決める: {max_mass} 次元")
    print("2. 全ての要素を0で初期化")
    print("3. 各ピークに対して...")

    # サンプルスペクトル
    spectrum_peaks = [
        (114, 1000),  # (質量, 強度)
        (242, 50),
        (371, 2000),
        (131, 800)
    ]

    # スペクトルベクトル初期化
    spectrum_vector = [0] * (max_mass + 1)

    print("\nスペクトルベクトルへの変換:")
    for mass, intensity in spectrum_peaks:
        # でも待って、強度をそのまま使うの？
        # 実は「振幅」という特殊な値を計算！
        amplitude = calculate_amplitude(mass, intensity)  # 仮想関数
        spectrum_vector[mass] = amplitude
        print(f"  質量 {mass} → ベクトル[{mass}] = {amplitude} （振幅）")

    print(f"\n結果のスペクトルベクトル（最初の10要素）:")
    print(spectrum_vector[:10])

def calculate_amplitude(mass, intensity):
    """振幅計算の概念説明"""
    # これは実際には複雑な確率計算
    # ここでは簡単化した例
    return int(intensity / 100)  # 簡略化

spectrum_vector_construction()
```

### 12-3. 振幅の秘密

```python
def amplitude_mystery():
    """
    振幅計算の本質
    """
    print("振幅（Amplitude）の正体:")
    print("=" * 40)

    print("⚠️  重要な誤解を解こう:")
    print("   振幅 ≠ ピーク強度")
    print("   振幅 = 「そのペプチドのプレフィックスである確率」に比例")

    print("\n🎯 振幅の意味:")
    print("  質量 m のピーク → 振幅 s[m]")
    print("  s[m] = 質量 m が未知ペプチドのプレフィックス質量である")
    print("         可能性の高さを表す数値")

    print("\n📊 具体例:")
    examples = [
        (114, 9, "高い確率でプレフィックス"),
        (150, -5, "低い確率（ノイズかも）"),
        (242, 7, "中程度の確率"),
        (300, 3, "やや低い確率")
    ]

    for mass, amplitude, meaning in examples:
        print(f"  質量 {mass:3d}: 振幅 {amplitude:2d} → {meaning}")

    print("\n🔍 振幅の計算方法:")
    print("  • 統計モデルを使用")
    print("  • 機械学習アルゴリズムで学習")
    print("  • ピーク強度、形状、周辺ピークを考慮")

amplitude_mystery()
```

## 📖 ステップ13：ペプチドベクトル - 双子の概念

### 13-1. ペプチドもベクトルにしちゃう

スペクトルがベクトルなら、ペプチドもベクトルにできる？

```python
def peptide_vector_concept():
    """
    ペプチドベクトルの概念
    """
    print("ペプチドベクトルの登場:")
    print("=" * 40)

    peptide = "GAP"
    masses = {'G': 57, 'A': 71, 'P': 97}

    print(f"ペプチド: {peptide}")
    print("変換手順:")

    # ステップ1: プレフィックス質量を計算
    prefix_masses = [0]
    total = 0
    for aa in peptide:
        total += masses[aa]
        prefix_masses.append(total)

    print(f"1. プレフィックス質量: {prefix_masses}")

    # ステップ2: バイナリベクトル化
    max_mass = max(prefix_masses)
    peptide_vector = [0] * (max_mass + 1)

    for mass in prefix_masses:
        peptide_vector[mass] = 1  # プレフィックスの位置を1にする

    print(f"2. ペプチドベクトル: {peptide_vector}")
    print("   （1がある位置 = プレフィックス質量）")

peptide_vector_concept()
```

### 13-2. 逆変換も可能

```python
def reverse_peptide_vector():
    """
    ペプチドベクトルからペプチドへの逆変換
    """
    print("ペプチドベクトルからペプチドへの復元:")
    print("=" * 40)

    # サンプルのペプチドベクトル
    peptide_vector = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 1]

    # 1がある位置を見つける
    prefix_positions = []
    for i, val in enumerate(peptide_vector):
        if val == 1:
            prefix_positions.append(i)

    print(f"ベクトル内の1の位置: {prefix_positions}")

    # 差分からアミノ酸を復元
    aa_masses = {57: 'G', 71: 'A', 97: 'P'}
    peptide = ""

    for i in range(1, len(prefix_positions)):
        diff = prefix_positions[i] - prefix_positions[i-1]
        if diff in aa_masses:
            peptide += aa_masses[diff]
            print(f"  差分 {diff} → アミノ酸 {aa_masses[diff]}")

    print(f"\n復元されたペプチド: {peptide}")

reverse_peptide_vector()
```

### 13-3. ここが天才的なポイント

```python
def vector_advantages():
    """
    ベクトル表現の利点
    """
    print("ベクトル表現の革命的利点:")
    print("=" * 40)

    print("🚀 1. 内積による類似度計算")
    print("   スペクトルベクトル · ペプチドベクトル = スコア")
    print("   → 線形代数で高速計算！")

    print("\n🎯 2. 統一的なフレームワーク")
    print("   • スペクトルもペプチドも同じ空間の点")
    print("   • 距離、角度、類似度が定義できる")

    print("\n⚡ 3. 高速化の可能性")
    print("   • 行列演算による並列化")
    print("   • GPUでの高速計算")
    print("   • メモリ効率の改善")

    print("\n🔍 4. 機械学習への応用")
    print("   • ニューラルネットワークの入力")
    print("   • 特徴量エンジニアリング")
    print("   • 深層学習モデル")

vector_advantages()
```

## 📖 ステップ14：振幅計算の実装詳細

### 14-1. 実際の振幅はどう計算する？

```python
def amplitude_calculation_detail():
    """
    振幅計算の詳細実装
    """
    print("振幅計算の実装:")
    print("=" * 40)

    print("⚠️ 重要：振幅 ≠ 強度")
    print("振幅は確率的モデルに基づいて計算される複雑な値")

    print("\n📊 簡略化した例:")

    def simplified_amplitude(mass, intensity, background_noise=100):
        """
        簡略化した振幅計算
        実際にはもっと複雑な統計モデルを使用
        """
        # ノイズレベルを考慮したシンプルな変換
        if intensity > background_noise * 3:
            # 強いピーク → 正の振幅
            return int((intensity - background_noise) / 100)
        elif intensity > background_noise:
            # 中程度のピーク → 小さな正の振幅
            return int((intensity - background_noise) / 200)
        else:
            # 弱いピーク → 負の振幅（ノイズの可能性）
            return -int((background_noise - intensity) / 150)

    # サンプルデータで実験
    sample_peaks = [
        (114, 1000, "強いピーク"),
        (150, 80, "弱いピーク"),
        (242, 700, "中程度のピーク"),
        (300, 300, "普通のピーク")
    ]

    print("\n計算例:")
    for mass, intensity, desc in sample_peaks:
        amplitude = simplified_amplitude(mass, intensity)
        print(f"  質量 {mass:3d}, 強度 {intensity:4d} ({desc:8s}) → 振幅 {amplitude:2d}")

amplitude_calculation_detail()
```

### 14-2. 負の振幅の意味

```python
def negative_amplitude_meaning():
    """
    負の振幅が持つ意味
    """
    print("負の振幅の深い意味:")
    print("=" * 40)

    print("🤔 なぜ負の値が？")
    print("振幅は「ベイズ確率」の対数に関連")
    print("P(プレフィックス|ピーク) vs P(ノイズ|ピーク)")

    print("\n📊 解釈:")
    print("  正の振幅: プレフィックスである可能性 > ノイズの可能性")
    print("  負の振幅: ノイズの可能性 > プレフィックスである可能性")
    print("  ゼロ付近: どちらとも言えない")

    print("\n💡 実用的な意味:")
    examples = [
        (+9, "非常に信頼できるプレフィックス"),
        (+3, "おそらくプレフィックス"),
        (+1, "プレフィックスの可能性あり"),
        (-1, "おそらくノイズ"),
        (-5, "ノイズの可能性大")
    ]

    for amp, meaning in examples:
        print(f"  振幅 {amp:+2d}: {meaning}")

negative_amplitude_meaning()
```

## 📝 まとめ：理想から現実への大きな一歩

### レベル1：表面的理解（これだけでもOK）

- 実スペクトルはノイズだらけで複雑
- 共有ピーク数でペプチド候補を評価
- スペクトルとペプチドをベクトル化
- 振幅は強度とは異なる概念

### レベル2：本質的理解（ここまで来たら素晴らしい）

- スコアリング手法の比較（ピーク数 vs 強度）
- スペクトルベクトルの確率的意味
- ペプチドベクトルの構築と逆変換
- 振幅計算の統計的背景

### レベル3：応用的理解（プロレベル）

- ベイズ統計による振幅計算
- 機械学習モデルとの統合
- GPU並列化による高速化
- 深層学習への応用可能性

## 🚀 次回への架け橋

理想スペクトルの理論を学んだあなたは、今度は実用的なアルゴリズムの世界へ！

**続きの講義**：[ペプチド配列決定アルゴリズム](./peptide-sequencing-algorithms.md)

そこでは以下を学びます：

- 内積スコアリングの実装
- DAGによる最大重みパス問題
- De novo vs データベース検索の比較
- 実用的なハイブリッドアプローチ

理想から現実へ、より実用的なアルゴリズムの旅が始まります！

## 参考文献

- Dancik, V. et al. (1999). "De novo peptide sequencing via tandem mass spectrometry"
- Chen, T. et al. (2001). "A dynamic programming approach to de novo peptide sequencing"
- Frank, A. & Pevzner, P. (2005). "PepNovo: de novo peptide sequencing"
