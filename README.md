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

### Human-facing (run these yourself)

| File | What it is |
|---|---|
| **[checklist.md](./checklist.md)** | The full **30-Minute Anti-Vibe Checklist** — 4 named checks, expanded with what to look for, why it matters, and how to fix it. |
| **[scoring.md](./scoring.md)** | The **Self-Audit Scoring Rubric** — score your app 0–10. Tells you whether it's safe to ship, needs work, or should not deploy. |
| **[examples/happy-path-trap.md](./examples/happy-path-trap.md)** | The *"every user can see every other user's data"* failure mode (the Lovable pattern). |
| **[examples/exposed-secrets.md](./examples/exposed-secrets.md)** | The *"database password is in the page source"* failure mode (the leaked-tokens pattern). |
| **[examples/platform-id-reuse.md](./examples/platform-id-reuse.md)** | The *"the apartment number is also the key"* failure mode (the Base44 pattern). |

### Agent-facing (install these in your AI tool)

| File | Where it goes | What it does |
|---|---|---|
| **[AGENTS.md](./AGENTS.md)** | Root of any project | Universal agent-instruction file. Cursor, Continue, OpenAI Codex CLI, Aider, and others read it automatically. |
| **[.cursor/rules/security.mdc](./.cursor/rules/security.mdc)** | `.cursor/rules/` in your project | Cursor-specific project rules. Always applied to every AI response. |
| **[templates/CLAUDE.md](./templates/CLAUDE.md)** | Root of any project | Claude Code reads this automatically at every session start. |
| **[prompts/guardrails-prompt-template.md](./prompts/guardrails-prompt-template.md)** | Paste as first user message | Per-build constraints — forces the agent to apply 7 named security rules to the specific feature. |
| **[prompts/secure-by-default-prompt.md](./prompts/secure-by-default-prompt.md)** | System prompt in any tool | Tool-agnostic version of the agent rules, for tools that don't have a standard rules file. |
| **[prompts/self-audit-prompt.md](./prompts/self-audit-prompt.md)** | Paste after code generation | Tells the agent to grade its own work against the checklist before you accept it. |

### Automation

| File | What it does |
|---|---|
| **[scripts/quick-audit.sh](./scripts/quick-audit.sh)** | Bash script that runs the *mechanical* parts of the checklist: scans for committed secrets, verifies declared dependencies exist on the npm registry, flags known insecure patterns. Run before every deploy. |

---

## How to install this in your AI coding agent

This is the highest-leverage thing you can do with this kit. **Five minutes of setup gives every prompt in your agent's session a security-aware bias by default.**

### Cursor

1. Copy [.cursor/rules/security.mdc](./.cursor/rules/security.mdc) into the same path in your project.
2. Cursor auto-applies it to every response.
3. Done. No restart needed.

### Claude Code

1. Copy [templates/CLAUDE.md](./templates/CLAUDE.md) to the root of your project (rename to `CLAUDE.md`).
2. Claude reads it at the start of every session.
3. Done.

### Any agent that respects [AGENTS.md](https://agents.md)

Continue, OpenAI Codex CLI, Aider, and a growing list of agents read a root-level `AGENTS.md` file.

1. Copy [AGENTS.md](./AGENTS.md) to the root of your project.
2. Restart your agent if it caches.

### Any other AI tool (ChatGPT, Claude.ai, Gemini, raw API)

These tools don't have project rules files. Instead:

1. Open [prompts/secure-by-default-prompt.md](./prompts/secure-by-default-prompt.md).
2. Paste it as the **first message** of every coding session.
3. Wait for the agent to acknowledge before requesting features.
4. Re-paste if the conversation gets long — these tools forget after enough turns.

### After every code generation — run the self-audit

Regardless of which tool you use, after the agent generates code, paste [prompts/self-audit-prompt.md](./prompts/self-audit-prompt.md). It forces the agent to grade its own work against the checklist with line citations. This catches ~80% of mistakes before they reach a human reviewer.

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

This kit is different in four ways:

1. **Time-boxed.** 30 minutes total. Four checks. If it takes longer than that, no one will run it.
2. **Built for non-engineers.** Plain language, real-world analogies, no jargon.
3. **Scored, not just listed.** You get a number out of 10. You know exactly whether to ship.
4. **Agent-installable.** Drop-in files for Cursor, Claude Code, and any agent that supports `AGENTS.md`. Every prompt in your session gets security-aware defaults.

---

## What this kit can and cannot do

Honest framing matters here. Some parts of security automate well. Others don't. This section tells you which is which.

### What the agent files actually deliver

Dropping [AGENTS.md](./AGENTS.md) / [CLAUDE.md](./templates/CLAUDE.md) / [.cursor/rules/security.mdc](./.cursor/rules/security.mdc) into your project will:

- Make your agent default to adding authentication on new endpoints
- Make your agent derive `userId` from sessions instead of URLs (the #1 BOLA fix)
- Make your agent refuse to put secrets in client-side code
- Make your agent add input validation by default
- Make your agent flag suspicious dependencies

It is *biased prompting at scale*. It is not magic. The agent can still drift in long sessions, especially with smaller models. Re-paste the rules if you notice the agent regressing.

### What still requires a human

Three of the four manual checks in [checklist.md](./checklist.md) cannot be reliably automated:

| Check | Why a human still has to do it |
|---|---|
| **The Right-Click Test** | Requires opening the *deployed* app in a browser and inspecting the live page source. Agents inside IDEs don't have that surface. The `scripts/quick-audit.sh` script catches secrets that are in the repo, but not secrets that are only present in the deployed JS bundle. |
| **The Negative Test** | Requires *intent* — visiting URLs, changing IDs, submitting bad input against the live app. Agents can run `curl`, but interpreting the responses for BOLA is judgment work. |
| **Authorization audit** | No static tool reliably catches BOLA. The agent's self-audit prompt helps, but a human has to verify the authorization logic still makes sense for the business. |

The scoring rubric exists precisely because *some failures are too critical to leave to automation*. If the manual checklist finds something the agent missed, that gap is the whole point.

### When this kit is not enough

For high-stakes apps — anything handling PCI data, HIPAA-protected data, GDPR-sensitive categories, financial transactions, healthcare records — this kit is the **floor**, not the ceiling. You also need:

- A penetration test before launch
- DAST scanning in CI
- A human security review of authorization logic
- A documented incident response plan
- Compliance-specific controls beyond what this kit covers

This kit closes the most common gaps in AI-generated apps. It does not make a non-engineer's app production-ready for regulated data. Be honest about which side of that line your app sits on.

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
