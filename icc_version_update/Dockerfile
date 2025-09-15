# 외부 서버용 ICC 버전 업데이트 컨테이너
FROM ubuntu:24.04

# 기본 패키지 설치
RUN apt-get update && \
    apt-get install -y curl git && \
    rm -rf /var/lib/apt/lists/*

# 작업 디렉토리 생성
WORKDIR /app

# 스크립트 복사
COPY update_version.sh /app/update_version.sh
RUN chmod +x /app/update_version.sh

# 컨테이너 시작 시 스크립트 실행
CMD ["./update_version.sh"]
