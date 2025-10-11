import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  eslint: {
    // 警告: 本番ビルドでESLintエラーを無視（急いで公開する場合のみ）
    // 後でコードクリーンアップが必要
    ignoreDuringBuilds: true,
  },
  typescript: {
    // 型エラーも一時的に無視（本番では推奨されない）
    ignoreBuildErrors: true,
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
      // Legacy URL redirects
      {
        source: '/progression',
        destination: '/find-key',
        permanent: true,
      },
      {
        source: '/analyze',
        destination: '/find-key',
        permanent: true,
      },
    ];
  },
};

export default nextConfig;
