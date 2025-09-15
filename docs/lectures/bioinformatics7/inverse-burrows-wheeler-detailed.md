# 反転Burrows-Wheeler変換：魔法の逆変換（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**圧縮されたBWT文字列から、元の文字列を完璧に復元する驚きの方法を理解する**

でも、ちょっと待ってください。前回BWTで文字列をぐちゃぐちゃに並び替えたのに、本当に元に戻せるのでしょうか？
実は、**たった2つの列**だけで元の文字列が完全に復元できる、魔法のような性質があるんです！

## 🤔 ステップ0：なぜ逆変換が重要なの？

### 0-1. そもそもの問題を考えてみよう

前回の講義でBWTを学びました。ゲノムを圧縮できる素晴らしい変換でした。

でも、圧縮したファイルをダウンロードした後、どうやって使うの？

```python
def illustrate_problem():
    """
    圧縮の問題を可視化
    """
    original_genome = "ATCGATCG" * 1000  # 8000文字

    # BWTで圧縮（仮想的に）
    compressed_size = 2000  # 圧縮後

    print(f"元のゲノム: {len(original_genome)}文字")
    print(f"圧縮後: {compressed_size}文字")
    print("\nでも...")
    print("使うときは元のゲノムが必要！")
    print("→ 解凍（逆変換）が必要")

illustrate_problem()
```

### 0-2. 驚きの事実

ランレングス圧縮なら逆変換は簡単です：

- "10G" → "GGGGGGGGGG"（Gを10回書く）

でもBWTの逆変換は？

- "annb$aa" → "banana$"

え？どうやって？順番がぐちゃぐちゃなのに！

## 📖 ステップ1：まず素朴に考えてみよう

### 1-1. 最初の直感：これ無理じゃない？

BWTの結果だけ見てみましょう：

```python
def show_bwt_result():
    """
    BWTの結果だけから何がわかる？
    """
    bwt = "annb$aa"

    print(f"BWT結果: {bwt}")
    print(f"文字の出現回数:")

    from collections import Counter
    counts = Counter(bwt)
    for char, count in sorted(counts.items()):
        print(f"  {char}: {count}回")

    print("\nこれだけじゃ元の文字列はわからない...")
    print("'banana$'? 'anbana$'? 'nabana$'?")

show_bwt_result()
```

### 1-2. でも待って、BWTには特別な構造がある

BWTは「すべての回転をソートした行列の最後の列」でした。
つまり、**構造的な情報**が隠されているはず！

## 📖 ステップ2：天才的な発見 - 最初の列は無料で手に入る

### 2-1. 重要な観察

```python
def discover_first_column():
    """
    最初の列を発見する
    """
    bwt = "annb$aa"  # 最後の列

    print("BWTは「ソート済み行列」の最後の列")
    print(f"最後の列: {bwt}")

    print("\nちょっと待って...")
    print("行列の各行は元の文字列の回転")
    print("→ すべての行に同じ文字が含まれる")
    print("→ 最初の列も同じ文字を含む")

    print("\nしかも行列はソート済み！")
    print("→ 最初の列は辞書順！")

    first_column = ''.join(sorted(bwt))
    print(f"\n最初の列: {first_column}")
    print("（最後の列をソートしただけ！）")

    return first_column

first_col = discover_first_column()
```

### 2-2. 2つの列を並べてみる

```python
def visualize_two_columns():
    """
    最初と最後の列を可視化
    """
    last = "annb$aa"
    first = ''.join(sorted(last))

    print("BWTマトリックスの最初と最後の列：")
    print("位置 | 最初 | ... | 最後")
    print("-" * 25)

    for i in range(len(first)):
        print(f" {i}   |  {first[i]}   | ... |  {last[i]}")

    print("\nこの2列だけで元の文字列が復元できる！？")

visualize_two_columns()
```

## 📖 ステップ3：段階的な行列の再構築（素朴な方法）

### 3-1. 2文字の組み合わせを作る

```python
def naive_reconstruction_step1():
    """
    素朴な復元方法：ステップ1
    """
    last = "annb$aa"
    first = ''.join(sorted(last))

    print("各行で、最後の文字の次は最初の文字")
    print("（循環しているから）")
    print("\n2文字の組み合わせ：")

    two_mers = []
    for i in range(len(first)):
        two_mer = last[i] + first[i]
        two_mers.append(two_mer)
        print(f"  行{i}: {last[i]} → {first[i]} = '{two_mer}'")

    return two_mers

two_mers = naive_reconstruction_step1()
```

### 3-2. 2文字をソートして最初の2列を得る

