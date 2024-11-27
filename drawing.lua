local coreGui = game:GetService("CoreGui")
local camera = workspace.CurrentCamera

local drawingUI = Instance.new("ScreenGui")
drawingUI.Name = "Drawing | Xeno"
drawingUI.IgnoreGuiInset = true
drawingUI.DisplayOrder = 0x7fffffff
drawingUI.Parent = coreGui

local drawingIndex = 0
local drawingFontsEnum = {
    [0] = Font.fromEnum(Enum.Font.Roboto),
    [1] = Font.fromEnum(Enum.Font.Legacy),
    [2] = Font.fromEnum(Enum.Font.SourceSans),
    [3] = Font.fromEnum(Enum.Font.RobotoMono)
}

local function getFontFromIndex(fontIndex)
    return drawingFontsEnum[fontIndex]
end

local function convertTransparency(transparency)
    return math.clamp(1 - transparency, 0, 1)
end

local function createBaseDrawingObj()
    return {
        Visible = true,
        ZIndex = 0,
        Transparency = 1,
        Color = Color3.new(),
        Remove = function(self) setmetatable(self, nil) end,
        Destroy = function(self) setmetatable(self, nil) end,
        SetProperty = function(self, index, value)
            if self[index] ~= nil then
                self[index] = value
            else
                warn("Attempted to set invalid property: " .. tostring(index))
            end
        end,
        GetProperty = function(self, index)
            if self[index] ~= nil then
                return self[index]
            else
                warn("Attempted to get invalid property: " .. tostring(index))
                return nil
            end
        end,
        SetParent = function(self, parent)
            self.Parent = parent
        end
    }
end

local DrawingLib = {}
DrawingLib.Fonts = {
    ["UI"] = 0,
    ["System"] = 1,
    ["Plex"] = 2,
    ["Monospace"] = 3
}

-- Create a reusable pool for UI elements
local function createUIElement(className, properties)
    local instance = Instance.new(className)
    for key, value in pairs(properties) do
        instance[key] = value
    end
    instance.Parent = drawingUI
    return instance
end

function DrawingLib.new(drawingType)
    drawingIndex += 1
    if drawingType == "Line" then
        return DrawingLib.createLine()
    elseif drawingType == "Text" then
        return DrawingLib.createText()
    elseif drawingType == "Circle" then
        return DrawingLib.createCircle()
    elseif drawingType == "Square" then
        return DrawingLib.createSquare()
    elseif drawingType == "Image" then
        return DrawingLib.createImage()
    elseif drawingType == "Quad" then
        return DrawingLib.createQuad()
    elseif drawingType == "Triangle" then
        return DrawingLib.createTriangle()
    elseif drawingType == "Frame" then
        return DrawingLib.createFrame()
    elseif drawingType == "ScreenGui" then
        return DrawingLib.createScreenGui()
    elseif drawingType == "TextButton" then
        return DrawingLib.createTextButton()
    elseif drawingType == "TextLabel" then
        return DrawingLib.createTextLabel()
    elseif drawingType == "TextBox" then
        return DrawingLib.createTextBox()
    else
        error("Invalid drawing type: " .. tostring(drawingType))
    end
end

function DrawingLib.createLine()
    local lineObj = createBaseDrawingObj()
    lineObj.From = Vector2.zero
    lineObj.To = Vector2.zero
    lineObj.Thickness = 1

    local lineFrame = createUIElement("Frame", {
        Name = drawingIndex,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0
    })

    return setmetatable({
        From = lineObj.From,
        To = lineObj.To,
        Thickness = lineObj.Thickness,
        Color = lineObj.Color,
        Transparency = lineObj.Transparency,
        Visible = lineObj.Visible,
        ZIndex = lineObj.ZIndex,
        Remove = function()
            lineFrame:Destroy()
            lineObj:Remove()
        end,
        Update = function()
            local fromPos = lineObj.From
            local toPos = lineObj.To
            lineFrame.Position = UDim2.new(0, fromPos.X, 0, fromPos.Y)
            lineFrame.Size = UDim2.new(0, (toPos - fromPos).Magnitude, 0, lineObj.Thickness)
            lineFrame.Rotation = math.deg(math.atan2(toPos.Y - fromPos.Y, toPos.X - fromPos.X))
            lineFrame.BackgroundColor3 = lineObj.Color
            lineFrame.BackgroundTransparency = convertTransparency(lineObj.Transparency)
            lineFrame.Visible = lineObj.Visible
            lineFrame.ZIndex = lineObj.ZIndex
        end
    }, { __index = lineObj })
end

function DrawingLib.createTextLabel()
    local textLabelObj = createBaseDrawingObj()
    textLabelObj.Text = ""
    textLabelObj.Position = UDim2.new(0, 0, 0, 0)
    textLabelObj.Font = DrawingLib.Fonts.UI
    textLabelObj.TextSize = 14
    textLabelObj.Center = false

    local textLabel = createUIElement("TextLabel", {
        Name = drawingIndex,
        Text = textLabelObj.Text,
        Position = textLabelObj.Position,
        Font = getFontFromIndex(textLabelObj.Font),
        TextSize = textLabelObj.TextSize,
        TextColor3 = textLabelObj.Color,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 0, 50)
    })

    return setmetatable({
        Text = textLabelObj.Text,
        Position = textLabelObj.Position,
        Color = textLabelObj.Color,
        Transparency = textLabelObj.Transparency,
        Visible = textLabelObj.Visible,
        ZIndex = textLabelObj.ZIndex,
        Remove = function()
            textLabel:Destroy()
            textLabelObj:Remove()
        end,
        Update = function()
            textLabel.Text = textLabelObj.Text
            textLabel.Position = textLabelObj.Position
            textLabel.TextColor3 = textLabelObj.Color
            textLabel.BackgroundTransparency = convertTransparency(textLabelObj.Transparency)
            textLabel.Visible = textLabelObj.Visible
            textLabel.ZIndex = textLabelObj.ZIndex
        end
    }, { __index = textLabelObj })
end

return DrawingLib
