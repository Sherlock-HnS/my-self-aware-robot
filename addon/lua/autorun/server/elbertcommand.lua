util.AddNetworkString("resetelbertbar")

concommand.Add("elbert_resetbar", function(ply, cmd, args)
    net.Start("resetelbertbar")
    net.Broadcast()
end)