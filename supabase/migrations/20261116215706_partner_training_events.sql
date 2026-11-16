-- Applied to the hosted project; canonical timestamped migration is in supabase/migrations.
create table public.partner_training_events (
 id uuid primary key default gen_random_uuid(),
 partner_company_id uuid not null references public.partner_companies(id),
 title text not null check (length(btrim(title)) between 2 and 180),
 training_date date not null,
 description text not null default '', logo_url text not null default '', cover_url text not null default '',
 is_published boolean not null default false,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index on public.partner_training_events(partner_company_id, training_date desc);
create table public.partner_training_questions (
 id uuid primary key default gen_random_uuid(), event_id uuid not null references public.partner_training_events(id) on delete cascade,
 question_text text not null check(length(btrim(question_text)) between 1 and 2000),
 options_json jsonb not null check(jsonb_typeof(options_json)='array' and jsonb_array_length(options_json) between 2 and 4),
 correct_option integer not null check(correct_option between 0 and 3), order_index integer not null default 0,
 check(correct_option < jsonb_array_length(options_json))
);
create index on public.partner_training_questions(event_id);
create table public.partner_training_materials (
 id uuid primary key default gen_random_uuid(), event_id uuid not null references public.partner_training_events(id) on delete cascade,
 kind text not null check(kind in ('library','module','product','comparison','link')),
 source_id uuid, title text not null, payload jsonb not null default '{}', url text not null default '', order_index integer not null default 0
);
create index on public.partner_training_materials(event_id);
create table public.partner_training_submissions (
 id uuid primary key default gen_random_uuid(), event_id uuid not null references public.partner_training_events(id),
 user_id uuid not null references auth.users(id), full_name text not null, email text not null,
 company_name text not null, title text not null, training_date date not null,
 correct_count integer not null, total_questions integer not null check(total_questions>0), score_pct numeric(5,2) not null,
 answers jsonb not null, submitted_at timestamptz not null default now(),
 unique(event_id,user_id), unique(event_id,email)
);
create index on public.partner_training_submissions(user_id);

alter table public.partner_training_events enable row level security;
alter table public.partner_training_questions enable row level security;
alter table public.partner_training_materials enable row level security;
alter table public.partner_training_submissions enable row level security;
revoke all on public.partner_training_events,public.partner_training_questions,public.partner_training_materials,public.partner_training_submissions from anon,authenticated;
grant select on public.partner_training_events to anon,authenticated;
grant select on public.partner_training_questions,public.partner_training_materials,public.partner_training_submissions to authenticated;
create policy training_events_read on public.partner_training_events for select to anon,authenticated using ((is_published and exists(select 1 from public.partner_companies c where c.id=partner_company_id and c.is_active)) or public.fn_is_admin());
create policy training_questions_admin on public.partner_training_questions for select to authenticated using (public.fn_is_admin());
create policy training_materials_read on public.partner_training_materials for select to authenticated using (public.fn_is_admin() or exists(select 1 from public.partner_training_events e join public.guest_registrations g on g.partner_company_id=e.partner_company_id where e.id=event_id and e.is_published and g.user_id=(select auth.uid())));
create policy training_submissions_read on public.partner_training_submissions for select to authenticated using (public.fn_is_admin() or user_id=(select auth.uid()));

-- Deliberate authenticated RPC boundary: guests see selected questions only, never the answer key.
create or replace function public.fn_partner_training_questions(p_event_id uuid) returns jsonb
language plpgsql security definer set search_path='' as $$
begin
 if auth.uid() is null then raise exception 'Identifique-se para acessar o treinamento.'; end if;
 if not public.fn_is_admin() and not exists(select 1 from public.partner_training_events e join public.guest_registrations g on g.partner_company_id=e.partner_company_id join public.partner_companies c on c.id=e.partner_company_id where e.id=p_event_id and e.is_published and c.is_active and g.user_id=auth.uid()) then raise exception 'Treinamento indisponível para esta empresa.'; end if;
 return coalesce((select jsonb_agg(jsonb_build_object('id',q.id,'question_text',q.question_text,'options_json',q.options_json,'order_index',q.order_index) order by q.order_index,q.id) from public.partner_training_questions q where event_id=p_event_id),'[]'::jsonb);
end $$;
revoke all on function public.fn_partner_training_questions(uuid) from public,anon;
grant execute on function public.fn_partner_training_questions(uuid) to authenticated;

create or replace function public.fn_save_partner_training(p_event jsonb,p_questions jsonb,p_materials jsonb) returns uuid
language plpgsql security definer set search_path='' as $$
declare v_id uuid; v_q jsonb; v_m jsonb; v_locked boolean; v_old jsonb; v_new jsonb;
begin
 if auth.uid() is null or not public.fn_is_admin() then raise exception 'Acesso restrito à administração.'; end if;
 if jsonb_typeof(p_questions) is distinct from 'array' or jsonb_typeof(p_materials) is distinct from 'array' then raise exception 'Dados inválidos.'; end if;
 if jsonb_array_length(p_questions)>100 or jsonb_array_length(p_materials)>100 then raise exception 'Limite de 100 perguntas e materiais por treinamento.'; end if;
 v_id:=nullif(p_event->>'id','')::uuid;
 if v_id is not null then
   perform 1 from public.partner_training_events where id=v_id for update;
   if not found then raise exception 'Treinamento não encontrado.'; end if;
 end if;
 if coalesce((p_event->>'is_published')::boolean,false) and jsonb_array_length(p_questions)=0 then raise exception 'Crie pelo menos uma pergunta antes de publicar.'; end if;
 for v_q in select value from jsonb_array_elements(p_questions) loop
   if jsonb_typeof(v_q->'options_json') is distinct from 'array' then raise exception 'Alternativas inválidas.'; end if;
   if length(btrim(coalesce(v_q->>'question_text','')))=0 or jsonb_array_length(v_q->'options_json') not between 2 and 4 or (v_q->>'correct_option') is null or (v_q->>'correct_option')::int not between 0 and jsonb_array_length(v_q->'options_json')-1 or exists(select 1 from jsonb_array_elements(v_q->'options_json') x where jsonb_typeof(x) <> 'string' or length(btrim(x#>>'{}'))=0) then raise exception 'Preencha a pergunta, 2 a 4 alternativas e a resposta correta.'; end if;
 end loop;
 v_locked:=exists(select 1 from public.partner_training_submissions where event_id=v_id);
 if v_locked then
   select coalesce(jsonb_agg(jsonb_build_object('id',id::text,'question_text',question_text,'options_json',options_json,'correct_option',correct_option,'order_index',order_index) order by order_index,id),'[]') into v_old from public.partner_training_questions where event_id=v_id;
   select coalesce(jsonb_agg(jsonb_build_object('id',value->>'id','question_text',value->>'question_text','options_json',value->'options_json','correct_option',(value->>'correct_option')::int,'order_index',coalesce((value->>'order_index')::int,0)) order by coalesce((value->>'order_index')::int,0),(value->>'id')::uuid),'[]') into v_new from jsonb_array_elements(p_questions);
   if v_old<>v_new then raise exception 'Este treinamento já recebeu respostas. Crie outro treinamento para alterar as perguntas.'; end if;
   if exists(select 1 from public.partner_training_events where id=v_id and partner_company_id<>(p_event->>'partner_company_id')::uuid) then raise exception 'Não é possível trocar a empresa após receber respostas.'; end if;
 end if;
 if v_id is null then
   insert into public.partner_training_events(partner_company_id,title,training_date) values((p_event->>'partner_company_id')::uuid,btrim(p_event->>'title'),(p_event->>'training_date')::date) returning id into v_id;
 end if;
 update public.partner_training_events set partner_company_id=(p_event->>'partner_company_id')::uuid,title=btrim(p_event->>'title'),training_date=(p_event->>'training_date')::date,description=coalesce(p_event->>'description',''),logo_url=coalesce(p_event->>'logo_url',''),cover_url=coalesce(p_event->>'cover_url',''),is_published=coalesce((p_event->>'is_published')::boolean,false),updated_at=now() where id=v_id;
 if not v_locked then
   delete from public.partner_training_questions where event_id=v_id;
   insert into public.partner_training_questions(id,event_id,question_text,options_json,correct_option,order_index) select coalesce(nullif(value->>'id','')::uuid,gen_random_uuid()),v_id,btrim(value->>'question_text'),value->'options_json',(value->>'correct_option')::int,coalesce((value->>'order_index')::int,0) from jsonb_array_elements(p_questions);
 end if;
 delete from public.partner_training_materials where event_id=v_id;
 insert into public.partner_training_materials(event_id,kind,source_id,title,payload,url,order_index) select v_id,value->>'kind',nullif(value->>'source_id','')::uuid,value->>'title',coalesce(value->'payload','{}'),coalesce(value->>'url',''),coalesce((value->>'order_index')::int,0) from jsonb_array_elements(p_materials);
 return v_id;
end $$;
revoke all on function public.fn_save_partner_training(jsonb,jsonb,jsonb) from public,anon;
grant execute on function public.fn_save_partner_training(jsonb,jsonb,jsonb) to authenticated;

create or replace function public.fn_submit_partner_training(p_event_id uuid,p_answers jsonb) returns jsonb
language plpgsql security definer set search_path='' as $$
declare v_g public.guest_registrations; v_e public.partner_training_events; v_s public.partner_training_submissions; v_total int; v_correct int; v_answers jsonb;
begin
 if auth.uid() is null then raise exception 'Identifique-se para responder.'; end if;
 select * into v_g from public.guest_registrations where user_id=auth.uid();
 if not found then raise exception 'Informe seu nome, e-mail e empresa antes de responder.'; end if;
 select * into v_e from public.partner_training_events where id=p_event_id for update;
 if not found or not v_e.is_published or v_e.partner_company_id<>v_g.partner_company_id or not exists(select 1 from public.partner_companies where id=v_e.partner_company_id and is_active) then raise exception 'Treinamento indisponível para esta empresa.'; end if;
 select * into v_s from public.partner_training_submissions where event_id=p_event_id and user_id=auth.uid();
 if found then return jsonb_build_object('id',v_s.id,'correct_count',v_s.correct_count,'total_questions',v_s.total_questions,'score_pct',v_s.score_pct,'submitted_at',v_s.submitted_at); end if;
 if exists(select 1 from public.partner_training_submissions where event_id=p_event_id and email=lower(v_g.email)) then raise exception 'Este e-mail já respondeu a este treinamento.'; end if;
 select count(*) into v_total from public.partner_training_questions where event_id=p_event_id;
 if v_total=0 or jsonb_typeof(p_answers) is distinct from 'array' then raise exception 'Questionário indisponível.'; end if;
 if jsonb_array_length(p_answers)<>v_total or (select count(distinct x->>'question_id') from jsonb_array_elements(p_answers) x)<>v_total or exists(select 1 from jsonb_array_elements(p_answers) a left join public.partner_training_questions q on q.id=(a->>'question_id')::uuid and q.event_id=p_event_id where q.id is null or (a->>'selected_option') is null or (a->>'selected_option')::int not between 0 and jsonb_array_length(q.options_json)-1) then raise exception 'Responda todas as perguntas com uma alternativa válida.'; end if;
 select count(*) filter(where q.correct_option=(a->>'selected_option')::int), jsonb_agg(jsonb_build_object('question_id',q.id,'question_text',q.question_text,'selected_option',(a->>'selected_option')::int,'selected_text',q.options_json->>((a->>'selected_option')::int),'correct_option',q.correct_option,'correct_text',q.options_json->>q.correct_option,'is_correct',q.correct_option=(a->>'selected_option')::int) order by q.order_index,q.id) into v_correct,v_answers from public.partner_training_questions q join jsonb_array_elements(p_answers) a on (a->>'question_id')::uuid=q.id where q.event_id=p_event_id;
 insert into public.partner_training_submissions(event_id,user_id,full_name,email,company_name,title,training_date,correct_count,total_questions,score_pct,answers) select p_event_id,auth.uid(),v_g.full_name,lower(v_g.email),c.name,v_e.title,v_e.training_date,v_correct,v_total,round(100.0*v_correct/v_total,2),v_answers from public.partner_companies c where c.id=v_e.partner_company_id returning * into v_s;
 return jsonb_build_object('id',v_s.id,'correct_count',v_s.correct_count,'total_questions',v_s.total_questions,'score_pct',v_s.score_pct,'submitted_at',v_s.submitted_at);
end $$;
revoke all on function public.fn_submit_partner_training(uuid,jsonb) from public,anon;
grant execute on function public.fn_submit_partner_training(uuid,jsonb) to authenticated;

-- Fix the existing guest email validator (the prior double escape rejected normal emails).
create or replace function public.fn_register_guest(p_full_name text,p_email text,p_partner_company_id uuid) returns public.guest_registrations
language plpgsql security definer set search_path='' as $$
declare v_brand uuid; v_row public.guest_registrations;
begin
 if auth.uid() is null or not public.fn_is_guest() then raise exception 'Acesso disponível apenas para convidados.'; end if;
 if p_full_name is null or length(btrim(p_full_name)) not between 2 and 120 then raise exception 'Informe seu nome completo.'; end if;
 if p_email is null or length(p_email)>254 or btrim(p_email) !~ '^[^@[:space:]]+@[^@[:space:]]+[.][^@[:space:]]+$' then raise exception 'Informe um e-mail válido.'; end if;
 select brand_id into v_brand from public.partner_companies where id=p_partner_company_id and is_active;
 if v_brand is null then raise exception 'Empresa indisponível.'; end if;
 insert into public.guest_registrations(user_id,brand_id,partner_company_id,full_name,email) values(auth.uid(),v_brand,p_partner_company_id,btrim(p_full_name),lower(btrim(p_email))) on conflict(user_id) do update set brand_id=excluded.brand_id,partner_company_id=excluded.partner_company_id,full_name=excluded.full_name,email=excluded.email returning * into v_row;
 update public.profiles set full_name=v_row.full_name where id=auth.uid();
 return v_row;
end $$;
revoke all on function public.fn_register_guest(text,text,uuid) from public,anon;
grant execute on function public.fn_register_guest(text,text,uuid) to authenticated;

-- The existing admin policy handles writes; grant only the required operations.
grant select on public.partner_companies to anon,authenticated;
grant insert,update on public.partner_companies to authenticated;
insert into public.partner_companies(brand_id,slug,name,order_index) select b.id,v.slug,v.name,v.ord from public.brands b cross join (values('moema','Moema',10),('morumbi','Morumbi',11),('revendas','Revendas',12)) v(slug,name,ord) where b.name='Garmin' on conflict(brand_id,slug) do nothing;
