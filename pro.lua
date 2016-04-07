-- pro protocol
pro_proto = Proto("pro","Pokemon Revolution Offline protocol")

--[[
	 give pecha berry to pokemon 1 (will replace the item if needed):
	 /giveitem 1, 525
	 take item of Pokemon 1
	 /takeitem 1
]]--

clientToServerPacketInfos = {
	 {"N",   "Talk to NPC"},
	 {"p",   "Pokedex"},
	 {"h",   "Evolution Accept"},
	 {"j",   "Evolution Cancel"},
	 {"+",   "Login"},
	 {"(",   "Battle Action"},
	 {"R",   "Dialogue Choice"},
	 {"M",   "PC"},
	 {"?",   "Reorder Pokemon"},
	 {"}",   "Move"},
	 {"{",   "Chat Send Message"},
	 {"a",   "Shop Move Learner"},
	 {".",   "Shop Egg Learner"},
	 {"c",   "Shop Pokemart"},
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
	 {"*",   "Use Item"},
	 {":",   "Guild Logo"},
	 {"mb",  "No ??"},
	 {"l",   "Purchase Coin"},
	 {"]",   "Purchase Guild Logo"},
	 {"z",   "Purchase Egg Move"},
	 {"b",   "Purchase Move"},
	 {"RE",  "Send Report"},
	 {"f",   "Show Friend"},
	 {"ah",  "Ban"},
	 {"btt", "Ban Speedhack"},
	 {"id",  "Ban Injection"},
	 {"sh",  "Ban Speedhack"},
	 {"2",   "Ask Avatar Refresh"},
	 {"S",   "Send Sync ???"},
	 {"_",   "Pong"},
	 {"-",   "Ask NPC Refresh"},
	 -- k|.|pokecenter lavender|.\
	 {"k",   "Request Map Wild Pokemon", 1, "Map name"},
	 --   follow an instruction like Use Item (*)
	 {"^",   "Teach Move ", 2, "Pokemon (1 to 6)", "Move position (1 to 4 or 0 for none)"}
}

serverToClientPacketInfos = {
	 {"w",   "Chat Message"},
	 {".",   "Ping"},
	 {"-",   "???"},
	 {"U",   "Other player position"},
	 {"E",   "Game Time"},
	 {"i",   "Character Informations"},
	 {"(",   "Cooldowns ???"},
	 {"]",   "Guild Logo Add"},
	 {";",   "Guild Logo Remove"},
	 {"o",   "Handle Shop"},
	 {"l",   "Move Relearn"},
	 {",",   "Egg Move Relearn"},
	 {"7",   "Error Rising Badge"},             -- You will be unable to use Pokemon from other regions in this region until you earn the Rising Badge!
	 {"8",   "Error Invalid Region Trade"},     -- The person you are trading with can not take Pokemon from another region.
	 {"9",   "Error Trade Pokemon Quest Item"}, -- You can not trade a Pokemon that it is holding a Quest Item.
	 {"0",   "Error Trade Legendary"},          -- You can not trade a Legendary Pokemon.
	 {"'",   "Does nothing?"},
	 {"k",   "Map Wild Pokemon"},
	 {"x",   "Pokemon Happyness"},
	 {"p",   "Pokedex Message"},
	 {"t",   "Trade"},
	 {"tb",  "Trade Accept? with args"},
	 {"tu",  "Trade Update"},
	 {"ta",  "Trade Accept"},
	 {"tc",  "Trade Cancel"},
	 {"m",   "Start Combat"},
	 {"h",   "Evolution"},
	 {"z",   "Receive Position"},
	 {"pm",  "Receive a Private Message"},
	 {"&",   "Receive items"},
	 {"^",   "Learned Move"},
	 {"mb",  "Start battle?"},
	 {"!",   "Show Battle"},
	 {"@",   "Creates NPC"},
	 {"*",   "Creates All NPC"},
	 {"a",   "Battle Text"},
	 {"$",   "Use Bike", 1, "always 1?"},
	 {"%",   "Use Surf"},
	 {"r",   "Handle Script"},
	 {"c",   "Chat Create Channel"},
	 {"g",   "Friend Connection Alert"},
	 {"f",   "Friend List Sort"},
	 {"[",   "Roster Sort"},
	 {"e",   "Send Meteo"},
	 {"u",   "???"},
	 {"S",   "Avatar Location"},
	 {"s",   "???"},
	 {"q",   "Map Load"},
	 {"y",   "Guild Info"},
	 {"i",   "Guild Join"},
	 {"d",   "Money"},
	 {"(",   "Fishing CD"},
	 {"5",   "Login"},
	 {"6",   "Login Invalid User"},
	 {"1",   "Create NPC"},
	 {")",   "Login Queue"},
	 {"R",   "Dialogue"},
	 {"#",   "Profile Update"}
}

