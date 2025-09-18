# ヤクザカジノからCpGアイランドへ：隠れマルコフモデルの基礎（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**19世紀日本のヤクザカジノのイカサマゲームから、ゲノム中のCpGアイランド検出まで、隠れマルコフモデルの威力を完全理解する**

でも、ちょっと待ってください。なぜ生物学の講義でヤクザが出てくるの。
実は、**「隠れた状態」を推定する**という問題は、イカサマコインの判別もDNA配列解析も本質的に同じなんです。

## 🤔 ステップ0：なぜヤクザのカジノから始めるのか

### 0-1. そもそもの問題設定

配列解析の本質的な問題：

```
観測できるもの：DNA配列（ATGCGC...）
知りたいこと：その背後にある「状態」（遺伝子領域か否か等）
```

これを理解するための最高の例え話が...

### 0-2. 19世紀日本のバクトーカジノ

```
ヤクザシンジケート
    ↓
バクトーカジノ運営
    ↓
チョーハン（丁半）ゲーム
```

なんと、このギャンブルゲームが**現代のゲノム解析**の基礎になるとは。

## 📖 ステップ1：チョーハンゲームの基礎

### 1-1. ゲームのルール

```python
def chohan_game():
    """丁半ゲーム"""
    dice1 = random.randint(1, 6)
    dice2 = random.randint(1, 6)
    total = dice1 + dice2

    if total % 2 == 0:
        return "丁（cho）= 偶数"
    else:
        return "半（han）= 奇数"
```

**ポイント**：通常なら勝率50/50のフェアゲーム。でも...

### 1-2. ヤクザの仕掛け

```
通常のサイコロ：各目が1/6の確率
イカサマサイコロ：特定の目が出やすい
```

ここで天才的な（悪徳な）アイデアが。
ディーラーはサイコロをこっそり入れ替える。

## 📖 ステップ2：コインフリップ版で単純化

### 2-1. 2種類のコイン

```python
# フェアコイン
fair_coin = {
    "表": 0.5,
    "裏": 0.5
}

# バイアスコイン（イカサマ）
biased_coin = {
    "表": 0.75,  # 3/4の確率で表。
    "裏": 0.25
}
```

### 2-2. 重要な疑問

「100回投げて63回表が出た。どっちのコインを使った。」

でも待って。この質問自体がおかしい。
なぜなら、**どちらのコインでも63回表は出うる**から。

正しい質問：「どちらのコインの**可能性が高い**か。」

## 📖 ステップ3：確率計算の魔法

### 3-1. それぞれの確率を計算

```python
def probability_fair(heads, total):
    """フェアコインでの確率"""
    return (0.5) ** total

def probability_biased(heads, total):
    """バイアスコインでの確率"""
    tails = total - heads
    return (0.75) ** heads * (0.25) ** tails
```

### 3-2. 驚きの結果

100回中63回表の場合：

```python
# 直感的には...
# 63は50より75に近いから、バイアスコインでは。

# でも実際に計算すると...
threshold = log2(3) * 100  # ≈ 63.2

# 63 < 63.2 なので...
result = "フェアコインの可能性が高い。"
```

**衝撃**：63回も表が出たのに、フェアコインの可能性が高い。

## 📖 ステップ4：平衡点の発見

### 4-1. 魔法の境界線

```python
def equilibrium_point(n):
    """どちらのコインか判定する境界"""
    return log2(3) * n  # ≈ 0.632 * n

# n=100の場合
if heads < 63.2:
    return "フェアコイン"
else:
    return "バイアスコイン"
```

### 4-2. なぜlog2(3)なのか

ここで数学の美しさが。

```
フェア確率 = バイアス確率 となる条件：
(1/2)^n = (3/4)^k * (1/4)^(n-k)

これを解くと...
k = log2(3) * n
```

## 📖 ステップ5：上半身裸のディーラー

### 5-1. なぜ上半身裸なのか

```
理由：サイコロをすり替えられないように
現実：でも実際にはすり替え可能だった。
```

### 5-2. より複雑な問題設定

```python
class CasinoDealer:
    """コインを切り替えるディーラー"""
    def __init__(self):
        self.current_coin = "fair"
        self.switch_probability = 0.1

    def flip(self):
        # 10%の確率でコインを切り替え
        if random.random() < self.switch_probability:
            self.switch_coin()

        # 現在のコインで投げる
        return self.toss_current_coin()
```

新たな問題：「**いつ**コインが切り替わったか。」

## 📖 ステップ6：スライディングウィンドウ法

### 6-1. 基本アイデア

```python
def sliding_window_analysis(sequence, window_size=5):
    """ウィンドウごとに判定"""
    results = []

    for i in range(len(sequence) - window_size + 1):
        window = sequence[i:i+window_size]
        heads = window.count('H')

        # この窓でどちらのコインか判定
        if heads / window_size < 0.632:
            results.append('F')  # Fair
        else:
            results.append('B')  # Biased

    return results
```

### 6-2. 例：HHHTHHTTHH

```
窓1: HHHTH (80%表) → バイアス
窓2: HHTHT (60%表) → フェア
窓3: HTHTT (40%表) → フェア
...
```

## 📖 ステップ7：対数オッズ比の導入

### 7-1. なぜ対数を使うのか

```python
def log_odds_ratio(heads, total):
    """対数オッズ比の計算"""
    # 比率 = P(フェア) / P(バイアス)
    # 対数化すると掛け算が足し算に。

    return total - log2(3) * heads

# 判定ルール
if log_odds_ratio < 0:
    return "バイアスコイン"
else:
    return "フェアコイン"
```

### 7-2. 対数の利点

