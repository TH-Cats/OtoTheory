import { APPLE_ICON_PATH } from '@/lib/constants/cta';

interface AppleIconProps {
  className?: string;
  size?: number | string;
}

export default function AppleIcon({ className = 'w-4 h-4', size }: AppleIconProps) {
  const sizeStyle = size ? { width: size, height: size } : undefined;
  
  return (
    <svg
      className={className}
      style={sizeStyle}
      fill="currentColor"
      viewBox="0 0 384 512"
      aria-hidden="true"
    >
      <path d={APPLE_ICON_PATH} />
    </svg>
  );
}

