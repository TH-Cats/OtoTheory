import { 
  Music, 
  Zap, 
  Palette, 
  Heart, 
  Hexagon, 
  Star,
  type LucideIcon 
} from 'lucide-react';

export type ScaleCategory = 'Basic' | 'Modes' | 'Pentatonic & Blues' | 'Minor family' | 'Symmetrical' | 'Advanced';

export interface CategoryIconInfo {
  icon: LucideIcon;
  color: string;
  bgColor: string;
}

export const SCALE_CATEGORY_ICONS: Record<ScaleCategory, CategoryIconInfo> = {
  'Basic': {
    icon: Music,
    color: 'text-blue-600',
    bgColor: 'bg-blue-50'
  },
  'Modes': {
    icon: Zap,
    color: 'text-purple-600',
    bgColor: 'bg-purple-50'
  },
  'Pentatonic & Blues': {
    icon: Palette,
    color: 'text-orange-600',
    bgColor: 'bg-orange-50'
  },
  'Minor family': {
    icon: Heart,
    color: 'text-red-600',
    bgColor: 'bg-red-50'
  },
  'Symmetrical': {
    icon: Hexagon,
    color: 'text-green-600',
    bgColor: 'bg-green-50'
  },
  'Advanced': {
    icon: Star,
    color: 'text-indigo-600',
    bgColor: 'bg-indigo-50'
  }
};

export function getCategoryIcon(category: ScaleCategory): CategoryIconInfo {
  return SCALE_CATEGORY_ICONS[category];
}

export function getAllCategories(): ScaleCategory[] {
  return Object.keys(SCALE_CATEGORY_ICONS) as ScaleCategory[];
}
