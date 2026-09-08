# Release acceptance checks

Before a release, run Start Agents on Windows and macOS for each host choice.
Test a fresh install, a refused collision, explicit backed-up replacement, and
missing Node. Confirm a failed bundle never reports success. Check Codex skill
loading, project trust and /hooks, benign edit, blocked record deletion, manual
ask-tier handling, and session restore. Perform an authenticated Claude session
as a regression check too. These live checks are not replaced by unit tests.

The legacy GUI remains Claude-only. Node.js is now a prerequisite. Its copy step
uses the same verified transaction as the cross-host installer and refuses an
existing skill until replacement is explicitly approved in Start Agents.

Check Windows at 100%, 150% and 200% display scaling, the legacy GUI fallback,
and the macOS first-launch permission flow. Test optional services only after
reviewing their current commands. A green Node suite does not certify native UI.
