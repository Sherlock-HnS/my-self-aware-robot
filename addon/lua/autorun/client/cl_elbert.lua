local timerDuration = 10
local timerstart = CurTime()
local cooldown1 = false
local mat1abil = Material("elberrmisc/charge_icon_for_elberr_NOT_USED.png")
local vignette = Material("elberrmisc/bluevignetteelberr.png")
local barmat = Material("elberrmisc/barelberr.png")
local vignettetransparency = 0
local r, g, b = 255,255,255
local whatthefock = false
local enableelberbar = false
local redbarwidth = 0
local islooking = nil
local state1 = false
local state2 = false
local state3 = false
local state4 = false
local ragdollentity = nil

    surface.CreateFont("CooldownFontmiku", {
        font = "Arial",      
        size = 48,            
        weight = 800,       
        antialias = true,     
        outline = true,      
    })

        surface.CreateFont("Abilitylabelmiku", {
        font = "Arial",      
        size = 60,            
        weight = 800,       
        antialias = true,     
        outline = true,      
    })


local xtimer = ScrW() - 200
local ytimer = ScrH() - 200

local xtimer2 = ScrW() - 550
local ytimer2 = ScrH() - 200


hook.Add("HUDPaint", "abiilityiconselberr", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local pill = pk_pills.getMappedEnt(ply)
    if not IsValid(pill) or pill:GetPillForm() ~= "pill_selfawarerobotelbert" then return end

    local w, h = 250, 250

    local x = ScrW() - 300
    local y = ScrH() - 300

    local x2 = ScrW() - 680
    local y2 = y

    surface.SetDrawColor(r, g, b)
    surface.SetMaterial(mat1abil)
    surface.DrawTexturedRect(x, y, w, h)
    draw.SimpleText("R", "Abilitylabelmiku", ScrW() - 310, ScrH() - 325)

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
end)


net.Receive("changematerialelberr", function()
    mat1abil = Material("elberrmisc/charge_icon_for_elberr_WHILE_USING.png")
end)

net.Receive("changematerialbacktodefault", function()
    mat1abil = Material("elberrmisc/charge_icon_for_elberr_NOT_USED.png")
end)

net.Receive("abilitycooldowneblerrRability", function()
    if not cooldown1 then
        timerstart = CurTime()
        cooldown1 = true
        r, g, b = 50,50,50
    end
end)

net.Receive("fadeinvignette", function()
    whatthefock = true
    vignettetransparency = 0
    timer.Create("controlfade", 0.1, 0, function()
        vignettetransparency = vignettetransparency + 5
        
        if vignettetransparency >= 255 then
            timer.Remove("controlfade")
        end
        print(vignettetransparency)
    end)

    timer.Simple(5.7, function()
        timer.Simple(5, function()
            if whatthefock then
                whatthefock = false
            end
        end)
    end)
end)

hook.Add("HUDPaint", "bluevignette", function()
    if not whatthefock then return end
    surface.SetDrawColor(255,255,255,vignettetransparency)
    surface.SetMaterial(vignette)
    surface.DrawTexturedRect(0,0,ScrW(),ScrH())
end)

net.Receive("fillupbarelberr", function()
    islooking = net.ReadBool()
end)

timer.Create("fillupelberrsbarlikeagoodboy", 0.1, 0, function()
    if not islooking then return end

    if islooking then
        redbarwidth = math.min(redbarwidth + 5, 810)
    end
end)

timer.Create("checkelberrbarcapacity", 0.1, 0, function()
    -- 25%
    if redbarwidth > 202.5 and not state1 then 
        print("red bar reached 25%!")
        net.Start("elberr25%")
        net.SendToServer()
        state1 = true
    end

    -- 50%

    if redbarwidth > 405 and not state2 then
        print("red bar reached 50%!")
        net.Start("elberr50%")
        net.SendToServer()
        state2 = true    
    end

    -- 75%

    if redbarwidth > 607.5 and not state3 then
        print("red bar reached 75%!")
        net.Start("elberr75%")
        net.SendToServer()
        state3 = true    
    end

    -- 100%

    if redbarwidth >= 810 and not state4 then
        print("red bar reached 100%!")
        net.Start("elberr100%")
        net.SendToServer()
        state4 = true
    end    

end)

hook.Add("HUDPaint", "elberrtbaer", function()
    local ply = LocalPlayer()

    local center = ScrW() / 2 + -425
    local centerred = ScrW() / 2 + -415

    local pill = pk_pills.getMappedEnt(ply)
    if not IsValid(pill) or pill:GetPillForm() ~= "pill_selfawarerobotelbert" then return end
    surface.SetDrawColor(255,0,0)
    surface.DrawRect(centerred,ScrH() - 50,redbarwidth,45)

    surface.SetDrawColor(255,255,255,255)
    surface.SetMaterial(barmat)
    surface.DrawTexturedRect(center,ScrH() - 80,840,90)
end)

net.Receive("resetelbertbar", function()
    redbarwidth = 0
    state1 = false
    state2 = false
    state3 = false
    state4 = false
    net.Start("resetelberbarserverside")
    net.SendToServer()
end)


net.Receive("playsoundforevery1elbert", function()
    surface.PlaySound("michael/ELBERR_overcharge_globalwarning.wav")
end)


net.Receive("makerargdollinvisibleduringkillelbertyesyesyesysye", function()
    ragdollentity = net.ReadEntity()
    if not IsValid(ragdollentity) then return end

    print(ragdollentity)

    ragdollentity:SetNoDraw(true)
end)

net.Receive("makeragdollvisibleagainelbert", function()
    if IsValid(ragdollentity) then
        ragdollentity:SetNoDraw(false)
    end
end)

net.Receive("stopbarfillingup", function()
    if islooking then
        islooking = false
    end
end)

net.Receive("resetelberrbar", function()
    redbarwidth = 0
    state1 = false
    state2 = false
    state3 = false
    state4 = false
end)