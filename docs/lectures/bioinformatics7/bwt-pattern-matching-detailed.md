# BWTでパターンマッチング：圧縮したまま高速検索（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**圧縮されたBWT文字列から、解凍せずに直接パターンを検索する驚異的な方法を理解する**

でも、ちょっと待ってください。圧縮データを解凍せずに検索なんて、そんなことが本当に可能なのでしょうか？
実は、BWTの特殊な性質を利用すると、**たった2つの列**だけで高速パターン検索ができるんです！

## 🤔 ステップ0：なぜBWTでパターン検索なの？

### 0-1. そもそもの問題を考えてみよう

サフィックスツリーでパターン検索はできました。でも...

```python
def show_memory_problem():
    """
    メモリ問題を可視化
    """
    genome_size = 3_000_000_000  # 30億文字（ヒトゲノム）

    data_structures = {
        "元のゲノム": genome_size,
        "サフィックスツリー": genome_size * 20,
        "サフィックス配列": genome_size * 4,
        "BWT": genome_size * 1,
    }

    print("30億文字のゲノムでパターン検索するには？")
    print("-" * 50)

    for name, bytes_needed in data_structures.items():
        gb = bytes_needed / (1024**3)
        print(f"{name:20s}: {gb:6.1f} GB")

    print("\nサフィックスツリーは速いけど、メモリが...")
    print("BWTなら元のゲノムと同じサイズ！")

show_memory_problem()
```

### 0-2. 驚きの事実

BWTには隠された超能力があります：

- **圧縮可能**（ランが多い）
- **逆変換可能**（元に戻せる）
- そして今回学ぶ：**検索可能**（しかも高速！）

## 📖 ステップ1：まず素朴に考えてみよう

### 1-1. BWTマトリックスを思い出そう

```python
def recall_bwt_matrix():
    """
    BWTマトリックスの復習
    """
    text = "panamabananas$"
    n = len(text)

    # すべての回転を作る
    rotations = []
    for i in range(n):
        rotation = text[i:] + text[:i]
        rotations.append(rotation)

    # ソート
    sorted_rotations = sorted(rotations)

    print("BWTマトリックス（panamabananas$）:")
    print("番号 | 回転文字列")
    print("-" * 35)

    for i, rot in enumerate(sorted_rotations):
        # 'ana'を含む行をハイライト
        if 'ana' in rot and not rot.startswith('$'):
            print(f" {i:2d}  | {rot} ← 'ana'を含む！")
        else:
            print(f" {i:2d}  | {rot}")

    print("\n重要な観察：")
    print("パターン'ana'はマトリックスの複数の行に現れる")
    print("→ これらの行を見つければパターンの位置がわかる！")

recall_bwt_matrix()
```

### 1-2. でも待って、マトリックス全体は保存できない

```python
def matrix_storage_problem():
    """
    マトリックス保存の問題
    """
    text_length = 14  # panamabananas$

    print(f"文字列長: {text_length}")
    print(f"マトリックスサイズ: {text_length} × {text_length} = {text_length * text_length}文字")

    print("\nヒトゲノム（30億文字）の場合：")
    genome_size = 3_000_000_000
    matrix_size = genome_size * genome_size

    print(f"マトリックスサイズ: {genome_size:,} × {genome_size:,}")
    print(f"= {matrix_size:,}文字")
    print(f"= 約{matrix_size / (10**18):.0f}エクサバイト")
    print("\n絶対無理！")

matrix_storage_problem()
```

## 📖 ステップ2：天才的な発想 - 2列だけで検索

### 2-1. 必要なのは最初と最後の列だけ

```python
def two_columns_only():
    """
    2列だけで十分なことを示す
    """
    text = "panamabananas$"
    n = len(text)

    # BWTを計算
    rotations = []
    for i in range(n):
        rotations.append(text[i:] + text[:i])
    sorted_rotations = sorted(rotations)

    # 最初と最後の列
    first_col = ''.join([rot[0] for rot in sorted_rotations])
    last_col = ''.join([rot[-1] for rot in sorted_rotations])  # BWT

    print("必要なのはこの2列だけ！")
    print("\n位置 | First | ... | Last(BWT)")
    print("-" * 30)

    for i in range(n):
        print(f" {i:2d}  |   {first_col[i]}   | ... |    {last_col[i]}")

    print(f"\nメモリ使用量: {n * 2}文字")
    print(f"（マトリックス全体なら{n * n}文字必要）")

    return first_col, last_col

first, last = two_columns_only()
```

