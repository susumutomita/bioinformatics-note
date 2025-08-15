import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Bioinformatics Note',
  tagline: 'バイオインフォマティクス講義ノート',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://susumutomita.github.io',
  baseUrl: '/bioinformatics-note/',

  organizationName: 'susumutomita',
  projectName: 'bioinformatics-note',

  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'ja',
    locales: ['ja'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          breadcrumbs: false,
          routeBasePath: '/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/docusaurus-social-card.jpg',
    navbar: {
      title: 'Bioinformatics Note',
      logo: {
        alt: 'Bioinformatics Note Logo',
        src: 'img/logo.svg',
        href: '/',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docs',
          position: 'left',
          label: 'ドキュメント',
        },
        {
          href: 'https://github.com/susumu/bioinformatics-note',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      copyright: `Copyright © ${new Date().getFullYear()} Bioinformatics Note`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
