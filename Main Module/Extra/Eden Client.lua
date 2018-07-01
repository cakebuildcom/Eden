--This is a local script inside Modules.Server

replicated = game.ReplicatedStorage:WaitForChild("EdenAuth"):InvokeServer(
	"***********" --read MainModule.Modules.Server.lua
)
client = require(replicated.Modules.Client)
client.Install(replicated)
