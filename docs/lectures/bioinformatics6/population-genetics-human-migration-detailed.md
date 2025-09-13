# 人類は地球上にどのように人口を増やしてきたのか - 集団遺伝学アルゴリズム入門（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**人類の移動と拡散の歴史を、ゲノムデータから読み解くアルゴリズムを理解し、集団遺伝学の計算手法を完全習得すること**

でも、ちょっと待ってください。そもそも、なぜゲノムから人類の歴史がわかるのでしょうか？
実は、私たちのDNAには**数万年にわたる祖先の旅の記録**が刻まれているんです！

## 🤔 ステップ0：なぜゲノムから人類史がわかるの？

### 0-1. まず身近な例で考えてみよう

想像してみてください。あなたが古い家系図を調べているとします：

```python
class FamilyTreeAnalogy:
    def __init__(self):
        self.your_features = {
            "目の色": "茶色",
            "髪の質": "直毛",
            "血液型": "A型",
            "特徴的な遺伝子": "ABCC11（乾型耳垢）"
        }

    def trace_ancestry(self):
        """
        家族の特徴から歴史を推測
        """
        return """
        もし、あなたの家族に以下の特徴があったら？

        1. 祖父母の世代：全員が同じ特徴を持つ
           → 共通の祖先を持つ可能性

        2. いとこ同士：一部の特徴を共有
           → 共通の祖父母から遺伝

        3. 遠い親戚：わずかな特徴のみ共有
           → より古い共通祖先

        つまり、遺伝的特徴の共有度 = 血縁関係の近さ！
        """
```

### 0-2. 驚きの事実：アフリカ単一起源説

```python
def out_of_africa_theory():
    """
    人類のアフリカ起源説の証拠
    """
    evidence = {
        "遺伝的多様性": "アフリカ > その他の地域",
        "最古の化石": "アフリカで発見",
        "ミトコンドリアDNA": "アフリカの女性に収束",
        "Y染色体": "アフリカの男性に収束"
    }

    timeline = """
    約20万年前：現生人類（ホモ・サピエンス）がアフリカで誕生
    約7万年前：アフリカから出発（Out of Africa）
    約4.5万年前：ヨーロッパに到達
    約4万年前：オーストラリアに到達
    約1.5万年前：アメリカ大陸に到達
    """

    return evidence, timeline
```

## 📖 ステップ1：遺伝的変異という「タイムスタンプ」

### 1-1. 突然変異は時計のように刻まれる

人類の移動の歴史を理解するには、まず「遺伝的変異」という概念を理解する必要があります：

```python
class GeneticMutation:
    def __init__(self):
        self.mutation_rate = 1e-8  # 1世代あたり、1塩基あたりの変異率
        self.generation_time = 25  # 年

    def molecular_clock(self):
        """
        分子時計の原理
        """
        return """
        DNAの突然変異は一定の速度で蓄積される

        例：ある遺伝子座で...
        祖先の配列：ATCGATCG
        ↓ 1000世代後
        子孫A：ATCGATCG（変化なし）
        子孫B：ATCGACCG（1箇所変異）
        子孫C：ATTGATCG（1箇所変異、別の場所）

        変異の数 ∝ 分岐してからの時間！
        """

    def calculate_divergence_time(self, num_mutations, genome_length):
        """
        分岐時間の推定
        """
        # 変異率から時間を逆算
        generations = num_mutations / (self.mutation_rate * genome_length * 2)
        years = generations * self.generation_time

        return f"""
        {num_mutations}個の変異が見つかった場合：

        計算：
        世代数 = {num_mutations} / (10^-8 × {genome_length} × 2)
        年数 = 世代数 × 25年

        推定分岐時間：約{years:,.0f}年前
        """
```

### 1-2. 変異のタイプと情報量

