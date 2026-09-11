-- ============================================================================
-- SHARED PLATFORM — Reusable services (DERIVED, NON-BREAKING COPY)
-- SOURCE: ../Schema.db (original left untouched)
-- These tables are NOT Mwarokin-real-estate logic. They are upgrade extras
-- that were merged into the same file. Deploy per-project as needed.
-- Uses IF NOT EXISTS. No DROPs. No RLS changes here (see audit docs).
-- ============================================================================

-- Shared identity base (NOTE: role enum is Mwarokin-contaminated, see audit)
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL,
  full_name text, phone text,
  role text NOT NULL DEFAULT 'tenant' CHECK (role IN ('admin','agent','landlord','caretaker','tenant')),
  company text, profile_pic text, bio text,
  preferred_language text NOT NULL DEFAULT 'en',
  preferred_currency text NOT NULL DEFAULT 'KES',
  timezone text NOT NULL DEFAULT 'Africa/Nairobi',
  notification_preferences jsonb NOT NULL DEFAULT '{"lease": true, "general": true, "payment": true, "maintenance": true}',
  is_verified boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.platform_settings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  key text NOT NULL UNIQUE, value jsonb NOT NULL, description text,
  updated_by uuid REFERENCES public.profiles(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT platform_settings_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.communication_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE REFERENCES public.profiles(id),
  phone varchar, whatsapp_phone varchar, telegram_username varchar,
  instagram_handle varchar, snapchat_username varchar, tiktok_handle varchar,
  preferred_channel text NOT NULL DEFAULT 'whatsapp' CHECK (preferred_channel IN ('sms','whatsapp','telegram','instagram','email','in-app')),
  is_verified boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT communication_profiles_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.message_queue (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  channel text NOT NULL CHECK (channel IN ('sms','whatsapp','telegram','instagram','snapchat','tiktok','in-app','email')),
  recipient_id uuid REFERENCES public.profiles(id),
  recipient_identifier text NOT NULL,
  sender_id uuid REFERENCES public.profiles(id),
  subject text, body text NOT NULL, media_urls jsonb NOT NULL DEFAULT '[]',
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','sent','delivered','read','failed')),
  priority text NOT NULL DEFAULT 'normal' CHECK (priority IN ('low','normal','high','urgent')),
  scheduled_for timestamptz, sent_at timestamptz, delivered_at timestamptz, read_at timestamptz,
  metadata jsonb NOT NULL DEFAULT '{}', error_message text,
  retry_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT message_queue_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id),
  type text NOT NULL DEFAULT 'general' CHECK (type IN ('payment_due','maintenance_update','lease_expiry','inspection','general','message')),
  title text NOT NULL, body text NOT NULL, link text,
  is_read boolean NOT NULL DEFAULT false,
  priority text NOT NULL DEFAULT 'normal',
  metadata jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(), read_at timestamptz,
  CONSTRAINT notifications_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.supported_languages (
  code text NOT NULL, name text NOT NULL, native_name text NOT NULL,
  flag text, is_rtl boolean NOT NULL DEFAULT false, is_active boolean NOT NULL DEFAULT true,
  CONSTRAINT supported_languages_pkey PRIMARY KEY (code)
);

CREATE TABLE IF NOT EXISTS public.translations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  language_code text NOT NULL REFERENCES public.supported_languages(code),
  namespace text NOT NULL DEFAULT 'common', key text NOT NULL, value text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT translations_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.supported_currencies (
  code text NOT NULL, name text NOT NULL, symbol text NOT NULL,
  decimal_places integer NOT NULL DEFAULT 2, is_active boolean NOT NULL DEFAULT true,
  CONSTRAINT supported_currencies_pkey PRIMARY KEY (code)
);

CREATE TABLE IF NOT EXISTS public.exchange_rates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  base_currency text NOT NULL REFERENCES public.supported_currencies(code),
  target_currency text NOT NULL REFERENCES public.supported_currencies(code),
  rate numeric NOT NULL, previous_rate numeric, change_percentage numeric NOT NULL DEFAULT 0,
  source text, last_updated timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT exchange_rates_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.audit_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid, action text NOT NULL, table_name text, record_id uuid,
  old_data jsonb, new_data jsonb, ip_address inet, user_agent text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT audit_logs_pkey PRIMARY KEY (id)
);

-- CRM / outreach (shared pattern, currently Mwarokin-adjacent)
CREATE TABLE IF NOT EXISTS public.prospects (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  source text, name text, phone text, email text, address text,
  property_address text, property_type text, estimated_value numeric,
  lead_score integer NOT NULL DEFAULT 0,
  qualification_status text NOT NULL DEFAULT 'new' CHECK (qualification_status IN ('new','qualified','hot','nurture','converted')),
  intent_signals jsonb NOT NULL DEFAULT '[]', preferred_channels jsonb NOT NULL DEFAULT '[]',
  notes text, discovered_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT prospects_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.outreach_campaigns (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL, target_criteria jsonb NOT NULL DEFAULT '{}',
  channels jsonb NOT NULL DEFAULT '["whatsapp", "sms"]',
  message_template_id uuid, schedule_config jsonb,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','active','paused','completed')),
  total_reached integer NOT NULL DEFAULT 0, total_converted integer NOT NULL DEFAULT 0,
  created_by uuid REFERENCES public.profiles(id),
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT outreach_campaigns_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.outreach_threads (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  prospect_id uuid REFERENCES public.prospects(id),
  campaign_id uuid REFERENCES public.outreach_campaigns(id),
  channel text NOT NULL, external_thread_id text,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','awaiting_response','converted','closed')),
  last_message_at timestamptz, engagement_score integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT outreach_threads_pkey PRIMARY KEY (id)
);
