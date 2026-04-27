const SHEETSURL = 'https://script.google.com/macros/s/AKfycbyv0UhVSiM52K-g8A31Myih_UMMGKhZIwRAAMcMW_3WwYofjgtNCV-6J7p6iv0ODSsU/exec';

async function registerResult(pct) {
  const nameInput = document.getElementById('regName');
  const successBox = document.getElementById('regSuccess');
  const form = document.querySelector('.register-form');
  const btn = document.querySelector('.register-btn');

  const name = nameInput.value.trim();

  if (!name) {
    nameInput.style.borderColor = 'var(--warn)';
    nameInput.focus();
    return;
  }

  nameInput.style.borderColor = 'var(--border)';
  btn.textContent = 'Enviando...';
  btn.disabled = true;

  try {
    const payload = {
      nome: name,
      modulo: 'Módulo 1 - Universo Garmin',
      nota: pct,
      acertos: Math.round((pct / 100) * 10),
      total: 10
    };

    const response = await fetch(SHEETSURL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    const text = await response.text();
    let result = {};

    try {
      result = JSON.parse(text);
    } catch (e) {
      throw new Error('Resposta inválida do Apps Script.');
    }

    if (!response.ok || result.success === false) {
      throw new Error(result.error || 'Falha ao registrar resultado.');
    }

    form.style.display = 'none';
    successBox.style.display = 'block';

  } catch (error) {
    btn.textContent = 'Registrar Conclusão';
    btn.disabled = false;
    alert('Erro ao registrar: ' + error.message);
  }
}
