---
sidebar_position: 7
title: 'オイラーの定理：アリのアルゴリズム'
---

# オイラーの定理：アリのアルゴリズム

## 🎯 この講義で学ぶこと

**最終ゴール**: オイラーサイクルの存在条件を理解し、それを見つけるアルゴリズムを学ぶ

でも、ちょっと待ってください。どんなグラフでもオイラーサイクルが存在するわけではないのでは？

## 🌉 ステップ0：オイラーサイクル vs オイラー経路

### サイクルと経路の違い

```python
def cycle_vs_path():
    """オイラーサイクルとオイラー経路の違い"""

    print("オイラーサイクル:")
    print("  • すべてのエッジを1回ずつ通過")
    print("  • 開始点と終了点が同じ")
    print("  • ケーニヒスベルクの元の問題")
    print()
    print("オイラー経路:")
    print("  • すべてのエッジを1回ずつ通過")
    print("  • 開始点と終了点が異なってもよい")
    print("  • より一般的な問題")
    print()
    print("重要: サイクルを見つける方法を学べば、")
    print("      経路を見つける方法もすぐに分かる！")

cycle_vs_path()
```

## 🔍 ステップ1：オイラーサイクルの存在条件

### 1-1. バランスの取れたグラフ

```python
def check_balanced_graph():
    """グラフがバランスしているかチェック"""

    # 例のグラフ（隣接リスト）
    graphs = [
        {
            'A': ['B'],
            'B': ['C'],
            'C': []  # 出口なし
        },
        {
            'A': ['B', 'C'],
            'B': ['C'],
            'C': ['A']  # 入力1、出力1
        },
        {
            'A': ['B', 'B'],
            'B': ['C', 'C'],
            'C': ['A', 'A']  # すべてバランス
        }
    ]

    for i, graph in enumerate(graphs, 1):
        print(f"グラフ{i}:")

        # 入次数と出次数を計算
        in_degree = {}
        out_degree = {}

        for node in graph:
            out_degree[node] = len(graph[node])
            in_degree[node] = 0

        for node in graph:
            for neighbor in graph[node]:
                in_degree[neighbor] = in_degree.get(neighbor, 0) + 1

        # バランスをチェック
        balanced = True
        for node in set(list(in_degree.keys()) + list(out_degree.keys())):
            ind = in_degree.get(node, 0)
            outd = out_degree.get(node, 0)
            print(f"  {node}: 入次数={ind}, 出次数={outd}", end="")
            if ind != outd:
                print(" ❌ アンバランス")
                balanced = False
            else:
                print(" ✓")

        if balanced:
            print("  → バランスが取れている（オイラーサイクルの可能性あり）")
        else:
            print("  → バランスが取れていない（オイラーサイクル不可能）")
        print()

check_balanced_graph()
```

### 1-2. なぜバランスが必要か

```python
def why_balance_needed():
    """なぜバランスが必要か視覚的に説明"""

    print("オイラーサイクルでノードを訪問するとき:")
    print("=" * 50)
    print()

    print("ノードAを考える:")
    print("  入ってくる → 出ていく")
    print("  入ってくる → 出ていく")
    print("  入ってくる → 出ていく")
    print()
    print("観察:")
    print("• ノードに入る回数 = ノードから出る回数")
    print("• だから: 入次数 = 出次数")
    print()

    print("もし入次数 ≠ 出次数なら:")
    print("• 入次数 > 出次数: 入ったまま出られない！")
    print("• 入次数 < 出次数: すべてのエッジを使えない！")
    print()
    print("→ オイラーサイクルは不可能")

why_balance_needed()
```

## 🐜 ステップ2：アリのアルゴリズム

### 2-1. アリの散歩戦略

```python
def ant_algorithm_concept():
    """アリのアルゴリズムの概念"""

    print("アリのランダムウォーク:")
    print("=" * 50)
    print()
    print("ルール:")
    print("1. アリはグラフをランダムに歩く")
    print("2. 同じエッジを2度通らない")
    print("3. 行き止まりになったら？")
    print()
    print("重要な観察:")
    print("• バランスの取れたグラフでは...")
    print("• アリは開始ノード以外で行き止まりにならない！")
    print()
    print("理由:")
    print("• 各ノード（開始ノード以外）で:")
    print("  入るエッジ数 = 出るエッジ数")
    print("• だから、入ったら必ず出られる")
    print("• 開始ノードだけは最初に1つエッジを使用済み")

ant_algorithm_concept()
```

