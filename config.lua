-- Case Clicker (PC-Windows Community Edition)
-- Solar2D configuration file

local fps = 60

-- Optional fps preference from user settings
local path = system.pathForFile("fps.txt", system.DocumentsDirectory)
if path then
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        if content == "30" then
            fps = 30
        elseif content == "60" then
            fps = 60
        end
        file:close()
    end
end

application = {
    content = {
        width = 1280,
        height = 720,
        scale = "letterBox",
        fps = fps,
        yAlign = "top",
        imageSuffix = {
            ["@2x"] = 1.5,
            ["@4x"] = 3.0
        }
    }
}
