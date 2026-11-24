local IsInThirdPerson = nil

hook.Add("OnEntityCreated", "elberr2pillpilliniitialize", function(ent)
    timer.Simple(0.00, function()
        if !IsValid(ent) then return end
        if ent:GetClass() == "pill_ent_costume" then
            if not ent then return end
            if ent.formTable then
                local PuppetEntity = ent:GetPuppet()
                local entityply = ent:GetPillUser()
                local hookName = "ThinkHookForEntity_HR_" .. ent:EntIndex()

                if ent.formTable.elberr2_initialize then
                    hook.Add("Think", hookName, function()
                        if not IsValid(ent) then
                            hook.Remove("Think", hookName)
                            return
                        end

                        local ply = ent:GetPillUser()
                        local puppet = ent:GetPuppet()

                        if not IsValid(puppet) or not IsValid(ply) then
                            hook.Remove("Think", hookName)
                            return
                        end

                        ent.formTable.elberr2_initialize(ply, ent)
                    end)
                end

                if ent.formTable.elberr2_custom_function then
                    ent.formTable.elberr2_custom_function(entityply, ent)
                end


                if ent.formTable.michael_elberr2_initialize then

                    local tablevarable = {["player"] = entityply, ["entity"] = ent, ["puppet"] = PuppetEntity}
                    timer.Simple(0.1, function()
                        if !IsValid(ent) then return end
                        ent.formTable:michael_elberr2_initialize(tablevarable,tablevarable,tablevarable,ply,ent)


                        local self = ent
                        self.formTable = pk_pills.getPillTable(self:GetPillForm())
                        local ply = self:GetPillUser()

                        if not self.formTable or not IsValid(ply) then
                            self:Remove()

                            return
                        end
                        local hull = self.formTable.hull or Vector(32, 32, 72)
                        local duckBy = self.formTable.duckBy or (self.formTable.hull and 0 or 36)
                        ply:SetHull(-Vector(hull.x / 2, hull.y / 2, 0), Vector(hull.x / 2, hull.y / 2, hull.z))
                        ply:SetHullDuck(-Vector(hull.x / 2, hull.y / 2, 0), Vector(hull.x / 2, hull.y / 2, hull.z - duckBy or 0))--
                        ply:SetRenderMode(RENDERMODE_NONE)
                        pk_pills.mapEnt(ply, nil)

                        if SERVER then
                            if ply:FlashlightIsOn() then
                                ply:Flashlight(false)
                            end

                            ply:Freeze(false)
                            ply:SetNotSolid(false)
                            ply:DrawViewModel(false)

                            local camOffset = Vector(0, 0, 20) --self.formTable.camera and self.formTable.camera.offset or 
                            --clside this?
                            ply:SetStepSize(hull.z / 4)
                            ply:SetViewOffset(camOffset)
                            ply:SetViewOffsetDucked(camOffset - Vector(0, 0, duckBy*0.15) )
                            self:ApplyMoveSpeed()
                        end
                        pk_pills.mapEnt(ply, self)

                    end)

                    local self = ent
                    ent.Think = function()
                        local currentanim = 'idle'
                        local ply = self:GetPillUser()
                        local puppet = self:GetPuppet()
                        if not IsValid(puppet) or not IsValid(ply) then return end
                        local vel = ply:GetVelocity():Length()

                        if CLIENT then    
                            if pk_pills.convars.cl_thirdperson:GetBool() then
                                self:SetNWBool("elberr2thirdperson", true)
                            else
                                self:SetNWBool("elberr2thirdperson", false)
                            end
                        end

                        if SERVER then
                            --Anims
                            local anims = table.Copy(self.formTable.anims.default or {})
                            table.Merge(anims, (IsValid(ply:GetActiveWeapon()) and self.formTable.anims[ply:GetActiveWeapon():GetHoldType()]) or (self.forceAnimSet and self.formTable.anims[self.forceAnimSet]) or {})
                            local anim
                            --local useSeqVel=true
                            local overrideRate

                            if (not self.anim or not anims[self.anim]) then
                                self.animFreeze = nil
                                self.animStart = nil
                            end

                            if self.animFreeze and not self.plyFrozen then
                                self:ApplyMoveSpeed()
                                self.plyFrozen = true
                            elseif not self.animFreeze and self.plyFrozen then
                                self:ApplyMoveSpeed()
                                self.plyFrozen = nil
                            end

                            if self.anim and anims[self.anim] then
                                anim = anims[self.anim]
                                overrideRate = anims[self.anim .. "_rate"] or 1
                                local cycle = puppet:GetCycle()

                                if not self.animStart then
                                    if cycle == 1 or (self.animCycle and self.animCycle > cycle) or (string.lower(anim) ~= string.lower(puppet:GetSequenceName(puppet:GetSequence()))) then
                                        self.anim = nil
                                        self.animCycle = nil

                                        if self.animFreeze then
                                            self.animFreeze = nil
                                        end
                                    elseif self.animCycle then
                                        self.animCycle = cycle
                                    end
                                end
                            elseif self.tickAnim and anims[self.tickAnim] then
                                anim = anims[self.tickAnim]
                                overrideRate = anims[self.tickAnim .. "_rate"] or 1
                                self.tickAnim = nil
                            elseif self.burrowed then
                                anim = anims["burrow_loop"]
                            elseif ply:WaterLevel() > 2 then
                                anim = anims["swim"] or anims["glide"] or anims["idle"]
                            elseif ply:IsOnGround() then
                                if ply:Crouching() then
                                    if vel > ply:GetCrouchedWalkSpeed() / 4 then
                                        anim = anims["crouch_walk"] or anims["crouch"] or anims["walk"] or anims["idle"]
                                    else
                                        anim = anims["crouch"] or anims["idle"]
                                    end
                                else
                                    if vel > (ply:GetWalkSpeed() + ply:GetRunSpeed()) / 2 then
                                        anim = anims["run"] or anims["walk"] or anims["idle"]
                                    elseif vel > ply:GetWalkSpeed() / 4 then
                                        anim = anims["walk"] or anims["idle"]
                                    else
                                        anim = anims["idle"]
                                    end
                                end
                            else
                                anim = anims["glide"] or anims["idle"]
                            end

                            if anim == anims["idle"] or anim == anims["crouch"] then
                                overrideRate = 1
                            end
                            self:SetNWString("Animlastplayed", anim)

                            local ShouldAlternate = table.Copy(self.formTable.anims.ShouldAlternate or {})
                            if type(ShouldAlternate[anim]) == "function" and ShouldAlternate[anim](self) then
                                if ShouldAlternate[anim](self) ~= nil and isstring(ShouldAlternate[anim](self)) then
                                    
                                    anim = ShouldAlternate[anim](self)
                                end
                            end

                            if (anim and puppet:GetSequence() ~= puppet:LookupSequence(anim)) or self.animStart or (self.formTable.autoRestartAnims and puppet:GetCycle() == 1) then
                                puppet:ResetSequence(puppet:LookupSequence(anim))
                                puppet:SetCycle(0)
                                self.animCycle = 0
                            end

                            self.animStart = nil
                            local seq_vel = puppet:GetSequenceGroundSpeed(puppet:GetSequence())

                            --if true then
                            if self.formTable.movePoseMode ~= "xy" and self.formTable.movePoseMode ~= "xy-bot" and not overrideRate then
                                local rate = overrideRate or vel / seq_vel

                                --goofy limitation (floods console with errors if above 12!)
                                if rate > 12 then
                                    rate = 12
                                end

                                puppet:SetPlaybackRate(rate)
                            else
                                --puppet:SetPlaybackRate(1)
                            end

                            --print(puppet:GetCycle())
                            if self.formTable.movePoseMode then
                                --
                                if self.formTable.movePoseMode == "yaw" then
                                    local move_dir = puppet:WorldToLocalAngles(ply:GetVelocity():Angle())
                                    puppet:SetPoseParameter("move_yaw", move_dir.y)
                                elseif self.formTable.movePoseMode == "xy" then
                                    if not overrideRate then
                                        local localvel = ply:WorldToLocal(ply:GetPos() + ply:GetVelocity())
                                        local maxdim = math.Max(math.abs(localvel.x), math.abs(localvel.y))
                                        local clampedvel = maxdim == 0 and Vector(0, 0, 0) or localvel / maxdim
                                        puppet:SetPoseParameter("move_x", clampedvel.x)
                                        puppet:SetPoseParameter("move_y", -clampedvel.y)
                                        seq_vel = puppet:GetSequenceGroundSpeed(puppet:GetSequence())

                                        if seq_vel ~= 0 then
                                            puppet:SetPoseParameter("move_x", math.Clamp(localvel.x / seq_vel, -.99, .99))
                                            puppet:SetPoseParameter("move_y", math.Clamp(-localvel.y / seq_vel, -.99, .99))
                                        end
                                        --print(puppet:GetPlaybackRate())
                                    else
                                        puppet:SetPoseParameter("move_x", 0)
                                        puppet:SetPoseParameter("move_y", 0)
                                    end
                                elseif self.formTable.movePoseMode == "xy-bot" then
                                    if not overrideRate then
                                        local localvel = ply:WorldToLocal(ply:GetPos() + ply:GetVelocity())
                                        local maxdim = math.Max(math.abs(localvel.x), math.abs(localvel.y))
                                        local clampedvel = maxdim == 0 and Vector(0, 0, 0) or localvel / maxdim
                                        local move_dir = puppet:WorldToLocalAngles(ply:GetVelocity():Angle())
                                        puppet:SetPoseParameter("move_x", clampedvel.x)
                                        puppet:SetPoseParameter("move_y", -clampedvel.y)
                                        puppet:SetPoseParameter("move_yaw", move_dir.y)
                                        puppet:SetPoseParameter("move_scale", 1)
                                        seq_vel = puppet:GetSequenceGroundSpeed(puppet:GetSequence())

                                        if seq_vel ~= 0 then
                                            puppet:SetPoseParameter("move_x", math.Clamp(localvel.x / seq_vel, -.99, .99))
                                            puppet:SetPoseParameter("move_y", math.Clamp(-localvel.y / seq_vel, -.99, .99))
                                            puppet:SetPoseParameter("move_scale", math.Clamp(localvel:Length() / seq_vel, -.99, .99))
                                        end
                                        --print(puppet:GetPlaybackRate())
                                    else
                                        puppet:SetPoseParameter("move_x", 0)
                                        puppet:SetPoseParameter("move_y", 0)
                                        puppet:SetPoseParameter("move_yaw", 0)
                                        puppet:SetPoseParameter("move_scale", 0)
                                    end
                                end
                            end

                            --Aimage
                            if self.formTable.aim then
                                if self.formTable.aim.xPose then
                                    local yaw = math.AngleDifference(ply:EyeAngles().y, puppet:GetAngles().y)

                                    if self.formTable.aim.xInvert then
                                        yaw = -yaw
                                    end

                                    puppet:SetPoseParameter(self.formTable.aim.xPose, yaw)
                                end

                                if self.formTable.aim.yPose then
                                    local pitch = math.AngleDifference(ply:EyeAngles().p, puppet:GetAngles().p)

                                    if self.formTable.aim.yInvert then
                                        pitch = -pitch
                                    end

                                    puppet:SetPoseParameter(self.formTable.aim.yPose, pitch)
                                end
                            end

                            --gliding and landing
                            if not ply:IsOnGround() and ply:WaterLevel() == 0 and self.formTable.glideThink then
                                self.formTable.glideThink(ply, self)
                            end

                            if not ply:IsOnGround() and not self.touchingWater and ply:WaterLevel() > 0 and self.formTable.land then
                                self.formTable.land(ply, self)
                            end

                            --tick attack
                            if ply:KeyDown(IN_ATTACK) and self.formTable.attack and self.formTable.attack.mode == "tick" then
                                self.formTable.attack.func(ply, self, self.formTable.attack)
                            end

                            if ply:KeyDown(IN_ATTACK2) and self.formTable.attack2 and self.formTable.attack2.mode == "tick" then
                                self.formTable.attack2.func(ply, self, self.formTable.attack2)
                            end

                            --auto attack
                            if ply:KeyDown(IN_ATTACK) and self.formTable.attack and self.formTable.attack.mode == "auto" then
                                if not self.formTable.aim then
                                    self:PillLoopSound("attack")
                                else
                                    self:PillLoopStop("attack")
                                end

                                if (not self.lastAttack or (self.formTable.attack.interval or self.formTable.attack.delay) < CurTime() - self.lastAttack) then
                                    self.formTable.attack.func(ply, self, self.formTable.attack)
                                    self.lastAttack = CurTime()
                                end
                            else
                                self:PillLoopStop("attack")
                            end

                            if ply:KeyDown(IN_ATTACK2) and self.formTable.attack2 and self.formTable.attack2.mode == "auto" then
                                if not self.formTable.aim then
                                    self:PillLoopSound("attack2")
                                else
                                    self:PillLoopStop("attack2")
                                end

                                if not self.lastAttack2 or (self.formTable.attack2.interval or self.formTable.attack2.delay) < CurTime() - self.lastAttack2 then
                                    self.formTable.attack2.func(ply, self, self.formTable.attack2)
                                    self.lastAttack2 = CurTime()
                                end
                            else
                                self:PillLoopStop("attack2")
                            end

                            --if !IsValid(ply) then self:NextThink(CurTime()) return true end
                            --wepon-no longer SO hackey
                            if not self.formTable.hideWeapons then
                                local realWep = self:GetPillUser():GetActiveWeapon()

                                --&&self:GetPillUser()!=ply or pk_pills.var_thirdperson:GetBool()) then
                                if IsValid(realWep) and realWep:GetModel() ~= "" then
                                    --hiding the real thing [BROKEN]
                                    --[[if realWep:GetRenderMode()!=RENDERMODE_NONE then
                                        realWep:SetRenderMode(RENDERMODE_NONE)
                                    end]]
                                    if realWep.pill_attachment then
                                        if IsValid(self.wepmdl) then
                                            self.wepmdl:Remove()
                                        end

                                        self.wepmdl = ents.Create("pill_attachment_wep")
                                        self.wepmdl:SetParent(self:GetPuppet())
                                        self.wepmdl:SetModel(realWep:GetModel())
                                        self.wepmdl.attachment = realWep.pill_attachment
                                        self.wepmdl:Spawn()

                                        if realWep.pill_offset then
                                            self.wepmdl:SetWepOffset(realWep.pill_offset)
                                        end

                                        if realWep.pill_angle then
                                            self.wepmdl:SetWepAng(realWep.pill_angle)
                                        end

                                        realWep.pill_proxy = self.wepmdl
                                    elseif not IsValid(self.wepmdl) then
                                        self.wepmdl = ents.Create("pill_attachment_wep")
                                        self.wepmdl:SetParent(self:GetPuppet())
                                        self.wepmdl:SetModel(realWep:GetModel())
                                        self.wepmdl:Spawn()
                                        realWep.pill_proxy = self.wepmdl
                                    elseif self.wepmdl:GetModel() ~= realWep:GetModel() then
                                        self.wepmdl:SetModel(realWep:GetModel())
                                    end
                                elseif IsValid(self.wepmdl) then
                                    self.wepmdl:Remove()
                                end
                            end
                        else  
                            if self:GetPillUser() ~= LocalPlayer() or pk_pills.convars.cl_thirdperson:GetBool() then
                                puppet:SetNoDraw(false)
                            else
                                puppet:SetNoDraw(false)
                            end

                            local realWep = self:GetPillUser():GetActiveWeapon()

                            if IsValid(realWep) and realWep:GetModel() ~= "" and not realWep:GetNoDraw() then
                                realWep:SetNoDraw(true)
                            end
                        end

                        --Align pos and angles with player
                        if SERVER then
                            puppet:SetPos(ply:GetPos())
                        else
                            puppet:SetRenderOrigin(ply:GetPos())
                        end
                        
                        currentanim = self:GetNWString("Animlastplayed")

                        if vel > 0 or math.abs(math.AngleDifference(puppet:GetAngles().y, ply:EyeAngles().y)) > 350 then
                        
                        local animsshouldspn = table.Copy(self.formTable.anims.ShouldMoveRotate or {})
                        if animsshouldspn[currentanim] or (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) then
                            
                            local typeofitem = (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) or animsshouldspn[currentanim]
                            local function SetTargetAngle(ang)
                                ang.p = 0
                                puppet:SetNW2Vector("SyncAng", ang:Forward())
                            end

                            local function GetTargetAngle()
                                local dir = puppet:GetNW2Vector("SyncAng")
                                if not dir or dir == vector_origin then return nil end
                                local ang = dir:Angle()
                                if not ang then return nil end
                                ang.p = 0
                                return ang
                            end

                            if typeofitem == "notshftlock" then
                                local dir = ply:GetVelocity():GetNormalized()
                                local aheadPos = ply:GetPos() + dir * 5
                                local ang = (aheadPos - ply:GetPos()):Angle()
                                ang.p = 0

                                if SERVER then
                                    SetTargetAngle(ang)
                                    puppet:SetAngles(ang)
                                end

                                if CLIENT then
                                    local targetAng = GetTargetAngle()
                                    if targetAng then
                                        local curAng = puppet:GetRenderAngles()
                                        if not curAng then curAng = targetAng end
                                        if not curAng.p then curAng = Angle(0,0,0) end
                                        local smoothAng = LerpAngle(FrameTime() * 10, curAng, targetAng)
                                        puppet:SetRenderAngles(smoothAng)
                                    end
                                end
                            elseif typeofitem == "assignedagnles_instant" then
                                local targetAng = self:GetNWAngle("pill_assignedangle")

                                if SERVER then
                                    SetTargetAngle(targetAng)
                                    puppet:SetAngles(targetAng)
                                end

                                if CLIENT then
                                    if targetAng then
                                        puppet:SetRenderAngles(targetAng)
                                    end
                                end

                            elseif typeofitem == "shiftlock" then
                                local angs = ply:EyeAngles()
                                angs.p = 0

                                if SERVER then
                                    SetTargetAngle(angs)
                                    puppet:SetAngles(angs)
                                end

                                if CLIENT then
                                    local targetAng = GetTargetAngle()
                                    if targetAng then
                                        local curAng = puppet:GetRenderAngles()
                                        if not curAng then curAng = targetAng end
                                        if not curAng.p then curAng = Angle(0,0,0) end
                                        local smoothAng = LerpAngle(FrameTime() * 10, curAng, targetAng)
                                        puppet:SetRenderAngles(smoothAng)
                                    end
                                end

                            elseif typeofitem == "Playerangles" then
                                local angs = ply:GetAngles()
                                angs.p = 0

                                if SERVER then
                                    SetTargetAngle(angs)
                                    puppet:SetAngles(angs)
                                end

                                if CLIENT then
                                    local targetAng = GetTargetAngle()
                                    if targetAng then
                                        local curAng = puppet:GetRenderAngles()
                                        if not curAng then curAng = targetAng end
                                        if not curAng.p then curAng = Angle(0,0,0) end
                                        local smoothAng = LerpAngle(FrameTime() * 10, curAng, targetAng)
                                        puppet:SetRenderAngles(smoothAng)
                                    end
                                end

                            elseif typeofitem == "assignedagnles" then
                                local targetAng = self:GetNWAngle("pill_assignedangle")

                                if SERVER then
                                    SetTargetAngle(targetAng)
                                    puppet:SetAngles(targetAng)
                                end

                                if CLIENT then
                                    if targetAng then
                                        local curAng = puppet:GetRenderAngles()
                                        if not curAng then curAng = targetAng end
                                        if not curAng.p then curAng = Angle(0,0,0) end
                                        local smoothAng = LerpAngle(FrameTime() * 10, curAng, targetAng)
                                        puppet:SetRenderAngles(smoothAng)
                                    end
                                end

                            elseif typeofitem == "notanything" then
                            end
                        return
                    end

                        self:NextThink(CurTime())

                        return true
                    end
                    end
                end
                if ent.formTable.HandleAnimEvent_ELBERR2_pill then
                    local PuppetEntity = ent:GetPuppet()
                    local entityply = ent:GetPillUser()

                    if IsValid(PuppetEntity) then
                        function PuppetEntity:AcceptInput(inputName, activator, caller, data)
                            ent.formTable.HandleAnimEvent_ELBERR2_pill(entityply, ent, inputName)
                            return true
                        end
                    end
                end
            end
        end
    end)
