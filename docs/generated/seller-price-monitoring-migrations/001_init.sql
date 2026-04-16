-- Migration 001: core schema for seller price monitoring
-- Source docs:
-- - docs/product-specs/seller-price-monitoring.md
-- - docs/design-docs/seller-price-monitoring.md

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TYPE organization_status AS ENUM ('active', 'suspended', 'closed');
CREATE TYPE plan_tier AS ENUM ('starter', 'growth', 'agency');
CREATE TYPE user_status AS ENUM ('active', 'suspended', 'deleted');
CREATE TYPE member_role AS ENUM ('admin', 'operator', 'viewer');
CREATE TYPE member_status AS ENUM ('active', 'suspended');
CREATE TYPE invite_status AS ENUM ('pending', 'accepted', 'expired', 'revoked');
CREATE TYPE monitor_status AS ENUM ('active', 'paused', 'archived');
CREATE TYPE sales_channel AS ENUM ('coupang', 'smartstore', '11st', 'gmarket', 'custom');
CREATE TYPE stock_status AS ENUM ('in_stock', 'out_of_stock', 'unknown');
CREATE TYPE event_type AS ENUM (
  'price_drop',
  'price_rise',
  'lowest_price_changed',
  'margin_risk',
  'out_of_stock',
  'restock',
  'review_spike',
  'rating_alert'
);
CREATE TYPE alert_rule_type AS ENUM (
  'price_drop_pct',
  'price_floor',
  'margin_floor',
  'stock_change',
  'review_spike',
  'rating_threshold'
);
CREATE TYPE delivery_channel AS ENUM ('email', 'slack', 'kakaowork', 'webhook');
CREATE TYPE notification_status AS ENUM ('queued', 'sent', 'delivered', 'failed');
CREATE TYPE report_type AS ENUM ('daily_summary', 'weekly_summary', 'client_report');

CREATE TABLE organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  plan plan_tier NOT NULL DEFAULT 'starter',
  status organization_status NOT NULL DEFAULT 'active',
  timezone text NOT NULL DEFAULT 'Asia/Seoul',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email citext NOT NULL UNIQUE,
  name text NOT NULL,
  password_hash text NOT NULL,
  status user_status NOT NULL DEFAULT 'active',
  last_login_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE organization_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  role member_role NOT NULL DEFAULT 'operator',
  status member_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (organization_id, user_id)
);

CREATE TABLE organization_invites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations (id) ON DELETE CASCADE,
  email citext NOT NULL,
  role member_role NOT NULL DEFAULT 'operator',
  invited_by_user_id uuid REFERENCES users (id) ON DELETE SET NULL,
  token text NOT NULL UNIQUE,
  status invite_status NOT NULL DEFAULT 'pending',
  expires_at timestamptz NOT NULL,
  accepted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE monitored_products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations (id) ON DELETE CASCADE,
  owner_product_name text NOT NULL,
  owner_product_url text NOT NULL,
  owner_price numeric(12, 2) NOT NULL CHECK (owner_price >= 0),
  min_margin_price numeric(12, 2) NOT NULL CHECK (min_margin_price >= 0),
  category text NOT NULL DEFAULT '',
  notes text,
  status monitor_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE competitor_products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  monitored_product_id uuid NOT NULL REFERENCES monitored_products (id) ON DELETE CASCADE,
  channel sales_channel NOT NULL,
  competitor_name text NOT NULL,
  competitor_product_url text NOT NULL,
  competitor_product_title text,
  is_active boolean NOT NULL DEFAULT true,
  first_seen_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (monitored_product_id, competitor_product_url)
);

CREATE TABLE product_snapshots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  competitor_product_id uuid NOT NULL REFERENCES competitor_products (id) ON DELETE CASCADE,
  collected_at timestamptz NOT NULL,
  listed_price numeric(12, 2) NOT NULL CHECK (listed_price >= 0),
  shipping_fee numeric(12, 2) NOT NULL DEFAULT 0 CHECK (shipping_fee >= 0),
  coupon_price numeric(12, 2) NOT NULL DEFAULT 0 CHECK (coupon_price >= 0),
  effective_price numeric(12, 2) NOT NULL CHECK (effective_price >= 0),
  review_count integer NOT NULL DEFAULT 0 CHECK (review_count >= 0),
  rating numeric(3, 2) CHECK (rating IS NULL OR (rating >= 0 AND rating <= 5)),
  stock_status stock_status NOT NULL DEFAULT 'unknown',
  seller_name text,
  raw_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations (id) ON DELETE CASCADE,
  monitored_product_id uuid NOT NULL REFERENCES monitored_products (id) ON DELETE CASCADE,
  competitor_product_id uuid REFERENCES competitor_products (id) ON DELETE SET NULL,
  event_type event_type NOT NULL,
  old_value jsonb,
  new_value jsonb,
  change_rate numeric(12, 4),
  detected_at timestamptz NOT NULL DEFAULT now(),
  is_read boolean NOT NULL DEFAULT false,
  is_pinned boolean NOT NULL DEFAULT false,
  resolved_at timestamptz,
  note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE alert_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations (id) ON DELETE CASCADE,
  rule_type alert_rule_type NOT NULL,
  threshold numeric(12, 4) NOT NULL,
  delivery_channel delivery_channel NOT NULL,
  filter_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  is_enabled boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations (id) ON DELETE CASCADE,
  event_id uuid REFERENCES events (id) ON DELETE SET NULL,
  monitored_product_id uuid REFERENCES monitored_products (id) ON DELETE SET NULL,
  delivery_channel delivery_channel NOT NULL,
  recipient text NOT NULL,
  title text NOT NULL,
  body text NOT NULL,
  status notification_status NOT NULL DEFAULT 'queued',
  sent_at timestamptz,
  delivered_at timestamptz,
  read_at timestamptz,
  error_message text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations (id) ON DELETE CASCADE,
  report_type report_type NOT NULL,
  report_date date NOT NULL,
  payload_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (organization_id, report_type, report_date)
);

COMMIT;
