# リードマッピングの驚くべき応用：構造変異からRNAまで（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**リードマッピングで構造変異やスプライシングなど、複雑なゲノム現象を解明する方法を完全マスター**

でも、ちょっと待ってください。これまでは単純な点変異（SNP）を見つける話でしたよね？
実は、ゲノムには**大規模な構造変化**が潜んでいて、それが病気の原因になることがあるんです。さらに、**RNA解析**にも同じ技術が使えるという驚きの事実があります！

## 🤔 ステップ0：なぜ構造変異が重要なの？

### 0-1. そもそもの問題を考えてみよう

本を読んでいて、こんな変化を想像してください：

```python
def book_analogy():
    """本の編集ミスで構造変異を理解"""

    original_book = """
    第1章：序論
    第2章：基礎理論
    第3章：応用編
    第4章：実践例
    第5章：まとめ
    """

    # さまざまな編集ミス（構造変異）
    errors = {
        "削除": "第3章が丸ごと抜けている",
        "重複": "第2章が2回印刷されている",
        "逆位": "第3章が逆さまに印刷されている",
        "転座": "第4章が第2章の位置に移動",
        "挿入": "謎の第2.5章が追加されている"
    }

    print("📚 本の編集ミスとゲノムの構造変異")
    print("=" * 50)
    print("正常な本:")
    print(original_book)
    print("\n編集ミス（構造変異）の例：")
    for error_type, description in errors.items():
        print(f"  {error_type}: {description}")

    print("\n💡 ゲノムでも同じことが起きます！")
    print("   これらの変化が病気の原因になることも...")

book_analogy()
```

### 0-2. 驚きの事実

構造変異の影響は想像以上に大きいんです：

- 🧬 **個人差の50%以上**は構造変異による
- 🦠 **がんの90%**で大規模な構造変異が発生
- 🧪 **遺伝病の15%**は構造変異が原因

点変異だけ見ていては、これらを見逃してしまいます！

## 📖 ステップ1：ペアエンドリードの魔法

### 1-1. まず、橋の建設で理解しよう

```python
def bridge_construction_analogy():
    """橋の建設でペアエンドリードを説明"""

    print("🌉 橋の建設とペアエンドリード")
    print("=" * 50)

    # 正常な橋
    print("\n正常な橋（300メートル）：")
    print("岸A ===== 橋脚1 ===== 橋脚2 ===== 岸B")
    print("     100m      100m      100m")

    # ペアエンドリード = 両端から測定
    print("\nペアエンドリード方式の測定：")
    print("1. 岸Aから100m地点を測定 → 橋脚1")
    print("2. 岸Bから100m地点を測定 → 橋脚2")
    print("3. 橋脚間の距離を計算 → 100m ✓ 正常")

    # 構造に問題がある橋
    print("\n問題のある橋：")
    print("岸A ===== 橋脚1 ========== 橋脚2 ===== 岸B")
    print("     100m         150m          100m")

    print("\nペアエンドで検出：")
    print("橋脚間の距離が150m！")
    print("→ 構造に異常あり！危険！")

    print("\n💡 ゲノムでも同じ原理で構造変異を検出")

bridge_construction_analogy()
```

### 1-2. ペアエンドリードの仕組み

```python
class PairedEndReadMapping:
    """ペアエンドリードマッピングの実装"""

    def __init__(self, expected_insert_size=300, tolerance=50):
        """
        expected_insert_size: 期待されるインサートサイズ
        tolerance: 許容誤差
        """
        self.expected_insert_size = expected_insert_size
        self.tolerance = tolerance

    def analyze_read_pair(self, read1_pos, read2_pos, read1_orientation, read2_orientation):
        """リードペアを解析して構造変異を検出"""

        # 距離を計算
        distance = abs(read2_pos - read1_pos)

        # 期待値との差
        size_diff = distance - self.expected_insert_size

        print(f"📊 リードペア解析")
        print(f"  Read1: 位置{read1_pos}, 向き{read1_orientation}")
        print(f"  Read2: 位置{read2_pos}, 向き{read2_orientation}")
        print(f"  距離: {distance}bp (期待値: {self.expected_insert_size}bp)")

        # 構造変異の判定
        if abs(size_diff) <= self.tolerance:
            if read1_orientation == "→" and read2_orientation == "←":
                print("  → 正常なマッピング ✓")
                return "normal"

        # 異常パターンの検出
        if distance > self.expected_insert_size + self.tolerance:
            print("  → 削除の可能性！🔴")
            return "deletion"
        elif distance < self.expected_insert_size - self.tolerance:
            print("  → 挿入の可能性！🔵")
            return "insertion"
        elif read1_orientation == read2_orientation:
            print("  → 逆位の可能性！🔄")
            return "inversion"
        else:
            print("  → 転座の可能性！↔️")
            return "translocation"

    def demonstrate_all_variants(self):
        """すべての構造変異パターンを実演"""

        print("🧬 構造変異の検出パターン")
        print("=" * 60)

        test_cases = [
            ("正常", 100, 400, "→", "←"),
            ("削除", 100, 600, "→", "←"),
            ("挿入", 100, 200, "→", "←"),
            ("逆位", 100, 400, "→", "→"),
            ("転座", 100, 10000, "→", "←")
        ]

        for name, r1_pos, r2_pos, r1_dir, r2_dir in test_cases:
            print(f"\n{name}のケース：")
            self.analyze_read_pair(r1_pos, r2_pos, r1_dir, r2_dir)

# デモンストレーション
mapper = PairedEndReadMapping()
mapper.demonstrate_all_variants()
```

