import { Metadata } from "next";

export const metadata: Metadata = {
  title: "プライバシーポリシー – OtoTheory",
  description: "OtoTheoryのプライバシーポリシー。個人情報の収集、使用、保護に関する方針を説明します。",
};

export default function PrivacyPage() {
  return (
    <div className="ot-page ot-stack">
      <h1 className="text-2xl font-semibold">プライバシーポリシー（OtoTheory）</h1>
      
      <section className="ot-card space-y-4">
        <div>
          <p><strong>事業者</strong>: TH Quest（神奈川県鎌倉市）</p>
          <p><strong>お問い合わせ</strong>: <a href="mailto:support@ototheory.com" className="underline">support@ototheory.com</a></p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">1. 収集するデータ</h2>
          <p className="text-sm leading-relaxed">
            連絡先（Apple Private Relayを含むメールアドレス）、識別子（ユーザー/デバイス）、
            アプリ内購入ステータス、使用イベント（例：progression_play、export_png）、
            診断情報（クラッシュ/パフォーマンス）、おおよその位置情報（IPから導出；正確な位置情報は含まず）、
            連絡先/写真/ファイルへのアクセスはありません。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">2. 使用目的</h2>
          <p className="text-sm leading-relaxed">
            アプリ機能の提供（同期、スケッチ、MIDI）、製品分析、カスタマーサポート、
            重要な通知の送信。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">3. 共有</h2>
          <p className="text-sm leading-relaxed">
            個人データの販売は行いません。ホスティング/CDNにVercelを使用しており、
            最小限の運用ログが処理される場合があります。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">4. 保持期間</h2>
          <p className="text-sm leading-relaxed">
            スケッチ：アカウント削除まで（削除後30日以内に完全削除）。
            ログ：90日間保持後、削除または匿名化。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">5. セキュリティ / 地域</h2>
          <p className="text-sm leading-relaxed">
            HTTPS、アクセス制御。データ地域：東京。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">6. お客様の権利</h2>
          <p className="text-sm leading-relaxed">
            アプリ内でアカウントを削除（設定 &gt; アカウント削除）するか、
            <a href="mailto:support@ototheory.com" className="underline">support@ototheory.com</a> までメールでお問い合わせください。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">7. 児童</h2>
          <p className="text-sm leading-relaxed">
            13歳未満の児童を対象としていません。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">8. 変更</h2>
          <p className="text-sm leading-relaxed">
            重要な変更はこちらでお知らせします。継続使用により承諾とみなします。
          </p>
        </div>

        <p className="text-xs opacity-70 mt-4">
          <strong>（最終更新：2025年10月3日）</strong>
        </p>
      </section>
    </div>
  );
}