### 2-2. なぜ2列で検索できるの？

```python
def explain_why_two_columns():
    """
    2列で検索できる理由
    """
    print("重要な性質：")
    print("1. First列 = ソート済みの文字")
    print("   → 文字cで始まる行の範囲がわかる")
    print("\n2. Last列の文字 = その行の最後の文字")
    print("   → 次に来る文字がFirst列のどこにあるかわかる")
    print("\n3. First-Lastプロパティ")
    print("   → k番目の文字は常にk番目に対応")
    print("\nこれらを組み合わせると...")
    print("パターンを逆向きに検索できる！")

explain_why_two_columns()
```

## 📖 ステップ3：逆向き検索の魔法

### 3-1. なぜ逆向きに検索するの？

```python
def why_backward_search():
    """
    逆向き検索の理由
    """
    print("パターン'ana'を検索する場合：\n")

    print("前向き検索（通常の方法）:")
    print("  'a' → 'n' → 'a'")
    print("  問題：'a'で始まる行が多すぎる！")
    print("  → 候補が絞れない\n")

    print("逆向き検索（BWTの方法）:")
    print("  'a' ← 'n' ← 'a'")
    print("  利点：最後の文字から始める")
    print("  → First-Lastプロパティで効率的に絞れる！")

why_backward_search()
```

### 3-2. 実際にやってみよう：'ana'を検索

```python
def search_ana_step_by_step():
    """
    'ana'の検索を段階的に実行
    """
    text = "panamabananas$"
    pattern = "ana"

    # BWT構築
    rotations = []
    for i in range(len(text)):
        rotations.append(text[i:] + text[:i])
    sorted_rotations = sorted(rotations)

    first = ''.join([rot[0] for rot in sorted_rotations])
    last = ''.join([rot[-1] for rot in sorted_rotations])

    print(f"テキスト: {text}")
    print(f"パターン: {pattern}")
    print(f"First列: {first}")
    print(f"Last列:  {last}\n")

    print("=== ステップ1: 最後の文字'a'から開始 ===")

    # 'a'で始まる範囲を見つける
    a_start = first.index('a')
    a_end = len(first) - first[::-1].index('a')

    print(f"First列で'a'が現れる範囲: [{a_start}, {a_end})")
    print("該当する行:")
    for i in range(a_start, a_end):
        print(f"  行{i}: {sorted_rotations[i]}")

    print("\n=== ステップ2: 前の文字'n'を確認 ===")

    # Last列で'n'を持つ行を絞る
    n_rows = []
    for i in range(a_start, a_end):
        if last[i] == 'n':
            n_rows.append(i)
            print(f"  行{i}: Last='{last[i]}' → OK!")
        else:
            print(f"  行{i}: Last='{last[i]}' → NG")

    print(f"\n残った行: {n_rows}")

    print("\n=== ステップ3: First-Lastプロパティ適用 ===")

    # 'n'の位置を特定
    n_positions = []
    n_count = {}

    for i in range(len(last)):
        char = last[i]
        if char not in n_count:
            n_count[char] = 0

        if i in n_rows:
            # この'n'が何番目の'n'か
            n_positions.append((i, n_count['n']))
            print(f"  行{i}の'n'は{n_count['n']+1}番目の'n'")

        if char == 'n':
            n_count[char] += 1

    print("\n=== ステップ4: 新しい範囲を特定 ===")

    # First列で対応する'n'の位置を見つける
    n_start_first = first.index('n')

    new_range = []
    for old_pos, n_idx in n_positions:
        new_pos = n_start_first + n_idx
        new_range.append(new_pos)
        print(f"  {n_idx+1}番目の'n' → 行{new_pos}")

    print("\n=== ステップ5: さらに前の文字'a'を確認 ===")

    final_matches = []
    for i in new_range:
        if last[i] == 'a':
            final_matches.append(i)
            print(f"  行{i}: Last='{last[i]}' → マッチ！")
            print(f"        {sorted_rotations[i]}")

    print(f"\n最終結果: {len(final_matches)}箇所で'ana'を発見！")

    return final_matches

matches = search_ana_step_by_step()
```

## 📖 ステップ4：アルゴリズムの一般化

### 4-1. BWTパターン検索アルゴリズム

