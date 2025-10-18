"use client";
import Link from "next/link";
import { ReactNode } from "react";
import styles from "./FeatureCard.module.css";

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
    <Link href={href} className={styles.featureCard}>
      <div className={styles.cardContent}>
        {/* Icon */}
        <div className={styles.iconContainer}>
          <div className={styles.icon}>
            {icon}
          </div>
        </div>

        {/* Content */}
        <div className={styles.content}>
          <h2 className={styles.title}>
            {title}
          </h2>
          
          <p className={styles.catchphrase}>
            {catchphrase}
          </p>

          <div className={styles.description}>
            {description.map((line, index) => (
              <p key={index} className={styles.descriptionLine}>
                {line}
              </p>
            ))}
          </div>
        </div>
      </div>
    </Link>
  );
}
