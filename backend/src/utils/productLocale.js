/**
 * Pick display name for order snapshot / UI from localized product fields.
 * @param {object} product — mongoose doc or lean object
 * @param {string} [locale] — 'ar', 'en', or BCP47
 */
export function resolveProductName(product, locale = 'en') {
  const code = String(locale || 'en').toLowerCase().startsWith('ar')
    ? 'ar'
    : 'en';
  if (code === 'ar') {
    const t = String(product.nameAr || '').trim();
    if (t) return t;
  } else {
    const t = String(product.nameEn || '').trim();
    if (t) return t;
  }
  return String(product.name || '').trim() || 'Product';
}
