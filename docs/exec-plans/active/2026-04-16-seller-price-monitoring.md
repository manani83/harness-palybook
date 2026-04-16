# 셀러용 가격 모니터링 + 경쟁사 추적 실행 계획

이 계획은 제품 명세와 설계 문서를 실행 가능한 문서 세트로 완성하기 위한 작업 순서다. 구현 코드는 만들지 않고, 와이어프레임, DB 스키마, API 명세, 교차 링크의 정합성을 맞춘다.

## 목표
- 셀러용 가격 모니터링 서비스의 문서 작업 범위를 고정한다.
- 핵심 화면 와이어프레임, DB 스키마 SQL, API 명세를 서로 일치시킨다.
- 문서 인덱스와 교차 링크를 최신 상태로 유지한다.

## 범위
- [제품 명세](../../product-specs/seller-price-monitoring.md)
- [설계 문서](../../design-docs/seller-price-monitoring.md)
- [화면 와이어프레임](../../design-docs/seller-price-monitoring-wireframes.md)
- [컴포넌트 목록](../../design-docs/seller-price-monitoring-components.md)
- [문구와 상태 메시지](../../design-docs/seller-price-monitoring-copy.md)
- [API 명세](../../design-docs/seller-price-monitoring-api.md)
- [Spring Boot 구현 가이드](../../design-docs/seller-price-monitoring-spring-boot-implementation-guide.md)
- [Spring Boot 프로젝트 골격](../../design-docs/seller-price-monitoring-spring-boot-project-skeleton.md)
- [Spring Boot 파일 맵](../../design-docs/seller-price-monitoring-spring-boot-file-map.md)
- [Spring Boot 재개 가이드](../../design-docs/seller-price-monitoring-spring-boot-restart-guide.md)
- [OpenAPI](../../generated/seller-price-monitoring-openapi.yaml)
- [QA 체크리스트](../../checklists/seller-price-monitoring-qa.md)
- [DB 스키마 SQL](../../generated/seller-price-monitoring-schema.sql)
- [DB 마이그레이션 001](../../generated/seller-price-monitoring-migrations/001_init.sql)
- [DB 마이그레이션 002](../../generated/seller-price-monitoring-migrations/002_indexes.sql)
- [외부 참조 자료](../../references/seller-price-monitoring-market-context.md)
- 관련 인덱스 갱신
- 용어와 필드명 정합성 점검

## 가정
- v1은 쿠팡과 스마트스토어만 대상으로 한다.
- 추적 기준은 사용자가 직접 등록한 상품 링크다.
- 가격 비교는 최종 소비자 판매가를 기준으로 해석한다.
- 알림 채널은 이메일과 하나의 웹훅부터 시작한다.
- 공식 API가 있으면 먼저 사용하고, 없으면 허용된 공개 페이지만 추적한다.

## 비목표
- 프런트엔드 코드 구현
- 백엔드 코드 구현
- 크롤링/수집기의 실제 연동
- 결제 시스템 연동
- 법무 검토 완료

## 마일스톤
1. 화면 범위와 정보 구조를 고정한다.
2. 와이어프레임 문서를 작성한다.
3. DB 스키마 SQL 초안을 작성한다.
4. API 명세 초안을 작성한다.
5. 교차 링크와 인덱스를 정리한다.
6. 용어, 테이블, 엔드포인트의 이름을 한 번 더 맞춘다.
7. Spring Boot 프로젝트 골격과 파일 맵을 추가한다.

## 작업 분해
| 티켓 | 작업 | 산출물 | 완료 기준 |
| --- | --- | --- | --- |
| DOC-01 | 핵심 화면 문구와 상태 메시지 정리 | `seller-price-monitoring-copy.md` | 랜딩, 대시보드, 상세, 이벤트, 알림, 공통 상태 문구가 정의된다 |
| DOC-02 | 화면 구조와 컴포넌트 경계 정리 | `seller-price-monitoring-wireframes.md`, `seller-price-monitoring-components.md` | 각 화면이 재사용 가능한 컴포넌트로 분해된다 |
| API-01 | API 계약과 예시 정리 | `seller-price-monitoring-api.md`, `seller-price-monitoring-openapi.yaml` | 주요 요청/응답 예시와 엔드포인트별 401/403/404/409 조건이 정의된다 |
| GEN-01 | DB 구조와 생성 산출물 정리 | `seller-price-monitoring-schema.sql`, `001_init.sql`, `002_indexes.sql` | 생성 SQL과 인덱스 분할이 일치한다 |
| LINK-01 | 인덱스와 교차 링크 정리 | `docs/design-docs/index.md`, `docs/generated/index.md`, `docs/exec-plans/active/index.md` | 모든 새 문서가 인덱스에서 발견된다 |
| REF-01 | 외부 근거 정리 | `seller-price-monitoring-market-context.md`, `docs/references/index.md` | 시장 맥락과 가격 기준의 출처가 문서에 연결된다 |
| GUIDE-01 | 구현 가이드 정리 | `seller-price-monitoring-spring-boot-implementation-guide.md` | AI 에이전트가 따를 Spring Boot 구현 계약이 고정된다 |
| DOC-03 | Spring Boot 프로젝트 골격 정리 | `seller-price-monitoring-spring-boot-project-skeleton.md` | AI 에이전트가 생성할 디렉터리와 초기 클래스 순서가 고정된다 |
| DOC-04 | Controller/Service/Entity/DTO/Repository 파일 맵 정리 | `seller-price-monitoring-spring-boot-file-map.md` | 기능별 파일 책임과 경계가 고정된다 |
| DOC-05 | Spring Boot 재개 가이드 정리 | `seller-price-monitoring-spring-boot-restart-guide.md` | 내일 이어서 작업할 때 읽는 단일 진입점이 고정된다 |

