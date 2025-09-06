# スペクトル辞書：サルと統計学者が出会うとき（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**ペプチド同定の統計的有意性を評価し、偽発見を適切に制御できるようになる**

でも、ちょっと待ってください。前回、恐竜のペプチドを見事に同定したと思ったのに、今度は「統計的有意性」？
実は、どんなに高スコアでも、それが「本物」かどうかは別問題なんです。

## 🤔 ステップ0：なぜ統計的有意性の評価が重要なの？

### 0-1. そもそもの問題を考えてみよう

前回の恐竜研究を思い出してください。T-Rexのスペクトルから27個のペプチドが同定されました。
「素晴らしい！ 恐竜の正体が判明した！」
...と思ったら大間違いです。

### 0-2. 驚きの事実

実は、質量分析の世界には「偽陽性」という恐ろしい敵が潜んでいます。
高スコアだからといって、必ずしも正解とは限らないのです。

まさに、推理小説で「完璧なアリバイ」を持つ容疑者が実は犯人だった、という展開と同じですね。

### 0-3. 具体的な問題設定

想像してみてください：

- ヒトのサンプルから1,000個のスペクトルを取得
- ヒトプロテオームに対してPSM検索を実行
- 閾値を超える100個のPSMを発見

**ここで重要な問題**：この100個のうち、何パーセントが間違いでしょうか？

## 📖 ステップ1：デコイプロテオームという天才的発想

### 1-1. まず素朴な疑問から

「どうやって間違いを見つけるの？正解が分からないのに...」

そこで登場するのが「デコイプロテオーム（Decoy Proteome）」という革命的なアイデアです。

### 1-2. デコイプロテオームとは何か

**デコイプロテオーム**：

- 実際のプロテオームと同じサイズ
- しかし、内容は **ランダムに生成された偽物**
- 「正解のないテスト」のようなもの

### 1-3. 実験してみましょう

```python
def decoy_experiment():
    """
    デコイプロテオーム実験のシミュレーション
    """
    # 実際の実験
    real_proteome = load_human_proteome()  # 実際のヒトプロテオーム
    real_matches = psm_search(spectra, real_proteome, threshold=100)
    print(f"実際のプロテオーム: {len(real_matches)} PSM")

    # デコイ実験
    decoy_proteome = generate_random_proteome(size=len(real_proteome))
    decoy_matches = psm_search(spectra, decoy_proteome, threshold=100)
    print(f"デコイプロテオーム: {len(decoy_matches)} PSM")

    return real_matches, decoy_matches
```

### 1-4. ここがポイント

デコイプロテオームで見つかったPSMは、**100%偽物**です。
なぜなら、元々正解のないデータベースだからです。

これは、間違いの数を直接測定する、まさに天才的な方法なのです！

## 📖 ステップ2：偽発見率（FDR）の概念

### 2-1. デコイ実験の結果を分析しよう

T-Rex研究の実際の結果：

- **実際のUniProt+**：27個のPSM
- **デコイプロテオーム**：1個のPSM
- **閾値**：100

### 2-2. FDRの計算方法

**偽発見率（False Discovery Rate, FDR）** の定義：

```python
def calculate_fdr(real_matches, decoy_matches):
    """
    FDRの計算
    """
    fdr = len(decoy_matches) / len(real_matches)
    return fdr * 100  # パーセンテージ

# T-Rex研究の場合
real_psms = 27
decoy_psms = 1
fdr = calculate_fdr(real_psms, decoy_psms)
print(f"FDR = {decoy_psms}/{real_psms} = {fdr:.1f}%")
```

結果：**FDR = 1/27 = 3.7%**

### 2-3. つまり、言い換えると

FDRは「間違いの割合」を表します。

- FDR 3.7% = 約27個のうち1個が間違い
- FDR 5% = 20個のうち1個が間違い

### 2-4. ここで重要な観察をしてみましょう

でも、FDRが3.7%なら「かなり良い結果」と思いませんか？
実は、そう単純ではないのです...

## 📖 ステップ3：実験室汚染という現実的な敵

### 3-1. でも、本当にT-Rexのペプチドが27個？

「素晴らしい！3.7%の誤差で27個の恐竜ペプチドを発見！」
...と思ったら、研究者は首を振りました。

### 3-2. 実験室汚染の正体

実は、同定されたペプチドの多くは：

- **ヒトの皮膚由来のケラチン**
- 実験器具の汚れ
- 空気中に浮遊する微粒子

