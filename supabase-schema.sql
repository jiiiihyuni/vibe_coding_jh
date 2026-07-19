-- Supabase 설정용 SQL
-- Supabase 대시보드 > SQL Editor 에서 이 전체를 실행하세요.

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

-- 3. RLS(행 단위 보안) 활성화
alter table public.products enable row level security;

-- 4. 본인 데이터만 조회/수정/삭제 가능하도록 정책 생성
create policy "Users can view own products"
  on public.products for select
  using (auth.uid() = user_id);

create policy "Users can insert own products"
  on public.products for insert
  with check (auth.uid() = user_id);

create policy "Users can update own products"
  on public.products for update
  using (auth.uid() = user_id);

create policy "Users can delete own products"
  on public.products for delete
  using (auth.uid() = user_id);