```python
class MutationTypes:
    def __init__(self):
        self.types = {
            "SNP": "一塩基多型（Single Nucleotide Polymorphism）",
            "Indel": "挿入・欠失",
            "CNV": "コピー数多型",
            "STR": "短い反復配列"
        }

    def snp_example(self):
        """
        SNPの具体例
        """
        return """
        集団Aの配列：...ATCGATCG...
        集団Bの配列：...ATCGACCG...
                          ↑
                       SNP（T→C）

        このSNPが：
        - 集団Aには存在しない
        - 集団Bの80%に存在する

        → 集団Bで新しく生じた変異
        → 集団Bの移動経路の手がかり！
        """
```

## 📖 ステップ2：集団遺伝学の基本法則

### 2-1. ハーディ・ワインベルグ平衡

集団遺伝学の基礎となる重要な法則から始めましょう：

```python
class HardyWeinbergEquilibrium:
    def __init__(self):
        self.assumptions = [
            "ランダム交配",
            "突然変異なし",
            "自然選択なし",
            "遺伝的浮動なし",
            "移住なし"
        ]

    def calculate_genotype_frequencies(self, p, q):
        """
        遺伝子型頻度の計算
        p: アレルAの頻度
        q: アレルaの頻度（p + q = 1）
        """
        AA = p ** 2
        Aa = 2 * p * q
        aa = q ** 2

        return f"""
        アレル頻度：
        A = {p}, a = {q}

        予測される遺伝子型頻度：
        AA = p² = {AA:.3f}
        Aa = 2pq = {Aa:.3f}
        aa = q² = {aa:.3f}

        合計 = {AA + Aa + aa:.3f}（必ず1.0）
        """

    def real_world_example(self):
        """
        実世界の例：鎌状赤血球症
        """
        return """
        マラリア流行地域での例：

        HbS（鎌状赤血球）アレル頻度 = 0.1
        HbA（正常）アレル頻度 = 0.9

        予測頻度：
        HbA/HbA（正常）= 0.9² = 0.81（81%）
        HbA/HbS（保因者）= 2×0.9×0.1 = 0.18（18%）
        HbS/HbS（鎌状赤血球症）= 0.1² = 0.01（1%）

        なぜHbSが消えない？
        → HbA/HbS保因者はマラリア耐性を持つ！
        → 平衡選択の例
        """
```

### 2-2. 遺伝的浮動の威力

```python
import random
import numpy as np

class GeneticDrift:
    def __init__(self, population_size):
        self.N = population_size

    def simulate_drift(self, initial_freq, generations):
        """
        遺伝的浮動のシミュレーション
        """
        freq_history = [initial_freq]
        current_freq = initial_freq

        for gen in range(generations):
            # 次世代のアレルをランダムサンプリング
            alleles = np.random.binomial(2 * self.N, current_freq)
            current_freq = alleles / (2 * self.N)
            freq_history.append(current_freq)

            if current_freq == 0 or current_freq == 1:
                # 固定または消失
                break

        return freq_history

    def bottleneck_effect(self):
        """
        ボトルネック効果の説明
        """
        return """
        🍾 ボトルネック効果の例：

        創始者効果（Founder Effect）:
        1. 大集団（1万人）から小集団（100人）が分離
        2. たまたま珍しいアレルを持つ人が多く含まれる
        3. 新しい集団でそのアレルが高頻度に！

        実例：アシュケナージ系ユダヤ人
        - テイ・サックス病の保因者率：1/27
        - 一般集団：1/250

        → 中世の迫害によるボトルネック効果
        """
```

## 📖 ステップ3：人類移動を追跡するマーカー

### 3-1. ミトコンドリアDNA（母系遺伝）