```
通常：確率の掛け算 → 数値が極小に
対数：掛け算が足し算に → 計算が安定
```

## 📖 ステップ8：スライディングウィンドウの問題点

### 8-1. 矛盾する判定

```
位置10のコイン投げ：
- 窓1（位置6-10）では「フェア」
- 窓2（位置8-12）では「バイアス」
- 窓3（位置10-14）では「フェア」

どれが正しい。
```

### 8-2. 窓サイズの選択

```python
# 窓が小さすぎると...
window_size = 3  # ノイズに敏感

# 窓が大きすぎると...
window_size = 100  # 変化を見逃す

# 最適なサイズは。誰も知らない。
```

## 📖 ステップ9：生物学への橋渡し - CpGアイランド

### 9-1. CpGジヌクレオチドの謎

```
期待値：ヒトゲノムでCGの出現率 = 5.29%
実際：CG出現率 = 約1%（5分の1。）

なぜ。
```

### 9-2. メチル化の影響

```python
def methylation_process():
    """メチル化による変化"""
    # CpGのCがメチル化
    CG = "CG"
    methylated_C = add_methyl_group("C")

    # メチル化Cは脱アミノ化してTに
    T = deaminate(methylated_C)

    # 結果：CG → TG
    return "TG"
```

つまり、進化の過程でCGがどんどん減少。

## 📖 ステップ10：CpGアイランドとは

### 10-1. 遺伝子周辺の特殊地帯

```
通常のゲノム：CG出現率 = 1%
CpGアイランド：CG出現率 = 5%以上

なぜ遺伝子周辺だけ。
→ メチル化が抑制されるから
```

### 10-2. 遺伝子発見への応用

```python
def find_genes():
    """遺伝子を見つける戦略"""
    # 1. CpGアイランドを探す
    islands = find_cpg_islands(genome)

    # 2. その近くが遺伝子の可能性大
    for island in islands:
        check_for_genes_nearby(island)
```

## 📖 ステップ11：カジノとゲノムの驚くべき類似

### 11-1. 問題の対応関係

```
カジノ問題：
- 観測：コイン投げ結果（HHTHHT...）
- 隠れた状態：フェアかバイアスか

CpGアイランド問題：
- 観測：DNA配列（ATCGCG...）
- 隠れた状態：アイランドか否か
```

### 11-2. 同じ数学的枠組み

```python
class HiddenStateDetection:
    """隠れた状態の検出"""

    def casino_problem(self, flips):
        # コインの種類を推定
        return detect_coin_type(flips)

    def cpg_island_problem(self, sequence):
        # CpGアイランドを推定
        return detect_cpg_island(sequence)

    # 実は同じアルゴリズム。
```

## 📖 ステップ12：現在の限界と次への期待

### 12-1. スライディングウィンドウの限界

```
問題点：
1. 窓サイズの恣意性
2. 境界での不連続性
3. 文脈情報の喪失
```

### 12-2. より洗練された手法の必要性

```python
# 現在の方法
def current_method(sequence):
    # 固定窓で局所的に判定
    return sliding_window(sequence, fixed_size)

# 必要な方法
def needed_method(sequence):
    # 全体を統一的にモデル化
    # 状態遷移を考慮
    # 確率的に最適化
    return hidden_markov_model(sequence)  # 次回。
```

## 🎓 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- ヤクザカジノのイカサマコインを見破る問題
- 63/100回表でもフェアコインの可能性が高い（驚き。）
- CpGアイランドは遺伝子近くのCGが多い領域

### レベル2：本質的理解（ここまで来たら素晴らしい）

- 観測データから隠れた状態を推定する問題の普遍性
- 対数オッズ比による判定の数学的根拠
- メチル化によるCG減少と遺伝子領域での保存

### レベル3：応用的理解（プロレベル）

- log2(3)が平衡点となる確率論的導出
- スライディングウィンドウの限界と改善の必要性
- カジノ問題とゲノム解析の数学的等価性

## 🚀 次回予告

次回は、ついに**隠れマルコフモデル（HMM）**の全貌が明らかに。
「なぜViterbiアルゴリズムが最適解を保証するのか。」
「Forward-Backwardアルゴリズムの魔法とは。」

## 📚 用語解説

1. **バクトー**：19世紀日本のヤクザが運営したカジノ
2. **チョーハン（丁半）**：サイコロの合計が偶数（丁）か奇数（半）かを当てるゲーム
3. **CpGジヌクレオチド**：シトシン(C)の次にグアニン(G)が来る配列
4. **メチル化**：DNAのシトシンにメチル基（CH3）が付く化学修飾
5. **CpGアイランド**：CpGが高頻度で出現する領域（通常は遺伝子の開始部付近）

## 🔬 実験：コイン判定を体験

```python
import random
from math import log2

def casino_experiment(n_flips=100):
    """カジノ実験シミュレーション"""

    # ランダムにコインを選ぶ
    true_coin = random.choice(["fair", "biased"])

    # コイン投げシミュレーション
    if true_coin == "fair":
        heads = sum(1 for _ in range(n_flips)
                   if random.random() < 0.5)
    else:
        heads = sum(1 for _ in range(n_flips)
                   if random.random() < 0.75)

    # 判定
    threshold = log2(3) * n_flips
    guess = "fair" if heads < threshold else "biased"

    print(f"結果：{heads}/{n_flips}回が表")
    print(f"判定：{guess}コイン")
    print(f"正解：{true_coin}コイン")
    print(f"判定は{'正しい' if guess == true_coin else '間違い'}。")

# 実行してみよう。
casino_experiment()
```

---

### 次回：「隠れマルコフモデル - なぜ動的計画法が確率モデルと融合するのか」
