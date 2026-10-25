-- LIFE REBUILD / ADR-003 / B+E Lite v0.2
-- FICTIONAL TEST DATA ONLY. Apply only to a NEW, disposable Supabase Free project.
-- One authenticated test owner. Specialist origin values are unverified labels.
-- No journal, medical, real financial, or family records.

create extension if not exists pgcrypto;

create table public.lr03_findings (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  external_id text not null check (external_id ~ '^[A-Z0-9][A-Z0-9_-]{3,63}$'),
  origin_claimed text not null check (origin_claimed in ('00','04','05')),
  recipient text not null check (recipient in ('00','04','05')),
  title text not null check (char_length(btrim(title)) between 1 and 120),
  finding text not null check (char_length(btrim(finding)) between 1 and 2000),
  proposed_action text not null default '' check (char_length(proposed_action) <= 1000),
  status text not null default 'pending' check (status in ('pending','approved','rejected','deferred')),
  version int not null default 1 check (version > 0),
  executive_assessment text,
  decision_note text,
  created_at timestamptz not null default now(),
  decided_at timestamptz,
  constraint lr03_finding_unique_key unique (owner_id, external_id)
);
create index lr03_findings_owner_time on public.lr03_findings(owner_id,created_at desc);

create table public.lr03_approved (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  finding_id uuid not null unique references public.lr03_findings(id),
  external_id text not null,
  origin_claimed text not null,
  recipient text not null,
  title text not null,
  finding text not null,
  executive_assessment text not null,
  created_at timestamptz not null default now()
);
create index lr03_approved_owner_time on public.lr03_approved(owner_id,created_at desc);

create table public.lr03_audit (
  id bigint generated always as identity primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  finding_id uuid not null references public.lr03_findings(id),
  event_type text not null check (event_type in ('submitted','owner_decision')),
  before_status text,
  after_status text,
  event_time timestamptz not null default now(),
  detail jsonb not null default '{}'::jsonb
);
create index lr03_audit_owner_time on public.lr03_audit(owner_id,event_time desc);

alter table public.lr03_findings enable row level security;
alter table public.lr03_approved enable row level security;
alter table public.lr03_audit enable row level security;

-- These tables have SELECT access only for authenticated users, gated by row ownership.
-- No normal browser client may directly INSERT, UPDATE, or DELETE on any table.
revoke all on table public.lr03_findings, public.lr03_approved, public.lr03_audit from public, anon, authenticated;
grant select on table public.lr03_findings, public.lr03_approved, public.lr03_audit to authenticated;

create policy lr03_findings_read on public.lr03_findings
  for select to authenticated using (owner_id = (select auth.uid()));
create policy lr03_approved_read on public.lr03_approved
  for select to authenticated using (owner_id = (select auth.uid()));
create policy lr03_audit_read on public.lr03_audit
  for select to authenticated using (owner_id = (select auth.uid()));

-- Security-definer RPC owns validated, atomic writes and audit logging.
-- Owner authorization is represented by the signed-in session plus an explicit
-- client confirmation; it is NOT independent proof of an Executive review.
create function public.lr03_submit(
  p_external_id text,
  p_origin_claimed text,
  p_recipient text,
  p_title text,
  p_finding text,
  p_proposed_action text
) returns uuid language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := auth.uid(); v_id uuid; v_key text := upper(btrim(coalesce(p_external_id, '')));
begin
  if v_uid is null then raise exception 'Authentication required'; end if;
  if v_key !~ '^[A-Z0-9][A-Z0-9_-]{3,63}$' then raise exception 'Invalid external ID'; end if;
  if p_origin_claimed is null or p_origin_claimed not in ('00','04','05') or
     p_recipient is null or p_recipient not in ('00','04','05') then
    raise exception 'Unknown specialist module';
  end if;
  if char_length(btrim(coalesce(p_title,''))) not between 1 and 120 or
     char_length(btrim(coalesce(p_finding,''))) not between 1 and 2000 or
     char_length(coalesce(p_proposed_action,'')) > 1000 then
    raise exception 'Invalid finding length';
  end if;
  insert into public.lr03_findings(owner_id,external_id,origin_claimed,recipient,title,finding,proposed_action)
  values(v_uid,v_key,p_origin_claimed,p_recipient,btrim(p_title),btrim(p_finding),coalesce(p_proposed_action,''))
  returning id into v_id;
  insert into public.lr03_audit(owner_id,finding_id,event_type,after_status,detail)
  values(v_uid,v_id,'submitted','pending',jsonb_build_object('origin_authenticated',false,'mode','fictional'));
  return v_id;
end; $$;

create function public.lr03_decide(
  p_id uuid,
  p_expected_version int,
  p_outcome text,
  p_executive_assessment text,
  p_decision_note text,
  p_owner_confirmed boolean
) returns uuid language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := auth.uid(); v public.lr03_findings%rowtype;
begin
  if v_uid is null then raise exception 'Authentication required'; end if;
  if p_owner_confirmed is distinct from true then raise exception 'Owner confirmation required'; end if;
  if p_outcome is null or p_outcome not in ('approved','rejected','deferred') then
    raise exception 'Invalid decision outcome';
  end if;
  if char_length(btrim(coalesce(p_executive_assessment,''))) not between 10 and 3000 or
     char_length(coalesce(p_decision_note,'')) > 1000 then
    raise exception 'Executive review text or note invalid';
  end if;
  select * into v from public.lr03_findings
   where id = p_id and owner_id = v_uid for update;
  if not found then raise exception 'Finding unavailable'; end if;
  if v.status <> 'pending' or v.version <> p_expected_version then
    raise exception 'Stale or previously decided; refresh before retrying';
  end if;
  update public.lr03_findings set
    status=p_outcome,
    version=v.version+1,
    executive_assessment=btrim(p_executive_assessment),
    decision_note=coalesce(p_decision_note,''),
    decided_at=now()
   where id=v.id;
  if p_outcome='approved' then
    insert into public.lr03_approved(owner_id,finding_id,external_id,origin_claimed,recipient,title,finding,executive_assessment)
    values(v_uid,v.id,v.external_id,v.origin_claimed,v.recipient,v.title,v.finding,btrim(p_executive_assessment));
  end if;
  insert into public.lr03_audit(owner_id,finding_id,event_type,before_status,after_status,detail)
  values(v_uid,v.id,'owner_decision','pending',p_outcome,
    jsonb_build_object('prior_version',v.version,'confirmed_in_client',true,'executive_review_user_attested',true));
  return v.id;
end; $$;

-- PostgreSQL functions can be executable by PUBLIC by default: revoke explicitly.
revoke all on function public.lr03_submit(text,text,text,text,text,text) from public, anon, authenticated;
revoke all on function public.lr03_decide(uuid,int,text,text,text,boolean) from public, anon, authenticated;
grant execute on function public.lr03_submit(text,text,text,text,text,text) to authenticated;
grant execute on function public.lr03_decide(uuid,int,text,text,text,boolean) to authenticated;

-- IMPORTANT LIMITATIONS:
-- 1. No autonomous ChatGPT agent handoff or verified specialist sender identity.
-- 2. One test owner's account may submit and review. The UI confirmation checkbox
--    is NOT cryptographic evidence of review by 00 or independent human approval.
-- 3. SECURITY DEFINER bypasses table RLS for its validated operations. Never
--    modify these functions to accept an arbitrary owner_id or trust role labels.
-- 4. Service-role/secret keys must never be placed into frontend code.
