-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 116: Storage de imagens de conteúdo
-- ============================================================================
-- Pedido: substituir "colar URL externa" por upload direto de imagem pra
-- capa de trilha/quiz/duelo/biblioteca, banner de blog, avatar, capa de
-- produto e imagens de bloco de lição.
--
-- Levantamento feito antes de escrever isto (não existe SQL versionado de
-- Storage neste repositório até agora — busquei `storage.buckets`/
-- `storage.objects`/`bucket_id` em todo `sql/*.sql` e no schema base: zero
-- ocorrências):
--   - O único bucket em uso real hoje ('certificates', usado por
--     certificateService.js) foi criado manualmente no dashboard do
--     Supabase, fora de controle de versão — upload é direto do client
--     (anon key + sessão), sem Edge Function.
--   - A Edge Function supabase/functions/upload-attachment/index.ts é
--     código morto: nenhum service do frontend a chama, e o bucket que ela
--     usa por padrão ('attachments') não existe em nenhuma migration.
--   - A tabela `attachments` (schema base) só é tocada em DELETE (limpeza
--     defensiva de cascade); nunca é populada. Não é usada aqui.
--
-- Decisão: seguir o padrão que já funciona em produção (upload direto do
-- client pro Storage, mesmo caminho de certificateService.js), com um
-- bucket novo e versionado, em vez de reaproveitar/consertar a Edge
-- Function morta.
--
-- Bucket público (obrigatório — uma tag <img src> não manda header de
-- autenticação, então o arquivo precisa ser legível sem sessão) com limite
-- de tipo/tamanho aplicado pelo PRÓPRIO Storage do Supabase (file_size_limit/
-- allowed_mime_types na tabela storage.buckets), não só validação client-side
-- — mesmo espírito de proteção de borda que a Edge Function morta pretendia,
-- só que através de um mecanismo que o projeto já sabe que funciona.
--
-- Estrutura de pastas dentro do bucket (por convenção, não enforced por
-- constraint — só a pasta `avatars/{user_id}/` é de fato verificada pela
-- policy de autoedição abaixo):
--   covers/trilhas/, covers/quizzes/, covers/games/, covers/biblioteca/,
--   covers/blog/, covers/produtos/, blocks/licoes/, avatars/{user_id}/
--
-- Escrita: admin em qualquer caminho do bucket (cobre todas as capas e
-- imagens de bloco de lição — só a Gestora edita conteúdo); qualquer
-- autenticado pode escrever só dentro da própria pasta `avatars/{auth.uid()}/`
-- (autoedição de avatar no Álbum da Equipe, mesmo escopo de "só a própria
-- linha" já usado em profiles_update_own/sql/008).
--
-- Decisão consciente, documentada: upload nunca apaga o arquivo antigo do
-- Storage ao substituir/remover uma imagem — evita apagar algo que porventura
-- ainda esteja referenciado por outra linha com a mesma URL. Custo de
-- armazenamento é desprezível na escala atual da organização.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Bucket
-- ----------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'content-images',
  'content-images',
  true,
  5242880, -- 5MB
  array['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
on conflict (id) do update set
  public             = excluded.public,
  file_size_limit    = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- ----------------------------------------------------------------------------
-- 2. Políticas em storage.objects (RLS já vem habilitada por padrão nos
--    projetos Supabase — não precisa de `alter table ... enable row level
--    security` aqui).
-- ----------------------------------------------------------------------------

drop policy if exists "content_images_public_read" on storage.objects;
create policy "content_images_public_read"
on storage.objects for select
using (bucket_id = 'content-images');

drop policy if exists "content_images_admin_insert" on storage.objects;
create policy "content_images_admin_insert"
on storage.objects for insert
with check (bucket_id = 'content-images' and public.fn_is_admin());

drop policy if exists "content_images_admin_update" on storage.objects;
create policy "content_images_admin_update"
on storage.objects for update
using (bucket_id = 'content-images' and public.fn_is_admin());

drop policy if exists "content_images_admin_delete" on storage.objects;
create policy "content_images_admin_delete"
on storage.objects for delete
using (bucket_id = 'content-images' and public.fn_is_admin());

-- Autoedição de avatar: qualquer autenticado pode escrever só dentro da
-- própria pasta avatars/{auth.uid()}/... — storage.foldername(name) devolve
-- os segmentos de pasta do caminho (tudo antes do nome do arquivo), então
-- para "avatars/<uid>/167_foto.png" o array é {avatars, <uid>}.
drop policy if exists "content_images_self_avatar_insert" on storage.objects;
create policy "content_images_self_avatar_insert"
on storage.objects for insert
with check (
  bucket_id = 'content-images'
  and (storage.foldername(name))[1] = 'avatars'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists "content_images_self_avatar_update" on storage.objects;
create policy "content_images_self_avatar_update"
on storage.objects for update
using (
  bucket_id = 'content-images'
  and (storage.foldername(name))[1] = 'avatars'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists "content_images_self_avatar_delete" on storage.objects;
create policy "content_images_self_avatar_delete"
on storage.objects for delete
using (
  bucket_id = 'content-images'
  and (storage.foldername(name))[1] = 'avatars'
  and (storage.foldername(name))[2] = auth.uid()::text
);

-- ============================================================================
-- FIM DA MIGRAÇÃO 116
-- ============================================================================
