create table if not exists public.graphs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 80),
  data jsonb not null default '{}'::jsonb check (jsonb_typeof(data) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists graphs_user_updated_idx
  on public.graphs (user_id, updated_at desc);

alter table public.graphs enable row level security;

grant select, insert, update, delete on public.graphs to authenticated;

drop policy if exists "Users can read their own graphs" on public.graphs;
create policy "Users can read their own graphs"
  on public.graphs for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can create their own graphs" on public.graphs;
create policy "Users can create their own graphs"
  on public.graphs for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own graphs" on public.graphs;
create policy "Users can update their own graphs"
  on public.graphs for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete their own graphs" on public.graphs;
create policy "Users can delete their own graphs"
  on public.graphs for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create or replace function public.set_graph_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_graph_updated_at on public.graphs;
create trigger set_graph_updated_at
  before update on public.graphs
  for each row execute function public.set_graph_updated_at();

create table if not exists public.me_profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null check (jsonb_typeof(data) = 'object')
);

alter table public.me_profiles enable row level security;

grant select, insert, update on public.me_profiles to authenticated;

drop policy if exists "Users can read their own Me profile" on public.me_profiles;
create policy "Users can read their own Me profile"
  on public.me_profiles for select to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can create their own Me profile" on public.me_profiles;
create policy "Users can create their own Me profile"
  on public.me_profiles for insert to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own Me profile" on public.me_profiles;
create policy "Users can update their own Me profile"
  on public.me_profiles for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
