# BWTで実現する近似パターンマッチング：変異を見つける魔法（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**ミスマッチを許容しながら高速にパターンを検索し、個人ゲノムの変異を発見する方法を完全マスター**

でも、ちょっと待ってください。そもそも、なぜ「不正確な」マッチングが必要なんでしょうか？
実は、**人間のゲノムは99.9%同じですが、残り0.1%の違いが個性や病気の原因**になるんです。その違いを見つけるには、完全一致ではなく「ほぼ一致」を探す必要があるんです！

## 🤔 ステップ0：なぜ不正確なマッチングが重要なの？

### 0-1. そもそもの問題を考えてみよう

あなたとあなたの友人のDNAを比較するとします：

```python
def show_why_approximate_matching():
    """なぜ近似マッチングが必要かを実例で説明"""

    reference = "ACGTACGTACGT"  # 参照ゲノム（標準的な配列）
    your_dna  = "ACGTACATACGT"  # あなたのDNA（1文字違い）
    #                  ^
    #                  この違いが個性や体質の違い！

    print("参照配列:", reference)
    print("あなたの配列:", your_dna)
    print()

    # 完全一致で探すと...
    if your_dna == reference:
        print("完全一致検索: マッチしません ❌")

    # でも実際は...
    differences = sum(1 for i in range(len(reference))
                     if reference[i] != your_dna[i])
    print(f"実際の違い: たった{differences}文字！")
    print("→ これが個人差の源！")

show_why_approximate_matching()
```

### 0-2. 驚きの事実

実際のゲノム解析では：

- 📖 **シーケンサーの読み取りエラー**: 0.1-1%の確率でエラー
- 🧬 **個人差（SNP）**: 300塩基に1つは違う
- 🔬 **体細胞変異**: がん細胞では多数の変異

完全一致だけでは、これらを見逃してしまいます！

## 📖 ステップ1：シード法 - 賢い分割戦略

### 1-1. まず身近な例で理解しよう

友達に電話番号を伝えるとき、1文字間違えたとします：

```python
def phone_number_analogy():
    """電話番号の例でシード法を説明"""

    correct = "090-1234-5678"
    heard   = "090-1234-5679"  # 最後の1文字を聞き間違えた
    #                        ^

    print("正しい番号:", correct)
    print("聞いた番号:", heard)
    print()

    # 番号を3つの部分に分割
    parts = heard.split('-')
    print("分割すると:")
    for i, part in enumerate(parts):
        correct_part = correct.split('-')[i]
        if part == correct_part:
            print(f"  部分{i+1}: {part} ✓ 完全一致")
        else:
            print(f"  部分{i+1}: {part} ✗ 不一致")

    print("\n重要な発見：")
    print("3つに分けると、2つは完全に一致している！")
    print("→ これがシード法の基本原理")

phone_number_analogy()
```

### 1-2. シード法の数学的原理

```python
class SeedMethod:
    """シード法の原理を実装"""

    def __init__(self):
        self.pattern = "ACGTACGTACGTACGTACGTACGTACGTACGTACG"  # 35文字
        self.mismatches = [5, 12, 18, 23, 28, 31]  # 6箇所にミスマッチ

    def demonstrate_principle(self):
        """d個のミスマッチがあるとき、d+1分割で必ず1つは完全一致する"""

        d = len(self.mismatches)  # ミスマッチ数
        num_seeds = d + 1  # 分割数

        print(f"パターン長: {len(self.pattern)}")
        print(f"ミスマッチ数: {d}")
        print(f"分割数: {num_seeds}")
        print()

        # パターンを分割
        seed_length = len(self.pattern) // num_seeds
        seeds = []

        for i in range(num_seeds):
            start = i * seed_length
            if i == num_seeds - 1:  # 最後のシード
                end = len(self.pattern)
            else:
                end = start + seed_length
            seeds.append((start, end))

        # 各シードにミスマッチが含まれるか確認
        print("各シード（部分文字列）の状況：")
        print("-" * 50)

        for i, (start, end) in enumerate(seeds):
            # このシード内のミスマッチ数を数える
            mismatches_in_seed = sum(1 for pos in self.mismatches
                                    if start <= pos < end)

            seed_str = self.pattern[start:end]
            status = "✓ 完全一致可能" if mismatches_in_seed == 0 else f"✗ {mismatches_in_seed}個のミスマッチ"

            print(f"シード{i+1} [{start:2}-{end:2}): {seed_str[:5]}... {status}")

        print("\n💡 鳩の巣原理：")
        print(f"  {d}個のミスマッチを{num_seeds}個の箱に入れると、")
        print(f"  少なくとも1つの箱は空（ミスマッチなし）！")

# デモンストレーション
seed_demo = SeedMethod()
seed_demo.demonstrate_principle()
```

