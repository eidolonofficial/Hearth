# Hearth maintenance

Canonical sources are eidolonofficial/eidolon and eidolonofficial/eidolon-setup.
Update bundles only from explicit reviewed commit pins; never hand-edit mirrored policy.
Run node --test tests/*.test.mjs and the bundled Eidolon test suite.
Keep installers dry-run by default, verify all bytes, preserve backups and require replacement consent.
Native GUI smoke tests and authenticated client tests must not be inferred from unit tests.
Do not merge, release or post announcements without approval.
