// hooks/protected-paths-guard.mjs
//
// PreToolUse(Bash) — HARD BLOCK (exit 2) on destructive commands aimed at
// the files this repo cannot lose: LICENSE, SKILL.md, references/, .git.
// why: the repo IS these files; a deliberate restructure can lift the gate
// by editing this guard in the open, in its own commit.

const PROTECTED = /\b(LICENSE|SKILL\.md)\b|references[\\/]|\.git\b/;
// command-position rm/del family, or git rm anywhere
const DESTRUCTIVE =
  /(^|[;&|()]\s*)(rm|del|rmdir|rd|Remove-Item)\b|\bgit\s+rm\b/i;

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

  if (DESTRUCTIVE.test(cmd) && PROTECTED.test(cmd)) {
    process.stderr.write(
      "PROTECTED-PATHS GUARD [BLOCKED]: this command would destroy a protected " +
        "file (LICENSE, SKILL.md, references/, .git). If the removal is " +
        "deliberate, change this guard first, in the open, in its own commit.\n"
    );
    process.exit(2);
  }
  process.exit(0);
});
