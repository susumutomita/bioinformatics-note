# Viterbiアルゴリズム：動的計画法がHMMデコードを征服する（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**Viterbiアルゴリズムで、指数時間かかるHMMデコード問題を多項式時間で解く魔法を完全理解する**

でも、ちょっと待ってください。なぜAndrewViterbiのアルゴリズムがそんなに画期的なの。
実は、**2^n通りの経路を全部調べることなく、最適経路を確実に見つける**という、まさに動的計画法の真骨頂なんです。

## 🤔 ステップ0：なぜViterbiアルゴリズムが必要なのか

### 0-1. 前回の問題点

```
HMMデコード問題：
- n=100のシンボル列
- 2状態のHMM
- 可能な経路数：2^100 ≈ 10^30

全探索は不可能。
```

### 0-2. Andrew Viterbiの革命

```
1967年：誤り訂正符号のために開発
現在：音声認識、自然言語処理、生物情報学で大活躍

なぜ革命的か：
O(2^n) → O(k²n)への劇的改善
```

## 📖 ステップ1：動的計画法の基本アイデア

### 1-1. 重要な観察

```python
def key_observation():
    """
    ある地点への最適経路は、
    その1つ前の地点への最適経路を必ず通る
    """
    # これが動的計画法の核心。
```

### 1-2. マンハッタングラフでの視覚化

```
時刻:  0    1    2    3    4
  F: start─○────○────○────○─end
           ╲  ╱ ╲  ╱ ╲  ╱
  B:       ─○────○────○────○

各ノードで「ここまでの最適経路」を記憶
```

## 📖 ステップ2：score_k(i)の定義

### 2-1. 魔法の変数

```python
def score_k(i):
    """
    score_k(i) = ソースからノード(k,i)までの
                 全経路の最大積重み

    k: 状態（F or B）
    i: 時刻（列番号）
    """
```

### 2-2. なぜこの定義が重要か

```
各ノードで「ここまでの最高スコア」を記録
→ 後で同じ計算を繰り返さない
→ 計算量が劇的に減る
```

## 📖 ステップ3：Viterbi再帰式の導出

### 3-1. 核心の再帰式

```python
def viterbi_recursion(k, i):
    """
    score_k(i) = max_l(score_l(i-1) × weight(l,k,i-1))

    つまり：
    現在のスコア = max(
        前の列の各状態のスコア × そこからのエッジ重み
    )
    """
```

### 3-2. 具体例で理解

```
時刻3、状態Bに到達する場合：

前の列（時刻2）から2つの可能性：
1. F→B: score_F(2) × P(F→B) × P(H|B)
2. B→B: score_B(2) × P(B→B) × P(H|B)

score_B(3) = max(可能性1, 可能性2)
```

## 📖 ステップ4：完全なViterbiアルゴリズム

### 4-1. 初期化

```python
def viterbi_init():
    """初期化：スタート地点のスコア"""
    for state in states:
        score[state][0] = initial_prob[state] * emission_prob[state][X[0]]
```

### 4-2. 再帰計算

```python
def viterbi_algorithm(X, hmm):
    """完全なViterbiアルゴリズム"""
    n = len(X)
    k = len(hmm.states)

    # スコア表を初期化
    score = [[0] * n for _ in range(k)]
    path = [[0] * n for _ in range(k)]

    # 初期化
    for s in range(k):
        score[s][0] = hmm.initial[s] * hmm.emission[s][X[0]]

    # 動的計画法
    for i in range(1, n):
        for curr_state in range(k):
            max_score = 0
            best_prev = 0

            for prev_state in range(k):
                temp_score = (score[prev_state][i-1] *
                            hmm.transition[prev_state][curr_state] *
                            hmm.emission[curr_state][X[i]])

                if temp_score > max_score:
                    max_score = temp_score
                    best_prev = prev_state

            score[curr_state][i] = max_score
            path[curr_state][i] = best_prev

    # バックトラック
    return backtrack(score, path)
```

## 📖 ステップ5：なぜこれで最適解が保証されるのか

### 5-1. 最適部分構造

```
定理：最適経路の部分経路も最適

証明（背理法）：
もし部分経路が最適でないなら...
→ より良い部分経路が存在
→ 全体もより良くできる
→ 矛盾。
```

### 5-2. 重複部分問題

```python
# 同じノードに到達する複数の経路
# でも計算は1回だけ。

     ○
   ╱│╲
  ○ ○ ○  → ●（ここで1回だけ計算）
   ╲│╱
     ○
```

## 📖 ステップ6：対数変換の魔法

### 6-1. なぜ対数が必要か

```python
# 問題：確率の積は急速に0に近づく
prob = 0.5 * 0.5 * 0.5 * ... # 100回
# = 0.5^100 ≈ 10^-30（アンダーフロー。）

# 解決：対数を使う
log_prob = log(0.5) + log(0.5) + ... # 和に変換。
# = -100 * log(2)（計算可能）
```

### 6-2. 対数版Viterbi

```python
def viterbi_log_version():
    """対数を使ったViterbi"""
    # 再帰式が変わる
    log_score[k][i] = max_l(
        log_score[l][i-1] +
        log(transition[l][k]) +
        log(emission[k][X[i]])
    )

    # 積が和に変換された。
```

## 📖 ステップ7：計算量の劇的改善

### 7-1. 全探索との比較

