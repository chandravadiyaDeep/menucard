const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const test = require('node:test');

// A tiny DOM surface is enough to exercise the real renderer without a browser dependency.
class FakeElement {
  constructor(tag = 'div') {
    this.tagName = tag;
    this.children = [];
    this.listeners = {};
    this.dataset = {};
    this.textContent = '';
    this.className = '';
    this.value = '';
  }

  append(...nodes) { this.children.push(...nodes); }
  replaceChildren(...nodes) { this.children = [...nodes]; }
  addEventListener(name, callback) { this.listeners[name] = callback; }
}

function collectText(node) {
  return [node.textContent, ...node.children.map(collectText)].join(' ');
}

test('customer renderer applies selected template and filters matching menu items', () => {
  const ids = ['shop-name', 'shop-description', 'shop-meta', 'language-select', 'menu-content', 'menu-status', 'menu-search'];
  const elements = Object.fromEntries(ids.map((id) => [id, new FakeElement(id)]));
  const document = {
    body: { dataset: {} },
    documentElement: { lang: '' },
    addEventListener(name, callback) { this.listeners ??= {}; this.listeners[name] = callback; },
    getElementById(id) { return elements[id]; },
    createElement(tag) { return new FakeElement(tag); }
  };
  const preview = {
    schema_version: 1,
    revision: 7,
    updated_at: '2026-11-27T10:00:00.000Z',
    template_id: 'editorial-terracotta',
    default_locale: 'en',
    languages: ['en', 'gu'],
    currency: 'INR',
    shop: {
      name: { en: 'Nukkad Cafe', gu: 'નુક્કડ કેફે' },
      description: { en: 'Fresh tea and snacks' },
      address: 'Main market',
      phone: ''
    },
    categories: [
      {
        sort_order: 0,
        translations: { en: { title: 'Drinks' } },
        items: [
          { sort_order: 0, price_minor: 2000, available: true, translations: { en: { name: 'Masala Chai', description: 'Ginger tea' } } }
        ]
      },
      {
        sort_order: 1,
        translations: { en: { title: 'Snacks' } },
        items: [
          { sort_order: 0, price_minor: 1500, available: false, translations: { en: { name: 'Samosa', description: 'Potato snack' } } }
        ]
      }
    ]
  };
  const source = fs.readFileSync('app/assets/publish/assets/menu.js', 'utf8');
  vm.runInNewContext(source, { document, window: { __MENUCARD_PREVIEW__: preview } });
  document.listeners.DOMContentLoaded();

  assert.equal(document.body.dataset.layout, 'editorial');
  assert.equal(document.body.dataset.theme, 'terracotta');
  assert.equal(elements['shop-name'].textContent, 'Nukkad Cafe');
  assert.match(collectText(elements['menu-content']), /Masala Chai/);
  assert.match(collectText(elements['menu-content']), /Samosa/);

  elements['menu-search'].value = 'samosa';
  elements['menu-search'].listeners.input();
  const filtered = collectText(elements['menu-content']);
  assert.match(filtered, /Samosa/);
  assert.doesNotMatch(filtered, /Masala Chai/);
  assert.equal(elements['menu-status'].textContent, '1 matching item(s)');

  elements['language-select'].value = 'gu';
  elements['language-select'].listeners.change();
  assert.equal(document.documentElement.lang, 'gu');
  assert.equal(elements['shop-name'].textContent, 'નુક્કડ કેફે');
});
