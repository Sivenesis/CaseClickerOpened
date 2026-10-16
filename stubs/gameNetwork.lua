-- Stub for gameNetwork module (Solar2D PC Windows)
local M = {}
function M.init(provider, callback)
    if callback then
        callback({ data = { alias = "Player", playerID = "local_player" } })
    end
    return true
end
function M.request(command, params)
    if params and params.listener then
        params.listener({ data = { alias = "Player", playerID = "local_player" } })
    end
    return true
end
function M.show(screen, params) return true end
return M
