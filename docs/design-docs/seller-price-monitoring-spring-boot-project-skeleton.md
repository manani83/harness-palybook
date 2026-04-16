# 셀러용 가격 모니터링 Spring Boot 프로젝트 골격

이 문서는 AI 에이전트가 Spring Boot 저장소를 처음 만들 때 따라야 할 디렉터리 구조와 초기 클래스 생성 순서를 고정한다. 목적은 부트스트랩 단계에서 패키지와 파일 경계가 흔들리지 않게 하는 것이다.

## 먼저 읽을 문서
- [Spring Boot 구현 가이드](./seller-price-monitoring-spring-boot-implementation-guide.md)
- [설계 문서](./seller-price-monitoring.md)
- [API 명세](./seller-price-monitoring-api.md)
- [OpenAPI](../generated/seller-price-monitoring-openapi.yaml)
- [DB 스키마 SQL](../generated/seller-price-monitoring-schema.sql)
- [QA 체크리스트](../checklists/seller-price-monitoring-qa.md)
- [실행 계획](../exec-plans/active/2026-04-16-seller-price-monitoring.md)

## 고정 전제
- 기본 루트 패키지는 `kr.co.harness.spm`이다.
- 패키지는 기능 기준으로 나눈다.
- `dashboard`는 별도 기능 패키지로 둔다.
- `report`는 `dashboard`와 분리한다.
- 컨트롤러는 HTTP만 담당한다.
- 서비스는 트랜잭션과 도메인 규칙만 담당한다.
- 엔티티는 영속성 필드만 가진다.
- DTO는 요청/응답 전용이다.

## 저장소 골격
```text
settings.gradle.kts
build.gradle.kts
gradle/wrapper/...
src/main/java/kr/co/harness/spm/SpmApplication.java
src/main/java/kr/co/harness/spm/config/
src/main/java/kr/co/harness/spm/shared/
src/main/java/kr/co/harness/spm/auth/
src/main/java/kr/co/harness/spm/organization/
src/main/java/kr/co/harness/spm/dashboard/
src/main/java/kr/co/harness/spm/monitoredproduct/
src/main/java/kr/co/harness/spm/competitorproduct/
src/main/java/kr/co/harness/spm/snapshot/
src/main/java/kr/co/harness/spm/event/
src/main/java/kr/co/harness/spm/alert/
src/main/java/kr/co/harness/spm/notification/
src/main/java/kr/co/harness/spm/report/
src/main/java/kr/co/harness/spm/ingestion/
src/main/java/kr/co/harness/spm/delivery/
src/main/java/kr/co/harness/spm/fixture/
src/main/resources/application.yml
src/main/resources/application-local.yml
src/main/resources/application-dev.yml
src/main/resources/application-test.yml
src/main/resources/db/migration/
src/main/resources/logback-spring.xml
src/test/java/kr/co/harness/spm/
```

