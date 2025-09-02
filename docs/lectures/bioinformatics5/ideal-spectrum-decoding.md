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

## 🚀 次回予告

次回は「**ペプチドシーケンシング問題**」を学びます！

- 実際のノイズだらけのスペクトル
- スコアリング関数の設計
- 動的計画法による高速化
- データベース検索アルゴリズム

理想から現実へ、より実用的なアルゴリズムを開発します！

## 参考文献

- Dancik, V. et al. (1999). "De novo peptide sequencing via tandem mass spectrometry"
- Chen, T. et al. (2001). "A dynamic programming approach to de novo peptide sequencing"
- Frank, A. & Pevzner, P. (2005). "PepNovo: de novo peptide sequencing"