```python
class MitochondrialDNA:
    def __init__(self):
        self.properties = {
            "サイズ": "16,569塩基対",
            "遺伝様式": "母系遺伝のみ",
            "組換え": "なし",
            "コピー数": "細胞あたり数百〜数千",
            "変異率": "核DNAの10倍"
        }

    def mitochondrial_eve(self):
        """
        ミトコンドリア・イブの概念
        """
        return """
        🧬 ミトコンドリア・イブとは？

        全人類の母系を辿ると一人の女性に行き着く

        重要な誤解を解く：
        ❌ 当時女性が一人しかいなかった
        ✅ 他の女性の母系が途絶えた

        なぜ途絶える？
        - 女児が生まれない
        - 子供が生まれない
        - 偶然の積み重ね（遺伝的浮動）

        推定：約15-20万年前のアフリカ女性
        """

    def haplogroups(self):
        """
        ハプログループによる移動追跡
        """
        return """
        主要なミトコンドリアハプログループ：

        L0, L1, L2, L3：アフリカ
        ↓
        M, N：アフリカ出発後すぐに分岐
        ↓
        R：Nから派生、ユーラシア全体へ
        ↓
        H：ヨーロッパで最多（40-50%）
        A, B, C, D：アジア・アメリカ先住民

        日本人の構成：
        D4：約35%（縄文系）
        M7：約15%（縄文系）
        B, F, A：各5-10%（弥生系）
        """
```

### 3-2. Y染色体（父系遺伝）

```python
class YChromosome:
    def __init__(self):
        self.properties = {
            "サイズ": "約6000万塩基対",
            "遺伝様式": "父系遺伝のみ",
            "組換え": "擬似常染色体領域を除きなし",
            "特徴": "男性のみが持つ"
        }

    def y_chromosomal_adam(self):
        """
        Y染色体アダムの概念
        """
        return """
        👨 Y染色体アダムとは？

        全男性の父系を辿ると一人の男性に行き着く

        興味深い事実：
        - 推定年代：約20-30万年前
        - ミトコンドリア・イブより古い可能性
        - これも遺伝的浮動の結果

        なぜ年代が異なる？
        → 男女の繁殖成功率の違い
        → 一夫多妻の影響
        → サンプリングの偶然
        """

    def japanese_y_haplogroups(self):
        """
        日本人のY染色体ハプログループ
        """
        return """
        日本人男性のY染色体構成：

        D1a2a（D-M55）：約35%
        - 縄文系
        - チベット以外では日本特有
        - 3万年以上前に分岐

        O1b2（O-P49）：約30%
        - 弥生系
        - 朝鮮半島経由
        - 稲作と共に流入

        O2（O-M122）：約20%
        - 弥生系
        - 中国大陸由来

        C1a1（C-M8）：約5%
        - 古い縄文系
        - 最初期の日本列島到達者？
        """
```

## 📖 ステップ4：集団間の遺伝的距離

### 4-1. FST（集団分化指数）

```python
class PopulationDifferentiation:
    def __init__(self):
        self.name = "Wright's FST"

    def calculate_fst(self, pop1_freq, pop2_freq):
        """
        2集団間のFSTを計算
        """
        # 各集団のアレル頻度
        p1, p2 = pop1_freq, pop2_freq

        # 全体のアレル頻度
        p_total = (p1 + p2) / 2

        # ヘテロ接合度
        Hs = (2*p1*(1-p1) + 2*p2*(1-p2)) / 2  # 集団内
        Ht = 2*p_total*(1-p_total)  # 全体

        # FST計算
        Fst = (Ht - Hs) / Ht if Ht > 0 else 0

        return f"""
        集団1のアレル頻度：{p1}
        集団2のアレル頻度：{p2}

        FST = {Fst:.3f}

        解釈：
        FST = 0：完全に同じ
        FST < 0.05：ほとんど分化なし
        FST = 0.05-0.15：中程度の分化
        FST = 0.15-0.25：大きな分化
        FST > 0.25：非常に大きな分化
        """

    def human_fst_examples(self):
        """
        人類集団間のFST実例
        """
        return """
        🌍 人類集団間のFST値：

        全人類の平均FST = 0.12
        （チンパンジーの亜種間FST = 0.32）

        具体例：
        - ヨーロッパ人 vs アジア人：0.06
        - ヨーロッパ人 vs アフリカ人：0.15
        - アジア人 vs アフリカ人：0.19
        - 日本人 vs 韓国人：0.007
        - 本州日本人 vs 沖縄人：0.024

        驚きの事実：
        人類の遺伝的多様性の85%は集団内に存在！
        集団間の違いはわずか15%
        """
```

