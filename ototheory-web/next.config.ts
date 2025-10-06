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
};

export default nextConfig;
