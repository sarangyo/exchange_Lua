local exchange = {}

exchange.GM = {'TEST_1'} -- 운영자 이름 추가하세요.
-- 용도)거래소의 아이템 강제회수 권한


-- name : 메뉴 버튼이름
-- type : 아이템 타입 (0:모자, 1:갑옷, 2:무기 ....)
-- strVar :데이터가 저장될 월드(서버)스트링변수 번호
exchange.menu = {
	{name = '무 기', type = 2, strVar = 1},
	{name = '모 자', type = 0, strVar = 2},
	{name = '갑 옷', type = 1, strVar = 3},
	{name = '방 패', type = 3, strVar = 4},
	{name = '신 발', type = 4, strVar = 5},
	{name = '반 지', type = 5, strVar = 6},
	{name = '악세사리', type = 6, strVar = 7},
	{name = '소모품', type = 10, strVar = 8},
	{name = '포 션', type = 8, strVar = 9},
	{name = '재 료', type = 9, strVar = 10},
	{name = '날 개', type = 7, strVar = 11}
}
exchange.sv = 12
-- 서버스트링 번호
-- 용도)팔린 아이템이 유저가 접속하기 전까지 데이터가 잔류합니다.
exchange.avg = 13
-- 서버스트링 번호
-- 용도)평균 20건 거래가

local personal = {
	storageBoxVar = 1, -- 택배보관함용)개인스트링변수
	strVar = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}, -- 백업용)개인스트링변수 12개를 넣어주세요.
	exchangeIndexTime = 6, -- 6번 변수
	dayToItems = 7, -- 7번 변수
	day = 8, -- 8번 변수
}
-- personal 테이블에는 서버가 아닌 개인변수로 작성해주세요.
-- (exchangeIndexTime, dayToItems, day) 에는 일반변수 번호를, strVar 에는 개인스트링번호를 넣어주세요.

exchange.dayToItems = 10
-- 하루에 아이템 등록갯수

exchange.fee = 5000
-- 아이템 등록수수료
-- 아이템 등록이 남용되지 않도록 적당히 비싼 수수료를 넣어주세요.
-- 아이템이 팔릴 때 반환됩니다. (회수, 마감 시간이 지났을 때는 수수료 반환 안됨)

exchange.saleFee = 3
-- 골드 회수 수수료(%)
-- 아이템을 판매하고 받는 골드의 수수료입니다. 소수점은 짤립니다.

--[=[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 거래소 스크립트
	
	수정금지, 재판매, 재배포 금지입니다.
	
	▣ 적용방법
		Pictures, Scripts, SE, ServerScripts 폴더들을 복사하여 프로젝트에 그대로 붙혀넣습니다.
		
	▣ 실행방법
		* 거래소
		서버 : exchangeOpen()
		클라 : Client.FireEvent('exchangeOpen')
		* 택배보관함
		서버 : storageBoxOpen()
		클라 : Client.FireEvent('storageBoxOpen')
		
	▣ 아이템 등록은 10개가 초과되면 아이템 등록이 제한될 수 있습니다.
		서버스트링으로 제작되었기 때문에 용량이 존재합니다.
		거래소에 등록되는 1개의 아이템이 약 100의 용량을 차지합니다.
		타입당 약 65000의 최대용량이 있으며, 타입당 600개 정도의 아이템이 등록될 수 있습니다.
		
	▣ 서버 시작 시 60초간 경매장 아이템 등록/회수/구매 불가
		
	▣ 재부팅을 하기전 규칙이 있습니다. 1분마다 자동백업이 되지만 확실하게 백업하기 위해서
		채팅창에 /script backUp() 을 입력한 후 재부팅합니다. 입력한 순간 거래소 이용이 전면 중지됩니다.
	
	▣ 11개의 타입중 날개를 제외한 10개의 아이템 타입이 각각 거래소에 올라와 있어야 자동백업이 됩니다.
		서버할당이 바뀌어 거래소에 올라간 아이템이 모두 소멸했을 경우에도 자동백업이 됨을 방지하기 위함입니다.
		자동백업이 불가한 상황에서 백업이 필요하다면 채팅창에 /script backUp() 를 통해서 강제백업이 가능합니다.
		
		자동백업 o
		예) 모든 타입의 아이템이 거래소에 1개라도 올라가 있음.
		예) 날개 아이템을 제외한 모든 아이템이 거래소에 올라가 있음.
		
		자동백업 x
		예) 재료 아이템을 제외한 모든 아이템이 거래소에 올라가 있음.
		
	▣ 만약 서버할당이 바뀌어 거래소 데이터가 소멸됐다면 /script dataRecovery() 라고 입력해주세요.
	
	▣ 효과음 에러 처리방법
		경로도 정확하고 F10 을 눌러 리소스를 최신화 했지만 채팅창에 다음과 같은 에러가 뜬다면
		There is no SE : 거래소/click.ogg file.
		
		1. F9를 눌러 데이터베이스 탭에 들어갑니다.
		2. 애니메이션탭에 들어갑니다.
		3. 아무스킬 > 아무커맨드 > 재생SE > 디텍토리 > 해당효과음 재생
		4. 저장하지 않고 탭을 닫습니다. (저장해도 상관없음)
	
	▣ 출시 예정 기능
		평균 거래가
		타재화 사용 기능
		거래소 로그(디코 메세지)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━]=]

