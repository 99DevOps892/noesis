# NOESIS — Knowledge & Reasoning Engine

> STA-006 | Syllogism Technology Africa

Knowledge base browser, RAG search interface, and syllogistic reasoning engine for the STA ecosystem.

## Features

- **Knowledge Base Browser** — Browse 8 namespaces: properties, tenants, payments, market, ceo, system, prospects, compliance
- **RAG Search** — Query the knowledge base with natural language, filtered by namespace
- **Syllogistic Reasoning** — Structured reasoning with major/minor premises and confidence scoring
- **Memory Stats** — Entry counts per namespace, embedding coverage, last refresh time
- **Recent Entries** — View latest knowledge entries with importance scoring

## Setup

1. Copy `.env.example` to `.env` and fill in your Supabase credentials
2. Open `app/index.html` in a browser
3. Ensure the `agent_memory` table exists in your Supabase project

## Architecture

- No build step — pure HTML/CSS/JS
- Supabase Realtime for live updates
- PWA-enabled with service worker
- Light theme optimized for reading

## Namespaces

| Namespace | Content | TTL |
|-----------|---------|-----|
| properties | Property details, locations, pricing | Permanent |
| tenants | Tenant profiles, lease history | Permanent |
| payments | Transaction records, fee structures | 90 days |
| market | Market trends, pricing analysis | 30 days |
| ceo | Executive briefings, KPIs | 90 days |
| system | Architecture decisions, deployment history | Permanent |
| prospects | Lead data, outreach history | 60 days |
| compliance | Regulatory requirements, audit findings | Permanent |

## Reasoning Protocol

1. Enter major premise (general rule)
2. Enter minor premise (specific case)
3. Optionally enter a question
4. Engine searches knowledge base for supporting evidence
5. Derives conclusion with confidence percentage
6. Lists alternatives when confidence < 90%
