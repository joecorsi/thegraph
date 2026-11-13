begin;

lock table public.graphs, public.me_profiles in access exclusive mode;

do $$
begin
  if exists (
    select 1 from public.graphs
    where jsonb_typeof(data -> 'traits') is distinct from 'array'
       or jsonb_typeof(data -> 'people') is distinct from 'array'
  ) then
    raise exception 'Migration stopped: a graph has invalid traits or people.';
  end if;
  if exists (
    select 1 from public.graphs
    where data ? 'funnyTraitMigrated'
      and data -> 'funnyTraitMigrated' is distinct from 'true'::jsonb
    union all
    select 1 from public.me_profiles
    where data ? 'funnyTraitMigrated'
      and data -> 'funnyTraitMigrated' is distinct from 'true'::jsonb
  ) then
    raise exception 'Migration stopped: the migration marker is already in use.';
  end if;
  if exists (
    select 1 from public.graphs g
    cross join lateral jsonb_array_elements(g.data -> 'traits') trait
    where g.data -> 'funnyTraitMigrated' is distinct from 'true'::jsonb
      and trait ->> 'id' = 'not-funny-funny'
      and (trait ->> 'name' is distinct from 'Funny' or trait ->> 'opposite' is distinct from 'Not funny')
  ) then
    raise exception 'Migration stopped: the new trait ID is already in use.';
  end if;
  if not exists (
    select 1 from pg_catalog.pg_trigger
    where tgrelid = 'public.graphs'::regclass
      and tgname = 'set_graph_updated_at' and tgenabled = 'O'
  ) then
    raise exception 'Migration stopped: the graph timestamp trigger is not enabled as expected.';
  end if;
end;
$$;

create schema thepear_backup_funny_20261113;
revoke all on schema thepear_backup_funny_20261113 from public, anon, authenticated, service_role;
create table thepear_backup_funny_20261113.graphs as select * from public.graphs;
create table thepear_backup_funny_20261113.me_profiles as select * from public.me_profiles;
revoke all on all tables in schema thepear_backup_funny_20261113 from public, anon, authenticated, service_role;
alter table thepear_backup_funny_20261113.graphs enable row level security;
alter table thepear_backup_funny_20261113.me_profiles enable row level security;

alter table public.graphs disable trigger set_graph_updated_at;

update public.graphs
set data = jsonb_set(
  jsonb_set(data, '{traits}',
    case when exists (
      select 1 from jsonb_array_elements(data -> 'traits') trait
      where trait ->> 'id' = 'not-funny-funny'
    ) then data -> 'traits'
    else (data -> 'traits') || '[{"id":"not-funny-funny","name":"Funny","opposite":"Not funny"}]'::jsonb
    end),
  '{funnyTraitMigrated}', 'true'::jsonb)
where data -> 'funnyTraitMigrated' is distinct from 'true'::jsonb;

alter table public.graphs enable trigger set_graph_updated_at;

update public.me_profiles
set data = jsonb_set(data, '{funnyTraitMigrated}', 'true'::jsonb)
where data -> 'funnyTraitMigrated' is distinct from 'true'::jsonb;

do $$
begin
  if exists (
    select 1
    from public.graphs g
    full join thepear_backup_funny_20261113.graphs b on b.id = g.id
    where g.id is null or b.id is null
       or g.user_id is distinct from b.user_id
       or g.name is distinct from b.name
       or g.created_at is distinct from b.created_at
       or g.updated_at is distinct from b.updated_at
       or (g.data - 'traits' - 'funnyTraitMigrated') is distinct from (b.data - 'traits' - 'funnyTraitMigrated')
       or g.data -> 'funnyTraitMigrated' is distinct from 'true'::jsonb
       or g.data -> 'traits' is distinct from
         case when b.data -> 'funnyTraitMigrated' = 'true'::jsonb or exists (
           select 1 from jsonb_array_elements(b.data -> 'traits') trait
           where trait ->> 'id' = 'not-funny-funny'
         ) then b.data -> 'traits'
         else (b.data -> 'traits') || '[{"id":"not-funny-funny","name":"Funny","opposite":"Not funny"}]'::jsonb
         end
  ) then
    raise exception 'Migration stopped: graph data did not match the backup.';
  end if;
  if exists (
    select 1
    from public.me_profiles m
    full join thepear_backup_funny_20261113.me_profiles b on b.user_id = m.user_id
    where m.user_id is null or b.user_id is null
       or (m.data - 'funnyTraitMigrated') is distinct from (b.data - 'funnyTraitMigrated')
       or m.data -> 'funnyTraitMigrated' is distinct from 'true'::jsonb
  ) then
    raise exception 'Migration stopped: Me profile data did not match the backup.';
  end if;
end;
$$;

create or replace function public.require_funny_trait_version()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.data -> 'funnyTraitMigrated' is distinct from 'true'::jsonb then
    if tg_op = 'INSERT' or old.data -> 'funnyTraitMigrated' = 'true'::jsonb then
      raise exception 'This tab is out of date. Reload the page before saving.';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists require_funny_trait_version on public.graphs;
create trigger require_funny_trait_version
  before insert or update on public.graphs
  for each row execute function public.require_funny_trait_version();

drop trigger if exists require_funny_trait_version on public.me_profiles;
create trigger require_funny_trait_version
  before insert or update on public.me_profiles
  for each row execute function public.require_funny_trait_version();

commit;
