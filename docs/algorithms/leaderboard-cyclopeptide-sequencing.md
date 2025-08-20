# リーダーボードシクロペプチドシーケンシング

## 📝 概要

リーダーボードシクロペプチドシーケンシングは、誤差を含む実験スペクトルからペプチド配列を推定するヒューリスティックアルゴリズムです。完全一致を求める代わりに、スコアリング関数を使用してペプチドの類似度を評価します。

## 🎯 解決する問題

**入力**：

- 実験スペクトル（質量のリスト）
- リーダーボードサイズN

**出力**：

- 最高スコアの環状ペプチド

## 💡 アルゴリズムの核心

### スコアリング関数

```python
def score_peptide(peptide, experimental_spectrum):
    """
    スコア = 理論スペクトルと実験スペクトルで共有する質量の数
    """
    theoretical = calculate_spectrum(peptide)
    score = 0
    exp_copy = list(experimental_spectrum)

    for mass in theoretical:
        if mass in exp_copy:
            score += 1
            exp_copy.remove(mass)  # 重複カウント防止

    return score
```

### リーダーボードの管理

上位N個のペプチドを保持（同点含む）します。

```python
def trim_leaderboard(leaderboard, spectrum, n):
    # スコア計算
    scored = [(score_peptide(p, spectrum), p) for p in leaderboard]
    scored.sort(reverse=True)

    # N番目のスコアを取得
    if len(scored) <= n:
        return [p for _, p in scored]

    nth_score = scored[n-1][0]

    # 同点を含めて選択
    return [p for s, p in scored if s >= nth_score]
```

## 🔧 完全な実装

