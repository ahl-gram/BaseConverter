# Release automation setup

Named `SETUP.md` rather than `README.md` on purpose: `fastlane docs` regenerates
`fastlane/README.md` and would silently overwrite these instructions.

## One-time: create an App Store Connect API key

Nothing here works until this exists. It replaces Apple ID and password auth,
which is what makes unattended releases possible (no 2FA prompt).

1. Sign in to [App Store Connect](https://appstoreconnect.apple.com).
2. Go to **Users and Access** then the **Integrations** tab, and pick
   **App Store Connect API** (Team Keys).
3. Click **+** to generate a key.

   **Name:** `route12b-fastlane`. The name is only a label, but it should say
   what consumes the key so that future-you can revoke the right one without
   guessing. If a hosted CI service is ever added, give it its own separate key
   (`route12b-ci`) so either can be revoked independently.

   **Role: App Manager.** This is the minimum that works, and the choice is
   load-bearing:

   | Role | Upload builds | Submit for review |
   |---|---|---|
   | Developer | yes | **no** |
   | App Manager | yes | yes |
   | Admin | yes | yes |

   A Developer key would let `fastlane beta` succeed and then fail
   `fastlane release`, which is a confusing way to discover the problem. Admin
   works too but grants more than releasing needs, including user management.

   One key covers every app on the team, so a single key serves Base Converter,
   Prime Finder, Sorting Visualizer, and Vibe Exchange. There is no need for one
   key per app.
4. **Download the `.p8` file immediately.** Apple allows exactly one download.
   If you lose it you must revoke the key and start over.
5. Record two identifiers from that page, which are different things and are
   easy to mix up:
   - **Key ID**, a short string shown on the key's row
   - **Issuer ID**, a UUID shown above the key list, shared by all your keys

## Store the key outside the repo

```
mkdir -p ~/.appstoreconnect/private_keys
mv ~/Downloads/AuthKey_XXXXXXXXXX.p8 ~/.appstoreconnect/private_keys/
chmod 600 ~/.appstoreconnect/private_keys/AuthKey_XXXXXXXXXX.p8
```

Never commit the `.p8`. It is a credential that can upload and submit builds on
your behalf. `.gitignore` blocks `*.p8`, but the safest place is outside any
repository, which is what the path above does.

## Set the environment variables

Add to `~/.zshrc`, or keep them in a local `.env` (which is gitignored):

```
export ASC_KEY_ID="XXXXXXXXXX"
export ASC_ISSUER_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ASC_KEY_PATH="~/.appstoreconnect/private_keys/AuthKey_XXXXXXXXXX.p8"
```

The Fastfile checks all three up front and fails with a clear message if any is
missing, rather than failing later inside an upload.

## Lanes

Run these from the repository root.

| Command | What it does |
|---|---|
| `fastlane test` | Runs the full test suite on a simulator. No credentials needed. |
| `fastlane verify_auth` | Checks the API key works. Read-only, uploads nothing. |
| `fastlane beta` | Builds, bumps the build number, uploads to TestFlight. |
| `fastlane release` | Builds, uploads, and submits to App Review. |

Run `fastlane verify_auth` first after any credential change. It is the cheapest
way to tell a broken key apart from a broken build.

`fastlane release` deliberately does **not** auto-release on approval
(`automatic_release: false`). After Apple approves, you still press the button
in App Store Connect. Use `beta` as the everyday lane and treat `release` as a
separate, deliberate act.

## Build numbering

Both upload lanes set the build number to one above the highest Apple has ever
seen, checking **three** sources: TestFlight, the live App Store build, and the
number already in the project.

Checking TestFlight alone is not enough, and this app proves why. TestFlight
builds expire after 90 days but App Store builds do not, so Base Converter
currently reports zero TestFlight builds while being live at build 13. A
TestFlight-only check would propose build 1, and Apple would reject the upload
for not being higher than an existing build.

`fastlane verify_auth` prints all three numbers, so you can see what the next
build will be before running an upload.

## Metadata and screenshots

`release` runs with `skip_metadata` and `skip_screenshots`, so it uploads the
binary and submits without touching the App Store listing text or images you
maintain by hand. If you later want fastlane to own those, run `fastlane deliver
init` to pull the current listing into `fastlane/metadata`, then remove those
two flags.

## Troubleshooting

**"A required agreement is missing or has expired."**

Your key is fine. This error can only come back from an authenticated request,
so receiving it proves the JWT was accepted. Apple is blocking the API at the
account level because an agreement is pending or has expired, which happens
whenever Apple revises the Developer Program License Agreement or the Paid
Applications Agreement.

Fix it in App Store Connect under **Business**, previously called **Agreements,
Tax, and Banking**, by reviewing the list and accepting anything marked pending
or expired. Only the Account Holder can accept. It blocks every API operation
and the App Store Connect UI equally, so it would have stopped a manual release
too.

**"Authentication credentials are missing or invalid."**

This one *is* a credential problem. Check that the Key ID matches the filename,
that the Issuer ID is the UUID from the top of the Integrations page rather than
the key's own ID, and that `ASC_KEY_PATH` points at a readable `.p8`.

## Export compliance

The app declares `ITSAppUsesNonExemptEncryption = NO` in the build settings, and
the release lane passes the matching `export_compliance_uses_encryption: false`.
These two must always agree; if they diverge, submissions get rejected. The
declaration is correct because the app ships no custom cryptography and makes no
network calls at all. If that ever changes, update both places together.