### 4-2. 主成分分析（PCA）による可視化

```python
import numpy as np
from sklearn.decomposition import PCA

class PopulationPCA:
    def __init__(self):
        self.description = "遺伝的変異の主成分分析"

    def simulate_pca(self):
        """
        集団遺伝学的PCAのシミュレーション
        """
        # 仮想的な遺伝子型データ（個体×SNP）
        np.random.seed(42)

        # 3集団をシミュレート
        pop1 = np.random.normal(0, 1, (100, 1000))
        pop2 = np.random.normal(2, 1, (100, 1000))
        pop3 = np.random.normal(1, 1.5, (100, 1000))

        data = np.vstack([pop1, pop2, pop3])

        # PCA実行
        pca = PCA(n_components=2)
        transformed = pca.fit_transform(data)

        return """
        PCAで見える集団構造：

        PC1（第1主成分）：
        - 最大の遺伝的変異を説明
        - 通常は大陸間の違い

        PC2（第2主成分）：
        - 2番目に大きな変異
        - 大陸内の違い

        ヨーロッパの例：
        北西 ←PC1→ 南東
        （スカンジナビア → イタリア/ギリシャ）

        なぜ地理と相関？
        → 距離による隔離（Isolation by Distance）
        → 移住の制限
        → 地理的障壁（山脈、海）
        """
```

## 📖 ステップ5：人類大移動の追跡アルゴリズム

### 5-1. 合体理論（Coalescent Theory）

```python
class CoalescentTheory:
    def __init__(self, population_size):
        self.Ne = population_size  # 有効集団サイズ

    def time_to_coalescence(self, n_lineages):
        """
        n系統が合体するまでの期待時間
        """
        expected_time = 0

        for k in range(n_lineages, 1, -1):
            # k系統がk-1系統になるまでの時間
            t_k = (2 * self.Ne) / (k * (k - 1))
            expected_time += t_k

        return f"""
        {n_lineages}系統が1つの共通祖先に合体するまで：

        期待時間 = {expected_time:.0f}世代
        年換算 = {expected_time * 25:.0f}年

        各ステップ：
        {n_lineages}→{n_lineages-1}系統：{(2*self.Ne)/(n_lineages*(n_lineages-1)):.0f}世代
        ...
        2→1系統：{2*self.Ne:.0f}世代
        """

    def migration_model(self):
        """
        移住を含む合体モデル
        """
        return """
        🚶 移住を考慮した合体過程：

        2集団モデル：
        集団A（サイズNA） ⟷ 集団B（サイズNB）
                移住率m

        時間を遡ると：
        1. 同じ集団内で合体
        2. 移住により集団を移動
        3. 最終的に共通祖先へ

        移住率mが大きい → 集団間の違い小さい
        移住率mが小さい → 集団間の違い大きい

        これがFSTと関連：
        FST ≈ 1/(1 + 4Nm)
        """
```

### 5-2. ADMIXTURE解析

