/** @type {import('next').NextConfig} */
const nextConfig = {
  eslint: {
    // ビルド時にESLintエラーをチェック
    ignoreDuringBuilds: false,
  },
  typescript: {
    // ビルド時にTypeScriptエラーをチェック
    ignoreBuildErrors: false,
  },
  async redirects() {
    return [
      // Reference → Resources migration (301 permanent redirects for SEO)
      {
        source: '/reference',
        destination: '/resources',
        permanent: true,
      },
      {
        source: '/reference/guitarist',
        destination: '/resources/music-theory',
        permanent: true,
      },
      {
        source: '/reference/chords',
        destination: '/resources/chord-library',
        permanent: true,
      },
      // Resources Learn Section redirects
      {
        source: '/resources/glossary',
        destination: '/resources/learn/intervals',
        permanent: true,
      },
      {
        source: '/resources/music-theory',
        destination: '/resources/learn/theory-intro',
        permanent: true,
      },
      {
        source: '/ja/resources/glossary',
        destination: '/ja/resources/learn/intervals',
        permanent: true,
      },
      {
        source: '/ja/resources/music-theory',
        destination: '/ja/resources/learn/theory-intro',
        permanent: true,
      },
      // Legacy URL redirects
      {
        source: '/find-key',
        destination: '/chord-progression',
        permanent: true,
      },
      {
        source: '/progression',
        destination: '/chord-progression',
        permanent: true,
      },
      {
        source: '/analyze',
        destination: '/chord-progression',
        permanent: true,
      },
    ];
  },
};

module.exports = nextConfig;
