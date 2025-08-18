---
sidebar_position: 6
title: 'De Bruijnグラフ：ゲノムなしでグラフを構築'
---

# De Bruijnグラフ：ゲノムなしでグラフを構築

## 🎯 この講義で学ぶこと

**最終ゴール**: k-mer構成から直接De Bruijnグラフを構築し、ユニバーサル文字列問題との関連を理解する

でも、ちょっと待ってください。前回はゲノムから作ったけど、実際はゲノムが分からないのでは？

## 🤔 ステップ0：重要な気づき

### 私たちの「浮気」を暴く

前回の講義で、私たちはDe Bruijnグラフをゲノムから作成しました。しかし...

```python
def reveal_the_cheat():
    """前回の「浮気」を明らかにする"""

    print("前回のアプローチ:")
    print("1. ゲノムがあった（知っていた）")
    print("2. ゲノムからk-merを抽出")
    print("3. De Bruijnグラフを構築")
    print()
    print("でも実際は:")
    print("1. ゲノムは不明！")
    print("2. 分かるのはリード（k-mer）だけ")
    print("3. k-merからゲノムを再構築する必要がある")
    print()
    print("質問: k-mer構成だけからDe Bruijnグラフを作れるか？")
    print("答え: できる！（これから証明）")

reveal_the_cheat()
```

## 📚 ステップ1：k-mer構成からDe Bruijnグラフを構築

### 1-1. 2つのアプローチの比較

```python
def compare_approaches():
    """ゲノムからvsゲノム構成からのグラフ構築"""

    # 例のゲノムとk-mer
    genome = "TAATGCCATGGGATGTT"
    kmers = ["TAA", "AAT", "ATG", "TGC", "GCC", "CCA", "CAT",
             "ATG", "TGG", "GGA", "GAT", "ATG", "TGT", "GTT"]

    print("=== アプローチ1: ゲノムから（前回）===")
    print(f"ゲノム: {genome}")
    print("1. ゲノムを経路として表現")
    print("2. k-merをエッジとして配置")
    print("3. 同じラベルのノードを接着")
    print()

    print("=== アプローチ2: k-mer構成から（今回）===")
    print(f"k-mer構成: {kmers}")
    print("1. 各k-merをエッジとして表現")
    print("2. 各エッジの端点を(k-1)-merでラベル付け")
    print("3. 同じラベルのノードを接着")
    print()
    print("結果: 同じDe Bruijnグラフができる！")

compare_approaches()
```

### 1-2. ステップバイステップの構築

```python
def build_from_kmers_step_by_step():
    """k-mer構成からDe Bruijnグラフを構築する詳細プロセス"""

    kmers = ["TAA", "AAT", "ATG", "TGC", "GCC"]

    print("Step 1: 各k-merをエッジとして表現")
    print("-" * 40)

    edges = []
    for kmer in kmers:
        prefix = kmer[:-1]  # 最初のk-1文字
        suffix = kmer[1:]   # 最後のk-1文字
        edges.append((prefix, suffix, kmer))
        print(f"k-mer: {kmer} → エッジ: {prefix} --[{kmer}]--> {suffix}")

    print("\nStep 2: 同じラベルのノードを識別")
    print("-" * 40)

    from collections import defaultdict
    node_appearances = defaultdict(list)

    for prefix, suffix, kmer in edges:
        node_appearances[prefix].append(f"start of {kmer}")
        node_appearances[suffix].append(f"end of {kmer}")

    for node, appearances in sorted(node_appearances.items()):
        if len(appearances) > 1:
            print(f"'{node}': {len(appearances)}回出現")
            for app in appearances:
                print(f"  - {app}")

    print("\nStep 3: 同じラベルのノードを接着")
    print("-" * 40)
    print("接着後、De Bruijnグラフが完成！")

    # 最終的なグラフ構造
    graph = defaultdict(list)
    for kmer in kmers:
        prefix = kmer[:-1]
        suffix = kmer[1:]
        graph[prefix].append(suffix)

    print("\n最終的なグラフ:")
    for node, neighbors in sorted(graph.items()):
        print(f"  {node} → {neighbors}")

build_from_kmers_step_by_step()
```

