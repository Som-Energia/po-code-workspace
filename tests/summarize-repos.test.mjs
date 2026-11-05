import assert from "node:assert/strict";
import { copyFileSync, existsSync, lstatSync, mkdirSync, mkdtempSync, readFileSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { spawnSync } from "node:child_process";
import test from "node:test";

const root = new URL("../", import.meta.url);
const template = readFileSync(new URL("templates/repos-AGENTS.md", root), "utf8");

function fixture(t) {
  const dir = mkdtempSync(join(tmpdir(), "po summaries "));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  mkdirSync(join(dir, "scripts"));
  mkdirSync(join(dir, "templates"));
  mkdirSync(join(dir, "repos"));
  copyFileSync(new URL("scripts/summarize-repos.sh", root), join(dir, "scripts/summarize-repos.sh"));
  writeFileSync(join(dir, "templates/repos-AGENTS.md"), template);
  return {
    dir,
    target: join(dir, "repos/AGENTS.md"),
    previous: join(dir, "summaries/.repos-AGENTS.last"),
    run() {
      const result = spawnSync("bash", [join(dir, "scripts/summarize-repos.sh")], {
        cwd: tmpdir(), encoding: "utf8",
      });
      assert.equal(result.status, 0, result.stderr);
      return result;
    },
  };
}

test("creates instructions and indexes from outside an empty workspace, idempotently", (t) => {
  const f = fixture(t);
  rmSync(join(f.dir, "repos"), { recursive: true });
  f.run();
  assert.equal(readFileSync(f.target, "utf8"), template);
  assert.equal(readFileSync(f.previous, "utf8"), template);
  assert.ok(existsSync(join(f.dir, "summaries/indexes/active-repos.md")));
  const modified = lstatSync(f.target).mtimeMs;
  f.run();
  assert.equal(lstatSync(f.target).mtimeMs, modified);
});

test("updates instructions only when they match the previously deployed template", (t) => {
  const f = fixture(t);
  f.run();
  const updated = `${template}\nUpdated instructions.\n`;
  writeFileSync(join(f.dir, "templates/repos-AGENTS.md"), updated);
  f.run();
  assert.equal(readFileSync(f.target, "utf8"), updated);
  assert.equal(readFileSync(f.previous, "utf8"), updated);
});

test("preserves edits to previously managed instructions and warns", (t) => {
  const f = fixture(t);
  f.run();
  writeFileSync(f.target, "Local instructions\n");
  const result = f.run();
  assert.match(result.stderr, /WARN.*es conserva/);
  assert.equal(readFileSync(f.target, "utf8"), "Local instructions\n");
  assert.equal(readFileSync(f.previous, "utf8"), template);
});

test("preserves an existing unknown file but adopts an identical template", (t) => {
  const f = fixture(t);
  writeFileSync(f.target, "Existing instructions\n");
  assert.match(f.run().stderr, /WARN.*es conserva/);
  assert.equal(readFileSync(f.target, "utf8"), "Existing instructions\n");
  assert.equal(existsSync(f.previous), false);
  writeFileSync(f.target, template);
  f.run();
  assert.equal(readFileSync(f.previous, "utf8"), template);
});

test("does not follow symlinks, even dangling ones, or replace directories", (t) => {
  const f = fixture(t);
  const external = join(f.dir, "external.md");
  writeFileSync(external, "Do not modify\n");
  symlinkSync(external, f.target);
  assert.match(f.run().stderr, /WARN.*no és un fitxer regular/);
  assert.ok(lstatSync(f.target).isSymbolicLink());
  assert.equal(readFileSync(external, "utf8"), "Do not modify\n");
  rmSync(external);
  assert.match(f.run().stderr, /WARN.*no és un fitxer regular/);
  assert.equal(existsSync(external), false);
  rmSync(f.target);
  mkdirSync(f.target);
  assert.match(f.run().stderr, /WARN.*no és un fitxer regular/);
  assert.ok(lstatSync(f.target).isDirectory());
});

test("summarizes a clone without touching its own AGENTS.md", (t) => {
  const f = fixture(t);
  const repo = join(f.dir, "repos/example");
  mkdirSync(repo);
  const init = spawnSync("git", ["init", "-q", repo], { encoding: "utf8" });
  assert.equal(init.status, 0, init.stderr);
  writeFileSync(join(repo, "README.md"), "Example product\n");
  writeFileSync(join(repo, "AGENTS.md"), "Repository-specific instructions\n");
  f.run();
  assert.equal(readFileSync(join(repo, "AGENTS.md"), "utf8"), "Repository-specific instructions\n");
  assert.match(readFileSync(join(f.dir, "summaries/repos/example.md"), "utf8"), /Example product/);
  assert.match(readFileSync(join(f.dir, "summaries/indexes/active-repos.md"), "utf8"), /example/);
});

test("fails before generating outputs if the versioned template is missing", (t) => {
  const f = fixture(t);
  rmSync(join(f.dir, "templates/repos-AGENTS.md"));
  const result = spawnSync("bash", [join(f.dir, "scripts/summarize-repos.sh")], { encoding: "utf8" });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /ERROR: falta la plantilla/);
  assert.equal(existsSync(f.target), false);
  assert.equal(existsSync(join(f.dir, "summaries")), false);
});