```python
class AdmixtureAnalysis:
    def __init__(self):
        self.description = "祖先集団の混合比率を推定"

    def admixture_model(self, k_populations):
        """
        ADMIXTURE解析の原理
        """
        return f"""
        K={k_populations}個の祖先集団を仮定：

        各個体のゲノム = 祖先集団の混合

        例：K=3の場合
        個体A：60% 集団1 + 30% 集団2 + 10% 集団3
        個体B：5% 集団1 + 90% 集団2 + 5% 集団3

        アルゴリズム：
        1. ランダムな初期値設定
        2. EMアルゴリズムで最尤推定
        3. 収束まで繰り返し
        """

    def real_world_example(self):
        """
        実際のADMIXTURE解析例
        """
        return """
        🧬 アメリカ大陸の例：

        メキシコ人の平均的構成：
        - ヨーロッパ系：50-60%
        - アメリカ先住民系：35-45%
        - アフリカ系：5-10%

        アフリカ系アメリカ人：
        - アフリカ系：75-80%
        - ヨーロッパ系：20-25%

        日本人の地域差：
        本州：縄文系20-30% + 弥生系70-80%
        沖縄：縄文系40-50% + 弥生系50-60%
        アイヌ：縄文系70-80% + 弥生系20-30%

        混合の時期推定も可能！
        （連鎖不平衡の崩壊速度から）
        """
```

## 📖 ステップ6：人類移動史の再構築

### 6-1. アフリカからの大移動

```python
class OutOfAfricaMigration:
    def __init__(self):
        self.route = "アフリカ → 中東 → 世界各地"

    def migration_waves(self):
        """
        人類移動の波
        """
        waves = """
        🌊 人類移動の主要な波：

        第1波（失敗）：12-10万年前
        - 中東まで到達
        - ネアンデルタール人と交雑
        - その後絶滅

        第2波（成功）：7-6万年前
        - 小集団（1000-1万人）
        - 紅海南部を渡る
        - 全世界へ拡散

        ルート1：海岸沿い
        アフリカ → アラビア → インド → 東南アジア → オーストラリア
        （約5万年前にオーストラリア到達）

        ルート2：内陸
        中東 → 中央アジア → ヨーロッパ/東アジア
        （約4.5万年前にヨーロッパ到達）

        ルート3：ベーリング陸橋
        東アジア → ベーリング → アメリカ大陸
        （約1.5万年前、最終氷期末期）
        """
        return waves

    def genetic_evidence(self):
        """
        遺伝学的証拠
        """
        return """
        🧬 移動を裏付ける遺伝学的証拠：

        1. 遺伝的多様性の勾配
           アフリカ > 中東 > ヨーロッパ/アジア > アメリカ

           理由：連続的なボトルネック効果

        2. 連鎖不平衡の増加
           アフリカから離れるほど増加
           （創始者効果の累積）

        3. 有害変異の蓄積
           小集団での遺伝的浮動
           → 有害変異が偶然固定

        4. ネアンデルタールDNA
           非アフリカ人：1-4%
           アフリカ人：ほぼ0%
           → アフリカ出発後に交雑
        """
```

### 6-2. 日本列島への到達

```python
class JapaneseMigration:
    def __init__(self):
        self.waves = ["旧石器時代", "縄文時代", "弥生時代"]

    def migration_history(self):
        """
        日本列島への人類移動史
        """
        return """
        🗾 日本列島への3つの波：

        第1波：4-3万年前（旧石器時代）
        - 陸橋を通じて到達
        - 現在のアイヌ・縄文人の祖先
        - Y染色体：C1a1、D1a2a
        - mtDNA：M7a、N9b

        第2波：1.6万年前〜（縄文時代）
        - 温暖化による海面上昇で隔離
        - 独自の縄文文化発展
        - 狩猟採集生活

        第3波：3000-2300年前（弥生時代）
        - 朝鮮半島から水田稲作と共に
        - Y染色体：O1b2、O2
        - mtDNA：D4、B4、F

        現代日本人の成立：
        縄文人 + 弥生人の混血
        地域差：北と南により多く縄文系
        """

    def dual_structure_model(self):
        """
        二重構造モデル
        """
        return """
        埴原和郎の二重構造モデル（1991）：

        基層：縄文系
        - アイヌ（70-80%縄文系）
        - 沖縄（40-50%縄文系）
        - 本州周辺部

        上層：弥生系
        - 本州中央部（70-80%弥生系）
        - 特に近畿地方

        遺伝的勾配：
        縄文度：北海道 > 東北 > 関東 > 近畿 < 中国 < 九州 < 沖縄

        最新の知見：
        - 縄文人は予想以上に独特
        - 東アジア集団から早期分岐（3.8万年前）
        - 現代東アジア人とは大きく異なる
        """
```

