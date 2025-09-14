# トライから接尾辞ツリーへ：ゲノム検索の革命（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**ゲノム全体を効率的に表現する「接尾辞ツリー」を理解し、どんなパターンでも瞬時に検索できる魔法のようなデータ構造をマスターする**

でも、ちょっと待ってください。前回学んだトライは素晴らしい技術でした。なのに、なぜ新しいデータ構造が必要なんでしょう？

実は、トライには**致命的な弱点**があったんです。そして、その弱点を克服する過程で、**バイオインフォマティクス史上最も重要なデータ構造の一つ**が生まれました。

## 🤔 ステップ0：なぜトライでは不十分なの？

### 0-1. トライの隠れた問題を発見しよう

前回、1000個のパターンを同時に検索できるトライを学びました。素晴らしい成果でした！でも...

```python
# トライのメモリ使用量を計算してみよう
def calculate_trie_memory():
    # 例：制限酵素認識配列1000個を検索
    pattern_count = 1000
    average_pattern_length = 20  # 塩基

    # トライのメモリ使用量
    trie_memory = pattern_count * average_pattern_length
    print(f"トライのメモリ: 約{trie_memory:,}文字分")
    # 出力: トライのメモリ: 約20,000文字分

    # でも、ゲノムの長さは？
    human_genome_length = 3_000_000_000  # 30億塩基
    print(f"ヒトゲノム: {human_genome_length:,}塩基")

    # 問題：パターンが多いと...
    many_patterns = 100_000  # 10万個のモチーフ
    huge_memory = many_patterns * average_pattern_length
    print(f"10万パターンのトライ: {huge_memory:,}文字分")
    # これはゲノムサイズに匹敵！
```

### 0-2. 発想の大転換

ここで天才的な発想が生まれました：

```python
# 従来の発想：パターンをデータ構造化
traditional_approach = """
パターン群 → トライ構築 → ゲノムをスキャン
（バスにパターンを乗せて、ゲノムという道を走る）
"""

# 新しい発想：ゲノムをデータ構造化！
revolutionary_approach = """
ゲノム → データ構造化 → パターンが瞬間移動
（道そのものを折りたたんで、パターンを目的地へテレポート）
"""
```

## 📖 ステップ1：接尾辞（サフィックス）の基本

### 1-1. そもそも接尾辞って何？

```python
def show_all_suffixes(text):
    """
    文字列のすべての接尾辞を表示
    """
    text = text + "$"  # 終端記号を追加
    suffixes = []

    for i in range(len(text)):
        suffix = text[i:]
        suffixes.append((i, suffix))

    return suffixes

# 実験してみよう
genome = "BANANA"
suffixes = show_all_suffixes(genome)
for pos, suffix in suffixes:
    print(f"位置{pos}: {suffix}")

# 出力:
# 位置0: BANANA$
# 位置1: ANANA$
# 位置2: NANA$
# 位置3: ANA$
# 位置4: NA$
# 位置5: A$
# 位置6: $
```

### 1-2. なぜ接尾辞が重要なのか？

```python
# 魔法の性質：任意の部分文字列は、必ずどれかの接尾辞の接頭辞！
def find_pattern_in_suffixes(text, pattern):
    """
    パターンが接尾辞の接頭辞として存在するか確認
    """
    text = text + "$"

    for i in range(len(text)):
        suffix = text[i:]
        if suffix.startswith(pattern):
            print(f"パターン'{pattern}'を位置{i}で発見！")
            print(f"  接尾辞: {suffix}")
            print(f"  マッチ部分: {suffix[:len(pattern)]}")
            return i

    return -1

# デモンストレーション
find_pattern_in_suffixes("BANANA", "ANA")
# 出力: パターン'ANA'を位置1で発見！
```

## 📖 ステップ2：接尾辞トライの構築

### 2-1. すべての接尾辞からトライを作る

```python
class SuffixTrieNode:
    def __init__(self):
        self.children = {}
        self.suffix_index = None  # この葉が表す接尾辞の開始位置

def build_suffix_trie(text):
    """
    接尾辞トライの構築
    """
    text = text + "$"
    root = SuffixTrieNode()

    # すべての接尾辞を追加
    for i in range(len(text)):
        current = root

        # 接尾辞の各文字を処理
        for j in range(i, len(text)):
            char = text[j]

            if char not in current.children:
                current.children[char] = SuffixTrieNode()

            current = current.children[char]

        # 葉に接尾辞の開始位置を記録
        current.suffix_index = i

    return root

# 実験
text = "BANANA"
suffix_trie = build_suffix_trie(text)
print("接尾辞トライ構築完了！")
```

