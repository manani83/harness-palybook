# 셀러용 가격 모니터링 Spring Boot 파일 맵

이 문서는 Controller / Service / Entity / DTO / Repository 파일을 기능별로 고정한다. 목적은 AI 에이전트가 구현을 시작할 때 파일을 어디에 둘지 더 이상 고민하지 않게 하는 것이다.

## 먼저 읽을 문서
- [Spring Boot 구현 가이드](./seller-price-monitoring-spring-boot-implementation-guide.md)
- [Spring Boot 프로젝트 골격](./seller-price-monitoring-spring-boot-project-skeleton.md)
- [API 명세](./seller-price-monitoring-api.md)
- [DB 스키마 SQL](../generated/seller-price-monitoring-schema.sql)
- [QA 체크리스트](../checklists/seller-price-monitoring-qa.md)

## 파일 분해 원칙
- controller는 HTTP만 다룬다.
- service는 트랜잭션과 도메인 규칙만 다룬다.
- entity는 영속성 필드만 가진다.
- DTO는 요청, 응답, 조회 projection만 가진다.
- repository는 저장과 조회만 담당한다.
- 외부 호출은 delivery 또는 ingestion 어댑터로 숨긴다.
- dashboard는 별도 feature package로 둔다.

## 공통 파일
| 레이어 | 파일 | 책임 |
| --- | --- | --- |
| App | `src/main/java/kr/co/harness/spm/SpmApplication.java` | 애플리케이션 진입점 |
| Config | `src/main/java/kr/co/harness/spm/config/ClockConfig.java` | UTC 시간 주입 |
| Config | `src/main/java/kr/co/harness/spm/config/JacksonConfig.java` | JSON 직렬화 규칙 |
| Config | `src/main/java/kr/co/harness/spm/config/WebMvcConfig.java` | CORS, path, interceptor 설정 |
| Config | `src/main/java/kr/co/harness/spm/config/SecurityConfig.java` | 보안 체인, JWT 필터, 접근 제어 |
| Config | `src/main/java/kr/co/harness/spm/config/JpaConfig.java` | JPA, 감사 필드, 검증 설정 |
| Config | `src/main/java/kr/co/harness/spm/config/RedisConfig.java` | Redis 연결과 템플릿 |
| Config | `src/main/java/kr/co/harness/spm/config/OpenApiConfig.java` | springdoc 설정 |
| Common | `src/main/java/kr/co/harness/spm/shared/api/ApiResponse.java` | 성공 응답 래퍼 |
| Common | `src/main/java/kr/co/harness/spm/shared/api/PageResponse.java` | cursor 목록 응답 래퍼 |
| Common | `src/main/java/kr/co/harness/spm/shared/api/ErrorResponse.java` | 오류 응답 래퍼 |
| Common | `src/main/java/kr/co/harness/spm/shared/exception/DomainException.java` | 비즈니스 예외 |
| Common | `src/main/java/kr/co/harness/spm/shared/exception/GlobalExceptionHandler.java` | 예외 -> HTTP 매핑 |
| Common | `src/main/java/kr/co/harness/spm/shared/cursor/CursorCodec.java` | opaque cursor 인코딩 |
| Common | `src/main/java/kr/co/harness/spm/shared/security/JwtAuthenticationFilter.java` | 토큰 인증 처리 |
| Common | `src/main/java/kr/co/harness/spm/shared/security/JwtTokenProvider.java` | JWT 생성/검증 |

## 인증
| 레이어 | 파일 | 책임 |
| --- | --- | --- |
| Controller | `src/main/java/kr/co/harness/spm/auth/controller/AuthController.java` | 로그인, 갱신, 로그아웃, 현재 사용자 |
| Service | `src/main/java/kr/co/harness/spm/auth/service/AuthService.java` | 로그인과 세션 오케스트레이션 |
| Service | `src/main/java/kr/co/harness/spm/auth/service/TokenService.java` | access/refresh 토큰 관리 |
| Service | `src/main/java/kr/co/harness/spm/auth/service/CurrentUserService.java` | `GET /me` 응답 조립 |
| Entity | `src/main/java/kr/co/harness/spm/auth/entity/User.java` | `users` 테이블 매핑 |
| Entity | `src/main/java/kr/co/harness/spm/auth/entity/RefreshToken.java` | refresh token `jti` 추적 |
| Repository | `src/main/java/kr/co/harness/spm/auth/repository/UserRepository.java` | 이메일/ID 조회 |
| Repository | `src/main/java/kr/co/harness/spm/auth/repository/RefreshTokenRepository.java` | 폐기된 토큰 조회 |
| DTO | `src/main/java/kr/co/harness/spm/auth/dto/LoginRequest.java` | 로그인 요청 |
| DTO | `src/main/java/kr/co/harness/spm/auth/dto/RefreshRequest.java` | 토큰 갱신 요청 |
| DTO | `src/main/java/kr/co/harness/spm/auth/dto/TokenResponse.java` | 토큰 응답 |
| DTO | `src/main/java/kr/co/harness/spm/auth/dto/MeResponse.java` | 현재 사용자 응답 |