### 2-2. アリのアルゴリズム実装

```python
def ant_algorithm_step_by_step():
    """アリのアルゴリズムをステップバイステップで実装"""

    # 簡単なバランスの取れたグラフ
    graph = {
        'A': ['B', 'C'],
        'B': ['C', 'D'],
        'C': ['A', 'D'],
        'D': ['A', 'B']
    }

    import copy

    print("グラフ:")
    for node, edges in graph.items():
        print(f"  {node} → {edges}")
    print()

    def ant_walk(g, start):
        """アリの一回の散歩"""
        graph_copy = copy.deepcopy(g)
        path = [start]
        current = start

        while current in graph_copy and graph_copy[current]:
            # ランダムに（ここでは最初の）エッジを選択
            next_node = graph_copy[current].pop(0)
            path.append(next_node)
            current = next_node

        return path

    # Step 1: 最初の散歩
    print("Step 1: アリの最初の散歩")
    print("-" * 30)
    path1 = ant_walk(graph, 'A')
    print(f"経路: {' → '.join(path1)}")

    if path1[0] == path1[-1]:
        print("✓ 開始ノードに戻った！")
    else:
        print("❌ 開始ノードに戻らなかった")

    # 使用したエッジを記録
    used_edges = []
    for i in range(len(path1) - 1):
        used_edges.append((path1[i], path1[i+1]))

    print(f"使用したエッジ: {len(used_edges)}")
    print(f"全エッジ数: {sum(len(e) for e in graph.values())}")

    if len(used_edges) < sum(len(e) for e in graph.values()):
        print("\n→ まだ未使用のエッジがある！")
        print("   未使用エッジがあるノードから再開...")

ant_algorithm_step_by_step()
```

## 🔄 ステップ3：完全なアリのアルゴリズム

### 3-1. 反復的な改良

```python
def complete_ant_algorithm():
    """完全なアリのアルゴリズム（Hierholzerのアルゴリズム）"""

    def find_eulerian_cycle(graph):
        """オイラーサイクルを見つける"""
        import copy

        # グラフをコピー
        g = copy.deepcopy(graph)

        # すべてのエッジを使うまで繰り返す
        def find_cycle_from(start):
            """指定ノードからサイクルを見つける"""
            cycle = [start]
            current = start

            while current in g and g[current]:
                next_node = g[current].pop(0)
                cycle.append(next_node)
                current = next_node

            return cycle

        # 任意のノードから開始
        start_node = next(iter(graph))
        main_cycle = find_cycle_from(start_node)

        # すべてのエッジを使うまで繰り返す
        while any(g[node] for node in g):
            # 未使用エッジがあるノードを探す
            for i, node in enumerate(main_cycle[:-1]):
                if node in g and g[node]:
                    # このノードから新しいサイクルを見つける
                    sub_cycle = find_cycle_from(node)
                    # メインサイクルに統合
                    main_cycle = main_cycle[:i] + sub_cycle + main_cycle[i+1:]
                    break

        return main_cycle

    # テスト
    graph = {
        '00': ['01', '10'],
        '01': ['10', '11'],
        '10': ['00', '11'],
        '11': ['00', '01']
    }

    print("グラフ（バイナリ2-mer）:")
    for node, edges in graph.items():
        print(f"  {node} → {edges}")
    print()

    cycle = find_eulerian_cycle(graph)
    print("オイラーサイクル:")
    print(" → ".join(cycle))

    # 検証
    edge_count = sum(len(edges) for edges in graph.values())
    print(f"\n検証:")
    print(f"  エッジ数: {edge_count}")
    print(f"  サイクルの長さ: {len(cycle) - 1}")
    print(f"  {'✓ 正しい' if len(cycle) - 1 == edge_count else '❌ 間違い'}")

complete_ant_algorithm()
```

### 3-2. アルゴリズムの視覚化