### 2-2. 接尾辞トライでのパターン検索

```python
def search_in_suffix_trie(suffix_trie, pattern):
    """
    接尾辞トライでパターンを検索
    """
    current = suffix_trie

    # パターンを辿る
    for char in pattern:
        if char not in current.children:
            return []  # パターンが存在しない
        current = current.children[char]

    # このノード以下のすべての葉を収集
    positions = []
    def collect_leaves(node):
        if node.suffix_index is not None:
            positions.append(node.suffix_index)
        for child in node.children.values():
            collect_leaves(child)

    collect_leaves(current)
    return positions

# テスト
positions = search_in_suffix_trie(suffix_trie, "ANA")
print(f"'ANA'の出現位置: {positions}")
```

## 📖 ステップ3：問題発覚！メモリの爆発

### 3-1. 接尾辞トライのメモリ使用量

```python
def calculate_suffix_trie_memory(genome_length):
    """
    接尾辞トライのメモリ使用量を計算
    """
    # 最悪の場合：すべての接尾辞の長さの合計
    total_chars = 0
    for i in range(genome_length):
        suffix_length = genome_length - i + 1  # +1 for $
        total_chars += suffix_length

    # これは n*(n+1)/2 = O(n²)
    theoretical = genome_length * (genome_length + 1) // 2

    print(f"ゲノム長: {genome_length:,}")
    print(f"接尾辞トライのメモリ: {total_chars:,}文字")
    print(f"理論値: {theoretical:,}文字")
    print(f"メモリ複雑度: O(n²)")

    return total_chars

# 恐ろしい現実
calculate_suffix_trie_memory(1000)  # 1000塩基
# 出力: 接尾辞トライのメモリ: 500,500文字

calculate_suffix_trie_memory(1_000_000)  # 100万塩基
# 出力: 接尾辞トライのメモリ: 500,000,500,000文字（！）
```

### 3-2. なぜこんなに大きくなるの？

```python
def visualize_suffix_trie_problem():
    """
    接尾辞トライの問題を視覚化
    """
    text = "AAAA$"

    print("テキスト: AAAA$")
    print("\n接尾辞:")
    print("  AAAA$ (5文字)")
    print("  AAA$  (4文字)")
    print("  AA$   (3文字)")
    print("  A$    (2文字)")
    print("  $     (1文字)")
    print(f"\n合計: {5+4+3+2+1} = 15文字")
    print(f"元のテキスト長: 5文字")
    print(f"倍率: 3倍！")

    # 一般化
    n = 5
    total = n * (n + 1) // 2
    print(f"\n一般式: n×(n+1)/2 = {n}×{n+1}/2 = {total}")

visualize_suffix_trie_problem()
```

## 📖 ステップ4：救世主「接尾辞ツリー」の登場

### 4-1. パス圧縮の天才的アイデア

```python
def compress_suffix_trie():
    """
    接尾辞トライを圧縮して接尾辞ツリーへ
    """
    example = """
    圧縮前（接尾辞トライ）:
    root → B → A → N → A → N → A → $
           ↓
           A → N → A → N → A → $

    圧縮後（接尾辞ツリー）:
    root → "BANANA$"
           ↓
           "ANANA$"

    分岐のないパスを1つのエッジに圧縮！
    """
    print(example)

compress_suffix_trie()
```

### 4-2. 接尾辞ツリーの実装

```python
class SuffixTreeNode:
    def __init__(self):
        self.children = {}
        self.edge_label = ""  # エッジのラベル（部分文字列）
        self.suffix_index = None

def compress_path(node, text):
    """
    分岐のないパスを圧縮
    """
    if len(node.children) == 1 and node.suffix_index is None:
        # 分岐がない場合、子ノードと結合
        child_char = list(node.children.keys())[0]
        child = node.children[child_char]

        # エッジラベルを結合
        node.edge_label += child_char + child.edge_label
        node.children = child.children
        node.suffix_index = child.suffix_index

        # 再帰的に圧縮を続ける
        compress_path(node, text)

# 実際には、エッジラベルの代わりに
# テキストへのポインタ（開始位置と終了位置）を使用
class EfficientSuffixTreeEdge:
    def __init__(self, text, start, end):
        self.text = text  # 元のテキストへの参照
        self.start = start  # 部分文字列の開始位置
        self.end = end  # 部分文字列の終了位置

    def get_label(self):
        return self.text[self.start:self.end]
```

