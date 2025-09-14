# 文字列圧縮とBurrows-Wheeler変換（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**巨大なゲノムデータを効率的に圧縮し、かつ高速にパターン検索できる魔法のような変換方法を理解する**

でも、ちょっと待ってください。そもそも「圧縮」と「検索」を同時に実現できるなんて、本当に可能なのでしょうか？
実は、**Burrows-Wheeler変換（BWT）**という天才的な発明により、これが可能になるんです。今日は、この不思議な変換の仕組みを、一歩ずつ解明していきましょう！

## 🤔 ステップ0：なぜサフィックスツリーだけじゃダメなの？

### 0-1. そもそもの問題を考えてみよう

前回の講義で、サフィックスツリーは素晴らしいデータ構造だと学びました。パターンマッチングがO(|パターン|)でできるなんて！

でも、実際にヒトゲノム（約30億文字）のサフィックスツリーを作ろうとすると...

```python
def calculate_memory_usage():
    """
    サフィックスツリーのメモリ使用量を計算
    """
    genome_size = 3_000_000_000  # 30億文字
    memory_factor = 20  # 実装によっては20倍必要

    bytes_needed = genome_size * memory_factor
    gb_needed = bytes_needed / (1024**3)

    print(f"必要メモリ: {gb_needed:.1f} GB")
    return gb_needed

calculate_memory_usage()
# 出力: 必要メモリ: 55.9 GB
```

### 0-2. 驚きの事実

なんと！**ゲノムの長さの20倍**ものメモリが必要なんです。普通のラップトップでは扱えません。

ここで重要な観察：

- サフィックスツリーは**検索は速い**が**メモリを食う**
- じゃあ、メモリ効率の良い方法はないの？
- 実は圧縮技術と組み合わせることで解決できる！

## 📖 ステップ1：まずは素朴な圧縮から考えてみよう

### 1-1. ランレングス圧縮って知ってる？

身近な例から始めましょう。次の文字列を見てください：

```
GGGGGGGGGGCCCCCCCCCCCAAAAAAAATTTTT
```

これ、もっと短く書けそうですよね？

```python
def run_length_encoding(text):
    """
    同じ文字の連続（ラン）を数えて圧縮
    """
    if not text:
        return ""

    result = []
    current_char = text[0]
    count = 1

    for i in range(1, len(text)):
        if text[i] == current_char:
            count += 1
        else:
            result.append(f"{count}{current_char}")
            current_char = text[i]
            count = 1

    result.append(f"{count}{current_char}")
    return "".join(result)

original = "GGGGGGGGGGCCCCCCCCCCCAAAAAAAATTTTT"
compressed = run_length_encoding(original)
print(f"元の文字列: {original} ({len(original)}文字)")
print(f"圧縮後: {compressed} ({len(compressed)}文字)")
# 出力:
# 元の文字列: GGGGGGGGGGCCCCCCCCCCCAAAAAAAATTTTT (35文字)
# 圧縮後: 10G11C9A5T (10文字)
```

### 1-2. でも待って、ゲノムってそんなに単純じゃない

実際のゲノムを見てみましょう：

```python
def count_runs(genome):
    """
    実際のゲノムでランの数を数える
    """
    runs = 1
    for i in range(1, len(genome)):
        if genome[i] != genome[i-1]:
            runs += 1
    return runs

# 実際のゲノムの一部
real_genome = "ATCGATCGATCGATCG" * 100
runs = count_runs(real_genome)
print(f"文字数: {len(real_genome)}, ラン数: {runs}")
print(f"平均ラン長: {len(real_genome) / runs:.2f}")
# 出力: 文字数: 1600, ラン数: 1600
# 平均ラン長: 1.00
```

なんと！実際のゲノムでは、ほとんど連続がない（平均ラン長が1に近い）！
つまり、**普通のランレングス圧縮は効果がない**んです。

## 📖 ステップ2：魔法の変換 - Burrows-Wheeler変換

### 2-1. そもそもBurrows-Wheeler変換って何？

