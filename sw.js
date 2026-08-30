const CACHE_NAME = 'noesis-v1';
const STATIC_ASSETS = [
  '/noesis/app/index.html',
  '/noesis/app/css/style.css',
  '/noesis/app/js/config.js',
  '/noesis/app/js/supabase-client.js',
  '/noesis/app/js/knowledge.js',
  '/noesis/app/js/reasoning.js',
  '/noesis/app/js/dashboard.js',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(STATIC_ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  if (event.request.url.includes('supabase')) return;
  if (event.request.url.includes('127.0.0.1:11434')) return;

  event.respondWith(
    caches.match(event.request).then(cached => cached || fetch(event.request))
  );
});