## 구현 백로그
| 티켓 | 영역 | 작업 | 의존성 | 완료 기준 |
| --- | --- | --- | --- | --- |
| SPM-FE-01 | 프런트엔드 | 공통 AppShell과 대시보드 레이아웃 구현 | DOC-02, DOC-01 | 대시보드 진입 시 상단 네비게이션과 요약 카드가 보인다 |
| SPM-FE-02 | 프런트엔드 | 모니터링 상품 목록과 상세 화면 구현 | DOC-02, API-01 | 상품 등록, 목록, 상세, 메모, 핀 고정이 동작한다 |
| SPM-FE-03 | 프런트엔드 | 이벤트 센터와 알림 설정 화면 구현 | DOC-02, DOC-01, API-01 | 이벤트 필터, 상태 변경, 알림 규칙 편집이 동작한다 |
| SPM-FE-04 | 프런트엔드 | 로그인, 워크스페이스, 멤버, 결제 화면 구현 | DOC-02, API-01 | 초대 수락, 멤버 관리, 플랜 확인이 가능하다 |
| SPM-BE-01 | 백엔드 | 인증과 조직/멤버십 API 구현 | API-01, GEN-01, DOC-03, DOC-04 | 로그인, 토큰 갱신, 워크스페이스 CRUD가 응답한다 |
| SPM-BE-02 | 백엔드 | 모니터링 상품과 경쟁상품 API 구현 | API-01, GEN-01, DOC-03, DOC-04 | 상품 등록, 경쟁상품 등록, 비활성화가 동작한다 |
| SPM-BE-03 | 백엔드 | 이벤트 감지와 조회 API 구현 | API-01, GEN-01, DOC-03, DOC-04 | 이벤트 목록, 이벤트 수정, 읽음 처리, 핀 고정이 동작한다 |
| SPM-BE-04 | 백엔드 | 알림 규칙과 리포트 API 구현 | API-01, GEN-01, DOC-03, DOC-04 | 알림 규칙 CRUD와 일간 리포트 조회가 가능하다 |
| SPM-DATA-01 | 데이터 | 마이그레이션 적용과 인덱스 검증 | GEN-01 | core schema와 index migration이 실제 DB에 적용된다 |
| SPM-DATA-02 | 데이터 | 스냅샷 집계와 이벤트 생성 규칙 연결 | GEN-01, API-01, DOC-03, DOC-04 | 가격 변동, 품절, 리뷰 이벤트가 스냅샷 기준으로 생성된다 |
| SPM-OPS-01 | 운영 | 알림 전송과 실패 재시도 정책 구현 | API-01, DOC-03, DOC-04 | 이메일/Slack/웹훅 알림이 발송되고 실패가 기록된다 |
| SPM-QA-01 | 검증 | 핵심 사용자 시나리오 스모크 테스트 | DOC-01, DOC-02, API-01, DOC-03, DOC-04 | QA 체크리스트가 작성되고 대시보드, 상세, 이벤트, 알림의 핵심 흐름이 통과한다 |

## 담당자
- 문서 오너: Codex
- 검토자: 사용자
- 구현 오너: 후속 개발 담당자

## 위험
- 팀/워크스페이스 모델이 불명확하면 스키마와 API가 어긋날 수 있다.
- 화면 우선순위가 흔들리면 MVP 범위가 넓어진다.
- `실질 판매가`와 이벤트 정의가 문서마다 다르게 쓰일 수 있다.
- 생성 산출물과 정본 문서가 섞이면 유지보수가 어려워진다.

## 검증
- 모든 문서가 서로 링크된다.
- 같은 용어가 같은 의미로 쓰인다.
- 화면 구성, API 필드, DB 컬럼명이 서로 충돌하지 않는다.
- 알림, 이벤트, 멤버십 모델이 하나의 흐름으로 읽힌다.
- 수집 실패와 알림 실패가 사용자에게 보이는 상태로 남는다.
- 권한이 없는 요청은 명확한 오류로 막힌다.

### 핵심 시나리오
1. 신규 사용자가 로그인해 대시보드 요약을 본다.
2. 모니터링 상품과 경쟁상품을 등록하고 첫 스냅샷을 저장한다.
3. 가격 하락 또는 품절 이벤트가 생성되고 알림이 발송된다.
4. 이벤트를 읽음 처리하고 메모와 핀 상태를 변경한다.
5. 알림 규칙 임계치를 바꾸고 이후 이벤트 반응 차이를 확인한다.

## 롤백 또는 대체 경로
- 스키마가 과하면 `organization_invites`와 `notifications`를 후속 범위로 미룬다.
- API가 너무 넓으면 v1은 대시보드, 상품 등록, 이벤트, 알림 설정만 남긴다.
- 와이어프레임이 과밀하면 상세 화면과 팀 관리 화면의 밀도를 줄인다.

## 완료 기준
- 실행 계획, 와이어프레임, DB 스키마, API 명세가 모두 작성됐다.
- 관련 인덱스가 갱신됐다.
- 설계 문서의 참고 자료가 새 산출물을 가리킨다.
- 외부 근거가 참고 자료로 분리되어 제품 가정과 출처가 연결된다.
- Spring Boot 구현 가이드가 코드 작성 기준으로 연결된다.
- 프로젝트 골격과 파일 맵 문서가 추가됐다.
- 재개 가이드가 추가됐다.
- 후속 구현자가 다음 단계에서 무엇을 만들어야 하는지 문서만으로 알 수 있다.
- 구현 백로그가 프런트엔드, 백엔드, 데이터, 운영, 검증으로 나뉘어 있다.