ここで天才的な発想が！
「**文字列を並び替えて、ランが多い形に変換できないか？**」

でも普通に並び替えたら、元に戻せませんよね？
実は、特殊な並び替え方法があるんです。それがBurrows-Wheeler変換！

### 2-2. 具体例で理解しよう：「banana」の変換

まず、簡単な例「banana$」で手順を追ってみましょう（$は終端記号）：

```python
def create_rotations(text):
    """
    文字列の全ての回転を作る
    """
    rotations = []
    for i in range(len(text)):
        # i文字目から始まる回転
        rotation = text[i:] + text[:i]
        rotations.append(rotation)
    return rotations

def burrows_wheeler_transform(text):
    """
    Burrows-Wheeler変換を実行
    """
    # ステップ1: 全ての回転を作る
    rotations = create_rotations(text)
    print("1. 全ての回転:")
    for i, rot in enumerate(rotations):
        print(f"   {i}: {rot}")

    # ステップ2: 辞書順にソート
    sorted_rotations = sorted(rotations)
    print("\n2. ソート後:")
    for i, rot in enumerate(sorted_rotations):
        print(f"   {i}: {rot}")

    # ステップ3: 最後の列を取り出す
    bwt = ''.join([rot[-1] for rot in sorted_rotations])
    print(f"\n3. BWT（最後の列）: {bwt}")

    return bwt

# 実行してみよう！
text = "banana$"
bwt = burrows_wheeler_transform(text)
```

出力：

```
1. 全ての回転:
   0: banana$
   1: anana$b
   2: nana$ba
   3: ana$ban
   4: na$bana
   5: a$banan
   6: $banana

2. ソート後:
   0: $banana
   1: a$banan
   2: ana$ban
   3: anana$b
   4: banana$
   5: na$bana
   6: nana$ba

3. BWT（最後の列）: annb$aa
```

### 2-3. なぜ最後の列を取るの？

ここが「魔法」のような部分です！

```python
def visualize_bwt_magic(text):
    """
    BWTの魔法を可視化
    """
    rotations = create_rotations(text)
    sorted_rotations = sorted(rotations)

    print("ソート後の行列を見てみよう：")
    print("最初の列 | 最後の列")
    print("-" * 20)

    first_column = ''.join([rot[0] for rot in sorted_rotations])
    last_column = ''.join([rot[-1] for rot in sorted_rotations])

    for i, rot in enumerate(sorted_rotations):
        print(f"    {rot[0]}    |    {rot[-1]}     {rot}")

    print(f"\n最初の列: {first_column}")
    print(f"最後の列:  {last_column} ← これがBWT！")

    # ランを数えてみる
    def count_consecutive(s):
        count = 1
        for i in range(1, len(s)):
            if s[i] != s[i-1]:
                count += 1
        return count

    print(f"\n元の文字列のラン数: {count_consecutive(text)}")
    print(f"BWTのラン数: {count_consecutive(last_column)}")

visualize_bwt_magic("banana$")
```

## 📖 ステップ3：なぜBWTは圧縮に効果的なの？

### 3-1. 繰り返しパターンの秘密

実は、文章には隠れた繰り返しパターンがあります：

```python
def analyze_real_text():
    """
    実際のテキストでBWTの効果を見る
    """
    # DNAの二重らせん構造の論文から（例）
    text = "the structure and the function and the role$"

    print(f"元のテキスト: {text}")
    print(f"繰り返し単語: 'the' が3回、'and' が2回")

    # BWTを実行
    rotations = create_rotations(text)
    sorted_rotations = sorted(rotations)
    bwt = ''.join([rot[-1] for rot in sorted_rotations])

    print(f"\nBWT後: {bwt}")

    # 'the'の前の文字を見てみる
    print("\n'the'で始まる回転を見てみよう：")
    for rot in sorted_rotations:
        if rot.startswith("the"):
            print(f"  {rot} → 最後の文字: {rot[-1]}")

analyze_real_text()
```

### 3-2. ここで重要な観察