```python
#!/usr/bin/env python3
"""
リーダーボードシクロペプチドシーケンシング
誤差のある実験スペクトルからペプチド配列を推定
"""

# アミノ酸質量表
AA_MASS = {
    'G': 57, 'A': 71, 'S': 87, 'P': 97, 'V': 99,
    'T': 101, 'C': 103, 'I': 113, 'L': 113, 'N': 114,
    'D': 115, 'K': 128, 'Q': 128, 'E': 129, 'M': 131,
    'H': 137, 'F': 147, 'R': 156, 'Y': 163, 'W': 186
}

# ユニークな質量のリスト
UNIQUE_MASSES = sorted(set(AA_MASS.values()))

def calculate_linear_spectrum(peptide):
    """直鎖ペプチドの理論スペクトルを計算"""
    if not peptide:
        return [0]

    n = len(peptide)
    spectrum = [0]

    for length in range(1, n + 1):
        for start in range(n - length + 1):
            subpeptide = peptide[start:start + length]
            if isinstance(peptide[0], int):
                mass = sum(subpeptide)
            else:
                mass = sum(AA_MASS[aa] for aa in subpeptide)
            spectrum.append(mass)

    return sorted(spectrum)

def calculate_cyclic_spectrum(peptide):
    """環状ペプチドの理論スペクトルを計算"""
    if not peptide:
        return [0]

    n = len(peptide)
    spectrum = [0]

    # 環状配列を2倍にして部分配列を取得
    double_peptide = peptide + peptide

    for length in range(1, n):
        for start in range(n):
            subpeptide = double_peptide[start:start + length]
            if isinstance(peptide[0], int):
                mass = sum(subpeptide)
            else:
                mass = sum(AA_MASS[aa] for aa in subpeptide)
            spectrum.append(mass)

    # 全体の質量を追加
    if isinstance(peptide[0], int):
        total_mass = sum(peptide)
    else:
        total_mass = sum(AA_MASS[aa] for aa in peptide)
    spectrum.append(total_mass)

    return sorted(spectrum)

def score_peptide(peptide, experimental_spectrum, is_cyclic=True):
    """ペプチドのスコアを計算"""
    if is_cyclic:
        theoretical_spectrum = calculate_cyclic_spectrum(peptide)
    else:
        theoretical_spectrum = calculate_linear_spectrum(peptide)

    score = 0
    exp_spectrum = list(experimental_spectrum)

    for mass in theoretical_spectrum:
        if mass in exp_spectrum:
            score += 1
            exp_spectrum.remove(mass)

    return score

def expand_peptides(peptides):
    """各ペプチドを全てのアミノ酸質量で拡張"""
    expanded = []
    for peptide in peptides:
        for mass in UNIQUE_MASSES:
            expanded.append(peptide + [mass])
    return expanded

def trim_leaderboard(leaderboard, experimental_spectrum, n, is_cyclic=True):
    """リーダーボードをトップNペプチドにトリミング"""
    if not leaderboard:
        return []

    # スコア計算
    scored_peptides = []
    for peptide in leaderboard:
        score = score_peptide(peptide, experimental_spectrum, is_cyclic)
        scored_peptides.append((score, peptide))

    # スコアでソート
    scored_peptides.sort(reverse=True, key=lambda x: x[0])

    # トップN（同点含む）を選択
    if len(scored_peptides) <= n:
        return [peptide for _, peptide in scored_peptides]

    nth_score = scored_peptides[n-1][0]

    trimmed = []
    for score, peptide in scored_peptides:
        if score >= nth_score:
            trimmed.append(peptide)
        else:
            break

    return trimmed

def leaderboard_cyclopeptide_sequencing(experimental_spectrum, n_leaders=1000):
    """
    メインアルゴリズム

    Parameters:
    - experimental_spectrum: 実験スペクトル
    - n_leaders: リーダーボードサイズ

    Returns:
    - (最高スコアのペプチド, スコア)
    """
    parent_mass = max(experimental_spectrum)
    leaderboard = [[]]  # 空のペプチドから開始
    leader_peptide = []
    leader_score = 0

    while leaderboard:
        # 分岐：拡張
        leaderboard = expand_peptides(leaderboard)

        # 各ペプチドをチェック
        new_leaderboard = []
        for peptide in leaderboard:
            peptide_mass = sum(peptide)

            if peptide_mass == parent_mass:
                # 親質量と一致
                score = score_peptide(peptide, experimental_spectrum, True)
                if score > leader_score:
                    leader_peptide = peptide
                    leader_score = score
            elif peptide_mass < parent_mass:
                # まだ拡張可能
                new_leaderboard.append(peptide)

        leaderboard = new_leaderboard

        # 結合：トリミング
        if leaderboard:
            leaderboard = trim_leaderboard(
                leaderboard, experimental_spectrum, n_leaders, False
            )

    return leader_peptide, leader_score
```

## 📊 使用例

### 基本的な使用方法

```python
# 実験スペクトル（例：NQEL）
experimental_spectrum = [0, 113, 114, 128, 129, 227, 242, 257,
                        355, 356, 370, 371, 484]

# アルゴリズム実行
result, score = leaderboard_cyclopeptide_sequencing(
    experimental_spectrum,
    n_leaders=1000
)

print(f"最適ペプチド: {result}")
print(f"スコア: {score}")
```

### ノイズのあるスペクトルのシミュレーション

```python
import random

def simulate_noisy_spectrum(peptide, noise_rate=0.1):
    """ノイズのある実験スペクトルを生成"""
    theoretical = calculate_cyclic_spectrum(peptide)
    experimental = []

    # 欠損質量
    for mass in theoretical:
        if random.random() > noise_rate:
            experimental.append(mass)

    # 偽質量
    n_false = int(len(theoretical) * noise_rate)
    max_mass = max(theoretical)
    for _ in range(n_false):
        false_mass = random.randint(1, max_mass)
        experimental.append(false_mass)

    return sorted(experimental)

# 10%ノイズでテスト
noisy_spectrum = simulate_noisy_spectrum("NQEL", 0.1)
result, score = leaderboard_cyclopeptide_sequencing(noisy_spectrum)
```

