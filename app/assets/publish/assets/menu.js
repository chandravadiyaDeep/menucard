// MenuCard static customer viewer. All data is read from the sibling public JSON file.
(() => {
  const $ = (id) => document.getElementById(id);
  let menu = null;
  let activeLocale = "en";

  // Resolve category/item translations with requested, shop default, then any available locale.
  function translated(translations, field) {
    const locales = [activeLocale, menu.default_locale, ...(menu.languages || [])];
    for (const locale of [...new Set(locales)]) {
      const value = translations?.[locale]?.[field];
      if (typeof value === "string" && value.trim()) return value;
    }
    return "";
  }

  // Shop profile translations are locale-to-string maps.
  function translatedShopText(values) {
    const locales = [activeLocale, menu.default_locale, ...(menu.languages || [])];
    for (const locale of [...new Set(locales)]) {
      const value = values?.[locale];
      if (typeof value === "string" && value.trim()) return value;
    }
    return "";
  }

  // Render owner-provided values as text, never as executable HTML.
  function element(tag, className, text) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined) node.textContent = text;
    return node;
  }

  function render() {
    // Apply the owner's selected template using an allowlisted layout/theme pair.
    // All menu text remains data; the design only changes how that data is presented.
    const templateParts = String(menu.template_id || "classic-forest").split("-");
    const layouts = new Set(["classic", "editorial", "compact", "photo", "chalkboard", "luxury", "modern", "rustic", "bistro", "streetfood"]);
    const themes = new Set(["forest", "ocean", "saffron", "rose", "midnight", "cream", "lavender", "terracotta", "emerald", "cobalt", "charcoal", "coral"]);
    document.body.dataset.layout = layouts.has(templateParts[0]) ? templateParts[0] : "classic";
    document.body.dataset.theme = themes.has(templateParts[1]) ? templateParts[1] : "forest";

    $("shop-name").textContent = translatedShopText(menu.shop.name) || "Digital Menu";
    $("shop-description").textContent = translatedShopText(menu.shop.description);
    $("shop-meta").textContent = [menu.shop.address, menu.shop.phone].filter(Boolean).join(" · ");

    const content = $("menu-content");
    content.replaceChildren();
    const searchTerm = ($("menu-search")?.value || "").trim().toLocaleLowerCase(activeLocale);
    const categories = [...menu.categories].sort((a, b) => a.sort_order - b.sort_order);
    let visibleItemCount = 0;

    for (const category of categories) {
      const categoryTitle = translated(category.translations, "title") || "Menu";
      const allItems = [...(category.items || [])].sort((a, b) => a.sort_order - b.sort_order);
      const categoryMatches = categoryTitle.toLocaleLowerCase(activeLocale).includes(searchTerm);
      const items = searchTerm && !categoryMatches
        ? allItems.filter((item) => {
            const name = translated(item.translations, "name").toLocaleLowerCase(activeLocale);
            const description = translated(item.translations, "description").toLocaleLowerCase(activeLocale);
            return name.includes(searchTerm) || description.includes(searchTerm);
          })
        : allItems;
      if (searchTerm && items.length === 0) continue;
      const section = element("section", "category");
      section.append(element("h2", "", categoryTitle));
      visibleItemCount += items.length;
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

    if (searchTerm && visibleItemCount === 0) {
      content.append(element("p", "empty", "No menu items match your search."));
    } else if (!categories.length) {
      content.append(element("p", "empty", "This menu has no items yet."));
    }
    $("menu-status").textContent = searchTerm
      ? visibleItemCount + " matching item(s)"
      : "Published revision " + menu.revision + " · Updated " + new Date(menu.updated_at).toLocaleString();
    document.documentElement.lang = activeLocale;
  }

  // Prices are stored in integer paise to avoid floating-point currency errors.
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
      // Revalidate on every page load. The host must also permit menu.json cache revalidation.
      // The owner preview injects its private local snapshot. Public pages fetch menu.json.
      if (window.__MENUCARD_PREVIEW__) {
        menu = window.__MENUCARD_PREVIEW__;
      } else {
        const response = await fetch("menu.json", { cache: "no-store" });
        if (!response.ok) throw new Error("Menu file not found");
        menu = await response.json();
      }
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
      $("menu-search")?.addEventListener("input", render);
      render();
    } catch (error) {
      $("shop-name").textContent = "Menu unavailable";
      $("menu-status").textContent = error.message + ". Please contact the shop.";
    }
  }

  document.addEventListener("DOMContentLoaded", start);
})();