## 📖 ステップ2：構造変異の詳細な種類

### 2-1. すべての構造変異を理解しよう

```python
def visualize_structural_variants():
    """構造変異の種類を視覚的に説明"""

    print("🧬 構造変異の完全ガイド")
    print("=" * 60)

    # 参照配列
    reference = "ABCDEFGHIJKLMNOP"
    print(f"参照配列: {reference}")
    print()

    variants = {
        "削除 (Deletion)": {
            "結果": "ABCD------JKLMNOP",
            "説明": "EFGHIが削除された",
            "影響": "遺伝子の機能喪失"
        },
        "挿入 (Insertion)": {
            "結果": "ABCD[XXX]EFGHIJKLMNOP",
            "説明": "XXXが挿入された",
            "影響": "フレームシフト、機能変化"
        },
        "重複 (Duplication)": {
            "結果": "ABCDEFGHDEFGHIJKLMNOP",
            "説明": "DEFGHが2回繰り返し",
            "影響": "遺伝子量の増加"
        },
        "逆位 (Inversion)": {
            "結果": "ABCDIHGFEJKLMNOP",
            "説明": "EFGHIが逆向きに",
            "影響": "遺伝子の破壊、融合遺伝子"
        },
        "転座 (Translocation)": {
            "結果": "ABCDMNOPEFGHIJKL",
            "説明": "MNOPが前に移動",
            "影響": "染色体間の交換"
        }
    }

    for variant_type, details in variants.items():
        print(f"{variant_type}:")
        print(f"  参照: {reference}")
        print(f"  変異: {details['結果']}")
        print(f"  説明: {details['説明']}")
        print(f"  臨床的影響: {details['影響']}")
        print()

visualize_structural_variants()
```

### 2-2. 実際のゲノムでの例

```python
class RealWorldExamples:
    """実際の疾患に関連する構造変異の例"""

    def show_disease_examples(self):
        """疾患関連の構造変異"""

        print("🏥 疾患に関連する構造変異の実例")
        print("=" * 60)

        examples = [
            {
                "疾患": "慢性骨髄性白血病（CML）",
                "変異": "転座 t(9;22)",
                "結果": "BCR-ABL融合遺伝子",
                "治療": "イマチニブ（グリベック）"
            },
            {
                "疾患": "デュシェンヌ型筋ジストロフィー",
                "変異": "大規模削除",
                "結果": "ジストロフィン遺伝子の欠失",
                "治療": "エクソンスキッピング療法"
            },
            {
                "疾患": "ハンチントン病",
                "変異": "トリプレットリピート伸長",
                "結果": "CAGリピートの増加（36回以上）",
                "治療": "対症療法（根治療法開発中）"
            }
        ]

        for example in examples:
            print(f"\n{example['疾患']}:")
            print(f"  構造変異: {example['変異']}")
            print(f"  分子的結果: {example['結果']}")
            print(f"  治療法: {example['治療']}")

        print("\n💡 構造変異の検出が新薬開発につながる！")

# 実例を表示
examples = RealWorldExamples()
examples.show_disease_examples()
```

## 📖 ステップ3：RNA-Seqでのスプライス検出

### 3-1. まず、映画の編集で理解しよう