local isGM_mapping = {}
for _, v in ipairs(exchange.GM) do isGM_mapping[v] = true end

local function stringInit(txt)
	if txt==nil or txt=='' then
		txt = '[]'
	end
	return txt
end

local type_mapping = {}
for i, v in ipairs(exchange.menu) do type_mapping[v.type] = v.strVar end

local serverExchangeData = {}
local safetyVar = {}
for i, v in ipairs(exchange.menu) do
	serverExchangeData[i] = Utility.JSONParse(stringInit(Server.GetWorldStringVar(v.strVar)))
	safetyVar[i] = false
end
local freeData = Utility.JSONParse(stringInit(Server.GetWorldStringVar(exchange.sv)))
safetyVar[12] = false
local isTxt = '<size=18>누군가 거래중이거나 거래소가 닫혀있습니다.\n잠시 후 다시 시도해주세요.</size>'

Server.GetTopic('registerItem').Add(function(uqID)
	local item = unit.player.GetItem(uqID)
	
	if not item then
		unit.SendCenterLabel('<size=18>선택하신 아이템이 없습니다.</size>')
		return
	end
	
	if exchange.fee > unit.gameMoney then
		unit.SendCenterLabel('<size=18>아이템 등록 수수료가 부족합니다.</size>')
		return
	end
	
	if #serverExchangeData[type_mapping[Server.GetItem(item.dataID).type]] > 600 then
		unit.SendCenterLabel('<size=18>해당 카테고리의 용량이 초과되었습니다.</size>')
		return
	end
	
	unit.FireEvent('registerItemPrice', uqID, '등록')
end)