## 📖 ステップ2：シード法を使った実際の検索

### 2-1. アルゴリズムの全体像

```python
class ApproximatePatternMatcher:
    """シード法による近似パターンマッチング"""

    def __init__(self, genome, max_mismatches=2):
        self.genome = genome
        self.max_mismatches = max_mismatches
        self.bwt_index = self._build_bwt_index()  # 仮想的なBWTインデックス

    def search_with_seeds(self, pattern):
        """シード法でパターンを検索"""

        print(f"🔍 パターン '{pattern}' を最大{self.max_mismatches}ミスマッチで検索")
        print("=" * 60)

        # ステップ1：パターンを分割
        num_seeds = self.max_mismatches + 1
        seeds = self._create_seeds(pattern, num_seeds)

        print(f"\nステップ1: {num_seeds}個のシードに分割")
        for i, seed in enumerate(seeds):
            print(f"  シード{i+1}: {seed['text']} (位置{seed['offset']})")

        # ステップ2：各シードを完全一致で検索
        print(f"\nステップ2: 各シードの完全一致を検索")
        candidate_positions = set()

        for i, seed in enumerate(seeds):
            # BWTで高速に完全一致を検索（シミュレーション）
            matches = self._exact_match_bwt(seed['text'])

            if matches:
                print(f"  シード{i+1}: {len(matches)}箇所で完全一致！")
                # 元のパターンの開始位置に変換
                for pos in matches:
                    original_pos = pos - seed['offset']
                    if 0 <= original_pos <= len(self.genome) - len(pattern):
                        candidate_positions.add(original_pos)
            else:
                print(f"  シード{i+1}: マッチなし")

        # ステップ3：候補位置を検証
        print(f"\nステップ3: {len(candidate_positions)}個の候補位置を検証")
        verified_matches = []

        for pos in candidate_positions:
            mismatches = self._count_mismatches(pattern, pos)
            if mismatches <= self.max_mismatches:
                verified_matches.append((pos, mismatches))
                print(f"  位置{pos}: {mismatches}個のミスマッチ ✓")

        return verified_matches

    def _create_seeds(self, pattern, num_seeds):
        """パターンをシードに分割"""
        seeds = []
        seed_length = len(pattern) // num_seeds

        for i in range(num_seeds):
            start = i * seed_length
            if i == num_seeds - 1:
                end = len(pattern)
            else:
                end = start + seed_length

            seeds.append({
                'text': pattern[start:end],
                'offset': start
            })

        return seeds

    def _exact_match_bwt(self, seed):
        """BWTで完全一致検索（シミュレーション）"""
        # 実際はBWTインデックスを使用
        matches = []
        for i in range(len(self.genome) - len(seed) + 1):
            if self.genome[i:i+len(seed)] == seed:
                matches.append(i)
        return matches

    def _count_mismatches(self, pattern, pos):
        """指定位置でのミスマッチ数を数える"""
        if pos + len(pattern) > len(self.genome):
            return float('inf')

        mismatches = 0
        for i in range(len(pattern)):
            if self.genome[pos + i] != pattern[i]:
                mismatches += 1

        return mismatches

    def _build_bwt_index(self):
        """BWTインデックスの構築（仮想）"""
        return None

# 使用例
genome = "ACGTACATACGTACGTACGTACGTACGTACGT"
pattern = "ACGTACGTACGT"
matcher = ApproximatePatternMatcher(genome, max_mismatches=2)
results = matcher.search_with_seeds(pattern)
```