end)


    hook.Add("CalcView", "momo_calcview", function(ply, pos, ang, fov)
        local ent = pk_pills.getMappedEnt(LocalPlayer())

        if IsValid(ent) and ply:GetViewEntity() == ply then
            local startpos

            if ent.formTable.type == "phys" then
                startpos = ent:LocalToWorld(ent.formTable.camera and ent.formTable.camera.offset or Vector(0, 0, 0))
            else
                startpos = pos
            end

            if pk_pills.convars.cl_thirdperson:GetBool() then

                if ent.formTable.ThirdPersonBone then

                    if IsValid(ent:GetPuppet()) then
                        local bonename = ent.formTable.ThirdPersonBone[1]
                        local boneID = ent:GetPuppet():LookupBone(bonename)
                        local bonePos, boneAng = ent:GetPuppet():GetBonePosition(boneID)

                        local dist

                        if ent.formTable.type == "phys" and ent.formTable.camera and ent.formTable.camera.distFromSize then
                            dist = ent:BoundingRadius() * 5
                        else
                            dist = ent.formTable.camera and ent.formTable.camera.dist or 100
                        end
                        local startpos = bonePos + LocalPlayer():GetForward() * (ent.formTable.ThirdPersonBone[2]) + LocalPlayer():GetUp() * (ent.formTable.ThirdPersonBone[4])+ LocalPlayer():GetRight() * (ent.formTable.ThirdPersonBone[3])
                        local underslung = ent.formTable.camera and ent.formTable.camera.underslung
                        local offset = LocalToWorld(Vector(-dist, 0, underslung and -dist / 5 or dist / 5), Angle(0, 0, 0), Vector(0, 0, 0), ang)

                        local tr = util.TraceHull({
                            start = startpos,
                            endpos = startpos + offset,
                            filter = ent.camTraceFilter,
                            mins = Vector(-5, -5, -5),
                            maxs = Vector(5, 5, 5),
                            mask = MASK_VISIBLE
                        })

                        local view = {}
                        view.origin = tr.HitPos
                        view.angles = ang
                        view.fov = fov
                        view.drawviewer = true

                        return view
                    end
                end

                local dist

                if ent.formTable.type == "phys" and ent.formTable.camera and ent.formTable.camera.distFromSize then
                    dist = ent:BoundingRadius() * 5
                else
                    dist = ent.formTable.camera and ent.formTable.camera.dist or 100
                end

                local underslung = ent.formTable.camera and ent.formTable.camera.underslung
                local offset = LocalToWorld(Vector(-dist, 0, underslung and -dist / 5 or dist / 5), Angle(0, 0, 0), Vector(0, 0, 0), ang)

                local tr = util.TraceHull({
                    start = startpos,
                    endpos = startpos + offset,
                    filter = ent.camTraceFilter,
                    mins = Vector(-5, -5, -5),
                    maxs = Vector(5, 5, 5),
                    mask = MASK_VISIBLE
                })

                local view = {}
                view.origin = tr.HitPos
                view.angles = ang
                view.fov = fov
                view.drawviewer = true

                return view
            else
                if ent.formTable.FirstPersonBone then
                    if IsValid(ent:GetPuppet()) then
                        local bonename = ent.formTable.FirstPersonBone[1]
                        local boneID = ent:GetPuppet():LookupBone(bonename)
                        local bonePos, boneAng = ent:GetPuppet():GetBonePosition(boneID)
                        local view = {}
                        view.origin = bonePos + LocalPlayer():GetForward() * (ent.formTable.FirstPersonBone[2]) + LocalPlayer():GetUp() * (ent.formTable.FirstPersonBone[4])+ LocalPlayer():GetRight() * (ent.formTable.FirstPersonBone[3])
                        view.angles = ang
                        view.fov = fov
                        view.drawviewer = false
                        return view
                    end
                end
            end
        end
    end)


