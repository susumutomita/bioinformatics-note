# トライの使用：複数パターン検索の革命的手法（超詳細版）

## 🎯 まず、この講義で何を学ぶのか

最終ゴール：**何千個ものパターンを同時に検索できる「トライ」というデータ構造を完璧に理解し、ゲノム解析での活用方法をマスターする**

でも、ちょっと待ってください。そもそも「複数のパターンを同時に検索」って、どういう意味でしょう？

実は、これは**ゲノム解析の速度を何千倍にも高速化する魔法のような技術**なんです。

## 🤔 ステップ0：なぜトライが必要なの？

### 0-1. そもそもの問題を考えてみよう

あなたは図書館の司書だとしましょう。

```python
# 1万冊の本の中から、特定の単語を含む本を探したい
books = ["本1の内容...", "本2の内容...", ...]  # 1万冊

# 探したい単語リスト（1000個）
search_words = ["DNA", "RNA", "タンパク質", ...]  # 1000個

# 素朴な方法：すべての組み合わせをチェック
def naive_search():
    results = []
    for book in books:  # 1万回
        for word in search_words:  # × 1000回
            if word in book:  # × 文字比較
                results.append((book, word))
    # 合計：1000万回以上の比較！
```

### 0-2. 驚きの事実

トライを使うと、**1000個のパターンを1回のスキャンで全部見つけられる**んです！

```python
# トライを使った検索
def trie_search(text, patterns):
    # 1000個のパターンをトライに構築（1回だけ）
    trie = build_trie(patterns)

    # テキストを1回スキャンするだけ！
    for position in text:
        check_all_patterns_at_once(trie, position)

    # 計算量：O(テキスト長) だけ！
```

## 📖 ステップ1：トライって何？〜木構造の基礎〜

### 1-1. まず、単語の共通部分を観察してみよう

```python
patterns = ["apple", "application", "apply", "banana", "band"]

# 共通の接頭辞に注目
# "app" -> "apple", "application", "apply"
# "ban" -> "banana", "band"
```

### 1-2. トライの基本構造

```
        root
        / \
       a   b
       |   |
       p   a
       |   |
       p   n
      /|\   |\
     l i y  a d
     | |    |
     e c    n
       |    |
       a    a
       |
       t...
```

**ポイント**：共通部分を共有することで、メモリを節約し、検索を高速化！

## 📖 ステップ2：トライの構築〜実装してみよう〜

### 2-1. ノードの定義

```python
class TrieNode:
    def __init__(self):
        self.children = {}  # 子ノードへの辞書
        self.is_end = False  # パターンの終端か？
        self.pattern_id = None  # どのパターンか

    def __repr__(self):
        return f"Node(children={list(self.children.keys())}, end={self.is_end})"
```

### 2-2. トライ構築アルゴリズム

```python
def build_trie(patterns):
    """
    複数のパターンからトライを構築
    """
    root = TrieNode()

    for pattern_id, pattern in enumerate(patterns):
        current = root

        # パターンの各文字を処理
        for char in pattern:
            # 子ノードがなければ作成
            if char not in current.children:
                current.children[char] = TrieNode()

            # 次のノードへ移動
            current = current.children[char]

        # パターンの終端をマーク
        current.is_end = True
        current.pattern_id = pattern_id

    return root

# 実験してみよう
patterns = ["AT", "AG", "AC", "TC"]
trie = build_trie(patterns)
print(f"トライ構築完了！ルートの子: {list(trie.children.keys())}")
# 出力: トライ構築完了！ルートの子: ['A', 'T']
```

## 📖 ステップ3：トライでの検索〜魔法の仕組み〜

### 3-1. 基本的な検索アルゴリズム

```python
def search_with_trie(text, trie):
    """
    テキスト中のすべてのパターンを一度に検索
    """
    matches = []

    # テキストの各位置から検索開始
    for start_pos in range(len(text)):
        current = trie
        pos = start_pos

        # トライを辿る
        while pos < len(text) and text[pos] in current.children:
            current = current.children[text[pos]]
            pos += 1

            # パターンの終端に到達？
            if current.is_end:
                pattern_length = pos - start_pos
                matches.append({
                    'position': start_pos,
                    'length': pattern_length,
                    'pattern': text[start_pos:pos]
                })

    return matches

# 実験
text = "ATCGATCG"
patterns = ["AT", "TC", "CG"]
trie = build_trie(patterns)
results = search_with_trie(text, trie)
print(f"見つかったパターン: {results}")
```

