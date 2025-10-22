import { Metadata } from "next";

export const metadata: Metadata = {
  title: "よくある質問 – OtoTheory",
  description: "OtoTheoryのよくある質問と回答。サブスクリプション、アカウント、機能、サポートに関する疑問を解決します。",
};

export default function FaqPage() {
  const faqs = [
    {
      question: "サブスクリプションをキャンセルするには？",
      answer: "Apple ID > サブスクリプション > OtoTheoryに移動してキャンセルしてください。サブスクリプションは現在の請求期間の終了まで有効です。"
    },
    {
      question: "アカウントを削除するには？",
      answer: "アプリ内で設定 > アカウント削除に移動してください。アカウントとすべてのクラウドデータは30日以内に完全に削除されます。"
    },
    {
      question: "データはどのくらいの期間保持されますか？",
      answer: "スケッチはアカウントを削除するまで保持されます。使用ログと診断データは90日間保持された後、削除または匿名化されます。"
    },
    {
      question: "「Shaped」と「Sounding」の違いは何ですか？",
      answer: "「Sounding」は実際に聞こえる音程を表示します。「Shaped」はカポを使ったコードの形を表示します。例えば、カポ3では、Amの形がCmとして聞こえます。"
    },
    {
      question: "コード進行をエクスポートできますか？",
      answer: "はい！PNG画像としてエクスポートできます。Proユーザーは、コード記号、マーカー、ガイドトーン付きのMIDIファイルもエクスポートできます。"
    },
    {
      question: "7日間無料トライアルには何が含まれますか？",
      answer: "無料トライアルでは、すべてのPro機能にフルアクセスできます：無制限クラウド保存、MIDIエクスポート、セクション編集。トライアル期間中はいつでもキャンセル可能です。"
    },
    {
      question: "キー検出はどのように行われますか？",
      answer: "当社のアルゴリズムは、録音のピッチクラスプロファイル（PCP）を分析し、相関スコアリングを使用してメジャーとマイナーのキーテンプレートと比較します。"
    },
    {
      question: "なぜカポを使うのですか？",
      answer: "カポは以下の点で役立ちます：ボーカルレンジの調整、より豊かな音のためにオープンストリングを多く使用、コードの形をより簡単に演奏。C、G、D、A、Eなどのキーはギターに適しています。"
    },
    {
      question: "OtoTheoryをオフラインで使用できますか？",
      answer: "はい！コア機能はオフラインで動作します。クラウド同期とアカウント機能にはインターネット接続が必要です。"
    },
    {
      question: "サポートに連絡するには？",
      answer: "support@ototheory.comまでメールをお送りください。通常2営業日以内に回答いたします。"
    }
  ];

  return (
    <div className="ot-page ot-stack">
      <h1 className="text-2xl font-semibold">よくある質問</h1>
      
      <section className="space-y-4">
        {faqs.map((faq, index) => (
          <div key={index} className="ot-card">
            <h2 className="font-semibold mb-2">{faq.question}</h2>
            <p className="text-sm leading-relaxed opacity-90">{faq.answer}</p>
          </div>
        ))}
      </section>

      <div className="ot-card text-center">
        <p className="text-sm mb-2">他に質問がありますか？</p>
        <a 
          href="mailto:support@ototheory.com" 
          className="text-sm underline hover:no-underline"
        >
          support@ototheory.comまでお問い合わせください
        </a>
      </div>
    </div>
  );
}