## 조직과 멤버십
| 레이어 | 파일 | 책임 |
| --- | --- | --- |
| Controller | `src/main/java/kr/co/harness/spm/organization/controller/OrganizationController.java` | 조직 CRUD |
| Controller | `src/main/java/kr/co/harness/spm/organization/controller/OrganizationMemberController.java` | 멤버 조회/제거 |
| Controller | `src/main/java/kr/co/harness/spm/organization/controller/OrganizationInviteController.java` | 초대 발송/수락 |
| Service | `src/main/java/kr/co/harness/spm/organization/service/OrganizationService.java` | 조직 생성/수정/상세 |
| Service | `src/main/java/kr/co/harness/spm/organization/service/OrganizationMemberService.java` | 멤버 상태 변경 |
| Service | `src/main/java/kr/co/harness/spm/organization/service/OrganizationInviteService.java` | 초대 토큰 발급/검증 |
| Entity | `src/main/java/kr/co/harness/spm/organization/entity/Organization.java` | 조직 테이블 |
| Entity | `src/main/java/kr/co/harness/spm/organization/entity/OrganizationMember.java` | 조직 멤버 테이블 |
| Entity | `src/main/java/kr/co/harness/spm/organization/entity/OrganizationInvite.java` | 초대 테이블 |
| Repository | `src/main/java/kr/co/harness/spm/organization/repository/OrganizationRepository.java` | 조직 조회 |
| Repository | `src/main/java/kr/co/harness/spm/organization/repository/OrganizationMemberRepository.java` | 멤버 조회 |
| Repository | `src/main/java/kr/co/harness/spm/organization/repository/OrganizationInviteRepository.java` | 초대 조회 |
| DTO | `src/main/java/kr/co/harness/spm/organization/dto/OrganizationCreateRequest.java` | 조직 생성 요청 |
| DTO | `src/main/java/kr/co/harness/spm/organization/dto/OrganizationUpdateRequest.java` | 조직 수정 요청 |
| DTO | `src/main/java/kr/co/harness/spm/organization/dto/OrganizationResponse.java` | 조직 응답 |
| DTO | `src/main/java/kr/co/harness/spm/organization/dto/MemberResponse.java` | 멤버 응답 |
| DTO | `src/main/java/kr/co/harness/spm/organization/dto/InviteCreateRequest.java` | 초대 발송 요청 |
| DTO | `src/main/java/kr/co/harness/spm/organization/dto/InviteResponse.java` | 초대 응답 |

## 대시보드
| 레이어 | 파일 | 책임 |
| --- | --- | --- |
| Controller | `src/main/java/kr/co/harness/spm/dashboard/controller/DashboardController.java` | 요약 카드 조회 |
| Service | `src/main/java/kr/co/harness/spm/dashboard/service/DashboardSummaryService.java` | 오늘의 요약 계산 |
| DTO | `src/main/java/kr/co/harness/spm/dashboard/dto/DashboardSummaryResponse.java` | 요약 응답 |
| DTO | `src/main/java/kr/co/harness/spm/dashboard/dto/DashboardActionItemResponse.java` | 대응 우선순위 항목 |

## 모니터링 상품
| 레이어 | 파일 | 책임 |
| --- | --- | --- |
| Controller | `src/main/java/kr/co/harness/spm/monitoredproduct/controller/MonitoredProductController.java` | 모니터링 상품 CRUD |
| Service | `src/main/java/kr/co/harness/spm/monitoredproduct/service/MonitoredProductService.java` | 등록/수정/아카이브 |
| Service | `src/main/java/kr/co/harness/spm/monitoredproduct/service/MonitoredProductQueryService.java` | 목록/상세 조회 |
| Entity | `src/main/java/kr/co/harness/spm/monitoredproduct/entity/MonitoredProduct.java` | 모니터링 상품 테이블 |
| Repository | `src/main/java/kr/co/harness/spm/monitoredproduct/repository/MonitoredProductRepository.java` | 상품 조회 |
| DTO | `src/main/java/kr/co/harness/spm/monitoredproduct/dto/MonitoredProductCreateRequest.java` | 생성 요청 |
| DTO | `src/main/java/kr/co/harness/spm/monitoredproduct/dto/MonitoredProductUpdateRequest.java` | 수정 요청 |
| DTO | `src/main/java/kr/co/harness/spm/monitoredproduct/dto/MonitoredProductResponse.java` | 상세 응답 |
| DTO | `src/main/java/kr/co/harness/spm/monitoredproduct/dto/MonitoredProductListItemResponse.java` | 목록 응답 |

