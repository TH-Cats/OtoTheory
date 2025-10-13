"use client";
import { useEffect, useState } from "react";

export default function UpdatedBadge({ since }:{ since:number }){
  const [visible, setVisible] = useState(false);
  useEffect(()=>{
    if(!since) return;
    setVisible(true);
    const t = setTimeout(()=> setVisible(false), 1500);
    return ()=> clearTimeout(t);
  }, [since]);
  if (!visible) return null;
  return <span className="ot-badge ot-badge-upd">Updated</span>;
}






