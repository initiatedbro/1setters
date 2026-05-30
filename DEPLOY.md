# Transcend Closers — Go Live (Supabase + Vercel)

This folder is your production app. Five things to do, ~15 minutes total.
Until you add your Supabase keys (Step 2), `index.html` runs in local demo mode.

---

## Step 1 — Create the database (Supabase)

1. Go to **supabase.com → New project**. Pick a name, set a database password, choose a region close to your closers. Wait ~2 minutes for it to provision.
2. Left sidebar → **SQL Editor → New query**.
3. Open **`schema.sql`** (in this folder), copy everything, paste it into the editor, and click **Run**. You should see "Success".
4. Left sidebar → **Authentication → Sign In / Providers → Email** → make sure **Email** is enabled.
   - Recommended: turn **OFF "Confirm email"** so closers can sign in instantly without an email step. (Leave it on if you want verified emails — they'll get a confirmation link on signup.)

## Step 2 — Get your keys and paste them in

1. Supabase → **Project Settings → API**.
2. Copy these two values:
   - **Project URL** (e.g. `https://abcd1234.supabase.co`)
   - **Project API keys → `anon` `public`** (a long token — this one is safe to ship in the browser)
3. Open **`index.html`** in a text editor, find these two lines near the top of the `<script>`:

   ```js
   const SUPABASE_URL = '';
   const SUPABASE_ANON_KEY = '';
   ```

   Paste your values between the quotes, e.g.

   ```js
   const SUPABASE_URL = 'https://abcd1234.supabase.co';
   const SUPABASE_ANON_KEY = 'eyJhbGciOi...your anon key...';
   ```

   Save the file. (The `anon` key is *meant* to be public — Row Level Security in the schema is what protects the data.)

## Step 3 — Deploy to Vercel

**Easiest (no Git) — Vercel CLI:**
```bash
npm i -g vercel          # one time
cd transcend-deploy      # this folder
vercel                   # follow prompts; accept defaults
vercel --prod            # publish to your live URL
```

**Or via GitHub:** push this folder to a new GitHub repo, then **vercel.com → Add New → Project → Import** that repo. Framework preset: **Other** (it's a static site, no build step). Deploy.

## Step 4 — Point Supabase at your live URL

1. Copy your new Vercel URL (e.g. `https://transcend-closers.vercel.app`).
2. Supabase → **Authentication → URL Configuration**:
   - **Site URL** → paste the Vercel URL.
   - **Redirect URLs** → add the Vercel URL too (needed for password-reset links).

## Step 5 — Test it

1. Open your Vercel URL → **Sign up free** → create an account → log a day in **Log Today**.
2. Open the URL in a second browser (or incognito) → sign up as a different closer → log some numbers.
3. Check the **Leaderboard** — both closers should appear, ranked, with clickable preview cards. That confirms multi-user is live.

---

## Notes

- **Each closer signs up themselves** with email + password. They appear on the leaderboard automatically (visibility is on by default; they can turn it off under Leaderboard → My Visibility).
- **Profile photos** are stored in the database as small (256px) images — fine for teams/communities of dozens.
- **Updating the app later:** edit `index.html`, then re-run `vercel --prod` (or push to GitHub). Your data in Supabase is untouched by redeploys.
- **The Scott GPT** "Analyse with Scott" button works as-is — it opens your ChatGPT custom GPT in a new tab.
- If something errors after first deploy, open the browser console (F12) — messages are tagged `[Transcend]` — and send them to me; that's the normal last-mile of a go-live.
