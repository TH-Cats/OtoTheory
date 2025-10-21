import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const BOT_UA = /bot|crawl|spider|slurp|bingpreview|duckduckgo|baiduspider|yandex/i;

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // Pass-through for static assets and Next internals
  if (pathname.startsWith('/_next') || pathname.match(/\.[a-zA-Z0-9]+$/)) {
    const response = NextResponse.next();
    response.headers.set('x-pathname', pathname);
    return response;
  }

  // Already on JA path
  if (pathname.startsWith('/ja')) {
    const response = NextResponse.next();
    response.headers.set('x-pathname', pathname);
    return response;
  }

  // Do not redirect bots/crawlers
  const ua = req.headers.get('user-agent') || '';
  if (BOT_UA.test(ua)) {
    const response = NextResponse.next();
    response.headers.set('x-pathname', pathname);
    return response;
  }

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
  const response = NextResponse.next();
  response.headers.set('x-pathname', pathname);
  return response;
}

export const config = {
  matcher: ['/((?!api/telemetry|_next/|.*\\..*).*)'],
};



