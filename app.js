const SHEETS_URL = "https://script.google.com/macros/s/AKfycbyMWnxsNOLK9yR9D8KfZfxilFMzN267r56Dhq4CTHwMCu75uNd1v8Z-s6TE_mC66N9x/exec";

function enviarResultado(nome, modulo, nota, acertos, total) {
  fetch(SHEETS_URL, {
    method: "POST",
    body: JSON.stringify({
      nome: nome,
      modulo: modulo,
      nota: nota,
      acertos: acertos,
      total: total
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