### 3-3. 驚くべき現実

今、この瞬間にも：

```
あなたの肌から → 何百万個の微粒子が剥がれ落ちる
部屋の空気中に → ケラチンタンパク質が浮遊
質量分析装置に → 混入して「偽の」ピークを作る
```

### 3-4. 実験してみましょう

想像してください：

```python
identified_peptides = [
    ("GPPGPPGKNGDDGEAGKPGCP", "恐竜コラーゲン?", score=95),
    ("SCDCRRSQWSTNGKTIHCCDPR", "ケラチン（実験室汚染）", score=88),
    ("LNAGDCSKSRSTSQSTSSYTC", "ケラチン（実験室汚染）", score=85),
    ("GLPGPPGPPGKNGDDGEAGK", "鳥コラーゲン?", score=82),
    # ... 残り23個
]

print("この中で本当の恐竜ペプチドは何個？")
```

### 3-5. 新たな課題の発見

全体のFDRではなく、**個別のPSMの統計的有意性** を評価する必要があります。

「この特定のペプチド同定は信頼できるか？」

## 📖 ステップ4：個別PSMの統計的有意性評価の必要性

### 4-1. 新しい問題設定

これまで：「100個のPSMのうち5%が間違い」（全体の話）
これから：「このPSMは信頼できるか？」（個別の話）

### 4-2. なぜ個別評価が必要なのか

理由は明確です：

```
ケラチン汚染ペプチド: スコア 88 → 間違いなく偽物
恐竜コラーゲンペプチド: スコア 95 → 本物の可能性が高い
```

同じFDRでも、個別の信頼性は全く異なります。

### 4-3. でも、どうやって個別評価するの？

ここで、まったく予想外の助っ人が登場します...

## 📖 ステップ5：サルとタイプライターの登場

### 5-1. 突然ですが、サルの話

想像してください：

```
🐵 + ⌨️ = ?

サルにタイプライターを渡して
ランダムにキーを叩かせる
長時間続ける
```

### 5-2. 実験結果の発表

サルが生成した文章を分析したところ：

```
ランダムな文字列: "asdfghqwertykjhgfd..."
その中に含まれる正しい英単語: 13個

単語例:
- "cat" (偶然の一致)
- "the" (偶然の一致)
- "dog" (偶然の一致)
...
```

### 5-3. 重要な疑問

### サルは英語を話せるのか？

当然、答えは「NO」です。これらはすべて偶然の産物です。

### 5-4. ここで重要な観察をしてみましょう

でも、**なぜ13個も正しい単語があるのか？**
そして、**この数は妥当なのか？**

これを調べるには「**サルとタイプライター問題**」を解く必要があります。

## 📖 ステップ6：質量分析との驚くべき関連性

### 6-1. 問題の定式化

**サルとタイプライター問題**：

- 入力：辞書、ランダム文字列の長さn
- 出力：長さnのランダム文字列に含まれる辞書単語の期待数

### 6-2. でも、質量分析と何の関係が？

実は、質量分析にもまったく同じ問題があります：

**高スコアペプチドの期待数問題**：

- 入力：スペクトル、デコイプロテオーム長n、スコア閾値
- 出力：長さnのデコイプロテオームで閾値以上のスコアを持つペプチドの期待数

### 6-3. 類似性に気づきましたか？

```python
# サルとタイプライター
random_text = generate_random_text(length=n)
dictionary_words = find_dictionary_words(random_text, webster_dict)
expected_count = calculate_expected_words(n, webster_dict)

# 質量分析
decoy_proteome = generate_random_proteome(length=n)
high_score_peptides = find_high_score_peptides(decoy_proteome, spectrum)
expected_count = calculate_expected_peptides(n, spectrum, threshold)
```

### 6-4. つまり、言い換えると

両方とも「**ランダムなデータから期待される一致数**」を計算する問題なのです！

### 6-5. でも実は、種を明かすと

これらは数学的に**完全に同等**な問題です。

## 📖 ステップ7：スペクトル辞書による統一的理解

### 7-1. 新しい概念の導入

**スペクトル辞書（Spectral Dictionary）**：
特定のスペクトルに対して、閾値以上のスコアを持つ **すべてのペプチドの集合**

```python
def create_spectral_dictionary(spectrum, threshold):
    """
    スペクトル辞書の生成
    """
    dictionary = []

    # 理論上すべての可能なペプチドをチェック
    for peptide in all_possible_peptides():
        score = calculate_score(peptide, spectrum)
        if score >= threshold:
            dictionary.append(peptide)

    return dictionary
```

