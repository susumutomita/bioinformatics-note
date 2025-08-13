import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docs: [
    'intro',
    {
      type: 'category',
      label: '基礎知識',
      items: ['tutorial-basics/create-a-document'],
    },
    {
      type: 'category',
      label: '応用',
      items: ['tutorial-extras/manage-docs-versions'],
    },
  ],
};

export default sidebars;
