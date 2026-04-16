# 데이터베이스 스키마

> 생성된 파일이다. 수동으로 편집하지 않는다.

## 원본
- 추출 원본: `docs/product-specs/seller-price-monitoring.md`
- 생성 시각: 2026-04-16
- 관련 SQL: [seller-price-monitoring-schema.sql](./seller-price-monitoring-schema.sql)
- 마이그레이션: [001_init.sql](./seller-price-monitoring-migrations/001_init.sql), [002_indexes.sql](./seller-price-monitoring-migrations/002_indexes.sql)

## 테이블
- organizations
- users
- organization_members
- organization_invites
- monitored_products
- competitor_products
- product_snapshots
- events
- alert_rules
- notifications
- reports

## 관계
- 조직은 멤버, 초대, 모니터링 상품, 이벤트, 알림 규칙, 알림 이력, 리포트를 가진다.
- 모니터링 상품은 여러 경쟁상품을 가진다.
- 경쟁상품은 여러 스냅샷을 가진다.
- 이벤트는 조직, 모니터링 상품, 선택적 경쟁상품에 연결된다.
- 알림 이력은 이벤트와 모니터링 상품을 참조할 수 있다.

## 메모
- 이 파일은 생성물 요약용 안내문이다.
- 실제 DDL은 [seller-price-monitoring-schema.sql](./seller-price-monitoring-schema.sql)에 둔다.