## 🔧 ステップ2：アルゴリズムの実装

### 2-1. シンプルな2行アルゴリズム

```python
def de_bruijn_from_kmers(kmers):
    """k-mer構成からDe Bruijnグラフを構築する2行アルゴリズム"""

    from collections import defaultdict

    # 1行目: すべてのk-merを接頭辞と接尾辞の間のエッジとして表現
    # 2行目: 同じラベルのノードを接着（defaultdictが自動的に処理）
    graph = defaultdict(list)
    for kmer in kmers:
        graph[kmer[:-1]].append(kmer[1:])

    return dict(graph)

# 例
kmers = ["AAT", "ATG", "TGC", "GCA", "CAT", "ATG", "TGG", "GGA"]
graph = de_bruijn_from_kmers(kmers)

print("De Bruijnグラフ（2行で構築！）:")
for node, edges in sorted(graph.items()):
    print(f"  {node} → {edges}")
```

### 2-2. 等価な定義

```python
def equivalent_definitions():
    """De Bruijnグラフの2つの等価な定義"""

    print("定義1: エッジとノードの構築")
    print("-" * 40)
    print("1. k-merを接頭辞と接尾辞の間のエッジとして表現")
    print("2. 同じラベルのノードを接着")
    print()

    print("定義2: ノードとエッジの直接構築")
    print("-" * 40)
    print("1. すべての(k-1)-merからグラフのノードを形成")
    print("2. 各k-merについて、接頭辞ノードと接尾辞ノードをエッジで接続")
    print()
    print("両方の定義は同じグラフを生成する！")

equivalent_definitions()
```

## 🎨 ステップ3：De Bruijnとユニバーサル文字列問題

### 3-1. De Bruijnの純粋数学的問題

```python
def universal_string_problem():
    """ユニバーサル文字列問題の説明"""

    print("De Bruijnの問題（1946年）:")
    print("=" * 50)
    print()
    print("すべてのバイナリk-merを1回だけ含む円形文字列を見つけよ")
    print()

    # k=3の例
    k = 3
    total_kmers = 2**k

    print(f"k={k}の場合:")
    print(f"バイナリ{k}-merの総数: {total_kmers}")

    binary_kmers = []
    for i in range(total_kmers):
        kmer = format(i, f'0{k}b')
        binary_kmers.append(kmer)

    print(f"すべてのバイナリ{k}-mer:")
    print(f"  {binary_kmers}")
    print()
    print("ユニバーサル文字列: 00010111")
    print("（円形なので最初と最後がつながる）")

    # 検証
    universal = "00010111"
    print("\n検証:")
    for i in range(len(universal)):
        kmer = universal[i:i+3] if i <= 5 else universal[i:] + universal[:3-(8-i)]
        print(f"  位置{i}: {kmer}")

universal_string_problem()
```

### 3-2. De Bruijnグラフによる解法

```python
def solve_universal_string():
    """De Bruijnグラフを使ってユニバーサル文字列を構築"""

    k = 3

    # Step 1: すべてのバイナリk-merを生成
    kmers = []
    for i in range(2**k):
        kmers.append(format(i, f'0{k}b'))

    print(f"すべてのバイナリ{k}-mer: {kmers}")
    print()

    # Step 2: De Bruijnグラフを構築
    from collections import defaultdict
    graph = defaultdict(list)

    for kmer in kmers:
        prefix = kmer[:-1]
        suffix = kmer[1:]
        graph[prefix].append(suffix)

    print("De Bruijnグラフ:")
    for node, edges in sorted(graph.items()):
        print(f"  {node} → {edges}")
    print()

    # Step 3: オイラーサイクルを見つける
    def find_eulerian_cycle(graph):
        """簡単なオイラーサイクル探索"""
        import copy
        g = copy.deepcopy(graph)

        cycle = []
        stack = ['00']  # 任意のノードから開始

        while stack:
            v = stack[-1]
            if v in g and g[v]:
                u = g[v].pop(0)
                stack.append(u)
            else:
                cycle.append(stack.pop())

        return cycle[::-1]

    cycle = find_eulerian_cycle(dict(graph))
    print(f"オイラーサイクル: {' → '.join(cycle)}")

    # Step 4: ユニバーサル文字列を構築
    universal = cycle[0]
    for node in cycle[1:-1]:  # 最後のノードは最初と同じ
        universal += node[-1]

    print(f"\nユニバーサル文字列: {universal}")

    # 検証
    print("\n含まれるk-mer:")
    for i in range(len(universal)):
        kmer = universal[i:i+3] if i <= len(universal)-3 else universal[i:] + universal[:3-(len(universal)-i)]
        print(f"  {kmer}", end=" ")
    print()

solve_universal_string()
```

