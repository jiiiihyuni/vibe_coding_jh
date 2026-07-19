# vibe_coding_jh

재고 관리 웹앱 (`index.html`). GitHub Pages로 배포됩니다.

## Supabase 설정 방법

이 앱은 로그인한 사용자별로 재고 데이터를 Supabase 데이터베이스에 저장합니다.

1. [supabase.com](https://supabase.com)에서 새 프로젝트를 만듭니다.
2. 프로젝트의 **SQL Editor**에서 `supabase-schema.sql` 파일 내용을 실행해 `products` 테이블과 보안 정책(RLS)을 생성합니다.
3. **Project Settings > API**에서 `Project URL`과 `anon public` 키를 복사합니다.
4. `index.html`의 `<script>` 상단에 있는 아래 두 값을 채워 넣습니다.

   ```js
   const SUPABASE_URL = "https://YOUR-PROJECT-REF.supabase.co";
   const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";
   ```

5. **Authentication > Providers**에서 Email 로그인이 켜져 있는지 확인합니다. (기본값이 켜짐)
   - 테스트 단계에서는 **Authentication > Providers > Email**의 "Confirm email"을 꺼두면 가입 즉시 로그인됩니다.
6. 브라우저에서 `index.html`을 열면 로그인/회원가입 화면이 뜹니다. 계정을 만들면 이후부터 재고 데이터가 Supabase에 저장되고, 같은 계정으로 로그인하면 어디서든 동일한 데이터를 볼 수 있습니다.

`anon public` 키는 공개되어도 되는 키입니다(RLS로 행 단위 접근이 제한됨). `service_role` 키는 절대 클라이언트 코드에 넣지 마세요.
