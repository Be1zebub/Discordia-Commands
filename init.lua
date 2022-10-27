-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Discordia-Commands

local ratelimit = require("ratelimit")

local Commands, CommandsMap, Aliases = {}, {}, {}
local Command, get = require("discordia").class("Command")
local meta = getmetatable(Command)

function Command:__call(name, ...)
	if CommandsMap[name] then
		self:__init(name, ...)
	else
		meta.__call(self, name, ...)

		self._id = #Commands + 1
		Commands[self._id] = self
		CommandsMap[name] = self
	end
end

function Command:__init(name, ...)
	self._name = name
	self._aliases = {}
	self:SetAlias(...)
end

-- setters

function Command:SetName(name)
	self._name = name
	return self
end

function Command:SetDescription(description)
	self._description = description
	return self
end

function Command:SetCallback(callback)
	self._callback = callback
	return self
end

function Command:SetCustomcheck(customcheck)
	self._customcheck = customcheck
	return self
end

function Command:SetGuildOnly(bool)
	self._guildonly = bool ~= false
	return self
end

function Command:SetPermissions(...)
	self._permissions = {...}
	return self
end

function Command:SetCooldown(length, count, weak)
	self._cooldown = ratelimit(length, count, weak)
	return self
end

function Command:SetAlias(...)
	if ... then
		for _, alias in ipairs({...}) do
			Aliases[alias] = self
			self._aliases[#self._aliases + 1] = alias
		end
	end

	return self
end

-- getters

function get.name(self)
	return self._name
end

function get.description(self)
	return self._description
end

function get.callback(self)
	return self._callback
end

function get.customcheck(self)
	return self._customcheck
end

function get.guildonly(self)
	return self._guildonly
end

function get.permissions(self)
	return self._permissions
end

function get.cooldown(self)
	return self._cooldown
end

function get.aliases(self)
	return self._aliases
end

-- helpers

local function stringSplit(pString, pPattern)
	local tbl = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = pString:find(fpat, 1)

	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(tbl, cap)
		end

		last_end = e + 1
		s, e, cap = pString:find(fpat, last_end)
	end

	if last_end <= #pString then
		cap = pString:sub(last_end)
		table.insert(tbl, cap)
	end

	return tbl
end

local numberReacts = setmetatable({
	["0"] = "0️⃣",
	["1"] = "1️⃣",
	["2"] = "2️⃣",
	["3"] = "3️⃣",
	["4"] = "4️⃣",
	["5"] = "5️⃣",
	["6"] = "6️⃣",
	["7"] = "7️⃣",
	["8"] = "8️⃣",
	["9"] = "9️⃣",
}, {
	__call = function(self, msg, num)
		for char in tostring(math.floor(num)):gmatch(".") do
			if self[char] then
				msg:addReaction(self[char])
			end
		end
	end
})

--

return setmetatable({
	list = Commands,
	map = CommandsMap,
	aliases = Aliases,
	New = function(_, name, desc)
		return Command(name, desc)
	end,
	Example = function()
		Command("help", "commands")
		:SetDescription("Shows a commands list")
		:SetCooldown(30, 1)
		:SetCallback(function(msg, args)
			local cmdName = args[1]

			if cmdName then
				local cmd = CommandsMap[cmdName] or Aliases[cmdName]

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

				for _, cmd in ipairs(Commands) do
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

		Command("ping")
		:SetDescription("Replies pong!")
		:SetCallback(function(msg)
			local new = msg:reply("Pong!")
			new:setContent("Pong! `".. math.abs(math.Round((new.createdAt - msg.createdAt) * 1000)) .." ms`")
		end)
	end
}, {
	__call = function(_, prefix, msg)
		if msg.author.bot then return end

		local args = stringSplit(msg.content, " ")
		local command = prefix .. table.remove(args, 1)

		local cmd = CommandsMap[command] or Aliases[command]
		if (cmd and cmd.callback) == nil then return end

		if cmd.customcheck and cmd.customcheck(msg) == false then
			msg:reply("You dont have permissions to run this command!")
			return false
		end

		if cmd.guildonly and msg.guild == nil then
			msg:reply("You cant use this command in DM!")
			return false
		end

		if cmd.permissions then
			if msg.member == nil then return false end -- permissions in dm? bruh, its guild only feature

			for _, permission in ipairs(cmd.permissions) do
				if msg.member:hasPermission(permission) == false then
					msg:reply("You dont have permissions to run this command!")
					return false
				end
			end
		end

		if cmd.cooldown then
			local cooldown, left = cooldown(msg.author.id)
			if cooldown then
				msg:addReaction("🕖")
				numberReacts(msg, left)
				return false
			end
		end

		cmd.callback(msg, args)
		return true
	end
})