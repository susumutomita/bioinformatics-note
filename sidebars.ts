import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docs: [
    'intro',
    {
      type: 'category',
      label: '📚 講義',
      collapsed: false,
      items: [
        {
          type: 'category',
          label: 'Week 1: DNA複製',
          items: ['lectures/week1/dna-replication-part1', 'lectures/week1/dna-replication-part2'],
        },
      ],
    },
    {
      type: 'category',
      label: '🔧 アルゴリズム',
      collapsed: false,
      items: ['algorithms/frequent-words'],
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
