-- pro protocol
pro_proto = Proto("pro","Pokemon Revolution Offline protocol")

--[[
	 give pecha berry to pokemon 1 (will swap the item if needed):
	 /giveitem 1, 525
	 take item of Pokemon 1
	 /takeitem 1
]]--

Packet = {header, description, parameters = {}}
function Packet:new(o)
	 o = o or {}   -- create object if user does not provide one
	 setmetatable(o, self)
	 self.__index = self
	 
	 self.header      = o[1]
	 self.description = o[2]
	 self.parameters  = o[3]
	 return o
end

clientToServerPacketInfos = {
	 Packet.new{"N",   "Talk to NPC", {"NPC ID"}},
	 -- param a to receive details
	 -- param l to receive the list
	 Packet.new{"p",   "Request Pokedex", "a: details, l: list"},
	 Packet.new{"h",   "Evolution accept"},
	 Packet.new{"j",   "Evolution cancel"},
	 Packet.new{"+",   "Login"},
	 Packet.new{"(",   "Battle action"},
	 Packet.new{"R",   "Dialogue choice"},
	 Packet.new{"M",   "PC"},
	 Packet.new{"?",   "Reorder pokemon"},
	 Packet.new{"}",   "[DEPRECATED] Move", {"Direction"}},
	 Packet.new{"#",   "Move", {"Direction"}},
	 -- This does the same as '{' to send a chat message but in practice is only used for surf, destroy and dive commands
	 Packet.new{"w",   "Send surf, destroy and dive"},
	 Packet.new{"a",   "Shop move learner"},
	 Packet.new{".",   "Shop egg learner"},
	 Packet.new{"c",   "Shop pokemart"},
	 --[[ 
			#155 Escape Rope
			>	*|.|155|.\
			>	-|.\
			> k|.|pokecenter lavender|.\
			> S|.\
			
			> *|.|317|.|1|.\  use item 317 (HM01 - Cut) on Pokemon 1
			< ^|.|348|.|Cut|.|1|.|30|.\
			> ^|.|1|.|1|.\    make pokemon1 forget attack1

			- 8/10/15     useItem out of combat
			- 2/13/14/3/9 useItem on Pokemon out of combat
			- 5           useItem in combat
			- 2           useItem on Pokemon in combat
	 ]]--
	 Packet.new{"*",   "Use item"},
	 Packet.new{":",   "Guild logo"},
	 Packet.new{"mb",  "Valid action"},
	 Packet.new{"l",   "Purchase coin"},
	 Packet.new{"]",   "Purchase guild logo"},
	 Packet.new{"z",   "Purchase egg move"},
	 Packet.new{"b",   "Purchase move"},
	 Packet.new{"RE",  "Send report"},
	 Packet.new{"f",   "Show friend"},
	 Packet.new{"ah",  "Ban"},
	 Packet.new{"btt", "Ban speedhack"},
	 Packet.new{"id",  "Ban injection"},
	 Packet.new{"sh",  "Ban speedhack"},
	 -- when entering a new zone or interacting with an NPC
	 Packet.new{"S",   "Synchronize character"},
	 Packet.new{"-",   "Ask NPC refresh"},
	 -- k|.|pokecenter lavender|.\
	 Packet.new{"k",   "Request wild pokemon map", {"Map name"}},
	 --   follow an instruction like Use Item (*)
	 Packet.new{"^",   "Teach move", {"PokemonUid", "MoveUid"}},
	 Packet.new{"{",   "Send message", {"Message"}},
	 Packet.new{"1",   "Heartbeat 1 (anti-cheat)"},
	 -- Was used to ask the server to refresh the player on the other client around
	 Packet.new{"2",   "Heartbeat 2 (anti-cheat)"},
	 Packet.new{"x",   "Ready for Battle"},
	 -- for any ping
	 Packet.new{"_",   "Pong"},
	 -- only for "'" request
	 Packet.new{"'",   "Pong '"},
	 Packet.new{"M",   "Request PC box"},
	 Packet.new{")",   "Login success" },
	 -- just a guess
	 Packet.new{"g",   "Send online info to friend" },
	 Packet.new{"=",   "Show mailbox" },
	 Packet.new{"<",   "Move move up" },
	 Packet.new{">",   "Move move down" },
	 Packet.new{",",   "Reset IVs" },
	 Packet.new{"RE",  "Send report" }
}

