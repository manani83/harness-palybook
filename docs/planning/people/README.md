# 사람별 작업 공간

## 목적
이 디렉터리는 기획팀 구성원별 Jira 처리 현황과 개인 메모를 분리해 관리하는 공간이다.

## 구조
- `docs/planning/people/<name-slug>/README.md`: 그 사람의 역할, 링크, 운영 메모
- `docs/planning/people/<name-slug>/jira/active/`: 진행 중인 Jira
- `docs/planning/people/<name-slug>/jira/blocked/`: 차단된 Jira
- `docs/planning/people/<name-slug>/jira/done/`: 완료된 Jira
- `docs/planning/people/<name-slug>/notes/`: 개인 노트

## 사용 방법
- 실제 사람 폴더는 `_template/`를 복제해 만든다.
- 한 Jira는 한 사람의 한 상태 폴더에만 둔다.
- 정책은 여기 두지 말고 [policies/](../policies/)로 올린다.
- 파일을 다른 사람에게 넘길 때는 이동 이유와 현재 상태를 함께 남긴다.

## 현재 사람
- [이성권](./lee-seong-gwon/)
