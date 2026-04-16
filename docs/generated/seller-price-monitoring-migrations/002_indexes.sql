-- Migration 002: indexes for seller price monitoring
-- Source docs:
-- - docs/product-specs/seller-price-monitoring.md
-- - docs/design-docs/seller-price-monitoring.md

BEGIN;

CREATE INDEX idx_organization_members_user_id
  ON organization_members (user_id);

CREATE INDEX idx_organization_invites_organization_email
  ON organization_invites (organization_id, email);

CREATE INDEX idx_monitored_products_organization_status
  ON monitored_products (organization_id, status);

CREATE INDEX idx_competitor_products_monitored_active
  ON competitor_products (monitored_product_id, is_active);

CREATE INDEX idx_product_snapshots_competitor_collected_at
  ON product_snapshots (competitor_product_id, collected_at DESC);

CREATE INDEX idx_events_organization_detected_at
  ON events (organization_id, detected_at DESC);

CREATE INDEX idx_alert_rules_organization_enabled
  ON alert_rules (organization_id, is_enabled);

CREATE INDEX idx_notifications_organization_created_at
  ON notifications (organization_id, created_at DESC);

CREATE INDEX idx_reports_organization_date
  ON reports (organization_id, report_date DESC);

COMMIT;
