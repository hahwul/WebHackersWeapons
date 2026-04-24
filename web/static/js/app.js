(function () {
  "use strict";

  const grid = document.getElementById("weaponGrid");
  if (!grid) return;

  const filter = document.getElementById("weaponFilter");
  const typeSel = document.getElementById("typeFilter");
  const langSel = document.getElementById("langFilter");
  const empty = document.getElementById("emptyState");
  const cards = Array.from(grid.querySelectorAll(".card"));

  // Populate filter dropdowns from the card dataset.
  function populate(select, key, labelKey) {
    if (!select) return;
    const seen = new Map();
    for (const c of cards) {
      const v = (c.dataset[key] || "").trim();
      if (!v) continue;
      if (!seen.has(v)) seen.set(v, c.dataset[labelKey] || v);
    }
    const options = Array.from(seen.entries()).sort((a, b) =>
      a[1].localeCompare(b[1], undefined, { sensitivity: "base" })
    );
    for (const [value, label] of options) {
      const opt = document.createElement("option");
      opt.value = value;
      opt.textContent = label;
      select.appendChild(opt);
    }
  }

  populate(typeSel, "type", "typeLabel");
  populate(langSel, "lang", "langLabel");

  function apply() {
    const q = (filter?.value || "").trim().toLowerCase();
    const type = (typeSel?.value || "").toLowerCase();
    const lang = (langSel?.value || "").toLowerCase();

    let shown = 0;
    for (const card of cards) {
      const name = card.dataset.name || "";
      const tags = card.dataset.tags || "";
      const cType = card.dataset.type || "";
      const cLang = card.dataset.lang || "";

      const matchesQuery = !q || name.includes(q) || tags.includes(q) || cType.includes(q) || cLang.includes(q);
      const matchesType = !type || cType === type;
      const matchesLang = !lang || cLang === lang;

      const visible = matchesQuery && matchesType && matchesLang;
      card.style.display = visible ? "" : "none";
      if (visible) shown++;
    }
    if (empty) empty.hidden = shown !== 0;
  }

  filter?.addEventListener("input", apply);
  typeSel?.addEventListener("change", apply);
  langSel?.addEventListener("change", apply);

  // Focus filter with "/" when not typing elsewhere.
  document.addEventListener("keydown", (e) => {
    if (e.key !== "/" || e.target.matches("input, textarea, select")) return;
    e.preventDefault();
    filter?.focus();
  });
})();
