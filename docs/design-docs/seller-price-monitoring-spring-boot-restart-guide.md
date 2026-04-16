# 셀러용 가격 모니터링 Spring Boot 재개 가이드

이 문서는 내일부터 이 저장소 작업을 다시 시작할 때 읽는 단일 진입점이다. 목적은 현재까지 완료된 상태, 다음에 구현할 파일, 그리고 작업을 재개하는 정확한 순서를 한 장에 고정하는 것이다.

## 먼저 읽을 문서
- [Spring Boot 구현 가이드](./seller-price-monitoring-spring-boot-implementation-guide.md)
- [Spring Boot 프로젝트 골격](./seller-price-monitoring-spring-boot-project-skeleton.md)
- [Spring Boot 파일 맵](./seller-price-monitoring-spring-boot-file-map.md)
- [메인 설계 문서](./seller-price-monitoring.md)
- [활성 실행 계획](../exec-plans/active/2026-04-16-seller-price-monitoring.md)
- [API 명세](./seller-price-monitoring-api.md)
- [DB 스키마 SQL](../generated/seller-price-monitoring-schema.sql)

## 현재 상태
- Spring Boot 스캐폴드가 생성돼 있다.
- `./gradlew test` 는 현재 통과한다.
- `SpmApplication`, 공통 설정, 공통 응답/예외, JWT 유틸, `AuthController`, `DashboardController` 는 생성돼 있다.
- `AuthService` 와 `DashboardSummaryService` 는 아직 스텁이다.
- `organization`, `monitoredproduct`, `competitorproduct`, `snapshot`, `event`, `alert`, `notification`, `report`, `ingestion`, `delivery`, `fixture` 패키지는 경계만 잡혀 있다.
- Flyway 실제 마이그레이션 파일은 아직 없다.
- 엔티티, 리포지토리, 서비스 구현은 아직 시작 전이다.

## 다음 작업
### 1. 조직과 멤버십부터 구현한다
- 대상 파일: `src/main/java/kr/co/harness/spm/organization/**`
- 목표: `Organization`, `OrganizationMember`, `OrganizationInvite` 엔티티와 저장소, 서비스, 컨트롤러를 만든다.
- 이유: 인증 이후 가장 먼저 필요한 워크스페이스 흐름이기 때문이다.

### 2. 모니터링 상품을 구현한다
- 대상 파일: `src/main/java/kr/co/harness/spm/monitoredproduct/**`
- 목표: 내 상품 CRUD와 소프트 아카이브를 만든다.
- 이유: 상품 등록이 되어야 경쟁상품과 스냅샷 흐름이 이어진다.

### 3. 경쟁상품과 스냅샷 뼈대를 만든다
- 대상 파일: `src/main/java/kr/co/harness/spm/competitorproduct/**`, `src/main/java/kr/co/harness/spm/snapshot/**`
- 목표: 경쟁상품 등록, 스냅샷 조회, 적재 오케스트레이션의 기본 틀을 만든다.
- 이유: 가격 비교와 이벤트 생성의 출발점이 된다.

### 4. Flyway 마이그레이션을 생성한다
- 대상 파일: `src/main/resources/db/migration/**`
- 기준 파일: `docs/generated/seller-price-monitoring-schema.sql`, `docs/generated/seller-price-monitoring-migrations/001_init.sql`, `docs/generated/seller-price-monitoring-migrations/002_indexes.sql`
- 목표: 실제 애플리케이션이 DB 없이가 아니라 PostgreSQL 마이그레이션으로 뜨게 만든다.

### 5. 통합 테스트 골격을 붙인다
- 대상 파일: `src/test/java/kr/co/harness/spm/**`
- 목표: PostgreSQL과 Redis Testcontainers 기반으로 최소 부팅/인증/대시보드 테스트를 만든다.

## 재개 순서
1. 이 문서와 [구현 가이드](./seller-price-monitoring-spring-boot-implementation-guide.md)를 먼저 읽는다.
2. `./gradlew test` 를 한 번 실행해 현재 상태를 확인한다.
3. `organization` 패키지부터 구현한다.
4. 그 다음 `monitoredproduct` 와 `competitorproduct` 로 넘어간다.
5. `snapshot` 과 `event` 를 붙인다.
6. 마지막에 `alert`, `notification`, `report`, `ingestion`, `delivery` 를 마무리한다.

## 재개용 지시문
내일 이 문서를 기준으로 작업을 시작할 때는 다음 원칙을 따른다.

- 먼저 읽는 문서를 다시 확인하고, 문서와 코드가 어긋나면 문서를 우선한다.
- 작업은 `organization` -> `monitoredproduct` -> `competitorproduct` -> `snapshot` -> `event` 순서로 시작한다.
- 구현 후에는 `./gradlew test` 를 다시 실행한다.
- 변경 파일 목록과 검증 결과를 함께 보고한다.
- 아직 결정되지 않은 항목은 임의로 확정하지 말고, 문서에 남긴다.

## 완료 기준
- 다음 날 작업을 시작하는 사람이 이 문서만 보고 첫 구현 파일을 고를 수 있어야 한다.
- 현재 빌드 상태와 다음 구현 순서가 분리돼 있어야 한다.
- 문서에 적힌 순서대로 진행하면 코드와 DB 마이그레이션을 붙일 수 있어야 한다.
