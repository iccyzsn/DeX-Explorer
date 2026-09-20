--[[
    Dex++ Ultimate Debugging Suite
    Custom lightweight build with built-in Telegram API integration.
]]

local TELEGRAM_BOT_TOKEN = "8305869255:AAEqIdORQUnQgg82LKbVwsj6Rzpfow0tKqo"
local TELEGRAM_CHAT_ID   = "5798404109"

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- Environment
local LocalPlayer = Players.LocalPlayer
local gethui = gethui or function() return game:GetService("CoreGui") end
local env = getgenv and getgenv() or {}

-- Clean up old instances
local oldGui = gethui():FindFirstChild("DexPlusPlus")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "DexPlusPlus"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = gethui()

-- [ 1. STARTUP SPLASH SCREEN ]
local splashBg = Instance.new("Frame")
splashBg.Size = UDim2.new(1, 0, 1, 0)
splashBg.BackgroundColor3 = Color3.fromRGB(35, 142, 90) -- Green background
splashBg.BorderSizePixel = 0
splashBg.ZIndex = 10
splashBg.Parent = gui

local splashWindow = Instance.new("Frame")
splashWindow.Size = UDim2.new(0, 400, 0, 200)
splashWindow.Position = UDim2.new(0.5, -200, 0.5, -100)
splashWindow.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
splashWindow.BorderSizePixel = 0
splashWindow.ZIndex = 11
splashWindow.Parent = splashBg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Dex++"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 36
title.Parent = splashWindow

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 20)
subtitle.Position = UDim2.new(0, 0, 0, 80)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Ultimate Debugging Suite"
subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
subtitle.Font = Enum.Font.SourceSans
subtitle.TextSize = 16
subtitle.Parent = splashWindow

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 20)
statusText.Position = UDim2.new(0, 0, 0, 130)
statusText.BackgroundTransparency = 1
statusText.Text = "Initializing Library..."
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.Font = Enum.Font.SourceSans
statusText.TextSize = 14
statusText.Parent = splashWindow

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -20, 0, 20)
footer.Position = UDim2.new(0, 10, 1, -25)
footer.BackgroundTransparency = 1
footer.Text = "v2.2 - Developed by Chillz."
footer.TextColor3 = Color3.fromRGB(150, 150, 150)
footer.Font = Enum.Font.SourceSans
footer.TextSize = 12
footer.TextXAlignment = Enum.TextXAlignment.Right
footer.Parent = splashWindow


-- [ 2. MAIN EXPLORER UI ]
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = gui

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 25)
topBar.BackgroundColor3 = Color3.fromRGB(51, 51, 51)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -30, 1, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = " Explorer"
titleLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
titleLbl.Font = Enum.Font.SourceSans
titleLbl.TextSize = 14
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = topBar

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Left Panel (Tree)
local treePanel = Instance.new("Frame")
treePanel.Size = UDim2.new(0.6, -2, 1, -27)
treePanel.Position = UDim2.new(0, 0, 0, 27)
treePanel.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
treePanel.BorderSizePixel = 0
treePanel.Parent = mainFrame

local treeList = Instance.new("ScrollingFrame")
treeList.Size = UDim2.new(1, 0, 1, 0)
treeList.BackgroundTransparency = 1
treeList.BorderSizePixel = 0
treeList.ScrollBarThickness = 4
treeList.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
treeList.AutomaticCanvasSize = Enum.AutomaticSize.Y
treeList.CanvasSize = UDim2.new(0, 0, 0, 0)
treeList.Parent = treePanel

local treeLayout = Instance.new("UIListLayout")
treeLayout.Parent = treeList
treeLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Right Panel (Properties)
local propPanel = Instance.new("Frame")
propPanel.Size = UDim2.new(0.4, -2, 1, -27)
propPanel.Position = UDim2.new(0.6, 2, 0, 27)
propPanel.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
propPanel.BorderSizePixel = 0
propPanel.Parent = mainFrame

local propList = Instance.new("ScrollingFrame")
propList.Size = UDim2.new(1, 0, 1, 0)
propList.BackgroundTransparency = 1
propList.BorderSizePixel = 0
propList.ScrollBarThickness = 4
propList.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
propList.AutomaticCanvasSize = Enum.AutomaticSize.Y
propList.CanvasSize = UDim2.new(0, 0, 0, 0)
propList.Parent = propPanel

local propLayout = Instance.new("UIListLayout")
propLayout.Parent = propList
propLayout.SortOrder = Enum.SortOrder.LayoutOrder


-- [ 3. EXPLORER LOGIC ]
local expandedMap = {}
local selection = nil
local contextMenu = nil