```python
def visualize_ant_algorithm():
    """アリのアルゴリズムを視覚的に説明"""

    print("アリのアルゴリズムの動作:")
    print("=" * 50)
    print()

    # 反復を表示
    iterations = [
        {
            "iteration": 1,
            "start": "A",
            "path": ["A", "B", "C", "A"],
            "unused": ["A→D", "D→A"],
            "note": "最初のサイクル（不完全）"
        },
        {
            "iteration": 2,
            "start": "A（未使用エッジあり）",
            "path": ["A", "B", "C", "A", "D", "A"],
            "unused": [],
            "note": "完全なオイラーサイクル！"
        }
    ]

    for it in iterations:
        print(f"反復 {it['iteration']}:")
        print(f"  開始: {it['start']}")
        print(f"  経路: {' → '.join(it['path'])}")
        if it['unused']:
            print(f"  未使用: {', '.join(it['unused'])}")
        print(f"  {it['note']}")
        print()

    print("アルゴリズムの要点:")
    print("1. サイクルを見つける")
    print("2. 未使用エッジがあるノードを探す")
    print("3. そのノードから新しいサイクルを見つける")
    print("4. サイクルを統合")
    print("5. すべてのエッジを使うまで繰り返す")

visualize_ant_algorithm()
```

## 📐 ステップ4：オイラーの定理

### 4-1. 定理の記述

```python
def euler_theorem():
    """オイラーの定理の正式な記述"""

    print("オイラーの定理（1736年）:")
    print("=" * 50)
    print()
    print("【定理】")
    print("連結な有向グラフGについて、")
    print("Gがオイラーサイクルを持つ")
    print("⇔")
    print("Gがバランスしている（すべてのノードで入次数=出次数）")
    print()
    print("【系】オイラー経路について")
    print("Gがオイラー経路を持つ")
    print("⇔")
    print("・入次数≠出次数のノードが最大2個")
    print("・その場合、1つは入次数=出次数-1（開始点）")
    print("・もう1つは入次数=出次数+1（終了点）")
    print()
    print("【計算複雑性】")
    print("• 判定: O(V + E) - 次数を数えるだけ")
    print("• 構築: O(E) - 各エッジを1回ずつ訪問")

euler_theorem()
```

### 4-2. 定理の証明（アリによる）

```python
def proof_by_ant():
    """アリによるオイラーの定理の証明"""

    print("オイラーの定理の証明（アリによる）:")
    print("=" * 50)
    print()
    print("【必要条件の証明】オイラーサイクル → バランス")
    print("-" * 40)
    print("オイラーサイクルが存在すると仮定")
    print("→ 各ノードを訪問するとき:")
    print("  ・入ってくる（エッジを1本使用）")
    print("  ・出ていく（エッジを1本使用）")
    print("→ 入る回数 = 出る回数")
    print("→ 入次数 = 出次数")
    print("∴ グラフはバランスしている ✓")
    print()
    print("【十分条件の証明】バランス → オイラーサイクル")
    print("-" * 40)
    print("グラフがバランスしていると仮定")
    print("アリのアルゴリズム:")
    print("1. アリは任意のノードから歩き始める")
    print("2. バランスのため、開始ノード以外で行き止まりにならない")
    print("3. 必ず開始ノードに戻る（サイクル完成）")
    print("4. 未使用エッジがあれば、そこから再開")
    print("5. すべてのエッジを使うまで繰り返す")
    print("∴ オイラーサイクルが構築できる ✓")

proof_by_ant()
```

## 🎯 まとめ：今日学んだことを整理

### レベル1：基礎理解

- **バランスしたグラフ**: すべてのノードで入次数=出次数
- **オイラーサイクル**: すべてのエッジを1回ずつ通るサイクル
- バランス ⇔ オイラーサイクルの存在

### レベル2：アルゴリズム理解

- **アリのアルゴリズム**（Hierholzerのアルゴリズム）
- 開始ノードでしか行き止まりにならない
- サイクルを見つけて統合を繰り返す

### レベル3：実践的意義

- 線形時間O(E)で解ける
- ゲノムアセンブリへの直接応用
- De Bruijnグラフでのオイラーサイクル探索

## 🚀 次回予告

次回は、実際のゲノムアセンブリでの課題を学びます：

- **リード誤りの処理**
- **リピート配列の問題**
- **ペアエンドリードの活用**

「理想から現実へ」- 実際のゲノムプロジェクトの課題をお楽しみに！
