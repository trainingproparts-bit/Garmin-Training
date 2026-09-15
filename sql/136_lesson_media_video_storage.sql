-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 136: Storage de vídeo pro bloco 'video'
-- ============================================================================
-- Pedido: permitir enviar um arquivo de vídeo direto do computador no bloco
-- 'video' do editor de lição (ContentBlocks.js), em vez de só colar uma URL
-- de embed (YouTube/Vimeo).
--
-- O bucket 'lesson-media' já existe no projeto (criado manualmente fora de
-- controle de versão, junto com avatars/brand-assets/certificates — ver nota
-- em sql/116) mas nunca foi usado por nenhum código do frontend e não tem
-- nenhuma policy em storage.objects: hoje NINGUÉM consegue enviar nada nele
-- (RLS habilitada por padrão, sem policy de insert = insert sempre nega).
-- Em vez de criar mais um bucket órfão, esta migração aproveita o que já
-- existe: define limite de tamanho/tipo e adiciona as policies, seguindo o
-- mesmo padrão já em produção de content-images (sql/116) — upload direto do
-- client (sessão do usuário logado), sem Edge Function.
--
-- Bucket público (obrigatório — a tag <video src> não manda header de
-- autenticação). Limite de 200MB por arquivo: suficiente pra um vídeo curto
-- de treinamento em resolução razoável, sem deixar o upload arrastar demais
-- numa conexão comum.
-- ============================================================================

update storage.buckets set
  public             = true,
  file_size_limit    = 209715200, -- 200MB
  allowed_mime_types = array['video/mp4', 'video/webm', 'video/quicktime', 'video/ogg']
where id = 'lesson-media';

-- Escrita restrita a admin (só a Gestora edita conteúdo de lição — mesmo
-- escopo de content_images_admin_*), leitura pública (necessária pro <video>
-- carregar sem sessão).

drop policy if exists "lesson_media_public_read" on storage.objects;
create policy "lesson_media_public_read"
on storage.objects for select
using (bucket_id = 'lesson-media');

drop policy if exists "lesson_media_admin_insert" on storage.objects;
create policy "lesson_media_admin_insert"
on storage.objects for insert
with check (bucket_id = 'lesson-media' and public.fn_is_admin());

drop policy if exists "lesson_media_admin_update" on storage.objects;
create policy "lesson_media_admin_update"
on storage.objects for update
using (bucket_id = 'lesson-media' and public.fn_is_admin());

drop policy if exists "lesson_media_admin_delete" on storage.objects;
create policy "lesson_media_admin_delete"
on storage.objects for delete
using (bucket_id = 'lesson-media' and public.fn_is_admin());

-- ============================================================================
-- FIM DA MIGRAÇÃO 136
-- ============================================================================