```python
def movie_editing_analogy():
    """映画編集でスプライシングを説明"""

    print("🎬 映画編集とRNAスプライシング")
    print("=" * 60)

    # 撮影した全シーン（ゲノムDNA）
    raw_footage = [
        "オープニング",     # エクソン1
        "NGシーン1",        # イントロン1
        "アクションシーン",  # エクソン2
        "NGシーン2",        # イントロン2
        "ラブシーン",       # エクソン3
        "NGシーン3",        # イントロン3
        "エンディング"      # エクソン4
    ]

    print("撮影した全シーン（DNA）：")
    for i, scene in enumerate(raw_footage):
        if "NG" in scene:
            print(f"  {i+1}. {scene} ❌ カット")
        else:
            print(f"  {i+1}. {scene} ✓ 採用")

    # 編集後の映画（mRNA）
    final_movie = [s for s in raw_footage if "NG" not in s]

    print("\n編集後の映画（mRNA）：")
    print(" → ".join(final_movie))

    print("\n💡 RNAスプライシングも同じ！")
    print("   イントロンをカットして、エクソンをつなぐ")

movie_editing_analogy()
```

### 3-2. スプリットリードマッピング

```python
class SplitReadMapper:
    """スプリットリードマッピングでスプライス接合を検出"""

    def __init__(self):
        self.exons = {
            "exon1": (1000, 1200),
            "exon2": (2000, 2150),
            "exon3": (3000, 3180),
            "exon4": (4000, 4200)
        }

    def map_split_read(self, read_sequence):
        """スプリットリードをマッピング"""

        print(f"📖 リード: {read_sequence}")
        print("=" * 50)

        # リードを2つの部分に分割（簡略化）
        split_point = len(read_sequence) // 2
        part1 = read_sequence[:split_point]
        part2 = read_sequence[split_point:]

        print(f"前半: {part1}")
        print(f"後半: {part2}")
        print()

        # 各部分をエクソンにマッピング（シミュレーション）
        print("マッピング結果：")
        print(f"  前半 → exon2の末尾（位置2140-2150）")
        print(f"  後半 → exon3の先頭（位置3000-3010）")
        print()

        # スプライス接合の検出
        print("🔍 スプライス接合を検出！")
        print(f"  exon2（終了:2150） → exon3（開始:3000）")
        print(f"  イントロン長: {3000-2150}bp")

        return ("exon2", "exon3", 3000-2150)

    def visualize_splicing(self):
        """スプライシングパターンを可視化"""

        print("\n🧬 検出されたスプライシングパターン")
        print("=" * 60)

        # ゲノム上の配置
        print("ゲノムDNA:")
        print("--[exon1]--intron1--[exon2]--intron2--[exon3]--intron3--[exon4]--")

        # 通常のスプライシング
        print("\n通常のスプライシング（全エクソン含む）:")
        print("[exon1]-[exon2]-[exon3]-[exon4]")

        # 選択的スプライシング
        print("\n選択的スプライシングの例：")
        patterns = [
            ("[exon1]-[exon2]-[exon4]", "exon3スキッピング"),
            ("[exon1]-[exon3]-[exon4]", "exon2スキッピング"),
            ("[exon1]-[exon2a]-[exon3]", "エクソン内部の選択的使用")
        ]

        for pattern, description in patterns:
            print(f"  {pattern}")
            print(f"    → {description}")

    def detect_novel_isoforms(self):
        """新規アイソフォームの検出"""

        print("\n🔬 新規アイソフォームの発見")
        print("=" * 60)

        print("従来の知識：")
        print("  アイソフォームA: exon1-2-3-4")
        print("  アイソフォームB: exon1-2-4")
        print()

        print("RNA-Seqで新発見：")
        print("  アイソフォームC: exon1-3-4 🆕")
        print("  アイソフォームD: exon1-2a-2b-3-4 🆕")
        print()

        print("💡 これらの新規アイソフォームが")
        print("   疾患特異的な場合があり、")
        print("   新しい治療標的になる可能性！")

# デモンストレーション
mapper = SplitReadMapper()
read = "ATCGATCG...GCTAGCTA"
mapper.map_split_read(read)
mapper.visualize_splicing()
mapper.detect_novel_isoforms()
```

## 📖 ステップ4：統合解析パイプライン

### 4-1. 構造変異とRNA-Seqの統合

