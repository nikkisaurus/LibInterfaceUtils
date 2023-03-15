local addonName, private = ...
local lib, minor = LibStub:GetLibrary(addonName)

local objectType, version = "TreeGroup", 1
if not lib or (lib.versions[objectType] or 0) >= version then
    return
end

local templates = {
    default = {
        frame = {
            bgEnabled = true,
            bordersEnabled = true,
        },
        node = {
            header = {
                bgEnabled = false,
                bordersEnabled = false,
                highlightColor = private.assets.colors.dimmedFlair,
            },
        },
        child = {
            disabled = {
                bgEnabled = false,
                bordersEnabled = false,
                highlightEnabled = false,
                justifyH = "LEFT",
            },
            highlight = {
                bgEnabled = false,
                bordersEnabled = false,
                highlightEnabled = false,
                justifyH = "LEFT",
            },
            normal = {
                bgEnabled = false,
                bordersEnabled = false,
                highlightEnabled = false,
                justifyH = "LEFT",
            },
        },
        resizer = {
            disabled = {
                bgEnabled = true,
                bgColor = private.assets.colors.darker,
                bordersEnabled = true,
            },
            highlight = {
                bgEnabled = true,
                bgColor = private.assets.colors.normal,
                bordersEnabled = true,
                bordersColor = private.assets.colors.black,
            },
            normal = {
                bgEnabled = true,
                bgColor = private.assets.colors.darker,
                bordersEnabled = true,
            },
        },
        selectedNode = {
            label = {
                color = private.assets.colors.white,
            },
            header = {
                bgEnabled = true,
                bordersEnabled = false,
                bgColor = private.assets.colors.dimmedFlair,
            },
        },
        selectedChild = {
            content = {
                bgEnabled = true,
                bgColor = private.assets.colors.dimmedFlair,
                bordersEnabled = false,
            },
        },
    },
}

local childScripts = {
    resizer = {
        OnMouseDown = function(self)
            local frame = self.widget.object
            frame.treeContainer:StartSizing("RIGHT")
        end,

        OnMouseUp = function(self)
            local frame = self.widget.object
            frame.treeContainer:StopMovingOrSizing()
            frame:SetAnchors()
            frame.treeContainer:SetUserPlaced(false)
        end,
    },
}

local scripts = {
    OnSizeChanged = function(self)
        local w, h = self:GetSize()
        local minWidth = min(200, w * (1 / 3))
        local maxWidth = w * (1 / 2)
        local width = self.treeContainer:GetWidth()
        if width < minWidth then
            self.treeContainer:SetWidth(minWidth)
        elseif width > maxWidth then
            self.treeContainer:SetWidth(maxWidth)
        end
        self.treeContainer:SetResizeBounds(minWidth, h, maxWidth, h)
    end,
}