local goldName = Server.GetStrings().gameMoney == '' and '골드' or string.gsub(Server.GetStrings().gameMoney, "{0} ", "")
Server.GetTopic('itemSell').Add(function(selectNum, uqID, count, value)
	local item = unit.player.GetItem(uqID)
	
	if not item then
		unit.SendCenterLabel('<size=18>선택하신 아이템이 없습니다.</size>')
		unit.FireEvent('roadingEnd')
		return
	end
	
	if item.count < count then
		unit.SendCenterLabel('<size=18>선택하신 아이템의 수량이 맞지 않습니다.</size>')
		unit.FireEvent('roadingEnd')
		return
	end
	
	local day = tonumber(os.date('%d', os.time()+32400))
	if unit.GetVar(personal.day) ~= day then
		unit.SetVar(personal.day, day)
		unit.SetVar(personal.dayToItems, 0)
	end
	
	if unit.GetVar(personal.dayToItems) >= exchange.dayToItems then
		unit.SendCenterLabel('<size=18>아이템 등록은 하루 '..exchange.dayToItems..'회까지 가능합니다.</size>')
		unit.FireEvent('roadingEnd')
		return
	end

	
	if exchange.fee > unit.gameMoney then
		unit.SendCenterLabel('<size=18>아이템 등록 수수료가 부족합니다.</size>')
		unit.FireEvent('roadingEnd')
		return
	end
	
	if safetyVar[selectNum] then
		unit.SendCenterLabel(isTxt)
		unit.FireEvent('roadingEnd')
		return
	end
	
	local itemData = {
		u = unit.player.id,
		I = item.dataID,
		t = tonumber(string.format('%.2f', os.time())),
		lv = item.level,
		op = {t={}, i={}, v={}},
		s = value,
		c = count,
	}
	for i, v in ipairs(item.options) do
		itemData.op.t[i] = v.type
		itemData.op.i[i] = v.statID
		itemData.op.v[i] = v.value
	end
	
	safetyVar[selectNum] = true -- 거래 연산 시작
-- · -- · -- · -- · -- · -- · -- -- · -- · -- · -- · -- · -- · -- 
	unit.UseGameMoney(exchange.fee)
	unit.RemoveItemByID(item.id, count, false)
	table.insert(serverExchangeData[selectNum], itemData)
	Server.SetWorldStringVar(exchange.menu[selectNum].strVar, Utility.JSONSerialize(serverExchangeData[selectNum]))
-- · -- · -- · -- · -- · -- · -- -- · -- · -- · -- · -- · -- · -- 
	safetyVar[selectNum] = false -- 거래 연산 종료
	unit.SetVar(personal.dayToItems, unit.GetVar(personal.dayToItems)+1)
	unit.SendCenterLabel('<size=18>아이템이 안전하게 등록되었습니다.</size>')
	unit.FireEvent('itemSellEnd')
	unit.FireEvent('dayToCount', exchange.dayToItems - unit.GetVar(personal.dayToItems))
	exchangeOpen(selectNum, unit)
end)

Server.GetTopic('itemBuy').Add(function(selectNum, key, count, txt)
	local item = serverExchangeData[selectNum][key]
	local tempTbl = Utility.JSONParse(txt)
	if not item or not (tempTbl[1]==item.t and tempTbl[2]==item.u and tempTbl[3]==item.s) then
		unit.SendCenterLabel('<size=18>해당 아이템은 이미 판매되었습니다.</size>')
		unit.FireEvent('itemSellEnd')
		exchangeOpen(selectNum, unit)
		return
	end
	
	if item.u==unit.player.id then
		unit.SendCenterLabel('<size=18>내 아이템은 구매할 수 없습니다.</size>')
		unit.FireEvent('itemSellEnd')
	end
	
	if item.c < count then
		unit.SendCenterLabel('<size=18>선택하신 아이템은 현재 '..item.c..'개 남았습니다.</size>')
		unit.FireEvent('roadingEnd')
		return
	end
	
	local sum = item.s*count
	if sum > unit.gameMoney then
		unit.SendCenterLabel('<size=18>'..goldName..'가 부족합니다.</size>')
		unit.FireEvent('roadingEnd')
		return
	end
	
	if safetyVar[selectNum] or safetyVar[12] then
		unit.SendCenterLabel(isTxt)
		unit.FireEvent('roadingEnd')
		return
	end
	
	safetyVar[selectNum] = true -- 거래 연산 시작
-- · -- · -- · -- · -- · -- · -- -- · -- · -- · -- · -- · -- · -- 
	unit.UseGameMoney(sum)
	local addItem = Server.CreateItem(item.I, count)
	for i, v in ipairs(item.op.t) do
		Utility.AddItemOption(addItem, v, item.op.i[i], item.op.v[i])
	end
	addItem.level = item.lv
	unit.AddItemByTItem(addItem, false)
	local lv = item.lv>0 and ('<color=#00FF00>+'..item.lv..'</color> ') or ''
	unit.SendCenterLabel('<size=18>'..lv..Server.GetItem(item.I).name..' '..count..'개를 획득했습니다.</size>')
	
	safetyVar[12] = true
	if Unit_data[item.u] then
		local lebel = '<color=#00FF00><color=#FFFF00>[거래소]</color> '..Server.GetItem(item.I).name..' '..count..'개 판매되었습니다.\n택배함을 확인해주세요.</color>'
		Unit_data[item.u].SendSay(lebel)
		Unit_data[item.u].SendCenterLabel('<size=18>'..lebel..'</size>')
	end
	item.o = unit.player.id
	item.t = math.floor(os.time())+2000000
	table.insert(freeData, item)
	Server.SetWorldStringVar(exchange.sv, Utility.JSONSerialize(freeData))
	safetyVar[12] = false
	
	if item.c-count > 0 then
		item.c = item.c-count
	else
		table.remove(serverExchangeData[selectNum], key)
	end
	Server.SetWorldStringVar(exchange.menu[selectNum].strVar, Utility.JSONSerialize(serverExchangeData[selectNum]))
-- · -- · -- · -- · -- · -- · -- -- · -- · -- · -- · -- · -- · -- 
	safetyVar[selectNum] = false -- 거래 연산 종료
	
	unit.FireEvent('itemSellEnd')
	exchangeOpen(selectNum, unit)
end)