```python
def naive_reconstruction_step2(two_mers):
    """
    素朴な復元方法：ステップ2
    """
    print("これらの2文字をソート：")
    sorted_two_mers = sorted(two_mers)

    for i, tm in enumerate(sorted_two_mers):
        print(f"  {i}: {tm}")

    print("\nこれがBWT行列の最初の2列！")
    print("（なぜなら行列はソート済みだから）")

    return sorted_two_mers

sorted_2mers = naive_reconstruction_step2(two_mers)
```

### 3-3. このプロセスを繰り返す

```python
def full_naive_reconstruction():
    """
    完全な素朴復元
    """
    bwt = "annb$aa"
    n = len(bwt)

    # 初期化：最後の列から始める
    current_strings = list(bwt)

    print("段階的に列を増やしていく：\n")

    for step in range(n):
        # 最後の列 + ソート済み = 新しい文字列
        first_col = sorted(current_strings)

        # 新しい文字列を作る
        new_strings = []
        for i in range(n):
            # 最後の文字 + 最初の文字列
            new_strings.append(bwt[i] + first_col[i])

        current_strings = sorted(new_strings)

        print(f"ステップ{step + 1}: {len(current_strings[0])}文字")
        for s in current_strings[:3]:  # 最初の3つだけ表示
            print(f"  {s}")
        if len(current_strings) > 3:
            print(f"  ... (他{len(current_strings) - 3}個)")
        print()

    # 元の文字列を見つける
    for s in current_strings:
        if s.endswith('$'):
            original = s[s.index('$')+1:] + s[:s.index('$')+1]
            print(f"元の文字列発見: {original}")
            return original

result = full_naive_reconstruction()
```

## 📖 ステップ4：でも待って、これじゃメモリが不足する

### 4-1. 問題点の分析

```python
def analyze_naive_problem():
    """
    素朴な方法の問題点
    """
    genome_size = 3_000_000_000  # 30億文字

    # 素朴な方法のメモリ使用量
    matrix_size = genome_size * genome_size
    gb_needed = matrix_size / (1024**3)

    print(f"ゲノムサイズ: {genome_size:,}文字")
    print(f"必要な行列サイズ: {genome_size:,} × {genome_size:,}")
    print(f"必要メモリ: {gb_needed:,.0f} GB")
    print("\n絶対無理！別の方法が必要...")

analyze_naive_problem()
```

## 📖 ステップ5：天才的な発見 - First-Lastプロパティ

### 5-1. 不思議な対応関係

```python
def discover_first_last_property():
    """
    First-Lastプロパティの発見
    """
    # banana$の例で説明
    text = "banana$"

    # BWT行列を作る（説明用）
    rotations = []
    for i in range(len(text)):
        rotations.append(text[i:] + text[:i])

    sorted_rotations = sorted(rotations)

    # 最初と最後の列を取得
    first_col = ''.join([rot[0] for rot in sorted_rotations])
    last_col = ''.join([rot[-1] for rot in sorted_rotations])

    print("BWTマトリックス（banana$）:")
    print("番号 | 全体の回転      | 最初 | 最後")
    print("-" * 40)

    for i, rot in enumerate(sorted_rotations):
        print(f" {i}   | {rot:15s} |  {rot[0]}   |  {rot[-1]}")

    print("\n重要な観察：")
    print("'a'の出現を見てみよう...")

    # 'a'の位置を追跡
    a_positions_first = []
    a_positions_last = []

    for i in range(len(first_col)):
        if first_col[i] == 'a':
            a_positions_first.append(i)
        if last_col[i] == 'a':
            a_positions_last.append(i)

    print(f"\n最初の列の'a': 位置 {a_positions_first}")
    print(f"最後の列の'a': 位置 {a_positions_last}")

    print("\n驚きの事実：")
    print("最初の列の1番目の'a'と最後の列の1番目の'a'は")
    print("元の文字列の同じ'a'を指している！")

discover_first_last_property()
```

### 5-2. なぜこれが成り立つのか？

```python
def explain_first_last_property():
    """
    First-Lastプロパティの理由
    """
    print("なぜFirst-Lastプロパティが成り立つ？\n")

    print("1. 'a'で始まる行だけを見る：")
    print("   a$banan")
    print("   a$ban")
    print("   ana$b")
    print("   anana")
    print("   （これらもソート済み）")

    print("\n2. 最初の'a'を取り除いても順序は変わらない：")
    print("   $banan")
    print("   na$ban")
    print("   na$b")
    print("   nana")

    print("\n3. これらを1文字回転（最後に'a'を追加）：")
    print("   na$bana")
    print("   n$banana")
    print("   a$bana")
    print("   anana$b")

    print("\n4. 結果：")
    print("   順序が保たれる！")
    print("   → k番目の'a'は常にk番目の'a'に対応")

explain_first_last_property()
```

## 📖 ステップ6：効率的な逆変換アルゴリズム

### 6-1. LF-mapping（Last-to-First マッピング）