## 📖 ステップ5：メモリ効率の劇的改善

### 5-1. 接尾辞ツリーのメモリ分析

```python
def analyze_suffix_tree_memory():
    """
    接尾辞ツリーのメモリ使用量を分析
    """
    print("=== 接尾辞ツリーのメモリ効率 ===\n")

    # 重要な事実
    facts = """
    1. 葉の数 = テキスト長（各接尾辞に1つの葉）
    2. 内部ノードの数 < テキスト長
    3. 総ノード数 < 2 × テキスト長
    4. 各エッジは開始・終了位置のみ保存
    """
    print(facts)

    # メモリ計算
    def calculate_memory(n):
        leaves = n
        internal_nodes = n - 1  # 最悪の場合
        total_nodes = leaves + internal_nodes

        # 各ノードは固定サイズ
        node_size = 3  # ポインタ2つ + インデックス
        total_memory = total_nodes * node_size

        return {
            'leaves': leaves,
            'internal': internal_nodes,
            'total_nodes': total_nodes,
            'memory': total_memory,
            'complexity': 'O(n)'
        }

    # 比較
    for size in [100, 1000, 1000000]:
        result = calculate_memory(size)
        print(f"\nゲノム長 {size:,}:")
        print(f"  接尾辞トライ: O(n²) = {size*size:,}")
        print(f"  接尾辞ツリー: O(n) = {result['memory']:,}")
        print(f"  削減率: {(size*size/result['memory']):.1f}倍")

analyze_suffix_tree_memory()
```

### 5-2. なぜO(n)で収まるのか？

```python
def why_linear_memory():
    """
    線形メモリの理由を説明
    """
    explanation = """
    === なぜ接尾辞ツリーはO(n)メモリなのか ===

    1. 葉の数 = n（接尾辞の数）
       - 各接尾辞は必ず1つの葉で終わる

    2. 内部ノードは分岐点のみ
       - 分岐 = 共通接頭辞の終わり
       - 分岐の数 ≤ n-1

    3. エッジは文字列をコピーしない
       - 開始位置と終了位置のみ保存
       - 例: "BANANA" → (0, 6) だけ

    4. 合計: 2n個未満のノード × 固定サイズ = O(n)
    """
    print(explanation)

    # 具体例で確認
    text = "MISSISSIPPI$"
    print(f"\nテキスト: {text}")
    print(f"長さ: {len(text)}")
    print(f"葉の数: {len(text)}")
    print(f"内部ノード数: 最大{len(text)-1}")
    print(f"総ノード数: 最大{2*len(text)-1}")

why_linear_memory()
```

## 📖 ステップ6：魔法のような構築アルゴリズム

### 6-1. ウッコネンのアルゴリズム

```python
def ukkonen_algorithm_intro():
    """
    ウッコネンのアルゴリズムの紹介
    """
    magic = """
    === ウッコネンのアルゴリズム（1995年）===

    驚きの性質：
    1. 時間計算量: O(n) - 線形時間！
    2. 空間計算量: O(n) - 線形メモリ！
    3. オンライン構築: 文字を1つずつ追加可能

    どうやって？
    - 「暗黙の接尾辞ツリー」という概念を使用
    - アクティブポイントを巧妙に管理
    - 接尾辞リンクで高速ジャンプ

    結果：接尾辞トライを経由せずに
          直接接尾辞ツリーを構築！
    """
    print(magic)

ukkonen_algorithm_intro()
```

### 6-2. 簡略化した構築例