```python
def bwt_pattern_search(text, pattern):
    """
    BWTを使ったパターン検索（完全版）
    """
    # BWTを構築
    text = text + '$' if not text.endswith('$') else text
    n = len(text)

    rotations = []
    for i in range(n):
        rotations.append((text[i:] + text[:i], i))

    sorted_rotations = sorted(rotations, key=lambda x: x[0])

    # First列とLast列を取得
    first = ''.join([rot[0][0] for rot in sorted_rotations])
    last = ''.join([rot[0][-1] for rot in sorted_rotations])

    # 各文字の開始位置を記録
    char_starts = {}
    for i, char in enumerate(first):
        if char not in char_starts:
            char_starts[char] = i

    # Last列の各文字のランクを計算
    last_ranks = []
    char_counts = {}

    for char in last:
        if char not in char_counts:
            char_counts[char] = 0
        last_ranks.append(char_counts[char])
        char_counts[char] += 1

    # LF-mappingを構築
    def lf_mapping(i):
        """Last列のi番目がFirst列のどこに対応するか"""
        char = last[i]
        rank = last_ranks[i]
        return char_starts[char] + rank

    # パターンを逆向きに検索
    print(f"\nパターン'{pattern}'を検索:")

    # 最後の文字から開始
    if pattern[-1] not in char_starts:
        print(f"  文字'{pattern[-1]}'が見つかりません")
        return []

    # 初期範囲
    char = pattern[-1]
    start = char_starts[char]
    end = char_starts.get(chr(ord(char) + 1), n) if char != '$' else n

    print(f"  ステップ1: '{char}'の範囲 = [{start}, {end})")

    # 残りの文字を逆順に処理
    for i in range(len(pattern) - 2, -1, -1):
        char = pattern[i]
        print(f"  ステップ{len(pattern)-i}: '{char}'でフィルタ")

        new_start = n
        new_end = 0

        for j in range(start, end):
            if last[j] == char:
                pos = lf_mapping(j)
                new_start = min(new_start, pos)
                new_end = max(new_end, pos + 1)

        if new_start >= new_end:
            print(f"    → マッチなし")
            return []

        start, end = new_start, new_end
        print(f"    → 新しい範囲 = [{start}, {end})")

    # マッチした位置を返す
    matches = []
    for i in range(start, end):
        original_pos = sorted_rotations[i][1]
        matches.append(original_pos)
        print(f"\n  マッチ位置: {original_pos}")
        print(f"    {text[original_pos:original_pos+len(pattern)]}")

    return matches

# テスト
text = "panamabananas"
patterns = ["ana", "ban", "pan", "nas"]

for pattern in patterns:
    print("=" * 50)
    matches = bwt_pattern_search(text, pattern)
    print(f"\n'{pattern}'は{len(matches)}箇所で発見")
```

## 📖 ステップ5：計算量の分析

### 5-1. 時間計算量

```python
def analyze_time_complexity():
    """
    時間計算量の分析
    """
    print("BWTパターン検索の時間計算量：\n")

    print("1. 前処理（BWT構築）:")
    print("   O(n log n) - ソートが必要")
    print("   ※ 一度だけ実行\n")

    print("2. パターン検索:")
    print("   O(m) - mはパターン長")
    print("   ※ 各文字について範囲を更新\n")

    print("比較：")
    methods = [
        ("単純な方法", "O(n × m)"),
        ("サフィックスツリー", "O(m)"),
        ("BWTパターン検索", "O(m)"),
    ]

    for method, complexity in methods:
        print(f"  {method:20s}: {complexity}")

    print("\nBWTはサフィックスツリーと同じ速度！")

analyze_time_complexity()
```

### 5-2. 空間計算量

```python
def analyze_space_complexity():
    """
    空間計算量の分析
    """
    genome_size = 3_000_000_000  # 30億文字

    print("メモリ使用量の比較（30億文字のゲノム）：\n")

    structures = [
        ("サフィックスツリー", genome_size * 20, "検索は速いがメモリ大"),
        ("サフィックス配列", genome_size * 4, "整数配列が必要"),
        ("BWT（非圧縮）", genome_size * 2, "First + Last列"),
        ("BWT（圧縮）", genome_size * 0.5, "ランレングス圧縮適用"),
        ("FM-index", genome_size * 0.3, "さらに最適化（次回）"),
    ]

    for name, bytes_needed, note in structures:
        gb = bytes_needed / (1024**3)
        print(f"{name:20s}: {gb:6.1f} GB  ({note})")

    print("\nBWTの利点：")
    print("✓ メモリ効率が良い")
    print("✓ 圧縮可能")
    print("✓ 検索速度も速い")

analyze_space_complexity()
```

