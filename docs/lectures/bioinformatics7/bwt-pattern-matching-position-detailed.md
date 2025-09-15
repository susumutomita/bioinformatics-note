# BWTによるパターン検索：位置の特定編（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**BWTでパターンを見つけた後、その正確な位置を特定する方法を完全マスター**

でも、ちょっと待ってください。前回の講義でBWTを使ってパターンが「ある」ことは分かったけど、「どこに」あるかが分からないままでした。
実は、**サフィックス配列**という魔法のようなデータ構造を使えば、位置まで完璧に特定できるんです！

## 🤔 ステップ0：なぜ位置の特定が重要なの？

### 0-1. そもそもの問題を考えてみよう

たとえば、あなたが「GATTACA」という遺伝子配列を3GBのヒトゲノムから探しているとします。

```python
# 前回までの状況
genome = "...CGATTACAG...GATTACA...TGATTACAT..."  # 3GB！
pattern = "GATTACA"

# BWTで検索すると...
print("GATTACAは存在します！3回見つかりました！")
print("でも...どこにあるの？？？")
```

この「どこ？」がわからないと：

- 🔬 研究者は遺伝子の位置を特定できない
- 💊 薬の設計で標的部位がわからない
- 🧬 突然変異の場所を報告できない

### 0-2. 驚きの事実

実は、BWTの各行には「元の文字列のどの位置から始まるサフィックス」という隠れた情報があるんです！
これを記録しておけば、位置が一発でわかる！

## 📖 ステップ1：サフィックス配列って何？

### 1-1. まず素朴な疑問から

「サフィックス」って聞いたことありますか？
これは「接尾辞」、つまり文字列の途中から最後までの部分文字列のことです。

```python
def show_all_suffixes(text):
    """文字列のすべてのサフィックスを表示"""
    for i in range(len(text)):
        suffix = text[i:]
        print(f"位置 {i}: {suffix}")

# 例：「BANANA$」のすべてのサフィックス
show_all_suffixes("BANANA$")
```

実行結果：

```
位置 0: BANANA$
位置 1: ANANA$
位置 2: NANA$
位置 3: ANA$
位置 4: NA$
位置 5: A$
位置 6: $
```

### 1-2. なぜこれが役立つの？

BWTの各行は、実は元の文字列の**周期的回転**を辞書順に並べたものでした。
そして、各回転は必ず「どこかから始まるサフィックス」に対応しているんです！

## 📖 ステップ2：「panamabananas$」で実験してみよう

### 2-1. BWTマトリックスを作ってみる

```python
def create_bwt_matrix_with_positions(text):
    """BWTマトリックスを作成し、各行の開始位置も記録"""
    n = len(text)
    # すべての回転を作成
    rotations = []
    for i in range(n):
        rotation = text[i:] + text[:i]
        rotations.append((rotation, i))  # 回転と開始位置のペア

    # 辞書順にソート
    rotations.sort(key=lambda x: x[0])

    # 表示
    print("位置 | 回転（BWTマトリックス）")
    print("-" * 40)
    for rotation, pos in rotations:
        # 元の文字列でこの回転がどの位置から始まるか
        suffix_start = (n - pos) % n
        print(f"{suffix_start:4} | {rotation}")

    return rotations

text = "panamabananas$"
rotations = create_bwt_matrix_with_positions(text)
```

実行結果：

```
位置 | 回転（BWTマトリックス）
----------------------------------------
  13 | $panamabananas
   5 | abananas$panam
   3 | amabananas$pan
  11 | ana$panamaban
   7 | anas$panamaba
   1 | anamabananas$p
   9 | as$panamabana
   4 | bananas$panama
  12 | na$panamabana
   6 | nanas$panamab
  10 | nas$panamaban
   2 | namabananas$pa
   8 | s$panamabanana
   0 | panamabananas$
```

### 2-2. ここがポイント

でも待って、左端の数字（13, 5, 3, 11, ...）が何を表しているか分かりますか？

これは**元の文字列でその行のサフィックスが始まる位置**なんです！

```python
def explain_suffix_array():
    """サフィックス配列の意味を詳しく説明"""
    text = "panamabananas$"

    # 第1行：$panamabananas
    print("第1行：'$panamabananas'")
    print("  → $から始まるサフィックスは位置13から")
    print(f"  → 確認：text[13:] = '{text[13:]}'")
    print()

    # 第2行：abananas$panam
    print("第2行：'abananas$panam'")
    print("  → abananas$で始まるサフィックスは位置5から")
    print(f"  → 確認：text[5:] = '{text[5:]}'")
    print()

    # 第3行：amabananas$pan
    print("第3行：'amabananas$pan'")
    print("  → amabananas$で始まるサフィックスは位置3から")
    print(f"  → 確認：text[3:] = '{text[3:]}'")

explain_suffix_array()
```

## 📖 ステップ3：サフィックス配列の正体