```python
class SimpleSuffixTree:
    """
    簡略化した接尾辞ツリー（教育用）
    """
    def __init__(self, text):
        self.text = text + "$"
        self.root = self._build()

    def _build(self):
        # 実際のウッコネンのアルゴリズムは複雑
        # ここでは概念的な説明のみ
        root = SuffixTreeNode()

        for i in range(len(self.text)):
            # 各接尾辞を追加
            self._add_suffix(root, i)

        # パス圧縮
        self._compress(root)

        return root

    def _add_suffix(self, node, start):
        # 接尾辞を追加（簡略化）
        pass

    def _compress(self, node):
        # パスを圧縮（簡略化）
        pass

    def search(self, pattern):
        """
        パターン検索
        """
        current = self.root
        pattern_index = 0

        while pattern_index < len(pattern):
            found = False
            for edge_label, child in current.children.items():
                if pattern[pattern_index:].startswith(edge_label):
                    pattern_index += len(edge_label)
                    current = child
                    found = True
                    break

            if not found:
                return []  # パターンが見つからない

        # 現在のノード以下のすべての葉を収集
        return self._collect_positions(current)
```

## 📖 ステップ7：実世界での応用

### 7-1. ゲノムアセンブリでの活用

```python
def genome_assembly_with_suffix_tree():
    """
    接尾辞ツリーを使ったゲノムアセンブリ
    """
    class GenomeAssembler:
        def __init__(self, reads):
            # すべてのリードを連結
            self.combined = "$".join(reads)
            self.suffix_tree = SimpleSuffixTree(self.combined)

        def find_overlaps(self, min_overlap=10):
            """
            リード間のオーバーラップを高速検出
            """
            overlaps = []

            for read in reads:
                # リードの接尾辞を検索
                for k in range(min_overlap, len(read)):
                    suffix = read[-k:]
                    positions = self.suffix_tree.search(suffix)

                    for pos in positions:
                        # オーバーラップを記録
                        overlaps.append({
                            'read1': read,
                            'suffix': suffix,
                            'position': pos
                        })

            return overlaps

# デモンストレーション
reads = ["ATCGATCG", "TCGATCGA", "GATCGATC"]
assembler = GenomeAssembler(reads)
print("リード間のオーバーラップを検出中...")
```

### 7-2. 繰り返し配列の検出

```python
def find_repeats_with_suffix_tree(genome):
    """
    接尾辞ツリーで繰り返し配列を検出
    """
    tree = SimpleSuffixTree(genome)

    def find_internal_nodes_with_multiple_leaves(node, path=""):
        """
        複数の葉を持つ内部ノードを探す
        （= 繰り返し配列）
        """
        repeats = []

        if len(node.children) > 1:
            # このノードまでのパスが繰り返し
            leaf_count = count_leaves(node)
            if leaf_count > 1:
                repeats.append({
                    'sequence': path,
                    'count': leaf_count
                })

        for edge, child in node.children.items():
            child_repeats = find_internal_nodes_with_multiple_leaves(
                child, path + edge
            )
            repeats.extend(child_repeats)

        return repeats

    return find_internal_nodes_with_multiple_leaves(tree.root)

# テスト
test_genome = "ATGATGATGATG"
repeats = find_repeats_with_suffix_tree(test_genome)
print(f"繰り返し配列: {repeats}")
```

## 📖 ステップ8：接尾辞ツリー vs 他の手法

### 8-1. 性能比較

```python
def performance_comparison():
    """
    各手法の性能比較
    """
    import pandas as pd

    comparison = pd.DataFrame({
        '手法': ['単純検索', 'トライ', '接尾辞トライ', '接尾辞ツリー', 'BWT+FM'],
        '前処理時間': ['O(1)', 'O(Σ|Pi|)', 'O(n²)', 'O(n)', 'O(n)'],
        '検索時間': ['O(nm)', 'O(m)', 'O(m)', 'O(m)', 'O(m)'],
        'メモリ': ['O(1)', 'O(Σ|Pi|)', 'O(n²)', 'O(n)', 'O(n)'],
        '最適な用途': [
            'パターンが少ない',
            '複数パターン',
            '理論的興味',
            '万能',
            '巨大ゲノム'
        ]
    })

    print(comparison.to_string(index=False))

    print("\n凡例:")
    print("n: テキスト（ゲノム）の長さ")
    print("m: パターンの長さ")
    print("Σ|Pi|: すべてのパターンの合計長")

performance_comparison()
```

### 8-2. いつ接尾辞ツリーを使うべきか