serverToClientPacketInfos = {
	 Packet.new{"w",   "Chat message", {"Message"}},
	 Packet.new{".",   "Ping ."},
	 Packet.new{"-",   "???"},
	 Packet.new{"U",   "[OBSOLETE] Other player info", {{"Nickname"}}},
	 Packet.new{"E",   "Game time"},
	 Packet.new{"i",   "Character informations"},
	 Packet.new{"(",   "Cooldowns ???"},
	 Packet.new{"]",   "Guild logo add"},
	 Packet.new{";",   "Guild logo remove"},
	 Packet.new{"o",   "Handle shop"},
	 Packet.new{"l",   "Move relearn"},
	 Packet.new{",",   "Egg move relearn"},
	 Packet.new{"7",   "Error rising badge"},             -- You will be unable to use Pokemon from other regions in this region until you earn the Rising Badge!
	 Packet.new{"8",   "Error invalid region trade"},     -- The person you are trading with can not take Pokemon from another region.
	 Packet.new{"9",   "Error trade pokemon quest item"}, -- You can not trade a Pokemon that it is holding a Quest Item.
	 Packet.new{"0",   "Error trade legendary"},          -- You can not trade a Legendary Pokemon.
	 Packet.new{"'",   "Ping '"},
	 Packet.new{"k",   "Map wild pokemon"},
	 Packet.new{"x",   "Pokemon happyness"},
	 Packet.new{"p",   "Pokedex message"},
	 Packet.new{"t",   "Trade"},
	 Packet.new{"tb",  "Trade accept? with args"},
	 Packet.new{"tu",  "Trade update"},
	 Packet.new{"ta",  "Trade accept"},
	 Packet.new{"tc",  "Trade cancel"},
	 Packet.new{"m",   "Start combat"},
	 Packet.new{"h",   "Evolution"},
	 Packet.new{"z",   "Receive position"},
	 Packet.new{"pm",  "Private message"},
	 Packet.new{"&",   "Item list"},
	 Packet.new{"^",   "Learning move"},
	 Packet.new{"mb",  "Action condition"},
	 Packet.new{"!",   "Show battle"},
	 Packet.new{"@",   "NPC"},
	 Packet.new{"*",   "NPC list"},
	 Packet.new{"a",   "Battle text"},
	 Packet.new{"$",   "Use bike", 1, "always 1?"},
	 Packet.new{"%",   "Use surf"},
	 Packet.new{"r",   "Handle script"},
	 Packet.new{"c",   "Chat create channel"},
	 Packet.new{"g",   "Friend connection alert"},
	 Packet.new{"f",   "Friend list sort"},
	 Packet.new{"[",   "Roster sort"},
	 Packet.new{"e",   "Send meteo"},
	 Packet.new{"u",   "???"},
	 Packet.new{"S",   "Avatar location"},
	 Packet.new{"s",   "???"},
	 Packet.new{"q",   "Map load"},
	 Packet.new{"y",   "Guild info"},
	 Packet.new{"i",   "Guild join"},
	 Packet.new{"d",   "Money"},
	 Packet.new{"(",   "Fishing cooldown"},
	 Packet.new{"5",   "Login (ping _)"},
	 Packet.new{"6",   "Login invalid user"},
	 Packet.new{"1",   "Create NPC"},
	 Packet.new{")",   "Login queue (ping _)"},
	 Packet.new{"R",   "Dialogue"},
	 Packet.new{"#",   "Profile update"},
	 Packet.new{"C",   "Channel list", {{"Count", "ID", "Name"}}},
	 Packet.new{"=",   "Other player info", {{"Nickname", "x", "y"}}},
	 Packet.new{"<",   "Inspection info", {{"Nickname", "Wins", "Losses", "Disconnects", "Subscription date", "?", "Play time", "Total Pokemon", "Appearance"}}}
}

local endOfPacket = "%.\\\r\n"

function dissectParameters(packetInfo, packetTree, data, offset, packet)
	 local parameterId = 1
	 local index = 0
	 while true do
			-- no regexp in Lua, its pattern matching has some limitations
			local parameterStart, parameterEnd, parameter = packet:find("(.-|)%.|", index)
			if parameter == nil then
						 parameterStart, parameterEnd, parameter = packet:find("(.-|)%.\\", index)
			end
			-- do not even try to understand this, just because a Lua array starts at 1 it is a freaking mess
			local loffset = 1
			
			if parameter == nil then break end
			
			local subParams = {}
			local subIndex = 0
			local subId = 1
			while true do
				 local subParameterStart, subParameterEnd, subParameter = parameter:find("(.-)|", subIndex)
				 if subParameter == nil then break end
				 subParams[subId] = {subParameterStart, subParameterEnd, subParameter}
				 subIndex = subParameterEnd + 1
				 subId = subId + 1
			end
			-- parameter:sub(1, parameter:len() - 1) remove the trailing '|'
			local parameterName = "Parameter" .. parameterId
			local subParametersNames
			if packetInfo.parameters ~= nil
				 and packetInfo.parameters[parameterId] ~= nil
			then
				 if type(packetInfo.parameters[parameterId]) == "string" then
						parameterName = packetInfo.parameters[parameterId]
				 elseif type(packetInfo.parameters[parameterId]) == "table" then
						subParametersNames = packetInfo.parameters[parameterId]
				 end
			end
			local subParamsTree = packetTree:add(data.buffer(offset + parameterStart + loffset, parameter:len() - 1),
																					parameterName .. ": " .. parameter:sub(1, parameter:len() - 1))
			if #subParams > 1 then
				 local i = 1
				 while i <= #subParams do
						local iString = "" .. i
						if i < 10 then
							 istring = "0" .. iString
						end
						-- loffset - 1 because the subParameterStart was starting at 1
						local subParameterName = "SubParameter" .. iString
						if subParametersNames ~= nil
							 and subParametersNames[i] ~= nil
							 and type(subParametersNames[i]) == "string"
						then
							 subParameterName = subParametersNames[i]
						end

						subParamsTree:add(data.buffer(offset + parameterStart + loffset - 1 + subParams[i][1], subParams[i][3]:len()),
															subParameterName .. ": " .. subParams[i][3])
						i = i + 1
				 end
			end
			
			parameterId = parameterId + 1
			index = parameterEnd + 1
	 end
