/// Data-driven ready-made menu design library.
////
//// Ten layout families combined with twelve curated visual themes provide
//// 120 selectable menu designs without duplicating shop content.
class MenuTemplate {
  const MenuTemplate({
    required this.id,
    required this.name,
    required this.layoutId,
    required this.layoutName,
    required this.themeId,
    required this.themeName,
    required this.primaryHex,
    required this.backgroundHex,
    required this.accentHex,
    required this.textHex,
  });

  final String id;
  final String name;
  final String layoutId;
  final String layoutName;
  final String themeId;
  final String themeName;
  final String primaryHex;
  final String backgroundHex;
  final String accentHex;
  final String textHex;

  // Convert CSS-style hexadecimal colors into Flutter ARGB color integers.
  int get primaryColor => int.parse('FF${primaryHex.substring(1)}', radix: 16);
  int get backgroundColor => int.parse('FF${backgroundHex.substring(1)}', radix: 16);
  int get accentColor => int.parse('FF${accentHex.substring(1)}', radix: 16);
  int get textColor => int.parse('FF${textHex.substring(1)}', radix: 16);
}

class MenuTemplateCatalog {
  MenuTemplateCatalog._();

  static const layouts = <({String id, String name})>[
    (id: 'classic', name: 'Classic'),
    (id: 'editorial', name: 'Editorial'),
    (id: 'compact', name: 'Compact'),
    (id: 'photo', name: 'Photo menu'),
    (id: 'chalkboard', name: 'Chalkboard'),
    (id: 'luxury', name: 'Luxury'),
    (id: 'modern', name: 'Modern'),
    (id: 'rustic', name: 'Rustic'),
    (id: 'bistro', name: 'Bistro'),
    (id: 'streetfood', name: 'Street food'),
  ];

  static const themes = <({String id, String name, String primary, String background, String accent, String text})>[
    (id: 'forest', name: 'Forest green', primary: '#174B3A', background: '#F4F5ED', accent: '#B9D5B8', text: '#20342A'),
    (id: 'ocean', name: 'Ocean blue', primary: '#174B68', background: '#F1F7FA', accent: '#A9D9E8', text: '#203440'),
    (id: 'saffron', name: 'Saffron spice', primary: '#9A4B16', background: '#FFF7E8', accent: '#F2C36B', text: '#432B1C'),
    (id: 'rose', name: 'Rose blush', primary: '#813C50', background: '#FFF5F5', accent: '#F0C6D0', text: '#422A32'),
    (id: 'midnight', name: 'Midnight', primary: '#202638', background: '#111827', accent: '#D8B56D', text: '#F7F3E9'),
    (id: 'cream', name: 'Warm cream', primary: '#59432E', background: '#FBF4E7', accent: '#E8D5B4', text: '#3D3024'),
    (id: 'lavender', name: 'Lavender', primary: '#59477C', background: '#F7F3FC', accent: '#D8C8F0', text: '#302844'),
    (id: 'terracotta', name: 'Terracotta', primary: '#8A3F2D', background: '#FAF0E9', accent: '#E6B39B', text: '#402A24'),
    (id: 'emerald', name: 'Emerald', primary: '#075B50', background: '#EFF8F4', accent: '#9CD7C4', text: '#173A34'),
    (id: 'cobalt', name: 'Cobalt pop', primary: '#2348A4', background: '#F1F4FF', accent: '#B9C8FF', text: '#1D2C50'),
    (id: 'charcoal', name: 'Charcoal', primary: '#282828', background: '#F0F0ED', accent: '#D2B36C', text: '#242424'),
    (id: 'coral', name: 'Coral sunset', primary: '#B94736', background: '#FFF2EC', accent: '#FFC2A8', text: '#482D29'),
  ];

  // Each layout/theme pair is a complete ready-made design with a stable ID.
  static final List<MenuTemplate> all = [
    for (final layout in layouts)
      for (final theme in themes)
        MenuTemplate(
          id: '${layout.id}-${theme.id}',
          name: '${layout.name} · ${theme.name}',
          layoutId: layout.id,
          layoutName: layout.name,
          themeId: theme.id,
          themeName: theme.name,
          primaryHex: theme.primary,
          backgroundHex: theme.background,
          accentHex: theme.accent,
          textHex: theme.text,
        ),
  ];

  static const defaultId = 'classic-forest';

  static MenuTemplate byId(String id) => all.firstWhere(
        (template) => template.id == id,
        orElse: () => all.firstWhere((template) => template.id == defaultId),
      );
}
