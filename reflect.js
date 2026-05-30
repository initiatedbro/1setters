// Vercel serverless function — proxies Reflection requests to the Anthropic (Claude) API.
// Your API key stays here on the server and is NEVER exposed to the browser.
//
// SETUP (one time):
//   Vercel → your project → Settings → Environment Variables →
//   add  ANTHROPIC_API_KEY = sk-ant-...your key...  (Production)  → Save → redeploy.
//
// Change the model below if you prefer a different Claude model.
const MODEL = 'claude-sonnet-4-6';

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  const key = process.env.ANTHROPIC_API_KEY;
  if (!key) {
    res.status(500).json({ error: 'ANTHROPIC_API_KEY is not set in Vercel environment variables.' });
    return;
  }
  try {
    let body = req.body;
    if (typeof body === 'string') { try { body = JSON.parse(body); } catch (_) { body = {}; } }
    body = body || {};
    const system = body.system || 'You are a helpful, direct reflection coach.';
    const prompt = body.prompt || '';
    if (!prompt) { res.status(400).json({ error: 'Missing prompt' }); return; }

    const r = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-api-key': key,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: 1024,
        system,
        messages: [{ role: 'user', content: prompt }]
      })
    });

    const data = await r.json();
    if (!r.ok) {
      res.status(r.status).json({ error: (data && data.error && data.error.message) || 'Anthropic API error' });
      return;
    }
    const text = (data.content || []).map(b => (b && b.text) || '').join('').trim();
    res.status(200).json({ text });
  } catch (e) {
    res.status(500).json({ error: String((e && e.message) || e) });
  }
};