hook.Add("PlayerButtonDown", "elberrTability", function(ply, button)
    local pill = ply.pk_pill_ent
    if IsValid(pill) then
        if pill.formTable.ELBERR2KeyBind then
            pill.formTable.ELBERR2KeyBind(ply, pill, button)
        end
    end
end)


if SERVER then
	AddCSLuaFile()
    util.AddNetworkString("makeragdollinvisduringjumpcam")
    util.AddNetworkString("changecamposelberr2")
    util.AddNetworkString("highlightelberrrobot")
    util.AddNetworkString("abiliconscooldownselberr2")
    util.AddNetworkString("killredscreenelberr")
    util.AddNetworkString("elberr2_thirdpersonsync")
end

local robots = {}

pk_pills.packStart("MY SELF AWARE ROBOT","MY SELF AWARE ROBOT","icon/Q_menu_icon.png")

pk_pills.register("pill_elberr2",{

    printName="BIG E.L.B.E.R.R",
	
    model="models/whynotboi/pills/elberr2/elberr2.mdl",
	
	modelScale="0.8",

    muteSteps = true,
	
    anims={
        default={
            idle="idle",
			run="run",
            walk="walk",
			attack="idle",
			jumpscare="kill",
            crouch="idle",
            crouch_walk="walk",
            charge="charge",
            chargeHW="charge_hitwall",
            chargeKW="charge_killwall",
            chargemiss="charge_miss",
            chargestart="charge_start",
            chargeTH="charge_throw",
        },

        ShouldMoveRotate={
            idle= function(ent)
                return 'notshftlock'
            end,

            run= function(ent) 
                return 'notshftlock'
            end,
            
            walk= function(ent)
                return 'notshftlock'
            end,

            missattack= function(ent) 
                return 'notshftlock'
            end,
            crouch= function(ent)
                return 'notshftlock'
            end,
            jumpscare= function(ent)
                return 'notshftlock'
            end,
            cwalk= function(ent)
                return 'notshftlock'
            end,
            charge= function(ent)
                return 'notshftlock'
            end,


        },

        
    },
	
    moveSpeed={
        walk=125,
        run=580 ,
        ducked=100,
    },
	
    sounds={
        chargehit = "elberrsound/elberr/BBELBERR_chargehit.ogg",
        charge = "elberrsound/elberr/BBELBERR_chargewarning.ogg",
        chargekill = "elberrsound/elberr/BBELBERR_chargewallslam.ogg",
        chargemiss = "elberrsound/elberr/BBELBERR_chargemiss.ogg",
        chargekillwall = "elberrsound/elberr/BBELBERR_chargewallslam.ogg",
        jumpscare = "elberrsound/elberr/BBELBERR_killanim.ogg",
    },

    FirstPersonBone = {
        'eye.R',
        10,
        0,
        0,
    },
   ThirdPersonBone = {
       'spine',
        0,
        25,
        0,
    },
	

    type="ply",

    camera={
        dist=200
    },
	
    jumpPower=0,
	
    health=250000,
	
	movePoseMode="xy",
		aim={
		xPose="aim_yaw",
		yPose="aim_pitch",
		nocrosshair = true
	},
	
	canAim=function(ply,ent)
		return ent.active
	end,

    elberr2_initialize = function(ply, ent)
    end,

    michael_elberr2_initialize = function(initializetable,initializetable2,initializetable3,ply,ent)
    end,

    HandleAnimEvent_ELBERR2_pill = function(ply, ent, event)
        if event == "ELB.EVENT.STEP" then
            if SERVER then
            util.ScreenShake(ply:GetPos(), 5, 5, 1, 100)
            end
        end
    end,

    elberr2_custom_function = function(ply, ent)
        local hookName = "disablefootstep" .. ent:EntIndex()
        local puppet = ent:GetPuppet()
        local hookName2 = "breakdoor" .. ent:EntIndex()
        local MAINidle = CreateSound(ent, "elberrsound/elberr/BBELBERR_idleLOOP.wav")
        local idle2 = CreateSound(ent, "elberrsound/elberr/BBELBERR_idle_droneLOOP.wav")
        MAINidle:Play()
        idle2:Play()

if CLIENT then    
    hook.Add("Think", "shiftlockfirstperson" .. ent:EntIndex(), function()
        if not IsValid(ent) then
            hook.Remove("Think", "shiftlockfirstperson" .. ent:EntIndex())
            return
        end

        if not ent:GetNWBool("elberr2thirdperson") then
            local eang = LocalPlayer():EyeAngles()
            puppet:SetRenderAngles(Angle(0, eang.y, 0))
        end
    end)
end

if SERVER then
        hook.Add("Think", hookName2, function()
            for _, door in ipairs(ents.FindInSphere(ply:GetPos(), 90)) do
                if door:GetClass() == "prop_door_rotating" or door:GetClass() == "func_door_rotating" then
                if not ent.CreatedDoor then
                if ply:GetVelocity():Length() < 550 then return end    
                    ent.CreatedDoor = true  
                    
                    local NEWdoor = ents.Create("prop_physics")
                    NEWdoor:SetModel(door:GetModel())
                    NEWdoor:SetSkin(door:GetSkin())
                    NEWdoor:SetPos(door:GetPos())
                    NEWdoor:SetAngles(door:GetAngles())
                    NEWdoor:Spawn()

                    local phys = NEWdoor:GetPhysicsObject()

                    local effectdata = EffectData()
                    effectdata:SetOrigin(door:GetPos())
                    util.Effect("MetalSpark", effectdata)

                    if IsValid(phys) then
                        local dir = ply:GetForward()
                        local speed = math.random(200,400)
                        phys:SetVelocity(dir * speed)
                    end

                    for i = 0, door:GetNumBodyGroups() - 1 do
                        NEWdoor:SetBodygroup(i, door:GetBodygroup(i))
                    end

                    door:EmitSound("physics/wood/wood_crate_break3.wav")

                    door:Remove()

                    ent.CreatedDoor = false
                end
            end
        end
    end)
end

        hook.Add("PlayerFootstep", hookName, function(ply2, pos, foot, sound, volume, filter)
            if ply2 == ply then
                return true
            end
        end)

        hook.Add("SetupPlayerVisibility", "VisibilityHandler", function()
			for i,plr in ipairs(player.GetAll()) do
				AddOriginToPVS(plr:GetPos())
			end
		end)

        ent:CallOnRemove("removefootstephook" .. ent:EntIndex(), function()

        if SERVER then    
            for _, robot in ipairs(ents.FindByClass("elberrr_minirobot")) do
                if IsValid(robot) then
                    robot:Remove()
                end
            end
        end

        hook.Remove("Think", "shiftlockfirstperson" .. ent:EntIndex())


            hook.Remove("PlayerFootstep", hookName)
            hook.Remove("Think", hookName2)
            MAINidle:Stop()
            idle2:Stop()
        end)
    end,
ELBERR2KeyBind = function(ply, ent, button)
    if button == KEY_T then
    if not SERVER then return end
    if ply.CreatedBotCD then return end
    if #robots == 7 then return end
    ply.CreatedBotCD = true

        net.Start("abiliconscooldownselberr2")
        net.WriteString("RobotCD")
        net.Send(ply)

    timer.Simple(5, function()
        ply.CreatedBotCD = false
    end)

        local robot = ents.Create("elberrr_minirobot")
        robot:SetPos(ply:GetPos() + Vector(0,0,50) + ply:GetForward() * 100)
        robot:SetOwner(ply)
        robot:Spawn()

        table.insert(robots, robot)
    end

    ent:CallOnRemove("resettable", function()
        robots = {}
    end)
end,


    attack = {
        mode = 'trigger',
            func = function(ply, ent)
            if ent.ActivatedRelberr then return end
            local ratio = 0.3
            local entity = nil
            local puppet = ent:GetPuppet()
            local ragdoll = nil

            local attachmentID = puppet:LookupAttachment("camera")
            local attachment = puppet:GetAttachment(attachmentID)

            local targetOrigin = ent:LocalToWorld(Vector(0, 0, 50))
if SherlockHNS then
    entity = SherlockHNS.FindVictim(ply, targetOrigin, 90, {
        filter = function(v)
        if v:GetClass() == "elberrr_minirobot" then return false end
            local trace = util.TraceLine({
                start = ent:EyePos(),
                endpos = v:EyePos(),
                filter = {ent, ply},
                mask = MASK_VISIBLE
            })
            return not trace.Hit
        end,
    })
else
for k, v in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 90)) do
                if v:IsPlayer() or v:IsNextBot() or v:IsNPC() then
                    if v == ent or v == ply then continue end
                    if v:GetClass() == "elberrr_minirobot" then continue end

                    if (v:IsPlayer() and v:Team() ~= TEAM_SPECTATOR) or (v:IsNPC() or v:IsNextBot()) and v:Health() > 0 then

                    local trace = util.TraceLine({start = ent:EyePos(), endpos = v:EyePos(), filter = {ent, ply}, mask = MASK_VISIBLE})

                    if not trace.Hit then
                        entity = v
                        break
                    end
                end
            end
        end
end

if SherlockHNS and IsValid(entity) and entity:IsPlayer() then
            return pk_pills.playHNSJumpscare(ply, ent, entity, 4, {
                camera = "makeragdollinvisduringjumpcam",
                offset = 50,
                animation = "jumpscare",
                sound = "jumpscare",
            })
        end

        if IsValid(entity) then
            local pill = ent:GetPuppet()

        timer.Simple(0.3, function()   
            ragdoll = ents.Create("prop_ragdoll")
            if not IsValid(ragdoll) then return end

            ragdoll:SetModel(entity:GetModel())
            ragdoll:SetPos(ply:GetPos())
            ragdoll:SetCollisionGroup(COLLISION_GROUP_WORLD)
            ragdoll:Spawn()
            ragdoll:Activate()

            timer.Simple(0.3, function()
                if not IsValid(ragdoll) or not IsValid(entity) then return end

                net.Start("makeragdollinvisduringjumpcam")
                net.WriteEntity(ragdoll)
                net.Send(entity)
            end)



            local headpos = nil

            for i = 0, ragdoll:GetPhysicsObjectCount() -1 do
                local phys = ragdoll:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    local boneIndex = ragdoll:TranslatePhysBoneToBone(i)
                    local boneName = ragdoll:GetBoneName(boneIndex) or ""
                    if string.find(string.lower(boneName), "head") then
                        headpos = phys
                        break
                    end
                end
            end

            timer.Create("setpos", 0.01, 0, function()
                if not IsValid(ragdoll) or not IsValid(headpos) then 
                    timer.Remove("setpos")
                    return 
                end

                local attachmentID = puppet:LookupAttachment("camera")
                local attach = puppet:GetAttachment(attachmentID)
                if not attach then return end

                headpos:SetPos(LerpVector(ratio, headpos:GetPos(), attach.Pos))
                headpos:SetAngles(LerpAngle(ratio, headpos:GetAngles(), attach.Ang))
            end)


        end)


            timer.Simple(4, function()
                timer.Remove("setpos")
                thisthatblahblahblah = false

                net.Start("makeragdollvisibleagainelbert")
                net.Send(entity)
            end)
            
            timer.Simple(2.5, function()
                print(ragdoll)
                local effectdata = EffectData()
                effectdata:SetOrigin(ragdoll:GetPos())
                effectdata:SetScale(50)
                effectdata:SetFlags(3)
                util.Effect("BloodImpact", effectdata, true, true)

                local headBone = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
                if headBone then
                    ragdoll:ManipulateBoneScale(headBone, Vector(0, 0, 0))
                end

                net.Start("killredscreenelberr")
                net.WriteBool(true)
                net.Send(entity)
            end)

            if entity:IsPlayer() then
                entity:SetNoDraw(true)
                entity:Freeze(true)
                entity:AddFlags(FL_NOTARGET)
                entity:DrawViewModel(false)
                entity:SetActiveWeapon(nil)

                net.Start('ELBERR2JUMPCAM')
                net.WriteEntity(pill)
                net.WriteBool(true)
                net.Send(entity)

            elseif entity:IsNPC() then
                entity:SetNoDraw(true)
                entity:SetNPCState(NPC_STATE_IDLE)
                entity:SetEnemy(nil)
            else
                entity:NextThink(CurTime())
                entity:TakeDamage(1e9, ply)
            end

            entity:SetPos(pill:GetPos() + pill:GetForward() * 50)
            ply:Freeze(true)

            ent:PillAnim('jumpscare')
            ent:PillSound('jumpscare')

            timer.Simple(4, function()
                if not (IsValid(entity) and IsValid(ent)) then return end

                ply:Freeze(false)

                if entity:IsPlayer() then
                    entity:Kill(ply)

                    net.Start('ELBERR2JUMPCAM')
                    net.WriteEntity(pill)
                    net.WriteBool(false)
                    net.Send(entity)

                    net.Start("killredscreenelberr")
                    net.WriteBool(false)
                    net.Send(entity)

                    ent.ActivatedRelberr = false

                    entity:RemoveFlags(FL_NOTARGET)
                    entity:Freeze(false)
                    entity:DrawViewModel(true)
                else

                    ent.ActivatedRelberr = false

                    entity:NextThink(CurTime())
                    entity:TakeDamage(1e9, ply)
                end
            end)
        else
        end

        timer.Simple(3, function()
            ply.OnHold = false
        end)

        ent:CallOnRemove("blahblahelbert", function()
        if IsValid(ragdoll) and IsValid(phys) then
           ragdoll:Remove()
        end
    end)

    end
},

