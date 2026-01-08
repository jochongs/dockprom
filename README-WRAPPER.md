# Dockprom Wrapper for macOS

macOS에서 Docker Compose 네트워킹 이슈를 우회하기 위한 Docker-in-Docker 솔루션입니다.

## 개요

Ubuntu 22.04 컨테이너 내부에서 전체 dockprom 스택을 실행하여 macOS의 Docker 네트워킹 버그를 우회합니다.

## 포함된 소프트웨어

Ubuntu 22.04 컨테이너에 자동으로 설치됩니다:

-   Git
-   Docker (Docker-in-Docker)
-   Node.js 20.x LTS
-   Docker Compose

```bash
# 기존 컨테이너 중지 및 제거
docker compose -f docker-compose.wrapper.yml down -v

# 새로 빌드 및 실행
docker compose -f docker-compose.wrapper.yml up -d --build

# 로그 확인
docker compose -f docker-compose.wrapper.yml logs -f
```

## 사용 방법

### 1. Wrapper 컨테이너 빌드 및 실행

```bash
docker compose -f docker-compose.wrapper.yml up -d --build
```

### 2. 로그 확인

```bash
docker compose -f docker-compose.wrapper.yml logs -f
```

### 3. Grafana 접속

브라우저에서 접속:

```
http://localhost:3000
```

기본 인증 정보:

-   Username: `admin`
-   Password: `admin`

### 4. 기타 서비스 접속

-   **Prometheus**: http://localhost:9090
-   **Alertmanager**: http://localhost:9093
-   **cAdvisor**: http://localhost:8080
-   **Pushgateway**: http://localhost:9091

## 작동 방식

1. `docker-compose.wrapper.yml`이 Ubuntu 22.04 컨테이너를 시작
2. Supervisord가 독립된 Docker 데몬과 서비스 스크립트를 관리
3. `start-services.sh` 스크립트가 자동으로 내부 `docker-compose.inner.yml` 실행
4. 내부 컨테이너들이 `0.0.0.0`으로 포트를 바인딩하여 wrapper 컨테이너로 노출
5. Wrapper 컨테이너의 포트가 호스트 macOS로 포워딩

## 컨테이너 내부 접속

디버깅이나 수동 작업이 필요한 경우:

```bash
docker exec -it dockprom-wrapper bash
```

내부에서 서비스 상태 확인:

```bash
docker compose -f /app/docker-compose.inner.yml ps
```

## 중지 및 제거

### 중지

```bash
docker compose -f docker-compose.wrapper.yml down
```

### 데이터까지 모두 삭제

```bash
docker compose -f docker-compose.wrapper.yml down -v
```

## 환경 변수 설정

`.env` 파일을 생성하여 인증 정보 변경:

```env
ADMIN_USER=your_username
ADMIN_PASSWORD=your_password
```

## 트러블슈팅

### 서비스가 시작되지 않는 경우

```bash
# 컨테이너 재시작
docker compose -f docker-compose.wrapper.yml restart

# 내부 로그 확인
docker exec -it dockprom-wrapper docker compose -f /app/docker-compose.inner.yml logs
```

### Docker 데몬 상태 확인

```bash
docker exec -it dockprom-wrapper docker info
```

## 구조

```
dockprom/
├── docker-compose.wrapper.yml  # Wrapper 컨테이너 설정
├── Dockerfile.wrapper           # Ubuntu + Docker + Git + Node
├── supervisord.conf             # Docker 데몬 및 서비스 관리
├── start-services.sh            # 자동 시작 스크립트
├── docker-compose.yml           # 원본 dockprom 설정 (호스트용)
├── docker-compose.inner.yml    # 내부에서 실행될 설정 (포트 바인딩 포함)
└── ...                          # 기타 dockprom 파일들
```
