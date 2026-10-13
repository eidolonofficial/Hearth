// hooks/commit-quality-guard.mjs
//
// PreToolUse(Bash) — HARD BLOCK (exit 2) on gate-bypass and history
// rewriting aimed at a public repo: --no-verify / --no-gpg-sign on commit,
// force-push in any form.
// why: every push here is instantly public; a quiet bypass is not a shortcut.

const BYPASS = /\bgit\s+commit\b[^\n]*(--no-verify|--no-gpg-sign)/i;
const FORCE_PUSH = /\bgit\s+push\b[^\n]*(--force(-with-lease)?\b|\s-f\b)/i;

let raw = "";
process.stdin.on("data", (c) => (raw += c));
process.stdin.on("end", () => {
  let j = {};
  try {
    j = JSON.parse((raw.charCodeAt(0) === 0xfeff ? raw.slice(1) : raw).trim());
  } catch {
    process.exit(0);
  }

  const cmd = String((j.tool_input || {}).command || "");
  if (!cmd) process.exit(0);

  if (BYPASS.test(cmd) || FORCE_PUSH.test(cmd)) {
    process.stderr.write(
      "COMMIT-QUALITY GUARD [BLOCKED]: gate bypass or force-push on a public " +
        "repo. If the gate is wrong, change it in the open and say so. If " +
        "history must move, do it through a new commit, not by rewriting.\n"
    );
    process.exit(2);
  }
  process.exit(0);
});