Server.GetTopic('itemRecovery').Add(function(selectNum, key, txt) -- 아이템 회수버튼
	local item = serverExchangeData[selectNum][key]
	local tempTbl = Utility.JSONParse(txt)
	if tempTbl[2]~=item.u or not isGM_mapping[unit.player.name] then
		unit.SendCenterLabel('<size=18>나의 아이템만 회수 가능합니다.</size>')
		unit.FireEvent('roadingEnd')
		return
	end
	
	if not item or not (tempTbl[1]==item.t and tempTbl[3]==item.s) then
		unit.SendCenterLabel('<size=18>해당 아이템은 이미 판매되었습니다.</size>')
		unit.FireEvent('roadingEnd')
		exchangeOpen(selectNum, unit)
		return
	end
	
	if safetyVar[selectNum] then
		unit.SendCenterLabel(isTxt)
		unit.FireEvent('roadingEnd')
		return
	end
	
	safetyVar[selectNum] = true -- 거래 연산 시작
-- · -- · -- · -- · -- · -- · -- -- · -- · -- · -- · -- · -- · -- 
	local addItem = Server.CreateItem(item.I, item.c)
	for i, v in ipairs(item.op.t) do
		Utility.AddItemOption(addItem, v, item.op.i[i], item.op.v[i])
	end
	addItem.level = item.lv
	unit.AddItemByTItem(addItem, false)
	local lv = item.lv>0 and ('<color=#00FF00>+'..item.lv..'</color> ') or ''
	unit.SendCenterLabel('<size=18>'..lv..Server.GetItem(item.I).name..' '..item.c..'개를 획득했습니다.</size>')
	table.remove(serverExchangeData[selectNum], key)
	Server.SetWorldStringVar(exchange.menu[selectNum].strVar, Utility.JSONSerialize(serverExchangeData[selectNum]))
-- · -- · -- · -- · -- · -- · -- -- · -- · -- · -- · -- · -- · -- 
	safetyVar[selectNum] = false -- 거래 연산 종료
	
	unit.FireEvent('roadingEnd')
	exchangeOpen(selectNum, unit)
end)

Server.GetTopic('exchangeData').Add(function()
	unit.FireEvent('exchangeData', Utility.JSONSerialize(exchange.menu),
		Utility.JSONSerialize{dayToItems=exchange.dayToItems, fee=exchange.fee, saleFee=exchange.saleFee, gold=goldName})
	unit.FireEvent('dayToCount', exchange.dayToItems - unit.GetVar(personal.dayToItems))
end)

function exchangeOpen(selectNum, u)
	local me = u and u or unit
	if not me then
		return
	end
	
	if selectNum then
		me.FireEvent('exchangeOpen', Utility.JSONSerialize(serverExchangeData[selectNum]), os.time())
	else
		me.FireEvent('exchangeOpen', nil, os.time())
	end
