# Contributing

Thank you for considering a contribution.

This kit is intentionally **small and stable**. The whole point is that it can be read and acted on in 30 minutes. PRs that significantly grow the surface area are unlikely to be accepted.

## What gets merged

- **Corrections** to existing content. If a check is wrong, a code example has a bug, or a remediation step is missing a step — yes, please.
- **New failure-mode examples** that fit the existing structure (one named pattern, real-world reference, code-level example, prevention via Guardrails Prompt, detection via the Checklist, remediation steps). One per PR.
- **Clarifications** for non-technical readers. If you found a paragraph confusing, suggest a clearer version.
- **Translations.** If you want to translate the kit into another language, open an issue first so we can discuss directory structure.

## What does not get merged

- New checklist items beyond the four named checks. The 30-minute budget is the whole product. Adding checks defeats the purpose.
- Tool-specific deep-dives ("how to secure your Lovable app specifically"). These belong in a separate repo.
- Generic security education content already well-covered by OWASP, SANS, or other established sources.
- Vendor-specific recommendations (please don't promote your security product here).
- Stylistic rewrites without substantive content change.

## How to contribute

1. Fork the repo.
2. Open an issue first if you're proposing more than a typo fix — that way we agree on scope before you spend time on it.
3. Branch off `main`. Name the branch descriptively: `fix-typo-checklist`, `add-example-csrf`, etc.
4. Submit a PR with:
   - A clear description of what changed and why.
   - A reference to the issue (if one was opened).
   - If you're adding a real-world reference, include a source link.
5. Be patient. See the maintenance status section in [README.md](./README.md) — responses may take up to a week, and after the initial 30-day active maintenance window, longer.

## Style notes

- Keep it readable by non-technical builders. Plain language over jargon.
- Time-box everything. If a check would take more than 10 minutes, it doesn't belong.
- Name your patterns memorably. "The Apartment Number Trap" beats "Insufficient Identifier Entropy."
- Use real-world analogies before introducing technical terms.
- Show, don't just describe. Code examples beat prose explanations.

## License

By contributing, you agree your contributions are licensed under the MIT License, same as the rest of the kit.
