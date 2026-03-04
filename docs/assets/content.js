(function () {
  const root = document.getElementById("content-root");
  if (!root) {
    return;
  }

  const markdownPath = root.dataset.markdownPath;
  if (!markdownPath) {
    root.innerHTML = '<p class="error-state">Missing markdown path configuration.</p>';
    return;
  }

  const setActiveNav = function () {
    const activeKey = document.body.dataset.page;
    if (!activeKey) {
      return;
    }

    const navLink = document.querySelector(`[data-nav="${activeKey}"]`);
    if (navLink) {
      navLink.setAttribute("aria-current", "page");
    }
  };

  const fallbackMarkdown = function (text) {
    return text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\n\n/g, "</p><p>")
      .replace(/\n/g, "<br>")
      .replace(/^# (.*)$/gm, "<h1>$1</h1>")
      .replace(/^## (.*)$/gm, "<h2>$1</h2>")
      .replace(/^### (.*)$/gm, "<h3>$1</h3>")
      .replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>")
      .replace(/\*(.*?)\*/g, "<em>$1</em>")
      .replace(/^\- (.*)$/gm, "<li>$1</li>")
      .replace(/(<li>.*<\/li>)/gs, "<ul>$1</ul>")
      .replace(/<ul>([\s\S]*?)<\/ul>/g, function (match) {
        return match.replace(/<\/li>\s*<li>/g, "</li><li>");
      });
  };

  const renderMarkdown = function (markdownText) {
    if (window.marked && typeof window.marked.parse === "function") {
      return window.marked.parse(markdownText);
    }
    return `<p>${fallbackMarkdown(markdownText)}</p>`;
  };

  const setFooterYear = function () {
    const yearNode = document.getElementById("footer-year");
    if (yearNode) {
      yearNode.textContent = String(new Date().getFullYear());
    }
  };

  setActiveNav();
  setFooterYear();

  fetch(markdownPath, { cache: "no-cache" })
    .then(function (response) {
      if (!response.ok) {
        throw new Error(`Unable to load content (${response.status})`);
      }
      return response.text();
    })
    .then(function (markdownText) {
      root.classList.remove("state-note");
      root.innerHTML = renderMarkdown(markdownText);
    })
    .catch(function (error) {
      root.classList.remove("state-note");
      root.innerHTML = `<p class="error-state">${error.message}</p>`;
    });
})();