local methods = {
    OnAcquire = function(self)
        self:SetLayout()
        self:SetSize(600, 500)
        self:ApplyTemplate("default")
        self:SetTree()
        self.treeContainer:SetResizable(true)
        self.treeContainer:SetWidth(200)
    end,

    OnRelease = function(self)
        self.tree:ReleaseChildren()
        self.content:ReleaseChildren()
    end,

    ApplyTemplate = function(self, templateName, mixin)
        templateName = type(templateName) == "string" and templateName:lower() or templateName
        local template
        if type(templateName) == "table" then
            template = CreateFromMixins(templates.default, templateName)
        else
            template = templates[templateName or "default"] or templates.default
        end

        private:SetBackdrop(self, template.frame)
        self.resizer:ApplyTemplate(template.resizer)

        self:SetUserData("template", template)
        self:SetAnchors()
    end,

    DoLayout = function(self, ...)
        return self.content:DoLayout(...)
    end,

    GetAnchorX = function(self)
        return self.content:GetAnchorX()
    end,

    GetAvailableHeight = function(self)
        return self.content:GetAvailableHeight()
    end,

    GetAvailableWidth = function(self)
        return self.content:GetAvailableWidth()
    end,

    MarkDirty = function(self, ...)
        self.content:MarkDirty(...)
    end,

    New = function(self, ...)
        return self.content:New(...)
    end,

    ParentChild = function(self, ...)
        self.content:ParentChild(...)
    end,

    ReleaseChildren = function(self)
        self.content:ReleaseChildren()
    end,

    RemoveChild = function(self, ...)
        self.content:RemoveChild(...)
    end,

    SetAnchors = function(self)
        self.treeContainer:SetParent(self)
        self.tree:SetParent(self.treeContainer)
        self.resizer:SetParent(self.treeContainer)
        self.content:SetParent(self)

        self.treeContainer:SetPoint("TOPLEFT")
        self.treeContainer:SetPoint("BOTTOM")

        self.resizer:SetPoint("TOPLEFT", self.tree, "TOPRIGHT")
        self.resizer:SetPoint("BOTTOMLEFT", self.tree, "BOTTOMRIGHT")

        self.content:SetPoint("TOPLEFT", self.resizer, "TOPRIGHT", 0, 0)
        self.content:SetPoint("BOTTOMRIGHT")
    end,

    SetLayout = function(self, ...)
        self.content:SetLayout(...)
    end,

    SetSelected = function(self, selectedNode, selectedChild)
        local template = self:GetUserData("template")

        for _, node in pairs(self.tree.children) do
            if not node:IsDisabled() then
                if node == selectedNode and not selectedChild then
                    node:ApplyTemplate(template.selectedNode)
                else
                    node:ApplyTemplate(template.node)
                end
            end

            for _, container in pairs(node.children) do
                for _, child in pairs(container.children) do
                    if not child:IsDisabled() then
                        if child == selectedChild then
                            container:ApplyTemplate(template.selectedChild)
                            container:SetUserData("selected", true)
                        else
                            container:ApplyTemplate(template.child)
                            container:SetUserData("selected")
                        end
                    end
                end
            end
        end
    end,

    SetTree = function(self, tree)
        self.tree:ReleaseChildren()

        if not tree then
            return
        end

        local template = self:GetUserData("template")

        for _, treeInfo in ipairs(tree) do
            local node = self.tree:New("CollapsibleGroup")
            node:SetLayout("List")
            node:SetFullWidth(true)
            node:SetPadding(0, 0, 5, 0)
            node:SetSpacing(0, 0)
            node:ApplyTemplate(template.node)
            node:SetIcon(treeInfo.icon, 14, 14)
            node:SetLabel(treeInfo.text)
            node:Collapse(true)

            local disabledNode = treeInfo.disabled
            if type(disabledNode) == "boolean" then
                node:SetDisabled(disabledNode)
            elseif type(disabledNode) == "function" then
                node:SetDisabled(disabledNode())
            end

            if treeInfo.children then
                for _, childInfo in ipairs(treeInfo.children) do
                    local container = node:New("Group")
                    container:SetFullWidth(true)
                    container:SetPadding(2, 2, 2, 2)

                    local child = container:New("Label")
                    child:SetFillWidth(true)
                    child:SetOffsets(10, 0, 0, 0)
                    child:ApplyTemplate(template.child)
                    child:SetIcon(childInfo.icon, 14, 14)
                    child:SetText(childInfo.text)

                    local disabledChild = childInfo.disabled
                    if type(disabledChild) == "boolean" then
                        child:SetDisabled(disabledChild or disabledNode)
                    elseif type(disabledChild) == "function" then
                        child:SetDisabled(disabledChild() or disabledNode)
                    end

                    container:SetCallback("OnMouseDown", function()
                        self:SetSelected(node, child)
                        self.content:ReleaseChildren()
                        childInfo.onClick(self.content, childInfo)
                        self.content:DoLayout()
                    end)

                    container:SetCallback("OnEnter", function()
                        container:ApplyTemplate(template.selectedChild)
                    end)

                    container:SetCallback("OnLeave", function()
                        container:ApplyTemplate(template[container:GetUserData("selected") and "selectedChild" or "child"])
                    end)

                    child:SetCallback("OnMouseDown", function()
                        container:Fire("OnMouseDown")
                    end)

                    child:SetCallback("OnEnter", function()
                        container:Fire("OnEnter")
                    end)

                    child:SetCallback("OnLeave", function()
                        container:Fire("OnLeave")
                    end)
                end
            else
                node:EnableIndicator()
                node:SetPadding(0, 0, 0, 0)
            end

            node:SetCallback("OnCollapse", function()
                self:SetSelected(node)
                self.content:ReleaseChildren()
                treeInfo.onClick(self.content, treeInfo)
                self.content:DoLayout()
            end)
        end

        self:SetSelected()
        self.tree:DoLayout()
    end,
}

local function creationFunc()
    local frame = CreateFrame("Frame", private:GetObjectName(objectType), UIParent)
    frame = private:CreateTextures(frame)

    frame.treeContainer = CreateFrame("Frame", nil, frame)

    frame.tree = lib:New("ScrollFrame")
    frame.tree:SetAllPoints(frame.treeContainer)
    frame.tree:SetLayout("List")

    frame.resizer = lib:New("Button")
    frame.resizer:SetWidth(5)
    frame.resizer:RegisterForDrag("LeftButton")
    frame.resizer:SetCallback("OnMouseDown", childScripts.resizer.OnMouseDown)
    frame.resizer:SetCallback("OnMouseUp", childScripts.resizer.OnMouseUp)

    frame.content = lib:New("ScrollFrame")

    local widget = {
        object = frame,
        type = objectType,
        version = version,
    }

    frame.resizer.widget = widget

    return private:RegisterContainer(widget, methods, scripts)
end

private:RegisterWidgetPool(objectType, creationFunc)
