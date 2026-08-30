/**
 * NOESIS — Syllogistic Reasoning Module
 * Performs structured reasoning with premise input and conclusion output.
 */
const Reasoning = (() => {
  let _outputEl = null;

  function init() {
    _outputEl = document.getElementById('reasoningOutput');
    _bindControls();
    Log.info('Reasoning module initialized');
  }

  function _bindControls() {
    const reasonBtn = document.getElementById('reasonBtn');
    if (reasonBtn) {
      reasonBtn.addEventListener('click', _performReasoning);
    }

    const exampleBtn = document.getElementById('loadExampleBtn');
    if (exampleBtn) {
      exampleBtn.addEventListener('click', _loadExample);
    }
  }

  function _loadExample() {
    document.getElementById('majorPremise').value =
      'All 3-bedroom apartments in Nairobi rent for 25K-45K KES per month';
    document.getElementById('minorPremise').value =
      'Property X (ID: prop-001) is a 3-bedroom apartment in Nairobi\'s Westlands area';
    document.getElementById('reasoningQuestion').value =
      'What is the expected rent range for Property X?';
  }

  async function _performReasoning() {
    const major = document.getElementById('majorPremise').value.trim();
    const minor = document.getElementById('minorPremise').value.trim();
    const question = document.getElementById('reasoningQuestion').value.trim();

    if (!major || !minor) {
      Toast.show('Both major and minor premises are required', 'warn');
      return;
    }

    if (!_outputEl) return;

    _outputEl.innerHTML = '<p class="search-results__empty">Performing syllogistic reasoning…</p>';
    Log.info(`Reasoning initiated: "${question || 'derive conclusion'}"`);

    try {
      const evidence = await _searchEvidence(major, minor);
      const result = _deriveConclusion(major, minor, question, evidence);
      _renderConclusion(result);
      Log.info(`Conclusion derived with ${result.confidence}% confidence`);
    } catch (err) {
      _outputEl.innerHTML = `<p class="search-results__empty">Reasoning failed: ${Utils.esc(err.message)}</p>`;
    }
  }

  async function _searchEvidence(major, minor) {
    const client = db();
    if (!client) return [];

    try {
      const combinedQuery = `${major} ${minor}`;
      const { data, error } = await client
        .from(APP_CONFIG.tables.memory)
        .select('*')
        .order('importance', { ascending: false })
        .limit(10);

      if (error) throw error;

      const queryWords = combinedQuery.toLowerCase().split(/\s+/).filter(w => w.length > 3);
      return (data || []).filter(entry => {
        const text = JSON.stringify(entry.content || '').toLowerCase();
        return queryWords.some(w => text.includes(w));
      });
    } catch {
      return [];
    }
  }

  function _deriveConclusion(major, minor, question, evidence) {
    const supportingCount = evidence.length;
    const highImportance = evidence.filter(e => (e.importance || 0) >= 0.7).length;
    const namespaces = [...new Set(evidence.map(e => e.namespace).filter(Boolean))];

    let baseConfidence = 0.5;

    if (supportingCount > 0) baseConfidence += 0.1;
    if (supportingCount >= 3) baseConfidence += 0.1;
    if (supportingCount >= 5) baseConfidence += 0.05;
    if (highImportance > 0) baseConfidence += 0.1;
    if (namespaces.length >= 2) baseConfidence += 0.05;

    const confidence = Math.min(0.98, baseConfidence);

    const majorLower = major.toLowerCase();
    const minorWords = minor.toLowerCase().split(/\s+/);

    const category = _extractCategory(majorLower);
    const subject = _extractSubject(minor);
    const value = _extractValue(majorLower);

    let conclusion;
    if (category && subject && value) {
      conclusion = `${subject} falls within the range of ${value}, based on the general rule that ${category}.`;
    } else if (question) {
      conclusion = `Based on the premises and ${supportingCount} supporting evidence entries, the answer to "${question}" is derived from the general principle (${major}) applied to the specific case (${minor}).`;
    } else {
      conclusion = `From the general principle that ${major}, applied to the specific case that ${minor}, we can derive a logical conclusion. ${supportingCount > 0 ? `${supportingCount} supporting evidence entries were found in the knowledge base.` : 'No direct supporting evidence was found in the knowledge base.'}`;
    }

    const alternatives = [];
    if (confidence < APP_CONFIG.reasoning.confidenceThreshold) {
      if (supportingCount < 3) {
        alternatives.push('Insufficient evidence in knowledge base — verify with manual research');
      }
      if (namespaces.length < 2) {
        alternatives.push('Evidence found in limited domains — cross-reference with other namespaces');
      }
      alternatives.push('Consider temporal validity — check if data is current');
    }

    return {
      conclusion,
      confidence,
      supporting: evidence.slice(0, 5),
      namespaces,
      supportingCount,
      highImportance,
      alternatives,
    };
  }

  function _extractCategory(text) {
    const patterns = [
      /all\s+(.+?)\s+in\s+/i,
      /all\s+(.+?)\s+are\s+/i,
      /all\s+(.+?)\s+rent/i,
    ];
    for (const p of patterns) {
      const m = text.match(p);
      if (m) return m[1];
    }
    return null;
  }

  function _extractSubject(text) {
    const m = text.match(/(.+?)\s+is\s+/i);
    return m ? m[1] : text.substring(0, 60);
  }

  function _extractValue(text) {
    const m = text.match(/(\d[\d,kK\-]+(?:\s*(?:KES|KSh|USD|\$))?(?:\s*(?:per|\/)\s*\w+)?)/);
    return m ? m[1] : null;
  }

  function _renderConclusion(result) {
    const confClass = result.confidence >= 0.8 ? 'high' : result.confidence >= 0.5 ? 'medium' : 'low';
    const confPercent = Math.round(result.confidence * 100);

    let html = `<div class="reasoning-conclusion">`;
    html += `<div class="reasoning-conclusion__label">Conclusion</div>`;
    html += `<div class="reasoning-conclusion__text">${Utils.esc(result.conclusion)}</div>`;
    html += `<div class="reasoning-conclusion__confidence">`;
    html += `<div class="confidence-bar"><div class="confidence-bar__fill confidence-bar__fill--${confClass}" style="width: ${confPercent}%"></div></div>`;
    html += `<span class="confidence-label">${confPercent}%</span>`;
    html += `</div>`;

    if (result.supporting.length > 0) {
      html += `<div class="reasoning-evidence">`;
      html += `<div class="reasoning-evidence__title">Supporting Evidence (${result.supportingCount} found)</div>`;
      result.supporting.forEach(e => {
        const title = e.content?.title || e.content?.name || e.content?.summary || JSON.stringify(e.content || {}).substring(0, 100);
        html += `<div class="reasoning-evidence__item">`;
        html += `<strong>[${Utils.esc(e.namespace || '—')}]</strong> ${Utils.esc(title)}`;
        html += `</div>`;
      });
      html += `</div>`;
    } else {
      html += `<div class="reasoning-evidence">`;
      html += `<div class="reasoning-evidence__title">Supporting Evidence</div>`;
      html += `<div class="reasoning-evidence__item" style="color: var(--text-muted);">No matching evidence found in knowledge base</div>`;
      html += `</div>`;
    }

    if (result.alternatives.length > 0) {
      html += `<div class="reasoning-alternatives">`;
      html += `<div class="reasoning-evidence__title">Alternatives & Caveats</div>`;
      result.alternatives.forEach(a => {
        html += `<div class="reasoning-alternatives__item">- ${Utils.esc(a)}</div>`;
      });
      html += `</div>`;
    }

    html += `</div>`;
    _outputEl.innerHTML = html;
  }

  return { init };
})();