## 최초 생성 순서
| 순서 | 파일 | 역할 | 비고 |
| --- | --- | --- | --- |
| 1 | `SpmApplication.java` | Spring Boot 진입점 | 패키지 스캔 기준점 |
| 2 | `config/ClockConfig.java` | 시간 기준 설정 | UTC 기준 주입 |
| 3 | `config/JacksonConfig.java` | JSON 직렬화 설정 | camelCase/UTC 정렬 |
| 4 | `config/WebMvcConfig.java` | CORS와 HTTP 공통 설정 | API 경로 정리 |
| 5 | `config/SecurityConfig.java` | 보안 설정 | JWT 필터 연결 |
| 6 | `config/JpaConfig.java` | JPA 설정 | 감사 필드와 검증 설정 |
| 7 | `config/RedisConfig.java` | Redis 설정 | 토큰 폐기와 락 지원 |
| 8 | `config/OpenApiConfig.java` | OpenAPI 설정 | springdoc 문서화 |
| 9 | `shared/api/ApiResponse.java` | 공통 성공 응답 | `data`/`meta` 구조 |
| 10 | `shared/api/PageResponse.java` | 공통 목록 응답 | cursor pagination 전용 |
| 11 | `shared/api/ErrorResponse.java` | 공통 오류 응답 | `error.code` 고정 |
| 12 | `shared/exception/DomainException.java` | 도메인 예외 | 상태 코드 매핑 기준 |
| 13 | `shared/exception/GlobalExceptionHandler.java` | 전역 예외 처리 | 400/401/403/404/409/429/503 |
| 14 | `shared/cursor/CursorCodec.java` | cursor 인코딩/디코딩 | opaque cursor 보장 |
| 15 | `auth/controller/AuthController.java` | 로그인/갱신/로그아웃/현재 사용자 | `GET /me` 포함 |
| 16 | `auth/service/AuthService.java` | 인증 오케스트레이션 | 토큰 발급과 회수 |
| 17 | `auth/service/TokenService.java` | JWT 생성/검증 | access/refresh 분리 |
| 18 | `auth/entity/User.java` | 사용자 영속성 모델 | `users` 테이블 매핑 |
| 19 | `auth/entity/RefreshToken.java` | refresh token 모델 | `jti` 폐기 추적 |
| 20 | `organization/controller/OrganizationController.java` | 워크스페이스 CRUD | 조직 상세/수정 |
| 21 | `organization/controller/OrganizationMemberController.java` | 멤버 조회/제거 | `status` 관리 |
| 22 | `organization/controller/OrganizationInviteController.java` | 초대 발송/수락 | `POST /organizations/{organizationId}/invites` |
| 23 | `dashboard/controller/DashboardController.java` | 대시보드 요약 | `GET /dashboard/summary` |
| 24 | `monitoredproduct/controller/MonitoredProductController.java` | 모니터링 상품 CRUD | 등록/수정/아카이브 |
| 25 | `competitorproduct/controller/CompetitorProductController.java` | 경쟁상품 CRUD | 활성/비활성 관리 |
| 26 | `snapshot/controller/SnapshotController.java` | 스냅샷 조회 | `GET /competitor-products/{id}/snapshots` |
| 27 | `event/controller/EventController.java` | 이벤트 조회/수정 | 읽음, 메모, 핀 |
| 28 | `alert/controller/AlertRuleController.java` | 알림 규칙 CRUD | 활성/비활성 관리 |
| 29 | `notification/controller/NotificationController.java` | 알림 조회/상태 변경 | 큐/발송 결과 포함 |
| 30 | `report/controller/ReportController.java` | 리포트 조회 | 일간/주간/클라이언트 |
| 31 | `ingestion/SnapshotIngestionOrchestrator.java` | 수집 오케스트레이션 | 스냅샷 -> 이벤트 -> 알림 |
| 32 | `delivery/NotificationSender.java` | 알림 전송 공통 포트 | 메일/Slack/웹훅 공통 |
| 33 | `delivery/EmailNotificationSender.java` | 메일 전송 구현체 | dev 프로파일 대체 가능 |
| 34 | `fixture/DevDataLoader.java` | 개발용 샘플 데이터 | 로컬 smoke test 지원 |

## 첫 테스트 파일
| 파일 | 역할 |
| --- | --- |
| `src/test/java/kr/co/harness/spm/shared/cursor/CursorCodecTest.java` | cursor 인코딩/디코딩 검증 |
| `src/test/java/kr/co/harness/spm/shared/exception/GlobalExceptionHandlerTest.java` | 예외 -> 상태 코드 매핑 검증 |
| `src/test/java/kr/co/harness/spm/auth/controller/AuthControllerTest.java` | 로그인/갱신/로그아웃 응답 검증 |
| `src/test/java/kr/co/harness/spm/dashboard/controller/DashboardControllerTest.java` | 요약 응답 검증 |
| `src/test/java/kr/co/harness/spm/snapshot/service/SnapshotIngestionServiceTest.java` | 스냅샷 -> 이벤트 생성 검증 |
| `src/test/java/kr/co/harness/spm/alert/service/AlertRuleServiceTest.java` | 규칙 해석 검증 |
| `src/test/java/kr/co/harness/spm/report/controller/ReportControllerTest.java` | 리포트 조회 검증 |
| `src/test/java/kr/co/harness/spm/snapshot/service/SnapshotIngestionServiceIT.java` | PostgreSQL/Redis 통합 검증 |

## 생성 규칙
- 먼저 `config`, `shared`, `auth`를 만들고 애플리케이션이 뜨는지 확인한다.
- 그다음 `organization`과 `dashboard`를 만든다.
- 이후 도메인 패키지를 하나씩 추가한다.
- 파일 이름은 역할이 드러나도록 유지한다.
- 나중에 필요해 보인다고 파일을 미리 늘리지 않는다.
- 골격 문서에 없는 새 패키지가 필요하면 먼저 이 문서를 갱신한다.

## 검증 기준
- 저장소 골격만으로 패키지 경계가 읽혀야 한다.
- 다음 단계의 파일 맵 문서 없이도 기본 순서는 정해져 있어야 한다.
- `dashboard`와 `report`가 같은 패키지로 섞이지 않아야 한다.
