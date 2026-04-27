// ============================================================
// GOOGLE APPS SCRIPT — Garmin Training Quiz
// Cole este código em: script.google.com > Novo projeto
// Depois publique como "Aplicativo da Web"
// ============================================================

// ID da planilha do Google Sheets (substitua pelo seu)
// Encontre na URL: docs.google.com/spreadsheets/d/1yJhiPOX5eDz1HuiTjWTiqggOvDRTcpke249ZWzzWYWLT-bcx7PRCrwp9/edit
const SPREADSHEET_ID = '1yJhiPOX5eDz1HuiTjWTiqggOvDRTcpke249ZWzzWYWLT-bcx7PRCrwp9';

// Nome da aba onde os dados serão salvos
const SHEET_NAME = 'Resultados';

/**
 * Função principal que recebe os dados do quiz via POST
 * e salva na planilha do Google Sheets
 */
function doPost(e) {
  try {
    // Lê os dados enviados pelo quiz
    const dados = JSON.parse(e.postData.contents);

    // Abre a planilha
    const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
    let sheet = ss.getSheetByName(SHEET_NAME);

    // Cria a aba se não existir e adiciona cabeçalho
    if (!sheet) {
      sheet = ss.insertSheet(SHEET_NAME);
      sheet.appendRow([
        'Data/Hora',
        'Nome',
        'Módulo',
        'Nota (%)',
        'Acertos',
        'Total de Questões',
        'Status'
      ]);
      // Formata o cabeçalho
      const header = sheet.getRange(1, 1, 1, 7);
      header.setBackground('#007CC3');
      header.setFontColor('#FFFFFF');
      header.setFontWeight('bold');
    }

    // Prepara a linha de dados
    const dataHora = new Date().toLocaleString('pt-BR', { timeZone: 'America/Sao_Paulo' });
    const status = dados.nota >= 70 ? 'APROVADO ✓' : 'Reprovado';

    // Adiciona a linha na planilha
    sheet.appendRow([
      dataHora,
      dados.nome || 'Não informado',
      dados.modulo || 'Módulo 1',
      dados.nota + '%',
      dados.acertos || '-',
      dados.total || 10,
      status
    ]);

    // Formata automaticamente linhas de aprovados em verde
    if (dados.nota >= 70) {
      const lastRow = sheet.getLastRow();
      sheet.getRange(lastRow, 7).setBackground('#e6faf7').setFontColor('#007a6a');
    }

    // Resposta de sucesso
    return ContentService
      .createTextOutput(JSON.stringify({ success: true, message: 'Resultado registrado!' }))
      .setMimeType(ContentService.MimeType.JSON);

  } catch (erro) {
    // Resposta de erro
    return ContentService
      .createTextOutput(JSON.stringify({ success: false, error: erro.toString() }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

/**
 * Função GET para testar se o script está funcionando
 * Acesse a URL do Web App no navegador para verificar
 */
function doGet() {
  return ContentService
    .createTextOutput(JSON.stringify({
      status: 'online',
      message: 'Garmin Training Quiz API funcionando!',
      planilha: SPREADSHEET_ID !== '1yJhiPOX5eDz1HuiTjWTiqggOvDRTcpke249ZWzzWYWLT-bcx7PRCrwp9' ? 'Configurada ✓' : 'NÃO CONFIGURADA ⚠️'
    }))
    .setMimeType(ContentService.MimeType.JSON);
}

// ============================================================
// INSTRUÇÕES DE PUBLICAÇÃO:
//
// 1. Abra script.google.com
// 2. Crie um novo projeto
// 3. Cole este código
// 4. Substitua SPREADSHEET_ID pelo ID da sua planilha
// 5. Clique em "Implantar" > "Nova implantação"
// 6. Tipo: "Aplicativo da Web"
// 7. Executar como: "Eu (seu e-mail)"
// 8. Quem pode acessar: "Qualquer pessoa"
// 9. Clique em "Implantar" e copie a URL gerada
// 10. Cole a URL no arquivo app.js na variável SHEETS_URL
// ============================================================
