-- ============================================================================
-- MWAROKIN ESTATES — Application-only schema (DERIVED, NON-BREAKING COPY)
-- SOURCE: ../Schema.db (original left untouched) + STA_Supabase_Separation map
-- TARGET PROJECT: spnerrqumefbuuscumhw (existing Mwarokin project ONLY)
-- DO NOT deploy to STA Core org project. Uses IF NOT EXISTS. No DROPs.
-- Missing: organization_id / application_id — intentionally NOT added here.
-- Adding tenancy columns requires Founder-approved migration (see audit docs).
-- ============================================================================

-- Properties (Mwarokin core)
CREATE TABLE IF NOT EXISTS public.properties (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text UNIQUE,
  description text,
  property_type text CHECK (property_type IN ('house','apartment','land','commercial','villa','bedsitter','bungalow')),
  status text NOT NULL DEFAULT 'available' CHECK (status IN ('available','rented','under_maintenance','sold')),
  price numeric NOT NULL DEFAULT 0,
  deposit numeric,
  bedrooms integer DEFAULT 0,
  bathrooms integer DEFAULT 0,
  area_sqft integer,
  location text NOT NULL,
  city text, county text,
  country text NOT NULL DEFAULT 'Kenya',
  latitude numeric, longitude numeric,
  amenities jsonb NOT NULL DEFAULT '[]',
  images jsonb NOT NULL DEFAULT '[]',
  video_url text, virtual_tour_url text,
  agent_id uuid REFERENCES public.profiles(id),
  is_featured boolean NOT NULL DEFAULT false,
  views_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT properties_pkey PRIMARY KEY (id)
);

-- Tenants (Mwarokin occupancy)
CREATE TABLE IF NOT EXISTS public.tenants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES public.profiles(id),
  full_name text NOT NULL,
  phone text NOT NULL,
  email text, id_number text, date_of_birth date, occupation text,
  emergency_contact_name text, emergency_contact_phone text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT tenants_pkey PRIMARY KEY (id)
);

-- Leases (Mwarokin occupancy contract)
CREATE TABLE IF NOT EXISTS public.leases (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL REFERENCES public.properties(id),
  tenant_id uuid NOT NULL REFERENCES public.tenants(id),
  landlord_id uuid REFERENCES public.profiles(id),
  start_date date NOT NULL, end_date date NOT NULL,
  rent_amount numeric NOT NULL,
  deposit_paid numeric NOT NULL DEFAULT 0,
  deposit_balance numeric NOT NULL DEFAULT 0,
  payment_frequency text NOT NULL DEFAULT 'monthly' CHECK (payment_frequency IN ('monthly','quarterly','annually')),
  is_active boolean NOT NULL DEFAULT true,
  lease_document_url text, notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT leases_pkey PRIMARY KEY (id)
);

-- Rent payments (Mwarokin finance — NOT global ledger)
CREATE TABLE IF NOT EXISTS public.payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  lease_id uuid REFERENCES public.leases(id),
  tenant_id uuid REFERENCES public.tenants(id),
  property_id uuid REFERENCES public.properties(id),
  landlord_id uuid REFERENCES public.profiles(id),
  amount numeric NOT NULL,
  landlord_amount numeric NOT NULL DEFAULT 0,
  platform_fee numeric NOT NULL DEFAULT 0,
  platform_fee_percentage numeric NOT NULL DEFAULT 5.0,
  payment_method text CHECK (payment_method IN ('mpesa','airtel-money','bank-transfer','card','cash')),
  transaction_id text UNIQUE,
  provider_reference text,
  payment_date date NOT NULL, due_date date NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','processing','completed','failed','refunded')),
  split_status text NOT NULL DEFAULT 'pending' CHECK (split_status IN ('pending','processing','completed','failed')),
  metadata jsonb NOT NULL DEFAULT '{}',
  notes text, receipt_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT payments_pkey PRIMARY KEY (id)
);

-- Maintenance (Mwarokin operations)
CREATE TABLE IF NOT EXISTS public.maintenance_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid REFERENCES public.properties(id),
  tenant_id uuid REFERENCES public.tenants(id),
  request_type text CHECK (request_type IN ('plumbing','electrical','structural','appliance','pest','other')),
  priority text NOT NULL DEFAULT 'medium' CHECK (priority IN ('low','medium','high','emergency')),
  description text NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','in_progress','completed','cancelled')),
  images jsonb NOT NULL DEFAULT '[]',
  technician_name text, technician_phone text,
  scheduled_date date, completed_date date, cost numeric, notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT maintenance_requests_pkey PRIMARY KEY (id)
);

-- Property documents (Mwarokin docs)
CREATE TABLE IF NOT EXISTS public.documents (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid REFERENCES public.properties(id),
  tenant_id uuid REFERENCES public.tenants(id),
  lease_id uuid REFERENCES public.leases(id),
  document_type text CHECK (document_type IN ('lease_agreement','identification','receipt','inspection','contract','other')),
  title text NOT NULL, file_url text NOT NULL,
  file_size integer, file_type text,
  uploaded_by uuid REFERENCES public.profiles(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT documents_pkey PRIMARY KEY (id)
);

-- Property analytics (Mwarokin-only)
CREATE TABLE IF NOT EXISTS public.property_views (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL REFERENCES public.properties(id),
  view_count integer NOT NULL DEFAULT 0,
  unique_viewers integer NOT NULL DEFAULT 0,
  last_viewed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT property_views_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.property_price_localization (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL REFERENCES public.properties(id),
  currency_code text NOT NULL REFERENCES public.supported_currencies(code),
  localized_price numeric NOT NULL,
  exchange_rate_used numeric NOT NULL,
  last_calculated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT property_price_localization_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.user_behavior (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES public.profiles(id),
  session_id text,
  action_type text CHECK (action_type IN ('view','favorite','share','search','inquiry')),
  property_id uuid REFERENCES public.properties(id),
  search_query text, search_filters jsonb, time_spent integer,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT user_behavior_pkey PRIMARY KEY (id)
);
