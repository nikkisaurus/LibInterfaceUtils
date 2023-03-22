local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "Table", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local defaults = {
    header = {},
    cell = {
        even = {
            disabled = {
                bgEnabled = true,
                bordersEnabled = false,
                justifyH = "LEFT",
                bgColor = private.assets.colors.dark,
            },
            highlight = {
                bgEnabled = true,
                bordersEnabled = false,
                justifyH = "LEFT",
                bgColor = private.assets.colors.light,
            },
            normal = {
                bgEnabled = true,
                bordersEnabled = false,
                justifyH = "LEFT",
                bgColor = private.assets.colors.dark,
            },
        },
        odd = {
            disabled = {
                bgEnabled = true,
                bordersEnabled = false,
                justifyH = "LEFT",
                bgColor = private.assets.colors.dark,
            },
            highlight = {
                bgEnabled = true,
                bordersEnabled = false,
                justifyH = "LEFT",
                bgColor = private.assets.colors.light,
            },
            normal = {
                bgEnabled = true,
                bordersEnabled = false,
                justifyH = "LEFT",
                bgColor = private.assets.colors.dark,
            },
        },
    },
}

local scripts = {}

local methods = {
    OnAcquire = function(self)
        self:SetSize(300, 100)
        self:ApplyTemplate()
        self:SetSpacing(0, 0)
    end,

    OnRelease = function(self)
        self:Reset()
    end,

    SetAnchors = function(self)
        self.headers:ClearAllPoints()
        self.content:ClearAllPoints()

        self.headers:SetPoint("TOPLEFT")
        self.headers:SetPoint("TOPRIGHT")

        self.content:SetPoint("TOPLEFT", self.headers, "BOTTOMLEFT")
        self.content:SetPoint("TOPRIGHT", self.headers, "BOTTOMRIGHT")
        self.content:SetPoint("BOTTOM")
    end,

    InitializeDataProvider = function(self, headers, data)
        if type(headers) ~= "table" or type(data) ~= "table" then
            return
        end

        local cols = {}
        for colID, col in ipairs(headers) do
            cols[colID] = col
        end

        self:Initialize(function(index, elementData)
            return 20
        end, function(frame, elementData)
            local container = frame.container or lib:New("Group")
            container:SetParent(frame)
            container:SetAllPoints(frame)
            container:SetLayout("row")
            frame.container = container

            container:PauseLayout()

            -- for colID, col in ipairs(elementData) do
            -- local cell = col:New("Button")
            for i = 1, #elementData do
                local cell = container:New("Label")
            end
            -- -- cell:ShowTruncatedText(true)
            -- -- cell:SetPadding(5, 5, 0, 0)
            -- cell:SetHeight(20)
            -- cell:SetWordWrap(false)
            -- cell:SetFullWidth(true)
            -- -- cell:SetInteractible(true)
            -- cell:SetText(col.text)
            print(elementData)
            -- for i, v in ipairs(elementData) do
            --     print(i, v)
            -- end
            -- -- cell:ApplyTemplate(defaults.cell[mod(row, 2) == 0 and "even" or "odd"])
            -- -- cell:SetIcon(cellInfo.icon, cellInfo.iconWidth, cellInfo.iconHeight, cellInfo.iconPoint)
            -- end
        end)

        self:SetDataProvider(function(provider)
            provider:InsertTable(data)
        end)
        -- self:SetUserData("data", data)
        -- self:SetUserData("cols", {})

        -- local spacingH = self:GetUserData("spacingH")

        -- -- ! table widget is causing fps loss just running
        -- for colID, colInfo in ipairs(data[1]) do
        --     -- local str = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        --     -- str:SetText("Cell")
        --     -- str:SetPoint("TOPLEFT", 0, -colID * 20)
        --     local col = self:New("Group")
        --     col:SetResizable(true)
        --     col:SetSpacing(0, 0)
        --     -- col:SetPadding(colID == 1 and private:GetPixel(1) or 0, colID == #data[1] and private:GetPixel(1) or 0, 0, private:GetPixel(1)) -- enables "border" around the table
        --     col:SetPadding(0, 0, 0, 0)
        --     col:SetLayout("List")
        --     col:SetWidth(colInfo.width)
        --     col:ApplyTemplate("bordered")

        --     local headerRow = col:New("Group")
        --     -- headerRow:SetUserData("xOffset", (colID == 1 and -private:GetPixel(1)) or (colID == #data[1] and private:GetPixel(1)) or 0)
        --     headerRow:SetSpacing(0, 0)
        --     headerRow:SetPadding(0, 0, 0, 0)
        --     headerRow:SetFullWidth(true)
        --     headerRow:SetLayout("filllefttoright")

        --     local header = headerRow:New("Button")
        --     header:SetText(colInfo.text)

        --     local resizer = headerRow:New("Button")
        --     resizer:SetWidth(5)
        --     resizer:RegisterForDrag("LeftButton")
        --     resizer:SetCallback("OnDragStart", function()
        --         col:SetUserData("left", col:GetLeft())
        --         col:StartSizing("RIGHT")
        --         col:ScheduleUpdater(function()
        --             print("running")
        --             if col:GetLeft() < col:GetUserData("left") or col:GetWidth() < 20 then
        --                 col:SetWidth(20)
        --             end
        --         end, 0.01)
        --     end)
        --     resizer:SetCallback("OnDragStop", function()
        --         col:StopMovingOrSizing()
        --         if col:GetLeft() < col:GetUserData("left") or col:GetWidth() < 20 then
        --             col:SetWidth(20)
        --         end
        --         col:CancelUpdater()
        --         self:DoLayoutDeferred()
        --     end)

        --     for row = 2, #data do
        --         local cellInfo = data[row][colID]

        --         local cellContainer = col:New("Group")
        --         -- cellContainer:ApplyTemplate("bordered")
        --         cellContainer:ApplyTemplate(defaults.cell[mod(row, 2) == 0 and "even" or "odd"])
        --         cellContainer:SetFullWidth(true)
        --         -- cellContainer:SetPadding(5, 5, 0, 0)

        --         -- local cell = col:New("Button")
        --         local cell = cellContainer:New("Label")
        --         -- -- cell:ShowTruncatedText(true)
        --         -- -- cell:SetPadding(5, 5, 0, 0)
        --         -- cell:SetHeight(20)
        --         -- cell:SetWordWrap(false)
        --         -- cell:SetFullWidth(true)
        --         -- -- cell:SetInteractible(true)
        --         cell:SetText(cellInfo.text)
        --         -- -- cell:ApplyTemplate(defaults.cell[mod(row, 2) == 0 and "even" or "odd"])
        --         -- -- cell:SetIcon(cellInfo.icon, cellInfo.iconWidth, cellInfo.iconHeight, cellInfo.iconPoint)
        --     end
        -- end

        -- self:DoLayoutDeferred()
    end,

    SetSpacing = function(self, spacingH, spacingV)
        self:SetUserData("spacingH", spacingH or 5)
        self:SetUserData("spacingV", spacingV or 5)
    end,
}

local function creationFunc()
    frame = lib:New("ScrollList")

    local widget = {
        object = frame,
        type = objectType,
        version = version,
    }

    return private:RegisterWidget(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
