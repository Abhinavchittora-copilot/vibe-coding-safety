# The Self-Audit Scoring Rubric

After running through the [30-Minute Anti-Vibe Checklist](./checklist.md), score yourself.

Each failure adds points. **The higher your score, the more dangerous it is to ship.**

---

## How to score

For each check, mark how many items you *failed* (or were not sure about — uncertainty counts as failure).

### Check 1: Guardrails Prompt — max 2 points

| Failure | Points |
|---|---|
| You did not answer the four pre-prompt questions before starting | +1 |
| The AI's generated code does not visibly enforce the security constraints you specified | +1 |

### Check 2: Right-Click Test — max 2 points

| Failure | Points |
|---|---|
| Any secret value (key, token, password) appears in client-side code or network responses | +2 (any failure here is automatically critical) |

### Check 3: Negative Test — max 4 points

| Failure | Points |
|---|---|
| The app shows data to unauthenticated users that it should not | +1 |
| Changing a user ID in the URL exposes another user's data (BOLA) | +2 (this is the #1 vulnerability — weight it heavily) |
| Invalid input (negative numbers, oversized data) crashes the app or is accepted | +0.5 |
| API endpoints are callable without proper authentication | +0.5 |

### Check 4: Hallucination Audit — max 2 points

| Failure | Points |
|---|---|
| Any dependency does not exist on the official registry | +2 (this is potential active malware — critical) |
| Any dependency has < 100 weekly downloads and is not from a recognized publisher | +1 |
| Any dependency was created within the last 3 months without a specific reason to trust it | +0.5 |

---

## The verdict

Add up your points.

### 🟢 Score 0–2: Ship it

Your app passes the floor. There may still be issues a deeper security audit would find, but you have caught the systemic AI failure modes.

**What to do:**
- Deploy.
- Add the Guardrails Prompt template to your team's standard practice.
- Re-run this checklist after every major AI-generated change.

### 🟡 Score 3–5: Red flag — fix before shipping

You have at least one serious gap. AI-generated apps with these gaps are the ones currently leaking data on the open internet.

**What to do:**
- Do not deploy until the failed items are addressed.
- If you've already deployed, set the app to private / staging mode while you fix.
- Pay particular attention to anything in Check 2 (secrets) and Check 3b (BOLA) — these are the highest-impact failures.

### 🔴 Score 6+: Do not deploy

Your app has multiple critical security gaps. If this is live, take it down. Now.

**What to do:**
1. Take the app offline immediately if it is in production touching real user data.
2. Rotate every secret (database password, API key, OAuth token) that has been exposed.
3. Notify anyone whose data may have been accessible.
4. Rebuild the failed sections with the [Guardrails Prompt](./prompts/guardrails-prompt-template.md) in place from the start.
5. Re-score before re-deploying.

---

## Critical-failure auto-fail rule

Any of the following **automatically means do not deploy**, regardless of your total score:

- Database credentials in client-side code
- Production API keys (Stripe `sk_live_*`, AWS `AKIA*`, etc.) in client-side code
- A working BOLA exploit (one user can see another user's data by changing a URL)
- A dependency that does not exist on the official package registry

These are not "issues." They are "your customers' data is on the open internet right now."

---

## Re-scoring after fixes

After you fix the failed items, run the affected check again — *not the whole checklist*. Re-score only the section you changed.

If you make material changes to the app between scoring and deployment, run the full checklist again. AI-generated apps change in ways that traditional code review assumptions do not anticipate; one fix can quietly undo another.

---

## The honest truth about scoring

A score of 0 does not mean your app is "secure." It means it has passed a deliberately narrow audit aimed at the failure modes AI coding tools systematically produce.

A real production app with sensitive data needs more than this:
- Penetration testing
- Dynamic application security testing (DAST)
- Code review by a security engineer
- A documented incident response plan

This kit is the **floor**, not the ceiling. It is the minimum bar you should clear before deploying anything that touches user data. If you have the budget for more, do more.

But if you have not even cleared the floor, doing more elsewhere is theatre.