## 🎨 可視化

### スペクトル比較

```python
import matplotlib.pyplot as plt

def visualize_spectrum_comparison(theoretical, experimental):
    """理論と実験スペクトルを比較"""
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 6))

    # 理論スペクトル
    ax1.vlines(theoretical, 0, 1, colors='blue', label='理論')
    ax1.set_ylabel('強度')
    ax1.set_title('理論スペクトル')

    # 実験スペクトル
    ax2.vlines(experimental, 0, 1, colors='red', label='実験')
    ax2.set_xlabel('質量 (m/z)')
    ax2.set_ylabel('強度')
    ax2.set_title('実験スペクトル（ノイズ含む）')

    plt.tight_layout()
    plt.show()
```

### リーダーボード進化の追跡

```python
def track_leaderboard_evolution(experimental_spectrum, n_leaders=100):
    """各反復でのリーダーボードを追跡"""
    parent_mass = max(experimental_spectrum)
    leaderboard = [[]]
    evolution = []

    iteration = 0
    while leaderboard and iteration < 10:
        leaderboard = expand_peptides(leaderboard)

        # フィルタリング
        leaderboard = [p for p in leaderboard
                      if sum(p) <= parent_mass]

        # トリミング
        if leaderboard:
            leaderboard = trim_leaderboard(
                leaderboard, experimental_spectrum, n_leaders, False
            )

            # 統計を記録
            scores = [score_peptide(p, experimental_spectrum, False)
                     for p in leaderboard]
            evolution.append({
                'iteration': iteration,
                'size': len(leaderboard),
                'max_score': max(scores) if scores else 0,
                'avg_score': sum(scores) / len(scores) if scores else 0
            })

        iteration += 1

    return evolution
```

## 🚀 パフォーマンス最適化

### 並列処理版

```python
from multiprocessing import Pool

def score_peptide_parallel(args):
    """並列処理用のラッパー"""
    peptide, spectrum = args
    return score_peptide(peptide, spectrum, False)

def trim_leaderboard_parallel(leaderboard, spectrum, n):
    """並列スコア計算"""
    with Pool() as pool:
        args = [(p, spectrum) for p in leaderboard]
        scores = pool.map(score_peptide_parallel, args)

    scored = list(zip(scores, leaderboard))
    scored.sort(reverse=True)

    if len(scored) <= n:
        return [p for _, p in scored]

    nth_score = scored[n-1][0]
    return [p for s, p in scored if s >= nth_score]
```

## ⚠️ 注意点とトラブルシューティング

### よくある問題

1. **メモリ不足**
   - リーダーボードサイズを小さくする
   - よりaggressiveなトリミングを実装

2. **遅い実行**
   - スペクトルをセットに変換して高速化
   - 並列処理を使用

3. **低精度**
   - リーダーボードサイズを増やす
   - スコアリング関数を改善

### デバッグのヒント

```python
def debug_leaderboard(leaderboard, spectrum, top_n=5):
    """リーダーボードの状態をデバッグ"""
    scored = [(score_peptide(p, spectrum, False), p)
              for p in leaderboard]
    scored.sort(reverse=True)

    print(f"リーダーボードサイズ: {len(leaderboard)}")
    print(f"トップ{top_n}ペプチド:")
    for score, peptide in scored[:top_n]:
        print(f"  スコア {score}: {peptide}")
```

## 📚 関連アルゴリズム

- [ブルートフォース環状ペプチド配列決定](brute-force-cyclopeptide)
- [頻出語問題](frequent-words)
- [GCスキュー](gc-skew)

## 🔗 参考文献

- Pevzner, P. & Shamir, R. (2011). _Bioinformatics for Biologists_. Cambridge University Press.
- Compeau, P. & Pevzner, P. (2015). _Bioinformatics Algorithms: An Active Learning Approach_.
