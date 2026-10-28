import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, readFileSync, copyFileSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { spawnSync } from "node:child_process";
import test from "node:test";
import { modelAllowlist } from "../plugins/model-allowlist/filter.js";

const root = new URL("../", import.meta.url);
const config = JSON.parse(readFileSync(new URL("opencode.json", root)));
const options = config.plugins.find((entry) => entry.package === "./plugins/model-allowlist").options;

function applyFilter(ids, transform = modelAllowlist(options.allowedModels)) {
  const models = new Map(ids.map((id) => {
    const slash = id.indexOf("/");
    return [id, { providerID: id.slice(0, slash), id: id.slice(slash + 1) }];
  }));
  transform({
    list: () => [...models.values()],
    remove: (provider, id) => models.delete(`${provider}/${id}`),
  });
  return [...models.keys()];
}

test("configuration uses exactly the requested models and default", () => {
  assert.equal(config.model, "openai/gpt-6-luna");
  assert.deepEqual(options.allowedModels, [
    "openai/gpt-6.1-sol", "openai/gpt-6.1-terra", "openai/gpt-6-luna",
  ]);
  assert.ok(options.allowedModels.includes(config.model));
});

test("only exact provider/model matches survive", () => {
  assert.deepEqual(applyFilter([
    ...options.allowedModels,
    "openai/other-model",
    "another-provider/gpt-6-luna",
    "openai/gpt-6-luna-extra",
  ]), options.allowedModels);
});

test("replayed transforms also remove newly discovered models", () => {
  const transform = modelAllowlist(options.allowedModels);
  assert.deepEqual(applyFilter([config.model], transform), [config.model]);
  assert.deepEqual(applyFilter([config.model, "openai/new-model"], transform), [config.model]);
});

test("unavailable allowed models are not fabricated", () => {
  assert.deepEqual(applyFilter(["other/model"]), []);
});

test("invalid or empty allowlists fail instead of allowing everything", () => {
  for (const invalid of [undefined, null, [], "openai/model", [null], ["model"], ["openai/model#high"], ["openai/model with spaces"]]) {
    assert.throws(() => modelAllowlist(invalid), /allowedModels/);
  }
});

test("launcher works from outside the workspace, creates repos and preserves arguments", () => {
  const temp = mkdtempSync(join(tmpdir(), "po workspace "));
  try {
    const workspace = join(temp, "workspace with spaces");
    const bin = join(temp, "bin");
    mkdirSync(join(workspace, "scripts"), { recursive: true });
    mkdirSync(bin);
    copyFileSync(new URL("scripts/opencode.sh", root), join(workspace, "scripts/opencode.sh"));
    writeFileSync(join(bin, "opencode"), '#!/usr/bin/env bash\nprintf "%s\\n" "$PWD" "$@"\n', { mode: 0o755 });
    const result = spawnSync("bash", [join(workspace, "scripts/opencode.sh"), "--prompt", "idea with spaces"], {
      cwd: temp,
      env: { ...process.env, PATH: `${bin}:${process.env.PATH}` },
      encoding: "utf8",
    });
    assert.equal(result.status, 0, result.stderr);
    assert.deepEqual(result.stdout.trim().split("\n"), [join(workspace, "repos"), "--prompt", "idea with spaces"]);
  } finally {
    rmSync(temp, { recursive: true, force: true });
  }
});
