/**
 * Fuzzy ranking for product name/description (tolerates typos, EN + AR).
 * No external dependencies.
 */

function levenshtein(a, b) {
  if (a === b) return 0;
  if (!a.length) return b.length;
  if (!b.length) return a.length;
  const m = a.length;
  const n = b.length;
  const dp = Array.from({ length: m + 1 }, () => new Array(n + 1).fill(0));
  for (let i = 0; i <= m; i++) dp[i][0] = i;
  for (let j = 0; j <= n; j++) dp[0][j] = j;
  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      const cost = a[i - 1] === b[j - 1] ? 0 : 1;
      dp[i][j] = Math.min(
        dp[i - 1][j] + 1,
        dp[i][j - 1] + 1,
        dp[i - 1][j - 1] + cost
      );
    }
  }
  return dp[m][n];
}

function charSimilarity(a, b) {
  if (!a.length || !b.length) return 0;
  const d = levenshtein(a, b);
  return 1 - d / Math.max(a.length, b.length);
}

function tokenize(s) {
  return String(s || '')
    .toLowerCase()
    .trim()
    .split(/\s+/)
    .filter(Boolean);
}

/** How many chars of q appear in order inside text (0–1). */
function subsequenceRatio(q, text) {
  const qq = q.toLowerCase();
  const tt = text.toLowerCase();
  if (!qq.length) return 1;
  let j = 0;
  for (let i = 0; i < tt.length && j < qq.length; i++) {
    if (tt[i] === qq[j]) j++;
  }
  return j / qq.length;
}

function bestTokenScore(queryToken, hayTokens, fullHayLower) {
  if (!queryToken.length) return 1;
  if (fullHayLower.includes(queryToken)) return 1;

  let best = 0;
  for (const h of hayTokens) {
    if (!h.length) continue;
    if (h.includes(queryToken) || queryToken.includes(h)) {
      best = Math.max(best, 0.92);
      continue;
    }
    const sim = charSimilarity(queryToken, h);
    best = Math.max(best, sim);
    const prefixLen = Math.min(4, queryToken.length, h.length);
    if (prefixLen >= 2) {
      best = Math.max(
        best,
        charSimilarity(queryToken.slice(0, prefixLen), h.slice(0, prefixLen)) * 0.95
      );
    }
  }
  return best;
}

/**
 * @param {object} product — lean mongoose doc
 * @param {string} rawQuery
 * @returns {number} score 0..1
 */
export function scoreProductMatch(product, rawQuery) {
  const query = String(rawQuery || '').trim();
  if (!query.length) return 1;

  const name = String(product.name || '');
  const nameEn = String(product.nameEn || '');
  const nameAr = String(product.nameAr || '');
  const desc = String(product.description || '');
  const descEn = String(product.descriptionEn || '');
  const descAr = String(product.descriptionAr || '');
  const fullHay = `${name} ${nameEn} ${nameAr} ${desc} ${descEn} ${descAr}`;
  const fullHayLower = fullHay.toLowerCase();
  const hayTokens = tokenize(fullHay);

  const qTokens = tokenize(query);
  if (qTokens.length === 0) return 0;

  let tokenPart = 0;
  for (const qt of qTokens) {
    tokenPart += bestTokenScore(qt.toLowerCase(), hayTokens, fullHayLower);
  }
  tokenPart /= qTokens.length;

  const subName = Math.max(
    subsequenceRatio(query, name),
    subsequenceRatio(query, nameEn),
    subsequenceRatio(query, nameAr)
  );
  const subFull = subsequenceRatio(query, fullHay);
  const subPart = Math.max(subName, subFull * 0.85);

  return Math.min(1, 0.55 * tokenPart + 0.45 * subPart);
}

/**
 * @param {object[]} products
 * @param {string} query
 * @param {{ minScore?: number, maxResults?: number }} opts
 */
export function rankProductsByQuery(products, query, opts = {}) {
  const q = String(query || '').trim();
  if (!q.length) return products.map((p) => ({ product: p, score: 1 }));

  const minScore =
    q.length <= 2 ? 0.52 : q.length === 3 ? 0.42 : 0.35;
  const maxResults = opts.maxResults ?? 80;

  const scored = products
    .map((product) => ({
      product,
      score: scoreProductMatch(product, q),
    }))
    .filter((x) => x.score >= minScore)
    .sort((a, b) => b.score - a.score)
    .slice(0, maxResults);

  return scored;
}
