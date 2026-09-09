# Committed distribution acceptance

The operator requested inspection, full GitHub testing and conditional merge of the
remaining Setup and Hearth verification branches on 2026-09-09. Keep all three
repositories separate and preserve the existing artwork and upstream persona files.

The earlier Hearth test branch assembled some fixes only in a disposable runner.
A passing assembled fixture did not mean the branch was a working distribution.
This candidate commits those interface changes and the generated skill mirrors.
The integration workflow now checks the committed files without patching them first.

Reviewed source pins: Eidolon 54ded26e23b731c02eb5156d1304aa343c3ce0b1 and
Setup 3e96e7119fd9778165063cdb0569c9b7a5891776. The Setup verification change
is CI-only; it does not change the bundled instruction skill. Vendor lock and
source bytes must agree; failed validation must not silently regenerate them.

Additional acceptance cases cover plan replay and concurrent confirmation, changed
confirmation targets, UTF-8 network chunks, invalid encoding, cancellation, CLI
preview, and lock/mirror corruption. Existing policy and installer checks remain.

Merge is conditional on passing the exact final PR-head cross-platform checks.
Automated software tests are not claims about authenticated model conduct, actual
agent permissions, browser exploitability, or exhaustive crash recovery.
