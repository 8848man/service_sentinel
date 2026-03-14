## 🧠 프로젝트 개요

Service Sentinel은  
여러 API 서비스의 인증 헤더 및 상태를 손쉽게 설정하고  
실시간으로 요청 결과를 확인할 수 있도록 돕는 도구입니다.

### 이런 문제를 해결합니다
- API 인증 구조(JWT, Header, Token)가 이해하기 어려움
- Postman 설정이 반복되고 관리가 어려움
- 서비스 상태 확인이 분산되어 있음

### 대상 사용자
- 주니어 개발자
- 백엔드/프론트엔드 협업 팀
- API 테스트가 잦은 프로젝트

### 상세 페이지
https://www.notion.so/service-sentinel/2e0ee09674108013bfc4ce5d1a429ee3?source=copy_link

## ✨ 주요 기능

- 🔐 API 인증 헤더 동적 설정
- 📡 서비스 상태 모니터링
- 🧪 요청 테스트 및 응답 뷰어
- 🗂 서비스 그룹 관리

## 🛠 기술 스택

| 구분 | 기술 | 선택 이유 |
|----|----|----|
| Framework | Flutter | 멀티 플랫폼 대응 |
| State | Riverpod | 명확한 의존성 관리 |
| Network | Dio | Interceptor 활용 확장성 |
| Architecture | Clean Architecture | 테스트/확장성 |

- Presentation → ViewModel → UseCase → Repository 구조
- UI 레이어에서 네트워크 로직 완전 분리
- Dialog / Toast는 ViewModel 상태로 제어

## ▶️ 실행 방법 (FE 애플리케이션)

```bash
git clone https://github.com/8848man/service_sentinel_fe
cd service-sentinel_fe
flutter pub get
flutter pub run build_runner build
flutter run -d chrome --web-port 8080 (백엔드 CORS 우회 설정 로컬 ip)
```