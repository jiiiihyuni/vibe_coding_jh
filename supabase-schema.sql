-- Supabase 설정용 SQL
-- Supabase 대시보드 > SQL Editor 에서 이 전체를 실행하세요.
-- 로그인한 사람 중 "허용 명단(allowed_users)"에 등록된 사람들끼리
-- 하나의 재고 데이터를 함께 보고 관리하는 구조입니다.

-- 1. products 테이블 생성
create table if not exists public.products (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  quantity integer not null default 0 check (quantity >= 0),
  buy_price numeric not null default 0 check (buy_price >= 0),
  sell_price numeric not null default 0 check (sell_price >= 0),
  created_at timestamptz not null default now()
);

-- 2. user_id 기준 조회 성능을 위한 인덱스
create index if not exists products_user_id_idx on public.products (user_id);

-- 3. 허용 명단 테이블: 여기에 등록된 사람만 데이터를 보고 쓸 수 있음
create table if not exists public.allowed_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  note text,
  added_at timestamptz not null default now()
);

-- 4. RLS(행 단위 보안) 활성화
alter table public.products enable row level security;
alter table public.allowed_users enable row level security;

-- 5. 기존 정책이 있다면 제거 (재실행 가능하도록)
drop policy if exists "Users can view own products" on public.products;
drop policy if exists "Users can insert own products" on public.products;
drop policy if exists "Users can update own products" on public.products;
drop policy if exists "Users can delete own products" on public.products;
drop policy if exists "Allowed users can view products" on public.products;
drop policy if exists "Allowed users can insert products" on public.products;
drop policy if exists "Allowed users can update products" on public.products;
drop policy if exists "Allowed users can delete products" on public.products;
drop policy if exists "Shared view for allow-list, own-only for others" on public.products;
drop policy if exists "Anyone logged in can insert their own products" on public.products;
drop policy if exists "Shared update for allow-list, own-only for others" on public.products;
drop policy if exists "Shared delete for allow-list, own-only for others" on public.products;

-- 6. 허용 명단에 있는 사람은 모든 사람의 재고 데이터를 조회/수정 가능.
--    명단에 없는 사람은 본인이 작성한 데이터만 조회/수정 가능.
create policy "Shared view for allow-list, own-only for others"
  on public.products for select
  using (
    exists (select 1 from public.allowed_users au where au.user_id = auth.uid())
    or user_id = auth.uid()
  );

create policy "Anyone logged in can insert their own products"
  on public.products for insert
  with check (user_id = auth.uid());

create policy "Shared update for allow-list, own-only for others"
  on public.products for update
  using (
    exists (select 1 from public.allowed_users au where au.user_id = auth.uid())
    or user_id = auth.uid()
  );

create policy "Shared delete for allow-list, own-only for others"
  on public.products for delete
  using (
    exists (select 1 from public.allowed_users au where au.user_id = auth.uid())
    or user_id = auth.uid()
  );

-- 7. 본인이 허용 명단에 있는지 스스로 확인할 수 있도록 허용
--    (allowed_users 자체는 관리자가 SQL Editor에서 직접 추가/삭제)
create policy "Users can check their own allow-list entry"
  on public.allowed_users for select
  using (auth.uid() = user_id);

-- ── 사용법 ────────────────────────────────────────────────────
-- 1) 공유할 사람이 먼저 앱에서 회원가입을 1번 해야 합니다 (auth.users에 계정 생성).
-- 2) 그 다음 아래 쿼리로 허용 명단에 추가합니다.
--
--    insert into public.allowed_users (user_id, note)
--    select id, 'teammate note' from auth.users where email = 'teammate@example.com';
--
-- 3) 명단에서 빼려면:
--
--    delete from public.allowed_users where user_id = (
--      select id from auth.users where email = 'teammate@example.com'
--    );
-- ─────────────────────────────────────────────────────────────
