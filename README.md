# PROWireshark

I made a **Lua** dissector for [Wireshark](https://www.wireshark.org/), an open source protocol analyser.

[Link](https://gist.github.com/g0ldPRO/4a089d3332a1ef8445b39c17f337133f)

(I blame [lua-mode.el](http://immerrr.github.io/lua-mode/) for the absurd extra tabulations)

##What does it mean?

To communicate from the game client to the server and the server to the game client, PRO is sending data via network. Those data contain informations such as *"I am moving to the right"* (client to server) or *"A wild pokemon attacks"* (server to client).

The goal of Wireshark is to show the packets of data that PRO sends on your network. The syntax used to write those data is defined in what we call a [protocol](https://en.wikipedia.org/wiki/Wireshark).

##The Protocol

The protocol of PRO is a text protocol (in opposition with a binary protocol), an instruction looks like this: `HEADER|.|PARAMETER1|.|PARAMETER2|.\\r\n`

 * `|.|` is a separator.
 * `|.\[\\r\\n]`(https://en.wikipedia.org/wiki/Newline) is the end of an instruction.

As defined by the TCP protocol, a packet can contain several concatenated instructions (see the wireshark section).

A move (client->server)

> `}|.|d|.\\r\n`

> The header is *"}"*, it means the command is a move.

> The parameter *d* means *"down"*. The others valid parameters are, obviously, *u*, *l* and *r*.

A chat message (server->client)

> `w|.|(Trade) [n=Floresta][/n]: buy gastly or abra perfect stat wisp|.\`

> The header is *w*, it means the command is a chat message.

> The 2nd parameter is the message (including the name of the channel and the sender with a silly syntax).

An example of packet without any parameter

> *"2"* is asking the server to refresh our player on the map : `2|.\`

The protocol is *"encrypted"*, a [XOR](https://en.wikipedia.org/wiki/Bitwise_operation#XOR) 1 has been applied on every byte. To decrypt it you simply need to apply the same operation on every byte of the packet.

We could spend this whole tutorial talking about the terrible choices made by the dev of PRO but that is not our goal.

##Wireshark

* [Download](https://www.wireshark.org/#download) and [install](https://www.wireshark.org/docs/wsug_html_chunked/ChBuildInstallWinInstall.html) Wireshark.
* [Download pro.lua, the Lua dissector script.](https://gist.github.com/g0ldPRO/4a089d3332a1ef8445b39c17f337133f)
* Copy the pro.lua file in the plugins directory of Wireshark. Something like: *%programfiles%\Wireshark\plugins\2.0.2*
* Open Wireshark.
* Go in `Analyze>Enabled Protocols`, search `Pokemon`, check the box of *PRO*.
* Optional: you can also enabled different colours for the client packets and server packets, to do so go to View>Coloring Rules, create a new one, call it *PRO* (the name does not matter), enter `pro and tcp.srcport==800` as a filter then define your background and foreground colours. I use black as foreground and #a7c9ca as background.
* Chose the your network interface. For instance mine is *Wireless Network Connection*, in *"... using filter:"* enter `port 800`, that's the port used by the server of PRO. If you do not enter this filter everything will still work but you will unwillingly capture packets that are not related to the protocol we are interesting in.
![](http://i.imgur.com/GgY0tdV.png)
* Double click your network interface.
* Enter `pro` as a display filter
![](http://i.imgur.com/Nw1cOtO.png)
* On this view you can see all the packet that transited between your client(s) and the server(s) since you started the capture.
* You can hide the bottom window, it is not going to be of any use since our data are plain text.
* The packet is shown in the *PRO Protocol ProData* section, the XOR 1 operation has already been applied to the packet to make it readable.
* Since this protocol is using TCP, you can find multiple instructions in one packet, all the different instructions and their count are written in the *Info* column.
