// ============================================================
// GOOGLE APPS SCRIPT — Garmin Training Quiz
// Cole este código em: script.google.com > Novo projeto
// Depois publique como "Aplicativo da Web"
// ============================================================

// ID da planilha do Google Sheets
// Troque pelo ID real da sua planilha, se necessário
const SPREADSHEET_ID = '1jltq1uvJOnO8_Bw4Fjn752kCmWkYMc01x90tL_fx7es';

// Nome da aba onde os dados serão salvos
const SHEET_NAME = 'Resultados';

/**
 * Garante que a aba exista e tenha cabeçalho
 */
function getOrCreateSheet_() {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  let sheet = ss.getSheetByName(SHEET_NAME);

  if (!sheet) {
    sheet = ss.insertSheet(SHEET_NAME);
  }

  if (sheet.getLastRow() === 0) {
    sheet.appendRow([
      'Data/Hora',
      'Enviado em ISO',
      'Nome',
      'Módulo',
      'Nota (%)',
      'Acertos',
      'Total de Questões',
      'Status',
      'Origem'
    ]);

    const header = sheet.getRange(1, 1, 1, 9);
    header.setBackground('#007CC3');
    header.setFontColor('#FFFFFF');
    header.setFontWeight('bold');
  }

  return sheet;
}

/**
 * Endpoint POST para receber os resultados do quiz
 */
function doPost(e) {
  try {
    if (!e || !e.postData || !e.postData.contents) {
      throw new Error('Nenhum payload recebido no POST.');
    }

    const dados = JSON.parse(e.postData.contents);

    const nome = dados.nome || 'Não informado';
    const modulo = dados.modulo || 'Módulo 1';
    const nota = Number(dados.nota || 0);
    const acertos = Number(dados.acertos || 0);
    const total = Number(dados.total || 0);
    const origem = dados.origem || 'Garmin Training Site';

    const dataHora = new Date().toLocaleString('pt-BR', {
      timeZone: 'America/Sao_Paulo'
    });
    const enviadoIso = new Date().toISOString();
    const status = nota >= 70 ? 'APROVADO ✓' : 'Reprovado';

    const sheet = getOrCreateSheet_();

    sheet.appendRow([
      dataHora,
      enviadoIso,
      nome,
      modulo,
      nota + '%',
      acertos,
      total,
      status,
      origem
    ]);

    const lastRow = sheet.getLastRow();

    if (nota >= 70) {
      sheet.getRange(lastRow, 8).setBackground('#e6faf7').setFontColor('#007a6a');
    } else {
      sheet.getRange(lastRow, 8).setBackground('#fff4f0').setFontColor('#c84a1a');
    }

    return ContentService
      .createTextOutput(JSON.stringify({
        success: true,
        message: 'Resultado registrado com sucesso!',
        row: lastRow
      }))
      .setMimeType(ContentService.MimeType.JSON);

  } catch (erro) {
    return ContentService
      .createTextOutput(JSON.stringify({
        success: false,
        error: String(erro)
      }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

/**
 * Endpoint GET para testar se o Web App está online
 */
function doGet() {
  return ContentService
    .createTextOutput(JSON.stringify({
      success: true,
      status: 'online',
      message: 'Garmin Training Quiz API funcionando!'
    }))
    .setMimeType(ContentService.MimeType.JSON);
}
