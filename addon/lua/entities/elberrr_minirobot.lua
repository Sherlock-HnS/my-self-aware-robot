AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.PrintName = "clanker"
ENT.Category = "clanker"
ENT.Spawnable = true

-- michael here, if someone is looking at this code just so you know this is my first time working with NPCs so pls dont roast me 😭😭
-- also eddy helped out with some of the code

function ENT:HealthBar()
    self.HookName = "Healthbarelberrrobot" .. self:EntIndex()

    hook.Add("PostDrawTranslucentRenderables", self.HookName, function()
    if not IsValid(self) then return end    
        local pos = self:GetPos() + Vector(0,0,50)
        local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

        cam.Start3D2D(pos, ang, 0.1)
        -- gray rectangle
        surface.SetDrawColor(114,114,114)
        surface.DrawRect(-180, -50, self:GetNWInt("GrayBar", 400), 75)

        -- health barr
        surface.SetDrawColor(0,255,0)
        surface.DrawRect(-155, -38, self:GetNWInt("HealthB", 350),50)
        cam.End3D2D()
    end)
end

function ENT:Initialize()
	self:SetModel("models/whynotboi/pills/elberrmini/elberrmini.mdl")
	self:SetSolid(SOLID_BBOX)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))
    self:HealthBar()
    self:SetHealth(9999999)
    self:AddFlags(FL_OBJECT)

    self.Alerted = false

    if SERVER then
        self:EmitSound("elberrsound/minirobot/elbite_roamloop.wav")
    end

    if SERVER then
    self:SetBloodColor(DONT_BLEED)
    end

    if self.loco then
        self.loco:SetStepHeight(18)
        self.loco:SetAcceleration(800)
        self.loco:SetDeceleration(800)
        self.loco:SetDesiredSpeed(90)
        self.loco:SetDeathDropHeight(200)
        self.loco:SetJumpHeight(58)
    end
end

function ENT:FreezeBOT(state)
    self.Frozen = state

    if self.loco then
        self.loco:SetDesiredSpeed(state and 0 or 90)
    end
    
end

function ENT:Use(ply)
end

