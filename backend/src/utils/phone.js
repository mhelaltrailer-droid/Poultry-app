export function normalizePhone(input) {
  return String(input ?? '')
    .replace(/\s/g, '')
    .trim();
}
