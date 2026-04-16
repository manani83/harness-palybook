# 생성 문서

이 문서는 생성 산출물의 진입점이다. 수동 편집 대상이 아닌 파일과 생성된 기준 파일을 분리해서 찾을 수 있게 한다.

## 현재 생성 산출물
- [DB 스키마 요약](./db-schema.md)
- [셀러용 가격 모니터링 통합 스키마](./seller-price-monitoring-schema.sql)
- [셀러용 가격 모니터링 OpenAPI](./seller-price-monitoring-openapi.yaml)
- [셀러용 가격 모니터링 마이그레이션 001](./seller-price-monitoring-migrations/001_init.sql)
- [셀러용 가격 모니터링 마이그레이션 002](./seller-price-monitoring-migrations/002_indexes.sql)

## 원칙
- 생성 파일은 정본 문서와 충돌하면 안 된다.
- 생성 파일은 원본 기준이 바뀌면 다시 만들어야 한다.
- 생성 파일을 수동 수정할 때는 그것이 임시인지 정본인지 분명히 기록한다.
