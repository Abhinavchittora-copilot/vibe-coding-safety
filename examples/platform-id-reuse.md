# Failure Mode: Platform-Level Identifier Reuse

**Real-world pattern observed in:** Base44 (a vibe-coding platform later acquired by Wix). The vulnerability was discovered by Wiz Research and patched within 24 hours after disclosure, but for the period before disclosure, every app on the platform shared the same broken lock.

**The technical name:** Insufficient identifier randomness combined with weak account verification flow.

**The plain-language name:** *"The apartment number that was also the key."*

---

## What it looks like

A platform hosts many apps built by different customers. Each app has an ID — a number or short string visible in its URL (`https://platform.com/app/12345`).

The platform also handles account creation for users of those apps. When a new user signs up to access an app, the platform sends a verification code.

**The vulnerability:** The verification flow uses the *app ID* (visible in the URL) as part of the verification key. So if you know the app ID, you can:

1. Trigger an account creation flow against the app.
2. Use the app ID itself to bypass the verification step.
3. Get a verified account, with full access, on any app on the platform.

Every app on the platform shared one lock. The "key" was visible in the URL.

---

## A concrete example

### The platform's setup

- Platform: `vibe-platform.com`
- Customer A's app: `vibe-platform.com/app/A1B2C3` — an internal HR tool with employee records
- Customer B's app: `vibe-platform.com/app/X9Y8Z7` — a startup's investor data room

### The signup flow (simplified)

When a new user signs up to access Customer A's app, the platform sends a 6-digit code to their email and asks them to enter it back.

The verification endpoint looks like:
```
POST /api/verify
{
  "app_id": "A1B2C3",
  "user_email": "intruder@example.com",
  "verification_code": "?????"
}
```

### The vulnerability

In Base44's documented case, the platform's verification logic accepted the *app ID itself* (or a trivially derivable transformation of it) as a valid verification code under certain conditions.

So an attacker could:

1. Visit `vibe-platform.com/app/X9Y8Z7` (Customer B's app).
2. Notice the app ID in the URL: `X9Y8Z7`.
3. Trigger signup with their own email.
4. Submit the verification with the app ID as the code.
5. Get verified. Get access. See the investor data room.

No password reset. No email interception. No phishing. Just typing the URL parameter into the verification field.

---

## Why this is a platform-level failure (not the customer's fault)

Here is the crucial point: **none of the customers (Customer A, Customer B, etc.) could have prevented this through better building**.

This is a vulnerability in the *platform's* signup flow, not in the individual apps. Every app on Base44 was vulnerable, because every app trusted the platform to handle authentication correctly.

This is the inherent risk of building on a vibe-coding platform: **you inherit the platform's security posture for all the things the platform handles for you**. If the platform's authentication is broken, your app is broken — regardless of how careful you were.

---

## Why platforms get this wrong

Vibe-coding platforms compete on speed and ease. They take over chunks of the stack that customers used to manage themselves:

- Authentication (signup, login, password reset)
- Database provisioning
- Hosting and deployment
- File storage
- Email sending

This is great for velocity. It is also a single point of failure. When the platform makes a security mistake in shared infrastructure, every app on that infrastructure becomes vulnerable simultaneously.

The Base44 case is not unique. The same dynamic produced:
- The Amazon S3 bucket exposures of 2017–2019 (Amazon's default settings were too permissive, so thousands of customers leaked data by accident)
- The MongoDB exposure wave of 2016–2017 (MongoDB shipped with no authentication by default; thousands of customer databases were exposed)
- Various Firebase Realtime Database exposures (Firebase's default rules were "world readable"; many customer apps leaked data)

Each time, the vendor blamed customers for misconfiguration. Each time, the vendor eventually changed defaults. Vibe-coding platforms are in the early phase of this cycle.

---

## What customers can actually do

Because this is a platform-level failure, the customer's defenses are mostly *meta-defenses* — defenses about *which platforms you choose to use* and *how you architect around them*.

### 1. Avoid putting your most sensitive data on a new vibe-coding platform

If you are building an internal HR tool, an investor data room, a healthcare app, or anything else where a breach would be material to your business, **do not use a brand-new vibe-coding platform for it**. Use mature, security-audited infrastructure (your own AWS / GCP / Azure account, with established frameworks).

The vibe-coding platforms are great for prototypes, internal tools with low-sensitivity data, and customer-facing apps where a breach would be annoying but not catastrophic. They are not yet mature enough for high-stakes data.

### 2. Check the platform's security disclosure history

- Does the platform have a security disclosure page?
- Do they have a bug bounty program?
- Have they had publicly disclosed vulnerabilities, and how did they respond?
- A platform that responded to a vulnerability disclosure in 24 hours (like Wix's response to the Base44 issue) is much safer than one that takes weeks or denies the problem.

### 3. Don't use the platform's primary auth for your highest-trust accounts

If the platform offers SSO via your existing identity provider (Google Workspace, Microsoft Entra, Okta), use that instead of the platform's native auth. Your existing identity provider has been hardened over many years. The platform's auth has not.

### 4. Assume the platform will eventually be breached

Build your app such that if the platform is breached *tomorrow*, you can recover:
- Keep regular backups of your data, exported to storage you control.
- Document which platforms you use and what data each holds, so you can issue breach notifications quickly if needed.
- Don't store data on the platform that you would not be willing to publish on the front page of Wired.

---

## How this kit helps

The [30-Minute Anti-Vibe Checklist](../checklist.md) cannot catch a platform-level vulnerability that lives below your app — that requires the *platform vendor* to fix it.

But the checklist *can* tell you whether the data your app handles is sensitive enough that you should not be on a vibe-coding platform in the first place. The [Scoring Rubric](../scoring.md) has a category for this:

> If your app handles regulated data (PCI, HIPAA, GDPR-sensitive categories) and you are deploying on a vibe-coding platform without specific compliance attestation, that is an automatic "do not deploy."

The Base44 case is the cleanest demonstration of why this rule exists.

---

## Remediation checklist (for customers when a platform-level breach is disclosed)

If your platform vendor publicly discloses a vulnerability like the Base44 case:

1. **Immediately:** Read the disclosure carefully. Determine the exposure window — from when the bug was introduced to when it was patched.
2. **Within hours:** If user accounts on your app may have been compromised during that window, force a session reset on all users. Require fresh authentication.
3. **Within a day:** Review audit logs (if your platform provides them) for the exposure window. Look for unfamiliar accounts created, unusual data access patterns.
4. **Within a week:** Notify any users whose data may have been accessible. The legal threshold for notification varies by jurisdiction, but in doubt, over-communicate.
5. **Within a month:** Re-evaluate whether the platform's response inspires enough confidence to continue. If it does not, plan a migration.
