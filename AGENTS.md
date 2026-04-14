# 에이전트 운영 가이드

이 저장소는 하네스 엔지니어링 작업을 위한 운영 매뉴얼이다. 의사결정, 계획, 참조 자료를 담는 마크다운 우선의 정본 저장소다.

## 저장소 구조

```
.
├── ARCHITECTURE.md
└── docs/
    ├── DESIGN.md
    ├── PRODUCT_SENSE.md
    ├── RELIABILITY.md
    ├── SECURITY.md
    ├── GLOSSARY.md
    ├── CHECKLISTS.md
    ├── exec-plans/
    │   ├── active/       # 진행 중 실행 계획
    │   └── completed/    # 완료된 실행 계획
    ├── product-specs/    # 제품 사양 문서
    ├── design-docs/      # 설계 문서
    └── references/       # 외부 참조 자료
```

## 먼저 읽을 문서
1. `ARCHITECTURE.md` — 시스템 전체 구조 파악
2. 가장 관련 있는 도메인 문서 — 작업 성격에 따라 선택
    - `docs/DESIGN.md` : UI/UX 및 설계 원칙
    - `docs/PRODUCT_SENSE.md` : 제품 방향성 및 판단 기준
    - `docs/RELIABILITY.md` : 장애 대응 및 SLO
    - `docs/SECURITY.md` : 보안 정책 및 요구사항
3. `docs/GLOSSARY.md` — 공통 용어 정의 / `docs/CHECKLISTS.md` — 작업별 체크리스트
4. `docs/exec-plans/active/` 아래의 현재 실행 계획
5. `docs/product-specs/` 또는 `docs/design-docs/` 아래의 관련 제품/설계 문서

## 문서 우선순위
문서 간 내용이 충돌할 경우 아래 순서를 따른다.

`ARCHITECTURE.md` > 도메인 문서 > 실행 계획 > 설계 문서

## 브랜치 생성 규약
- 실행계획에 Jira 링크가 포함되어 있으면, 해당 이슈의 상위 이슈 키를 확인한다.
- 상위 이슈 키가 `SPMO-xxxx` 형식이면, `bitbucket.org/pulmuone/pulmuone-module-2025` 레포를 사용한다
- 작업 유형이 `feature`이면 `qa_develop`를 기준으로 `feature/SPMO-xxxx_ffff` 브랜치를 생성하고 `xxxx`는 지라번호 `ffff`는 작업 내용을 타이틀로 요약하여 영어로 추가한다.
- 작업 유형이 `hotfix`이면 `master`를 기준으로 `hotfix/SPMO-xxxx_ffff` 브랜치를 생성하고 `xxxx`는 지라번호 `ffff`는 작업 내용을 타이틀로 요약하여 영어로 추가한다.
- 브랜치 생성 전에는 원격 기준 브랜치를 최신 상태로 갱신한다.
- 하위 이슈 키(`SPAG-xxxx`)는 브랜치명에 사용하지 않는다.
- 상위 이슈 키를 확인할 수 없거나 형식이 다르면, 임의로 브랜치를 만들지 말고 사용자 확인을 요청한다.
- 이미 같은 브랜치가 존재하면 새로 만들지 말고 기존 브랜치를 사용한다.

## 작업 규칙
- 한 파일에는 한 주제만 담는다.
- 문서는 빠르게 훑을 수 있을 만큼 간결하되, 실제로 행동할 수 있을 만큼 구체적으로 쓴다.
- 새 문서를 추가할 때는 인덱스를 함께 추가하거나 갱신한다.
- 정본 문서와 생성 산출물을 분리한다.
- 작업이 단순하지 않다면 변경 전에 실행 계획을 먼저 작성한다.
- 가정, 열린 질문, 위험, 롤백 아이디어를 명시적으로 기록한다.
- 품질, 신뢰성, 보안은 필수 검토 기준으로 취급한다.
- 어떤 결정이 외부 참조에 의존한다면 `docs/references/`에 담거나 관련 문서에 출처를 남긴다.
- 개념 이름을 조용히 바꾸지 않는다. 용어는 한 번 정의하고 계속 재사용한다.

## 문서 작성 기준
- 첫 문단에 문서의 목적이 적혀 있어야 한다.
- 읽는 사람이 다음에 무엇을 해야 하는지 바로 보여야 한다.
- 탐색에 도움이 되는 곳에는 교차 링크가 있어야 한다.

## 문서 검수 기준
- 낡았거나 중복된 지침은 제거하거나 통합해야 한다.
- 생성된 콘텐츠는 생성물임이 분명히 표시돼야 한다.

## 계획 관리 원칙
- 진행 중인 작업은 `docs/exec-plans/active/`에 둔다.
- 완료된 작업은 `docs/exec-plans/completed/`로 옮긴다.
- 하나의 이니셔티브에는 하나의 활성 계획만 둔다.
- 결과, 검증, 후속 항목을 기록해 마무리까지 연결한다.
- 계획의 모든 목표가 달성되고 후속 항목이 정리되면 담당자가 `completed/`로 이동한다.

## 파일 네이밍 규칙
실행 계획 파일은 아래 형식을 따른다.

`YYYY-MM-DD_initiative-name.md`

예시: `2025-04-09_auth-refactor.md`