# Discordia-Commands

A commands library for the [Discordia](https://github.com/SinisterRectus/Discordia)

## Installation

1. Open your project folder
2. Run `apt install git && git clone git@github.com:Be1zebub/Discordia-Commands.git deps/discordia-commands`
3. Have fun ;)

## Example

```lua
local commands = require("discordia-commands")

commands:New("ping")
:SetDescription("Replies pong!")
:SetCallback(function(msg)
	local new = msg:reply("Pong!")
	new:setContent("Pong! `".. math.abs(math.Round((new.createdAt - msg.createdAt) * 1000)) .." ms`")
end)

commands:New("help", "commands")
:SetDescription("Shows a commands list")
:SetCooldown(30, 1)
:SetCallback(function(msg, args)
	local cmdName = args[1]

	if cmdName then
		local cmd = commands.map[cmdName] or commands.aliases[cmdName]

		if cmd == nil then
			msg:reply("Unknown command!")
			return
		end

		local desc = cmd.description

		if desc == nil then
			msg:reply("This command has no description!")
			return
		end

		if cmd.aliases then
			desc = desc .."\nAliases: **".. table.concat(cmd.aliases, ", ") .."**"
		end

		msg:reply({
			embed = {
				title = cmdName,
				description = desc,
				color = 0x2895C8
			}
		})
	else
		local commands = {}

		for _, cmd in ipairs(commands.list) do
			if cmd.description then
				commands[#commands + 1] = "**" .. cmd.name .. ":** " .. cmd.description
			end
		end

		msg:reply({
			embed = {
				title = "Commands list:",
				description = table.concat(commands, "\n"),
				color = 0x2895C8
			}
		})
	end
end)

local client = require("discordia").Client()

client:on("messageCreate", commands) -- listen for new commands
client:run("Bot YourTokenHere")
```