const SHEETS_URL = "https://script.google.com/macros/s/AKfycbyv0UhVSiM52K-g8A31Myih_UMMGKhZIwRAAMcMW_3WwYofjgtNCV-6J7p6iv0ODSsU/exec";

function registerResult(pct) {
  const nameInput = document.getElementById('regName');
  const name = nameInput ? nameInput.value.trim() : "";

  if (!name) {
    alert("Digite seu nome");
    return;
  }

  fetch(SHEETS_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      nome: name,
      modulo: "Módulo 1 — Universo Garmin",
      nota: pct,
      acertos: Math.round(pct / 10),
      total: 10
    })
  })
  .then(() => {
    alert("Resultado enviado!");
  })
  .catch((err) => {
    console.error(err);
    alert("Erro ao enviar");
  });
}