```python
def build_lf_mapping():
    """
    LFマッピングを構築
    """
    bwt = "annb$aa"
    first = ''.join(sorted(bwt))

    print("LF-mappingの構築：")
    print("（最後の列の各位置が最初の列のどこに対応するか）")

    # 各文字の出現回数をカウント
    char_count_last = {}
    char_count_first = {}
    lf_map = {}

    for i in range(len(bwt)):
        # 最後の列
        char = bwt[i]
        if char not in char_count_last:
            char_count_last[char] = 0
        occurrence = char_count_last[char]
        char_count_last[char] += 1

        # 最初の列で同じ文字の同じ出現番号を探す
        count = 0
        for j in range(len(first)):
            if first[j] == char:
                if count == occurrence:
                    lf_map[i] = j
                    print(f"  L[{i}]='{char}' → F[{j}]='{char}' (#{occurrence+1})")
                    break
                count += 1

    return lf_map, first

lf_map, first_col = build_lf_mapping()
```

### 6-2. 文字列を逆向きに辿る

```python
def efficient_inverse_bwt():
    """
    効率的な逆BWT
    """
    bwt = "annb$aa"
    n = len(bwt)

    # First列を計算
    first = ''.join(sorted(bwt))

    # LF-mappingを構築
    print("ステップ1: LF-mappingを構築")

    # 各文字の累積カウント
    char_counts = {}
    for char in set(bwt):
        char_counts[char] = 0

    lf = []
    for i, char in enumerate(bwt):
        # この文字が何番目の出現か
        occurrence = char_counts[char]
        char_counts[char] += 1

        # First列で同じ文字の同じ出現番号を探す
        count = 0
        for j, fc in enumerate(first):
            if fc == char:
                if count == occurrence:
                    lf.append(j)
                    break
                count += 1

    print(f"LF-mapping: {lf}\n")

    # 逆向きに辿る
    print("ステップ2: $から逆向きに辿る")

    # $の位置を見つける（First列の最初）
    pos = 0  # $は常に最初
    result = []

    for step in range(n):
        char = bwt[pos]
        result.append(char)
        print(f"  位置{pos}: '{char}'を追加")

        if char == '$':
            break

        pos = lf[pos]

    # 逆順にして$を除く
    original = ''.join(reversed(result[:-1])) + '$'
    print(f"\n復元された文字列: {original}")

    return original

restored = efficient_inverse_bwt()
```

### 6-3. より詳細な実装

```python
def detailed_inverse_bwt_with_trace():
    """
    詳細なトレース付き逆BWT
    """
    bwt = "annb$aa"

    print("=== 詳細な逆BWTアルゴリズム ===\n")

    # 1. First列を作成
    first = sorted(bwt)
    print(f"Last列（BWT）: {bwt}")
    print(f"First列:       {''.join(first)}\n")

    # 2. 各文字の開始位置を記録
    first_occurrence = {}
    for i, char in enumerate(first):
        if char not in first_occurrence:
            first_occurrence[char] = i

    print("各文字のFirst列での最初の位置:")
    for char, pos in sorted(first_occurrence.items()):
        print(f"  '{char}': {pos}")

    # 3. Last列の各文字をランク付け
    ranks = []
    char_count = {}

    for char in bwt:
        if char not in char_count:
            char_count[char] = 0
        ranks.append(char_count[char])
        char_count[char] += 1

    print(f"\nLast列の各文字のランク: {ranks}")

    # 4. LF-mappingを構築
    lf = []
    for i, char in enumerate(bwt):
        lf.append(first_occurrence[char] + ranks[i])

    print(f"LF-mapping: {lf}\n")

    # 5. 復元
    print("復元プロセス:")
    pos = first.index('$')
    path = [pos]
    result = []

    for _ in range(len(bwt) - 1):
        pos = lf[pos]
        path.append(pos)
        result.append(bwt[pos])
        print(f"  → 位置{pos}: '{bwt[pos]}'")

    original = ''.join(reversed(result)) + '$'
    print(f"\n最終結果: {original}")

    return original, path

result, path = detailed_inverse_bwt_with_trace()
```

## 📖 ステップ7：実際のゲノムでの性能

### 7-1. メモリ効率の比較

```python
def compare_memory_usage():
    """
    各手法のメモリ使用量比較
    """
    genome_size = 3_000_000_000  # 30億文字

    methods = {
        "素朴な方法（行列全体）": genome_size * genome_size,
        "改良版（2列のみ）": genome_size * 2,
        "LF-mapping版": genome_size * 1.5,  # BWT + インデックス
        "実用的な実装": genome_size * 0.5,  # 最適化済み
    }

    print("30億文字のゲノムでのメモリ使用量：")
    print("-" * 50)

    for method, bytes_needed in methods.items():
        gb = bytes_needed / (1024**3)
        if gb > 1000:
            print(f"{method:25s}: {gb/1000:6.1f} TB")
        else:
            print(f"{method:25s}: {gb:6.1f} GB")

    print("\n結論：")
    print("LF-mappingを使えば実用的なメモリ量で逆変換可能！")

compare_memory_usage()
```