attack2 = {
    mode = "trigger",
    func = function(ply, ent)
        ent:PillSound("chargemiss")
    end,
},




	

    noragdoll=true,
	
    reload=function(ply,ent)
        if ply.ChargeCD then return end
        ply.ChargeCD = true

        net.Start("abiliconscooldownselberr2")
        net.WriteString("ChargeUse")
        net.Send(ply)

        ent.ActivatedRelberr = true

        ent:PillAnim("chargestart")
        ent:PillSound("charge")
        local puppet = ent:GetPuppet()
        local ragdoll = nil
        local loopentity = nil
        local range = 180
        local headPos = nil
        ent.SpawnedRagdoll = false
        ent.CreatedTimer = false
        ent.HitWall = false

        timer.Simple(0.5, function()
            ent.formTable.anims.default.run = "charge"
            timer.Create("chargeelberr" .. ent:EntIndex(), 0.01, 0, function()

            local trace = util.TraceLine({
                start = ply:EyePos() + Vector(0,0,100),
                endpos = ply:EyePos() + Vector(0,0,100) + ply:GetForward() * range,
                filter = ply, ent, ragdoll
            })

            debugoverlay.Line(ply:GetForward() + Vector(0,0,100), ply:EyePos() + Vector(0,0,100) + ply:GetForward() * range, 0, Color(255,255,255))

            if trace.HitWorld and not ent.HitWall then
                ent.HitWall = true
                timer.Remove("chargeelberr" .. ent:EntIndex())
                timer.Remove("removetimers" .. ent:EntIndex())
                ply:Freeze(true)
                ent.formTable.anims.default.run = "run"

                if not ent.CreatedTimer then
                    ent:PillAnim("chargeHW")
                    ent:PillSound("chargehit")

                --print("cdhit")

                ent.ActivatedRelberr = false
                

                timer.Simple(15, function()
                    ply.ChargeCD = false
                end)

                net.Start("abiliconscooldownselberr2")
                net.WriteString("ChargeCD")
                net.Send(ply)

                else

                    range = 1
                if loopentity:Health() <= 75 then
                    ent:PillSound("chargekillwall")
                    ent:PillAnim("chargeKW")
                else
                    --print("chargehitanim")
                    ent:PillSound("chargeHW")
                    ent:PillAnim("chargehit")
                end

                    loopentity:SetPos(ply:GetPos())

                    net.Start('ELBERR2JUMPCAM')
                    net.WriteEntity(puppet)
                    net.WriteBool(true)
                    net.Send(loopentity)

                    timer.Simple(1.2, function()
                        timer.Remove("setragdollposition" .. ent:EntIndex())
                    end)

                if loopentity:Health() <= 75 then
                    
                    --print("ply kill")
                    
                    timer.Simple(3.5, function()
                        net.Start('ELBERR2JUMPCAM')
                        net.WriteEntity(puppet)
                        net.WriteBool(false)
                        net.Send(loopentity)

                    timer.Simple(0.1, function()
                        net.Start("changecamposelberr2")
                        net.WriteBool(false)
                        net.Send(loopentity)
                    end)

                        net.Start("abiliconscooldownselberr2")
                        net.WriteString("ChargeCD")
                        net.Send(ply)

                        loopentity:Freeze(false)

                        if loopentity:Health() <= 75 then
                            loopentity:Kill()
                            ragdoll:Remove()
                        else
                            
                            loopentity:TakeDamage(75, ply, ent)

                            timer.Simple(0.1, function()    
                                net.Start("changecamposelberr2")
                                net.WriteBool(false)
                                net.Send(loopentity)
                            end)


                            loopentity:SetPos(ragdoll:GetPos())
                            ragdoll:Remove()
                            loopentity:SetNoDraw(false)

                            local wep = loopentity:GetActiveWeapon()

                            if IsValid(wep) then
                                wep:SetNoDraw(false)
                            end
                        end

                        print("cdkill")
                        ent.ActivatedRelberr = false

                        timer.Simple(15, function()
                            ply.ChargeCD = false
                        end)

                    end)
                else
                    print("charge hit no kill ply")
                    ent.ActivatedRelberr = false
                    timer.Remove("sendheadpos" .. ent:EntIndex())
                    timer.Remove("setragdollposition" .. ent:EntIndex())

                    loopentity:Freeze(true)
                    loopentity:SetNoDraw(false)

                    local wep = loopentity:GetActiveWeapon()

                    if IsValid(wep) then
                        wep:SetNoDraw(false)
                    end

                    local dmg = DamageInfo()
                    dmg:SetDamage(50)
                    dmg:SetAttacker(ply)
                    dmg:SetInflictor(ent)
                    dmg:SetDamageType(DMG_DIRECT)

                    loopentity:TakeDamageInfo(dmg)

                    timer.Simple(15, function()
                        ply.ChargeCD = false
                    end)

                    ent:PillSound("chargehit")
                    ent:PillAnim("chargeHW")

                    net.Start("abiliconscooldownselberr2")
                    net.WriteString("ChargeCD")
                    net.Send(ply)

                timer.Simple(2, function()
                    ragdoll:Remove()
                    loopentity:Freeze(false)
                    timer.Simple(0.1, function()
                        --print(loopentity)

                        net.Start("changecamposelberr2")
                        net.WriteBool(false)
                        net.Send(loopentity)
                    end)
                end)

                    timer.Simple(0.1, function()
                        net.Start('ELBERR2JUMPCAM')
                        net.WriteEntity(puppet)
                        net.WriteBool(false)
                        net.Send(loopentity)
                    end)
                end
            end

                timer.Simple(0.67, function()
                    ply:Freeze(false)
                end)
            end

            for _, v in ipairs(ents.FindInSphere(ply:GetPos(), 100)) do
                    if v == ply then continue end
                    if v:IsPlayer() and v:Alive() then
                    if v:Team() == TEAM_SPECTATOR then continue end
                    if not ent.SpawnedRagdoll then
                        ent.SpawnedRagdoll = true
                        ragdoll = ents.Create("prop_ragdoll")
                        ragdoll:SetModel(v:GetModel())
                        ragdoll:SetMoveType(MOVETYPE_NONE)
                        ragdoll:SetCollisionGroup(COLLISION_GROUP_WORLD)
                        ragdoll:SetPos(ply:GetPos())
                        ragdoll:Spawn()

                        loopentity = v

                        for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
                            local phys = ragdoll:GetPhysicsObjectNum(i)

                            if IsValid(phys) then
                                phys:EnableDrag(false)
                            end
                        end

                        for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
                            local phys = ragdoll:GetPhysicsObjectNum(i)
                            if IsValid(phys) then
                                local boneIndex = ragdoll:TranslatePhysBoneToBone(i)
                                local boneName = ragdoll:GetBoneName(boneIndex) or ""
                                if string.find(string.lower(boneName), "head") then
                                    headPos = phys
                                    break
                                end
                            end
                        end

                    end
                       --print("player detected")
                    if not ent.CreatedTimer then
                       ent.CreatedTimer = true
                       v:Freeze(true)
                       v:SetNoDraw(true)

                       local wep = v:GetActiveWeapon()

                       if IsValid(wep) then
                          wep:SetNoDraw(true)
                       end

                        timer.Create("sendheadpos" .. ent:EntIndex(), 0.01, 0, function()
                            if IsValid(ragdoll) then
                                local boneID = puppet:LookupBone("wrist.R")
                                local matrix = puppet:GetBoneMatrix(boneID)
                                local pos = matrix:GetTranslation()



                                net.Start("changecamposelberr2")
                                net.WriteBool(true)
                                net.WriteVector(pos)
                                net.WriteAngle(headPos:GetAngles())
                                net.Send(loopentity)
                            end
                        end)

                       timer.Create("setragdollposition" .. ent:EntIndex(), 0.01, 0, function()
                            if IsValid(ragdoll) then
                                local boneID = puppet:LookupBone("wrist.R")
                                local matrix = puppet:GetBoneMatrix(boneID)
                                local bonePOS = matrix:GetTranslation()
                                local boneANG = matrix:GetAngles()
                                local forward = boneANG:Forward()
                                local up = boneANG:Up()
                                local right = boneANG:Right()

                                local phys = ragdoll:GetPhysicsObject()
                                phys:SetPos(bonePOS)
                                phys:SetAngles(boneANG)
                            end
                       end)
                    end
                end
            end

                if not ply:IsOnGround() then return end
                ply:SetVelocity(ply:GetForward() * 100)
            end)
        end)

        timer.Create("removetimers" .. ent:EntIndex(), 4, 0, function()

            if IsValid(ent) then
            ent.formTable.anims.default.run = "run"
            end

            if ent.CreatedTimer then
            ent:PillAnim("chargeTH")

            print("throw")

            ent.ActivatedRelberr = false

        timer.Create("sendragdollposagain", 0.01, 0, function()    
            net.Start("changecamposelberr2")
            net.WriteBool(true)
            net.WriteVector(headPos:GetPos())
            net.WriteAngle(headPos:GetAngles())
            net.Send(loopentity)
        end)

            timer.Simple(2, function()

                timer.Remove("sendragdollposagain")

                loopentity:SetPos(ragdoll:GetPos())
                ragdoll:Remove()
                loopentity:SetNoDraw(false)

                local wep = loopentity:GetActiveWeapon()

                if IsValid(wep) then
                    wep:SetNoDraw(false)
                end

                net.Start("abiliconscooldownselberr2")
                net.WriteString("ChargeCD")
                net.Send(ply)

                timer.Remove("sendheadpos" .. ent:EntIndex())

                net.Start("changecamposelberr2")
                net.WriteBool(false)
                net.WriteVector(headPos:GetPos())
                net.WriteAngle(headPos:GetAngles())
                net.Send(loopentity)


            end)

            else
                ent:PillSound("chargemiss")
                ent:PillAnim("chargemiss")

                ent.ActivatedRelberr = false

                net.Start("abiliconscooldownselberr2")
                net.WriteString("ChargeCD")
                net.Send(ply)

            end

            timer.Remove("removetimers" .. ent:EntIndex())
            timer.Remove("chargeelberr" .. ent:EntIndex())

            timer.Simple(0.5, function()

                --print("cd")

                timer.Simple(15, function()
                    ply.ChargeCD = false
                end)

            if IsValid(loopentity) then
                loopentity:Freeze(false)
            end
                timer.Remove("setragdollposition" .. ent:EntIndex())
            end)
        end)

        ent:CallOnRemove("removeabilityelberr2" .. ent:EntIndex(), function()
            ent.formTable.anims.default.run = "run"
            if IsValid(ply) then
                timer.Remove("setragdollposition" .. ent:EntIndex())
                timer.Remove("removetimers" .. ent:EntIndex())
                timer.Remove("chargeelberr" .. ent:EntIndex())
                timer.Remove("sendheadpos" .. ent:EntIndex())

                net.Start("abiliconscooldownselberr2")
                net.WriteString("ChargeCD")
                net.Send(ply)

                timer.Simple(15, function()
                    ply.ChargeCD = false
                end)
            end
        end)
    end,
	
    flashlight=function(ply,ent)

    end,
	
    jump=function(ply,ent)

    end
}, function(form)
    -- The legacy damage branches are for Sandbox and NPCs.
    form.hnsKillAPI = true
    form.hnsAbilities = {
        { id = "attack", name = "Ataque", key = IN_ATTACK, OnUse = form.attack.func },
        { id = "roar", name = "Rugido", key = IN_ATTACK2, OnUse = form.attack2.func },
        { id = "charge", name = "Investida", key = IN_RELOAD, cooldown = 19, duration = 4,
            OnUse = function(ply, ent)
                ent:PillAnim("chargestart")
                ent:PillSound("charge")
            end,
            OnTick = function(ply, ent, ab)
                if not IsValid(ent) or ab.activeUntil - CurTime() > 3.5 then return end
                local tr = util.TraceHull({
                    start = ply:WorldSpaceCenter(), endpos = ply:WorldSpaceCenter() + ply:GetForward() * 100,
                    mins = Vector(-15, -15, -15), maxs = Vector(15, 15, 15), filter = {ply, ent, ent:GetPuppet()},
                })
                if tr.HitWorld then
                    ent:PillAnim("chargeHW")
                    ent:PillSound("chargehit")
                    SherlockHNS.Ability.End(ply, "charge")
                elseif IsValid(tr.Entity) and tr.Entity:IsPlayer() then
                    if pk_pills.playHNSJumpscare(ply, ent, tr.Entity, 3.5, {
                        animation = "chargeKW", sound = "chargekillwall", camera = "ELBERR2JUMPCAM",
                    }) then SherlockHNS.Ability.End(ply, "charge") end
                elseif ply:OnGround() then
                    ply:SetVelocity(ply:GetForward() * 100)
                end
            end },
    }
    form.attack, form.attack2, form.reload = nil, nil, nil
    pk_pills.bindHNSButtons(form, "ELBERR2KeyBind", {
        { id = "robot", name = "Mini-robô", button = KEY_T, keyLabel = "T", cooldown = 5 },
    })