同じ単語（例：「the」）が複数回現れると：

1. ソート後、これらは**近くに集まる**
2. その前の文字（多くの場合スペース）が**最後の列に集まる**
3. 結果として**ランが増える**！

## 📖 ステップ4：より複雑な例「panamabananas」

### 4-1. 講義で使われた例を詳しく見てみよう

```python
def detailed_bwt_example():
    """
    'panamabananas$'の詳細なBWT解析
    """
    text = "panamabananas$"

    # 全ての回転を作成
    rotations = []
    for i in range(len(text)):
        rotation = text[i:] + text[:i]
        rotations.append((i, rotation))

    # ソート
    sorted_rotations = sorted(rotations, key=lambda x: x[1])

    # 美しく表示
    print("回転番号 | ソート後の文字列     | 最後の文字")
    print("-" * 50)

    bwt_chars = []
    for orig_idx, rot in sorted_rotations:
        last_char = rot[-1]
        bwt_chars.append(last_char)

        # 'ana'パターンをハイライト
        display_rot = rot
        if 'ana' in rot:
            display_rot = rot.replace('ana', '[ana]')

        print(f"   {orig_idx:2d}    | {display_rot:20s} | {last_char}")

    bwt = ''.join(bwt_chars)
    print(f"\nBWT結果: {bwt}")

    # パターン分析
    print("\n重要な観察：")
    print("- 'ana'というパターンが3回出現")
    print("- ソート後、これらは連続して配置される")
    print("- その結果、'a'が連続してBWTに現れる")

    return bwt

bwt_result = detailed_bwt_example()
```

### 4-2. ランの効果を測定

```python
def measure_compression_effect(text):
    """
    圧縮効果を測定
    """
    # BWTを実行
    rotations = create_rotations(text)
    sorted_rotations = sorted(rotations)
    bwt = ''.join([rot[-1] for rot in sorted_rotations])

    # ランレングス圧縮
    def compress(s):
        result = []
        i = 0
        while i < len(s):
            char = s[i]
            count = 1
            while i + count < len(s) and s[i + count] == char:
                count += 1
            if count > 1:
                result.append(f"{count}{char}")
            else:
                result.append(char)
            i += count
        return ''.join(result)

    original_compressed = compress(text)
    bwt_compressed = compress(bwt)

    print(f"元の文字列: {text}")
    print(f"圧縮後: {original_compressed} ({len(original_compressed)}文字)")
    print(f"\nBWT後: {bwt}")
    print(f"圧縮後: {bwt_compressed} ({len(bwt_compressed)}文字)")
    print(f"\n圧縮率改善: {len(original_compressed) - len(bwt_compressed)}文字削減")

# いくつかの例で試してみる
examples = [
    "banana$",
    "panamabananas$",
    "mississippi$",
    "abracadabra$"
]

for ex in examples:
    print(f"\n{'='*50}")
    measure_compression_effect(ex)
```

## 📖 ステップ5：なぜ最初の列じゃダメなの？

### 5-1. 素朴な疑問

講義で触れられた重要な質問：「最初の列もランが多いんじゃない？」

```python
def compare_first_vs_last_column():
    """
    最初の列と最後の列を比較
    """
    texts = ["banana$", "mississippi$", "abracadabra$"]

    for text in texts:
        rotations = create_rotations(text)
        sorted_rotations = sorted(rotations)

        first_col = ''.join([rot[0] for rot in sorted_rotations])
        last_col = ''.join([rot[-1] for rot in sorted_rotations])

        print(f"\n文字列: {text}")
        print(f"最初の列: {first_col}")
        print(f"最後の列: {last_col}")

        # でも、最初の列には重大な問題が...
        print("\n問題点：")
        print("最初の列は常にソート済み！（辞書順）")
        print("→ 元の文字列の情報が失われている！")

compare_first_vs_last_column()
```

### 5-2. 最後の列が特別な理由

