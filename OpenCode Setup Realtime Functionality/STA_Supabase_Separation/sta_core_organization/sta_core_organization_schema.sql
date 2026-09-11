-- ============================================================================
-- STA CORE ORGANIZATION — New org-level layer (SAFE TO DEPLOY TO NEW PROJECT)
-- TARGET: new Supabase project under org iyngtxvchqpeayvsuvph (NOT spnerrqumefbuuscumhw)
-- Purpose: Organizations management + application registry + shared billing/audit
-- for non-Mwarokin extras. Uses IF NOT EXISTS. No DROPs. No seed data.
-- After deploy: point Mwarokin/Mali apps at this via organization_id/app_id
-- (requires approved migration — NOT done here).
-- ============================================================================

-- Organizations (STA root)
CREATE TABLE IF NOT EXISTS public.organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  name text NOT NULL,
  display_name text,
  org_type text NOT NULL DEFAULT 'sta_business_unit' CHECK (org_type IN ('sta_root','sta_business_unit','customer','partner')),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended','archived')),
  country text DEFAULT 'Kenya',
  metadata jsonb NOT NULL DEFAULT '{}',
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.organization_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key text UNIQUE NOT NULL,
  label text NOT NULL,
  scope text NOT NULL DEFAULT 'organization' CHECK (scope IN ('platform','organization','application','resource')),
  permissions jsonb NOT NULL DEFAULT '[]',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.organization_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL,
  role_id uuid REFERENCES public.organization_roles(id),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','invited','suspended','removed')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (organization_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.organization_settings (
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  key text NOT NULL,
  value jsonb NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (organization_id, key)
);

-- Application registry (Mwarokin = one row, NOT the root)
CREATE TABLE IF NOT EXISTS public.applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  name text NOT NULL,
  description text,
  owner_organization_id uuid REFERENCES public.organizations(id),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('planned','active','deprecated','retired')),
  metadata jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.application_memberships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id uuid NOT NULL REFERENCES public.applications(id) ON DELETE CASCADE,
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL,
  role_key text NOT NULL DEFAULT 'member',
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended','removed')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (application_id, organization_id, user_id)
);

-- Shared commercial layer (separate from rent / union contributions)
CREATE TABLE IF NOT EXISTS public.billing_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  name text NOT NULL,
  amount numeric NOT NULL DEFAULT 0,
  currency text NOT NULL DEFAULT 'KES',
  interval text NOT NULL DEFAULT 'monthly' CHECK (interval IN ('weekly','monthly','quarterly','annually','one_time')),
  metadata jsonb NOT NULL DEFAULT '{}',
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  application_id uuid REFERENCES public.applications(id) ON DELETE SET NULL,
  plan_id uuid REFERENCES public.billing_plans(id),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('trialing','active','past_due','cancelled','expired')),
  current_period_start timestamptz,
  current_period_end timestamptz,
  metadata jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Central audit (separate from app-level audit_logs / union_audit_trail)
CREATE TABLE IF NOT EXISTS public.sta_audit_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid REFERENCES public.organizations(id) ON DELETE SET NULL,
  application_id uuid REFERENCES public.applications(id) ON DELETE SET NULL,
  actor_type text NOT NULL DEFAULT 'user' CHECK (actor_type IN ('user','agent','system','api')),
  actor_id uuid,
  action text NOT NULL,
  resource_type text,
  resource_id uuid,
  environment text NOT NULL DEFAULT 'production',
  success boolean NOT NULL DEFAULT true,
  error_class text,
  correlation_id uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Bank accounts referenced by Mali schema (defined here as STA-owned, nullable owner)
CREATE TABLE IF NOT EXISTS public.bank_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid REFERENCES public.organizations(id) ON DELETE SET NULL,
  account_name text NOT NULL,
  account_number text NOT NULL,
  bank_name text,
  currency text NOT NULL DEFAULT 'KES',
  is_active boolean NOT NULL DEFAULT true,
  metadata jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_org_members_org ON public.organization_members(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_members_user ON public.organization_members(user_id);
CREATE INDEX IF NOT EXISTS idx_app_memberships_app ON public.application_memberships(application_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_org ON public.subscriptions(organization_id);
CREATE INDEX IF NOT EXISTS idx_sta_audit_org_time ON public.sta_audit_events(organization_id, created_at DESC);
