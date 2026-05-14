// ============================================================
// SERVICE WORKER — Proparts Training PWA
// Estratégia: Cache-First para assets estáticos
// ============================================================
const CACHE_NAME = 'proparts-training-v11';
const ASSETS_TO_CACHE = [
  './',
  './index.html',
  'https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=DM+Sans:wght@300;400;500;600&family=Barlow+Condensed:ital,wght@1,700;1,800&display=swap'
];

// ── INSTALL: cacheia os arquivos principais ──
self.addEventListener('install', (event) => {
  console.log('[SW] Instalando...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[SW] Cacheando arquivos principais');
        return cache.addAll(ASSETS_TO_CACHE);
      })
      .then(() => self.skipWaiting())
      .catch((err) => console.error('[SW] Erro no cache:', err))
  );
});

// ── ACTIVATE: limpa caches antigos ──
self.addEventListener('activate', (event) => {
  console.log('[SW] Ativando...');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME)
          .map((name) => {
            console.log('[SW] Removendo cache antigo:', name);
            return caches.delete(name);
          })
      );
    }).then(() => self.clients.claim())
  );
});

// ── FETCH: Cache-First, fallback para rede ──
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  // Nunca intercepta chamadas ao Google Sheets
  if (event.request.url.includes('script.google.com')) return;

  // Nunca intercepta chamadas ao Google Fonts (deixa a rede resolver)
  if (event.request.url.includes('fonts.googleapis.com') ||
      event.request.url.includes('fonts.gstatic.com')) return;

  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      if (cachedResponse) {
        // Atualiza o cache em background (stale-while-revalidate)
        fetch(event.request)
          .then((networkResponse) => {
            if (networkResponse && networkResponse.status === 200 && networkResponse.type !== 'opaque') {
              caches.open(CACHE_NAME).then((cache) => {
                cache.put(event.request, networkResponse.clone());
              });
            }
          })
          .catch(() => {});
        return cachedResponse;
      }

      // Não estava no cache — busca na rede e cacheia
      return fetch(event.request).then((networkResponse) => {
        if (!networkResponse || networkResponse.status !== 200 || networkResponse.type === 'opaque') {
          return networkResponse;
        }
        const responseToCache = networkResponse.clone();
        caches.open(CACHE_NAME).then((cache) => {
          cache.put(event.request, responseToCache);
        });
        return networkResponse;
      }).catch(() => {
        // Offline e não está em cache — retorna o HTML principal como fallback
        if (event.request.destination === 'document') {
          return caches.match('./');
        }
      });
    })
  );
});
