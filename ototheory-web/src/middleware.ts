import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const BOT_UA = /bot|crawl|spider|slurp|bingpreview|duckduckgo|baiduspider|yandex/i;

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // Pass-through for static assets and Next internals
  if (pathname.startsWith('/_next') || pathname.match(/\.[a-zA-Z0-9]+$/)) {
    return NextResponse.next();
  }

  // Already on JA path
  if (pathname.startsWith('/ja')) {
    return NextResponse.next();
  }

  // Do not redirect bots/crawlers
  const ua = req.headers.get('user-agent') || '';
  if (BOT_UA.test(ua)) return NextResponse.next();

  // One-time redirect for Japanese users
  const cookie = req.cookies.get('ot_locale')?.value;
  const accept = req.headers.get('accept-language') || '';
  const prefersJa = /^ja\b/i.test(accept);

  if (!cookie && prefersJa) {
    const url = req.nextUrl.clone();
    url.pathname = `/ja${pathname === '/' ? '' : pathname}`;
    const res = NextResponse.redirect(url, 307);
    res.cookies.set('ot_locale', 'ja', { maxAge: 60 * 60 * 24 * 365, path: '/', sameSite: 'lax' });
    return res;
  }
  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api/telemetry|_next/|.*\\..*).*)'],
};