```python
def explain_why_last_column():
    """
    最後の列が選ばれる本当の理由
    """
    text = "banana$"
    rotations = create_rotations(text)
    sorted_rotations = sorted(rotations)

    print("重要な性質：")
    print("1. 最後の列は元の文字列を復元するのに十分な情報を持つ")
    print("2. かつ、圧縮効果が高い")
    print("\n証明のヒント：")

    for i, rot in enumerate(sorted_rotations):
        next_char = rot[1] if len(rot) > 1 else '$'
        print(f"{rot} → 最後の文字'{rot[-1]}'の次は'{next_char}'")

    print("\nつまり、最後の列の各文字は、")
    print("「ソート後のどの位置の文字の前にあったか」という情報を保持！")

explain_why_last_column()
```

## 📖 ステップ6：実際のゲノムデータでの効果

### 6-1. ゲノム配列での実験

```python
import random

def generate_genome_with_repeats(length=1000, repeat_prob=0.3):
    """
    繰り返しを含むゲノム配列を生成
    """
    bases = ['A', 'T', 'C', 'G']
    patterns = ['ATG', 'GCA', 'TCA', 'GAT']  # よくあるパターン

    genome = []
    i = 0
    while i < length:
        if random.random() < repeat_prob and i < length - 3:
            # パターンを挿入
            pattern = random.choice(patterns)
            genome.extend(list(pattern))
            i += 3
        else:
            # ランダムな塩基
            genome.append(random.choice(bases))
            i += 1

    return ''.join(genome[:length]) + '$'

def test_on_genome():
    """
    ゲノムデータでBWTをテスト
    """
    genome = generate_genome_with_repeats(100)

    # BWTを実行（簡略版）
    rotations = create_rotations(genome)
    sorted_rotations = sorted(rotations)
    bwt = ''.join([rot[-1] for rot in sorted_rotations])

    # ラン数を比較
    def count_runs(s):
        runs = 1
        for i in range(1, len(s)):
            if s[i] != s[i-1]:
                runs += 1
        return runs

    original_runs = count_runs(genome)
    bwt_runs = count_runs(bwt)

    print(f"ゲノム長: {len(genome)}")
    print(f"元のラン数: {original_runs}")
    print(f"BWT後のラン数: {bwt_runs}")
    print(f"改善率: {((original_runs - bwt_runs) / original_runs * 100):.1f}%")

    # 実際の圧縮サイズを計算
    def calc_compressed_size(s):
        size = 0
        i = 0
        while i < len(s):
            j = i
            while j < len(s) and s[j] == s[i]:
                j += 1
            run_length = j - i
            # 数字の桁数 + 1文字
            size += len(str(run_length)) + 1
            i = j
        return size

    original_size = calc_compressed_size(genome)
    bwt_size = calc_compressed_size(bwt)

    print(f"\n圧縮後のサイズ:")
    print(f"元: {original_size} バイト")
    print(f"BWT後: {bwt_size} バイト")
    print(f"圧縮率: {(1 - bwt_size/original_size) * 100:.1f}%改善")

# 複数回実験
for i in range(3):
    print(f"\n実験{i+1}:")
    test_on_genome()
```

## 📖 ステップ7：サフィックスツリーとの関係

### 7-1. 実は深い関係がある

```python
def show_suffix_array_connection():
    """
    BWTとサフィックス配列の関係を示す
    """
    text = "banana$"
    n = len(text)

    # サフィックス配列を作る
    suffixes = []
    for i in range(n):
        suffix = text[i:]
        suffixes.append((i, suffix))

    # ソート
    suffixes.sort(key=lambda x: x[1])

    print("サフィックス配列:")
    print("位置 | サフィックス")
    print("-" * 30)
    for pos, suffix in suffixes:
        print(f" {pos:2d}  | {suffix}")

    print("\n実は...")
    print("BWTの各文字は、サフィックス配列の")
    print("各位置の1文字前の文字なんです！")

    print("\n証明:")
    bwt_chars = []
    for pos, suffix in suffixes:
        prev_pos = (pos - 1) % n
        prev_char = text[prev_pos]
        bwt_chars.append(prev_char)
        print(f"位置{pos}の前 → {prev_char}")

    print(f"\nBWT: {''.join(bwt_chars)}")

show_suffix_array_connection()
```