## 📖 ステップ3：BWTの直接的アプローチ

### 3-1. ミスマッチを許容しながら逆向き検索

前回学んだBWTの逆向き検索を拡張します：

```python
class BWTApproximateMatcher:
    """BWTで直接的に近似マッチングを行う"""

    def __init__(self, text="panamabananas$"):
        self.text = text
        self.bwt = self._build_bwt()
        self.first_column = sorted(self.bwt)

    def _build_bwt(self):
        """簡略化されたBWT構築"""
        # 実装は省略
        return "smnpbnnaaaaa$a"

    def search_with_mismatches(self, pattern, max_mismatches=1):
        """ミスマッチを許容しながらパターンを検索"""

        print(f"🔍 '{pattern}'を最大{max_mismatches}ミスマッチで検索")
        print("=" * 60)

        # 検索状態を保持するキュー
        # (現在位置, パターンの残り, これまでのミスマッチ数, 範囲)
        queue = [(len(pattern), pattern, 0, (0, len(self.bwt)-1))]
        results = []

        while queue:
            pos, remaining, mismatches, (top, bottom) = queue.pop(0)

            # パターンを全て処理した
            if pos == 0:
                results.append((top, bottom, mismatches))
                continue

            # 次の文字
            char = remaining[-1]
            remaining = remaining[:-1]
            pos -= 1

            print(f"\n位置{pos}: 文字'{char}'を処理")
            print(f"  現在の範囲: [{top}, {bottom}]")
            print(f"  これまでのミスマッチ: {mismatches}")

            # 各文字について試す
            for symbol in set(self.bwt):
                # この文字での新しい範囲を計算
                new_top, new_bottom = self._update_range(top, bottom, symbol)

                if new_top <= new_bottom:  # 有効な範囲
                    if symbol == char:
                        # マッチ
                        print(f"    '{symbol}': マッチ ✓")
                        queue.append((pos, remaining, mismatches,
                                    (new_top, new_bottom)))
                    elif mismatches < max_mismatches:
                        # ミスマッチだが、まだ許容範囲内
                        print(f"    '{symbol}': ミスマッチ（許容）")
                        queue.append((pos, remaining, mismatches + 1,
                                    (new_top, new_bottom)))

        print(f"\n結果: {len(results)}個の近似マッチを発見！")
        for top, bottom, mismatches in results:
            count = bottom - top + 1
            print(f"  範囲[{top},{bottom}]: {count}箇所 ({mismatches}ミスマッチ)")

        return results

    def _update_range(self, top, bottom, symbol):
        """指定された文字で範囲を更新（簡略版）"""
        # 実際はFirst-Lastプロパティを使用
        # ここでは簡略化
        new_top = top  # 仮の値
        new_bottom = bottom - 1  # 仮の値
        return new_top, new_bottom

# デモンストレーション
bwt_matcher = BWTApproximateMatcher()
bwt_matcher.search_with_mismatches("ana", max_mismatches=1)
```

### 3-2. 探索木の可視化