### 3-2. なぜこれが速いのか？

```python
# 従来の方法：各パターンを個別に検索
def naive_multiple_search(text, patterns):
    time_complexity = len(text) * len(patterns) * average_pattern_length
    # O(n * m * k) の計算量

# トライを使った方法
def trie_search_complexity(text, patterns):
    build_time = sum(len(p) for p in patterns)  # トライ構築
    search_time = len(text) * max_pattern_length  # 検索
    # O(総パターン長 + n * k) の計算量
```

## 📖 ステップ4：ゲノム解析での応用〜実践例〜

### 4-1. 制限酵素認識配列の検索

```python
def find_restriction_sites(genome, enzyme_patterns):
    """
    複数の制限酵素認識配列を同時に検索
    """
    # 制限酵素のパターン
    enzymes = {
        "EcoRI": "GAATTC",
        "BamHI": "GGATCC",
        "PstI": "CTGCAG",
        "HindIII": "AAGCTT"
    }

    # トライ構築
    patterns = list(enzymes.values())
    trie = build_trie(patterns)

    # ゲノム全体を1回スキャン
    sites = search_with_trie(genome, trie)

    return sites

# デモンストレーション
sample_genome = "GAATTCGGATCCCTGCAGAAGCTT"
sites = find_restriction_sites(sample_genome, None)
print(f"制限酵素サイト: {sites}")
```

### 4-2. モチーフ検索への応用

```python
def find_regulatory_motifs(genome, motif_database):
    """
    数千個の調節モチーフを同時検索
    """
    # 転写因子結合サイトのデータベース
    motifs = load_motif_database()  # 5000個のモチーフ

    # トライ構築（1回だけ）
    trie = build_trie(motifs)

    # ゲノム全体をスキャン
    binding_sites = []
    for chromosome in genome.chromosomes:
        sites = search_with_trie(chromosome.sequence, trie)
        binding_sites.extend(sites)

    return binding_sites
```

## 📖 ステップ5：トライの最適化〜さらなる高速化〜

### 5-1. 失敗リンクの追加（Aho-Corasickアルゴリズム）

```python
class AhoCorasickNode(TrieNode):
    def __init__(self):
        super().__init__()
        self.failure_link = None  # 失敗時のジャンプ先
        self.output_link = None   # 出力リンク

def build_aho_corasick(patterns):
    """
    Aho-Corasickオートマトンの構築
    """
    # 基本トライ構築
    root = build_trie(patterns)

    # 失敗リンクを幅優先探索で構築
    queue = []
    for child in root.children.values():
        child.failure_link = root
        queue.append(child)

    while queue:
        current = queue.pop(0)

        for char, child in current.children.items():
            queue.append(child)

            # 失敗リンクを計算
            failure = current.failure_link
            while failure != root and char not in failure.children:
                failure = failure.failure_link

            if char in failure.children and failure.children[char] != child:
                child.failure_link = failure.children[char]
            else:
                child.failure_link = root

    return root
```

### 5-2. パフォーマンス比較

```python
import time

def performance_comparison():
    # テストデータ準備
    genome = "ACGT" * 1000000  # 400万塩基
    patterns = [generate_random_pattern(10) for _ in range(1000)]

    # 方法1：単純な逐次検索
    start = time.time()
    for pattern in patterns:
        genome.find(pattern)
    naive_time = time.time() - start

    # 方法2：トライを使った検索
    start = time.time()
    trie = build_trie(patterns)
    search_with_trie(genome, trie)
    trie_time = time.time() - start

    print(f"単純検索: {naive_time:.2f}秒")
    print(f"トライ検索: {trie_time:.2f}秒")
    print(f"速度向上: {naive_time/trie_time:.1f}倍")
```

## 📖 ステップ6：実装の落とし穴と解決策

