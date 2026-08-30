/**
 * NOESIS — Configuration (STA-006)
 * Knowledge & Reasoning Engine
 */
const APP_CONFIG = Object.freeze({
  appName: 'NOESIS',
  appSlug: 'noesis',
  appCode: 'sta-006',
  basePath: '/noesis/',

  supabase: {
    url: window.__SUPABASE_URL || 'https://YOUR_PROJECT.supabase.co',
    anonKey: window.__SUPABASE_ANON_KEY || 'YOUR_ANON_KEY_HERE',
  },

  features: {
    ragSearch: true,
    reasoning: true,
    knowledgeBase: true,
    memoryStats: true,
  },

  namespaces: [
    { id: 'properties',  label: 'Properties',  color: 'properties',  description: 'Property details, locations, pricing, amenities', ttl: 'Permanent' },
    { id: 'tenants',     label: 'Tenants',      color: 'tenants',     description: 'Tenant profiles, lease history, payment behavior', ttl: 'Permanent' },
    { id: 'payments',    label: 'Payments',     color: 'payments',    description: 'Transaction records, fee structures, revenue', ttl: '90 days' },
    { id: 'market',      label: 'Market',       color: 'market',      description: 'Market trends, pricing analysis, competitor intel', ttl: '30 days' },
    { id: 'ceo',         label: 'CEO',          color: 'ceo',         description: 'Executive briefings, KPIs, strategic decisions', ttl: '90 days' },
    { id: 'system',      label: 'System',       color: 'system',      description: 'Architecture decisions, deployment history', ttl: 'Permanent' },
    { id: 'prospects',   label: 'Prospects',    color: 'prospects',   description: 'Lead data, qualification status, outreach history', ttl: '60 days' },
    { id: 'compliance',  label: 'Compliance',   color: 'compliance',  description: 'Regulatory requirements, audit findings', ttl: 'Permanent' },
  ],

  agentIds: {
    knowledge: 'noesis-001',
    reasoning: 'noesis-002',
  },

  ollama: {
    url: 'http://127.0.0.1:11434',
    models: ['qwen3:8b', 'gemma3:4b', 'llama3.2:3b'],
  },

  tables: {
    memory: 'agent_memory',
    tasks: 'agent_tasks',
    events: 'agent_events',
  },

  search: {
    maxResults: 20,
    minImportance: 0.3,
  },

  reasoning: {
    confidenceThreshold: 0.9,
    maxAlternatives: 3,
  },

  refreshIntervals: {
    dashboard: 30000,
    clock: 1000,
  },

  toast: {
    duration: 3000,
    position: 'top-right',
  },
});

if (typeof module !== 'undefined' && module.exports) {
  module.exports = APP_CONFIG;
}