## 📖 ステップ6：実装の最適化

### 6-1. カウント配列による高速化

```python
def optimized_bwt_search():
    """
    最適化されたBWT検索
    """
    text = "panamabananas$"

    # BWT構築（省略）
    rotations = []
    for i in range(len(text)):
        rotations.append(text[i:] + text[:i])
    sorted_rotations = sorted(rotations)

    first = ''.join([rot[0] for rot in sorted_rotations])
    last = ''.join([rot[-1] for rot in sorted_rotations])

    # カウント配列を事前計算
    print("最適化テクニック：\n")

    print("1. Occ配列（出現回数の累積）:")

    # Occ[c][i] = last[0:i]に文字cが何回出現するか
    alphabet = sorted(set(text))
    occ = {c: [0] for c in alphabet}

    for i, char in enumerate(last):
        for c in alphabet:
            if c == char:
                occ[c].append(occ[c][-1] + 1)
            else:
                occ[c].append(occ[c][-1])

    # 表示
    print("位置:", end="")
    for i in range(len(text) + 1):
        print(f" {i:2d}", end="")
    print()

    for c in alphabet[:3]:  # 最初の3文字だけ表示
        print(f"'{c}': ", end="")
        for count in occ[c]:
            print(f" {count:2d}", end="")
        print()

    print("\n2. C配列（各文字より小さい文字の総数）:")

    C = {}
    for c in alphabet:
        C[c] = sum(1 for ch in first if ch < c)

    for c in alphabet:
        print(f"  C['{c}'] = {C[c]}")

    print("\n3. 高速LF-mapping:")
    print("  LF(i) = C[last[i]] + Occ[last[i]][i]")
    print("  → O(1)で計算可能！")

    return occ, C

occ, C = optimized_bwt_search()
```

### 6-2. 実用的な実装

```python
class BWTSearcher:
    """
    実用的なBWT検索クラス
    """
    def __init__(self, text):
        """BWT構築と前処理"""
        if not text.endswith('$'):
            text = text + '$'

        self.text = text
        self.n = len(text)

        # BWT構築
        rotations = []
        for i in range(self.n):
            rotations.append((text[i:] + text[:i], i))

        sorted_rotations = sorted(rotations, key=lambda x: x[0])
        self.sa = [r[1] for r in sorted_rotations]  # サフィックス配列

        self.first = ''.join([r[0][0] for r in sorted_rotations])
        self.last = ''.join([r[0][-1] for r in sorted_rotations])

        # 前処理
        self._precompute()

    def _precompute(self):
        """Occ配列とC配列を事前計算"""
        alphabet = sorted(set(self.text))

        # Occ配列
        self.occ = {c: [0] for c in alphabet}
        for char in self.last:
            for c in alphabet:
                if c == char:
                    self.occ[c].append(self.occ[c][-1] + 1)
                else:
                    self.occ[c].append(self.occ[c][-1])

        # C配列
        self.C = {}
        for c in alphabet:
            self.C[c] = sum(1 for ch in self.first if ch < c)

    def search(self, pattern):
        """パターンを検索"""
        if not pattern:
            return []

        # 最後の文字から開始
        char = pattern[-1]
        if char not in self.C:
            return []

        start = self.C[char]
        end = self.C.get(chr(ord(char) + 1), self.n) if char != '~' else self.n

        # 残りの文字を逆順に処理
        for i in range(len(pattern) - 2, -1, -1):
            char = pattern[i]
            if char not in self.C:
                return []

            start = self.C[char] + self.occ[char][start]
            end = self.C[char] + self.occ[char][end]

            if start >= end:
                return []

        # マッチ位置を返す
        return [self.sa[i] for i in range(start, end)]

# 使用例
searcher = BWTSearcher("panamabananas")

patterns = ["ana", "ban", "pan", "nas", "xyz"]
for pattern in patterns:
    positions = searcher.search(pattern)
    if positions:
        print(f"'{pattern}': {positions}")
    else:
        print(f"'{pattern}': not found")
```

## 📖 ステップ7：実際のゲノムでの応用

