-- from incredible-gmod.ru with <3
-- rate-limiter

--[[ usage example:
local rateLimit = require("ratelimit")

function channel:onReceiveMessage(msg)
	if self.rateLimiter == nil then
		self.rateLimiter = rateLimit(5, 5, true) -- allow 5 messages per 5 seconds per channel (ratelimiter storage is weak in this case)
	end

	if self.rateLimiter(msg.author.id) then
		self:pushMessage(msg) -- push message to channel if ratelimit not reached
	end
end
]]--

--[[ usage example 2:
local rateLimiter = require("ratelimit")(60 * 60, 3) -- allow 3 bans per 1 hour

function canBan(admin, user)
	if rateLimiter(admin.id) then
		ban(admin, user)
	end
end
]]--

-- src:

return function(length, count, weak, getTime)
	getTime = getTime or os.time

	local storage = weak and setmetatable({}, {__mode = "k"}) or {}
	local bans = {}

	return function(uid)
		local curTime = getTime()

		if bans[uid] then
			if bans[uid] > curTime then
				return true, bans[uid] - curTime
			end
			bans[uid] = nil
		end

		local instance = storage[uid]
		if instance == nil then
			instance = weak and setmetatable({}, {__mode = "k"}) or {}
			storage[uid] = instance
		end

		if #instance == count then
			local lmit_reached, min = true, math.huge

			for i = count, 1, -1 do
				if instance[i] < curTime - length then
					instance[i] = nil
					lmit_reached = false
				else
					min = math.min(min, instance[i])
				end
			end

			if lmit_reached then
				local left = length + curTime - min
				bans[uid] = curTime + left

				return true, left
			end
		end

		table.insert(instance, curTime)
		return false
	end
end