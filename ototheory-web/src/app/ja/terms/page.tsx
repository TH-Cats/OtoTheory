import { Metadata } from "next";

export const metadata: Metadata = {
  title: "利用規約 – OtoTheory",
  description: "OtoTheoryの利用規約。サービス利用に関する条件、権利、義務を説明します。",
};

export default function TermsPage() {
  return (
    <div className="ot-page ot-stack">
      <h1 className="text-2xl font-semibold">利用規約（OtoTheory）</h1>
      
      <section className="ot-card space-y-6">
        <p className="text-sm leading-relaxed">
          TH Questが提供するOtoTheory（Web/iOS）をご利用いただくことで、本規約に同意していただいたものとみなします。
        </p>

        <div>
          <h2 className="text-lg font-semibold mb-2">サービス提供者</h2>
          <p className="text-sm leading-relaxed">
            <strong>TH Quest</strong><br />
            所在地：神奈川県鎌倉市<br />
            お問い合わせ：<a href="mailto:support@ototheory.com" className="underline">support@ototheory.com</a>
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">利用資格</h2>
          <p className="text-sm leading-relaxed">
            本サービスをご利用いただくには、13歳以上である必要があります。iOSアプリユーザーは「Apple IDでサインイン」が必要です。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">サブスクリプション</h2>
          <ul className="list-disc pl-5 text-sm leading-relaxed space-y-1">
            <li><strong>料金</strong>：Proサブスクリプション月額¥490（地域により価格が異なる場合があります）</li>
            <li><strong>自動更新</strong>：現在の期間終了の24時間前にキャンセルしない限り、サブスクリプションは自動的に更新されます</li>
            <li><strong>無料トライアル</strong>：新規登録者向けに7日間の無料トライアルをご利用いただけます</li>
            <li><strong>キャンセル</strong>：Apple ID &gt; サブスクリプション &gt; OtoTheoryからいつでもキャンセル可能</li>
            <li><strong>返金</strong>：返金リクエストはAppleの返金ポリシーに従います</li>
          </ul>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">出力物の権利</h2>
          <p className="text-sm leading-relaxed">
            OtoTheoryからエクスポートしたPNG画像とMIDIファイルは、ユーザーであるお客様のものです。ただし、使用する第三者コンテンツが適用される著作権法およびライセンス法に準拠していることを確認する責任はお客様にあります。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">禁止行為</h2>
          <p className="text-sm leading-relaxed mb-2">以下の行為を禁止します：</p>
          <ul className="list-disc pl-5 text-sm leading-relaxed space-y-1">
            <li>ソフトウェアのリバースエンジニアリング、逆コンパイル、または逆アセンブル</li>
            <li>当社のシステムまたは他のユーザーのアカウントへの不正アクセスの試行</li>
            <li>違法、虐待的、または有害な行為への従事</li>
            <li>他人の知的財産権の侵害</li>
          </ul>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">保証の免責</h2>
          <p className="text-sm leading-relaxed">
            OtoTheoryは「現状のまま」提供され、明示または黙示を問わず、いかなる保証もありません。サービスが中断されない、エラーがない、またはお客様の特定の要件を満たすことを保証しません。OtoTheoryで生成された出力物の商用利用は、お客様自身のリスクと責任で行ってください。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">責任の制限</h2>
          <p className="text-sm leading-relaxed">
            法律で許可される最大限の範囲で、TH Questは、OtoTheoryのご利用に起因する間接的、偶発的、特別、結果的、または懲罰的損害について一切の責任を負いません。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">サービスの変更と終了</h2>
          <p className="text-sm leading-relaxed">
            当社は、いつでも機能を追加、変更、停止、または廃止する場合があります。重要な変更は本サイトでお知らせします。本規約に違反するアカウントを終了する権利を留保します。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">アカウント削除</h2>
          <p className="text-sm leading-relaxed">
            アプリ内の設定 &gt; アカウント削除から、または<a href="mailto:support@ototheory.com" className="underline">support@ototheory.com</a>までメールでお問い合わせいただくことで、いつでもアカウントを削除できます。
            クラウドに保存されたすべてのデータは、削除から30日以内に完全に削除されます。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">準拠法と管轄</h2>
          <p className="text-sm leading-relaxed">
            本規約は日本法に準拠します。本規約またはOtoTheoryのご利用に起因する紛争は、横浜地方裁判所の専属的管轄に服します。
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">規約の変更</h2>
          <p className="text-sm leading-relaxed">
            当社は、本規約を随時更新する場合があります。重要な変更は本ページでお知らせします。変更の掲載後もOtoTheoryを継続してご利用いただくことで、更新された規約に同意していただいたものとみなします。
          </p>
        </div>

        <p className="text-xs opacity-70 mt-6 pt-4 border-t border-black/10 dark:border-white/10">
          <strong>（最終更新：2025年10月3日）</strong>
        </p>
      </section>
    </div>
  );
}