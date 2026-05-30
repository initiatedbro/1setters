-- ============================================================
--  Transcend Closers — Supabase schema
--  Run in: Supabase Dashboard → SQL Editor → New query → paste → Run
-- ============================================================

-- 1) Public profile + daily logs (readable by any signed-in user when visible)
create table if not exists public.players (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text,
  name        text,
  visible     boolean not null default true,
  public      jsonb   not null default '{}'::jsonb,   -- name, role, color, photo, city, bio, socials, verified
  logs        jsonb   not null default '[]'::jsonb,   -- daily logs (powers the leaderboard)
  updated_at  timestamptz not null default now()
);

-- 2) Private data — owner only (call reviews, goals, reflections, money tracker)
create table if not exists public.player_private (
  id          uuid primary key references auth.users(id) on delete cascade,
  data        jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now()
);

-- 3) Row Level Security
alter table public.players        enable row level security;
alter table public.player_private enable row level security;

-- players: any signed-in user can read VISIBLE profiles (and always their own)
drop policy if exists players_read on public.players;
create policy players_read on public.players
  for select to authenticated
  using ( visible = true or auth.uid() = id );

drop policy if exists players_insert on public.players;
create policy players_insert on public.players
  for insert to authenticated
  with check ( auth.uid() = id );

drop policy if exists players_update on public.players;
create policy players_update on public.players
  for update to authenticated
  using ( auth.uid() = id ) with check ( auth.uid() = id );

drop policy if exists players_delete on public.players;
create policy players_delete on public.players
  for delete to authenticated
  using ( auth.uid() = id );

-- player_private: owner only, full access
drop policy if exists private_all on public.player_private;
create policy private_all on public.player_private
  for all to authenticated
  using ( auth.uid() = id ) with check ( auth.uid() = id );

-- 4) 90D Tracker — habits, goal plan, milestones (owner only)
create table if not exists public.tracker90d (
  id          uuid primary key references auth.users(id) on delete cascade,
  data        jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now()
);
alter table public.tracker90d enable row level security;
drop policy if exists tracker_all on public.tracker90d;
create policy tracker_all on public.tracker90d
  for all to authenticated
  using ( auth.uid() = id ) with check ( auth.uid() = id );

-- 5) GymBro — fitness goals, training days, exercises, logs (owner only)
create table if not exists public.gymbro (
  id          uuid primary key references auth.users(id) on delete cascade,
  data        jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now()
);
alter table public.gymbro enable row level security;
drop policy if exists gymbro_all on public.gymbro;
create policy gymbro_all on public.gymbro
  for all to authenticated
  using ( auth.uid() = id ) with check ( auth.uid() = id );