local function renderProperties(obj)
    for _, child in ipairs(propList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    if not obj then return end
    
    local props = {"ClassName", "Name", "Parent", "Archivable"}
    local isa = obj.IsA
    
    if isa(obj, "BasePart") then
        table.insert(props, "Position")
        table.insert(props, "Size")
        table.insert(props, "Anchored")
    elseif isa(obj, "LuaSourceContainer") then
        table.insert(props, "Disabled")
        table.insert(props, "RunContext")
    end
    
    for _, propName in ipairs(props) do
        local success, val = pcall(function() return obj[propName] end)
        if success then
            local item = Instance.new("Frame")
            item.Size = UDim2.new(1, 0, 0, 24)
            item.BackgroundTransparency = 1
            item.Parent = propList
            
            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(0.4, 0, 1, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = propName
            nameLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Font = Enum.Font.SourceSans
            nameLbl.TextSize = 14
            nameLbl.Parent = item
            
            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0.6, -5, 1, 0)
            valLbl.Position = UDim2.new(0.4, 5, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(val)
            valLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            valLbl.TextXAlignment = Enum.TextXAlignment.Left
            valLbl.Font = Enum.Font.SourceSans
            valLbl.TextSize = 14
            valLbl.TextTruncate = Enum.TextTruncate.AtEnd
            valLbl.Parent = item
        end
    end
end

local function renderTree()
    for _, child in ipairs(treeList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local function recur(obj, depth)
        local item = Instance.new("Frame")
        item.Size = UDim2.new(1, 0, 0, 20)
        item.BackgroundTransparency = 1
        item.Parent = treeList
        
        local indent = depth * 16
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -indent, 0, 20)
        btn.Position = UDim2.new(0, indent, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = "  " .. obj.Name
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.Parent = item
        
        btn.MouseEnter:Connect(function()
            if selection ~= obj then
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                btn.BackgroundTransparency = 0
            end
        end)
        btn.MouseLeave:Connect(function()
            if selection ~= obj then
                btn.BackgroundTransparency = 1
            end
        end)
        
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                selection = obj
                renderProperties(obj)
                renderTree()
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                selection = obj
                renderProperties(obj)
                showContextMenu(obj, UserInputService:GetMouseLocation())
                renderTree()
            end
        end)
        
        if selection == obj then
            btn.BackgroundColor3 = Color3.fromRGB(38, 76, 114)
            btn.BackgroundTransparency = 0
        end
        
        local expandBtn = Instance.new("TextButton")
        expandBtn.Size = UDim2.new(0, 16, 0, 20)
        expandBtn.Position = UDim2.new(0, indent - 16, 0, 0)
        expandBtn.BackgroundTransparency = 1
        expandBtn.Text = ""
        expandBtn.Font = Enum.Font.SourceSans
        expandBtn.TextSize = 12
        expandBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        expandBtn.Parent = item
        
        if #obj:GetChildren() > 0 then
            expandBtn.Text = expandedMap[obj] and "▾" or "▸"
            expandBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    expandedMap[obj] = not expandedMap[obj]
                    renderTree()
                end
            end)
        end
        
        if expandedMap[obj] then
            for _, child in ipairs(obj:GetChildren()) do
                recur(child, depth + 1)
            end
        end
    end
    
    recur(game, 0)
end


-- [ 4. TELEGRAM & CONTEXT MENU LOGIC ]
local function sendToTelegram(obj)
    task.spawn(function()
        local htmlParts = {}
        local escapeHtml = function(str)
            str = tostring(str)
            str = str:gsub("&", "&amp;")
            str = str:gsub("<", "&lt;")
            str = str:gsub(">", "&gt;")
            return str
        end
        
        local fullName = obj:GetFullName()
        local className = obj.ClassName
        local propsList = {}
        
        local knownProps = {
            "Name", "ClassName", "Parent", "Position", "Size", "Color", 
            "Transparency", "Anchored", "CanCollide", "Value", "Text", 
            "Source", "Disabled", "RunContext", "Archivable", "Locked"
        }
        for _, propName in ipairs(knownProps) do
            local success, val = pcall(function() return obj[propName] end)
            if success then
                table.insert(propsList, string.format("<b>%s</b> = %s", propName, escapeHtml(val)))
            end
        end
        
        local propsText = #propsList > 0 and table.concat(propsList, "\n") or "N/A"
        table.insert(htmlParts, string.format("<b>Instance:</b> %s\n<b>Class:</b> %s\n%s", escapeHtml(fullName), escapeHtml(className), propsText))
        
        local htmlMessage = "<b>Dex-Explorer Selection Dump</b>\n\n" .. table.concat(htmlParts, "\n\n--------------------\n\n")
        local url = "https://api.telegram.org/bot"..TELEGRAM_BOT_TOKEN.."/sendMessage"
        
        pcall(function()
            HttpService:RequestAsync({
                Url = url, Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({chat_id = TELEGRAM_CHAT_ID, text = htmlMessage, parse_mode = "HTML"})
            })
        end)
    end)
end

local function saveAndUploadToTelegram(obj)
    task.spawn(function()
        if not env.saveinstance then
            -- Fallback if executor lacks saveinstance
            local textUrl = "https://api.telegram.org/bot"..TELEGRAM_BOT_TOKEN.."/sendMessage"
            pcall(function()
                HttpService:RequestAsync({
                    Url = textUrl, Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({chat_id = TELEGRAM_CHAT_ID, text = "SaveInstance: 'saveinstance' not available in your executor."})
                })
            end)
            return
        end

        local filename = obj.Name .. "_" .. os.time()
        local s, e = pcall(env.saveinstance, obj, filename, {Decompile = true})
        if not s then return end
        
        local fileData = nil
        local successFile, errFile = pcall(function()
            fileData = env.readfile(filename..".rbxlx")
        end)
        
        local sendSuccess = false
        if successFile and fileData and #fileData > 0 then
            local boundary = "----DEXBoundary" .. tostring(math.random(100000, 999999))
            local body = "--" .. boundary .. "\r\n"
            body = body .. 'Content-Disposition: form-data; name="chat_id"' .. "\r\n\r\n"
            body = body .. TELEGRAM_CHAT_ID .. "\r\n"
            body = body .. "--" .. boundary .. "\r\n"
            body = body .. 'Content-Disposition: form-data; name="document"; filename="'..filename..'.rbxlx"' .. "\r\n"
            body = body .. 'Content-Type: application/octet-stream' .. "\r\n\r\n"
            body = body .. fileData .. "\r\n"
            body = body .. "--" .. boundary .. "--" .. "\r\n"
            
            local url = "https://api.telegram.org/bot"..TELEGRAM_BOT_TOKEN.."/sendDocument"
            local successSend, sendResult = pcall(function()
                local response = HttpService:RequestAsync({
                    Url = url, Method = "POST",
                    Headers = {["Content-Type"] = "multipart/form-data; boundary=" .. boundary},
                    Body = body
                })
                if not response.Success then error("HTTP Error") end
            end)
            sendSuccess = successSend
        end
        
        if not sendSuccess then
            -- Fallback to text
            local textUrl = "https://api.telegram.org/bot"..TELEGRAM_BOT_TOKEN.."/sendMessage"
            pcall(function()
                HttpService:RequestAsync({
                    Url = textUrl, Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({chat_id = TELEGRAM_CHAT_ID, text = "SaveInstance: Successfully saved '"..filename..".rbxlx' but failed to upload to Telegram."})
                })
            end)
        end
    end)
end

function showContextMenu(obj, pos)
    if contextMenu then contextMenu:Destroy() end
    
    contextMenu = Instance.new("Frame")
    contextMenu.Size = UDim2.new(0, 200, 0, 0)
    contextMenu.Position = UDim2.new(0, pos.X, 0, pos.Y)
    contextMenu.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
    contextMenu.BorderSizePixel = 0
    contextMenu.Parent = gui
    contextMenu.ZIndex = 20
    contextMenu.AutomaticSize = Enum.AutomaticSize.Y
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = contextMenu
    
    local function addItem(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.BackgroundTransparency = 1
        btn.Text = " " .. name
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.Parent = contextMenu
        
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(38, 76, 114)
            btn.BackgroundTransparency = 0
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundTransparency = 1
        end)
        
        btn.MouseButton1Click:Connect(function()
            callback()
            contextMenu:Destroy()
            contextMenu = nil
        end)
    end
    
    addItem("Send to Telegram", function() sendToTelegram(obj) end)
    addItem("Save Instance & Upload", function() saveAndUploadToTelegram(obj) end)
    addItem("Copy Path", function() if env.setclipboard then env.setclipboard(obj:GetFullName()) end end)
    addItem("Delete", function() pcall(function() obj:Destroy() end) selection = nil renderTree() end)
    
    -- Click outside to close
    local closeCon
    closeCon = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = UserInputService:GetMouseLocation()
            if mousePos.X < contextMenu.AbsolutePosition.X or mousePos.X > contextMenu.AbsolutePosition.X + contextMenu.AbsoluteSize.X or
               mousePos.Y < contextMenu.AbsolutePosition.Y or mousePos.Y > contextMenu.AbsolutePosition.Y + contextMenu.AbsoluteSize.Y then
                contextMenu:Destroy()
                contextMenu = nil
                closeCon:Disconnect()
            end
        end
    end)
end


-- [ 5. INITIALIZATION ]
task.spawn(function()
    -- Hold splash screen for 3 seconds to simulate initialization
    task.wait(3)
    
    splashWindow.Visible = false
    splashBg.Visible = false
    mainFrame.Visible = true
    
    expandedMap[game] = true -- Expand game by default
    renderTree()
    
    -- Auto-update tree when instances are added/removed
    game.DescendantAdded:Connect(function(obj)
        local par = obj.Parent
        if par and expandedMap[par] then
            renderTree()
        end
    end)
    
    game.DescendantRemoving:Connect(function(obj)
        local par = obj.Parent
        if par and expandedMap[par] then
            task.wait(0.1) -- wait for actual removal
            renderTree()
        end
    end)
end)
