# 셀러용 가격 모니터링 Spring Boot 구현 가이드

이 문서는 AI 에이전트가 셀러용 가격 모니터링 백엔드 코드를 작성할 때 따라야 할 구현 계약이다. 목적은 Spring Boot 애플리케이션이 로컬에서 기동되고, DB 마이그레이션이 적용되며, OpenAPI와 같은 에러 형식을 쓰도록 구현의 흔들림을 줄이는 것이다.

## 먼저 읽을 문서
- [제품 명세](../product-specs/seller-price-monitoring.md)
- [설계 문서](./seller-price-monitoring.md)
- [API 명세](./seller-price-monitoring-api.md)
- [OpenAPI](../generated/seller-price-monitoring-openapi.yaml)
- [DB 스키마 SQL](../generated/seller-price-monitoring-schema.sql)
- [QA 체크리스트](../checklists/seller-price-monitoring-qa.md)
- [실행 계획](../exec-plans/active/2026-04-16-seller-price-monitoring.md)
- [시장 맥락](../references/seller-price-monitoring-market-context.md)
- [프로젝트 골격](./seller-price-monitoring-spring-boot-project-skeleton.md)
- [파일 맵](./seller-price-monitoring-spring-boot-file-map.md)

## 구현 목표
- 단일 Spring Boot 모듈로 API, 도메인, 배치, 알림 처리를 제공한다.
- `./gradlew bootRun` 으로 애플리케이션이 기동된다.
- `./gradlew test` 가 통과한다.
- 공개 API는 문서의 경로, 필드명, 상태 코드와 일치한다.
- 개발 프로파일에서는 외부 채널 없이도 핵심 흐름을 수동 검증할 수 있다.

## 고정 선택
| 항목 | 선택 | 비고 |
| --- | --- | --- |
| 언어 | Java 21 | records와 최신 Spring 기능 사용 |
| 프레임워크 | Spring Boot 3.4.x | 단일 백엔드 애플리케이션 기준 |
| 빌드 | Gradle Kotlin DSL | 스크립트 단순화 |
| 데이터베이스 | PostgreSQL 15+ | `jsonb`, enum, UUID 사용 |
| 캐시/락 | Redis 7+ | 토큰 폐기, 작업 잠금, 큐 보조 |
| 마이그레이션 | Flyway | `ddl-auto` 의존 금지 |
| ORM | Spring Data JPA | CRUD와 조회 필터 중심 |
| 보안 | Spring Security + JWT | Bearer 토큰 사용 |
| 검증 | Bean Validation | 요청 DTO 검증 |
| 문서 | springdoc-openapi | API 문서 동기화 |
| 테스트 | JUnit 5, Mockito, Testcontainers | 실제 DB/Redis 검증 포함 |
| 매핑 | 수동 매핑 우선 | Lombok은 기본적으로 사용하지 않음 |

## 구현 원칙
- 이 구현은 모놀리식 백엔드로 시작한다.
- 컨트롤러는 얇게 유지하고 비즈니스 규칙은 서비스 계층에 둔다.
- 엔티티를 API 응답으로 직접 노출하지 않는다.
- 데이터베이스 스키마와 API 계약을 임의로 바꾸지 않는다.
- 새로운 필드나 테이블이 필요하면 코드에서 우회하지 말고 문서와 마이그레이션을 함께 갱신한다.
- H2는 사용하지 않는다. 로컬과 테스트 모두 PostgreSQL 기반으로 맞춘다.
- 외부 채널 수집과 전송은 인터페이스 뒤에 숨기고, 기본 개발 프로파일에서는 fixture 구현을 사용한다.

## 패키지 구조
루트 패키지는 한 번 정하고 끝까지 유지한다. 아래는 feature-based 구조의 권장 형태다.

```text
<root>
  config
  shared
  auth
  organization
  dashboard
  monitoredproduct
  competitorproduct
  snapshot
  event
  alert
  notification
  report
  ingestion
  delivery
  fixture
```

### 패키지 책임
- `config`: 보안, CORS, Jackson, Swagger, Redis, JPA, Flyway 설정
- `shared`: 공통 응답, 예외, cursor codec, time utilities
- `auth`: 로그인, refresh, logout, 현재 사용자 조회
- `organization`: 조직, 멤버, 초대, 권한
- `dashboard`: 오늘의 요약 카드와 대응 우선순위 조회
- `monitoredproduct`: 내 상품 CRUD와 상태 변경
- `competitorproduct`: 경쟁상품 등록, 수정, 비활성화, 스냅샷 조회
- `snapshot`: 스냅샷 저장, 계산, 이력 조회
- `event`: 이벤트 생성, 조회, 읽음 처리, 메모, 핀 고정
- `alert`: 알림 규칙 CRUD와 규칙 검증
- `notification`: 알림 발송 이력, 읽음 처리, 큐 처리
- `report`: 일간/주간 리포트 조회와 생성
- `ingestion`: 스냅샷 적재와 이벤트 탐지 오케스트레이션
- `delivery`: email/slack/kakaowork/webhook 전송 어댑터
- `fixture`: 개발/테스트용 샘플 데이터와 대체 어댑터