end
Server.GetTopic('exchangeOpen').Add(exchangeOpen)

function storageBoxOpen(u)
	local me = u and u or unit
	if not me.customData.storage then
		me.customData.storage = Utility.JSONParse(stringInit(me.GetStringVar(personal.storageBoxVar)))
	end
	
	if safetyVar[12] then
		me.SendCenterLabel(isTxt)
		me.FireEvent('roadingEnd')
		return
	end
	
	local playerID = me.player.id
	local tempTbl = {key={}, value={}}
	safetyVar[12] = true
	for i, v in ipairs(freeData) do
		if playerID==v.u then
			table.insert(tempTbl.key, i)
			table.insert(tempTbl.value, v)
		end
	end
	
	for i=#tempTbl.key, 1, -1 do
		table.remove(freeData, tempTbl.key[i])
		table.insert(me.customData.storage, tempTbl.value[i])
	end
	Server.SetWorldStringVar(exchange.sv, Utility.JSONSerialize(freeData))
	local txt = Utility.JSONSerialize(me.customData.storage)
	me.SetStringVar(personal.storageBoxVar, txt)
	safetyVar[12] = false
	
	me.FireEvent('storageBoxOpen', txt)
end
Server.GetTopic('storageBoxOpen').Add(storageBoxOpen)

