net.Receive("makeragdollinvisduringjumpcam", function()
    local ragdollentity = net.ReadEntity()
    local state = net.ReadBool()

if state then
    if not IsValid(ragdollentity) then return end

    print(ragdollentity)

    ragdollentity:SetNoDraw(true)
else
    if IsValid(ragdollentity) then
        ragdollentity:SetNoDraw(false)
    end
 end
end)

local TargetPos = nil
local SmoothPos = nil

net.Receive("changecamposelberr2", function()
    local state = net.ReadBool()
    local headpos = net.ReadVector()
    local headang = net.ReadAngle()

if state then

        TargetPos = headpos

        if not TargetPos then return end

        SmoothPos = SmoothPos and LerpVector(FrameTime() * 10, SmoothPos, TargetPos) or TargetPos

        hook.Add("CalcView", "changeplayercam", function(ply, pos, angles, fov)
                local view = {
                    origin = SmoothPos + Vector(0,0,50),
                    angles = angles + Angle(0,180,0),
                    fov = fov,
                    drawviewer = true
                }
                return view
        end)

    else
        print("removing hook")
        hook.Remove("CalcView", "changeplayercam")
    end
end)

local highlightedplayer = {}

net.Receive("highlightelberrrobot", function()
    local HIGHLIGHTENT = net.ReadEntity()
    local pill = net.ReadEntity()
    local state = net.ReadBool()

if state then

    table.insert(highlightedplayer, HIGHLIGHTENT)

    pill:ChatPrint("Someone Got Spotted By a Robot!")

    hook.Add("PreDrawHalos", "highlightplayer", function()
        halo.Add(highlightedplayer, Color(255,0,0), 5, 5, 5, true, true)
    end)
else
    hook.Remove("PreDrawHalos", "highlightplayer")
    highlightedplayer = {}
 end
end)

local timerDuration = 15
local timerDuration2 = 5
local timerstart = CurTime()
local timerstart2 = CurTime()
local cooldown1 = false
local cooldown2 = false
local mat1abil = Material("abilicons/charge_icon_yeah.png")
local mat2abil = Material("abilicons/elberr_icons.png")
local r, g, b = 255,255,255
local r2, g2, b2 = 255,255,255

    surface.CreateFont("CooldownFontmiku", {
        font = "Arial",      
        size = 48,            
        weight = 800,       
        antialias = true,     
        outline = true,      
    })

        surface.CreateFont("Abilfont", {
        font = "Arial",      
        size = 60,            
        weight = 800,       
        antialias = true,     
        outline = true,      
    })




local xtimer = ScrW() - 200
local ytimer = ScrH() - 200

local xtimer2 = ScrW() - 580
local ytimer2 = ScrH() - 200


hook.Add("HUDPaint", "abiilityiconselberrPHASE2", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local pill = pk_pills.getMappedEnt(ply)
    if not IsValid(pill) or pill:GetPillForm() ~= "pill_elberr2" then return end

    local w, h = 250, 250

    local x = ScrW() - 300
    local y = ScrH() - 300

    local x2 = ScrW() - 680
    local y2 = y

    surface.SetDrawColor(r, g, b)
    surface.SetMaterial(mat1abil)
    surface.DrawTexturedRect(x, y, w, h)
    draw.SimpleText("R", "Abilfont", ScrW() - 310, ScrH() - 325)

    surface.SetDrawColor(r2, g2, b2)
    surface.SetMaterial(mat2abil)
    surface.DrawTexturedRect(x2, y2, w, h)
    draw.SimpleText("T", "Abilfont", ScrW() - 690, ScrH() - 325)

    if cooldown1 then
        local elapsed = CurTime() - timerstart
        local remaining = math.max(timerDuration - elapsed, 0)
        local seconds = math.ceil(remaining)

        local secondsStr = tostring(seconds)
        local offset = (seconds < 10) and 12 or 0

        surface.SetFont("CooldownFontmiku")
        surface.SetTextColor(255,255,255)
        surface.SetTextPos(xtimer + offset, ytimer)
        surface.DrawText(secondsStr)

        if remaining <= 0 then
            r, g, b = 255, 255, 255
            cooldown1 = false
        end
    end

        if cooldown2 then
        local elapsed2 = CurTime() - timerstart2
        local remaining2 = math.max(timerDuration2 - elapsed2, 0)
        local seconds2 = math.ceil(remaining2)

        local secondsStr2 = tostring(seconds2)
        local offset2 = (seconds2 < 10) and 12 or 0

        surface.SetFont("CooldownFontmiku")
        surface.SetTextColor(255,255,255)
        surface.SetTextPos(xtimer2 + offset2, ytimer2)
        surface.DrawText(secondsStr2)

        if remaining2 <= 0 then
            r2, g2, b2 = 255, 255, 255
            cooldown2 = false
        end
    end
end)

net.Receive("abiliconscooldownselberr2", function()
    local state = net.ReadString()

    if state == "ChargeUse" then
        r, g, b = 50,50,50
    elseif state == "ChargeCD" then
        cooldown1 = true
        timerstart = CurTime()
    elseif state == "RobotCD" then
        cooldown2 = true
        r2, g2, b2 = 50,50,50
        timerstart2 = CurTime()
    end
end)

local transparencyredelb = 0
local duration = 0.2

net.Receive("killredscreenelberr", function()
    local bool = net.ReadBool()

    transparencyredelb = 0

    if bool then    
        timer.Create("changetransparencyelberr", 0.01, 0, function()
            transparencyredelb = math.min(transparencyredelb + (255 / duration) * FrameTime(), 255)

            if transparencyredelb >= 255 then
                timer.Remove("changetransparencyelberr")
            end
        end)

        hook.Add("HUDPaint", "redscreenblood", function()
            surface.SetDrawColor(255,0,0, transparencyredelb)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end)
    else
        hook.Remove("HUDPaint", "redscreenblood")
    end
end)


net.Receive("elberr2_thirdpersonsync", function()
    local isThird = net.ReadBool()
    local pill = ply.pk_pill_ent
    if IsValid(pill) then
        pill:SetNWBool("elberr2_thirdperson", isThird)
    end
end)