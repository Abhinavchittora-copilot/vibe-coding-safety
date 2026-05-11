# The Self-Audit Prompt

> Tell your AI agent to audit the code it just wrote. This is the highest-leverage 30-second move in the entire kit.

After your agent generates a meaningful chunk of code — a new endpoint, a new page, an auth flow, a database query — paste this prompt **before you accept the changes or hit deploy**.

---

## Copy-paste prompt

```
Before I accept or deploy the code you just wrote, audit it against the
30-Minute Anti-Vibe Checklist. Answer each of these out loud, citing
specific lines or files. If you don't know, say "I don't know" — do not
guess.

1. AUTHENTICATION CHECK
   - For every new backend endpoint or server function you added, where
     do you verify the user is authenticated? Cite the line.
   - If any endpoint does NOT verify authentication, is that an explicit,
     justified design decision? State the justification.

2. AUTHORIZATION CHECK (the BOLA test)
   - For every query that fetches user-owned data, where does the user
     ID come from? Show me the exact line.
   - If the user ID comes from req.params, req.query, req.body, or any
     client-controlled source — without being cross-checked against
     req.session.user.id — that is a BOLA vulnerability. Identify every
     case and fix it now.

3. SECRETS CHECK (the Right-Click test)
   - List every secret value (API keys, DB credentials, tokens) used in
     the code you wrote.
   - For each one, confirm: is it referenced via a server-side env var?
     Or does it appear in any file that gets sent to the browser?
   - If any secret is in client-side code, fix it now.

4. INPUT VALIDATION CHECK
   - For every user-controllable input (URL params, form fields, file
     uploads, headers), what validation did you add?
   - Specifically: do you reject negative numbers where they shouldn't
     be negative? Empty strings where data is required? Files larger
     than a sensible cap? File types outside an allow-list?
   - If any input has no validation, flag it.

5. ERROR DISCLOSURE CHECK
   - When errors happen, what does the client see?
   - Do any error responses include stack traces, database details,
     internal file paths, or IDs of other resources?
   - If yes, sanitize them now.

6. ADMIN ROUTE CHECK
   - If you added any admin-only functionality, where do you verify the
     user has the admin role — server-side, in code?
   - If you only hide the UI, that is not security. Fix it now.

7. DEPENDENCY CHECK
   - List every new package you added to package.json / requirements.txt
     / equivalent.
   - For each, confirm: have you verified it exists on the official
     registry? Does it have meaningful weekly download counts? Is it
     from a recognized publisher?
   - If any dependency was invented (hallucinated) or has < 100 weekly
     downloads, flag it.

After the audit, give me a SCORE out of 10 using the rubric in scoring.md:

  - 0-2 points: Ship it
  - 3-5 points: Red flag, fix before shipping
  - 6+ points: Do not deploy

Show your scoring math. Then tell me what to fix in priority order.
```

---

## When to use this

- **After any AI-generated build session** that produced more than a trivial change.
- **Before any deployment** to a live environment.
- **When taking over an AI-generated codebase** you didn't build yourself — paste the prompt against the existing code to find inherited issues.

---

## What this catches that nothing else does

The agent has full context of what it just wrote. A separate static analysis tool, a security scanner, or even a human reviewer has to *reconstruct* that context. Asking the agent to audit its own output is the highest-information-density review you can do.

It is not a replacement for:
- The [30-Minute Manual Checklist](../checklist.md) — some checks (Right-Click Test, Negative Test) require running the live app, which the agent can't always do.
- Dynamic application security testing (DAST) — needed for production-grade apps.
- A human security review — required for high-stakes data.

But it is the cheapest, fastest, most-leverage step you can take before any of the above. Run it every time.

---

## A note on honesty

If your agent regularly says "everything checks out" and then the manual checklist catches issues — that means the agent is **not being honest in its self-audit**. Some models are better at this than others. If you notice this pattern:

1. Switch to a more capable model for the self-audit step (Claude Sonnet > GPT-4o > smaller models).
2. Demand specific line citations in the audit. Vague answers ("auth is handled") are worthless. Specific answers ("auth is verified on line 47 of `routes/api.js` via `requireAuth` middleware") are auditable.
3. Periodically cross-check the agent's self-audit against the manual checklist. If they disagree, trust the manual checklist.

The agent's self-audit is a *first pass*, not a substitute.

---

*Part of `vibe-coding-safety`. License: MIT.*