end

function dissectPacket(packetInfo, data, packetStart, packetEnd, packet, headersFound)
	 local packetTree = data.tree:add(data.buffer(packetStart - 1, packetEnd - packetStart), "Description: " .. packetInfo.description)
	 packetTree:add(data.buffer(packetStart - 1, packetInfo.header:len()),     "Header:      " .. packetInfo.header)

	 
	 local parametersStart, parametersEnd, parameters
	 if packetInfo.header == "U" then
			parametersStart, parametersEnd, parameters = packet:find("U(.*)")
			parametersStart = parametersStart - 3
	 else
			parametersStart, parametersEnd, parameters = packet:find(".-|%.|(.*)")
	 end
	 if parameters ~= nil then
			dissectParameters(packetInfo, packetTree, data, packetStart + parametersStart, parameters)
	 end
	 packetTree:add(data.buffer(packetStart - 1, packetEnd - packetStart), "Packet:      " .. packet)
	 packetFound = true
	 localPacketFound = true
	 if headersFound[packetInfo.description] == nil then
			headersFound[packetInfo.description] = 0
	 end
	 headersFound[packetInfo.description] = headersFound[packetInfo.description] + 1
end

function bindPacket(packetList, data)
	 local packetFound = false
	 local index = 1
	 local headersFound = {}
	 
	 while true do
			local packetStart, packetEnd, packet = data.proData:find("(.-" .. endOfPacket .. ")", index)
			if packet == nil then break end
			local localPacketFound = false
			for i, packetInfo in ipairs(packetList) do
				 if packet:find(packetInfo.header .. "|", 1, true) == 1 then
						dissectPacket(packetInfo, data, packetStart, packetEnd, packet, headersFound)
						packetFound = true
						localPacketFound = true
						break
				 end
			end
			if localPacketFound == false and packet:find(serverToClientPacketInfos[4].header, 1, true) == 1 then
				 dissectPacket(serverToClientPacketInfos[4], data, packetStart, packetEnd, packet, headersFound)
				 packetFound = true
				 localPacketFound = true
			elseif localPacketFound == false then
				 local headerStart, headerEnd, header = packet:find("(.-|)", index)
				 dissectPacket(Packet:new{header, "UNKNOWN"}, data, packetStart, packetEnd, packet, headersFound)
			end
			index = packetEnd + 1
	 end

	 index = 1
	 for headerName, headerCount in pairs(headersFound) do
			if index ~= 1 then
				 data.infoField = data.infoField .. "|"
			end
			data.infoField = data.infoField .. headerName
			if headerCount > 1 then
				 data.infoField = data.infoField .. [[(x]] .. headerCount .. [[)]]
			end
			index = index + 1
	 end
	 return packetFound
end

-- create a function to dissect it
function pro_proto.dissector(buffer,pinfo,tree)
	 pinfo.cols.protocol = "PRO"

	 local data = {
			buffer = buffer,
			pinfo = pinfo,
			proData = "",
			tree = tree:add(pro_proto, buffer(), "PRO Protocol ProData"),
			infoField = ""
	 }

	 local i = 0
	 while i < buffer:len() do
			data.proData = data.proData .. string.char(bit.bxor(buffer(i,1):uint(), 1))
			i = i + 1
	 end
	 
	 local packetFound = false
	 if pinfo.src_port == 800 then
			data.infoField = "[s]"
			data.tree:add(buffer(0,buffer:len()), "server -> client")
			packetFound = bindPacket(serverToClientPacketInfos, data)
	 else
			data.infoField = "[c]"
			data.tree:add(buffer(0,buffer:len()), "client -> server")
			packetFound = bindPacket(clientToServerPacketInfos, data)
	 end
	 pinfo.cols.info = data.infoField;
	 -- data.tree:add(buffer(0,buffer:len()), data.proData)
end
-- load the tcp.port table
tcp_table = DissectorTable.get("tcp.port")
-- register our protocol to handle tcp port 800
tcp_table:add(800,pro_proto)
