# Discordia-Commands

A commands library for the [Discordia](https://github.com/SinisterRectus/Discordia)

## Installation

1. Open your project folder
2. Run `apt install git && git clone git@github.com:Be1zebub/Discordia-Commands.git deps/discordia-commands`
3. Have fun ;)

## Examples

```lua
local commands = require("discordia-commands")

commands:New("ping")
:SetDescription("Replies pong!")
:SetCallback(function(msg)
	local new = msg:reply("Pong!")
	new:setContent("Pong! `".. math.abs(math.Round((new.createdAt - msg.createdAt) * 1000)) .." ms`")
end)

commands:New("say")
:SetCustomcheck(function(msg)
	return msg.author == msg.client.owner -- is bot owner
end)
:SetCallback(function(msg, args)
	msg:reply(table.concat(args, " "))
	msg:delete()
end)

commands:New("clear", "clean")
:SetGuildOnly(true)
:SetPermissions("administrator")
:SetCooldown(60 * 60, 3) -- allow 3 calls in hour
:SetCallback(function(msg, args)
	local count = tonumber(args[1])
	if count == nil or count < 1 or count > 100 then
		return msg:reply("Out of range! Count should be 1-100.")
	end

	msg.channel:bulkDelete(msg.channel:getMessages(count))
end)

commands:New("help", "commands")
:SetDescription("Shows a commands list")
:SetCooldown(30, 2) -- allow 2 calls in 30 seconds
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

Join to our developers community [incredible-gmod.ru](https://discord.incredible-gmod.ru)
[![thumb](https://i.imgur.com/LYGqTnx.png)](https://discord.incredible-gmod.ru)