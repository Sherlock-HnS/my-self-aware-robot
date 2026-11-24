local IsInThirdPerson = nil

hook.Add("OnEntityCreated", "elberr2pillpilliniitialize", function(ent)
    timer.Simple(0.00, function()
        if !IsValid(ent) then return end
        if ent:GetClass() == "pill_ent_costume" then
            if not ent then return end
            if ent.formTable then
                local PuppetEntity = ent:GetPuppet()
                local targetOrigin = ent:LocalToWorld(Vector(0, 0, 50))
local entity
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
                local targetOrigin = ent:LocalToWorld(Vector(0, 0, 50))
local entity
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
