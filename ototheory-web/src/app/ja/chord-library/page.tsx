import { redirect } from "next/navigation";

export default function Page() {
  // 一時対応: JP版は改修完了までEN版へ誘導
  redirect("/chord-library");
}


