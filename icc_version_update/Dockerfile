# 베이스 이미지
FROM ubuntu:24.04

# 필수 패키지 설치
RUN apt-get update && \
    apt-get install -y curl bash git && \
    rm -rf /var/lib/apt/lists/*

# 작업 디렉토리
WORKDIR /app

# GitHub에서 스크립트 다운로드
RUN curl -fsSL https://raw.githubusercontent.com/the-xero/icc-docker/main/icc_version_update/update_version.sh \
    -o update_version.sh && \
    chmod +x update_version.sh

# 컨테이너 실행 시 스크립트 실행
ENTRYPOINT ["/app/update_version.sh"]
