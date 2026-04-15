# 기획 운영 공간

## 목적
이 디렉터리는 기획팀이 사람별 Jira 큐와 공용 정책을 분리해 운영하는 공간이다. 제품 명세, 설계, 실행 계획의 정본은 각각 [docs/product-specs/](../product-specs/), [docs/design-docs/](../design-docs/), [docs/exec-plans/](../exec-plans/)에 둔다.

## 구성
- [policies/](./policies/): 기획팀 공용 기준
- [people/](./people/): 사람별 작업 공간

## 사용 원칙
- Jira 1건은 하나의 담당자 폴더에서만 관리한다.
- 공용 정책은 `policies/`에만 둔다.
- 사람별 폴더는 이름 슬러그로 만든다.
- 작업 내용이 제품 명세나 설계로 승격되면 해당 정본 문서로 이동하고 여기에는 링크만 남긴다.

## 시작점
- 정책을 바꾸려면 [policies/](./policies/)를 먼저 본다.
- Jira를 배정하거나 이동하려면 [people/](./people/)를 본다.
- 사람별 현재 목록은 [people/README.md](./people/README.md)를 본다.
- 실행 계획이 필요하면 [docs/PLANS.md](../PLANS.md)와 [docs/exec-plans/](../exec-plans/)를 본다.