## 📖 ステップ7：最新の解析技術

### 7-1. 古代DNA解析

```python
class AncientDNA:
    def __init__(self):
        self.challenges = [
            "DNA分解（断片化）",
            "現代DNAの混入",
            "微生物DNAの混入",
            "化学的損傷"
        ]

    def extraction_process(self):
        """
        古代DNA抽出プロセス
        """
        return """
        🦴 古代DNA解析の革命：

        サンプル源：
        - 骨（特に側頭骨の錐体部）
        - 歯（象牙質）
        - 毛髪（まれ）

        技術革新：
        1. 次世代シーケンサー
           → 短い断片でも解読可能

        2. ターゲットキャプチャー
           → 特定領域を濃縮

        3. 損傷パターン認識
           → 古代DNAと現代DNAを区別
           → C→T置換（脱アミノ化）

        成功例：
        - ネアンデルタール人ゲノム（2010）
        - デニソワ人発見（2010）
        - 縄文人ゲノム（2019）
        """

    def japanese_ancient_dna(self):
        """
        日本の古代DNA研究
        """
        return """
        🗾 日本列島の古代ゲノム：

        縄文人（3800年前、礼文島）：
        - 東アジア人とは大きく異なる
        - 独自の系統
        - 現代日本人への寄与：12-38%

        弥生人（2300年前）：
        - 東アジア系
        - 現代中国東北部に近い

        古墳人（1400年前）：
        - 縄文+弥生+追加の大陸系
        - 現代日本人にほぼ一致

        驚きの発見：
        三段階混合モデル
        縄文人 → (+弥生人) → (+古墳時代の渡来人) → 現代日本人
        """
```

### 7-2. 機械学習による祖先推定

```python
class MachineLearningAncestry:
    def __init__(self):
        self.algorithms = [
            "ランダムフォレスト",
            "ニューラルネットワーク",
            "SVM",
            "深層学習"
        ]

    def ancestry_prediction(self):
        """
        機械学習による祖先推定
        """
        return """
        🤖 AI時代の集団遺伝学：

        入力データ：
        - 数十万〜数百万のSNP
        - 個体×SNPの巨大行列

        予測タスク：
        1. 祖先集団の分類
        2. 混合比率の推定
        3. 移住時期の推定
        4. 選択圧の検出

        深層学習の応用：
        - CNN：連鎖不平衡パターン認識
        - RNN：配列データの処理
        - VAE：潜在的な集団構造の発見
        - GAN：シミュレーションデータ生成

        精度：
        大陸レベル：99%以上
        地域レベル：90-95%
        村レベル：70-80%
        """

    def future_directions(self):
        """
        将来の展望
        """
        return """
        🚀 次世代の人類史研究：

        1. 全ゲノムシーケンス時代
           - 1000ドルゲノム → 100ドルゲノムへ
           - 全人類のゲノムデータベース

        2. 環境DNA（eDNA）
           - 土壌から古代DNAを抽出
           - 化石なしでも解析可能

        3. エピゲノム解析
           - DNAメチル化パターン
           - 環境適応の痕跡

        4. マルチオミクス統合
           - ゲノム+プロテオーム+メタボローム
           - 総合的な人類史理解

        5. リアルタイム系統追跡
           - 感染症の伝播経路
           - 移民のリアルタイム追跡
        """
```

## 📖 ステップ8：自然選択の検出

### 8-1. 正の選択の痕跡