```python
def visualize_search_tree():
    """近似マッチングの探索木を可視化"""

    print("🌳 BWTでの近似マッチング探索木")
    print()
    print("パターン: 'ana' (最大1ミスマッチ)")
    print()
    print("                     [開始]")
    print("                        |")
    print("                    'a'を探索")
    print("                   /    |    \\")
    print("               a(✓)   m(✗)   n(✗)  ← 1文字目")
    print("              /         |        \\")
    print("          'n'を探索  'n'を探索  'n'を探索")
    print("           /           |           \\")
    print("       n(✓)        n(✓)         n(✓)")
    print("        /            |             \\")
    print("    'a'を探索    'a'を探索     'a'を探索")
    print("      /             |              \\")
    print("   a(✓)          a(✓)           a(✓)")
    print("  完全一致!    1ミスマッチ!   1ミスマッチ!")
    print()
    print("✓: マッチ、✗: ミスマッチ")
    print("ミスマッチ数が上限に達したら、その枝は打ち切り")

visualize_search_tree()
```

## 📖 ステップ4：どちらの方法を使うべき？

### 4-1. 方法の比較

```python
def compare_methods():
    """シード法とBWT直接法の比較"""

    comparison = {
        "シード法": {
            "長所": [
                "実装が単純",
                "並列化しやすい",
                "メモリ効率が良い"
            ],
            "短所": [
                "シードが短いと偽陽性が多い",
                "ミスマッチ数が多いと効率低下"
            ],
            "適した用途": "少数のミスマッチ（1-3個）"
        },
        "BWT直接法": {
            "長所": [
                "柔軟性が高い",
                "ギャップも扱える",
                "確実に全ての近似マッチを発見"
            ],
            "短所": [
                "探索空間が指数的に増加",
                "実装が複雑"
            ],
            "適した用途": "複雑なエラーモデル"
        }
    }

    print("📊 近似マッチング手法の比較")
    print("=" * 60)

    for method, details in comparison.items():
        print(f"\n{method}:")
        print("  長所:")
        for pro in details["長所"]:
            print(f"    ✓ {pro}")
        print("  短所:")
        for con in details["短所"]:
            print(f"    ✗ {con}")
        print(f"  適用: {details['適した用途']}")

compare_methods()
```

## 📖 ステップ5：実際のゲノム解析での応用

### 5-1. 変異発見パイプライン

```python
class VariantDiscoveryPipeline:
    """実際の変異発見パイプライン"""

    def process_reads(self, reads, reference_genome):
        """リードをマッピングして変異を発見"""

        print("🧬 変異発見パイプライン")
        print("=" * 60)

        # ステップ1：リードのマッピング
        print("\n1. リードマッピング（近似マッチング）")
        mapped_reads = []
        for read in reads:
            # シード法で高速にマッピング
            positions = self.map_with_seeds(read, reference_genome)
            if positions:
                mapped_reads.append((read, positions))
                print(f"  ✓ リード: {read[:20]}... → {len(positions)}箇所")

        # ステップ2：変異の検出
        print("\n2. 変異の検出")
        variants = []
        for read, positions in mapped_reads:
            for pos in positions:
                mismatches = self.find_mismatches(read, reference_genome, pos)
                for mismatch_pos, ref_base, read_base in mismatches:
                    variants.append({
                        'position': pos + mismatch_pos,
                        'reference': ref_base,
                        'alternative': read_base,
                        'type': 'SNP'
                    })

        # ステップ3：変異のフィルタリング
        print("\n3. 変異のフィルタリング")
        print(f"  生の変異: {len(variants)}個")

        # 頻度でフィルタリング
        filtered = self.filter_by_frequency(variants, min_frequency=0.2)
        print(f"  フィルタ後: {len(filtered)}個")

        return filtered

    def map_with_seeds(self, read, genome):
        """シード法でリードをマッピング（簡略版）"""
        # 実装は省略
        return [100, 500, 1000]  # ダミーの位置

    def find_mismatches(self, read, genome, pos):
        """ミスマッチを検出（簡略版）"""
        # 実装は省略
        return [(5, 'A', 'G')]  # ダミーのミスマッチ

    def filter_by_frequency(self, variants, min_frequency):
        """頻度でフィルタリング（簡略版）"""
        # 実際は複数のリードからの情報を統合
        return variants[:5]  # ダミーの結果

# 使用例
pipeline = VariantDiscoveryPipeline()
reads = ["ACGTACGTACGT", "ACGTACATACGT", "ACGTACGTACGT"]
reference = "ACGTACGTACGTACGTACGT" * 100
variants = pipeline.process_reads(reads, reference)
```

