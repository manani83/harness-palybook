# 셀러용 가격 모니터링 API 명세

이 문서는 셀러용 가격 모니터링 서비스의 v1 REST API 초안이다. 프런트엔드, DB 스키마, 실행 계획이 같은 용어와 필드명을 쓰도록 기준을 고정하는 것이 목적이다.

## 설계 전제
- API는 `/api/v1`을 기본 경로로 사용한다.
- 인증은 JWT Bearer 토큰을 사용한다.
- JSON 필드는 camelCase를 사용하고, DB 컬럼은 snake_case를 사용한다.
- 시각은 ISO-8601 UTC 문자열로 반환한다.
- 금액은 KRW 기준 숫자 값으로 반환한다.
- 목록 응답은 cursor pagination을 기본으로 한다.
- 공통 필드와 에러 형식은 모든 엔드포인트에서 동일하게 유지한다.

## 공통 응답
### 성공
```json
{
  "data": {},
  "meta": {
    "requestId": "req_123",
    "nextCursor": null,
    "hasMore": false
  }
}
```

### 에러
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "ownerProductUrl is required",
    "details": {
      "ownerProductUrl": ["required"]
    }
  }
}
```

권장 에러 코드:
- `UNAUTHORIZED`
- `FORBIDDEN`
- `NOT_FOUND`
- `CONFLICT`
- `VALIDATION_ERROR`
- `RATE_LIMITED`
- `UPSTREAM_UNAVAILABLE`

OpenAPI에서는 공통 오류 응답 세트를 사용한다.
- 인증 관련 엔드포인트는 `400`, `401`, `403`, `429`, `503`을 포함한다.
- 조회 중심 엔드포인트는 `400`, `401`, `403`, `404`, `429`, `503`을 포함한다.
- 생성/수정/삭제 엔드포인트는 `400`, `401`, `403`, `404`, `409`, `429`, `503`을 포함한다.

## 인증
### POST `/auth/login`
이메일/비밀번호 로그인.

Request
```json
{
  "email": "seller@example.com",
  "password": "password123"
}
```

Response
```json
{
  "data": {
    "accessToken": "jwt...",
    "refreshToken": "jwt...",
    "user": {
      "id": "uuid",
      "email": "seller@example.com",
      "name": "홍길동"
    }
  }
}
```

### POST `/auth/refresh`
리프레시 토큰으로 새 access token을 발급한다.

### POST `/auth/logout`
토큰 무효화 또는 클라이언트 세션 제거를 위한 엔드포인트다.

### GET `/me`
현재 로그인한 사용자와 접근 가능한 조직 목록을 반환한다.

## 조직과 멤버십
### GET `/organizations`
현재 사용자가 접근 가능한 워크스페이스 목록을 반환한다.

### POST `/organizations`
새 워크스페이스를 만든다.

Request
```json
{
  "name": "브랜드 A",
  "timezone": "Asia/Seoul"
}
```

### GET `/organizations/{organizationId}`
워크스페이스 상세를 조회한다.

### PATCH `/organizations/{organizationId}`
워크스페이스 이름, 타임존, 플랜 정보를 수정한다.

### GET `/organizations/{organizationId}/members`
멤버 목록을 조회한다.

Response fields:
- `id`
- `userId`
- `email`
- `name`
- `role`
- `status`
- `createdAt`

`status` 값은 `active` 또는 `suspended`를 사용한다.

### POST `/organizations/{organizationId}/invites`
초대 메일을 보낸다.

Request
```json
{
  "email": "operator@example.com",
  "role": "operator"
}
```

### POST `/invites/{token}/accept`
초대 토큰을 수락한다.

### DELETE `/organizations/{organizationId}/members/{memberId}`
멤버를 제거한다.

## 대시보드
### GET `/dashboard/summary?organizationId={organizationId}&range=24h`
오늘의 요약 카드와 대응 우선순위를 반환한다.

Response fields:
- `asOf`
- `metrics.priceDropCompetitorCount`
- `metrics.cheaperCompetitorCount`
- `metrics.marginRiskCount`
- `metrics.stockOutCount`
- `metrics.reviewSpikeCount`
- `actionItems[]`

Example
```json
{
  "data": {
    "asOf": "2026-04-16T00:00:00Z",
    "metrics": {
      "priceDropCompetitorCount": 12,
      "cheaperCompetitorCount": 8,
      "marginRiskCount": 3,
      "stockOutCount": 2,
      "reviewSpikeCount": 5
    },
    "actionItems": [
      {
        "monitoredProductId": "uuid",
        "title": "경쟁사 A 가격 8% 하락",
        "reason": "marginRisk",
        "severity": "high",
        "currentLowestEffectivePrice": 28100,
        "minMarginPrice": 29000
      }
    ]
  }
}
```

## 모니터링 상품
### GET `/monitored-products`
조직의 모니터링 상품 목록을 반환한다.

Query params:
- `organizationId`
- `status`
- `cursor`
- `limit`

### POST `/monitored-products`
모니터링 상품을 생성한다.

Request
```json
{
  "organizationId": "uuid",
  "ownerProductName": "유기농 견과세트",
  "ownerProductUrl": "https://...",
  "ownerPrice": 39000,
  "minMarginPrice": 32000,
  "category": "식품",
  "competitors": [
    {
      "channel": "coupang",
      "competitorName": "경쟁사 A",
      "competitorProductUrl": "https://..."
    }
  ]
}
```

Response fields:
- `id`
- `ownerProductName`
- `ownerProductUrl`
- `ownerPrice`
- `minMarginPrice`
- `category`
- `status`
- `competitorCount`

### GET `/monitored-products/{monitoredProductId}`
상품 상세와 요약 지표를 반환한다.

### PATCH `/monitored-products/{monitoredProductId}`
상품의 이름, 기준가, 상태를 수정한다.

### DELETE `/monitored-products/{monitoredProductId}`
상품 추적을 비활성화한다. 물리 삭제보다 소프트 삭제를 권장한다.

## 경쟁상품과 스냅샷
### GET `/monitored-products/{monitoredProductId}/competitor-products`
경쟁상품 목록을 반환한다.

Response fields:
- `id`
- `channel`
- `competitorName`
- `competitorProductUrl`
- `competitorProductTitle`
- `isActive`
- `lastSeenAt`
- `lowestEffectivePrice`

### POST `/monitored-products/{monitoredProductId}/competitor-products`
경쟁상품 링크를 등록한다.

Request
```json
{
  "channel": "smartstore",
  "competitorName": "경쟁사 B",
  "competitorProductUrl": "https://..."
}
```

### PATCH `/competitor-products/{competitorProductId}`
경쟁상품의 이름, 활성 상태, 채널 메타를 수정한다.

### DELETE `/competitor-products/{competitorProductId}`
경쟁상품 추적을 중단한다.

### GET `/competitor-products/{competitorProductId}/snapshots`
수집 이력과 가격 변화를 반환한다.

Query params:
- `cursor`
- `limit`
- `from`
- `to`

Response fields:
- `collectedAt`
- `listedPrice`
- `shippingFee`
- `couponPrice`
- `effectivePrice`
- `reviewCount`
- `rating`
- `stockStatus`
- `sellerName`

## 이벤트
### GET `/events`
이벤트 센터 목록을 반환한다.

Query params:
- `organizationId`
- `eventType`
- `isRead`
- `isPinned`
- `cursor`
- `limit`

### GET `/events/{eventId}`
이벤트 상세를 반환한다.

### PATCH `/events/{eventId}`
이벤트를 읽음 처리하거나 핀 고정/해제한다.

Request
```json
{
  "isRead": true,
  "isPinned": false,
  "resolvedAt": "2026-04-16T00:00:00Z",
  "note": "가격 조정 예정"
}
```

Response fields:
- `id`
- `eventType`
- `oldValue`
- `newValue`
- `changeRate`
- `detectedAt`
- `isRead`
- `isPinned`
- `resolvedAt`
- `note`

권장 `eventType` 값:
- `price_drop`
- `price_rise`
- `lowest_price_changed`
- `margin_risk`
- `out_of_stock`
- `restock`
- `review_spike`
- `rating_alert`

## 알림 규칙
### GET `/alert-rules`
조직의 알림 규칙을 반환한다.

### POST `/alert-rules`
알림 규칙을 생성한다.

Request
```json
{
  "organizationId": "uuid",
  "ruleType": "price_drop_pct",
  "threshold": 3,
  "deliveryChannel": "slack",
  "filterJson": {
    "category": "식품"
  },
  "isEnabled": true
}
```

### PATCH `/alert-rules/{alertRuleId}`
알림 규칙을 수정한다.

### DELETE `/alert-rules/{alertRuleId}`
알림 규칙을 삭제하거나 비활성화한다.

권장 `ruleType` 값:
- `price_drop_pct`
- `price_floor`
- `margin_floor`
- `stock_change`
- `review_spike`
- `rating_threshold`

권장 `deliveryChannel` 값:
- `email`
- `slack`
- `kakaowork`
- `webhook`

## 알림 이력
### GET `/notifications`
발송된 알림 이력과 읽음 상태를 반환한다.

Query params:
- `organizationId`
- `status`
- `channel`
- `cursor`
- `limit`

### PATCH `/notifications/{notificationId}`
알림을 읽음 처리한다.

Response fields:
- `id`
- `eventId`
- `deliveryChannel`
- `recipient`
- `title`
- `body`
- `status`
- `sentAt`
- `readAt`

## 리포트
### GET `/reports`
일간/주간 리포트 목록을 반환한다.

Query params:
- `organizationId`
- `reportType`
- `cursor`
- `limit`

### GET `/reports/{reportId}`
리포트 상세와 payload를 반환한다.

권장 `reportType` 값:
- `daily_summary`
- `weekly_summary`
- `client_report`

## 대표 DTO
### MonitoredProduct
- `id`
- `organizationId`
- `ownerProductName`
- `ownerProductUrl`
- `ownerPrice`
- `minMarginPrice`
- `category`
- `status`
- `competitorCount`
- `lowestEffectivePrice`
- `createdAt`
- `updatedAt`

### CompetitorProduct
- `id`
- `monitoredProductId`
- `channel`
- `competitorName`
- `competitorProductUrl`
- `competitorProductTitle`
- `isActive`
- `firstSeenAt`
- `lastSeenAt`

### ProductSnapshot
- `id`
- `competitorProductId`
- `collectedAt`
- `listedPrice`
- `shippingFee`
- `couponPrice`
- `effectivePrice`
- `reviewCount`
- `rating`
- `stockStatus`
- `sellerName`

### Event
- `id`
- `monitoredProductId`
- `competitorProductId`
- `eventType`
- `oldValue`
- `newValue`
- `changeRate`
- `detectedAt`
- `isRead`
- `isPinned`

### AlertRule
- `id`
- `organizationId`
- `ruleType`
- `threshold`
- `deliveryChannel`
- `filterJson`
- `isEnabled`

### Notification
- `id`
- `eventId`
- `deliveryChannel`
- `recipient`
- `title`
- `body`
- `status`
- `sentAt`
- `readAt`

### Report
- `id`
- `organizationId`
- `reportType`
- `reportDate`
- `payloadJson`

## 대표 예시
### 로그인
```json
{
  "email": "seller@example.com",
  "password": "password123"
}
```

### 모니터링 상품 생성
```json
{
  "organizationId": "uuid",
  "ownerProductName": "유기농 견과세트",
  "ownerProductUrl": "https://example.com/my-product",
  "ownerPrice": 39000,
  "minMarginPrice": 32000,
  "category": "식품",
  "competitors": [
    {
      "channel": "coupang",
      "competitorName": "경쟁사 A",
      "competitorProductUrl": "https://example.com/competitor-a"
    }
  ]
}
```

### 이벤트 수정
```json
{
  "isRead": true,
  "isPinned": false,
  "resolvedAt": "2026-04-16T00:00:00Z",
  "note": "가격 조정 예정"
}
```

### 대시보드 요약
```json
{
  "asOf": "2026-04-16T00:00:00Z",
  "metrics": {
    "priceDropCompetitorCount": 12,
    "cheaperCompetitorCount": 8,
    "marginRiskCount": 3,
    "stockOutCount": 2,
    "reviewSpikeCount": 5
  },
  "actionItems": [
    {
      "monitoredProductId": "uuid",
      "title": "경쟁사 A 가격 8% 하락",
      "reason": "marginRisk",
      "severity": "high",
      "currentLowestEffectivePrice": 28100,
      "minMarginPrice": 29000
    }
  ]
}
```

## 오류 처리
- 모든 오류 응답은 `ErrorResponse` 형식을 따른다.
- `VALIDATION_ERROR`는 요청 필드가 비었거나 형식이 맞지 않을 때 사용한다.
- `UNAUTHORIZED`는 토큰이 없거나 만료됐을 때 사용한다.
- `FORBIDDEN`은 권한이 부족할 때 사용한다.
- `NOT_FOUND`는 리소스가 없을 때 사용한다.
- `CONFLICT`는 중복 등록이나 상태 충돌이 있을 때 사용한다.
- `RATE_LIMITED`는 수집이나 조회가 과도할 때 사용한다.
- `UPSTREAM_UNAVAILABLE`는 외부 채널 수집 실패나 종속 서비스 장애에 사용한다.

## 엔드포인트별 예외 조건
### 인증
| 엔드포인트 | 401 | 403 | 404 | 409 |
| --- | --- | --- | --- | --- |
| `POST /auth/login` | 이메일 또는 비밀번호 불일치 | 계정 정지 또는 로그인 차단 | - | - |
| `POST /auth/refresh` | refresh token 만료, 위조, 누락 | 세션 폐기 | - | - |
| `POST /auth/logout` | 토큰 없음 또는 만료 | 세션 이미 폐기 | - | - |
| `GET /me` | 토큰 없음 또는 만료 | 계정 비활성화 또는 권한 회수 | - | - |

### 조직과 멤버십
| 엔드포인트 | 401 | 403 | 404 | 409 |
| --- | --- | --- | --- | --- |
| `GET /organizations` | 토큰 없음 또는 만료 | 워크스페이스 접근 권한 없음 | - | - |
| `POST /organizations` | 토큰 없음 또는 만료 | 워크스페이스 생성 제한 | - | 동일 이름 또는 slug 충돌 |
| `GET /organizations/{organizationId}` | 토큰 없음 또는 만료 | 해당 조직 멤버가 아님 | 조직 없음 | - |
| `PATCH /organizations/{organizationId}` | 토큰 없음 또는 만료 | 관리자 권한 없음 | 조직 없음 | 이름 또는 상태 변경 충돌 |
| `GET /organizations/{organizationId}/members` | 토큰 없음 또는 만료 | 멤버 조회 권한 없음 | 조직 없음 | - |
| `POST /organizations/{organizationId}/invites` | 토큰 없음 또는 만료 | 초대 발송 권한 없음 | 조직 없음 | 이미 초대됨 또는 이미 멤버 |
| `POST /invites/{token}/accept` | 토큰 없음 또는 만료 | 초대 대상 이메일과 현재 계정 불일치 | 초대 토큰 없음 또는 만료 | 이미 수락됨 또는 이미 멤버 |
| `DELETE /organizations/{organizationId}/members/{memberId}` | 토큰 없음 또는 만료 | 멤버 제거 권한 없음 | 조직 또는 멤버 없음 | 마지막 관리자 제거 또는 제거 불가 상태 |

### 대시보드와 상품
| 엔드포인트 | 401 | 403 | 404 | 409 |
| --- | --- | --- | --- | --- |
| `GET /dashboard/summary` | 토큰 없음 또는 만료 | 조직 접근 권한 없음 | 조직 없음 | - |
| `GET /monitored-products` | 토큰 없음 또는 만료 | 상품 목록 조회 권한 없음 | 조직 없음 | - |
| `POST /monitored-products` | 토큰 없음 또는 만료 | 상품 등록 권한 없음 | 조직 없음 | 동일 상품 또는 URL이 이미 추적 중 |
| `GET /monitored-products/{monitoredProductId}` | 토큰 없음 또는 만료 | 해당 조직 상품이 아님 | 모니터링 상품 없음 | - |
| `PATCH /monitored-products/{monitoredProductId}` | 토큰 없음 또는 만료 | 수정 권한 없음 | 상품 없음 | 이미 아카이브된 상품 또는 상태 충돌 |
| `DELETE /monitored-products/{monitoredProductId}` | 토큰 없음 또는 만료 | 삭제 권한 없음 | 상품 없음 | 활성 경쟁상품이 있어 삭제 불가 |

### 경쟁상품과 스냅샷
| 엔드포인트 | 401 | 403 | 404 | 409 |
| --- | --- | --- | --- | --- |
| `GET /monitored-products/{monitoredProductId}/competitor-products` | 토큰 없음 또는 만료 | 조회 권한 없음 | 모니터링 상품 없음 | - |
| `POST /monitored-products/{monitoredProductId}/competitor-products` | 토큰 없음 또는 만료 | 등록 권한 없음 | 모니터링 상품 없음 | 동일 경쟁상품 URL이 이미 등록됨 |
| `PATCH /competitor-products/{competitorProductId}` | 토큰 없음 또는 만료 | 수정 권한 없음 | 경쟁상품 없음 | 이미 비활성화됨 또는 상태 충돌 |
| `DELETE /competitor-products/{competitorProductId}` | 토큰 없음 또는 만료 | 삭제 권한 없음 | 경쟁상품 없음 | 이미 제거되었거나 스냅샷 상태 때문에 삭제 불가 |
| `GET /competitor-products/{competitorProductId}/snapshots` | 토큰 없음 또는 만료 | 조회 권한 없음 | 경쟁상품 없음 | - |

### 이벤트
| 엔드포인트 | 401 | 403 | 404 | 409 |
| --- | --- | --- | --- | --- |
| `GET /events` | 토큰 없음 또는 만료 | 이벤트 조회 권한 없음 | 조직 없음 | - |
| `GET /events/{eventId}` | 토큰 없음 또는 만료 | 이벤트 조회 권한 없음 | 이벤트 없음 | - |
| `PATCH /events/{eventId}` | 토큰 없음 또는 만료 | 이벤트 수정 권한 없음 | 이벤트 없음 | 이미 처리됨 또는 중복 상태 변경 |

### 알림과 리포트
| 엔드포인트 | 401 | 403 | 404 | 409 |
| --- | --- | --- | --- | --- |
| `GET /alert-rules` | 토큰 없음 또는 만료 | 알림 규칙 조회 권한 없음 | 조직 없음 | - |
| `POST /alert-rules` | 토큰 없음 또는 만료 | 알림 규칙 생성 권한 없음 | 조직 없음 | 동일 규칙 또는 조건 충돌 |
| `PATCH /alert-rules/{alertRuleId}` | 토큰 없음 또는 만료 | 알림 규칙 수정 권한 없음 | 알림 규칙 없음 | 동일 조건의 다른 규칙과 충돌 |
| `DELETE /alert-rules/{alertRuleId}` | 토큰 없음 또는 만료 | 알림 규칙 삭제 권한 없음 | 알림 규칙 없음 | 이미 비활성화됨 또는 삭제 보호 상태 |
| `GET /notifications` | 토큰 없음 또는 만료 | 알림 조회 권한 없음 | 조직 없음 | - |
| `PATCH /notifications/{notificationId}` | 토큰 없음 또는 만료 | 알림 수정 권한 없음 | 알림 없음 | 이미 최종 상태로 잠김 |
| `GET /reports` | 토큰 없음 또는 만료 | 리포트 조회 권한 없음 | 조직 없음 | - |
| `GET /reports/{reportId}` | 토큰 없음 또는 만료 | 리포트 조회 권한 없음 | 리포트 없음 | - |

OpenAPI의 각 operation `description`도 위 조건을 같은 순서로 반영한다.

## 구현 메모
- 목록 API는 cursor pagination을 우선 사용한다.
- `effectivePrice`는 서버에서 계산한 읽기 전용 값으로 취급한다.
- `monitored-products/{id}` 계열은 대시보드와 상세 화면에서 재사용한다.
- 추후 public API를 열더라도 v1은 내부 운영용으로 제한한다.

## 참고 자료
- [제품 명세](../product-specs/seller-price-monitoring.md)
- [설계 문서](./seller-price-monitoring.md)
- [OpenAPI](../generated/seller-price-monitoring-openapi.yaml)
- [DB 스키마 SQL](../generated/seller-price-monitoring-schema.sql)
