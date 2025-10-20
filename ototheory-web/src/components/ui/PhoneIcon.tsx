interface PhoneIconProps {
  className?: string;
  size?: number | string;
}

export default function PhoneIcon({ className = 'w-4 h-4', size }: PhoneIconProps) {
  const sizeStyle = size ? { width: size, height: size } : undefined;
  
  return (
    <svg
      className={className}
      style={sizeStyle}
      fill="currentColor"
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      <path d="M7 2C5.9 2 5 2.9 5 4v16c0 1.1.9 2 2 2h10c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2H7zm0 2h10v12H7V4zm0 14h10v2H7v-2zm1-1h8v1H8v-1z"/>
    </svg>
  );
}