## 공통 API 계약
### 응답 포맷
- 성공 응답은 `data`와 `meta`를 사용한다.
- 목록 응답은 `meta.requestId`, `meta.nextCursor`, `meta.hasMore`를 포함한다.
- 에러 응답은 항상 `ErrorResponse` 형식을 사용한다.
- `204`는 본문이 없어야 한다.
- `201`은 생성된 리소스를 반환한다.

### 예외 매핑
| 예외 | 상태 코드 | error.code |
| --- | --- | --- |
| 요청 검증 실패 | 400 | `VALIDATION_ERROR` |
| 인증 실패 | 401 | `UNAUTHORIZED` |
| 권한 부족 | 403 | `FORBIDDEN` |
| 리소스 없음 | 404 | `NOT_FOUND` |
| 상태 충돌/중복 | 409 | `CONFLICT` |
| 호출 제한 | 429 | `RATE_LIMITED` |
| 외부 종속성 장애 | 503 | `UPSTREAM_UNAVAILABLE` |

### cursor pagination
- 리스트는 기본적으로 최신순이다.
- cursor는 외부에 의미가 드러나지 않는 opaque string 이어야 한다.
- 구현은 `createdAt` 또는 `detectedAt`과 `id`를 조합한 base64url 인코딩을 사용한다.
- page size 기본값은 20, 최대값은 100이다.
- offset pagination은 사용하지 않는다.

## 인증과 세션
- access token TTL 기본값은 15분이다.
- refresh token TTL 기본값은 14일이다.
- refresh token은 JWT `jti`를 Redis에 폐기 목록으로 저장해 회수한다.
- logout은 현재 토큰의 `jti`를 폐기 목록에 넣는 동작이다.
- refresh 요청은 토큰 회전(rotation)을 수행한다.
- `403`은 계정/멤버/조직이 suspended 또는 closed 상태일 때 사용한다.
- 비밀번호 해시는 BCrypt를 사용한다.

## 데이터 매핑
- UUID는 모두 문자열 UUID로 주고받는다.
- 시각은 UTC ISO-8601 문자열을 사용한다.
- 금액은 KRW 숫자 값으로 주고받는다.
- enum 값은 스키마와 완전히 동일하게 맞춘다.
- `jsonb` 컬럼은 `JsonNode` 또는 `Map<String, Object>` 로 매핑한다.
- 엔티티는 API DTO와 분리한다.
- `ddl-auto=validate` 를 기본으로 두고, 스키마 변경은 Flyway로만 반영한다.

### JSON 필드 처리
- `events.old_value`, `events.new_value`, `alert_rules.filter_json`, `reports.payload_json`, `product_snapshots.raw_payload` 는 JSON 그대로 저장한다.
- 서비스 계층에서 필요한 값만 꺼내고 나머지는 투명하게 유지한다.
- JSON 구조를 바꿔야 하면 코드를 먼저 우회하지 말고 문서와 마이그레이션을 함께 갱신한다.

## 도메인 규칙
### 가격 계산
- `effectivePrice = listedPrice + shippingFee - couponPrice`
- `effectivePrice` 는 서비스에서 계산한다.
- 음수가 나오면 저장하지 말고 검증 실패로 처리한다.
- 스냅샷 요청이 오더라도 `effectivePrice` 는 클라이언트 입력을 신뢰하지 않는다.

### 스냅샷과 이벤트
- 스냅샷 저장은 `SnapshotIngestionService` 가 책임진다.
- 흐름은 `스냅샷 저장 -> 이전 스냅샷 조회 -> 이벤트 탐지 -> 이벤트 저장 -> 알림 큐 적재` 순서다.
- 최초 스냅샷은 baseline 으로만 저장하고 이벤트를 만들지 않는다.
- 동일 스냅샷에 대해 이벤트를 중복 생성하지 않는다.
- 이벤트 생성은 트랜잭션 안에서 수행한다.
- 경쟁상품 하나에 대해 동시에 여러 스냅샷이 들어오면 `FOR UPDATE` 또는 동등한 잠금 전략으로 순서를 보장한다.

### 이벤트 기준
- 가격 하락: 이전 `effectivePrice` 대비 3% 이상 하락
- 가격 상승: 이전 `effectivePrice` 대비 3% 이상 상승
- 최저가 갱신: 경쟁상품 중 최저 `effectivePrice` 변경
- 마진 위험: 경쟁사 최저가가 내 최소 마진 가격 이하
- 품절 전환: `in_stock -> out_of_stock`
- 재입고: `out_of_stock -> in_stock`
- 리뷰 급증: 24시간 내 리뷰 수 10개 이상 증가
- 평점 경고: 기본 임계치는 설정값으로 관리하고, 미설정 시 warning 이벤트를 생성하지 않는다