## 경쟁상품
| 레이어 | 파일 | 책임 |
| --- | --- | --- |
| Controller | `src/main/java/kr/co/harness/spm/competitorproduct/controller/CompetitorProductController.java` | 경쟁상품 CRUD |
| Service | `src/main/java/kr/co/harness/spm/competitorproduct/service/CompetitorProductService.java` | 등록/수정/비활성화 |
| Service | `src/main/java/kr/co/harness/spm/competitorproduct/service/CompetitorProductQueryService.java` | 조회와 활성화 필터 |
| Entity | `src/main/java/kr/co/harness/spm/competitorproduct/entity/CompetitorProduct.java` | 경쟁상품 테이블 |
| Repository | `src/main/java/kr/co/harness/spm/competitorproduct/repository/CompetitorProductRepository.java` | 경쟁상품 조회 |
| DTO | `src/main/java/kr/co/harness/spm/competitorproduct/dto/CompetitorProductCreateRequest.java` | 생성 요청 |
| DTO | `src/main/java/kr/co/harness/spm/competitorproduct/dto/CompetitorProductUpdateRequest.java` | 수정 요청 |
| DTO | `src/main/java/kr/co/harness/spm/competitorproduct/dto/CompetitorProductResponse.java` | 상세 응답 |
| DTO | `src/main/java/kr/co/harness/spm/competitorproduct/dto/CompetitorProductListItemResponse.java` | 목록 응답 |

## 스냅샷
| 레이어 | 파일 | 책임 |
| --- | --- | --- |
| Controller | `src/main/java/kr/co/harness/spm/snapshot/controller/SnapshotController.java` | 경쟁상품 스냅샷 조회 |
| Service | `src/main/java/kr/co/harness/spm/snapshot/service/SnapshotQueryService.java` | 스냅샷 목록/상세 조회 |
| Service | `src/main/java/kr/co/harness/spm/snapshot/service/SnapshotIngestionService.java` | 스냅샷 저장과 이벤트 트리거 |
| Entity | `src/main/java/kr/co/harness/spm/snapshot/entity/ProductSnapshot.java` | 스냅샷 테이블 |
| Repository | `src/main/java/kr/co/harness/spm/snapshot/repository/ProductSnapshotRepository.java` | 스냅샷 조회 |
| DTO | `src/main/java/kr/co/harness/spm/snapshot/dto/SnapshotResponse.java` | 스냅샷 응답 |
| DTO | `src/main/java/kr/co/harness/spm/snapshot/dto/SnapshotListItemResponse.java` | 목록 응답 |
| DTO | `src/main/java/kr/co/harness/spm/snapshot/dto/SnapshotIngestionCommand.java` | 내부 적재 명령 |

## 이벤트
| 레이어 | 파일 | 책임 |
| --- | --- | --- |
| Controller | `src/main/java/kr/co/harness/spm/event/controller/EventController.java` | 이벤트 조회/수정 |
| Service | `src/main/java/kr/co/harness/spm/event/service/EventService.java` | 읽음, 메모, 핀 처리 |
| Service | `src/main/java/kr/co/harness/spm/event/service/EventDetectionService.java` | 이벤트 규칙 적용 |
| Entity | `src/main/java/kr/co/harness/spm/event/entity/Event.java` | 이벤트 테이블 |
| Repository | `src/main/java/kr/co/harness/spm/event/repository/EventRepository.java` | 이벤트 조회 |
| DTO | `src/main/java/kr/co/harness/spm/event/dto/EventResponse.java` | 상세 응답 |
| DTO | `src/main/java/kr/co/harness/spm/event/dto/EventListItemResponse.java` | 목록 응답 |
| DTO | `src/main/java/kr/co/harness/spm/event/dto/EventPatchRequest.java` | 읽음/메모/핀 변경 |

## 알림 규칙
| 레이어 | 파일 | 책임 |
| --- | --- | --- |
| Controller | `src/main/java/kr/co/harness/spm/alert/controller/AlertRuleController.java` | 알림 규칙 CRUD |
| Service | `src/main/java/kr/co/harness/spm/alert/service/AlertRuleService.java` | 규칙 검증과 저장 |
| Entity | `src/main/java/kr/co/harness/spm/alert/entity/AlertRule.java` | 알림 규칙 테이블 |
| Repository | `src/main/java/kr/co/harness/spm/alert/repository/AlertRuleRepository.java` | 규칙 조회 |
| DTO | `src/main/java/kr/co/harness/spm/alert/dto/AlertRuleCreateRequest.java` | 생성 요청 |
| DTO | `src/main/java/kr/co/harness/spm/alert/dto/AlertRuleUpdateRequest.java` | 수정 요청 |
| DTO | `src/main/java/kr/co/harness/spm/alert/dto/AlertRuleResponse.java` | 상세 응답 |
| DTO | `src/main/java/kr/co/harness/spm/alert/dto/AlertRuleListItemResponse.java` | 목록 응답 |

