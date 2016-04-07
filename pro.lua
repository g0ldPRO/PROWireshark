-- pro protocol
pro_proto = Proto("pro","Pokemon Revolution Offline protocol")

--[[
	 give pecha berry to pokemon 1 (will replace the item if needed):
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
	 Packet.new{"N",   "Talk to NPC"},
	 Packet.new{"p",   "Pokedex"},
	 Packet.new{"h",   "Evolution Accept"},
	 Packet.new{"j",   "Evolution Cancel"},
	 Packet.new{"+",   "Login"},
	 Packet.new{"(",   "Battle Action"},
	 Packet.new{"R",   "Dialogue Choice"},
	 Packet.new{"M",   "PC"},
	 Packet.new{"?",   "Reorder Pokemon"},
	 Packet.new{"}",   "Move"},
	 Packet.new{"Packet.new{",   "Chat Send Message"},
	 Packet.new{"a",   "Shop Move Learner"},
	 Packet.new{".",   "Shop Egg Learner"},
	 Packet.new{"c",   "Shop Pokemart"},
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
	 Packet.new{"*",   "Use Item"},
	 Packet.new{":",   "Guild Logo"},
	 Packet.new{"mb",  "No ??"},
	 Packet.new{"l",   "Purchase Coin"},
	 Packet.new{"]",   "Purchase Guild Logo"},
	 Packet.new{"z",   "Purchase Egg Move"},
	 Packet.new{"b",   "Purchase Move"},
	 Packet.new{"RE",  "Send Report"},
	 Packet.new{"f",   "Show Friend"},
	 Packet.new{"ah",  "Ban"},
	 Packet.new{"btt", "Ban Speedhack"},
	 Packet.new{"id",  "Ban Injection"},
	 Packet.new{"sh",  "Ban Speedhack"},
	 Packet.new{"2",   "Ask Avatar Refresh"},
	 Packet.new{"S",   "Send Sync ???"},
	 Packet.new{"_",   "Pong"},
	 Packet.new{"-",   "Ask NPC Refresh"},
	 -- k|.|pokecenter lavender|.\
	 Packet.new{"k",   "Request Map Wild Pokemon", {"Map name"}},
	 --   follow an instruction like Use Item (*)
	 Packet.new{"^",   "Teach Move", {"PokemonUid", "MoveUid"}}
}

serverToClientPacketInfos = {
	 Packet.new{"w",   "Chat Message", {"Message"}},
	 Packet.new{".",   "Ping"},
	 Packet.new{"-",   "???"},
	 Packet.new{"U",   "Other player position", {{"Nickname"}}},
	 Packet.new{"E",   "Game Time"},
	 Packet.new{"i",   "Character Informations"},
	 Packet.new{"(",   "Cooldowns ???"},
	 Packet.new{"]",   "Guild Logo Add"},
	 Packet.new{";",   "Guild Logo Remove"},
	 Packet.new{"o",   "Handle Shop"},
	 Packet.new{"l",   "Move Relearn"},
	 Packet.new{",",   "Egg Move Relearn"},
	 Packet.new{"7",   "Error Rising Badge"},             -- You will be unable to use Pokemon from other regions in this region until you earn the Rising Badge!
	 Packet.new{"8",   "Error Invalid Region Trade"},     -- The person you are trading with can not take Pokemon from another region.
	 Packet.new{"9",   "Error Trade Pokemon Quest Item"}, -- You can not trade a Pokemon that it is holding a Quest Item.
	 Packet.new{"0",   "Error Trade Legendary"},          -- You can not trade a Legendary Pokemon.
	 Packet.new{"'",   "Does nothing?"},
	 Packet.new{"k",   "Map Wild Pokemon"},
	 Packet.new{"x",   "Pokemon Happyness"},
	 Packet.new{"p",   "Pokedex Message"},
	 Packet.new{"t",   "Trade"},
	 Packet.new{"tb",  "Trade Accept? with args"},
	 Packet.new{"tu",  "Trade Update"},
	 Packet.new{"ta",  "Trade Accept"},
	 Packet.new{"tc",  "Trade Cancel"},
	 Packet.new{"m",   "Start Combat"},
	 Packet.new{"h",   "Evolution"},
	 Packet.new{"z",   "Receive Position"},
	 Packet.new{"pm",  "Receive a Private Message"},
	 Packet.new{"&",   "Receive items"},
	 Packet.new{"^",   "Learned Move"},
	 Packet.new{"mb",  "Start battle?"},
	 Packet.new{"!",   "Show Battle"},
	 Packet.new{"@",   "Creates NPC"},
	 Packet.new{"*",   "Creates All NPC"},
	 Packet.new{"a",   "Battle Text"},
	 Packet.new{"$",   "Use Bike", 1, "always 1?"},
	 Packet.new{"%",   "Use Surf"},
	 Packet.new{"r",   "Handle Script"},
	 Packet.new{"c",   "Chat Create Channel"},
	 Packet.new{"g",   "Friend Connection Alert"},
	 Packet.new{"f",   "Friend List Sort"},
	 Packet.new{"[",   "Roster Sort"},
	 Packet.new{"e",   "Send Meteo"},
	 Packet.new{"u",   "???"},
	 Packet.new{"S",   "Avatar Location"},
	 Packet.new{"s",   "???"},
	 Packet.new{"q",   "Map Load"},
	 Packet.new{"y",   "Guild Info"},
	 Packet.new{"i",   "Guild Join"},
	 Packet.new{"d",   "Money"},
	 Packet.new{"(",   "Fishing CD"},
	 Packet.new{"5",   "Login"},
	 Packet.new{"6",   "Login Invalid User"},
	 Packet.new{"1",   "Create NPC"},
	 Packet.new{")",   "Login Queue"},
	 Packet.new{"R",   "Dialogue"},
	 Packet.new{"#",   "Profile Update"}
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