### 6-1. メモリ使用量の問題

```python
def memory_efficient_trie():
    """
    メモリ効率的なトライの実装
    """
    class CompactNode:
        def __init__(self):
            # 辞書ではなく配列を使用（DNA用）
            self.children = [None] * 4  # A, C, G, T
            self.is_end = False

        def get_child(self, char):
            index = {'A': 0, 'C': 1, 'G': 2, 'T': 3}[char]
            return self.children[index]
```

### 6-2. 大文字小文字の処理

```python
def case_insensitive_trie(patterns):
    """
    大文字小文字を区別しないトライ
    """
    normalized_patterns = [p.upper() for p in patterns]
    return build_trie(normalized_patterns)
```

## 📖 ステップ7：トライ vs 他の手法

### 7-1. 比較表

| 手法               | 前処理時間 | 検索時間 | メモリ使用量 | 適用場面           |
| ------------------ | ---------- | -------- | ------------ | ------------------ |
| 単純検索           | O(1)       | O(n×m×k) | O(m×k)       | パターン数が少ない |
| トライ             | O(m×k)     | O(n×k)   | O(m×k)       | パターン数が多い   |
| サフィックスツリー | O(n)       | O(m+k)   | O(n)         | テキストが固定     |
| BWT                | O(n log n) | O(m)     | O(n)         | 大規模ゲノム       |

### 7-2. 使い分けの指針

```python
def choose_algorithm(text_size, pattern_count, pattern_length):
    """
    最適なアルゴリズムの選択
    """
    if pattern_count < 10:
        return "単純検索"
    elif pattern_count < 1000:
        return "トライ"
    elif text_size > 1_000_000_000:  # 1Gb以上
        return "BWT + FM-index"
    else:
        return "サフィックスツリー"
```

## 📖 ステップ8：実世界での応用例

### 8-1. ウイルス検出システム

```python
class VirusDetector:
    def __init__(self, virus_database):
        # 既知のウイルス配列をトライに構築
        self.virus_patterns = load_virus_signatures()
        self.trie = build_aho_corasick(self.virus_patterns)

    def scan_sample(self, sample_sequence):
        """
        サンプル中のウイルス配列を検出
        """
        matches = search_with_trie(sample_sequence, self.trie)

        # ウイルスの同定
        detected_viruses = []
        for match in matches:
            virus_info = self.identify_virus(match)
            detected_viruses.append(virus_info)

        return detected_viruses
```

### 8-2. CRISPR標的サイト探索

```python
def find_crispr_targets(genome, pam_sequence="NGG"):
    """
    CRISPR-Cas9の標的サイトを探索
    """
    # 20塩基 + PAM配列のパターンを生成
    potential_targets = []

    # PAM配列を含むすべての位置を高速検索
    pam_variants = generate_pam_variants(pam_sequence)
    trie = build_trie(pam_variants)

    pam_positions = search_with_trie(genome, trie)

    # 各PAM位置の前20塩基を標的候補として抽出
    for pos in pam_positions:
        if pos['position'] >= 20:
            target = genome[pos['position']-20:pos['position']]
            potential_targets.append({
                'sequence': target,
                'position': pos['position']-20,
                'pam': genome[pos['position']:pos['position']+3]
            })

    return potential_targets
```

## 📖 ステップ9：トライの発展形

### 9-1. サフィックストライ

```python
def build_suffix_trie(text):
    """
    テキストのすべての接尾辞からトライを構築
    """
    suffixes = []
    for i in range(len(text)):
        suffixes.append(text[i:] + "$")  # 終端記号を追加

    return build_trie(suffixes)

# 使用例：任意の部分文字列を高速検索
text = "ATCGATCG"
suffix_trie = build_suffix_trie(text)
# これで"TCG"や"CG"など、任意の部分文字列を検索可能
```

### 9-2. パトリシアトライ（基数木）

```python
class PatriciaNode:
    """
    共通接頭辞を圧縮したトライ
    """
    def __init__(self, edge_label=""):
        self.edge_label = edge_label  # エッジのラベル（複数文字可）
        self.children = {}
        self.is_end = False

def build_patricia_trie(patterns):
    """
    パトリシアトライの構築（メモリ効率的）
    """
    # 実装は複雑だが、メモリ使用量を大幅削減
    pass
```