local function comma(str)
    local left, num, right = string.match(str, '^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end
Server.GetTopic('takeOut').Add(function(idx)
	if not unit.customData.storage then
		unit.customData.storage = Utility.JSONParse(stringInit(unit.GetStringVar(personal.storageBoxVar)))
	end
	
	local t = unit.customData.storage[idx]
	if t.o then
		local sum = math.floor(t.s*t.c*(1-exchange.saleFee*0.01)) + exchange.fee
		unit.AddGameMoney(sum)
		unit.SendCenterLabel('<size=18>'..comma(sum)..' '..goldName..' 획득하셨습니다.</size>')
	else
		local item = Server.CreateItem(t.I, t.c)
		for i, v in ipairs(t.op.t) do
			Utility.AddItemOption(item, v, t.op.i[i], t.op.v[i])
		end
		item.level = t.lv
		unit.AddItemByTItem(item, false)
		
		local lv = t.lv>0 and ('<color=#00FF00>+'..t.lv..'</color> ') or ''
		unit.SendCenterLabel('<size=18>'..lv..Server.GetItem(t.I).name..' '..t.c..'개를 획득했습니다.</size>')
	end
	table.remove(unit.customData.storage, idx)
	storageBoxOpen(unit)
	unit.FireEvent('roadingEnd')
end)

Server.GetTopic('playerID').Add(function()
	unit.FireEvent('playerID', unit.player.id, isGM_mapping[unit.player.name])
end)

Unit_data = {}
Server.onJoinPlayer.Add(function(player)
	Unit_data[player.id] = player.unit
end)

local units = {}
local function stringDataRemove(tbl, i, deleteTime)
	if not safetyVar[i] and not safetyVar[12] then
		local removeIndex = {}
		for j, v in ipairs(tbl) do
			if v.t+deleteTime < os.time() then
				table.insert(removeIndex, j)
			end
		end
		
		for j=#removeIndex, 1, -1 do
			tbl[j].t = math.floor(os.time())
			table.insert(freeData, tbl[j])
			table.remove(tbl, removeIndex[j])
		end
	
		local txt = Utility.JSONSerialize(tbl)
		Server.SetWorldStringVar(exchange.menu[i].strVar, txt)
		Server.SetWorldStringVar(exchange.sv, Utility.JSONSerialize(freeData))
		for j=1, #units do
			if units[j] then
				units[j].SetStringVar(personal.strVar[i], txt)
			end
		end
	end
end

local isCheck = false
function timeCheck()
	units = {}
	
	if isCheck then return end
	
	for i=1, 10 do
		if #serverExchangeData[i]==0 then
			return
		end
	end
	
	local serverUnits = Server.players
	local serverUnitsLen = #serverUnits
	for i=1, serverUnitsLen > 6 and 6 or serverUnitsLen do
		table.insert(units, serverUnits[rand(1, serverUnitsLen+1)].unit)
		units[i].SetVar(personal.exchangeIndexTime, math.floor(os.time()))
	end
	
	for i=1, 11 do
		Server.RunLater(function()
			stringDataRemove(serverExchangeData[i], i, 260000)
		end, i*0.5)
	end
	
	Server.RunLater(function()
		if not safetyVar[12] then
		
			local removeIndex = {}
			for j, v in ipairs(freeData) do
				if v.t+600000 < os.time() then
					table.insert(removeIndex, j)
				end
			end
			
			for j=#removeIndex, 1, -1 do
				table.remove(freeData, removeIndex[j])
			end
			
			local txt = Utility.JSONSerialize(freeData)
			Server.SetWorldStringVar(exchange.sv, txt)
			for j=1, #units do
				if units[j] then
					units[j].SetStringVar(personal.strVar[12], txt)
				end
			end
		end
	end, 6)
	
	Server.RunLater(timeCheck, 60)
end
Server.RunLater(timeCheck, 1)

local dataRecoveryIsStart = false
local LatestDataUsers = nil
function dataRecovery()
	Server.SendSay('<color=#00FF00>[#] 거래소 데이터 복구중입니다.\n[#] 거래소를 이용하실 수 없습니다.</color>')
	dataRecoveryIsStart = true
	local maxOsTime = 0
	
	Server.RunLater(function()
		for i, v in ipairs(Server.players) do
			local t = v.unit.GetVar(personal.exchangeIndexTime)
			if maxOsTime < t then
				maxOsTime = t
				LatestDataUsers = v.unit
			end
		end
		if maxOsTime==0 then
			Server.SendSay('<color=#00FF00>[#] 복구에 실패하였습니다. 다시 시도해주세요.</color>')
			return
		end
		
		for i, v in ipairs(exchange.menu) do
			serverExchangeData[i] = Utility.JSONParse(stringInit(LatestDataUsers.GetStringVar(personal.strVar[i])))
			Server.SetWorldStringVar(v.strVar, Utility.JSONSerialize(serverExchangeData[i]))
			safetyVar[i] = false
		end
		freeData = Utility.JSONParse(stringInit(LatestDataUsers.GetStringVar(personal.strVar[12])))
		Server.SetWorldStringVar(exchange.sv, Utility.JSONSerialize(freeData))
		safetyVar[12] = false
		
		Server.SendSay('<color=#00FF00>[#] 거래소 데이터복구가 완료되었습니다.\n[#] 거래소 이용이 가능해졌습니다.</color>')
	end, 180)
end

Server.RunLater(function()
	if not dataRecoveryIsStart then
		for i=1, 12 do 
			safetyVar[i] = false 
		end 
	end
end, 60)

function backUp()
	for i=1, 12 do 
		safetyVar[i] = true 
	end 
	Server.SendSay('<color=#00FF00>[#] 거래소 이용이 중단되었습니다.</color>')
	isCheck = true
	
	local players = {}
	
	local serverUnits = Server.players
	local serverUnitsLen = #serverUnits
	for i=1, serverUnitsLen > 6 and 6 or serverUnitsLen do
		table.insert(players, serverUnits[rand(1, serverUnitsLen+1)].unit)
		players[i].SetVar(personal.exchangeIndexTime, math.floor(os.time()))
	end
	
	for i=1, 11 do
		local removeIndex = {}
		local tbl = serverExchangeData[i]
		for j, v in ipairs(tbl) do
			if v.t+260000 < os.time() then
				table.insert(removeIndex, j)
			end
		end
		
		for j=#removeIndex, 1, -1 do
			tbl[j].t = math.floor(os.time())
			table.insert(freeData, tbl[j])
			table.remove(tbl, removeIndex[j])
		end
	
		local txt = Utility.JSONSerialize(tbl)
		Server.SetWorldStringVar(exchange.menu[i].strVar, txt)
		Server.SetWorldStringVar(exchange.sv, Utility.JSONSerialize(freeData))
		print(personal.strVar[i], exchange.menu[i].strVar)
		for j=1, #players do
			if players[j] then
				players[j].SetStringVar(personal.strVar[i], txt)
			end
		end
	end
	
	local removeIndex = {}
	for j, v in ipairs(freeData) do
		if v.t+600000 < os.time() then
			table.insert(removeIndex, j)
		end
	end
	
	for j=#removeIndex, 1, -1 do
		table.remove(freeData, removeIndex[j])
	end
	
	local txt = Utility.JSONSerialize(freeData)
	Server.SetWorldStringVar(exchange.sv, txt)
	for j=1, #players do
		if players[j] then
			players[j].SetStringVar(personal.strVar[12], txt)
		end
	end
	
	Server.SendSay('<color=#00FF00>[#] 거래소 데이터 백업이 완료되었습니다.</color>')
end

function test3() -- 아이템 랜덤등록
	local s = Server.GetItem
	
	local dataID = rand(1, 100)
	local boolean = s(dataID) and s(dataID).name~='' and s(dataID).canTrade
	
	local index = 1
	while not boolean do
		dataID = rand(1, 100)
		boolean = s(dataID) and s(dataID).name~='' and s(dataID).canTrade
		index = index+1
		if index>10 then unit.SendCenterLabel('아이템 생성 실패') return end
	end
	
	local t = s(dataID).type
	local index = 1
	for i=1, 11 do
		if exchange.menu[i].type==t then
			index = i
			break
		end
	end
	
	local itemData = {
		u = rand(1, 4), -- TEST_3까지
		I = dataID,
		t = math.floor(os.time())-rand(0, 260000),
		lv = s(dataID).maxCount==1 and rand(0, 10) or 0,
		op = {t={}, i={}, v={}},
		s = rand(1, 10000000),
		c = t<=7 and 1 or rand(1, s(dataID).maxCount+1),
	}
	for i=1, s(dataID).maxCount==1 and rand(1, 6) or 0 do
		itemData.op.t[i] = rand(1, 5)
		itemData.op.i[i] = rand(0, 8)
		itemData.op.v[i] = rand(1, 1000)
	end
	
	table.insert(serverExchangeData[index], itemData)
	Server.SetWorldStringVar(exchange.menu[index].strVar, Utility.JSONSerialize(serverExchangeData[index]))
	unit.SendCenterLabel('완료')
end

function test4() -- 아이템 랜덤생성
	local s = Server.GetItem
	
	local dataID = rand(1, 100)
	local boolean = s(dataID) and s(dataID).name~='' and s(dataID).canTrade
	
	local index = 1
	while not boolean do
		dataID = rand(1, 100)
		boolean = s(dataID) and s(dataID).name~='' and s(dataID).canTrade
		index = index+1
		if index>10 then unit.SendCenterLabel('아이템 생성 실패') return end
	end
	
	local t = s(dataID).type
	local index = 1
	for i=1, 11 do
		if exchange.menu[i].type==t then
			index = i
			break
		end
	end
	
	local itemData = {
		I = dataID,
		lv = s(dataID).maxCount==1 and rand(0, 10) or 0,
		op = {t={}, i={}, v={}},
		c = t<=7 and 1 or rand(1, s(dataID).maxCount+1),
	}
	for i=1, s(dataID).maxCount==1 and rand(1, 6) or 0 do
		itemData.op.t[i] = rand(1, 5)
		itemData.op.i[i] = rand(0, 8)
		itemData.op.v[i] = rand(1, 1000)
	end
	
	local item = Server.CreateItem(dataID, rand(1, itemData.c))
	for i, v in ipairs(itemData.op.t) do
		Utility.AddItemOption(item, v, itemData.op.i[i], itemData.op.v[i])
	end
	item.level = itemData.lv
	unit.AddItemByTItem(item, false)
	unit.SendCenterLabel('완료')
end
