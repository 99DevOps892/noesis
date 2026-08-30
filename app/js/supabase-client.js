/**
 * NOESIS — Supabase Client
 * Singleton client instance for all Supabase operations.
 */
const SupabaseClient = (() => {
  let _client = null;

  function getClient() {
    if (_client) return _client;
    if (typeof supabase === 'undefined' || !supabase.createClient) {
      console.error('[SupabaseClient] Supabase JS library not loaded');
      return null;
    }
    _client = supabase.createClient(
      APP_CONFIG.supabase.url,
      APP_CONFIG.supabase.anonKey,
      {
        auth: {
          autoRefreshToken: true,
          persistSession: true,
          detectSessionInUrl: true,
          flowType: 'pkce',
        },
        realtime: {
          params: { eventsPerSecond: 10 },
        },
      }
    );
    return _client;
  }

  function reset() {
    _client = null;
  }

  return { getClient, reset };
})();

const db = () => SupabaseClient.getClient();
const auth = () => SupabaseClient.getClient()?.auth;

const Clock = {
  _interval: null,

  init() {
    this.update();
    this._interval = setInterval(() => this.update(), APP_CONFIG.refreshIntervals.clock);
  },

  update() {
    const el = document.getElementById('clock');
    if (el) {
      el.textContent = new Date().toLocaleTimeString('en-GB', { hour12: false });
    }
  },

  destroy() {
    if (this._interval) clearInterval(this._interval);
  },
};

const Toast = {
  show(message, type = 'info') {
    const existing = document.querySelector('.toast-notification');
    if (existing) existing.remove();

    const toast = document.createElement('div');
    toast.className = `toast-notification toast-notification--${type}`;
    toast.textContent = message;
    toast.style.cssText = `
      position: fixed; top: 1rem; right: 1rem; z-index: 9999;
      padding: 0.6rem 1rem; border-radius: 6px; font-size: 0.8rem;
      color: #fff; max-width: 360px; box-shadow: 0 4px 12px rgba(0,0,0,0.2);
      ${type === 'error' ? 'background: #cf222e;' :
        type === 'success' ? 'background: #1a7f37;' :
        type === 'warn' ? 'background: #9a6700;' :
        'background: #0969da;'}
    `;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), APP_CONFIG.toast.duration);
  },
};

const Utils = {
  timeAgo(date) {
    if (!date) return '—';
    const seconds = Math.floor((Date.now() - new Date(date).getTime()) / 1000);
    if (seconds < 60) return `${seconds}s ago`;
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}m ago`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours}h ago`;
    const days = Math.floor(hours / 24);
    return `${days}d ago`;
  },

  formatNumber(n) {
    if (n === null || n === undefined) return '—';
    return n.toLocaleString('en-US');
  },

  formatDate(date) {
    if (!date) return '—';
    return new Date(date).toLocaleDateString('en-GB', {
      day: 'numeric', month: 'short', year: 'numeric',
    });
  },

  formatDateTime(date) {
    if (!date) return '—';
    return new Date(date).toLocaleString('en-GB', {
      day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit',
    });
  },

  esc(str) {
    if (!str) return '';
    const d = document.createElement('div');
    d.textContent = str;
    return d.innerHTML;
  },
};

const Log = {
  _container: null,

  init() {
    this._container = document.getElementById('activityLog');
  },

  info(msg) {
    console.log(`[NOESIS] ${msg}`);
  },

  warn(msg) {
    console.warn(`[NOESIS] ${msg}`);
  },

  error(msg) {
    console.error(`[NOESIS] ${msg}`);
  },

  entry(msg, type = 'system') {
    if (!this._container) this.init();
    if (!this._container) return;
    const time = new Date().toLocaleTimeString('en-GB', { hour12: false });
    const el = document.createElement('div');
    el.className = `activity-log__entry activity-log__entry--${type}`;
    el.innerHTML = `<span class="activity-log__time">[${time}]</span> <span class="activity-log__msg">${Utils.esc(msg)}</span>`;
    this._container.prepend(el);
    while (this._container.children.length > 50) {
      this._container.lastChild.remove();
    }
  },
};