### 7-2. 計算時間の分析

```python
def analyze_time_complexity():
    """
    時間計算量の分析
    """
    import time

    def measure_inverse_bwt(size):
        """指定サイズでの逆BWTの時間を測定（シミュレーション）"""
        # 実際の実装の代わりにシミュレーション
        operations = size * 2  # LF-mapping + 復元
        return operations / 1_000_000  # ミリ秒に変換（仮想）

    sizes = [100, 1000, 10000, 100000]

    print("逆BWTの実行時間（シミュレーション）：")
    print("サイズ  | 時間")
    print("-" * 25)

    for size in sizes:
        time_ms = measure_inverse_bwt(size)
        print(f"{size:6d} | {time_ms:8.2f} ms")

    print("\n時間計算量: O(n)")
    print("（nは文字列の長さ）")

analyze_time_complexity()
```

## 📖 ステップ8：なぜこれが革命的なのか

### 8-1. BWTの全体像

```python
def show_bwt_ecosystem():
    """
    BWTエコシステムの全体像
    """
    print("BWTが可能にすること：\n")

    features = [
        ("圧縮", "繰り返しパターンをランに変換"),
        ("逆変換", "完全に元の文字列を復元"),
        ("検索", "圧縮したまま高速パターン検索（次回）"),
        ("省メモリ", "サフィックスツリーの1/20以下"),
    ]

    for feature, description in features:
        print(f"✓ {feature:8s}: {description}")

    print("\n実際の応用：")
    applications = [
        "BWA (Burrows-Wheeler Aligner)",
        "Bowtie/Bowtie2",
        "SOAP2",
        "bzip2圧縮",
    ]

    for app in applications:
        print(f"  • {app}")

show_bwt_ecosystem()
```

### 8-2. パターンマッチングへの道

```python
def preview_pattern_matching():
    """
    次回予告：パターンマッチング
    """
    print("でも、ちょっと待って...")
    print("圧縮と解凍はわかった。")
    print("\nでも本当にすごいのはこれから：")
    print("「圧縮したままパターン検索ができる」")
    print("\n考えてみてください：")
    print("1. ゲノムをBWTで変換（圧縮可能）")
    print("2. 解凍せずにパターンを検索")
    print("3. しかもO(|パターン|)の時間で！")
    print("\nこれがFM-indexの魔法...")
    print("次回、その秘密を解き明かします！")

preview_pattern_matching()
```

## 📝 まとめ：3段階の理解レベル

### レベル1：表面的理解（これだけでもOK）

- **逆BWTは可能**：BWTから元の文字列を完全復元できる
- 手順：最後の列 → 最初の列（ソート）→ LF-mapping → 復元
- メモリ効率的：行列全体を作らなくてもOK

### レベル2：本質的理解（ここまで来たら素晴らしい）

- **First-Lastプロパティが鍵**
  - k番目の文字は常にk番目に対応
  - これによりLF-mappingが可能に
- **時間計算量O(n)**で復元可能
- **メモリ使用量もO(n)**

### レベル3：応用的理解（プロレベル）

- **BWTは可逆変換の傑作**
  - 情報理論的に無損失
  - 局所性を高めつつ復元可能性を保持
- **実用システムの基盤**
  - bzip2の核心技術
  - ゲノムアライナーの前処理
- **FM-indexへの布石**
  - LF-mappingは検索にも使える

## 🧪 実験課題（やってみよう）

```python
def challenge_inverse_bwt():
    """
    チャレンジ：自分でBWTを逆変換してみよう
    """
    # 問題
    bwt_examples = [
        "ard$rcaaaabb",  # "abracadabra$"
        "ipssm$pissii",  # "mississippi$"
        "e$neeec__ssr", # ヒント：「__」はスペース
    ]

    print("以下のBWTを逆変換してみよう：")
    for i, bwt in enumerate(bwt_examples, 1):
        print(f"{i}. BWT = '{bwt}'")
        print("   元の文字列は？")

    print("\nヒント：")
    print("1. First列を作る（ソート）")
    print("2. LF-mappingを構築")
    print("3. $から逆向きに辿る")

challenge_inverse_bwt()
```

## 🔮 次回予告：FM-indexの衝撃

次回はついに、BWTの真の力が明らかになります：

圧縮したまま高速パターン検索

- なぜ解凍不要で検索できるのか？
- どうやってO(|パターン|)を実現するのか？
- 実際のゲノムアライナーでの応用

これらの謎を、一緒に解き明かしていきましょう！

---

次回：「FM-index：圧縮ゲノムでの超高速パターン検索」へ続く