```python
def when_to_use_suffix_tree():
    """
    接尾辞ツリーの使用指針
    """
    guidelines = """
    === 接尾辞ツリーを使うべき場面 ===

    ✅ 最適な場合:
    1. 同じゲノムに対して多数の検索を行う
    2. 最長共通部分文字列を見つけたい
    3. すべての繰り返し配列を列挙したい
    4. パターンの長さが様々

    ⚠️ 注意が必要な場合:
    1. メモリが非常に限られている
       → BWT + FM-indexを検討
    2. ゲノムが頻繁に更新される
       → 動的データ構造を検討
    3. 単純なパターンマッチングのみ
       → KMPやBMアルゴリズムで十分かも

    💡 実装のヒント:
    - 実装は複雑なので、既存のライブラリを使用推奨
    - Python: suffix-trees, pysuffix
    - C++: SDSL library
    """
    print(guidelines)

when_to_use_suffix_tree()
```

## 📖 ステップ9：実装の課題と解決策

### 9-1. 実装上の課題

```python
def implementation_challenges():
    """
    接尾辞ツリー実装の課題
    """
    challenges = {
        "メモリ管理": {
            "問題": "ポインタが多く、メモリが断片化",
            "解決": "メモリプールやカスタムアロケータを使用"
        },
        "構築の複雑さ": {
            "問題": "ウッコネンのアルゴリズムは理解が困難",
            "解決": "まず単純な実装から始め、段階的に最適化"
        },
        "大規模データ": {
            "問題": "ゲノムが大きすぎてメモリに収まらない",
            "解決": "ディスクベースの実装やBWTへの移行"
        },
        "並列化": {
            "問題": "構築の並列化が困難",
            "解決": "部分的な並列化や近似アルゴリズム"
        }
    }

    for challenge, details in challenges.items():
        print(f"\n【{challenge}】")
        print(f"  問題: {details['問題']}")
        print(f"  解決: {details['解決']}")

implementation_challenges()
```

### 9-2. 実用的な実装例

```python
class PracticalSuffixTree:
    """
    実用的な接尾辞ツリー実装の骨格
    """
    def __init__(self, text, alphabet_size=256):
        self.text = text + "$"
        self.n = len(self.text)
        self.alphabet_size = alphabet_size

        # ノードプール（メモリ効率化）
        self.node_pool = []
        self.edge_pool = []

        # 統計情報
        self.stats = {
            'nodes': 0,
            'edges': 0,
            'memory_bytes': 0
        }

        self._build()

    def _build(self):
        """
        最適化された構築
        """
        # 実際の実装では：
        # 1. サフィックスリンクを使用
        # 2. アクティブポイントを管理
        # 3. 規則1,2,3を適用（ウッコネン）
        pass

    def search_all(self, pattern):
        """
        すべての出現位置を検索
        """
        positions = []
        # O(|pattern|)時間で検索
        return positions

    def get_statistics(self):
        """
        メモリ使用量の統計
        """
        return self.stats

    def longest_repeated_substring(self):
        """
        最長繰り返し部分文字列を検出
        """
        # 最深の内部ノードを探す
        pass

    def serialize(self, filename):
        """
        ディスクへの永続化
        """
        # 接尾辞ツリーをファイルに保存
        pass

    @staticmethod
    def deserialize(filename):
        """
        ディスクから読み込み
        """
        # 保存された接尾辞ツリーを復元
        pass
```

## 📖 ステップ10：さらなる発展

### 10-1. 一般化接尾辞ツリー

```python
def generalized_suffix_tree():
    """
    複数文字列の一般化接尾辞ツリー
    """
    class GeneralizedSuffixTree:
        def __init__(self, strings):
            # 複数の文字列を特殊記号で連結
            self.strings = strings
            self.combined = ""
            self.separators = []

            for i, s in enumerate(strings):
                self.combined += s + f"${i}"
                self.separators.append(f"${i}")

            # 通常の接尾辞ツリーを構築
            self.tree = SimpleSuffixTree(self.combined)

        def find_common_substrings(self, min_length=10):
            """
            複数文字列に共通する部分文字列を検出
            """
            # 異なる文字列からの葉を持つノードを探す
            pass

    # 使用例：複数ゲノムの比較
    genomes = [
        "ATCGATCGATCG",
        "GATCGATCGATC",
        "TCGATCGATCGA"
    ]
    gst = GeneralizedSuffixTree(genomes)
    print("複数ゲノムの共通配列を検索中...")

generalized_suffix_tree()
```

### 10-2. 圧縮接尾辞ツリー