## 📖 ステップ10：まとめと次のステップ

### 10-1. トライのメリット・デメリット

**メリット**：

- 複数パターンを同時検索
- 前処理後は高速
- 共通接頭辞でメモリ節約

**デメリット**：

- 構築にメモリが必要
- 動的な追加・削除が複雑
- パターンが少ないと過剰

### 10-2. 実装チェックリスト

```python
def trie_implementation_checklist():
    """
    トライ実装時の確認事項
    """
    checklist = {
        "基本機能": [
            "パターン挿入",
            "検索機能",
            "削除機能（必要なら）"
        ],
        "最適化": [
            "メモリ効率化",
            "失敗リンク（Aho-Corasick）",
            "圧縮（Patricia）"
        ],
        "エラー処理": [
            "空パターン",
            "重複パターン",
            "不正文字"
        ]
    }
    return checklist
```

## 🎯 実践演習：完全なトライ実装

```python
class CompleteTrie:
    """
    本番環境で使える完全なトライ実装
    """
    def __init__(self, case_sensitive=True):
        self.root = TrieNode()
        self.case_sensitive = case_sensitive
        self.pattern_count = 0

    def insert(self, pattern):
        """パターンの挿入"""
        if not self.case_sensitive:
            pattern = pattern.upper()

        current = self.root
        for char in pattern:
            if char not in current.children:
                current.children[char] = TrieNode()
            current = current.children[char]

        if not current.is_end:
            current.is_end = True
            self.pattern_count += 1
            current.pattern_id = self.pattern_count

    def search(self, text):
        """テキスト中のパターンを検索"""
        if not self.case_sensitive:
            text = text.upper()

        results = []
        for i in range(len(text)):
            current = self.root
            j = i

            while j < len(text) and text[j] in current.children:
                current = current.children[text[j]]
                j += 1

                if current.is_end:
                    results.append({
                        'start': i,
                        'end': j,
                        'pattern': text[i:j],
                        'id': current.pattern_id
                    })

        return results

    def delete(self, pattern):
        """パターンの削除"""
        def _delete(node, pattern, depth):
            if depth == len(pattern):
                if node.is_end:
                    node.is_end = False
                    return len(node.children) == 0
                return False

            char = pattern[depth]
            if char not in node.children:
                return False

            should_delete = _delete(node.children[char], pattern, depth + 1)

            if should_delete:
                del node.children[char]
                return len(node.children) == 0 and not node.is_end

            return False

        if not self.case_sensitive:
            pattern = pattern.upper()

        _delete(self.root, pattern, 0)

# 使用例
trie = CompleteTrie(case_sensitive=False)
patterns = ["GATTACA", "GAGAGA", "GATT"]
for p in patterns:
    trie.insert(p)

genome = "CGATTAGATTACAGAGAGATT"
matches = trie.search(genome)
print(f"検出されたパターン: {matches}")
```

## 📝 まとめ：今日学んだことを整理

### レベル1：表面的理解（これだけでもOK）

- トライは複数のパターンを効率的に検索するデータ構造
- 共通の接頭辞を共有してメモリを節約
- ゲノム解析で広く使われている

### レベル2：本質的理解（ここまで来たら素晴らしい）

- O(n×m×k)の計算量をO(n×k)に削減
- Aho-Corasickアルゴリズムでさらに高速化
- メモリと速度のトレードオフを理解

### レベル3：応用的理解（プロレベル）

- 様々な変種（サフィックストライ、パトリシアトライ）の使い分け
- 実装の最適化テクニック
- 実際のゲノム解析パイプラインへの組み込み

## 🚀 次回予告

次回は「**バローズ・ウィーラー変換の詳細**」を学びます。

トライが「複数パターンの同時検索」を可能にしたように、BWTは「巨大なゲノムの超高速検索」を可能にします。なんと、**3億塩基のヒトゲノムを数秒で検索**できるようになるんです！

その秘密は、データの「可逆的な並べ替え」にあります。次回、その魔法のような仕組みを解き明かしていきましょう！
