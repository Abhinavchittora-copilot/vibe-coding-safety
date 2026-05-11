# The Guardrails Prompt Template

> The single highest-leverage thing you can do to improve the security of AI-generated code is to write a better first prompt.

This template is designed to be **pasted into the first prompt** of your build session — *before* you describe the feature you want.

It forces the AI to consider security constraints as a first-class concern of the build, not an afterthought.

---

## Copy-paste template

```
Before building this feature, I need you to follow these security rules
on every line of code you generate:

1. AUTHENTICATION: Every backend endpoint or server function must verify
   the user is logged in before doing anything. If there is no valid session
   token, return 401 Unauthorized — do not proceed.

2. AUTHORIZATION: When fetching, updating, or deleting any user-owned data,
   verify the data belongs to the currently logged-in user. Never trust
   a user ID passed in the URL or request body — always derive the user
   identity from the server-side session.

3. INPUT VALIDATION: Reject negative numbers, zero, and absurdly large
   values for any numeric field where they don't make sense (prices,
   quantities, ages, etc.). Reject empty strings where data is required.
   Cap string length at a sensible maximum. Validate file types and sizes
   on uploads.

4. SECRETS: No API keys, database passwords, access tokens, or other
   secrets may appear in client-side code or network responses. All
   secrets must be referenced through server-side environment variables.

5. ERROR HANDLING: Errors must not expose internal details (stack traces,
   database table names, file paths, environment variables). Return
   generic error messages to the client. Log details server-side.

6. RATE LIMITING: Authentication endpoints (login, signup, password reset)
   must be rate-limited. Otherwise they will be brute-forced.

7. ADMIN ROUTES: Any route or function that performs administrative
   actions must verify the user has admin role *on the server side* —
   not just by hiding the UI.

After you generate code, explicitly tell me which of these seven rules
are enforced where. If any rule is not applicable, say so and explain why.

Here is the feature I want to build:
[paste your feature description here]
```

---

## When to use this

- **First prompt of any new build.** Always.
- **First prompt of any major feature addition** to an existing AI-generated codebase (e.g., "add user accounts to my app," "add an admin dashboard," "add a payments page").
- **Whenever the AI generates code that touches user data, authentication, or external APIs.**

---

## Why this works

AI coding tools are pattern matchers. They optimize for what was asked for. If you ask for "a login page," you get a login page that handles the happy path. If you ask for "a login page that follows these seven security rules," you get a login page with the rules baked in.

The prompt is not magic. The AI may still miss things — that's why the [30-Minute Anti-Vibe Checklist](../checklist.md) exists as the second line of defense. But this prompt closes the largest single source of vulnerability: the gap between *"build this feature"* and *"build this feature safely."*

---

## Tuning notes

- **For payment, auth, or healthcare apps:** add explicit rules about PCI-DSS, GDPR, or HIPAA compliance based on your region and use case. The seven rules above are the floor — these domains require more.
- **For multi-tenant SaaS apps:** add an explicit rule about tenant isolation ("Data from tenant A must never be returned to tenant B, even through indirect queries").
- **For internal tools:** you can relax rate limiting, but never relax authorization. *Especially* not for internal tools — they're often shipped with the assumption that "only employees use this" and then end up exposed.

---

## What to do after the AI responds

1. Read the AI's response carefully — particularly the part where it says which rules are enforced where.
2. If any rule is marked "not enforced" or "not applicable" without a clear reason, **push back**. Ask the AI to enforce it or justify why.
3. Spot-check the generated code: pick one or two endpoints and verify the auth, authorization, and input validation are actually in the code.
4. Run [the 30-Minute Anti-Vibe Checklist](../checklist.md) before deploying.

The prompt gets you 80% of the way there. The checklist catches what slipped through.