### 7-2. メモリ効率の比較

```python
def compare_memory_efficiency():
    """
    各データ構造のメモリ使用量を比較
    """
    genome_size = 3_000_000_000  # 30億文字

    structures = {
        "元のゲノム": genome_size * 1,
        "サフィックスツリー": genome_size * 20,
        "サフィックス配列": genome_size * 4,  # 整数配列
        "BWT": genome_size * 1,  # 文字列と同じ
        "圧縮BWT": genome_size * 0.3,  # 圧縮後（推定）
    }

    print("30億文字のゲノムに必要なメモリ:")
    print("-" * 40)

    for name, bytes_needed in structures.items():
        gb = bytes_needed / (1024**3)
        print(f"{name:20s}: {gb:6.1f} GB")

    print("\n結論：")
    print("BWTは元のゲノムと同じサイズ！")
    print("しかも圧縮可能で、パターン検索も可能！")

compare_memory_efficiency()
```

## 📖 ステップ8：BWTの逆変換（おまけ）

### 8-1. 元に戻せるの？

```python
def inverse_bwt(bwt):
    """
    BWTから元の文字列を復元（簡易版）
    """
    n = len(bwt)

    # 最後の列（L列）と最初の列（F列）を作る
    L = list(bwt)
    F = sorted(L)

    print(f"L列（BWT）: {' '.join(L)}")
    print(f"F列（ソート後）: {' '.join(F)}")

    # LF-mappingを構築
    # （詳細は次回の講義で！）

    print("\n逆変換のアイデア：")
    print("1. F列の文字は、L列のどこかから来た")
    print("2. 同じ文字の順序は保存される")
    print("3. これらの関係を辿れば復元できる！")

    # 実際の復元は複雑なので省略
    return "（復元アルゴリズムは次回！）"

# 試してみる
bwt = "annb$aa"
inverse_bwt(bwt)
```

## 📝 まとめ：3段階の理解レベル

### レベル1：表面的理解（これだけでもOK）

- **BWT = 文字列を特殊な方法で並び替える変換**
- 手順：回転 → ソート → 最後の列を取る
- 効果：同じパターンが集まってランが増える → 圧縮しやすい

### レベル2：本質的理解（ここまで来たら素晴らしい）

- **BWTは文脈情報を保持しながら局所性を高める**
- 繰り返しパターンの前後の文字が集まる性質
- サフィックス配列と密接な関係
- 元に戻せる（可逆変換）という驚きの性質

### レベル3：応用的理解（プロレベル）

- **BWTはゲノム解析の基盤技術**
- FM-indexと組み合わせて高速パターン検索
- 圧縮率とメモリ効率の最適なバランス
- 実際のゲノムアライナー（BWA、Bowtie）の核心技術

## 🔮 次回予告：BWTを使った超高速パターン検索

次回は、このBWTを使って、なんと**圧縮したまま**パターン検索ができる「FM-index」という驚異的な技術を学びます！

考えてみてください：

- 30億文字のゲノムを圧縮
- 解凍せずに検索
- しかもサフィックスツリーより省メモリ

こんな魔法のような技術、本当に存在するのでしょうか？
次回、その謎を解き明かします！

## 🧪 実験課題（やってみよう！）

```python
def challenge():
    """
    自分の名前でBWTを試してみよう！
    """
    # あなたの名前を入れてください
    your_name = "YAMADA$"  # 例

    # BWTを実行
    rotations = create_rotations(your_name)
    sorted_rotations = sorted(rotations)
    bwt = ''.join([rot[-1] for rot in sorted_rotations])

    print(f"あなたの名前: {your_name}")
    print(f"BWT後: {bwt}")
    print("\nパターンを見つけられますか？")

# 実行してみよう！
challenge()
```

---

次回：「FM-indexによる圧縮ゲノムの高速検索」へ続く
