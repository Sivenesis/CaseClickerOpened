-- Stub for ads module (Solar2D PC Windows)
local M = {}
function M.init(provider, appKey, listener) return true end
function M.setCurrentProvider(provider) return true end
function M.load(adType, params) return true end
function M.isLoaded(adType) return false end
function M.isAdAvailable() return false end
function M.show(adType, params) return false end
function M.hide() return true end
return M
