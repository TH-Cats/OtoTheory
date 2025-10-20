#!/usr/bin/env node

/**
 * Vercel設定確認スクリプト
 * 
 * このスクリプトは、Vercelの設定情報を確認するために使用します。
 * 実行前に、Vercel CLIがインストールされていることを確認してください。
 * 
 * インストール方法:
 * npm install -g vercel
 * 
 * 使用方法:
 * 1. vercel login でログイン
 * 2. node scripts/check-vercel-config.js を実行
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🔍 Vercel設定情報を確認中...\n');

try {
  // Vercel CLIがインストールされているかチェック
  execSync('vercel --version', { stdio: 'pipe' });
  console.log('✅ Vercel CLI がインストールされています');
} catch (error) {
  console.log('❌ Vercel CLI がインストールされていません');
  console.log('以下のコマンドでインストールしてください:');
  console.log('npm install -g vercel');
  process.exit(1);
}

try {
  // ログイン状態をチェック
  execSync('vercel whoami', { stdio: 'pipe' });
  console.log('✅ Vercelにログイン済みです');
} catch (error) {
  console.log('❌ Vercelにログインしていません');
  console.log('以下のコマンドでログインしてください:');
  console.log('vercel login');
  process.exit(1);
}

// プロジェクトディレクトリに移動
const projectDir = path.join(__dirname, '../ototheory-web');
if (!fs.existsSync(projectDir)) {
  console.log('❌ ototheory-web ディレクトリが見つかりません');
  process.exit(1);
}

process.chdir(projectDir);

try {
  // プロジェクト情報を取得
  console.log('\n📋 プロジェクト情報:');
  const projectInfo = execSync('vercel project ls', { encoding: 'utf8' });
  console.log(projectInfo);
  
  // 設定ファイルを確認
  console.log('\n📁 設定ファイル:');
  const vercelJsonPath = path.join(projectDir, 'vercel.json');
  if (fs.existsSync(vercelJsonPath)) {
    const vercelConfig = JSON.parse(fs.readFileSync(vercelJsonPath, 'utf8'));
    console.log('vercel.json:', JSON.stringify(vercelConfig, null, 2));
  } else {
    console.log('vercel.json が見つかりません');
  }
  
  console.log('\n✅ 設定確認完了');
  console.log('\n📝 次のステップ:');
  console.log('1. Vercelダッシュボードでトークンを作成');
  console.log('2. GitHubリポジトリのSecretsに設定を追加');
  console.log('3. GitHub Actionsワークフローを実行');
  
} catch (error) {
  console.log('❌ エラーが発生しました:', error.message);
  console.log('\n💡 解決方法:');
  console.log('1. vercel login でログインし直してください');
  console.log('2. vercel link でプロジェクトをリンクしてください');
}
