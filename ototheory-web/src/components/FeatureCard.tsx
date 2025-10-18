"use client";
import Link from "next/link";
import { ReactNode } from "react";

interface FeatureCardProps {
  href: string;
  icon: ReactNode;
  title: string;
  catchphrase: string;
  description: string[];
}

export default function FeatureCard({ 
  href, 
  icon, 
  title, 
  catchphrase, 
  description 
}: FeatureCardProps) {
  return (
    <Link 
      href={href} 
      className="group ot-card hover:bg-black/5 dark:hover:bg-white/5 transition-all duration-300 hover:shadow-lg hover:scale-[1.02] border border-transparent hover:border-gradient-to-r hover:from-brand-primary/20 hover:to-brand-secondary/20"
    >
      <div className="flex items-start gap-4">
        {/* Icon */}
        <div className="flex-shrink-0 w-12 h-12 rounded-xl bg-gradient-to-br from-brand-primary/10 to-brand-secondary/10 flex items-center justify-center group-hover:from-brand-primary/20 group-hover:to-brand-secondary/20 transition-all duration-300">
          <div className="w-6 h-6 text-brand-primary group-hover:text-brand-secondary transition-colors duration-300">
            {icon}
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <h2 className="font-semibold mb-2 text-lg group-hover:text-brand-primary transition-colors duration-300">
            {title}
          </h2>
          
          <div className="mb-3">
            <p className="text-sm font-medium text-brand-secondary group-hover:text-brand-primary transition-colors duration-300">
              {catchphrase}
            </p>
          </div>

          <div className="space-y-1">
            {description.map((line, index) => (
              <p key={index} className="text-sm opacity-80 leading-relaxed">
                {line}
              </p>
            ))}
          </div>
        </div>
      </div>
    </Link>
  );
}
