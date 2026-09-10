# Engine and operator approval contract

Setup prepares questions and handoffs; it cannot grant engine authority.

Before ASI-Evolve execution, name the objective, exact candidate scope, evaluator
and supporting input files, score definition, timeout, round budget, stop conditions
and whether the code is trusted. Local execution requires explicit trusted-local
consent. A process supervisor or virtual environment is not an operating-system
sandbox. Untrusted candidates require a separately configured disposable sandbox.

Review the current plan digest. Approval must name that exact digest; changing the
evaluator, declared inputs, runtime or budget requires another review. Never edit
an approval receipt, flip a confirmation Boolean, disable a guard, or retry through
a different tool to manufacture consent. Unsupported host ask responses stay blocked
for the operator. An existing installation does not approve a replacement.

Keep controller and worker identity separate. A worker must not overwrite the
controller's handoff, persona, outcome history or another worker's state. Ambiguous
legacy state needs operator-reviewed migration; do not adopt or delete it silently.
Carry unresolved scope questions forward instead of treating absence as approval.

Record success only after a successful evaluator outcome whose code, results and
plan still match. Failed, interrupted, stale or non-finite results are not successful
experiments. Retain historical evidence; correct it through new superseding entries.

Optional models and memory services require separate approval of their exact
dependency graph and data access. Do not download a model or install an unpinned
service just to satisfy a workflow. MemPalace automatic installation is held pending
review of the ChromaDB advisories recorded in Eidolon's dependency report. Existing
user installations must not be removed or reconfigured without separate consent.

Before closeout, distinguish local tests, native-client observations and unverified
integrations. A package vulnerability scan is not a malware review or proof that
unknown vulnerabilities are absent; a secret scan reports its reachable-history
scope and unresolved matches rather than guaranteeing complete absence.