### 7-1. ゲノム検索のシミュレーション

```python
def genome_search_simulation():
    """
    ゲノム検索のシミュレーション
    """
    import random

    # 小さなゲノムをシミュレート
    def generate_genome(size=1000):
        bases = ['A', 'T', 'C', 'G']
        return ''.join(random.choices(bases, k=size))

    genome = generate_genome(1000)

    # 特定のパターンを挿入
    pattern = "ATCGATCG"
    positions = [100, 500, 800]

    genome_list = list(genome)
    for pos in positions:
        for i, base in enumerate(pattern):
            genome_list[pos + i] = base

    genome = ''.join(genome_list)

    print("ゲノム検索シミュレーション：")
    print(f"ゲノムサイズ: {len(genome)}塩基")
    print(f"検索パターン: {pattern}")
    print(f"埋め込んだ位置: {positions}")

    # BWT検索
    searcher = BWTSearcher(genome)
    found = searcher.search(pattern)

    print(f"\n検索結果: {found}")
    print(f"正解率: {set(found) == set(positions)}")

    # 検証
    print("\n検証:")
    for pos in found:
        extracted = genome[pos:pos+len(pattern)]
        print(f"  位置{pos}: {extracted}")

genome_search_simulation()
```

## 📖 ステップ8：BWTからFM-indexへ

### 8-1. さらなる改良の余地

```python
def towards_fm_index():
    """
    FM-indexへの道
    """
    print("BWTパターン検索の課題と改良：\n")

    print("現在の実装：")
    print("✓ First列とLast列を保存")
    print("✓ Occ配列で高速化")
    print("✓ O(m)時間で検索\n")

    print("さらなる改良（FM-index）：")
    print("• First列を保存しない（計算で求める）")
    print("• Occ配列を圧縮（サンプリング）")
    print("• チェックポイント方式")
    print("• ウェーブレット木\n")

    print("結果：")
    print("メモリ使用量: 元のテキストの30%以下")
    print("検索速度: ほぼ同じO(m)")
    print("→ 実用的なゲノムアライナーの基礎！")

towards_fm_index()
```

## 📝 まとめ：3段階の理解レベル

### レベル1：表面的理解（これだけでもOK）

- **BWTで圧縮したまま検索可能**
- 手順：パターンを逆向きに検索
- 必要なのは2列（FirstとLast）だけ
- 時間計算量O(m)で高速

### レベル2：本質的理解（ここまで来たら素晴らしい）

- **逆向き検索が鍵**
  - 最後の文字から始めて範囲を絞る
  - First-Lastプロパティで次の位置を特定
- **LF-mappingが核心技術**
  - Last列の位置からFirst列の位置を計算
  - Occ配列とC配列で高速化
- **メモリと速度の両立**

### レベル3：応用的理解（プロレベル）

- **BWTは圧縮と検索の統合**
  - データ構造の圧縮表現
  - 圧縮したまま操作可能
- **実用システムの基盤**
  - BWA、Bowtie2などのアライナー
  - 次世代シーケンサーのデータ解析
- **FM-indexへの発展**
  - さらなるメモリ削減
  - 実用的な大規模ゲノム検索

## 🧪 実験課題（やってみよう）

```python
def challenge_bwt_search():
    """
    チャレンジ：BWTパターン検索を試そう
    """
    # 問題
    text = "mississippi"
    patterns = ["iss", "ssi", "pp", "miss"]

    print("テキスト:", text)
    print("\n以下のパターンを検索してみよう：")

    for pattern in patterns:
        print(f"  '{pattern}': 位置は？")

    print("\nヒント：")
    print("1. BWTを構築")
    print("2. 各パターンを逆向きに検索")
    print("3. First-Lastプロパティを活用")

    # 解答例（コメントアウト）
    # searcher = BWTSearcher(text)
    # for pattern in patterns:
    #     positions = searcher.search(pattern)
    #     print(f"'{pattern}': {positions}")

challenge_bwt_search()
```

## 🔮 次回予告：FM-indexの完成形

次回は、BWTパターン検索をさらに洗練させた**FM-index**を学びます：

- どうやってメモリをさらに削減するのか？
- サンプリングとは何か？
- 実際のゲノムアライナーでの実装

現代のゲノム解析の心臓部に迫ります！

---

次回：「FM-index：究極の圧縮検索データ構造」へ続く