```python
class IntegratedAnalysisPipeline:
    """DNA変異とRNA発現を統合的に解析"""

    def analyze_cancer_sample(self):
        """がんサンプルの統合解析"""

        print("🔬 がんゲノムの統合解析パイプライン")
        print("=" * 60)

        # ステップ1：DNA-Seq
        print("\n1️⃣ DNA-Seq解析")
        print("  ✓ 点変異: TP53 p.R273H")
        print("  ✓ 削除: CDKN2A完全欠失")
        print("  ✓ 転座: EML4-ALK融合")

        # ステップ2：RNA-Seq
        print("\n2️⃣ RNA-Seq解析")
        print("  ✓ 融合遺伝子の発現確認")
        print("  ✓ 選択的スプライシングの変化")
        print("  ✓ 遺伝子発現プロファイル")

        # ステップ3：統合解釈
        print("\n3️⃣ 統合解釈")
        print("  → EML4-ALK融合が発現している")
        print("  → ALK阻害剤が有効な可能性")
        print("  → 個別化医療の実現！")

    def show_clinical_impact(self):
        """臨床的インパクト"""

        print("\n💊 実際の治療への応用")
        print("=" * 60)

        treatments = {
            "構造変異": {
                "BCR-ABL転座": "イマチニブ",
                "EML4-ALK転座": "クリゾチニブ",
                "ROS1転座": "ロルラチニブ"
            },
            "スプライシング異常": {
                "SF3B1変異": "スプライシング調節薬",
                "U2AF1変異": "免疫療法の適応"
            }
        }

        for category, examples in treatments.items():
            print(f"\n{category}に基づく治療：")
            for mutation, drug in examples.items():
                print(f"  {mutation} → {drug}")

# 実行
pipeline = IntegratedAnalysisPipeline()
pipeline.analyze_cancer_sample()
pipeline.show_clinical_impact()
```

## 📖 ステップ5：計算上の課題と解決策

### 5-1. 処理速度とメモリの最適化

```python
def computational_challenges():
    """計算上の課題と解決策"""

    print("⚡ 計算上の課題")
    print("=" * 60)

    # データ量の計算
    print("データ規模：")
    print("  1サンプル: 30億塩基 × 30倍カバレッジ")
    print("  = 900億塩基のシーケンスデータ")
    print("  = 約100GBの生データ")
    print()

    print("構造変異検出の課題：")
    challenges = {
        "偽陽性": "反復配列での誤ったマッピング",
        "感度": "複雑な再構成の見逃し",
        "計算時間": "全リードペアの比較に時間がかかる"
    }

    for challenge, description in challenges.items():
        print(f"  {challenge}: {description}")

    print("\n解決策：")
    solutions = [
        "1. 階層的アプローチ（粗い検索→詳細検証）",
        "2. 機械学習による偽陽性フィルタリング",
        "3. クラウドコンピューティングの活用",
        "4. GPUアクセラレーション"
    ]

    for solution in solutions:
        print(f"  {solution}")

computational_challenges()
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- **ペアエンドリード** = 両端から読んで距離を測る
- **構造変異** = 削除、挿入、逆位、転座など大規模な変化
- **RNA-Seq** = スプライシングを検出、新規アイソフォーム発見

### レベル2：本質的理解（ここまで来たら素晴らしい）

- **距離と向きの異常**が構造変異のシグナル
  - 期待値と実測値の差から変異を推定
  - リードの向きから逆位や転座を検出
- **スプリットリードマッピング**
  - リードを分割してエクソン接合を発見
  - 新規スプライシングパターンの同定
- **統合解析の重要性**
  - DNAとRNAの情報を組み合わせる
  - 変異の機能的影響を評価

### レベル3：応用的理解（プロレベル）

- **アルゴリズムの選択**
  - 短い挿入削除：スプリットリード
  - 大規模変異：ペアエンドリード
  - 複雑な再構成：de novoアセンブリ
- **臨床応用**
  - 融合遺伝子による分子標的薬の選択
  - スプライシング異常による診断
- **技術的課題**
  - 反復配列での誤検出
  - 計算リソースの最適化

## 🧪 実験課題（やってみよう）

```python
# 課題1：構造変異シミュレーター
def simulate_structural_variant(reference, variant_type):
    """
    参照配列に構造変異を導入し、
    ペアエンドリードでどう見えるか
    シミュレーション
    """
    pass

# 課題2：スプライシング検出器
def detect_splice_junctions(reads, exon_boundaries):
    """
    スプリットリードから
    スプライス接合を検出
    """
    pass

# 課題3：統合解析器
def integrated_variant_caller(dna_seq, rna_seq):
    """
    DNA-SeqとRNA-Seqのデータを統合して
    機能的に重要な変異を優先順位付け
    """
    pass
```

## 🔮 次回予告：ゲノムアセンブリへの挑戦

次回は、リードマッピングの究極の応用：**de novoゲノムアセンブリ**に挑戦！

- リファレンスなしでゲノムを再構築
- グラフ理論の応用
- ロングリードとショートリードの統合

パズルのピースから全体像を組み立てる、究極のチャレンジです！

---

_Bioinformatics Algorithms: An Active Learning Approach_ より
_第7章：パターンマッチングの革命 - 応用編_