function ENT:GetSafeRandomNavPos(searchRadius)
    searchRadius = searchRadius or 350

    local areas = navmesh.Find(self:GetPos(), searchRadius, 80, 80)
    if not areas or #areas == 0 then return nil end

    local validAreas = {}

    for _, area in ipairs(areas) do
        if area then
            validAreas[#validAreas + 1] = area
        end
    end

    if #validAreas == 0 then return nil end

    local chosen = validAreas[math.random(1, #validAreas)]
    local point = chosen:GetRandomPoint()

    if not point then return nil end
    return point
end

function ENT:SimpleMoveToward(pos, seconds, speed)
    seconds = seconds or 1.5
    speed = speed or 90

    if not self.loco then return false end

    self.loco:SetDesiredSpeed(speed)

    local endTime = CurTime() + seconds

    while CurTime() < endTime do
        if not IsValid(self) or not self.loco then return false end

        local myPos = self:GetPos()
        local toPos = pos - myPos
        toPos.z = 0

        local dist = toPos:Length()
        if dist < 20 then
            return true
        end

        local dir = toPos:GetNormalized()
        local stepTarget = myPos + dir * math.min(20, dist)

        self.loco:FaceTowards(stepTarget)
        self.loco:Approach(stepTarget, 1)

        coroutine.yield()
    end

    return false
end

function ENT:RoamOnce()
    local navPos = self:GetSafeRandomNavPos(350)

    if navPos then
        self:SimpleMoveToward(navPos, 2, 90)
        return
    end

    local fallbackPos = self:GetPos() + Vector(
        math.random(-120, 120),
        math.random(-120, 120),
        0
    )

    self:SimpleMoveToward(fallbackPos, 1.5, 90)
end

local AlertSounds = {
    "elberrsound/minirobot/elbite_detect_1.ogg",
    "elberrsound/minirobot/elbite_detect_2.ogg",
    "elberrsound/minirobot/elbite_detect_3.ogg",
    "elberrsound/minirobot/elbite_detect_4.ogg",
    "elberrsound/minirobot/elbite_detect_5.ogg",
    "elberrsound/minirobot/elbite_detect_6.ogg"
}

function ENT:Think()
    local idle = self:LookupSequence("idle")
    local walk = self:LookupSequence("walk")
    
    local startPos = self:GetPos() + Vector(0,0,50)
    local endPos = startPos + self:GetForward() * 1000

    if self:GetNWBool("Damaged") then return end

    local trace = util.TraceHull({
        start = self:GetPos() + Vector(0,0,50),
        endpos = self:GetPos() + Vector(0,0,50) + self:GetForward() * 1000,
        mins = Vector(-40,-40,-40),
        maxs = Vector(40,40,40),
        filter = self
    })
    debugoverlay.Box(self:GetPos() + Vector(0,0,50) + self:GetForward() * 1000, Vector(-40,-40,-40), Vector(40,40,40), 0, Color(255,255,255))

    if IsValid(trace.Entity) and trace.Entity:IsPlayer() then
    if trace.Entity == self:GetOwner() then return end
    self.Alerted = true

    print("alerted")

    if not IsValid(self.TargetPLY) then
        self.TargetPLY = trace.Entity
    end

    if IsValid(trace.Entity) and trace.Entity:IsPlayer() then
    self.TargetPLY = trace.Entity
    end

        self:SetNWEntity("TracedENT", trace.Entity)

        self:SetNWBool("alerted", true)

        self:FreezeBOT(true)

    if not self.Hit then
        self.Hit = true
        local alert = self:LookupSequence("alert")
        self:ResetSequence(alert)
        self:SetCycle(0)
        self:SetPlaybackRate(1)

if SERVER then
    if self.Alerted then
        local alert = AlertSounds[math.random(#AlertSounds)]
        self:EmitSound(alert)
        self:StopSound("elberrsound/minirobot/elbite_roamloop.wav")

        self:EmitSound("elberrsound/minirobot/elbites_alerted_movingLOOP.wav")
    end
end

    if not IsValid(self:GetOwner()) then return end
    if not SERVER then return end
        print("running")
        net.Start("highlightelberrrobot")
        net.WriteEntity(trace.Entity)
        net.WriteEntity(self:GetOwner())
        net.WriteBool(true)
        net.Send(self:GetOwner())
    end

    elseif self.Alerted and not self.LostTrack then
        if SERVER then
    if IsValid(self:GetOwner()) then
        net.Start("highlightelberrrobot")
        net.WriteEntity(self:GetNWEntity("TracedENT"))
        net.WriteEntity(self:GetOwner())
        net.WriteBool(false)
        net.Send(self:GetOwner())
    end
end
    self.LostTrack = true
        if not IsValid(self) then return end    
        if self:GetNWBool("Damaged") then return end

timer.Simple(2, function()    
            self.Alerted = false

            print("lost")

    if SERVER then        
        self:StopSound("elberrsound/minirobot/elbites_alerted_movingLOOP.wav")

        self:EmitSound("elberrsound/minirobot/elbite_roamloop.wav")
    end

            self.LostTrack = false
            self.Hit = false
            self:SetNWBool("alerted", false)

            timer.Simple(2, function()
                self.LostTrack = false
            end)
    end)
end

    if self:GetNWBool("alerted") then return end

    local speed = self:GetVelocity():Length()

    if speed < 1 then
        if not self.PlayedIdle then
            self:ResetSequence(idle)

            self.PlayedIdle = true
            self.PlayedWalk = false
        end
    else
        if not self.PlayedWalk then
            self:ResetSequence(walk)

            self.PlayedWalk = true
            self.PlayedIdle = false
        end
    end
end

function ENT:RunBehaviour()
    coroutine.wait(0.2)

    while true do
        if self:GetNWBool("Damaged") then return end

        while self:GetNWBool("alerted") do
            coroutine.wait(0.2)
        end

        self:RoamOnce()
        coroutine.wait(0.4)
    end
end

function ENT:HandleStuck()
    if self.loco then
        self.loco:ClearStuck()
    end

    local pos = self:GetPos()
    self:SetPos(pos + Vector(math.random(-25, 25), math.random(-25, 25), 8))

    coroutine.wait(0.2)
end

function ENT:OnTakeDamage(dmg)
    local health = self:GetNWInt("HealthB", 350)

    health = health - 50

    local effect = EffectData()
    effect:SetOrigin(self:GetPos() + Vector(0,0,35))
    effect:SetNormal(VectorRand())

    util.Effect("MetalSpark", effect)

    health = math.max(health, 0)

    if health == 0 then
    if not self.Damaged then    
        self:SetNWBool("Damaged", true)
        self:SetNWInt("GrayBar", 0)

        self.Damaged = true

        if SERVER then
        timer.Remove("setangle" .. self:EntIndex())

        self:StopSound("elberrsound/minirobot/elbite_roamloop.wav")

        self:StopSound("elberrsound/minirobot/elbites_alerted_movingLOOP.wav")

        self:EmitSound("elberrsound/minirobot/elbite_shutdown.ogg")
        end

        self:FreezeBOT(true)

        local shutdownanim = self:LookupSequence("shutdown")
        self:ResetSequence(shutdownanim)
        self:SetCycle(0)
        self:SetPlaybackRate(1)

        hook.Remove("PostDrawTranslucentRenderables", self.HookName)

        timer.Create("alotofsparks" .. self:EntIndex(), 0.1, 0, function()
            if not IsValid(self) then return end
            local sparks = EffectData()
            sparks:SetOrigin(self:GetPos() + Vector(0,0,20))
            sparks:SetNormal(VectorRand())
            util.Effect("MetalSpark", sparks)
        end)

        timer.Simple(5, function()
            if not IsValid(self) then return end
            timer.Remove("alotofsparks" .. self:EntIndex())
            local explosion = EffectData()
            explosion:SetOrigin(self:GetPos() + Vector(0,0,20))
            explosion:SetScale(2)
            util.Effect("Explosion", explosion)

            if SherlockHNS then
                local owner = self:GetOwner()
                if IsValid(owner) then
                    for _, target in ipairs(ents.FindInSphere(self:GetPos(), 200)) do
                        if target:IsPlayer() and target ~= owner then
                            SherlockHNS.Kill(target, owner, { reason = "robot", inflictor = self })
                        end
                    end
                end
            else
                util.BlastDamage(self, self, self:GetPos(), 200, 25)
            end

            net.Start("highlightelberrrobot")
            net.WriteEntity(self:GetNWEntity("TracedENT"))
            net.WriteEntity(self:GetOwner())
            net.WriteBool(false)
            net.Send(self:GetOwner())

            self:Remove()
        end)
    end
end

    print(health)

    self:SetNWInt("HealthB", health)
end

function ENT:OnRemove()
    self:StopSound("elberrsound/minirobot/elbite_roamloop.wav")

    self:StopSound("elberrsound/minirobot/elbites_alerted_movingLOOP.wav")

    if SERVER then    
        net.Start("highlightelberrrobot")
        net.WriteEntity(self:GetNWEntity("TracedENT"))
        net.WriteEntity(self:GetOwner())
        net.WriteBool(false)
        net.Send(self:GetOwner())
    end
end