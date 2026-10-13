// hooks/hedge-guard.mjs
//
// PreToolUse(Write|Edit) — ADVISORY ONLY on the published prose files.
// Injects additionalContext when a hedged claim is about to ship; never
// blocks, because this repo's own doctrine (references/collaborate.md) says
// a watch word earns a second look, not a ban.
//
// META note: verify.md and collaborate.md legitimately ENUMERATE these
// phrases as catalog entries. The advisory wording accounts for that; a
// human judges enumeration vs claim. Guard infrastructure is excluded.

const SCOPE = /(SKILL\.md|README\.md|references[\\/].+\.md|docs[\\/].+\.md)$/i;
const META = /hooks[\\/]|skill-audit|working-with-claude/i;
const HEDGE =
  /\b(probably|should work|should be fine|i think|i believe|most likely|in theory|presumably|seems to work|appears to work)\b/i;

const NOTE =
  "HEDGE GUARD: a hedged phrase is going into published prose. This repo's " +
  "rule (references/verify.md): a hedge is the tell that a claim has not " +
  "been checked — either check it and drop the hedge, or label the claim " +
  "unsure and hand it to the person. If the line ENUMERATES watch words as " +
  "catalog entries rather than making a claim, carry on.";

let raw = "";
process.stdin.on("data", (c) => (raw += c));
process.stdin.on("end", () => {
  let j = {};
  try {
    j = JSON.parse((raw.charCodeAt(0) === 0xfeff ? raw.slice(1) : raw).trim());
  } catch {
    process.exit(0);
  }

  const ti = j.tool_input || {};
  const path = String(ti.file_path || "");
  if (!SCOPE.test(path) || META.test(path)) process.exit(0);

  const body = String(ti.content != null ? ti.content : (ti.new_string ?? ""));
  if (!HEDGE.test(body)) process.exit(0);

  process.stdout.write(
    JSON.stringify({
      systemMessage: NOTE,
      hookSpecificOutput: { hookEventName: "PreToolUse", additionalContext: NOTE },
    })
  );
  process.exit(0);
});
