export function modelAllowlist(allowedModels) {
  if (
    !Array.isArray(allowedModels) ||
    allowedModels.length === 0 ||
    allowedModels.some((id) => typeof id !== "string" || !/^[^/#\s]+\/[^#\s]+$/.test(id))
  ) {
    throw new Error("model-allowlist: allowedModels must be a non-empty array of provider/model IDs");
  }

  const allowed = new Set(allowedModels);
  return (editor) => {
    for (const model of editor.list()) {
      if (!allowed.has(`${model.providerID}/${model.id}`)) {
        editor.remove(model.providerID, model.id);
      }
    }
  };
}
