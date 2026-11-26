// MenuCard static customer viewer. This file runs only in the customer's browser.
(() => {
  const $ = (id) => document.getElementById(id);
  let menu = null;
  let activeLocale = "en";

  // Resolve a translated category/item field with the documented fallback order.
  function translated(translations, field) {
    const locales = [activeLocale, menu.default_locale, ...(menu.languages || [])];
    for (const locale of [...new Set(locales)]) {
      const value = translations?.[locale]?.[field];
      if (typeof value === "string" && value.trim()) return value;
    }
    return "";
  }

  // Shop profile translations are simple locale-to-string values.
  function translatedShopText(values) {
    const locales = [activeLocale, menu.default_locale, ...(menu.languages || [])];
    for (const locale of [...new Set(locales)]) {
      const value = values?.[locale];
      if (typeof value === "string" && value.trim()) return value;
    }
    return "";
  }

  // Build DOM nodes with textContent; never inject owner-entered text as HTML.
  function element(tag, className, text) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined) node.textContent = text;
    return node;
  }

  function render() {
    $("shop-name").textContent = translatedShopText(menu.shop.name) || "Digital Menu";
    $("shop-description").textContent = translatedShopText(menu.shop.description);
    const meta = [menu.shop.address, menu.shop.phone].filter(Boolean).join(" · ");
    $("shop-meta").textContent = meta;

    const content = $("menu-content");
    content.replaceChildren();
    const categories = [...(menu.categories || [])].sort((a, b) => a.sort_order - b.sort_order);
    if (!categories.length) content.append(element("p", "empty", "This menu has no items yet."));

    for (const category of categories) {
      const section = element("section", "category");
      section.append(element("h2", "", translated(category.translations, "title") || "Menu"));
      const items = [...(category.items || [])].sort((a, b) => a.sort_order - b.sort_order);
      for (const item of items) {
        const card = element("article", "menu-item");
        const copy = element("div", "item-copy");
        copy.append(element("h3", "", translated(item.translations, "name") || "Unnamed item"));
        const description = translated(item.translations, "description");
        if (description) copy.append(element("p", "", description));
        card.append(copy);

        const priceColumn = element("div", "");
        priceColumn.append(element("div", "price", formatPrice(item.price_minor, item.currency || menu.currency)));
        if (!item.available) priceColumn.append(element("span", "unavailable", "Currently unavailable"));
        card.append(priceColumn);
        if (item.image) {
          const image = document.createElement("img");
          image.className = "item-image";
          image.src = item.image;
          image.alt = "";
          image.loading = "lazy";
          card.append(image);
        }
        section.append(card);
      }
      content.append(section);
    }

    $("menu-status").textContent = "Published revision " + menu.revision +
      " · Updated " + new Date(menu.updated_at).toLocaleString();
    document.documentElement.lang = activeLocale;
  }

  // Prices are stored as integer paise to avoid floating-point currency errors.
  function formatPrice(priceMinor, currency) {
    const amount = Number(priceMinor);
    if (!Number.isFinite(amount)) return "Price unavailable";
    return new Intl.NumberFormat(activeLocale, {
      style: "currency",
      currency: currency || "INR",
      maximumFractionDigits: 2
    }).format(amount / 100);
  }

  async function start() {
    try {
      // Revalidate JSON on each page load; the static host must allow cache revalidation too.
      const response = await fetch("menu.json", { cache: "no-store" });
      if (!response.ok) throw new Error("Menu file not found");
      menu = await response.json();
      if (menu.schema_version !== 1 || !menu.shop || !Array.isArray(menu.categories)) {
        throw new Error("Unsupported or invalid menu file");
      }
      const select = $("language-select");
      const languages = menu.languages?.length ? menu.languages : [menu.default_locale || "en"];
      for (const locale of languages) {
        const option = document.createElement("option");
        option.value = locale;
        option.textContent = ({ en: "English", gu: "ગુજરાતી", hi: "हिन्दી" })[locale] || locale;
        select.append(option);
      }
      activeLocale = languages.includes(menu.default_locale) ? menu.default_locale : languages[0];
      select.value = activeLocale;
      select.addEventListener("change", () => { activeLocale = select.value; render(); });
      render();
    } catch (error) {
      $("shop-name").textContent = "Menu unavailable";
      $("menu-status").textContent = error.message + ". Please contact the shop.";
    }
  }

  document.addEventListener("DOMContentLoaded", start);
})();
