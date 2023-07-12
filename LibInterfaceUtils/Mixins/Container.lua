local addonName, addon = ...
local lib = LibStub:GetLibrary(addonName .. "-1.0")
if not lib then
	return
end

local Container = {}
addon.Container = Container

function Container:AddChild(widget)
	widget._frame:SetParent(self._frame.content)
	widget._state.parent = self
	tinsert(self.children, widget)
end

function Container:DoLayoutDeferred()
	C_Timer.NewTicker(0.1, GenerateClosure(self.DoLayout, self), 1)
end

function Container:DoLayout(child)
	if self._state.paused then
		return
	end

	local width, height = self:layout(self._frame.content, self.children, self._frame.scrollBox)
	addon.Fire("OnLayoutFinished", self, width, height)

	return width, height
end

function Container:GetContentSize()
	return self._frame.content:GetWidth(), self._frame.content:GetHeight()
end

function Container:New(widgetType)
	local widget = lib:New(widgetType)
	self:AddChild(widget)
	return widget
end

function Container:PauseLayout()
	self._state.paused = true
end

function Container:ReleaseChild(widget)
	for i, child in ipairs(self.children) do
		if child == widget then
			tremove(self.children, i)
			break
		end
	end
	widget:Release()
	self:DoLayoutDeferred()
end

function Container:ReleaseChildren()
	for _, child in ipairs(self.children) do
		child:Release()
	end
	self.children = {}
	self:DoLayoutDeferred()
end

function Container:ResumeLayout()
	self._state.paused = nil
end

function Container:SetLayout(layout)
	layout = layout:lower()
	self._state.layout = layout -- to ensure there's a name ref if it's a built-in layout
	self.layout = addon.layouts[layout] or layout
end

function Container:SetPadding(left, right, top, bottom)
	self._state.padding = {
		left = left or 0,
		right = right or 0,
		top = top or 0,
		bottom = bottom or 0,
	}
end

function Container:SetSpacing(x, y)
	self._state.spacing = {
		x = x or 0,
		y = y or 0,
	}
end
