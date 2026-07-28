(function () {
  const root = document.documentElement;
  root.classList.add("js");

  try {
    const savedTheme = localStorage.getItem("portfolio-theme");
    const prefersLight = window.matchMedia("(prefers-color-scheme: light)").matches;
    root.dataset.theme = savedTheme || (prefersLight ? "light" : "dark");
  } catch (error) {
    root.dataset.theme = "dark";
  }
})();
