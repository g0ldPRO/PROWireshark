-- pro protocol
pro_proto = Proto("pro","Pokemon Revolution Offline protocol")

clientToServerPacketInfos = {
	 {"N",   "Talk to NPC"},
	 {"p",   "Pokedex"},
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
	 {"c",   "Shope Pokemart"},
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
	 {"2",   "Ask Players Refresh"},
	 {"S",   "Send Sync ???"},
	 {"_",   "Pong"},
	 {"-",   "???"},
	 {"k",   "Move To Teleporter"}
}

serverToClientPacketInfos = {
	 {"w",   "Chat Message"},
	 {".",   "Ping"},
	 {"-",   "???"},
	 {"U",   "Other player position"},
	 {"E",   "Game Time"},
	 {"i",   "Character Informations"},
	 {"(",   "???"},
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
	 {"k",   "Map Wild Pokemons"},
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
	 {"$",   "Use Bike"},
	 {"%",   "Use Surf"},
	 {"r",   "Handle Script"},
	 {"c",   "Chat Create Channel"},
	 {"g",   "Friend Connection Alert"},
	 {"f",   "Friend List Sort"},
	 {"[",   "Roster Sort"},
	 {"#",   "PC Open"},
	 {"e",   "Send Meteo"},
	 {"u",   ""},
	 {"S",   "Avatar Location"},
	 {"s",   ""},
	 {"q",   "Map Load"},
	 {"y",   "Guild Info"},
	 {"i",   "Guild Join"},
	 {"d",   "Money"},
	 {"(",   "Fishing CD"},
	 {"5",   "Login"},
	 {"6",   "Login Invalid User"},
	 {"1",   "Create NPC"},
	 {")",   "Login Queue"},
	 {"R",   "Dialogue"}
}

local endOfPacket = [[|.\]] .. "\r\n"

function bindPacket(packetList, data)
	 local packetFound = false
	 local index = 1
	 local headersFound = {}
	 
	 while true do
			local matchStart, matchEnd, packet = data.proData:find("(.-" .. endOfPacket .. ")", index)
			if packet == nil then break end
			local localPacketFound = false
			for i, packetInfo in ipairs(packetList) do
				 if packet:find(packetInfo[1], 1, true) == 1 then
						data.tree:add(data.buffer(0,data.buffer:len() - 1),   "Description: " .. packetInfo[2])
						data.tree:add(data.buffer(0,packetInfo[1]:len() - 1), "Header:      " .. packetInfo[1])
						data.tree:add(data.buffer(0,packetInfo[1]:len() - 1), "Packet:      " .. packet)
						packetFound = true
						if headersFound[packetInfo[2]] == nil then
							 headersFound[packetInfo[2]] = 0
						end
						headersFound[packetInfo[2]] = headersFound[packetInfo[2]] + 1
						localPacketFound = true
						break
				 end
			end
			if localPacketFound == false then
				 if headersFound["UNKNOWN"] == nil then
						headersFound["UNKNOWN"] = 0
				 end
				 headersFound["UNKNOWN"] = headersFound["UNKNOWN"] + 1
			end
			index = matchEnd + 1
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
	 data.tree:add(buffer(0,buffer:len() - 1), data.proData)
end
-- load the tcp.port table
tcp_table = DissectorTable.get("tcp.port")
-- register our protocol to handle tcp port 800
tcp_table:add(800,pro_proto)

-- local wtap_encap_table = DissectorTable.get("wtap_encap")
-- local tcp_encap_table  = DissectorTable.get("tcp.port")
-- wtap_encap_table:add(1, pro_proto)
-- tcp_encap_table:add(800,pro_proto)