end)


hook.Add("OnEntityCreated", "elberrpillinitialize", function(ent)
    timer.Simple(0.00, function()
        if !IsValid(ent) then return end
        if ent:GetClass() == "pill_ent_costume" then
            if not ent then return end
            if ent.formTable then
                local PuppetEntity = ent:GetPuppet()
                local entityply = ent:GetPillUser()
                local hookName = "ThinkHookForEntity_OM_" .. ent:EntIndex()

                if ent.formTable.elber_initialize then
                    hook.Add("Think", hookName, function()
                        if not IsValid(ent) then
                            hook.Remove("Think", hookName)
                            return
                        end

                        local ply = ent:GetPillUser()
                        local puppet = ent:GetPuppet()

                        if not IsValid(puppet) or not IsValid(ply) then
                            hook.Remove("Think", hookName)
                            return
                        end

                        ent.formTable.elber_initialize(ply, ent)
                    end)
                end

                if ent.formTable.elber_custom_function then
                    ent.formTable.elber_custom_function(entityply, ent)
                end


                if ent.formTable.michael_elberr_initialize then

                    local tablevarable = {["player"] = entityply, ["entity"] = ent, ["puppet"] = PuppetEntity}
                    timer.Simple(0.1, function()
                        if !IsValid(ent) then return end
                        ent.formTable:michael_elberr_initialize(tablevarable,tablevarable,tablevarable,ply,ent)


                        local self = ent
                        self.formTable = pk_pills.getPillTable(self:GetPillForm())
                        local ply = self:GetPillUser()

                        if not self.formTable or not IsValid(ply) then
                            self:Remove()

                            return
                        end
                        local hull = self.formTable.hull or Vector(32, 32, 72)
                        local duckBy = self.formTable.duckBy or (self.formTable.hull and 0 or 36)
                        ply:SetHull(-Vector(hull.x / 2, hull.y / 2, 0), Vector(hull.x / 2, hull.y / 2, hull.z))
                        ply:SetHullDuck(-Vector(hull.x / 2, hull.y / 2, 0), Vector(hull.x / 2, hull.y / 2, hull.z - duckBy or 0))--
                        ply:SetRenderMode(RENDERMODE_NONE)
                        pk_pills.mapEnt(ply, nil)

                        if SERVER then
                            if ply:FlashlightIsOn() then
                                ply:Flashlight(false)
                            end

                            ply:Freeze(false)
                            ply:SetNotSolid(false)
                            ply:DrawViewModel(false)

                            local camOffset = Vector(0, 0, 20) --self.formTable.camera and self.formTable.camera.offset or 
                            --clside this?
                            ply:SetStepSize(hull.z / 4)
                            ply:SetViewOffset(camOffset)
                            ply:SetViewOffsetDucked(camOffset - Vector(0, 0, duckBy*0.15) )
                            self:ApplyMoveSpeed()
                        end
                        pk_pills.mapEnt(ply, self)

                    end)

                    local self = ent
                    ent.Think = function()
                        local currentanim = 'idle'
                        local ply = self:GetPillUser()
                        local puppet = self:GetPuppet()
                        if not IsValid(puppet) or not IsValid(ply) then return end
                        local vel = ply:GetVelocity():Length()

                        if SERVER then
                            --Anims
                            local anims = table.Copy(self.formTable.anims.default or {})
                            table.Merge(anims, (IsValid(ply:GetActiveWeapon()) and self.formTable.anims[ply:GetActiveWeapon():GetHoldType()]) or (self.forceAnimSet and self.formTable.anims[self.forceAnimSet]) or {})
                            local anim
                            --local useSeqVel=true
                            local overrideRate

                            if (not self.anim or not anims[self.anim]) then
                                self.animFreeze = nil
                                self.animStart = nil
                            end

                            if self.animFreeze and not self.plyFrozen then
                                self:ApplyMoveSpeed()
                                self.plyFrozen = true
                            elseif not self.animFreeze and self.plyFrozen then
                                self:ApplyMoveSpeed()
                                self.plyFrozen = nil
                            end

                            if self.anim and anims[self.anim] then
                                anim = anims[self.anim]
                                overrideRate = anims[self.anim .. "_rate"] or 1
                                local cycle = puppet:GetCycle()

                                if not self.animStart then
                                    if cycle == 1 or (self.animCycle and self.animCycle > cycle) or (string.lower(anim) ~= string.lower(puppet:GetSequenceName(puppet:GetSequence()))) then
                                        self.anim = nil
                                        self.animCycle = nil

                                        if self.animFreeze then
                                            self.animFreeze = nil
                                        end
                                    elseif self.animCycle then
                                        self.animCycle = cycle
                                    end
                                end
                            elseif self.tickAnim and anims[self.tickAnim] then
                                anim = anims[self.tickAnim]
                                overrideRate = anims[self.tickAnim .. "_rate"] or 1
                                self.tickAnim = nil
                            elseif self.burrowed then
                                anim = anims["burrow_loop"]
                            elseif ply:WaterLevel() > 2 then
                                anim = anims["swim"] or anims["glide"] or anims["idle"]
                            elseif ply:IsOnGround() then
                                if ply:Crouching() then
                                    if vel > ply:GetCrouchedWalkSpeed() / 4 then
                                        anim = anims["crouch_walk"] or anims["crouch"] or anims["walk"] or anims["idle"]
                                    else
                                        anim = anims["crouch"] or anims["idle"]
                                    end
                                else
                                    if vel > (ply:GetWalkSpeed() + ply:GetRunSpeed()) / 2 then
                                        anim = anims["run"] or anims["walk"] or anims["idle"]
                                    elseif vel > ply:GetWalkSpeed() / 4 then
                                        anim = anims["walk"] or anims["idle"]
                                    else
                                        anim = anims["idle"]
                                    end
                                end
                            else
                                anim = anims["glide"] or anims["idle"]
                            end

                            if anim == anims["idle"] or anim == anims["crouch"] then
                                overrideRate = 1
                            end
                            self:SetNWString("Animlastplayed", anim)

                            local ShouldAlternate = table.Copy(self.formTable.anims.ShouldAlternate or {})
                            if type(ShouldAlternate[anim]) == "function" and ShouldAlternate[anim](self) then
                                if ShouldAlternate[anim](self) ~= nil and isstring(ShouldAlternate[anim](self)) then
                                    
                                    anim = ShouldAlternate[anim](self)
                                end
                            end

                            if (anim and puppet:GetSequence() ~= puppet:LookupSequence(anim)) or self.animStart or (self.formTable.autoRestartAnims and puppet:GetCycle() == 1) then
                                puppet:ResetSequence(puppet:LookupSequence(anim))
                                puppet:SetCycle(0)
                                self.animCycle = 0
                            end

                            self.animStart = nil
                            local seq_vel = puppet:GetSequenceGroundSpeed(puppet:GetSequence())

                            --if true then
                            if self.formTable.movePoseMode ~= "xy" and self.formTable.movePoseMode ~= "xy-bot" and not overrideRate then
                                local rate = overrideRate or vel / seq_vel

                                --goofy limitation (floods console with errors if above 12!)
                                if rate > 12 then
                                    rate = 12
                                end

                                puppet:SetPlaybackRate(rate)
                            else
                                --puppet:SetPlaybackRate(1)
                            end

                            --print(puppet:GetCycle())
                            if self.formTable.movePoseMode then
                                --
                                if self.formTable.movePoseMode == "yaw" then
                                    local move_dir = puppet:WorldToLocalAngles(ply:GetVelocity():Angle())
                                    puppet:SetPoseParameter("move_yaw", move_dir.y)
                                elseif self.formTable.movePoseMode == "xy" then
                                    if not overrideRate then
                                        local localvel = ply:WorldToLocal(ply:GetPos() + ply:GetVelocity())
                                        local maxdim = math.Max(math.abs(localvel.x), math.abs(localvel.y))
                                        local clampedvel = maxdim == 0 and Vector(0, 0, 0) or localvel / maxdim
                                        puppet:SetPoseParameter("move_x", clampedvel.x)
                                        puppet:SetPoseParameter("move_y", -clampedvel.y)
                                        seq_vel = puppet:GetSequenceGroundSpeed(puppet:GetSequence())

                                        if seq_vel ~= 0 then
                                            puppet:SetPoseParameter("move_x", math.Clamp(localvel.x / seq_vel, -.99, .99))
                                            puppet:SetPoseParameter("move_y", math.Clamp(-localvel.y / seq_vel, -.99, .99))
                                        end
                                        --print(puppet:GetPlaybackRate())
                                    else
                                        puppet:SetPoseParameter("move_x", 0)
                                        puppet:SetPoseParameter("move_y", 0)
                                    end
                                elseif self.formTable.movePoseMode == "xy-bot" then
                                    if not overrideRate then
                                        local localvel = ply:WorldToLocal(ply:GetPos() + ply:GetVelocity())
                                        local maxdim = math.Max(math.abs(localvel.x), math.abs(localvel.y))
                                        local clampedvel = maxdim == 0 and Vector(0, 0, 0) or localvel / maxdim
                                        local move_dir = puppet:WorldToLocalAngles(ply:GetVelocity():Angle())
                                        puppet:SetPoseParameter("move_x", clampedvel.x)
                                        puppet:SetPoseParameter("move_y", -clampedvel.y)
                                        puppet:SetPoseParameter("move_yaw", move_dir.y)
                                        puppet:SetPoseParameter("move_scale", 1)
                                        seq_vel = puppet:GetSequenceGroundSpeed(puppet:GetSequence())

                                        if seq_vel ~= 0 then
                                            puppet:SetPoseParameter("move_x", math.Clamp(localvel.x / seq_vel, -.99, .99))
                                            puppet:SetPoseParameter("move_y", math.Clamp(-localvel.y / seq_vel, -.99, .99))
                                            puppet:SetPoseParameter("move_scale", math.Clamp(localvel:Length() / seq_vel, -.99, .99))
                                        end
                                        --print(puppet:GetPlaybackRate())
                                    else
                                        puppet:SetPoseParameter("move_x", 0)
                                        puppet:SetPoseParameter("move_y", 0)
                                        puppet:SetPoseParameter("move_yaw", 0)
                                        puppet:SetPoseParameter("move_scale", 0)
                                    end
                                end
                            end

                            --Aimage
                            if self.formTable.aim then
                                if self.formTable.aim.xPose then
                                    local yaw = math.AngleDifference(ply:EyeAngles().y, puppet:GetAngles().y)

                                    if self.formTable.aim.xInvert then
                                        yaw = -yaw
                                    end

                                    puppet:SetPoseParameter(self.formTable.aim.xPose, yaw)
                                end

                                if self.formTable.aim.yPose then
                                    local pitch = math.AngleDifference(ply:EyeAngles().p, puppet:GetAngles().p)

                                    if self.formTable.aim.yInvert then
                                        pitch = -pitch
                                    end

                                    puppet:SetPoseParameter(self.formTable.aim.yPose, pitch)
                                end
                            end

                            --gliding and landing
                            if not ply:IsOnGround() and ply:WaterLevel() == 0 and self.formTable.glideThink then
                                self.formTable.glideThink(ply, self)
                            end

                            if not ply:IsOnGround() and not self.touchingWater and ply:WaterLevel() > 0 and self.formTable.land then
                                self.formTable.land(ply, self)
                            end

                            --tick attack
                            if ply:KeyDown(IN_ATTACK) and self.formTable.attack and self.formTable.attack.mode == "tick" then
                                self.formTable.attack.func(ply, self, self.formTable.attack)
                            end

                            if ply:KeyDown(IN_ATTACK2) and self.formTable.attack2 and self.formTable.attack2.mode == "tick" then
                                self.formTable.attack2.func(ply, self, self.formTable.attack2)
                            end

                            --auto attack
                            if ply:KeyDown(IN_ATTACK) and self.formTable.attack and self.formTable.attack.mode == "auto" then
                                if not self.formTable.aim then
                                    self:PillLoopSound("attack")
                                else
                                    self:PillLoopStop("attack")
                                end

                                if (not self.lastAttack or (self.formTable.attack.interval or self.formTable.attack.delay) < CurTime() - self.lastAttack) then
                                    self.formTable.attack.func(ply, self, self.formTable.attack)
                                    self.lastAttack = CurTime()
                                end
                            else
                                self:PillLoopStop("attack")
                            end

                            if ply:KeyDown(IN_ATTACK2) and self.formTable.attack2 and self.formTable.attack2.mode == "auto" then
                                if not self.formTable.aim then
                                    self:PillLoopSound("attack2")
                                else
                                    self:PillLoopStop("attack2")
                                end

                                if not self.lastAttack2 or (self.formTable.attack2.interval or self.formTable.attack2.delay) < CurTime() - self.lastAttack2 then
                                    self.formTable.attack2.func(ply, self, self.formTable.attack2)
                                    self.lastAttack2 = CurTime()
                                end
                            else
                                self:PillLoopStop("attack2")
                            end

                            --if !IsValid(ply) then self:NextThink(CurTime()) return true end
                            --wepon-no longer SO hackey
                            if not self.formTable.hideWeapons then
                                local realWep = self:GetPillUser():GetActiveWeapon()

                                --&&self:GetPillUser()!=ply or pk_pills.var_thirdperson:GetBool()) then
                                if IsValid(realWep) and realWep:GetModel() ~= "" then
                                    --hiding the real thing [BROKEN]
                                    --[[if realWep:GetRenderMode()!=RENDERMODE_NONE then
                                        realWep:SetRenderMode(RENDERMODE_NONE)
                                    end]]
                                    if realWep.pill_attachment then
                                        if IsValid(self.wepmdl) then
                                            self.wepmdl:Remove()
                                        end

                                        self.wepmdl = ents.Create("pill_attachment_wep")
                                        self.wepmdl:SetParent(self:GetPuppet())
                                        self.wepmdl:SetModel(realWep:GetModel())
                                        self.wepmdl.attachment = realWep.pill_attachment
                                        self.wepmdl:Spawn()

                                        if realWep.pill_offset then
                                            self.wepmdl:SetWepOffset(realWep.pill_offset)
                                        end

                                        if realWep.pill_angle then
                                            self.wepmdl:SetWepAng(realWep.pill_angle)
                                        end

                                        realWep.pill_proxy = self.wepmdl
                                    elseif not IsValid(self.wepmdl) then
                                        self.wepmdl = ents.Create("pill_attachment_wep")
                                        self.wepmdl:SetParent(self:GetPuppet())
                                        self.wepmdl:SetModel(realWep:GetModel())
                                        self.wepmdl:Spawn()
                                        realWep.pill_proxy = self.wepmdl
                                    elseif self.wepmdl:GetModel() ~= realWep:GetModel() then
                                        self.wepmdl:SetModel(realWep:GetModel())
                                    end
                                elseif IsValid(self.wepmdl) then
                                    self.wepmdl:Remove()
                                end
                            end
                        else
                            if self:GetPillUser() ~= LocalPlayer() or pk_pills.convars.cl_thirdperson:GetBool() then
                                puppet:SetNoDraw(false)
                            else
                                puppet:SetNoDraw(false)
                            end

                            local realWep = self:GetPillUser():GetActiveWeapon()

                            if IsValid(realWep) and realWep:GetModel() ~= "" and not realWep:GetNoDraw() then
                                realWep:SetNoDraw(true)
                            end
                        end

                        --Align pos and angles with player
                        if SERVER then
                            puppet:SetPos(ply:GetPos())
                        else
                            puppet:SetRenderOrigin(ply:GetPos())
                        end
                        
                        currentanim = self:GetNWString("Animlastplayed")

                        if vel > 0 or math.abs(math.AngleDifference(puppet:GetAngles().y, ply:EyeAngles().y)) > 350 then

                        local animsshouldspn = table.Copy(self.formTable.anims.ShouldMoveRotate or {})
                        if animsshouldspn[currentanim] or (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) then
                            
                            local typeofitem = (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) or animsshouldspn[currentanim]
                            local function SetTargetAngle(ang)
                                ang.p = 0
                                puppet:SetNW2Vector("SyncAng", ang:Forward())
                            end

                            local function GetTargetAngle()
                                local dir = puppet:GetNW2Vector("SyncAng")
                                if not dir or dir == vector_origin then return nil end
                                local ang = dir:Angle()
                                if not ang then return nil end
                                ang.p = 0
                                return ang
                            end

                            if typeofitem == "notshftlock" then
                                local dir = ply:GetVelocity():GetNormalized()
                                local aheadPos = ply:GetPos() + dir * 5
                                local ang = (aheadPos - ply:GetPos()):Angle()
                                ang.p = 0

                                if SERVER then
                                    SetTargetAngle(ang)
                                    puppet:SetAngles(ang)
                                end

                                if CLIENT then
                                    local targetAng = GetTargetAngle()
                                    if targetAng then
                                        local curAng = puppet:GetRenderAngles()
                                        if not curAng then curAng = targetAng end
                                        if not curAng.p then curAng = Angle(0,0,0) end
                                        local smoothAng = LerpAngle(FrameTime() * 10, curAng, targetAng)
                                        puppet:SetRenderAngles(smoothAng)
                                    end
                                end
                            elseif typeofitem == "assignedagnles_instant" then
                                local targetAng = self:GetNWAngle("pill_assignedangle")

                                if SERVER then
                                    SetTargetAngle(targetAng)
                                    puppet:SetAngles(targetAng)
                                end

                                if CLIENT then
                                    if targetAng then
                                        puppet:SetRenderAngles(targetAng)
                                    end
                                end

                            elseif typeofitem == "shiftlock" then
                                local angs = ply:EyeAngles()
                                angs.p = 0

                                if SERVER then
                                    SetTargetAngle(angs)
                                    puppet:SetAngles(angs)
                                end

                                if CLIENT then
                                    local targetAng = GetTargetAngle()
                                    if targetAng then
                                        local curAng = puppet:GetRenderAngles()
                                        if not curAng then curAng = targetAng end
                                        if not curAng.p then curAng = Angle(0,0,0) end
                                        local smoothAng = LerpAngle(FrameTime() * 10, curAng, targetAng)
                                        puppet:SetRenderAngles(smoothAng)
                                    end
                                end

                            elseif typeofitem == "Playerangles" then
                                local angs = ply:GetAngles()
                                angs.p = 0

                                if SERVER then
                                    SetTargetAngle(angs)
                                    puppet:SetAngles(angs)
                                end

                                if CLIENT then
                                    local targetAng = GetTargetAngle()
                                    if targetAng then
                                        local curAng = puppet:GetRenderAngles()
                                        if not curAng then curAng = targetAng end
                                        if not curAng.p then curAng = Angle(0,0,0) end
                                        local smoothAng = LerpAngle(FrameTime() * 10, curAng, targetAng)
                                        puppet:SetRenderAngles(smoothAng)
                                    end
                                end

                            elseif typeofitem == "assignedagnles" then
                                local targetAng = self:GetNWAngle("pill_assignedangle")

                                if SERVER then
                                    SetTargetAngle(targetAng)
                                    puppet:SetAngles(targetAng)
                                end

                                if CLIENT then
                                    if targetAng then
                                        local curAng = puppet:GetRenderAngles()
                                        if not curAng then curAng = targetAng end
                                        if not curAng.p then curAng = Angle(0,0,0) end
                                        local smoothAng = LerpAngle(FrameTime() * 10, curAng, targetAng)
                                        puppet:SetRenderAngles(smoothAng)
                                    end
                                end

                            elseif typeofitem == "notanything" then
                            end
                        end

                        self:NextThink(CurTime())

                        return true
                    end
                    end
                end
                if ent.formTable.HandleAnimEvent_ELBERR_OM_pill then
                    local PuppetEntity = ent:GetPuppet()
                    local entityply = ent:GetPillUser()

                    if IsValid(PuppetEntity) then
                        function PuppetEntity:AcceptInput(inputName, activator, caller, data)
                            ent.formTable.HandleAnimEvent_ELBERR_OM_pill(entityply, ent, inputName)
                            return true
                        end
                    end
                end
            end
        end
    end)
