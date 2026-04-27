const SHEETS_URL = "https://script.google.com/macros/s/AKfycbyMWnxsNOLK9yR9D8KfZfxilFMzN267r56Dhq4CTHwMCu75uNd1v8Z-s6TE_mC66N9x/exec";

function registerResult(pct) {
  const name = document.getElementById('regName').value.trim();

  fetch(SHEETS_URL, {
    method: "POST",
    body: JSON.stringify({
      nome: name,
      modulo: "Módulo 1 — Universo Garmin",
      nota: pct,
      acertos: Math.round(pct / 10),
      total: 10
    })
  })
  .then(res => res.json())
  .then(data => {
    alert("Resultado enviado!");
  })
  .catch(err => {
    alert("Erro ao enviar");
    console.error(err);
  });
}
