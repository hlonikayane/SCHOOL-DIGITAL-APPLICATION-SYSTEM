-- Lenyora Primary School Digital Application System
-- Run once in Supabase SQL Editor. Uses auth.users UUIDs (not BIGINT identity IDs).
create extension if not exists pgcrypto;

create type public.app_status as enum ('pending','approved','rejected');

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  phone_number text,
  role text not null default 'parent' check (role in ('parent','admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.learners (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid not null references public.profiles(id) on delete cascade,
  full_name text not null,
  date_of_birth date,
  age integer check (age is null or age between 3 and 20),
  grade text not null check (grade in ('Grade R','Grade 1','Grade 2','Grade 3','Grade 4','Grade 5','Grade 6','Grade 7')),
  created_at timestamptz not null default now()
);

create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  application_number text not null unique default ('APP-' || to_char(now(),'YYYY') || '-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,8))),
  parent_id uuid not null references public.profiles(id),
  learner_id uuid not null references public.learners(id),
  status public.app_status not null default 'pending',
  parent_notes text,
  admin_notes text,
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz,
  submitted_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(),
  application_id uuid not null references public.applications(id) on delete cascade,
  owner_id uuid not null references public.profiles(id) on delete cascade,
  document_type text not null check (document_type in ('birth_certificate','parent_id','proof_of_residence','other')),
  file_name text not null,
  storage_path text not null unique,
  content_type text,
  size_bytes bigint check (size_bytes is null or size_bytes <= 10485760),
  created_at timestamptz not null default now()
);

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  grade text not null check (grade in ('Grade R','Grade 1','Grade 2','Grade 3','Grade 4','Grade 5','Grade 6','Grade 7')),
  description text,
  active boolean not null default true,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(name, grade)
);

create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  target_grade text check (target_grade is null or target_grade in ('Grade R','Grade 1','Grade 2','Grade 3','Grade 4','Grade 5','Grade 6','Grade 7')),
  published boolean not null default true,
  starts_at timestamptz not null default now(),
  ends_at timestamptz,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_learners_parent on public.learners(parent_id);
create index if not exists idx_applications_parent on public.applications(parent_id);
create index if not exists idx_applications_status on public.applications(status);
create index if not exists idx_subjects_grade_active on public.subjects(grade, active);
create index if not exists idx_announcements_live on public.announcements(published, starts_at, ends_at);

-- Automatically create a parent profile after Supabase Auth sign-up.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name, phone_number, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''), new.raw_user_meta_data->>'phone_number', 'parent')
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.profiles p where p.id = (select auth.uid()) and p.role = 'admin');
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

alter table public.profiles enable row level security;
alter table public.learners enable row level security;
alter table public.applications enable row level security;
alter table public.documents enable row level security;
alter table public.subjects enable row level security;
alter table public.announcements enable row level security;

grant select on public.profiles to authenticated;
-- Parents may update contact details, but cannot promote themselves by changing role.
grant update (full_name, phone_number, updated_at) on public.profiles to authenticated;
grant insert, select, update, delete on public.learners to authenticated;
grant select, update, delete on public.applications to authenticated;
grant insert (parent_id, learner_id, parent_notes) on public.applications to authenticated;
grant insert, select, update, delete on public.documents to authenticated;
grant select, insert, update, delete on public.subjects to authenticated;
grant select, insert, update, delete on public.announcements to authenticated;

create policy "profiles read self or admin" on public.profiles for select to authenticated using (id = (select auth.uid()) or public.is_admin());
create policy "profiles update self or admin" on public.profiles for update to authenticated using (id = (select auth.uid()) or public.is_admin()) with check (id = (select auth.uid()) or public.is_admin());
create policy "parents create own learner" on public.learners for insert to authenticated with check (parent_id = (select auth.uid()));
create policy "parents read own learners admin all" on public.learners for select to authenticated using (parent_id = (select auth.uid()) or public.is_admin());
create policy "parents update own learners admin all" on public.learners for update to authenticated using (parent_id = (select auth.uid()) or public.is_admin()) with check (parent_id = (select auth.uid()) or public.is_admin());
create policy "admin delete learners" on public.learners for delete to authenticated using (public.is_admin());

create policy "parents create own applications" on public.applications for insert to authenticated with check (parent_id = (select auth.uid()) and exists(select 1 from public.learners l where l.id = learner_id and l.parent_id = (select auth.uid())));
create policy "parents read own applications admin all" on public.applications for select to authenticated using (parent_id = (select auth.uid()) or public.is_admin());
create policy "admin update applications" on public.applications for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin delete applications" on public.applications for delete to authenticated using (public.is_admin());

create policy "documents owner or admin read" on public.documents for select to authenticated using (owner_id = (select auth.uid()) or public.is_admin());
create policy "documents owner insert" on public.documents for insert to authenticated with check (owner_id = (select auth.uid()) and exists(select 1 from public.applications a where a.id = application_id and a.parent_id = (select auth.uid())));
create policy "documents owner or admin delete" on public.documents for delete to authenticated using (owner_id = (select auth.uid()) or public.is_admin());
create policy "documents admin update" on public.documents for update to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "authenticated read active subjects" on public.subjects for select to authenticated using (active or public.is_admin());
create policy "admin insert subjects" on public.subjects for insert to authenticated with check (public.is_admin());
create policy "admin update subjects" on public.subjects for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin delete subjects" on public.subjects for delete to authenticated using (public.is_admin());

create policy "authenticated read live announcements" on public.announcements for select to authenticated using ((published and starts_at <= now() and (ends_at is null or ends_at > now())) or public.is_admin());
create policy "admin insert announcements" on public.announcements for insert to authenticated with check (public.is_admin());
create policy "admin update announcements" on public.announcements for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin delete announcements" on public.announcements for delete to authenticated using (public.is_admin());

-- Enable Realtime for announcements. If this errors because already in publication, skip it.
alter publication supabase_realtime add table public.announcements;
