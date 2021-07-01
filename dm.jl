# julia connection to julius
using Sockets, LightXML
# voice decode event
struct VDevent
	vdscore::Float32 # score
	vdconf::Float32 # confidence
	vdstring::String # Julius interp what was said
end
"""
	juliusProcessID
	
	check if Julius is running by fetching the PID from the system
	knowledge of PID can be used to force shutdown of process later
"""
function juliusProcessID()
	ps = read(`ps ax`,String)
	pss = split(ps,"\n")
	pidid = 0
	for p in pss
		global pidid
		if contains(p,"mod.jconf")
			pid = split(strip(p))[1]
			pidid = parse(Int32,pid)
			return pidid
		end
	end
	return pidid
end
"""
	juliusGetStatus()
	
	find out what state Julius is in (listening, )
	Input is TCPSocket
	Output is the message
"""
function juliusGetStatus(cs::TCPSocket)
	write(cs,"STATUS\n")
	sleep(0.5)
	flush(cs)
	while true
		msg = readline(cs)
		if contains(msg,"SYSINFO")
			return msg
		end
	end
end
"""
	juliusDecodeVoice()
	
	Input is the TCPSocket already open
	Output is the complete decode message
	including input status, time, frames, timing,
	and word decode hypotheses
"""
function juliusDecodeVoice(cs::TCPSocket)
	flush(cs)
	msg = ""
	while true
		lin = readline(cs)
		#println(lin)
		msg *= lin
		if contains(lin,"/RECOGOUT")
			break
		end
	end
	msg = replace(msg,">.<"=>">\n<")
	xml = "<REC>"*msg[2:end]*"</REC>"
	#println(xml)
	return parse_xml(xml)
end
"""
	parse_xml()
	
	inputs a string in XML form and 
	extracts the words as a string, the score and 
	the mean confidence for the string as a whole
	return as a struct
"""
function parse_xml(xml::String)
	xdoc = parse_string(xml)
	xroot = root(xdoc)
	xscore = xroot["RECOGOUT"][1]["SHYPO"][1]
	score = parse(Float32,attribute(xscore,"SCORE"))
	xwds = xroot["RECOGOUT"][1]["SHYPO"][1]["WHYPO"][2:end-1]
	confs = [parse(Float32,attribute(a,"CM")) for a in xwds]
	nconfs = length(confs)
	conf = sum(confs) ./ nconfs
	heard = join([attribute(a,"WORD") for a in xwds]," ")
	vdevent = VDevent(score,conf,heard)
	return vdevent
end
"""
	juliusRecogToggle()
	
	tells the Julius server to ignore the speech it hears (off/false)
	or to resume decoding (on/true)
"""
function juliusRecogToggle(cs,onoff::Bool)
	action = onoff ? "RESUME\n" : "PAUSE\n"
	write(cs,action)
end
#
"""
	announce()
	
	say something through flite
"""
function announce(msg::String)
	cmd = `padsp flite -voice slt -t $msg`
	run(cmd)
end
#
"""
	tidyupandend()
	
	perform any needed cleanup tasks
	and terminate
"""
function tidyupandend()
	announce("Ending now. Goodbye")
	println("Ending now. Goodbye")
	exit(0)
end
#
# loop
#
function recogLoop(cs::TCPSocket)
	while true
		juliusRecogToggle(cs,false)
		announce("Ready")
		juliusRecogToggle(cs,true)
		vdevent = juliusDecodeVoice(cs)
		println(vdevent.vdstring)
		if vdevent.vdstring == "zulu zulu"
			tidyupandend()
		end
	end
end
#
# main section
# establish the connection to the server and start decoding
#
Jpid = juliusProcessID()
println(Jpid)
if  Jpid > 0
	local cs
	try
		cs = connect(10500)
	catch e
		println(e)
		announce("julius is not running. stopping now")
		error("cannot connect to socket on 10500")
	end
	announce("Julius is ready")
	println(juliusGetStatus(cs))
	recogLoop(cs)
end
