if !pcall(require,"pk_pills") then
	if SERVER then
		hook.Add("PlayerInitialSpawn","pk_pill_extfail_cl",function(ply)
			if game.SinglePlayer() || ply:IsListenServerHost() then
				ply:SendLua('notification.AddLegacy("One or more pill extensions failed to load. Did you forget to install Parakeet\'s Pill Pack?",NOTIFY_ERROR,30)')
			end
		end)
		hook.Add("Initialize","pk_pill_extfail_sv",function(ply)
			print("[ALERT] One or more pill extensions failed to load. Did you forget to install Parakeet's Pill Pack?")
		end)
	end
	return
end

AddCSLuaFile()
AddCSLuaFile("include/elber2.0.lua")
include("include/elber2.0.lua")


if SERVER then
	util.AddNetworkString('ELBERR2JUMPCAM')
end

if CLIENT then

	local savedCalcViewHooks = {}
	local savedCalcViewHooks2 = {}

	net.Receive('ELBERR2JUMPCAM', function()
		local ply = LocalPlayer()
		local ent = net.ReadEntity()
		local state = net.ReadBool()
		local hookname1 = 'ELBERR2JUMPCAM_playercam_new_' .. tostring(ply)

	if not state then
		hook.Remove("CalcView", hookname1)
		return
	end

		local transitionStart = RealTime()

		hook.Add('CalcView', hookname1, function(ply, pos, angles, fov)
			if not IsValid(ply) or not ply:Alive() or not IsValid(ent) then
				hook.Remove('CalcView', hookname1)
				return
			end	
			local transitionProgress = math.Clamp((RealTime() - transitionStart) / 0.25, 0, 1)
			local cam = ent:GetAttachment(ent:LookupAttachment('camera'))
			return {
				origin = LerpVector(transitionProgress, pos, cam.Pos),
				angles = LerpAngle(transitionProgress, angles, cam.Ang),
				fov = 70,
				drawviewer = false
			}
		end)
	end)
end


if SERVER then
    util.AddNetworkString("ELBERJUMPCAM")
end

if CLIENT then
    net.Receive("ELBERJUMPCAM", function()
        local ply = LocalPlayer()
        local ent = net.ReadEntity()
        local state = net.ReadBool()
        local hookname = "elbertpillpack_new_" .. tostring(ply)

        if not state then
            hook.Remove("CalcView", hookname)
            return
        end

        local transitionStart = RealTime()

        hook.Add("CalcView", hookname, function(ply, pos, angles, fov)
            if not IsValid(ply) or not ply:Alive() or not IsValid(ent) then
                hook.Remove("CalcView", hookname)
                return
            end
            local transitionProgress = math.Clamp((RealTime() - transitionStart) / 0.25, 0, 1)
            local cam = ent:GetAttachment(ent:LookupAttachment("camera"))
            return {
                origin = LerpVector(transitionProgress, pos, cam.Pos),
                angles = LerpAngle(transitionProgress, angles, cam.Ang),
                fov = 80,
                drawviewer = false
            }
        end)
    end)
end
