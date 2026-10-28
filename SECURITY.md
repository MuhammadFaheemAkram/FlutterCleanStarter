# Security Policy

## Supported Versions

Flutter Clean Starter is a starter template. Security fixes are applied to the latest `main` only; an app built from it owns its own copy.

| Version | Supported |
|---------|:---------:|
| `main`  | ✅ |

## Reporting a Vulnerability

Please **do not** open a public issue for security problems.

Instead, email **muhammadfaheem004@gmail.com** with:

- a description of the issue and its impact;
- steps to reproduce (a proof of concept if possible);
- any suggested remediation.

You can expect an acknowledgement within a few business days.

## What the Template Holds

It has **no backend, no account and no API key**. The "API" is a fake inside the app that reads a JSON file bundled with it; the app makes no network request.

- **Tasks** (titles, notes, due dates) live in a SQLite database (drift) in the app's documents directory. It is not encrypted at rest; the operating system's app sandbox protects it like any app's private files. Reset demo data replaces them; everything goes when the app is removed.
- **Preferences** hold only the appearance, dynamic color, and whether the demo was seeded.
- **SQL is never built from text:** every value reaches SQLite as a bound parameter through drift's typed queries.
- **The server's data is checked before it is stored:** a malformed or rule-breaking answer is refused whole, and nothing is written.

## When You Build on It

The template's choices are safe for its sample, not a security design for every app. Before shipping an app built from it, review at least:

- **Secrets:** never put API keys in the app or the repository; use your backend, or the platforms' secure storage (`flutter_secure_storage`) for tokens.
- **The network:** a real `TaskApi` should use HTTPS only, validate responses as the mappers do, and handle authentication outside the Cubits.
- **Data at rest:** if your app stores sensitive data, encrypt the database (SQLCipher) or keep that data off the device.
- **Release builds:** enable obfuscation (`--obfuscate --split-debug-info`) if your code holds anything worth hiding, and sign with your own keys (the template's Android release build uses the debug keys).

Reports about the template's patterns, dependency issues or unsafe defaults are very welcome.