end)

if SERVER then
    util.AddNetworkString("abilitycooldowneblerrRability")
    util.AddNetworkString("changematerialelberr")
    util.AddNetworkString("changematerialbacktodefault")
    util.AddNetworkString("abilitycooldowneblerrRability")
    util.AddNetworkString("fadeinvignette")
    util.AddNetworkString("fillupbarelberr")
    util.AddNetworkString("elberr25%")
    util.AddNetworkString("elberr50%")
    util.AddNetworkString("elberr75%")
    util.AddNetworkString("elberr100%")
    util.AddNetworkString("elberrsendmessageinchat")
    util.AddNetworkString("playsoundforevery1elbert")
    util.AddNetworkString("makerargdollinvisibleduringkillelbertyesyesyesysye")
    util.AddNetworkString("makeragdollvisibleagainelbert")
    util.AddNetworkString("stopbarfillingup")
    util.AddNetworkString("resetelberbarserverside")
    util.AddNetworkString("resetelberrbar")
end


pk_pills.register("pill_selfawarerobotelbert",{

    printName="E.L.B.E.R.R",
	
    model="models/whynotboi/pills/elberr/elberr.mdl",
	
	modelScale="1.5",

    muteSteps = true,
	
    anims={
        default={
            idle="idle",
			run="run",
            walk="walk",
			attack="idle",
			jumpscare="kill",
            overcharge="special",
            crouch="cidle",
            crouch_walk="cwalk",
        },

        ShouldMoveRotate={
            idle= function(ent) 
                return 'notshftlock'
            end,
            run= function(ent) 
                return 'notshftlock'
            end,
            walk= function(ent) 
                return 'notshftlock'
            end,
            missattack= function(ent) 
                return 'notshftlock'
            end,
            crouch= function(ent)
                return 'notshftlock'
            end,
            jumpscare= function(ent)
                return 'notshftlock'
            end,
            cwalk= function(ent)
                return 'notshftlock'
            end,


        },

        
    },
	
    moveSpeed={
        walk=120,
        run=580 ,
        ducked=100,
    },
	
    sounds={
        jumpscare="michael/ELBERR_killanim.wav",
        overcharge = "michael/ELBERR_overcharge.wav",
    },
	

    type="ply",

    camera={
        dist=100
    },

    FirstPersonBone = {
        'eye.R',
        10,
        0,
        0,
    },
   ThirdPersonBone = {
       'spine.002',
        0,
        15,
        0,
    },
	
    jumpPower=0,
	
    health=250000,
	
	movePoseMode="xy",
		aim={
		xPose="aim_yaw",
		yPose="aim_pitch",
		nocrosshair = true
	},
	
	canAim=function(ply,ent)
		return ent.active
	end,

    elber_initialize = function(ply, ent)
    end,

    michael_elberr_initialize = function(initializetable,initializetable2,initializetable3,ply,ent)
    end,

    elber_custom_function = function(ply, ent)

hook.Add("PlayerFootstep", "CustomFootstepelbert", function(plyfootstep, pos, foot, sound, volume, rf)
    if plyfootstep == ply then
        print(sound)
        if string.find(sound, "player/footsteps/concrete") or string.find(sound, "player/footsteps/grass") or string.find(sound, "player/footsteps/metal") or string.find(sound, "player/footsteps/rubber") or string.find(sound, "player/footsteps/tile") or string.find(sound, "player/footsteps/wood") or string.find(sound, "player/footsteps/woodpanel") or string.find(sound, "physics/cardboard/cardboard_box_impact_soft") then
        return true
        end
    end
end)



        local puppet = ent:GetPuppet()
        local state1 = false
        local state2 = false
        local state3 = false
        local state4 = false
        thisthatblahblahblah = false -- sorry about this variable name i got really lazy lmao

        ent.ElberrAnimSpeed = ent.ElberrAnimSpeed or 1
        ent.ElberrSpeedWalk = ent.ElberrSpeedWalk or 120
        ent.ElberrSpeedRun = ent.ElberrSpeedRun or 580

        timer.Create("animspeedcontroller", 0.1, 0, function()
            if thisthatblahblahblah then return end
            if not IsValid(puppet) then return end
            puppet:SetPlaybackRate(ent.ElberrAnimSpeed)
            pk_pills.setCostumeMoveSpeed(ent, ent.ElberrSpeedWalk, ent.ElberrSpeedRun)
        end)

    net.Receive("elberr25%", function()
        if not IsValid(ent) then return end
        if not state1 then
            state1 = true
            ent.ElberrSpeedWalk = 150
            ent.ElberrSpeedRun = 600
            PrintMessage(HUD_PRINTTALK, "Elberr's Bar Reached 25%!")
            thisthatblahblahblah = false
            ent.ElberrAnimSpeed = 1.25
            ent.ElberrFaster = true
        end
    end)

    net.Receive("elberr50%", function()
        if not IsValid(ent) then return end
        if not state2 then
            state2 = true
            ent.ElberrSpeedWalk = 175
            ent.ElberrSpeedRun = 620
            PrintMessage(HUD_PRINTTALK, "Elberr's Bar Reached 50%!")
            ent.ElberrAnimSpeed = 1.5
        end
    end)

    net.Receive("elberr75%", function()
        if not IsValid(ent) then return end
        if not state3 then
            state3 = true
            ent.ElberrSpeedWalk = 200
            ent.ElberrSpeedRun = 640
            PrintMessage(HUD_PRINTTALK, "Elberr's Bar Reached 75%!")
            ent.ElberrAnimSpeed = 1.75
        end
    end)

        net.Receive("elberr100%", function()
        if not IsValid(ent) then return end
        if not state4 then
            state4 = true
            PrintMessage(HUD_PRINTTALK, "Elberr's Bar Reached 100%! you better start running.")
            ent.ElberrSpeedWalk = 250
            ent.ElberrSpeedRun = 670
            ent.ElberrAnimSpeed = 2
            net.Start("playsoundforevery1elbert")
            net.Broadcast()
        end
    end)

        net.Receive("resetelberbarserverside", function()
            if ent.ElberrFaster then
            if not IsValid(ent) then return end
                state1 = false
                state2 = false
                state3 = false
                state4 = false
                thisthatblahblahblah = true
                pk_pills.setCostumeMoveSpeed(ent, 120, 580)
                PrintMessage(HUD_PRINTTALK, "Elberr's Bar Reached Has Been Reset.")
            end
        end)

        ent:CallOnRemove("asdasadasd", function()
            hook.Remove("PlayerFootstep", "CustomFootstepelbert")
            thisthatblahblahblah = true
        end)
    end,

    attack = {
        mode = 'trigger',
            func = function(ply, ent)
            local ratio = 0.3
            local entity = nil
            local puppet = ent:GetPuppet()

            local attachmentID = puppet:LookupAttachment("camera")
            local attachment = puppet:GetAttachment(attachmentID)

            local targetOrigin = ent:LocalToWorld(Vector(0, 0, 50))
if SherlockHNS then
    entity = SherlockHNS.FindVictim(ply, targetOrigin, 90, {
        filter = function(v)

            local trace = util.TraceLine({
                start = ent:EyePos(),
                endpos = v:EyePos(),
                filter = {ent, ply},
                mask = MASK_VISIBLE
            })
            return not trace.Hit
        end,
    })
else
for k, v in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 90)) do
                if v:IsPlayer() or v:IsNextBot() or v:IsNPC() then
                    if v == ent or v == ply then continue end

                    if (v:IsPlayer() and v:Team() ~= TEAM_SPECTATOR) or (v:IsNPC() or v:IsNextBot()) and v:Health() > 0 then

                    local trace = util.TraceLine({start = ent:EyePos(), endpos = v:EyePos(), filter = {ent, ply}, mask = MASK_VISIBLE})

                    if not trace.Hit then
                        entity = v
                        break
                    end
                end
            end
        end
end

if SherlockHNS and IsValid(entity) and entity:IsPlayer() then
            return pk_pills.playHNSJumpscare(ply, ent, entity, 8, {
                camera = "ELBERJUMPCAM",
                offset = 50,
                animation = "jumpscare",
                sound = "jumpscare",
            })
        end

        if IsValid(entity) then
            local pill = ent:GetPuppet()

        if ent.ElberrFaster then
            thisthatblahblahblah = true
            local walk = pill:LookupSequence("walk")
            local idle = pill:LookupSequence("idle")
            local run = pill:LookupSequence("run")

            pill:SetPlaybackRate(1)
            pill:ResetSequence(walk)
            pill:ResetSequence(idle)
            pill:ResetSequence(run)
        end

        if ent.ElberrReload then
            timer.Remove("setplaybackspeed" .. ent:EntIndex())
            local walk = pill:LookupSequence("walk")
            local idle = pill:LookupSequence("idle")
            local run = pill:LookupSequence("run")

            pill:SetPlaybackRate(1)
            pill:ResetSequence(walk)
            pill:ResetSequence(idle)
            pill:ResetSequence(run)
        end    

        timer.Simple(0.3, function()   
            local ragdoll = ents.Create("prop_ragdoll")
            if not IsValid(ragdoll) then return end

            ragdoll:SetModel(entity:GetModel())
            ragdoll:SetPos(ply:GetPos())
            ragdoll:SetCollisionGroup(COLLISION_GROUP_WORLD)
            ragdoll:Spawn()
            ragdoll:Activate()

            timer.Simple(0.3, function()
                if not IsValid(ragdoll) or not IsValid(entity) then return end

                net.Start("makerargdollinvisibleduringkillelbertyesyesyesysye")
                net.WriteEntity(ragdoll)
                net.Send(entity)
            end)



            local headpos = nil

            for i = 0, ragdoll:GetPhysicsObjectCount() -1 do
                local phys = ragdoll:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    local boneIndex = ragdoll:TranslatePhysBoneToBone(i)
                    local boneName = ragdoll:GetBoneName(boneIndex) or ""
                    if string.find(string.lower(boneName), "head") then
                        headpos = phys
                        break
                    end
                end
            end

            timer.Create("setpos", 0.01, 0, function()
                if not IsValid(ragdoll) or not IsValid(headpos) then 
                    timer.Remove("setpos")
                    return 
                end

                local attachmentID = puppet:LookupAttachment("camera")
                local attach = puppet:GetAttachment(attachmentID)
                if not attach then return end

                headpos:SetPos(LerpVector(ratio, headpos:GetPos(), attach.Pos))
                headpos:SetAngles(LerpAngle(ratio, headpos:GetAngles(), attach.Ang))
            end)


        end)


            timer.Simple(8, function()
                timer.Remove("setpos")
                thisthatblahblahblah = false
                net.Start("makeragdollvisibleagainelbert")
                net.Send(entity)
            end)

            if entity:IsPlayer() then
                entity:SetNoDraw(true)
                entity:Freeze(true)
                entity:AddFlags(FL_NOTARGET)
                entity:DrawViewModel(false)
                entity:SetActiveWeapon(nil)

                net.Start('ELBERJUMPCAM')
                net.WriteEntity(pill)
                net.WriteBool(true)
                net.Send(entity)

            elseif entity:IsNPC() then
                entity:SetNoDraw(true)
                entity:SetNPCState(NPC_STATE_IDLE)
                entity:SetEnemy(nil)
            else
                entity:NextThink(CurTime())
                entity:TakeDamage(1e9, ply)
            end

            entity:SetPos(pill:GetPos() + pill:GetForward() * 50)
            ply:Freeze(true)

            ent:PillAnim('jumpscare')
            ent:PillSound('jumpscare')

            timer.Simple(8, function()
                if not (IsValid(entity) and IsValid(ent)) then return end

                ply:Freeze(false)

                if entity:IsPlayer() then
                    entity:Kill(ply)

                    net.Start('ELBERJUMPCAM')
                    net.WriteEntity(pill)
                    net.WriteBool(false)
                    net.Send(entity)

                    ent.ElberrReload = false

                    entity:RemoveFlags(FL_NOTARGET)
                    entity:Freeze(false)
                    entity:DrawViewModel(true)
                else

                    ent.ElberrReload = false

                    entity:NextThink(CurTime())
                    entity:TakeDamage(1e9, ply)
                end
            end)
        else
        end

        timer.Simple(3, function()
            ply.OnHold = false
        end)

        ent:CallOnRemove("blahblahelbert", function()
        if IsValid(ragdoll) and IsValid(phys) then
           ragdoll:Remove()
        end
    end)

    end
},