```python
def compressed_suffix_tree():
    """
    さらなるメモリ最適化
    """
    optimizations = """
    === 圧縮接尾辞ツリーの技術 ===

    1. Enhanced Suffix Array (ESA)
       - 配列ベースで接尾辞ツリーを表現
       - キャッシュ効率が良い

    2. Compressed Suffix Array (CSA)
       - ウェーブレット木を使用
       - メモリをさらに削減

    3. FM-index
       - BWTベース
       - 極限までの圧縮

    トレードオフ:
    - メモリ削減 ↔ 検索速度
    - 構築時間 ↔ 検索効率
    """
    print(optimizations)

compressed_suffix_tree()
```

## 🎯 実践演習：完全な接尾辞ツリー

```python
class CompleteSuffixTree:
    """
    教育用の完全な接尾辞ツリー実装
    """
    class Node:
        def __init__(self):
            self.children = {}
            self.start = -1
            self.end = -1
            self.suffix_link = None
            self.suffix_index = -1

    def __init__(self, text):
        self.text = text + "$"
        self.n = len(self.text)
        self.root = self.Node()
        self.active_node = self.root
        self.active_edge = -1
        self.active_length = 0
        self.remaining_suffix_count = 0
        self.leaf_end = -1
        self.internal_node_count = 0

        self._build_suffix_tree()

    def _build_suffix_tree(self):
        """
        ウッコネンのアルゴリズムの簡略版
        """
        for i in range(self.n):
            self._extend_suffix_tree(i)

    def _extend_suffix_tree(self, pos):
        """
        位置posの文字を追加
        """
        # 実装の詳細は省略（非常に複雑）
        pass

    def search(self, pattern):
        """
        パターンを検索してすべての位置を返す
        """
        node = self.root
        i = 0

        while i < len(pattern):
            if pattern[i] in node.children:
                child = node.children[pattern[i]]
                edge_len = child.end - child.start + 1

                # エッジ上を進む
                j = 0
                while j < edge_len and i < len(pattern):
                    if self.text[child.start + j] != pattern[i]:
                        return []  # 不一致
                    i += 1
                    j += 1

                if i == len(pattern):
                    # パターン完全一致
                    return self._collect_leaves(child)

                node = child
            else:
                return []  # パターンが見つからない

        return self._collect_leaves(node)

    def _collect_leaves(self, node):
        """
        ノード以下のすべての葉の位置を収集
        """
        positions = []

        if node.suffix_index >= 0:
            positions.append(node.suffix_index)

        for child in node.children.values():
            positions.extend(self._collect_leaves(child))

        return positions

    def print_statistics(self):
        """
        統計情報を表示
        """
        print(f"テキスト長: {self.n}")
        print(f"内部ノード数: {self.internal_node_count}")
        print(f"葉の数: {self.n}")
        print(f"総ノード数: {self.internal_node_count + self.n}")
        print(f"メモリ複雑度: O(n)")

# 使用例
text = "MISSISSIPPI"
st = CompleteSuffixTree(text)
st.print_statistics()

# パターン検索
pattern = "ISS"
positions = st.search(pattern)
print(f"\n'{pattern}'の出現位置: {positions}")
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- 接尾辞ツリーはゲノム全体を効率的に表現するデータ構造
- どんなパターンでもO(m)時間で検索可能
- メモリ使用量はO(n)で線形

### レベル2：本質的理解（ここまで来たら素晴らしい）

- 接尾辞トライのパス圧縮により接尾辞ツリーが生まれた
- ウッコネンのアルゴリズムで線形時間構築が可能
- 繰り返し配列検出や最長共通部分文字列など多様な応用

### レベル3：応用的理解（プロレベル）

- 実装の最適化技術（メモリプール、サフィックスリンク）
- 一般化接尾辞ツリーで複数配列の比較
- BWTやFM-indexへの発展と使い分け

## 🚀 次回予告

次回は「**バローズ・ウィーラー変換（BWT）**」を学びます。

接尾辞ツリーが「メモリ効率的な検索」を実現したように、BWTは「**圧縮しながら検索できる**」という、さらに驚異的な技術です。

なんと、3GBのヒトゲノムを**500MBに圧縮しながら高速検索**できるんです！その秘密は、文字の「巧妙な並べ替え」にあります。次回、その魔法を解き明かしましょう！
