// hooks/doc-integrity-guard.mjs
//
// PreToolUse(Write|Edit) — HARD BLOCK (exit 2) on shrinking an append-only
// log entry under docs/fixes/ or docs/insights/.
// why: the dual log is the repo's memory (see references/remember.md);
// retiring an entry means deleting the whole file deliberately via git,
// never quietly editing history down.

import { readFileSync, existsSync } from "node:fs";

const APPEND_ONLY = /docs[\\/](fixes|insights)[\\/].+\.md$/i;
const lines = (s) => String(s).split("\n").length;

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
  if (!APPEND_ONLY.test(path)) process.exit(0);

  let shrink = false;
  if (ti.content != null && existsSync(path)) {
    // Write over an existing log entry: block if the new body is shorter.
    try {
      shrink = lines(ti.content) < lines(readFileSync(path, "utf8"));
    } catch {
      /* unreadable -> let it pass; git history still protects */
    }
  } else if (ti.old_string != null && ti.new_string != null) {
    // Edit: block net line removal. Same-length rewording stays allowed.
    shrink = lines(ti.new_string) < lines(ti.old_string);
  }

  if (shrink) {
    process.stderr.write(
      "DOC-INTEGRITY GUARD [BLOCKED]: docs/fixes and docs/insights are " +
        "append-only. Fix a wrong entry by appending a correction, or retire " +
        "the whole file via git in its own commit. Never shrink history in place.\n"
    );
    process.exit(2);
  }
  process.exit(0);
});