## 알림
| 레이어 | 파일 | 책임 |
| --- | --- | --- |
| Controller | `src/main/java/kr/co/harness/spm/notification/controller/NotificationController.java` | 알림 목록/상태 변경 |
| Service | `src/main/java/kr/co/harness/spm/notification/service/NotificationService.java` | 알림 상태 변경 |
| Service | `src/main/java/kr/co/harness/spm/notification/service/NotificationDispatchService.java` | 큐에서 꺼내 발송 |
| Entity | `src/main/java/kr/co/harness/spm/notification/entity/Notification.java` | 알림 테이블 |
| Repository | `src/main/java/kr/co/harness/spm/notification/repository/NotificationRepository.java` | 알림 조회 |
| DTO | `src/main/java/kr/co/harness/spm/notification/dto/NotificationResponse.java` | 상세 응답 |
| DTO | `src/main/java/kr/co/harness/spm/notification/dto/NotificationListItemResponse.java` | 목록 응답 |
| DTO | `src/main/java/kr/co/harness/spm/notification/dto/NotificationPatchRequest.java` | 읽음/상태 변경 |

## 리포트
| 레이어 | 파일 | 책임 |
| --- | --- | --- |
| Controller | `src/main/java/kr/co/harness/spm/report/controller/ReportController.java` | 리포트 조회 |
| Service | `src/main/java/kr/co/harness/spm/report/service/ReportService.java` | 리포트 생성/조회 |
| Entity | `src/main/java/kr/co/harness/spm/report/entity/Report.java` | 리포트 테이블 |
| Repository | `src/main/java/kr/co/harness/spm/report/repository/ReportRepository.java` | 리포트 조회 |
| DTO | `src/main/java/kr/co/harness/spm/report/dto/ReportResponse.java` | 상세 응답 |
| DTO | `src/main/java/kr/co/harness/spm/report/dto/ReportListItemResponse.java` | 목록 응답 |

## 적재와 전송
| 레이어 | 파일 | 책임 |
| --- | --- | --- |
| Service | `src/main/java/kr/co/harness/spm/ingestion/SnapshotIngestionOrchestrator.java` | 스냅샷 적재 흐름 제어 |
| Service | `src/main/java/kr/co/harness/spm/ingestion/EventDetectionService.java` | 이벤트 탐지 엔진 |
| Port | `src/main/java/kr/co/harness/spm/ingestion/CompetitorSnapshotClient.java` | 스냅샷 수집 포트 |
| Port | `src/main/java/kr/co/harness/spm/delivery/NotificationSender.java` | 알림 전송 공통 포트 |
| Adapter | `src/main/java/kr/co/harness/spm/delivery/EmailNotificationSender.java` | 이메일 전송 |
| Adapter | `src/main/java/kr/co/harness/spm/delivery/SlackNotificationSender.java` | Slack 전송 |
| Adapter | `src/main/java/kr/co/harness/spm/delivery/KakaoWorkNotificationSender.java` | 카카오워크 전송 |
| Adapter | `src/main/java/kr/co/harness/spm/delivery/WebhookNotificationSender.java` | 웹훅 전송 |
| Adapter | `src/main/java/kr/co/harness/spm/fixture/FixtureCompetitorSnapshotClient.java` | dev 프로파일 대체 수집기 |
| Adapter | `src/main/java/kr/co/harness/spm/fixture/DevDataLoader.java` | 개발용 샘플 데이터 주입 |

## 생성 순서
1. `shared`와 `config`를 만든다.
2. `auth`와 `organization`을 만든다.
3. `dashboard`를 만든다.
4. `monitoredproduct`와 `competitorproduct`를 만든다.
5. `snapshot`과 `event`를 만든다.
6. `alert`와 `notification`을 만든다.
7. `report`, `ingestion`, `delivery`, `fixture`를 만든다.
8. 각 feature에 DTO를 추가한다.
9. 마지막에 통합 테스트를 붙인다.

## 하지 말아야 할 분해
- controller마다 service를 하나 이상 억지로 만들지 않는다.
- entity와 DTO를 1:1로 강제로 복제하지 않는다.
- repository를 기능별로 과도하게 잘게 쪼개지 않는다.
- 외부 연동 코드를 service 안에 직접 박아 넣지 않는다.
- 문서에 없는 파일명을 임의로 추가하지 않는다.