```python
class PositiveSelection:
    def __init__(self):
        self.methods = [
            "Tajima's D",
            "Fu and Li's D",
            "Fay and Wu's H",
            "iHS (integrated Haplotype Score)"
        ]

    def lactase_persistence(self):
        """
        乳糖耐性の進化
        """
        return """
        🥛 乳糖耐性の驚くべき進化：

        通常：乳児期のみラクターゼ産生
        変異：成人でも産生継続

        地域別頻度：
        北欧：90%以上
        南欧：50-70%
        東アジア：5-10%
        アフリカ（牧畜民）：50-90%
        アフリカ（農耕民）：5-20%

        独立した進化：
        ヨーロッパ：-13910*T変異
        アフリカ：-14010*C変異
        （異なる変異が同じ表現型）

        選択の強さ：
        わずか1万年で頻度が急上昇
        選択係数s = 0.05-0.15（非常に強い）

        理由：
        栄養価の高い乳製品を利用可能
        → 生存率・繁殖成功率の向上
        """

    def altitude_adaptation(self):
        """
        高地適応の遺伝学
        """
        return """
        🏔️ チベット人の高地適応：

        EPAS1遺伝子の変異：
        - 低酸素応答を調節
        - ヘモグロビン濃度を抑制
        - 高山病を防ぐ

        驚きの発見：
        デニソワ人から獲得！
        （古代型人類との交雑の恩恵）

        他の高地民族：
        アンデス：異なる遺伝子
        エチオピア：また別の遺伝子

        → 収斂進化の美しい例
        """
```

### 8-2. バランス選択

```python
class BalancingSelection:
    def __init__(self):
        self.examples = [
            "MHC（主要組織適合性複合体）",
            "ABO血液型",
            "鎌状赤血球"
        ]

    def mhc_diversity(self):
        """
        MHCの超多様性
        """
        return """
        🛡️ 免疫系の多様性維持：

        MHC（HLA）の特徴：
        - 最も多型性の高い遺伝子
        - 数百のアレル型
        - 個人識別可能なレベル

        なぜ多様性が維持される？

        1. 病原体との軍拡競争
           新しい病原体 → 新しいMHC有利

        2. 性選択
           MHC非類似個体を好む
           （においで判別）

        3. 頻度依存選択
           稀なアレル → 病原体が適応していない → 有利

        結果：
        人類の長期的生存に貢献
        """
```

## 📖 ステップ9：実践的な解析

### 9-1. 実際のデータ解析例

```python
import pandas as pd
import numpy as np
from scipy import stats

class PopulationGeneticsAnalysis:
    def __init__(self):
        self.data = None

    def calculate_allele_frequencies(self, genotypes):
        """
        遺伝子型データからアレル頻度を計算
        """
        # genotypes: 0=AA, 1=Aa, 2=aa
        n_individuals = len(genotypes)
        n_A = genotypes.count(0) * 2 + genotypes.count(1)
        n_a = genotypes.count(2) * 2 + genotypes.count(1)

        freq_A = n_A / (2 * n_individuals)
        freq_a = n_a / (2 * n_individuals)

        return {
            "freq_A": freq_A,
            "freq_a": freq_a,
            "in_HWE": self.hardy_weinberg_test(genotypes, freq_A, freq_a)
        }

    def hardy_weinberg_test(self, genotypes, p, q):
        """
        ハーディ・ワインベルグ平衡の検定
        """
        observed = [
            genotypes.count(0),  # AA
            genotypes.count(1),  # Aa
            genotypes.count(2)   # aa
        ]

        n = sum(observed)
        expected = [
            n * p**2,      # AA
            n * 2 * p * q, # Aa
            n * q**2       # aa
        ]

        chi2, p_value = stats.chisquare(observed, expected)

        return {
            "chi2": chi2,
            "p_value": p_value,
            "in_equilibrium": p_value > 0.05
        }

    def estimate_effective_population_size(self, heterozygosity_t1, heterozygosity_t2, generations):
        """
        有効集団サイズの推定
        """
        # ヘテロ接合度の減少から推定
        H_t1 = heterozygosity_t1
        H_t2 = heterozygosity_t2
        t = generations

        # H_t = H_0 * (1 - 1/(2*Ne))^t
        Ne = -t / (2 * np.log(H_t2 / H_t1))

        return f"""
        世代{t}後のヘテロ接合度変化：
        {H_t1:.3f} → {H_t2:.3f}

        推定有効集団サイズ：{Ne:.0f}個体

        解釈：
        Ne < 50：絶滅の危機
        Ne = 50-500：遺伝的浮動が強い
        Ne > 500：比較的安定
        """
```

