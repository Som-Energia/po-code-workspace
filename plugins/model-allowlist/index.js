import { Plugin } from "@opencode/plugin";
import { modelAllowlist } from "./filter.js";

export default Plugin.define({
  id: "po-workspace.model-allowlist",
  async setup(ctx) {
    await ctx.model.transform(modelAllowlist(ctx.options.allowedModels));
  },
});
