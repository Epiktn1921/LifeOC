-- Life OS: таблица для данных пользователей.
-- Выполните один раз: Supabase → SQL Editor → New query → вставить → Run.

create table if not exists public.planner (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Каждый пользователь видит и меняет только свои данные
alter table public.planner enable row level security;

drop policy if exists "planner select own" on public.planner;
drop policy if exists "planner insert own" on public.planner;
drop policy if exists "planner update own" on public.planner;
drop policy if exists "planner delete own" on public.planner;

create policy "planner select own" on public.planner for select to authenticated using (auth.uid() = user_id);
create policy "planner insert own" on public.planner for insert to authenticated with check (auth.uid() = user_id);
create policy "planner update own" on public.planner for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "planner delete own" on public.planner for delete to authenticated using (auth.uid() = user_id);

-- Кнопка «Удалить аккаунт»: удаляет вход пользователя и все его данные
create or replace function public.delete_me()
returns void
language sql
security definer
set search_path = public
as $$
  delete from auth.users where id = auth.uid();
$$;

revoke all on function public.delete_me() from public, anon;
grant execute on function public.delete_me() to authenticated;