## 🔮 ステップ4：より大きなkへの拡張

### 4-1. スケーラビリティの分析

```python
def scalability_analysis():
    """より大きなkに対するユニバーサル文字列"""

    print("ユニバーサル文字列のスケール:")
    print("=" * 50)

    for k in range(2, 11):
        num_kmers = 2**k
        string_length = 2**k  # ユニバーサル文字列の長さ
        num_nodes = 2**(k-1)  # De Bruijnグラフのノード数

        print(f"\nk={k}:")
        print(f"  バイナリk-mer数: {num_kmers}")
        print(f"  ユニバーサル文字列長: {string_length}")
        print(f"  De Bruijnグラフのノード数: {num_nodes}")

        if k <= 5:
            print(f"  → 実用的に計算可能")
        elif k <= 10:
            print(f"  → 計算可能だが時間がかかる")
        else:
            print(f"  → メモリと時間の制約が厳しい")

scalability_analysis()
```

### 4-2. なぜDe Bruijnグラフは効率的か

```python
def why_de_bruijn_efficient():
    """De Bruijnグラフの効率性の理由"""

    print("De Bruijnグラフが効率的な3つの理由:")
    print("=" * 50)
    print()

    print("1. ノード数の削減")
    print("   • k-merの数に関わらず、最大4^(k-1)ノード")
    print("   • 実際はもっと少ない（重複を接着）")
    print()

    print("2. オイラー経路の効率的な探索")
    print("   • 線形時間O(E)で解ける")
    print("   • ハミルトニアン経路（NP完全）と違い効率的")
    print()

    print("3. メモリ効率")
    print("   • 隣接リスト表現で省メモリ")
    print("   • 大規模なゲノムでも処理可能")
    print()

    # 具体例
    print("例: ヒトゲノムの場合")
    print("-" * 30)
    genome_size = 3_000_000_000
    k = 31  # 典型的なk値

    print(f"  ゲノムサイズ: {genome_size:,} bp")
    print(f"  k-mer長: {k}")
    print(f"  理論最大ノード数: 4^{k-1} = 非常に大きい")
    print(f"  実際のノード数: ゲノムサイズ程度（重複により大幅削減）")

why_de_bruijn_efficient()
```

## 🎯 まとめ：今日学んだことを整理

### レベル1：基礎理解

- **k-mer構成から直接**De Bruijnグラフを構築できる
- ゲノムを知らなくてもグラフを作れる
- 2行の簡単なアルゴリズムで実装可能

### レベル2：理論的背景

- De Bruijnは**ユニバーサル文字列問題**を解くためにこのグラフを考案
- すべてのバイナリk-merを1回ずつ含む円形文字列
- オイラーサイクルを見つけることで解決

### レベル3：実践的意義

- ゲノムアセンブリへの応用
- 効率的なアルゴリズム（線形時間）
- 大規模データにも対応可能

## 🚀 次回予告

次回は、オイラーサイクル/経路を効率的に見つけるアルゴリズムを学びます：

- **Hierholzerのアルゴリズム**
- グラフの条件とオイラー経路の存在
- 実際のゲノムアセンブラーでの応用

「理論を実装へ」- アルゴリズムの詳細をお楽しみに！