local endOfPacket = [[.\]] .. "\r\n"

function dissectParameters(data, packetStart, packet)
	 local parameterId = 1
	 local index = 0
	 while true do
			-- TODO: pass the parameters without the header to avoid redondance
			local parameterStart, parameterEnd, parameter = packet:find("|%.|(.-|)%.", index)
			-- do not even try to understand this, just because a Lua array starts at 1 it is a freaking mess
			local offset = 1
			
			if parameter == nil then
				 -- exception for the stupig Uparam1|param2 instead of u|.|param1|param2
				 parameterStart, parameterEnd, parameter = packet:find("U(.-|)%.", index)
				 offset = -1
				 if parameter == nil then break end
			end
			
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
			local subParamsTree = data.tree:add(data.buffer(packetStart + parameterStart + offset, parameter:len() - 1),
																					"Parameter" .. parameterId .. ": " .. parameter:sub(1, parameter:len() - 1))
			if #subParams > 1 then
				 local i = 1
				 while i <= #subParams do
						local iString = "" .. i
						if i < 10 then
							 istring = "0" .. iString
						end
						-- offset - 1 because the subParameterStart was starting at 1
						subParamsTree:add(data.buffer(packetStart + parameterStart + offset - 1 + subParams[i][1], subParams[i][3]:len()),
															"SubParameter" .. iString .. ": " .. subParams[i][3])
						i = i + 1
				 end
			end
			
			parameterId = parameterId + 1
			index = parameterEnd - 1
	 end
end

function dissectPacket(packetInfo, data, packetStart, packetEnd, packet, headersFound)
	 data.tree:add(data.buffer(packetStart - 1, packetEnd - packetStart), "Description: " .. packetInfo[2])
	 data.tree:add(data.buffer(packetStart - 1, packetInfo[1]:len()),     "Header:      " .. packetInfo[1])
	 dissectParameters(data, packetStart, packet)
	 data.tree:add(data.buffer(packetStart - 1, packetEnd - packetStart), "Packet:      " .. packet)
	 packetFound = true
	 localPacketFound = true
	 if headersFound[packetInfo[2]] == nil then
			headersFound[packetInfo[2]] = 0
	 end
	 headersFound[packetInfo[2]] = headersFound[packetInfo[2]] + 1
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
				 if packet:find(packetInfo[1] .. "|", 1, true) == 1 then
						dissectPacket(packetInfo, data, packetStart, packetEnd, packet, headersFound)
						packetFound = true
						localPacketFound = true
						break
				 end
			end
			if localPacketFound == false and packet:find(serverToClientPacketInfos[4][1], 1, true) == 1 then
				 dissectPacket(serverToClientPacketInfos[4], data, packetStart, packetEnd, packet, headersFound)
				 packetFound = true
				 localPacketFound = true
			elseif localPacketFound == false then
				 local headerStart, headerEnd, header = packet:find("(.-|)", index)
				 dissectPacket({header, "UNKNOWN"}, data, packetStart, packetEnd, packet, headersFound)
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
	 data.tree:add(buffer(0,buffer:len()), data.proData)
end
-- load the tcp.port table
tcp_table = DissectorTable.get("tcp.port")
-- register our protocol to handle tcp port 800
tcp_table:add(800,pro_proto)
