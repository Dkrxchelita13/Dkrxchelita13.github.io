const root = document.documentElement;
const header = document.querySelector("[data-site-header]");
const navigation = document.querySelector("#primary-navigation");
const navToggle = document.querySelector(".nav-toggle");
const themeToggle = document.querySelector("[data-theme-toggle]");
const themeColorMeta = document.querySelector("#theme-color-meta");
const systemTheme = window.matchMedia("(prefers-color-scheme: light)");

const THEME_STORAGE_KEY = "portfolio-theme";

function getStoredTheme() {
  try {
    return localStorage.getItem(THEME_STORAGE_KEY);
  } catch (error) {
    return null;
  }
}

function updateThemeControls(theme) {
  if (!themeToggle) {
    return;
  }

  const isDark = theme === "dark";
  const nextThemeLabel = isDark
    ? themeToggle.dataset.lightLabel
    : themeToggle.dataset.darkLabel;

  themeToggle.setAttribute("aria-label", nextThemeLabel);
  themeToggle.setAttribute("title", nextThemeLabel);
  themeToggle.setAttribute("aria-pressed", String(!isDark));

  const visibleLabel = themeToggle.querySelector(".theme-label");
  if (visibleLabel) {
    visibleLabel.textContent = nextThemeLabel;
  }

  if (themeColorMeta) {
    themeColorMeta.setAttribute("content", isDark ? "#07111f" : "#f5f8fc");
  }
}

function applyTheme(theme, persist = false) {
  const normalizedTheme = theme === "light" ? "light" : "dark";
  root.dataset.theme = normalizedTheme;
  updateThemeControls(normalizedTheme);

  if (persist) {
    try {
      localStorage.setItem(THEME_STORAGE_KEY, normalizedTheme);
    } catch (error) {
      // The theme still works when storage is unavailable.
    }
  }
}

applyTheme(root.dataset.theme || "dark");

if (themeToggle) {
  themeToggle.addEventListener("click", () => {
    const nextTheme = root.dataset.theme === "dark" ? "light" : "dark";
    applyTheme(nextTheme, true);
  });
}

systemTheme.addEventListener("change", (event) => {
  if (!getStoredTheme()) {
    applyTheme(event.matches ? "light" : "dark");
  }
});

function setNavigationState(isOpen) {
  if (!navigation || !navToggle) {
    return;
  }

  navigation.classList.toggle("is-open", isOpen);
  navToggle.classList.toggle("is-open", isOpen);
  navToggle.setAttribute("aria-expanded", String(isOpen));
  navToggle.setAttribute(
    "aria-label",
    isOpen ? navToggle.dataset.closeLabel : navToggle.dataset.openLabel,
  );

  document.body.classList.toggle("navigation-open", isOpen);
}

if (navToggle && navigation) {
  navToggle.addEventListener("click", () => {
    setNavigationState(!navigation.classList.contains("is-open"));
  });

  navigation.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => setNavigationState(false));
  });

  document.addEventListener("click", (event) => {
    const clickedInsideNavigation = navigation.contains(event.target);
    const clickedToggle = navToggle.contains(event.target);

    if (!clickedInsideNavigation && !clickedToggle) {
      setNavigationState(false);
    }
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      setNavigationState(false);
      navToggle.focus();
    }
  });

  window.addEventListener("resize", () => {
    if (window.innerWidth > 860) {
      setNavigationState(false);
    }
  });
}

function updateHeaderState() {
  if (header) {
    header.classList.toggle("is-scrolled", window.scrollY > 12);
  }
}

updateHeaderState();
window.addEventListener("scroll", updateHeaderState, { passive: true });

const revealElements = document.querySelectorAll(".reveal");
const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

if (reducedMotion || !("IntersectionObserver" in window)) {
  revealElements.forEach((element) => element.classList.add("is-visible"));
} else {
  const revealObserver = new IntersectionObserver(
    (entries, observer) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        }
      });
    },
    {
      threshold: 0.14,
      rootMargin: "0px 0px -40px",
    },
  );

  revealElements.forEach((element) => revealObserver.observe(element));
}


const copyEmailButton = document.querySelector("[data-copy-email]");
const copyFeedback = document.querySelector("[data-copy-feedback]");
let copyFeedbackTimer;

async function copyTextToClipboard(text) {
  if (navigator.clipboard && window.isSecureContext) {
    await navigator.clipboard.writeText(text);
    return;
  }

  const temporaryInput = document.createElement("textarea");
  temporaryInput.value = text;
  temporaryInput.setAttribute("readonly", "");
  temporaryInput.style.position = "fixed";
  temporaryInput.style.opacity = "0";
  document.body.appendChild(temporaryInput);
  temporaryInput.select();

  const copied = document.execCommand("copy");
  temporaryInput.remove();

  if (!copied) {
    throw new Error("Clipboard copy failed");
  }
}

if (copyEmailButton && copyFeedback) {
  copyEmailButton.addEventListener("click", async () => {
    const email = copyEmailButton.dataset.copyEmail;

    try {
      await copyTextToClipboard(email);
      copyFeedback.textContent = copyEmailButton.dataset.successLabel;
      copyEmailButton.classList.add("is-success");
    } catch (error) {
      copyFeedback.textContent = copyEmailButton.dataset.errorLabel;
      copyEmailButton.classList.remove("is-success");
    }

    window.clearTimeout(copyFeedbackTimer);
    copyFeedbackTimer = window.setTimeout(() => {
      copyFeedback.textContent = "";
      copyEmailButton.classList.remove("is-success");
    }, 3000);
  });
}