attack2 = {
    mode = "trigger",
    func = function(ply, ent)
    end,
},




	

    noragdoll=true,
	
   	reload=function(ply,ent)
        if not ent.ElberrCooldown then
        
        
        ent.ElberrCooldown = true
        pk_pills.setHNSCooldown(ent, "overcharge", 20.75)

        ent.ElberrReload = true

        net.Start("fadeinvignette")
        net.Send(ply)

        local puppet = ent:GetPuppet()

        local run = puppet:LookupSequence("run")
        local walk = puppet:LookupSequence("walk")
        local idle = puppet:LookupSequence("idle")

        thisthatblahblahblah = true
        puppet:SetPlaybackRate(1)
        puppet:ResetSequence(run)
        puppet:ResetSequence(walk)
        puppet:ResetSequence(idle)

        ply:Freeze(true)
        ent:PillAnim("overcharge")
        ent:PillSound("overcharge")

    timer.Simple(5.75, function()
        ply:Freeze(false)
        net.Start("changematerialelberr")
        net.Send(ply)
        timer.Create("setplaybackspeed" .. ent:EntIndex(), 0.5, 0, function()
            if IsValid(puppet) then
                puppet:SetPlaybackRate(2)
            if not ent.ElberrFaster then
                pk_pills.setCostumeMoveSpeed(ent, 200, 650)
            else
                pk_pills.setCostumeMoveSpeed(ent, 250, 690)
            end
        end
    end)

    timer.Simple(5, function()
        thisthatblahblahblah = false
        timer.Remove("setplaybackspeed" .. ent:EntIndex())

        net.Start("changematerialbacktodefault")
        net.Send(ply)

        net.Start("abilitycooldowneblerrRability")
        net.Send(ply)

        timer.Simple(10, function()
            if ent.ElberrCooldown then
                ent.ElberrCooldown = false
            end
        end)

        pk_pills.setCostumeMoveSpeed(ent, ent.ElberrSpeedWalk, ent.ElberrSpeedRun)
    end)

    end)
 end
