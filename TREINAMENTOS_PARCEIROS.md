# Treinamentos de parceiros

## Preparar um treinamento

1. Entre com sua conta administrativa e abra o menu do avatar → **Treinamentos de parceiros**.
2. Clique em **Novo treinamento**, ou em **Gerenciar** no rascunho existente. Escolha empresa, data, título e apresentação.
3. Envie o logo da empresa e a imagem de capa/fundo.
4. Busque os materiais já publicados e marque os conteúdos que deseja compartilhar. Comparativos ficam em uma aba própria. Os materiais são copiados para o treinamento; alterações futuras na biblioteca não alteram automaticamente a cópia da turma.
5. Clique em **Adicionar pergunta**, escreva as alternativas (entre 2 e 4) e marque a correta. Nenhuma pergunta é preenchida automaticamente.
6. Marque **Publicar para participantes** e salve. A publicação exige ao menos uma pergunta completa.
7. Use **Ver página** para conferir e **Copiar link para participantes** para compartilhar. Para testar como participante sem encerrar sua conta administrativa, use uma janela anônima.

O participante também pode abrir o site normalmente e clicar em **Acessar treinamento de parceiros**. Escolhe entre Duty Free, Bayard, Centauro, Decathlon e Track n' Field, informa nome e e-mail e entra sem senha. Moema e Morumbi são lojas internas e continuam no login normal da equipe. O e-mail é informado pelo participante e não é validado por mensagem. Trata-se de identificação para o treinamento, não de comprovação de vínculo com a empresa.

## Acompanhar e exportar

Abra **Gerenciar** no treinamento para ver os resultados e clicar em **Exportar planilha CSV**. O arquivo abre no Excel e contém classificação, identificação, empresa, treinamento/data, horário de envio, nota, cada pergunta, resposta escolhida, resposta correta e acerto/erro.

Cada participante/e-mail tem um envio por treinamento. A nota é calculada no banco. Depois do primeiro envio, as perguntas ficam bloqueadas para preservar o relatório: para outra avaliação, crie um novo treinamento. Capa e materiais continuam editáveis. Os dados de cada envio são preservados no relatório.

## Ativação necessária no Supabase

No projeto `gnxglqjrvnetkbmzetfc`, a opção **Authentication → Sign In / Providers → Allow anonymous sign-ins** foi habilitada e salva em 16/11/2026, após acesso do proprietário ao painel. O fluxo usa a sessão anônima do Supabase, sem senha nem cadastro manual pelo administrador.

## Implementação e validação

- Migração: `supabase/migrations/20261116215706_partner_training_events.sql`, aplicada no banco conectado.
- A migração depende da base de convidados já existente (`partner_companies`, `guest_registrations`, `fn_is_guest`, `fn_is_admin`). Não é um bootstrap completo de banco vazio.
- Testes de banco: `sql/tests_partner_training.sql`, com rollback integral dos dados de verificação. Verificam cadastro, publicação, gabarito oculto, acesso por empresa, privacidade de respostas, correção, envio idempotente e bloqueio de edição após resposta.
- Testes da exportação: `src/__tests__/PartnerTrainingExport.test.js`, incluindo acentos, separadores, empate na classificação e proteção contra fórmulas em células.
- Frontend: `npm run build`; suíte: `npm test -- --run`.
- A hospedagem utilizada é o **Netlify**. `netlify.toml` configura `npm run build`, publicação da pasta `dist` e o redirecionamento da aplicação. O build usa a raiz `/`. No ambiente do Netlify devem estar configuradas `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY`, sempre com chave pública; não usar chave administrativa. O workflow de GitHub Pages criado durante a implementação foi removido após a confirmação da hospedagem correta.
