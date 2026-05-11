# Failure Mode: The Happy Path Trap (BOLA)

**Real-world pattern observed in:** Lovable, Replit, Cursor, Bolt — across roughly 10% of audited AI-generated apps.

**The technical name:** Broken Object-Level Authorization (BOLA). It is consistently #1 on the OWASP API Security Top 10.

**The plain-language name:** *"The shared spreadsheet with no access rules."*

---

## What it looks like

You build an app where users can store their own data: a notes app, a CRM, a project tracker, a simple e-commerce dashboard.

The login works. Users sign up, log in, see their dashboard. They can create, edit, and delete *their* records. From the inside, the app feels secure — you can only see what you logged in to see.

Then a researcher (or an attacker) does this:

1. Logs in as User A. Their dashboard URL is `/dashboard?user_id=42`.
2. Changes the URL to `/dashboard?user_id=43`.
3. **The app shows User B's data.**

That's BOLA. The AI built "show me data for whatever user ID is in the URL." It forgot to build "verify the user ID in the URL matches the logged-in user."

---

## A concrete example

### The prompt that creates the problem

```
Build me a personal CRM. Each user can store their contacts.
I need a page that shows their list of contacts and lets them
add new ones.
```

### The code the AI generates (simplified)

```javascript
// GET /api/contacts?user_id=42
app.get('/api/contacts', async (req, res) => {
  const userId = req.query.user_id;        // ❌ trusting URL param
  const contacts = await db.contacts.find({ owner_id: userId });
  res.json(contacts);
});
```

### Why this fails

The AI built a query that takes whatever `user_id` is in the URL and returns matching contacts. There is no check that the URL's `user_id` matches the *logged-in* user's ID.

Any logged-in user can change the `user_id` parameter and see anyone else's contacts.

### The code that should have been generated

```javascript
// GET /api/contacts
app.get('/api/contacts', requireAuth, async (req, res) => {
  const userId = req.session.user.id;       // ✅ derive from session
  const contacts = await db.contacts.find({ owner_id: userId });
  res.json(contacts);
});
```

The user ID comes from the *server-side session*, not the URL. The URL parameter is gone entirely.

This is a two-line fix. The AI did not write it because nobody asked.

---

## Why the AI gets this wrong

Three reasons, in priority order:

### 1. The training data is full of tutorials that show this exact anti-pattern

If you search Stack Overflow or GitHub for "build a REST API with user data," a huge fraction of the results pass `user_id` as a URL parameter. The AI is reproducing the most common pattern in its training data. That pattern is insecure, but it works for the happy path.

### 2. Building it the secure way takes more setup

The secure pattern requires a session middleware (`requireAuth`), which requires session storage, which requires choosing a session store, which is more decisions than "just put the user_id in the URL." When the AI is optimizing for "make it work quickly," it picks the path with fewer dependencies.

### 3. Nobody prompted it to enforce ownership

The prompt asked for "a page that shows their list of contacts." The word "their" implies ownership enforcement. But the AI does not infer the *enforcement mechanism* from natural-language pronouns — it just builds a contacts page.

---

## How the [Guardrails Prompt](../prompts/guardrails-prompt-template.md) prevents this

The Guardrails Prompt includes:

> **AUTHORIZATION: When fetching, updating, or deleting any user-owned data, verify the data belongs to the currently logged-in user. Never trust a user ID passed in the URL or request body — always derive the user identity from the server-side session.**

If this is in your first prompt, the AI generates the secure version. If it is not, you get the insecure version 9 times out of 10.

---

## How [Check 3b of the Anti-Vibe Checklist](../checklist.md#3b-try-to-access-another-users-data-by-changing-the-id-in-the-url) catches this

After deployment, run this:

1. Log in as a test user. Note your user ID (look in the URL, look in the page source, or look in DevTools → Application → Cookies / Local Storage).
2. Find any URL or API endpoint that includes your user ID as a parameter.
3. Change the user ID to a different number (try `1`, `2`, `999`).
4. If the app returns *anyone else's data*, you have BOLA.

It takes 60 seconds. It is the single most important check in this entire kit.

---

## What a real-world consequence looks like

In the Wired investigation that motivated this kit, roughly **10% of audited Lovable projects had no access control rules at all**. Live applications. Holding names, emails, home addresses, payment details.

Anyone who knew the URL pattern could enumerate every customer record. No password. No bypass. Just typing different numbers into the URL bar.

This is not theoretical. This is the most common way AI-generated apps leak data on the open internet right now.

---

## Remediation checklist

If you found this failure in your app:

1. **Immediately:** Take the affected endpoints offline or put them behind authentication-required middleware.
2. **Within an hour:** Patch the queries to derive `user_id` from the server-side session, not the URL or request body.
3. **Within a day:** Audit every other endpoint that accepts a user identifier or resource ID from the client. The AI probably made the same mistake everywhere.
4. **Within a week:** Notify any users whose data may have been accessible during the exposure window. Depending on jurisdiction and data type, you may be legally required to do this.
5. **Before re-deploying:** Add the [Guardrails Prompt](../prompts/guardrails-prompt-template.md) to your build workflow and re-run [the full checklist](../checklist.md).
