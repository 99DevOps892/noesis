/**
 * NOESIS — Dashboard Stats Module
 * Fetches aggregate statistics and health data.
 */
const Dashboard = (() => {
  let _interval = null;
  const Log = {
    info(msg) { console.log(`[NOESIS] ${msg}`); },
    warn(msg) { console.warn(`[NOESIS] ${msg}`); },
  };

  function init() {
    Log.info('Dashboard module initializing…');
    _fetchStats();
    _interval = setInterval(_fetchStats, APP_CONFIG.refreshIntervals.dashboard);
  }

  async function _fetchStats() {
    const client = db();
    if (!client) {
      _renderFallback();
      return;
    }

    try {
      // Total entries
      const { count: totalCount, error: totalErr } = await client
        .from(APP_CONFIG.tables.memory)
        .select('*', { count: 'exact', head: true });

      if (!totalErr) {
        document.getElementById('statTotal').textContent = Utils.formatNumber(totalCount);
      }

      // Embedding coverage
      const { count: embeddedCount, error: embErr } = await client
        .from(APP_CONFIG.tables.memory)
        .select('*', { count: 'exact', head: true })
        .not('embedding', 'is', null);

      if (!embErr && totalCount > 0) {
        const coverage = ((embeddedCount / totalCount) * 100).toFixed(1);
        document.getElementById('statEmbeddings').textContent = `${coverage}%`;
      }

      // Last refresh — most recent entry
      const { data: latest, error: latestErr } = await client
        .from(APP_CONFIG.tables.memory)
        .select('created_at')
        .order('created_at', { ascending: false })
        .limit(1);

      if (!latestErr && latest && latest.length > 0) {
        document.getElementById('statRefresh').textContent = Utils.timeAgo(latest[0].created_at);
      }

      Log.info('Stats updated');
    } catch (err) {
      console.warn('[Dashboard] Stats fetch failed:', err.message);
    }
  }

  function _renderFallback() {
    document.getElementById('statTotal').textContent = '—';
    document.getElementById('statEmbeddings').textContent = '—';
    document.getElementById('statRefresh').textContent = '—';
  }

  function destroy() {
    if (_interval) clearInterval(_interval);
  }

  return { init, destroy };
})();
