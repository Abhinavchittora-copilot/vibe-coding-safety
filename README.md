# vibe-coding-safety

> **A 30-minute audit kit for shipping AI-generated apps without leaking customer data.**

When an AI writes your code, *you* are still the one shipping it. This kit gives you four named checks, a scoring rubric, and copy-paste prompts to catch the security gaps AI coding tools systematically miss — in 30 minutes, before you deploy.

---

## Why this exists

A Wired investigation found **5,000 AI-generated apps** sitting on the open internet. **2,000 were leaking real data**: customer chat logs, financial records, executive decks, and 1.5 million database access tokens.

A separate study by Tenzai tested five top AI coding tools (Cursor, Claude Code, OpenAI Codex, Replit, Devin) on identical app-building prompts. The result: **69 vulnerabilities across 15 builds**. Four of five let users place orders with negative prices. Every tool failed to add standard security protections — not incorrectly, but, as Tenzai put it, *"in most cases, they didn't even try."*

The AI is not broken. It is a pattern matcher trained on tutorials that prioritize *"working"* over *"safe."* It builds exactly what you prompt it to build, and nothing more.

This kit is the gap-filler.

---

## Who this is for

- **Product Managers & non-technical builders** using Lovable, Base44, Replit, Bolt, v0, or Cursor to ship apps fast.
- **Engineers** reviewing AI-generated code they did not personally write.
- **Tech leaders** who need a 30-minute review gate between *"the AI built it"* and *"we shipped it."*

If you're using AI to ship things that touch user data, this kit is for you.

---

## What's inside

| File | What it is |
|---|---|
| **[checklist.md](./checklist.md)** | The full **30-Minute Anti-Vibe Checklist** — 4 named checks, expanded with what to look for, why it matters, and how to fix it. |
| **[scoring.md](./scoring.md)** | The **Self-Audit Scoring Rubric** — score your app 0–10. Tells you whether it's safe to ship, needs work, or should not deploy. |
| **[prompts/guardrails-prompt-template.md](./prompts/guardrails-prompt-template.md)** | A copy-paste prompt prefix that forces the AI to ask security questions *before* writing code. |
| **[prompts/secure-by-default-prompt.md](./prompts/secure-by-default-prompt.md)** | A system-level prompt that biases your AI tool toward secure defaults across every prompt in a session. |
| **[examples/happy-path-trap.md](./examples/happy-path-trap.md)** | A real-world walkthrough of the *"every user can see every other user's data"* failure mode (the Lovable pattern). |
| **[examples/exposed-secrets.md](./examples/exposed-secrets.md)** | A real-world walkthrough of the *"database password is in the page source"* failure mode (the Moltbook pattern). |
| **[examples/platform-id-reuse.md](./examples/platform-id-reuse.md)** | A real-world walkthrough of the *"the apartment number is also the key"* failure mode (the Base44 pattern). |

---

## How to use this kit

### If you're building a new app

1. **Before prompting,** read [prompts/guardrails-prompt-template.md](./prompts/guardrails-prompt-template.md) and paste it into your first prompt.
2. **Before deploying,** run through [checklist.md](./checklist.md). 30 minutes, four checks.
3. **Score yourself** with [scoring.md](./scoring.md). If you score 3+, do not ship until you fix.

### If you've already shipped

1. **Run the audit** in [checklist.md](./checklist.md) against your live app right now.
2. **Score it.** If you score 6+, take it offline until you remediate.
3. **Read the examples** to understand what these failures actually look like in real apps.

### If you're a PM or tech leader

Make this checklist a required gate for any production deployment of AI-generated code in your team. The whole point is that it takes 30 minutes — there is no excuse to skip it.

---

## What makes this different

There are other vibe-coding security checklists. They're good, and you should read them too:

- [astoj/vibe-security](https://github.com/astoj/vibe-security) — comprehensive 17-area engineer checklist
- [Replit's vibe coding security checklist](https://docs.replit.com/tutorials/vibe-code-security-checklist) — platform-specific guidance
- [Invicti's vibe coding security checklist](https://www.invicti.com/blog/web-security/vibe-coding-security-checklist-how-to-secure-ai-generated-apps) — runtime/DAST-focused

This kit is different in three ways:

1. **Time-boxed.** 30 minutes total. Four checks. If it takes longer than that, no one will run it.
2. **Built for non-engineers.** Plain language, real-world analogies, no jargon.
3. **Scored, not just listed.** You get a number out of 10. You know exactly whether to ship.

---

## Maintenance status

**Active maintenance:** First 30 days from publish (until June 11, 2026). PRs and issues will be reviewed within a week.

**After that:** This kit will move to reference mode. The checklist itself is intentionally stable — security fundamentals don't change quarterly. Major issues and security-relevant updates will still be addressed.

If you want to keep it alive longer, fork it. MIT license. Use it however helps.

---

## Contributing

Found a check that's missing? A case study that should be in here? An example that's wrong? PRs welcome — see [CONTRIBUTING.md](./CONTRIBUTING.md). Keep the spirit: short, named, time-boxed, audience-aware.

---

## About

Built by [Abhinav Chittora](https://www.linkedin.com/in/abhinavchittora), Senior Product Manager at Microsoft. I write about the operational reality of AI product management at [abhinavchittora.substack.com](https://abhinavchittora.substack.com).

If you want to build a review process like this into your own team, I take a small number of mentoring sessions each month at [topmate.io/chittora](https://topmate.io/chittora).

---

## License

[MIT](./LICENSE) — use it, fork it, ship it, take credit for shipping safer apps because of it.