### 알림 규칙
- `alert_rules.rule_type` 과 `threshold` 는 서비스 계층에서 해석한다.
- `filter_json` 은 조직/카테고리/채널 같은 추가 조건을 담는 확장 필드로 취급한다.
- 알림 발송은 트랜잭션 바깥에서 수행한다.
- queued 알림은 `FOR UPDATE SKIP LOCKED` 방식으로 가져와 중복 발송을 막는다.
- 발송 실패는 `status=failed` 와 `error_message` 로 기록한다.

### 삭제 규칙
- `DELETE /monitored-products` 는 소프트 아카이브 처리로 구현한다.
- `DELETE /competitor-products` 는 `is_active=false` 로 구현한다.
- `DELETE /alert-rules` 는 `is_enabled=false` 로 구현한다.
- `DELETE /organizations/{organizationId}/members/{memberId}` 는 `status=suspended` 또는 동등한 비활성 처리로 구현한다.

## 조립해야 할 컴포넌트
### Security
- JWT 필터
- 인증 실패 핸들러
- 권한 실패 핸들러
- role 기반 접근 제어

### Persistence
- `JpaRepository` 기반 저장소
- 커스텀 검색 조건이 필요할 때만 명시적 query method 사용
- 공통 감사 필드 `createdAt`, `updatedAt`
- `@Transactional` 은 서비스 계층에만 사용

### Common
- `ApiResponse<T>`
- `PageResponse<T>`
- `ErrorResponse`
- `CursorCodec`
- `DomainException`
- `GlobalExceptionHandler`

### External adapters
- `EmailNotificationSender`
- `SlackNotificationSender`
- `KakaoWorkNotificationSender`
- `WebhookNotificationSender`
- `CompetitorSnapshotClient`
- `FixtureCompetitorSnapshotClient`

## 개발 프로파일
- `local` 또는 `dev` 프로파일에서는 외부 채널이 없어도 애플리케이션이 기동해야 한다.
- fixture 데이터로 다음을 제공한다.
  - 조직 1개
  - 관리자 1명
  - 모니터링 상품 1개
  - 경쟁상품 3개
  - 스냅샷 최소 3개
  - 이벤트 최소 3개
  - 알림 규칙 1개
  - 리포트 1개
- dev 프로파일은 실제 발송 대신 로그/메모리 대체 송신기를 사용할 수 있다.
- 프로덕션 프로파일만 실제 메일/웹훅 키를 사용한다.

## 테스트 기준
- 단위 테스트는 규칙 엔진, cursor codec, 예외 매핑, DTO 검증을 포함한다.
- 통합 테스트는 PostgreSQL과 Redis Testcontainers 를 사용한다.
- 컨트롤러 테스트는 401, 403, 404, 409 응답을 반드시 포함한다.
- 스냅샷 저장 -> 이벤트 생성 -> 알림 적재 흐름을 하나의 통합 테스트로 검증한다.
- 테스트는 H2 를 쓰지 않는다.

## 구현 순서
1. 프로젝트 부트스트랩과 공통 설정
2. 인증, 조직, 멤버십
3. 모니터링 상품, 경쟁상품
4. 스냅샷 저장과 이벤트 탐지
5. 알림 규칙과 알림 발송
6. 리포트
7. dev fixture와 smoke test
8. OpenAPI/문서와 코드 정합성 확인

## 완료 기준
- 애플리케이션이 로컬에서 기동된다.
- Flyway 마이그레이션이 정상 적용된다.
- 공개 API가 문서의 경로와 응답 형식을 따른다.
- 핵심 사용자 시나리오가 dev fixture 로 재현된다.
- `./gradlew test` 가 통과한다.
- `bootRun` 중 예외 없이 대시보드, 상품, 이벤트, 알림, 리포트 흐름을 확인할 수 있다.

## 하면 안 되는 것
- microservice 로 쪼개기
- H2 로 대체하기
- 엔티티를 그대로 API 응답으로 내보내기
- 외부 호출을 트랜잭션 안에서 직접 실행하기
- 문서에 없는 필드를 슬쩍 추가하기
- 코드 변경 후 문서와 마이그레이션을 갱신하지 않기

## 아직 남은 결정
- 실제 채널 수집 정책과 법무 허용 범위
- 평점 경고의 기본 임계치 세부값
- 프로덕션 메일/웹훅 공급자 선택
- billing/plan enforcement 방식

## 한 줄 지침
코드가 먼저가 아니라 계약이 먼저다. 이 문서와 연결된 스펙이 바뀌지 않았다면, 구현은 문서의 이름과 필드를 그대로 따라가야 한다.
