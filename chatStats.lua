function OnStartup()
	tConfig, tUserStats, tBotStats = {
		tBot = {
			sName = "[BOT]Stats",
			sDescription = "Statistics collection and fetching tasks.",
			sEmail = "do-not@mail.me",
		},
		sPath = Core.GetPtokaXPath(),
		sExtPath = "scripts/files/external/",
		sFunctionsFile = "stats.lua",
		iTimerID = TmrMan.AddTimer( 90 * 10^3, "UpdateStats" ),
	}, {}, {}
	Core.RegBot( tConfig.tBot.sName, tConfig.tBot.sDescription, tConfig.tBot.sEmail, true )
	dofile( tConfig.sPath..tConfig.sExtPath..tConfig.sFunctionsFile )
end

function ChatArrival( tUser, sMessage )
	if tUser.iProfile == -1 then return false end
	local sDate, sCmd, sData = os.date( "%Y-%m-%d" ), sMessage:match( "%b<> [-+*/?#!](%w+)%s?(.*)|" )
	if type( tUserStats[sDate] ) ~= "table" then
		tUserStats[sDate] = {}
	end
	if not tUserStats[sDate][tUser.sNick] then tUserStats[sDate][tUser.sNick] = { main = 0, msg = 0 } end
	tUserStats[sDate][tUser.sNick].main = ( tUserStats[sDate][tUser.sNick].main or 0 ) + 1
	if not sCmd then return false end
end

function ToArrival( tUser, sMessage )
	local sTo, sDate, bRegUserFlag = sMessage:match( "$To: (%S+)" ), os.date( "%Y-%m-%d" ), tUser.iProfile ~= -1
	local iFlag = VerifyBots( sTo )
	if iFlag == 0 and not bRegUserFlag then return false end
	if bRegUserFlag then
		if type( tUserStats[sDate] ) ~= "table" then
			tUserStats[sDate] = {}
		end
		if not tUserStats[sDate][tUser.sNick] then tUserStats[sDate][tUser.sNick] = { msg = 0, main = 0 } end
		tUserStats[sDate][tUser.sNick].msg = ( tUserStats[sDate][tUser.sNick].msg or 0 ) + 1
	end
	if iFlag == 0 then return false end
	if type( tBotStats[sDate] ) ~= "table" then
		tBotStats[sDate] = {}
	end
	if not tBotStats[sDate][sTo] then tBotStats[sDate][sTo] = { regs = 0, unregs = 0 } end
	if bRegUserFlag then
		tBotStats[sDate][sTo].regs = (tBotStats[sDate][sTo].regs or 0) + 1
	else
		tBotStats[sDate][sTo].unregs = (tBotStats[sDate][sTo].unregs or 0) + 1
	end
	if sTo ~= tConfig.tBot.sName then return false end
	local sCmd, sData = sMessage:match( "%b$$%b<> [-+*/?#!](%w+)%s?(.*)|" )
	if not sCmd then return false end
end

function OnExit()
	Core.UnregBot( tConfig.tBot.sName )
	TmrMan.RemoveTimer( tConfig.iTimerID )
end

function VerifyBots( sInput )
	if sInput:find( "^%[BOT%]" ) then
		return 1
	elseif sInput:find( "^#%[" ) then
		return 2
	elseif sInput:find( "OpChat" ) then
		return 2
	elseif sInput == SetMan.GetString( 21 ) then
		return 1
	else
		return 0
	end
end

function UpdateStats()
	for sDate, tTemporary in pairs( tUserStats ) do
		for sNick, tTemp in pairs( tTemporary ) do
			UserScore( sNick, sDate, tTemp.main, tTemp.msg )
		end
	end
	for sDate, tTemporary in pairs( tBotStats ) do
		for sName, tTemp in pairs( tTemporary ) do
			BotStats( sName, sDate, tTemp.regs, tTemp.unregs )
		end
	end
	tUserStats, tBotStats = {}, {}
end
