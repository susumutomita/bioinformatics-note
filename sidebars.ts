import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docs: [
    'intro',
    {
      type: 'category',
      label: '🧬 基礎知識',
      collapsed: false,
      items: [
        'basics/biology-fundamentals',
        'basics/bioinformatics-vs-synthetic-biology',
        'basics/what-is-mrna',
      ],
    },
    {
      type: 'category',
      label: '📚 講義',
      collapsed: false,
      items: [
        {
          type: 'category',
          label: 'Week 1: DNA複製',
          items: [
            'lectures/week1/dna-replication-part1',
            'lectures/week1/dna-replication-part1-detailed',
            'lectures/week1/dna-replication-part2',
            'lectures/week1/dna-replication-part3',
            'lectures/week1/dna-replication-part4',
          ],
        },
        {
          type: 'category',
          label: 'Week 2: モチーフ発見',
          items: [
            'lectures/week2/motif-finding-part1',
            'lectures/week2/motif-finding-part1-detailed',
            'lectures/week2/randomized-motif-search-detailed',
            'lectures/week2/gibbs-sampler-detailed',
            'lectures/week2/laplace-and-chip-seq-detailed',
            'lectures/week2/understanding-motif-and-drug-discovery',
            'lectures/week2/motif-finding-part2',
            'lectures/week2/motif-finding-part3',
            'lectures/week2/quiz-week3',
          ],
        },
        {
          type: 'category',
          label: 'Week 3: ゲノムアセンブリ',
          items: [
            'lectures/week3/genome-sequencing-intro',
            'lectures/week3/genome-assembly-intro',
            'lectures/week3/genome-assembly-euler',
          ],
        },
      ],
    },
    {
      type: 'category',
      label: '🔧 アルゴリズム',
      collapsed: false,
      items: [
        'algorithms/frequent-words',
        'algorithms/gc-skew',
        'algorithms/frequent-words-mismatches',
      ],
    },
    {
      type: 'category',
      label: '🚀 先端技術',
      collapsed: false,
      items: [
        'advanced/state-and-ai-in-biology',
        'advanced/mrna-vaccine-development',
        'advanced/drug-discovery-limits-and-synthetic-biology',
      ],
    },
    {
      type: 'category',
      label: '📖 参考資料',
      collapsed: true,
      items: ['resources/glossary'],
    },
  ],
};

export default sidebars;