### 7-2. 問題の再定式化

**元の問題**：

- デコイプロテオームで閾値以上のペプチド期待数を求める

**新しい問題**：

- デコイプロテオームに含まれる「スペクトル辞書の単語」の期待数を求める

### 7-3. 完全な等価性の証明

```python
# Step 1: スペクトル辞書を生成
spectral_dict = create_spectral_dictionary(spectrum, threshold)

# Step 2: 問題を再定式化
def expected_peptides_in_decoy(n, spectral_dict):
    """
    長さnのデコイプロテオームに含まれる
    スペクトル辞書ペプチドの期待数
    """
    return calculate_expected_strings(n, spectral_dict)
```

### 7-4. ここが「魔法」のような部分です

スペクトル辞書により：

- **サルとタイプライター問題** = 辞書からの単語期待数
- **質量分析問題** = スペクトル辞書からのペプチド期待数

両者が **完全に同じ数学的構造** を持つことが明確になりました！

### 7-5. 実用的な意味

これにより：

1. **サルとタイプライター問題**の解法がそのまま使える
2. 統計学の豊富な知識を活用可能
3. 個別PSMの統計的有意性を正確に評価できる

## 📖 ステップ8：問題の完全な再定式化

### 8-1. 最終的な問題設定

**入力**：

- スペクトル辞書のすべてのペプチド
- デコイプロテオーム長 n

**出力**：

- 長さnのデコイプロテオームに現れる辞書ペプチドの期待数

### 8-2. 実装例

```python
def solve_spectral_dictionary_problem(spectrum, threshold, n):
    """
    スペクトル辞書問題の解法
    """
    # Step 1: スペクトル辞書を構築
    spectral_dict = create_spectral_dictionary(spectrum, threshold)
    print(f"スペクトル辞書サイズ: {len(spectral_dict)} ペプチド")

    # Step 2: 期待数を計算
    expected_count = 0
    for peptide in spectral_dict:
        probability = calculate_occurrence_probability(peptide, n)
        expected_count += probability

    return expected_count

# 使用例
spectrum = load_trex_spectrum()
n = 2_000_000  # UniProt+のサイズ
expected = solve_spectral_dictionary_problem(spectrum, threshold=100, n)
print(f"期待される偽陽性数: {expected:.2f}")
```

### 8-3. 統計的有意性の評価

```python
def evaluate_psm_significance(observed_psms, expected_false_positives):
    """
    PSMの統計的有意性評価
    """
    if observed_psms <= expected_false_positives:
        return "統計的に有意ではない（偶然の可能性大）"
    else:
        significance = observed_psms / expected_false_positives
        return f"統計的に有意（期待値の{significance:.1f}倍）"

# T-Rex研究への適用
observed = 27
expected = 1.0  # デコイ実験から推定
result = evaluate_psm_significance(observed, expected)
print(result)
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- デコイプロテオームで偽陽性の数を推定できる
- FDR（偽発見率）は間違いの割合を示す指標
- 実験室汚染が質量分析の大きな問題
- スペクトル辞書は高スコアペプチドの集合

### レベル2：本質的理解（ここまで来たら素晴らしい）

- サルとタイプライター問題と質量分析は数学的に同等
- ランダムデータからの期待値計算が統計的評価の基礎
- 個別PSMの有意性評価が実用上重要
- スペクトル辞書により問題を統一的に理解可能

### レベル3：応用的理解（プロレベル）

- 統計学の理論を直接質量分析に応用できる仕組み
- 期待値計算の数学的背景と計算複雑度
- 実験設計における統計的検出力の重要性
- 多重検定問題とFDR制御の理論的基盤

## 🚀 次回予告

さらに興味深い発展が待っています！
次回は「**期待値計算の実際の数学**」について詳しく学びます。

スペクトル辞書の期待値を実際にどう計算するのか？数学の美しい理論がいかに実用的な問題解決に威力を発揮するかを体験しましょう。

また、**多重検定補正**の重要性と、なぜ単純なFDRでは不十分なのかの深い理由も明らかにします。お楽しみに！

---

## 今日のポイント

- デコイプロテオーム = 偽陽性の検出器
- FDR = 間違いの割合の指標
- 実験室汚染 = 現実的な大敵
- サルとタイプライター = 統計的類推の天才的発想
- スペクトル辞書 = 統一的理解の鍵