```python
def complexity_comparison(n, k):
    """
    n: シンボル列の長さ
    k: 状態数
    """
    brute_force = k ** n  # 指数的
    viterbi = k * k * n   # 多項式的

    # n=100, k=2の場合
    # 全探索：2^100 ≈ 10^30
    # Viterbi：2*2*100 = 400

    # 10^30 / 400 = 10^27倍の高速化。
```

### 7-2. 禁止遷移がある場合

```
通常：k²n の計算量
禁止遷移あり：(エッジ数)×n

例：4状態で一部遷移禁止
  A ─→ B
  ↓ ╲ ↗ ↓
  C ←─ D

エッジ数=6 < 16(=4²)
→ さらに高速化
```

## 📖 ステップ8：Forwardアルゴリズムへの拡張

### 8-1. 新しい問題設定

```python
# Viterbi：最も可能性の高い経路
# Forward：文字列Xが生成される確率

def outcome_likelihood_problem():
    """
    入力：HMM、観察列X
    出力：P(X) = すべての経路でのP(X,π)の和
    """
```

### 8-2. たった1文字の変更

```python
# Viterbi（最大値）
score[k][i] = MAX_l(...)

# Forward（合計）
forward[k][i] = SUM_l(...)

# たった3文字の違い。
```

## 📖 ステップ9：実装の詳細とトリック

### 9-1. バックトラック

```python
def backtrack(score, path, n, k):
    """最適経路を復元"""
    # 最後の列で最大スコアを見つける
    best_last = argmax(score[:][n-1])

    # 逆向きにたどる
    result = [best_last]
    for i in range(n-1, 0, -1):
        best_last = path[best_last][i]
        result.append(best_last)

    return result[::-1]  # 逆順を元に戻す
```

### 9-2. メモリ最適化

```python
def space_efficient_viterbi():
    """
    実は前の列だけ覚えればOK
    O(kn) → O(k)のメモリ削減
    """
    prev_column = [...]
    curr_column = [...]
    # 2列分のメモリで十分
```

## 📖 ステップ10：生物学への応用

### 10-1. CpGアイランド検出

```python
def cpg_island_detection(dna_sequence):
    """ViterbiでCpGアイランドを検出"""
    hmm = CpGIslandHMM()
    hidden_path = viterbi(dna_sequence, hmm)

    # hidden_path: [通常,通常,島,島,島,通常,...]
    return hidden_path
```

### 10-2. 遺伝子予測

```python
def gene_prediction(genome):
    """遺伝子領域の予測"""
    states = ["遺伝子", "非遺伝子"]
    # Viterbiで最適な状態列を推定
```

## 🎓 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- Viterbiは最適な隠れ経路を効率的に見つける
- 動的計画法で指数的計算を多項式的に削減
- 対数変換で数値的安定性を確保

### レベル2：本質的理解（ここまで来たら素晴らしい）

- score_k(i)が部分問題の最適解を記憶
- 最適部分構造により全体最適が保証される
- maxをsumに変えるだけでForwardアルゴリズムに

### レベル3：応用的理解（プロレベル）

- O(k²n)の計算量、O(kn)の空間計算量
- 禁止遷移でさらなる高速化が可能
- バックトラックで経路復元、メモリ最適化技術

## 🚀 次回予告

次回は、**HMMの学習問題**に挑戦。
「観察データからHMMのパラメータをどう推定するか」
「Baum-Welchアルゴリズムの魔法とは」

## 📚 重要な公式集

```python
# Viterbi再帰式
score[k][i] = max_l(score[l][i-1] * trans[l][k] * emit[k][X[i]])

# 対数版
log_score[k][i] = max_l(log_score[l][i-1] + log_trans[l][k] + log_emit[k][X[i]])

# Forward再帰式
forward[k][i] = sum_l(forward[l][i-1] * trans[l][k] * emit[k][X[i]])
```

## 🔬 実験：Viterbiアルゴリズム実装

```python
import numpy as np

class ViterbiDecoder:
    """Viterbiアルゴリズムの完全実装"""

    def __init__(self, states, trans, emit, initial):
        self.states = states
        self.trans = np.log(trans)  # 対数変換
        self.emit = np.log(emit)
        self.initial = np.log(initial)

    def decode(self, observations):
        """最適な隠れ状態列を推定"""
        n = len(observations)
        k = len(self.states)

        # Viterbiテーブル
        V = np.zeros((k, n))
        path = np.zeros((k, n), dtype=int)

        # 初期化
        for s in range(k):
            V[s, 0] = self.initial[s] + self.emit[s, observations[0]]

        # 再帰
        for t in range(1, n):
            for s in range(k):
                prob = V[:, t-1] + self.trans[:, s] + self.emit[s, observations[t]]
                V[s, t] = np.max(prob)
                path[s, t] = np.argmax(prob)

        # バックトラック
        states = np.zeros(n, dtype=int)
        states[-1] = np.argmax(V[:, -1])
        for t in range(n-2, -1, -1):
            states[t] = path[states[t+1], t+1]

        return states

# 使用例
decoder = ViterbiDecoder(
    states=["Fair", "Biased"],
    trans=[[0.9, 0.1], [0.1, 0.9]],
    emit=[[0.5, 0.5], [0.75, 0.25]],
    initial=[0.5, 0.5]
)

observations = [0, 0, 1, 0, 0, 1]  # H,H,T,H,H,T
hidden_states = decoder.decode(observations)
print(f"最適な隠れ状態列: {hidden_states}")
```

---

### 次回：「Baum-Welchアルゴリズム - HMMパラメータの学習」
