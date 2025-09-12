# IPTIME 통합 관리 (ICC Docker)
이 레포지토리는 **IPTIME 통합 관리(ICC)** 서버를 Docker 컨테이너로 쉽게 실행하고, 최신 버전을 자동으로 GitHub Actions를 통해 빌드/등록하는 워크플로우를 제공합니다.

---

## ICC 소개

- **ICC (IPTIME 통합 관리)** 는 IPTIME 공유기 및 관련 장치를 중앙에서 관리할 수 있는 통합 관리 서버입니다.
- 본 Docker 이미지는 **자동 업데이트/감시 기능을 제거**하고, ICC 본체와 웹 인터페이스만 운영하도록 간소화되어 있습니다.
- MySQL은 컨테이너 내부에서만 운영되며 외부 노출이 필요 없습니다.

---

## GitHub Actions 워크플로우

- 매일 자정(`0 0 * * *`) 또는 수동 실행으로 ICC 최신 이미지를 다운로드하고 Docker 이미지로 빌드/등록합니다.
- GHCR(GitHub Container Registry)에 최신 버전과 `latest` 태그로 자동 푸시됩니다.
- 자동 업데이트/감시 스크립트(`icc_watch.sh`)는 제거되어 있습니다.

---

## Docker Compose 사용법

### 1. 디렉토리 구조 준비

호스트에서 ICC 데이터를 보존하기 위해 아래 디렉토리를 생성합니다:

```bash
mkdir -p ./icc/etc ./icc/mysql ./icc/var/tmp ./icc/var/run/upload
```

### 2. docker-compose.yml 예시
```
services:
  icc:
    image: ghcr.io/the-xero/icc-docker:latest
    container_name: icc_docker
    restart: unless-stopped
    ports:
      - "8090:8090"   # ICC 포트
      - "8800:8800"   # WEB 포트
    volumes:
      - ./icc/etc:/etc
      - ./icc/mysql:/usr/local/mysql
      - ./icc/var/tmp:/var/tmp
      - ./icc/var/run/upload:/var/run/upload
```

### 3. 컨테이너 실행
`docker-compose up -d` 로 실행
- ICC 웹 인터페이스 접속 : `http://localhost:8800`
- ICC 서비스 포트 : `8090`

---

## 이미지 업데이트
GitHub Actions 워크플로우가 매일 최신 버전을 자동으로 GHCR에 푸시합니다.

---

## 폴더 구조
```
./icc
├── etc/             # ICC 설정 파일
├── mysql/           # MySQL 데이터 저장
├── var/
│   ├── tmp/         # 임시 파일
│   └── run/
│       └── upload/  # 업로드 파일
```


이제 `docker-compose up -d`만으로 ICC 통합 관리 서버를 바로 실행할 수 있습니다.