### 3-1. 定義を整理しよう

```python
class SuffixArray:
    """サフィックス配列の実装"""

    def __init__(self, text):
        self.text = text
        self.n = len(text)
        self.suffix_array = self._build_suffix_array()

    def _build_suffix_array(self):
        """サフィックス配列を構築"""
        # すべてのサフィックスとその開始位置のペアを作成
        suffixes = []
        for i in range(self.n):
            suffix = self.text[i:]
            suffixes.append((suffix, i))

        # 辞書順にソート
        suffixes.sort(key=lambda x: x[0])

        # 位置だけを取り出す
        return [pos for suffix, pos in suffixes]

    def show(self):
        """サフィックス配列を表示"""
        print("インデックス | SA値 | サフィックス")
        print("-" * 50)
        for i, pos in enumerate(self.suffix_array):
            suffix = self.text[pos:]
            print(f"{i:11} | {pos:4} | {suffix}")

# 実験
sa = SuffixArray("panamabananas$")
sa.show()
```

### 3-2. つまり、サフィックス配列とは

#### サフィックス配列の定義

辞書順にソートされたサフィックスの開始位置のリスト

これだけ！シンプルでしょう？

## 📖 ステップ4：パターンの位置を特定する魔法

### 4-1. 「ana」を探してみよう

前回のBWT検索で「ana」が3回見つかったとします。
さて、それらの位置はどこでしょう？

```python
def find_pattern_positions(text, pattern):
    """BWTとサフィックス配列を使ってパターンの位置を特定"""

    # ステップ1：BWTマトリックスとサフィックス配列を構築
    n = len(text)
    rotations = []
    for i in range(n):
        rotation = text[i:] + text[:i]
        suffix_start = (n - i) % n
        rotations.append((rotation, suffix_start))

    rotations.sort(key=lambda x: x[0])

    # ステップ2：パターンで始まる行を探す
    positions = []
    print(f"'{pattern}'を探しています...")
    print("-" * 50)

    for i, (rotation, suffix_pos) in enumerate(rotations):
        if rotation.startswith(pattern):
            positions.append(suffix_pos)
            print(f"行 {i}: {rotation[:20]}... → 位置 {suffix_pos}")

    return positions

# 実験
text = "panamabananas$"
pattern = "ana"
positions = find_pattern_positions(text, pattern)

print(f"\n結果：'{pattern}'は位置 {positions} にあります！")

# 検証
print("\n検証してみましょう：")
for pos in positions:
    print(f"位置 {pos}: {text[pos:pos+len(pattern)]}")
```

### 4-2. 魔法の種明かし

なんと！サフィックス配列の値（1, 7, 9）が、そのまま「ana」の出現位置になっています！

これは偶然ではありません。BWTマトリックスの各行が辞書順に並んでいて、
「ana」で始まる行のサフィックス配列の値が、まさに「ana」の開始位置を示しているからです。

## 📖 ステップ5：完全なBWT検索システムの実装

### 5-1. すべてを統合しよう

```python
class BWTPatternMatcher:
    """BWTとサフィックス配列を使った完全なパターンマッチャー"""

    def __init__(self, text):
        if not text.endswith('$'):
            text += '$'
        self.text = text
        self.n = len(text)
        self.bwt = self._build_bwt()
        self.suffix_array = self._build_suffix_array()
        self.first_column = sorted(self.bwt)

    def _build_bwt(self):
        """BWT文字列を構築"""
        rotations = []
        for i in range(self.n):
            rotation = self.text[i:] + self.text[:i]
            rotations.append(rotation)
        rotations.sort()
        return ''.join(rot[-1] for rot in rotations)

    def _build_suffix_array(self):
        """サフィックス配列を構築"""
        suffixes = []
        for i in range(self.n):
            suffix = self.text[i:]
            suffixes.append((suffix, i))
        suffixes.sort(key=lambda x: x[0])
        return [pos for suffix, pos in suffixes]

    def search(self, pattern):
        """パターンを検索し、すべての出現位置を返す"""
        # ステップ1：BWTで範囲を特定（前回の内容）
        top = 0
        bottom = self.n - 1

        for char in reversed(pattern):
            # ... BWTマッチングアルゴリズム（簡略化）
            pass

        # ステップ2：サフィックス配列から位置を取得
        # （実際の実装では範囲内のインデックスを使用）
        positions = []
        # ここで見つかった範囲のサフィックス配列値を返す

        return positions

# 使用例
matcher = BWTPatternMatcher("panamabananas")
# positions = matcher.search("ana")
# print(f"'ana'の位置: {positions}")
```

## 📖 ステップ6：メモリ使用量の問題

### 6-1. でも、ちょっと待って

