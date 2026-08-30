/**
 * NOESIS — Knowledge Base Module
 * Browse, search, and filter knowledge entries from agent_memory.
 */
const Knowledge = (() => {
  let _entries = [];
  let _offset = 0;
  const PAGE_SIZE = 20;
  let _currentNamespace = 'all';
  let _namespaceCounts = {};

  function init() {
    Log.info('Knowledge base module initializing…');
    _bindControls();
    _renderNamespaceChips();
    _fetchEntries();
    _fetchCounts();
  }

  async function _fetchEntries(reset = false) {
    const client = db();
    if (!client) {
      _renderFallback();
      return;
    }

    if (reset) {
      _entries = [];
      _offset = 0;
    }

    try {
      let query = client
        .from(APP_CONFIG.tables.memory)
        .select('*')
        .order('created_at', { ascending: false })
        .order('importance', { ascending: false })
        .range(_offset, _offset + PAGE_SIZE - 1);

      if (_currentNamespace !== 'all') {
        query = query.eq('namespace', _currentNamespace);
      }

      const { data, error } = await query;
      if (error) throw error;

      if (data) {
        if (reset) {
          _entries = data;
        } else {
          _entries = [..._entries, ...data];
        }
        _offset += data.length;
        _renderEntries();
        _renderRecent();
        _updateEntryCount(data.length);
        Log.info(`Loaded ${_entries.length} knowledge entries`);
      }
    } catch (err) {
      console.warn('[Knowledge] Fetch failed:', err.message);
      _renderFallback();
    }
  }

  async function _fetchCounts() {
    const client = db();
    if (!client) return;

    const counts = {};
    for (const ns of APP_CONFIG.namespaces) {
      try {
        const { count, error } = await client
          .from(APP_CONFIG.tables.memory)
          .select('*', { count: 'exact', head: true })
          .eq('namespace', ns.id);

        if (!error) counts[ns.id] = count || 0;
      } catch {
        counts[ns.id] = 0;
      }
    }

    _namespaceCounts = counts;
    _renderNamespaceChips();
    _updateTotalCount();
  }

  function _renderNamespaceChips() {
    const container = document.getElementById('namespaceChips');
    if (!container) return;

    container.innerHTML = APP_CONFIG.namespaces.map(ns => {
      const count = _namespaceCounts[ns.id] || 0;
      const active = _currentNamespace === ns.id ? 'namespace-chip--active' : '';
      return `<button class="namespace-chip ${active}" data-ns="${ns.id}">
        ${ns.id} <span class="namespace-chip__count">${count}</span>
      </button>`;
    }).join('');

    container.querySelectorAll('.namespace-chip').forEach(chip => {
      chip.addEventListener('click', () => {
        _currentNamespace = chip.dataset.ns;
        _renderNamespaceChips();
        document.getElementById('namespaceFilter').value = _currentNamespace;
        _fetchEntries(true);
      });
    });
  }

  function _renderEntries() {
    const container = document.getElementById('knowledgeList');
    if (!container) return;

    if (_entries.length === 0) {
      container.innerHTML = '<p class="knowledge-list__empty">No knowledge entries found</p>';
      return;
    }

    container.innerHTML = _entries.map(e => {
      const ns = e.namespace || 'default';
      const content = _extractTitle(e.content);
      const excerpt = _extractExcerpt(e.content);
      const importance = e.importance != null ? `${Math.round(e.importance * 100)}%` : '—';
      const accessCount = e.access_count || 0;

      return `<div class="knowledge-entry">
        <span class="knowledge-entry__ns knowledge-entry__ns--${ns}">${Utils.esc(ns)}</span>
        <div class="knowledge-entry__body">
          <div class="knowledge-entry__title">${Utils.esc(content)}</div>
          <div class="knowledge-entry__excerpt">${Utils.esc(excerpt)}</div>
          <div class="knowledge-entry__meta">
            <span>importance: ${importance}</span>
            <span>accesses: ${accessCount}</span>
            <span>${Utils.timeAgo(e.created_at)}</span>
          </div>
        </div>
      </div>`;
    }).join('');
  }

  function _renderRecent() {
    const container = document.getElementById('recentEntries');
    if (!container) return;

    const recent = _entries.slice(0, 10);
    if (recent.length === 0) {
      container.innerHTML = '<p class="recent-entries__empty">No recent entries</p>';
      return;
    }

    container.innerHTML = recent.map(e => {
      const ns = e.namespace || 'default';
      const title = _extractTitle(e.content);
      const importance = e.importance != null ? `${Math.round(e.importance * 100)}%` : '—';

      return `<div class="recent-entry">
        <span class="recent-entry__time">${Utils.formatDateTime(e.created_at)}</span>
        <span class="recent-entry__ns">${Utils.esc(ns)}</span>
        <span class="recent-entry__title">${Utils.esc(title)}</span>
        <span class="recent-entry__importance">${importance}</span>
      </div>`;
    }).join('');
  }

  function _renderFallback() {
    const container = document.getElementById('knowledgeList');
    if (container) {
      container.innerHTML = '<p class="knowledge-list__empty">Unable to connect to knowledge base. Ensure Supabase is configured.</p>';
    }
  }

  function _extractTitle(content) {
    if (!content) return 'Untitled';
    if (typeof content === 'string') {
      try { content = JSON.parse(content); } catch { return content.substring(0, 100); }
    }
    return content.title || content.name || content.summary || content.key || JSON.stringify(content).substring(0, 80);
  }

  function _extractExcerpt(content) {
    if (!content) return '';
    if (typeof content === 'string') {
      try { content = JSON.parse(content); } catch { return content.substring(0, 150); }
    }
    const str = JSON.stringify(content);
    return str.length > 150 ? str.substring(0, 147) + '…' : str;
  }

  function _updateEntryCount(lastPageCount) {
    const el = document.getElementById('entryCount');
    if (el) {
      el.textContent = `Showing ${_entries.length} entries`;
    }
  }

  function _updateTotalCount() {
    const total = Object.values(_namespaceCounts).reduce((a, b) => a + b, 0);
    document.getElementById('statTotal').textContent = Utils.formatNumber(total);
  }

  function _bindControls() {
    const nsFilter = document.getElementById('namespaceFilter');
    if (nsFilter) {
      nsFilter.addEventListener('change', (e) => {
        _currentNamespace = e.target.value;
        _renderNamespaceChips();
        _fetchEntries(true);
      });
    }

    const loadMore = document.getElementById('loadMoreBtn');
    if (loadMore) {
      loadMore.addEventListener('click', () => _fetchEntries(false));
    }

    const searchBtn = document.getElementById('ragSearchBtn');
    const searchInput = document.getElementById('ragQuery');
    if (searchBtn && searchInput) {
      searchBtn.addEventListener('click', _performSearch);
      searchInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') _performSearch();
      });
    }
  }

  async function _performSearch() {
    const query = document.getElementById('ragQuery').value.trim();
    const namespace = document.getElementById('ragNamespace').value;
    const container = document.getElementById('ragResults');
    if (!query || !container) return;

    container.innerHTML = '<p class="search-results__empty">Searching…</p>';

    const client = db();
    if (!client) {
      container.innerHTML = '<p class="search-results__empty">Supabase not configured</p>';
      return;
    }

    try {
      let rpcArgs = {
        search_query: query,
        max_results: APP_CONFIG.search.maxResults,
      };
      if (namespace) rpcArgs.search_namespace = namespace;

      const { data, error } = await client.rpc('search_knowledge', rpcArgs);

      if (error) {
        // Fallback: client-side text search
        const { data: fallback, error: fbErr } = await client
          .from(APP_CONFIG.tables.memory)
          .select('*')
          .order('importance', { ascending: false })
          .limit(APP_CONFIG.search.maxResults);

        if (fbErr) throw fbErr;

        const queryLower = query.toLowerCase();
        const filtered = (fallback || []).filter(e => {
          const text = JSON.stringify(e.content || '').toLowerCase();
          const nsMatch = namespace ? e.namespace === namespace : true;
          return nsMatch && text.includes(queryLower);
        });

        _renderSearchResults(container, filtered, query);
        return;
      }

      _renderSearchResults(container, data || [], query);
    } catch (err) {
      container.innerHTML = `<p class="search-results__empty">Search failed: ${Utils.esc(err.message)}</p>`;
    }
  }

  function _renderSearchResults(container, results, query) {
    if (results.length === 0) {
      container.innerHTML = '<p class="search-results__empty">No results found</p>';
      return;
    }

    container.innerHTML = results.map(r => {
      const ns = r.namespace || 'default';
      const title = _extractTitle(r.content);
      const content = _extractExcerpt(r.content);
      const confidence = r.relevance_score != null ? `${Math.round(r.relevance_score * 100)}%` : '—';

      return `<div class="search-result">
        <div class="search-result__header">
          <span class="search-result__ns">${Utils.esc(ns)}</span>
          <span class="search-result__score">relevance: ${confidence}</span>
        </div>
        <div class="search-result__content">${Utils.esc(content)}</div>
      </div>`;
    }).join('');
  }

  async function searchKnowledge(query, namespace) {
    const client = db();
    if (!client) return [];

    try {
      const { data, error } = await client
        .from(APP_CONFIG.tables.memory)
        .select('*')
        .order('importance', { ascending: false })
        .limit(10);

      if (error) throw error;

      const queryLower = (query || '').toLowerCase();
      return (data || []).filter(e => {
        const text = JSON.stringify(e.content || '').toLowerCase();
        const nsMatch = namespace ? e.namespace === namespace : true;
        return nsMatch && text.includes(queryLower);
      });
    } catch {
      return [];
    }
  }

  return { init, searchKnowledge };
})();
