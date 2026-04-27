const SHEETS_URL = "https://script.google.com/macros/s/AKfycbyv0UhVSiM52K-g8A31Myih_UMMGKhZIwRAAMcMW_3WwYofjgtNCV-6J7p6iv0ODSsU/exec";

function registerResult(pct) {
  try {
    const input = document.getElementById('regName');
    const name = input ? input.value.trim() : "";

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
      console.log("Enviado com sucesso");

      const form = document.querySelector('.register-form');
      const success = document.getElementById('regSuccess');

      if (form) form.style.display = 'none';
      if (success) success.style.display = 'block';
    })
    .catch((err) => {
      console.error("Erro:", err);
      alert("Erro ao enviar");
    });

  } catch (e) {
    console.error("Erro geral:", e);
  }
}