## 📖 ステップ6：計算量とメモリのトレードオフ

### 6-1. 複雑度の分析

```python
def analyze_complexity():
    """各手法の計算複雑度を分析"""

    print("⚡ 計算複雑度の分析")
    print("=" * 60)

    n = 3_000_000_000  # ゲノムサイズ
    m = 100  # パターン長
    d = 3  # 最大ミスマッチ数

    print(f"前提条件:")
    print(f"  ゲノムサイズ(n): {n:,}")
    print(f"  パターン長(m): {m}")
    print(f"  最大ミスマッチ(d): {d}")
    print()

    # ナイーブな方法
    naive_time = n * m * d
    print(f"ナイーブな方法:")
    print(f"  時間: O(n×m×d) = {naive_time:,}")
    print(f"  → 実用的ではない！")
    print()

    # シード法
    seed_time = (m / (d + 1)) * n / 1000 + n * d  # BWTで1000倍高速化
    print(f"シード法 + BWT:")
    print(f"  時間: O(m/(d+1) × n/1000 + n×d)")
    print(f"  → {naive_time / seed_time:.0f}倍高速！")
    print()

    # BWT直接法
    alphabet = 4  # DNA
    bwt_time = m * (alphabet ** d)
    print(f"BWT直接法:")
    print(f"  時間: O(m × |Σ|^d) = {bwt_time:,}")
    print(f"  → dが小さければ高速")

analyze_complexity()
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- **近似マッチング** = ミスマッチを許容したパターン検索
- **シード法** = パターンを分割して、完全一致する部分から探す
- **BWT直接法** = ミスマッチを記録しながら逆向き検索

### レベル2：本質的理解（ここまで来たら素晴らしい）

- **鳩の巣原理の応用**
  - d個のミスマッチをd+1分割すれば、1つは完全一致
  - これが高速化の鍵
- **探索空間の制御**
  - ミスマッチ数で枝刈り
  - BWTで効率的に候補を絞る
- **変異発見への応用**
  - 個人ゲノムの違いを発見
  - 病気の原因遺伝子の特定

### レベル3：応用的理解（プロレベル）

- **ハイブリッドアプローチ**
  - シード法で候補を絞る
  - BWT直接法で詳細検証
- **実装の最適化**
  - シード長の動的調整
  - 並列処理の活用
- **実用システムでの統合**
  - BWA-MEM：シード拡張法
  - Bowtie2：FM-indexベース

## 🧪 実験課題（やってみよう）

```python
# 課題1：最適なシード長を見つける
def find_optimal_seed_length(pattern_length, max_mismatches):
    """
    偽陽性と計算時間のバランスを考慮して
    最適なシード長を決定
    """
    pass

# 課題2：ギャップを考慮した近似マッチング
def approximate_matching_with_gaps(pattern, genome, max_errors):
    """
    ミスマッチだけでなく、挿入・削除も
    考慮した近似マッチング
    """
    pass

# 課題3：品質スコアを使った重み付け
def weighted_approximate_matching(pattern, qualities, genome):
    """
    シーケンサーの品質スコアを使って
    信頼度の低い位置のミスマッチを許容
    """
    pass
```

## 🔮 次回予告：リードマッピングの実践

次回は、今日学んだ技術を統合して**実際のリードマッピング**を行います！

- 100万本のリードを高速にマッピング
- マッピング品質の評価
- 重複領域への対処法

現代のゲノム解析の最前線技術を完全マスターします！

---

_Bioinformatics Algorithms: An Active Learning Approach_ より
_第7章：パターンマッチングの革命 - 近似マッチング編_
