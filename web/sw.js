const CACHE_NAME = 'notaia-offline-v2';
const CORE_ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './flutter_bootstrap.js',
  './favicon.png',
  './icons/Icon-192.png',
  './icons/Icon-512.png'
];

self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then(async (cache) => {
      try {
        await cache.addAll(CORE_ASSETS);
      } catch (e) {
        console.log('Error caching some core assets during install:', e);
      }
    })
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    Promise.all([
      self.clients.claim(),
      caches.keys().then((keys) => {
        return Promise.all(
          keys.map((key) => {
            if (key !== CACHE_NAME && !key.startsWith('flutter-app-manifest')) {
              return caches.delete(key);
            }
          })
        );
      })
    ])
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  const url = new URL(event.request.url);

  // Handle SPA Navigation requests (opening the app / reloading offline)
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request).catch(async () => {
        const cached = await caches.match('./index.html') || 
                       await caches.match('index.html') || 
                       await caches.match('./');
        if (cached) return cached;
        return new Response('NotaIA Offline', { headers: { 'Content-Type': 'text/html' } });
      })
    );
    return;
  }

  // Cache First, Network Fallback + Cache on the fly
  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      if (cachedResponse) {
        return cachedResponse;
      }

      return fetch(event.request).then((networkResponse) => {
        if (networkResponse && networkResponse.status === 200) {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
        }
        return networkResponse;
      }).catch(async () => {
        const fallback = await caches.match(event.request);
        if (fallback) return fallback;
        return new Response('', { status: 408, statusText: 'Offline' });
      });
    })
  );
});