end,
	
    flashlight=function(ply,ent)

    end,
	
    jump=function(ply,ent)

    end
}, function(form)
    -- The legacy damage branches are for Sandbox and NPCs.
    form.hnsKillAPI = true
    form.hnsAbilities = {
        { id = "attack", name = "Ataque", key = IN_ATTACK, OnUse = form.attack.func },
        { id = "overcharge", name = "Sobrecarga", key = IN_RELOAD, OnUse = form.reload },
    }
    form.attack, form.attack2, form.reload = nil, nil, nil
end)

local lastLookingstate = false

hook.Add("OnEntityCreated", "elberridle", function(ent)
    if not SERVER then return end
    if ent:GetClass() ~= "pill_ent_costume" then return end

    timer.Simple(0, function()
        if not IsValid(ent) then return end
        if not ent.formTable or ent.formTable.name ~= "pill_selfawarerobotelbert" then return end

        local pilluser = ent:GetPillUser()
        if not IsValid(pilluser) then return end

        local elberrmainidleloop = CreateSound(ent, "michael/ELBERR_idleanim_yesloop.wav")
        local elberrmainidleloopfan = CreateSound(ent, "michael/elbertfanloopidlepleasefuckingworkpleaseeeee.wav")

        elberrmainidleloopfan:Play()
        elberrmainidleloop:Play()

        elberrmainidleloop:ChangeVolume(0.3, 0)

        local FOV_DOT = 0.75

        timer.Create("checkifsomeoneislookingatelberr", 0.1, 0, function()
            if not IsValid(ent) then return end

            local lookingstate = false
            local pillPos = ent:WorldSpaceCenter()

            for _, v in ipairs(player.GetAll()) do
                if v == pilluser then continue end
                if not v:IsPlayer() or not v:Alive() then continue end
                if v:Team() == TEAM_SPECTATOR then continue end

                local eyePos = v:EyePos()
                local viewDir = v:EyeAngles():Forward()
                local dirToPill = (pillPos - eyePos):GetNormalized()

                local dot = viewDir:Dot(dirToPill)

                if dot >= FOV_DOT then
                    local tr = util.TraceLine({
                        start = eyePos,
                        endpos = pillPos,
                        filter = {v, ent},
                        mask = MASK_VISIBLE
                    })

                    if not tr.Hit then
                        lookingstate = true
                        break
                    end
                end
            end

            if lookingstate ~= lastLookingstate then
                lastLookingstate = lookingstate

                net.Start("fillupbarelberr")
                net.WriteBool(lookingstate)
                net.Broadcast()
            end
        end)

        ent:CallOnRemove("ASDJKJDSAelberr", function()
            timer.Remove("checkifsomeoneislookingatelberr")

            net.Start("resetelberrbar")
            net.Send(pilluser)

            net.Start("stopbarfillingup")
            net.Send(pilluser)

            elberrmainidleloop:Stop()
            elberrmainidleloopfan:Stop()
        end)
    end)
end)