### 9-2. シミュレーション実習

```python
import matplotlib.pyplot as plt

class PopulationSimulation:
    def __init__(self):
        self.populations = []

    def simulate_founder_effect(self, source_size=10000, founder_size=20, generations=100):
        """
        創始者効果のシミュレーション
        """
        import random

        # 元集団のアレル頻度（多様）
        source_alleles = ['A'] * 7000 + ['B'] * 2000 + ['C'] * 800 + ['D'] * 200

        # 創始者集団をランダムサンプリング
        founders = random.sample(source_alleles * 2, founder_size * 2)

        # アレル頻度を計算
        freq_A = founders.count('A') / len(founders)
        freq_B = founders.count('B') / len(founders)
        freq_C = founders.count('C') / len(founders)
        freq_D = founders.count('D') / len(founders)

        return f"""
        創始者効果シミュレーション結果：

        元集団（{source_size}個体）：
        A: 70%, B: 20%, C: 8%, D: 2%

        創始者集団（{founder_size}個体）：
        A: {freq_A:.1%}, B: {freq_B:.1%},
        C: {freq_C:.1%}, D: {freq_D:.1%}

        観察：
        - 稀なアレルDが消失する可能性
        - アレル頻度が大きく変動
        - 遺伝的多様性の減少

        実例：
        ピンガラップ島の色覚異常
        1775年の台風で20人に減少
        → 現在5%が全色盲（通常0.003%）
        """
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- 人類はアフリカで誕生し、約7万年前に世界へ拡散した
- DNAの変異は時計のように一定速度で蓄積される
- ミトコンドリアDNAは母系、Y染色体は父系を追跡する
- 日本人は縄文人と弥生人の混血で形成された

### レベル2：本質的理解（ここまで来たら素晴らしい）

- FST値で集団間の遺伝的分化を定量化できる
- 遺伝的浮動と創始者効果が集団の多様性を決定する
- ハーディ・ワインベルグ平衡から集団の交配様式がわかる
- ADMIXTURE解析で祖先集団の混合比率を推定できる

### レベル3：応用的理解（プロレベル）

- 合体理論で過去の集団動態を推定できる
- 古代DNA解析が人類史の理解を革新している
- 自然選択の痕跡を複数の統計量で検出できる
- 機械学習が集団遺伝学に新たな可能性をもたらしている

## 🚀 次回予告

次回は、集団遺伝学の数理モデルについて学びます！

- **Wright-Fisher モデル**：遺伝的浮動の数学
- **拡散近似**：アレル頻度変化の連続モデル
- **Kingman の合体過程**：系統樹の確率過程
- **ABC 法**：複雑な人口動態の推定

人類の歴史を数式で解き明かす、エキサイティングな世界へようこそ！

---

### 重要な概念チェックリスト

- [ ] アフリカ単一起源説を理解している
- [ ] 分子時計の原理を説明できる
- [ ] ミトコンドリアDNAとY染色体の特徴を知っている
- [ ] FST値の意味と計算方法を理解している
- [ ] 遺伝的浮動とボトルネック効果を説明できる
- [ ] 日本人の成立過程（二重構造モデル）を理解している
- [ ] 自然選択の検出方法を知っている
- [ ] 古代DNA解析の原理と課題を把握している
