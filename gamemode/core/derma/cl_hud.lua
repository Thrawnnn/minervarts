local PANEL = {}

function PANEL:Init()
    gmodwars.gui.hud = self

    local padding = ScreenScale(8)
    local abilitiesButtonScale = ScreenScale(24)
    local selectedButtonScale = ScreenScale(24)
    local abilitiesScale = ScreenScale(96)
    local minimapScale = ScreenScale(128)
    local selectedScale = ScreenScale(96)

    self:SetSize(ScrW(), ScrH())
    self:ParentToHUD()
    self:MakePopup()

    self:SetKeyboardInputEnabled(true)
    self:SetMouseInputEnabled(true)
    self:SetWorldClicker(true)

    // abilities panel
    local abilities = self:Add("DPanel")
    abilities:SetPos(0, self:GetTall() - abilitiesScale)
    abilities:SetSize(abilitiesScale, abilitiesScale)
    abilities.Paint = function(self, w, h)
        // draw abilities panel background
        draw.RoundedBox(0, 0, 0, w, h, Color(150, 150, 150, 200))
    end
    
    // abilities grid
    local grid = abilities:Add("DGrid")
    grid:SetCols(4)
    grid:SetColWide(abilitiesButtonScale)
    grid:SetRowHeight(abilitiesButtonScale)

    // populate abilities grid with buttons
    for i = 1, 16 do
        local button = grid:Add("DButton")
        button:SetText(tostring(i))
        button:SetSize(abilitiesButtonScale, abilitiesButtonScale)
        button.Paint = function(self, w, h)
            // draw button background
            draw.RoundedBox(0, 0, 0, w, h, Color(150, 150, 150, 200))
        end

        grid:AddItem(button)
    end

    // minimap
    local minimap = self:Add("DPanel")
    minimap:SetPos(self:GetWide() - minimapScale, self:GetTall() - minimapScale)
    minimap:SetSize(minimapScale, minimapScale)
    minimap.Paint = function(self, w, h)
        // draw minimap background
        draw.RoundedBox(0, 0, 0, w, h, Color(150, 150, 150, 200))
    end

    // selected units/buildings panel
    local selected = self:Add("DScrollPanel")
    selected:SetPos(abilitiesScale + padding, self:GetTall() - selectedScale)
    selected:SetSize(self:GetWide() - padding * 2 - minimap:GetWide() - abilitiesScale, selectedScale)
    selected.Paint = function(self, w, h)
        // draw selected units/buildings panel background
        draw.RoundedBox(0, 0, 0, w, h, Color(150, 150, 150, 200))
    end
    
    // selected units/buildings grid
    local grid = selected:Add("DGrid")
    grid:SetCols(selected:GetWide() * 0.005)
    grid:SetPos(0, 0)
    grid:SetColWide(selectedButtonScale)
    grid:SetRowHeight(selectedButtonScale)

    // populate selected units/buildings grid with buttons
    for i = 1, 16 do
        local button = grid:Add("SpawnIcon")
        button:SetModel("models/kleiner.mdl")
        button:SetSize(selectedButtonScale, selectedButtonScale)
        button:SetTooltip("Kleiner Unit")
        button.Paint = function(self, w, h)
            // draw button background
            draw.RoundedBox(0, 0, 0, w, h, Color(150, 150, 150, 200))
        end

        grid:AddItem(button)
    end

    // selection circle
    self.circle = self:Add("DPanel")
    self.circle:SetSize(64, 64)
    self.circle.Paint = function(self, w, h)
        draw.SimpleTextOutlined("Selected", "DermaDefault", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    self.circle:SetVisible(false)
end

// store selected entities in a table
local selectedEntities = {}

// select unit on mouse click
function PANEL:OnMousePressed(mouseCode)
    if mouseCode == MOUSE_LEFT then
        local mousePos = self:CursorPos()
        local trace = util.TraceLine({
            start = LocalPlayer():GetShootPos(),
            endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 10000,
            filter = LocalPlayer(),
            mask = MASK_SHOT_HULL
        })
        if trace.HitNonWorld then
            local entity = trace.Entity
            if entity:IsValid() then
                selectedEntities = {}
                table.insert(selectedEntities, entity)
                self.circle:SetPos(mousePos - self.circle:GetWide()/2, mousePos - self.circle:GetTall()/2)
                self.circle:SetVisible(true)
            end
        end
    end
end

// clear selection on right-click
function PANEL:OnMouseReleased(mouseCode)
    if mouseCode == MOUSE_RIGHT then
        selectedEntities = {}
        self.circle:SetVisible(false)
    end
end

// highlight selected entities with circle
function PANEL:Think()
    local selectedPos = Vector(0, 0, 0)
    local numSelected = #selectedEntities
    if numSelected > 0 then
        for i, entity in ipairs(selectedEntities) do
            selectedPos = selectedPos + entity:GetPos()
        end
        selectedPos = selectedPos / numSelected
        local screenPos = selectedPos:ToScreen()
        self.circle:SetPos(screenPos.x - self.circle:GetWide()/2, screenPos.y - self.circle:GetTall()/2)
        self.circle:SetVisible(true)
    else
        self.circle:SetVisible(false)
    end
end

vgui.Register("gmodwars.HUD", PANEL, "EditablePanel")

if ( IsValid(gmodwars.gui.hud) ) then
    gmodwars.gui.hud:Remove()
end

vgui.Create("gmodwars.HUD")