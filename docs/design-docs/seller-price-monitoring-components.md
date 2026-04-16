# 셀러용 가격 모니터링 컴포넌트 목록

이 문서는 [와이어프레임](./seller-price-monitoring-wireframes.md)을 실제 화면 구현 단위로 분해한 목록이다. 디자인 시스템이 아니라, 페이지별 조합과 재사용 경계를 먼저 정리하는 데 목적이 있다.

## 원칙
- 페이지는 레이아웃, 요약, 리스트, 상세, 설정으로 분해한다.
- 핵심 카드와 테이블은 재사용 가능한 컴포넌트로 만든다.
- 상태 표현은 컴포넌트의 일부로 포함한다.
- 모바일에서는 같은 컴포넌트를 다른 배치로 재조합한다.

## 공통 컴포넌트
### AppShell
- 역할: 상단 네비게이션과 본문 영역을 감싼다.
- 포함: Logo, WorkspaceSwitcher, DateRangePicker, GlobalSearch, AlertsMenu, UserMenu

### MetricCard
- 역할: 대시보드 상단 핵심 수치를 보여준다.
- props: `label`, `value`, `delta`, `tone`, `onClick`

### StatusBadge
- 역할: 수집 상태, 품절 상태, 읽음 상태를 표시한다.
- variants: `success`, `warning`, `danger`, `neutral`

### DataTimestamp
- 역할: 마지막 수집 시각과 최신성 정보를 보여준다.
- props: `collectedAt`, `sourceLabel`

### ActionMenu
- 역할: 메모, 무시, 핀 고정, 알림 조정과 같은 보조 행동을 제공한다.
- props: `items`, `onSelect`

### EmptyState
- 역할: 등록 전, 권한 없음, 데이터 없음 상태를 보여준다.

### LoadingState
- 역할: 수집 중, 동기화 중, 리포트 생성 중 상태를 보여준다.

### ErrorState
- 역할: 수집 실패, 권한 오류, 결제 만료를 분리해서 보여준다.

## 랜딩페이지 컴포넌트
### LandingHero
- 제목, 부제, CTA, 신뢰 문구를 포함한다.

### ProblemStrip
- 사용자의 현재 수작업 흐름을 짧은 카드로 요약한다.

### ValueCardGrid
- 가격, 품절, 리뷰, 알림, 리포트 같은 핵심 가치를 카드로 보여준다.

### DemoScreenshotPanel
- 대시보드와 상세 화면 미리보기를 배치한다.

### PricingTable
- Starter, Growth, Agency 플랜을 비교한다.

### FAQSection
- 수집 범위, 알림 빈도, 지원 채널, 보안 질문을 처리한다.

## 대시보드 컴포넌트
### DashboardSummaryRow
- 상단 MetricCard 5개를 배치한다.

### PriorityActionList
- 오늘 바로 대응할 상품 목록을 보여준다.
- 항목 필드: 상품명, 이유, 심각도, 예상 조치

### PriceTrendChart
- 기간별 시장 최저가와 내 기준가를 함께 보여준다.

### EventTimeline
- 최근 이벤트를 시간순으로 보여준다.

### SummaryEmailPreview
- 오늘 발송될 요약 메일을 미리 보여준다.

## 상품 상세 컴포넌트
### ProductHeader
- 내 상품명, 채널, 현재가, 최소 마진가, 시장 최저가 차이를 보여준다.
- 메모와 핀 고정 액션을 함께 둔다.

### CompetitorPriceTable
- 채널, 경쟁사, 상품명, 현재가, 배송비, 쿠폰 반영가, 리뷰 수, 평점, 품절 여부, 수집 시각을 보여준다.

### CompetitorPriceRow
- 테이블의 단일 행 컴포넌트다.

### ProductPriceHistoryChart
- 가격 이력과 최저가 이동을 보여준다.

### ProductEventPanel
- 상품 단위 이벤트를 카드형으로 보여준다.

### NotificationHistoryPanel
- 발송 이력과 읽음 상태를 보여준다.

### NoteComposer
- 메모를 남기고 수정하는 입력 컴포넌트다.

## 이벤트 센터 컴포넌트
### EventFilterChips
- 가격 하락, 가격 상승, 품절, 재입고, 리뷰 증가, 평점 하락을 필터 칩으로 제공한다.

### EventCard
- 이벤트 한 건의 요약 카드다.
- 포함: 무엇이 바뀌었는가, 언제 바뀌었는가, 얼마나 바뀌었는가, note, actions

### EventCardActions
- 메모, 무시, 핀 고정 버튼을 제공한다.

### EventDetailDrawer
- 선택한 이벤트를 상세하게 보는 측면 패널이다.

## 알림 설정 컴포넌트
### AlertRuleList
- 조직의 규칙 목록을 보여준다.

### AlertRuleEditor
- 규칙 생성/수정 폼이다.
- fields: rule type, threshold, delivery channel, category filter, enabled

### DeliveryChannelPicker
- Email, Slack, KakaoWork, Webhook 채널을 선택한다.

### QuietHoursEditor
- 알림 침묵 시간을 설정한다.

### ProductOverrideEditor
- 상품별 예외 규칙을 지정한다.

## 워크스페이스 / 멤버 / 결제 컴포넌트
### MemberTable
- 이름, 이메일, 역할, 상태, 초대일, 액션을 보여준다.

### MemberInviteForm
- 멤버 초대 폼이다.

### PlanCard
- 현재 플랜, 사용량, 초과 사용, 업그레이드 CTA를 보여준다.

### BillingPanel
- 결제 수단, 인보이스, 청구서 다운로드를 제공한다.

## 상태 조합 규칙
- 리스트 페이지는 `LoadingState -> DataTable -> EmptyState -> ErrorState` 순서로 대응한다.
- 대시보드 카드는 데이터가 없을 때 `0`을 보여주는 대신 이유를 설명해야 한다.
- 수집 실패는 전체 페이지 실패가 아니라 부분 실패로 보여주는 것을 우선한다.

## 컴포넌트 경계
- AppShell은 데이터 로직을 가지지 않는다.
- MetricCard와 StatusBadge는 도메인 독립적이어야 한다.
- EventCard와 CompetitorPriceRow는 도메인 전용으로 유지한다.
- 설정 컴포넌트는 API 스키마와 직접 대응되어야 한다.

## 참고 자료
- [와이어프레임](./seller-price-monitoring-wireframes.md)
- [API 명세](./seller-price-monitoring-api.md)
- [제품 명세](../product-specs/seller-price-monitoring.md)