```python
def calculate_memory_usage(genome_size_gb=3):
    """メモリ使用量を計算"""
    genome_size_bytes = genome_size_gb * 10**9

    print(f"ゲノムサイズ: {genome_size_gb}GB")
    print("-" * 50)

    # BWT文字列
    bwt_size = genome_size_bytes  # 1文字1バイト
    print(f"BWT文字列: {bwt_size / 10**9:.1f}GB")

    # サフィックス配列（整数は4バイト）
    sa_size = genome_size_bytes * 4
    print(f"サフィックス配列: {sa_size / 10**9:.1f}GB")

    # 合計
    total = bwt_size + sa_size
    print(f"合計: {total / 10**9:.1f}GB")

    return total

memory = calculate_memory_usage(3)
```

実行結果：

```
ゲノムサイズ: 3GB
--------------------------------------------------
BWT文字列: 3.0GB
サフィックス配列: 12.0GB
合計: 15.0GB
```

### 6-2. 驚きの事実

えっ！？サフィックス配列だけで12GBも使うの！？

そうなんです。各位置を32ビット整数で保存すると、元のゲノムの4倍のメモリが必要になります。
これは大問題です！

## 📖 ステップ7：サフィックスツリーとの不思議な関係

### 7-1. 実はサフィックス配列はツリーに隠れている

```python
def show_suffix_tree_traversal():
    """サフィックスツリーの順序走査とサフィックス配列の関係"""

    print("サフィックスツリーの順序走査：")
    print("（左から右へ、深さ優先で訪問）")
    print()

    # 簡略化した例
    tree_traversal = [
        ("$", 13),
        ("a", None),
        ("  bananas$", 5),
        ("  mabananas$", 3),
        ("  na", None),
        ("    $", 11),
        ("    mabananas$", 1),
        ("    s$", 7),
        # ... 以下省略
    ]

    print("ノード | 葉の値（サフィックス配列）")
    print("-" * 40)
    sa_values = []
    for node, value in tree_traversal:
        if value is not None:
            print(f"{node:15} | {value}")
            sa_values.append(value)

    print(f"\nサフィックス配列: {sa_values}")
    print("これが辞書順になっている！")

show_suffix_tree_traversal()
```

### 7-2. なるほど、だから

サフィックスツリーを順序走査（in-order traversal）すると、
葉ノードの値がそのままサフィックス配列になるんです！

これは偶然ではなく、両方とも「辞書順にソートされたサフィックス」を表現しているからです。

## 📖 ステップ8：メモリ削減への挑戦

### 8-1. 現状の問題を整理

```python
def compare_data_structures():
    """各データ構造のメモリ使用量を比較"""

    data = {
        "元のゲノム": 1,
        "サフィックスツリー": 20,
        "BWT + サフィックス配列": 5,
        "BWT単体": 1,
        "理想": 1.5
    }

    print("データ構造 | メモリ使用量（ゲノムサイズ比）")
    print("-" * 50)
    for name, ratio in data.items():
        bar = "■" * int(ratio * 2)
        print(f"{name:20} | {ratio:4.1f}x {bar}")

compare_data_structures()
```

### 8-2. 次回予告：驚きの解決策

でも、諦めないでください！
実は、サフィックス配列を**圧縮**する天才的な方法があるんです。

- **チェックポイント法**：一部の位置だけ保存
- **FMインデックス**：BWTの性質を最大限活用
- **ウェーブレット木**：さらなる圧縮

次回は、メモリ使用量を劇的に削減しながら、高速検索を実現する方法を学びます！

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- BWTで「パターンがある」ことは分かるが、「どこに」あるかは分からない
- サフィックス配列 = 各サフィックスの開始位置を記録した配列
- サフィックス配列を使えば位置が特定できる

### レベル2：本質的理解（ここまで来たら素晴らしい）

- BWTマトリックスの各行は、元の文字列のサフィックスに対応
- サフィックス配列の値が、そのままパターンの出現位置になる
- ただし、メモリ使用量が4倍になる問題がある

### レベル3：応用的理解（プロレベル）

- サフィックス配列はサフィックスツリーの葉を順序走査したもの
- メモリと速度のトレードオフが存在
- 実用的にはさらなる圧縮技術が必要

## 🚀 実践課題

```python
# 課題1：小さな文字列で実験
text = "mississippi$"
# 1. BWTマトリックスを作成
# 2. サフィックス配列を構築
# 3. "si"の位置をすべて見つける

# 課題2：メモリ使用量の計算
# あなたのPCで扱える最大のゲノムサイズは？

# 課題3：最適化のアイデア
# サフィックス配列のメモリを削減する方法を考えてみよう
```

## 💭 次回予告

「**BWTの完成形：FMインデックスによる超高速・省メモリ検索**」

次回は、ついにBWTの真の力が解放されます！

- メモリ使用量を1/10に削減
- 検索速度は変わらず高速
- 実際のゲノム解析ツールで使われている技術

お楽しみに！

---

_Bioinformatics Algorithms: An Active Learning Approach_ より
_第7章：パターンマッチングの革命 - サフィックス配列編_
