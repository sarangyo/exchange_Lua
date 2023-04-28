local exchange = {}
exchange.max = 999999999999999 -- 최대 금액
-- 15자리수를 넘어가게되면 표기형식이 1E+16 같이 바뀜

exchange.maxList = 16
-- 아이템 리스트 최대 개수






local textStyle = { textAlign = 4, borderEnabled = true }
local centerStyle = { anchor = 4, pivot = Point(0.5, 0.5) }
function roading(is)
	if not exchange.roadingPanel and is then
		exchange.roadingPanel = Panel(Rect(0, 0, Client.width, Client.height)){
			color = Color.black,
			opacity = 200,
			showOnTop = true
		}
		exchange.roadingPanel.AddChild(Text('<size=24>Roading...</size>\n<size=14>Please wait a moment.</size>', Rect(0, 0, Client.width, Client.height)){
			textAlign = 4,
			borderEnabled = true
		})
	elseif exchange.roadingPanel and not is then
		exchange.roadingPanel.Destroy()
		exchange.roadingPanel = nil
	end
end
Client.GetTopic('roadingEnd').Add(roading)

function comma(str)
    local left, num, right = string.match(str, '^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function numberToKorean(num)
	local units = {"", "만", "억", "조", "경"}
	local result = ""
	local index = 1

	while num > 0 do
		local n = num % 10000
		if n ~= 0 then
			local str = ""
			if n < 1000 then
				str = tostring(n)
			else
				str = string.format("%d%03d", math.floor(n / 1000), n % 1000)
			end
			result = string.format("%s%s%s", str, units[index], result)
		end
		num = math.floor(num / 10000)
		index = index + 1
	end

	return result
end




local c = Client.GetStrings()
StatInfo = {
	type = {
		[0] = {'', ''},
		[1] = {'직업', ''},
		[2] = {'직업', '%'},
		[3] = {'아이템', ''},
		[4] = {'아이템', '%'},
		[5] = {'', ''},
	},
	name = {
		[0] = c.attack == '' and '공격력' or c.attack,
		[1] = c.defense == '' and '방어력' or c.defense,
		[2] = c.magic_attack == '' and '마법 공격력' or c.magic_attack,
		[3] = c.magic_defense == '' and '마법 방어력' or c.magic_defense,
		[4] = c.agility == '' and '민첩' or c.agility,
		[5] = c.lucky == '' and '행운' or c.lucky,
		[6] = c.hp == '' and '체력' or c.hp,
		[7] = c.mp == '' and '마력' or c.mp,
	},
	custom = {c.custom1,c.custom2,c.custom3,c.custom4,c.custom5,c.custom6,c.custom7,c.custom8,c.custom9,c.custom10,c.custom11,c.custom12,c.custom13,c.custom14,c.custom15,c.custom16,c.custom17,c.custom18,c.custom19,c.custom20,c.custom21,c.custom22,c.custom23,c.custom24,c.custom25,c.custom26,c.custom27,c.custom28,c.custom29,c.custom30,c.custom31,c.custom32},
}

function Stat_Text(statID)
	local txt = StatInfo.name[statID]
    if statID > 100 then
		txt = StatInfo.custom[statID-100]
	end

    return txt
end

local me, tradeData, dayToCount = nil, nil, 0
local function buttonSE() me.PlaySE('거래소/click.ogg', 1) end
local getItem = Client.GetItem
local path = 'Pictures/거래소UI/'
function exchange:init()
	self.mainPanel = Image(path..'mainPanel.png', Rect(0, 0, 740, 420)){
		showOnTop = true,
		anchor = 4,
		pivot = Point(0.5, 0.5),
		visible = false
	}
	self.mainPanel.AddChild(Text('<color=#ffcc00>거래소</color>', Rect(15, 14, 100, 40)){
		textSize = 21,
		borderEnabled = true
	})
	
	local closeButton = Button('', Rect(-10, 8, 32, 32)){
		anchor = 2,
		pivotX = 1,
		opacity = 0,
		parent = self.mainPanel
	}
	local closeImage = Image(path..'close.png', Rect(0, 0, 18, 18))
	closeImage.style = centerStyle
	closeImage.SetParent(closeButton)
	
	closeButton.onClick.Add(function()
		buttonSE()
		self.mainPanel.visible = false
	end)
	
	local descButton = Button('', Rect(-50, 8, 32, 32)){
		anchor = 2,
		pivotX = 1,
		opacity = 0,
		parent = self.mainPanel
	}
	local descImage = Image(path..'desc.png', Rect(0, 0, 24, 24))
	descImage.style = centerStyle
	descImage.SetParent(descButton)
	descImage.DOColor(Color.magenta, 0)

	descButton.onClick.Add(function()
		buttonSE()
		
		local descText = [[<size=14><color=cyan>거래소 이용 Tip</color></size>
<color=blue>-*</color> 서버시작 60초 후부터 거래소를 이용하실 수 있습니다.
<color=blue>-*</color> 아이템 등록은 하루에 <color=yellow>]]..tradeData.dayToItems..[[회</color> 가능합니다. <color=#FFBF00>(오늘 남은 횟수: ]]..dayToCount..[[회)</color>
<color=blue>-*</color> 아이템 등록 수수료는 <color=yellow>]]..tradeData.fee..[[ ]]..tradeData.gold..[[</color> 입니다.
<color=blue>-*</color> 팔린 아이템의 ]]..tradeData.gold..[[는 택배보관함에서 수령 가능합니다.
<color=blue>-*</color> 팔린 아이템의 <color=yellow>]]..tradeData.gold..[[ 수령 수수료는 ]]..tradeData.saleFee..[[%</color> 입니다.
<color=blue>-*</color> 팔린 아이템의 ]]..tradeData.gold..[[를 수령할 때 <color=yellow>아이템 등록 수수료를 함께 지급</color>받습니다.
<color=blue>-*</color> 팔린 아이템의 ]]..tradeData.gold..[[를 30일간 수령하지 않으면 소멸됩니다.

<color=blue>-*</color> 아이템이 72시간 동안 판매되지 못하면 <color=#FF3232>마감</color>됩니다.
<color=blue>-*</color> 마감된 아이템은 택배보관함에서 수령받으실 수 있습니다.
<color=blue>-*</color> 마감된 아이템을 168시간(일주일) 동안 <color=#FF3232>수령하지 않으면 소멸</color>됩니다.
<color=blue>-*</color> 소멸된 아이템 및 ]]..tradeData.gold..[[는 복구받으실 수 없습니다.

<color=blue>-*</color> 가격 및 아이템을 잘못 인식하여 구매한 것은 개인의 책임입니다.

터치하여 닫기]]
		
		descImage.DOColor(Color.white, 0)
		local but = Button('', Rect(0, 0, Client.width, Client.height)){
			opacity = 0,
			showOnTop = true
		}
		but.AddChild(Panel(but.rect){
			opacity = 222,
			color = Color.black
		})
		local img = Image(path..'itemListPanel.png', Rect(0, 0, 400, 322))
		img.style = centerStyle
		img.SetParent(but)
		img.AddChild(Text(descText, Rect(5, 11, img.width-10, img.height-22)){
			color = Color(234, 234, 234),
			textSize = 12,
			lineSpacing = 1.2,
			borderEnabled = true
		})
		descText = nil
		
		but.onClick.Add(function()
			buttonSE()
			but.Destroy()
			but = nil
		end)
	end)
	
	
	local function leftPanelUI() -- menuList
		local img = Image(path..'menuPanel.png', Rect(9, 50, 98, 328)){
			parent = self.mainPanel
		}
		local pal = Panel(Rect(0, 0, img.width, img.height)){ opacity=0 }
		local scroll = ScrollPanel(pal.rect){
			horizontal = false,
			content = pal,
			parent = img
		}
		pal.height = 6+38*#self.menu
		
		self.menuSelectObj, self.menuSelectNum = nil, 0
		for i=1, #self.menu do
			local but = Button('', Rect(4, 6+38*(i-1), 90, 35)){ 
				opacity = 0,
				parent = pal
			}
			but.AddChild(Image(path..'menuButton.png', Rect(0, 0, but.width, but.height)))
			but.AddChild(Text(self.menu[i].name, Rect(0, 0, but.width, but.height)))
			but.children[2].style = textStyle
			
			but.onClick.Add(function()
				if self.findMode then
					Client.ShowAlert('검색모드를 해제해주세요.')
					return
				end
				
				local pal = Panel(Rect(img.x, img.y, img.width, img.height)){
					opacity = 0,
					parent = self.mainPanel
				}
				Client.RunLater(function()
					pal.Destroy()
					pal = nil
				end, 0.3)
				
				if self.menuSelectObj then
					self.menuSelectObj.image = path..'menuButton.png'
				end
				but.children[1].image = path..'onMenuButton.png'
				self.menuSelectObj = but.children[1]
				self.menuSelectNum = i
				
				self.buySelectNum = 0
				self.itemDescImage.children[1].text = ''
				self.itemDescImage.GetChild('but1').visible = false
				self.itemDescImage.GetChild('but2').visible = false
				
				Client.FireEvent('exchangeOpen', i)
			end)
		end
	end
	leftPanelUI()
	
	
	local function rightPanelUI()
		local img = Image(path..'newPanel.png', Rect(113, 50, 618, 328)){
			parent = self.mainPanel
		}
		
		local itemListImage = Image(path..'itemListPanel.png', Rect(4, 3, 400, 322)){
			parent = img
		}
		self.itemListPanel = Panel(Rect(0, 0, itemListImage.width, 6+49*self.maxList)){ opacity=0 }
		local itemListScroll = ScrollPanel(itemListImage.rect){
			showVerticalScrollbar = true,
			horizontal = false,
			content = self.itemListPanel,
			parent = img
		}
		self.scrollBar = itemListScroll.verticalScrollbar
		self.scrollBar.scale = Point(0, 0)
		
		self.itemDescImage = Image(path..'itemDescPanel.png', Rect(408, itemListImage.y, 210, itemListImage.height)){
			parent = img
		}
		local itemDescText = Text('', Rect(6, 8, self.itemDescImage.width-12, self.itemDescImage.height-16)){
			textSize = 11,
			borderEnabled = true,
			parent = self.itemDescImage
		}
		local but1 = Button('', Rect(0, -16, 74, 28)){
			anchor = 7,
			pivot = Point(1.2, 1),
			opacity = 0,
			visible = false,
			parent = self.itemDescImage
		}
		but1.name = 'but1'
		but1.AddChild(Image(path..'menuButton.png', Rect(0, 0, but1.width, but1.height)))
		but1.AddChild(Text('회 수', Rect(0, 0, but1.width, but1.height)){
			textAlign = 4,
			textSize = 12,
			borderEnabled = true,
		})
		local but2 = Button('', Rect(0, -16, 74, 28)){
			anchor = 7,
			pivot = Point(-0.2, 1),
			opacity = 0,
			visible = false,
			parent = self.itemDescImage
		}
		but2.name = 'but2'
		but2.AddChild(Image(path..'menuButton.png', Rect(0, 0, but2.width, but2.height)))
		but2.AddChild(Text('구 매', Rect(0, 0, but2.width, but2.height)){
			textAlign = 4,
			textSize = 12,
			borderEnabled = true,
		})
		but1.onClick.Add(function() -- 회수
			buttonSE()
			if self.buySelectNum > 0 then
				local d = self.findMode and self.filteredList[self.buySelectI] or self.itemList[self.buySelectNum]
				
				if playerID==d.u or isGM then
					roading(true)				
					local txt = '['..d.t..','..d.u..','..d.s..']'
					Client.FireEvent('itemRecovery', self.menuSelectNum, self.buySelectNum, txt)
				else
					Client.ShowAlert('내 아이템이 아닙니다.')
				end
			end
		end)
		but2.onClick.Add(function() -- 구매
			buttonSE()
			if self.buySelectNum > 0 then
				local d = self.findMode and self.filteredList[self.buySelectI] or self.itemList[self.buySelectNum]
				if playerID==d.u then
					Client.ShowAlert('내 아이템은 구매할 수 없습니다.')
				else
					self.registerItemPrice(d, '구매')
				end
			end
		end)
		
		self.notItem = Text('<color=#999999>등록된 아이템이 없습니다.</color>', Rect(0, 30, self.itemListPanel.width, 200)){
			textAlign = 1,
			textSize = 16,
			borderEnabled = true,
			visible = false,
			parent = self.itemListPanel
		}
		
		self.listData = {but={}, icon={}, level={}, name={}, time={}, price={}}
		self.backStick = nil
		local t = self.listData
		for i=1, self.maxList do
			t.but[i] = Button(path..'itemListButton.png', Rect(5, 6+49*(i-1), 390, 48)){ 
				opacity = 0,
				visible = false,
				parent = self.itemListPanel
			}
			t.but[i].AddChild(Image(path..'itemListButton.png', Rect(0, 0, t.but[i].width, t.but[i].height)))
			
			local listBg = Image(path..'itemBg.png', Rect(4, 0, 40, 40)){
				anchor = 3,
				pivotY = 0.5,
				parent = t.but[i]
			}
			t.icon[i] = Image(path..'itemBg.png', Rect(4, 4, 32, 32)){
				parent = listBg
			}
			t.level[i] = Text('1', Rect(1, 1, 38, 38)){
				textSize = 10,
				borderEnabled = true,
				parent = listBg
			}
			t.name[i] = Text('진혼의 검\n<size=11><color=#D1D1D1>(수량: 30)</color></size>', Rect(listBg.x+listBg.width+4, 0, 200, t.but[i].height)){
				textAlign = 3,
				textSize = 12,
				borderEnabled = true,
				parent = t.but[i]
			}
			t.time[i] = Text('<color=#D1D1D1>72시간</color>', Rect(t.name[i].x+140, 0, 40, t.but[i].height)){
				textAlign = 3,
				textSize = 10,
				borderEnabled = true,
				parent = t.but[i]
			}
			t.time[i].AddChild(Image(path..'마감.png', Rect(-3, 0, 19, 15)){
				anchor = 3,
				pivot = Point(1, 0.5)
			})
			t.time[i].AddChild(Image(path..'infoLine.png', Rect(5, 0, 2, 13)){
				anchor = 5,
				pivotY = 0.5
			})
			t.price[i] = Text('1,000 <color=#F7DA22>'..tradeData.gold..'</color>', Rect(-4, 0, 150, t.but[i].height)){
				anchor = 5,
				pivot = Point(1, 0.5),
				textAlign = 5,
				textSize = 11,
				borderEnabled = true,
				parent = t.but[i]
			}
			
			
			t.but[i].onClick.Add(function()
				buttonSE()
				but1.visible = true
				but2.visible = true
				
				local tbl = self.findMode and self.filteredList or self.itemList
				local I = i+(self.nowPage-1)*self.maxList
				local data = tbl[I]
				self.buySelectNum = data.index
				self.buySelectI = I
				
				if self.backStick then
					self.backStick.image = path..'itemListButton.png'
				end
				
				if playerID==data.u then
					self.itemDescImage.DOColor(Color(255, 196, 196), 0)
				else
					self.itemDescImage.DOColor(Color.white, 0)
					self.backStick = t.but[i].children[1]
					self.backStick.image = path..'onItemListButton.png'
				end
				
				local opText = ''
				for j, v in ipairs(data.op.v) do
					local statType = data.op.t[j]
					local statName = data.op.i[j]
					opText = opText..StatInfo.type[statType][1]..' '..Stat_Text(statName)..' +'..v..StatInfo.type[statType][2]..'\n'
				end
				opText = opText=='' and '<color=#B2B2B2>옵션없음</color>' or ('<color=magenta>옵션</color>\n<color=cyan>'..opText..'</color>')
				local ko = data.s > 9999 and ('('..numberToKorean(data.s)..')\n') or ''
				local level = data.lv>0 and '<color=#00FF00>+'..data.lv..' </color>' or ''
				itemDescText.text = '<size=13>'..level..getItem(data.I).name..'</size>\n\n판매 가격: '..
					comma(data.s)..' <color=#F7DA22>'..tradeData.gold..'</color>\n<color=#D1D1D1><size=11>'..ko..'(수량: '..comma(data.c)..')</size></color>\n\n'..opText
					
				
			end)
		end
	end
	rightPanelUI()
	
	local sortButtonSize = Point(115, 30)
	local buttonName = {'아이템 등록'--[[, '가격순 정렬']]}
	for i=1, #buttonName do
		local but = Button('', Rect(13+121*(i-1), 383, sortButtonSize.x, sortButtonSize.y)){
			opacity = 0,
			parent = self.mainPanel
		}
		but.name = 'sortButton_'..i
		but.AddChild(Image(path..'sortButton.png', Rect(0, 0, sortButtonSize.x, sortButtonSize.y)))
		but.AddChild(Text(buttonName[i], Rect(0, 0, sortButtonSize.x, sortButtonSize.y)))
		but.children[2].style = textStyle
	end--[[
	self.mainPanel.GetChild('sortButton_2').onClick.Add(function()
		buttonSE()
		if self.itemList then
			if not self.sortMode then self.sortMode=0 end
			self.sortMode = self.sortMode+1
			if self.sortMode > 2 then self.sortMode=0 end
			
			if self.sortMode==0 then
				self.mainPanel.GetChild('sortButton_2').children[1].image = path..'sortButton.png'
				self.mainPanel.GetChild('sortButton_2').children[2].text = buttonName[2]
			elseif self.sortMode==1 then
				self.mainPanel.GetChild('sortButton_2').children[1].image = path..'onSortButton.png'
				self.mainPanel.GetChild('sortButton_2').children[2].text = buttonName[2]..'▼'
			else
				self.mainPanel.GetChild('sortButton_2').children[1].image = path..'onSortButton.png'
				self.mainPanel.GetChild('sortButton_2').children[2].text = buttonName[2]..'▲'
			end
			self:showList()
		end
	end)]]
	
	local nowSelectRegi, nowSelectNum = nil, 0
	local function registerItem()
		buttonSE()
		if self.menuSelectNum <= 0 then
			Client.ShowAlert('좌측 카테고리를 먼저 선택해주세요.')
			return
		end
		
		roading(true)
		if not self.registerDark then
			self.registerDark = Panel(Rect(0, 0, Client.width, Client.height)){
				color = Color.black,
				opacity = 100,
				showOnTop = true
			}
			
			local img = Image(path..'아이템등록/배경.png', Rect(0, 0, 480, 270))
			img.style = centerStyle
			img.SetParent(self.registerDark)
			
			self.registerTitle = Text('', Rect(10, 8, 200, 26)){
				textSize = 14,
				borderEnabled = true,
				parent = img
			}
			
			local closeButton = Button('', Rect(-2, 2, 28, 28)){
				anchor = 2,
				pivotX = 1,
				opacity = 0,
				parent = img
			}
			local closeImage = Image(path..'close.png', Rect(0, 0, 16, 16))
			closeImage.style = centerStyle
			closeImage.SetParent(closeButton)
			
			closeButton.onClick.Add(function()
				buttonSE()
				self.registerDark.visible = false
			end)
			
			local innerImg = Image(path..'아이템등록/아이템칸배경.png', Rect(0, -38, 451, 195)){
				anchor = 7,
				pivot = Point(0.5, 1),
				parent = img
			}
			
			local regiDescPanel = Panel(Rect(0, 0, 189, 200)){
				color = Color.black,
				opacity = 120,
			}
			local regiDescText = Text('', Rect(5, 5, regiDescPanel.width-10, regiDescPanel.height-10)){
				textSize = 12,
				borderEnabled = true,
				parent = regiDescPanel
			}
			local regiDescButton = Button('', Rect(0, -5, 115, 30)){
				opacity = 0,
				anchor = 7,
				pivot = Point(0.5, 1),
				parent = regiDescPanel
			}
			regiDescButton.AddChild(Image(path..'sortButton.png', Rect(0, 0, regiDescButton.width, regiDescButton.height)){ opacity=234 })
			regiDescButton.AddChild(Text('등 록', Rect(0, 0, regiDescButton.width, regiDescButton.height)){
				textAlign = 4,
				textSize = 12,
				borderEnabled = true,
			})
			
			local dbut = Button('', Rect(0, 0, Client.width, Client.height)){
				showOnTop = true,
				opacity = 0,
				visible = false,
			}
			dbut.AddChild(regiDescPanel)
			dbut.onClick.Add(function()
				buttonSE()
				dbut.visible = false
			end)
			
			self.regi = {icon={}, count={}, level={}, dataID={}, uqID={}, op={}}
			regiDescButton.onClick.Add(function()
				buttonSE()
				Client.FireEvent('registerItem', self.regi.uqID[nowSelectNum])
				dbut.visible = false
			end)
			for i=1, 36 do
				local x = 5.5+46*((i%9==0 and 9 or i%9) -1)
				local y = 6+46*(math.ceil(i/9)-1)
				local itemBut = Button('', Rect(x, y, 46, 46)){
					opacity = 0,
					parent = innerImg
				}	
				local back = Image(path..'아이템등록/아이템칸.png', Rect(0, 0, itemBut.width, itemBut.height)){
					parent = itemBut
				}
				local t = self.regi
				t.icon[i] = Image(path..'아이템등록/골드.png', Rect(3, 3, 40, 40)){
					opacity = 0,
					parent = back
				}
				t.count[i] = Text('', Rect(1, 1, 38, 38)){
					textAlign = 8,
					textSize = 11,
					borderEnabled = true,
					parent = t.icon[i]
				}
				t.level[i] = Text('', Rect(0, 0, 40, 40))
				t.level[i].style = t.count[i].style
				t.level[i].textAlign = 0
				t.dataID[i] = -1
				t.uqID[i] = -1
				
				itemBut.onClick.Add(function()
					buttonSE()
					if t.dataID[i] ~= -1 then
						if nowSelectRegi then
							nowSelectRegi.image = path..'아이템등록/아이템칸.png'
							nowSelectRegi.opacity = 255
						end
						back.image = path..'아이템등록/on아이템칸.png'
						back.opacity = 222
						
						nowSelectRegi = back
						nowSelectNum = i
						dbut.visible = true
						
						local mouse = Input.mousePositionToScreen
						regiDescPanel.x = mouse.x+11
						regiDescPanel.y = mouse.y/2
						
						local opText = ''
						for j, v in ipairs(t.op[i].v) do
							local statType = t.op[i].t[j]
							local statName = t.op[i].i[j]
							opText = opText..StatInfo.type[statType][1]..' '..Stat_Text(statName)..' +'..v..StatInfo.type[statType][2]..'\n'
						end
						opText = opText=='' and '<color=#B2B2B2>옵션없음</color>' or ('<color=magenta>옵션</color>\n'..opText)
						local lv = t.level[i].text=='' and '' or (t.level[i].text..' ')
						regiDescText.text = '<size=14>'..lv..getItem(t.dataID[i]).name..'</size>\n\n<color=cyan>'..opText..'</color>'
					end
				end)
			end
			
			local pageLeft = Button('', Rect(-110, -6, 34, 25)){
				opacity = 0,
				anchor = 8,
				pivot = Point(1, 1),
				parent = img
			}
			pageLeft.AddChild(Image(path..'아이템등록/좌측버튼.png', Rect(0, 0, pageLeft.width, pageLeft.height)))
			
			local pageRight = Button('', Rect(-18, -6, 34, 25)){
				opacity = 0,
				anchor = 8,
				pivot = Point(1, 1),
				parent = img
			}
			pageRight.AddChild(Image(path..'아이템등록/우측버튼.png', Rect(0, 0, pageRight.width, pageRight.height)))
			
			local pagePanel = Panel(Rect(-56, -6, 50, 25)){
				color = Color.white,
				opacity = 23,
				anchor = 8,
				pivot = Point(1, 1),
				parent = img
			}
			
			pageLeft.onClick.Add(function()
				buttonSE()
				if self.nowBagPage > 1 then
					self.nowBagPage = self.nowBagPage-1
					local maxPage = math.ceil(self.bagIdx/36)
					self.regi.pageText.text = self.nowBagPage..'/'..(maxPage==0 and 1 or maxPage)
					if nowSelectRegi then
						nowSelectRegi.image = path..'아이템등록/아이템칸.png'
						nowSelectRegi.opacity = 255
					end
					self:showBagList()
				end
			end)
			pageRight.onClick.Add(function()
				buttonSE()
				local maxPage = math.ceil(self.bagIdx/36)
				if self.nowBagPage < maxPage then
					self.nowBagPage = self.nowBagPage+1
					self.regi.pageText.text = self.nowBagPage..'/'..(maxPage==0 and 1 or maxPage)
					if nowSelectRegi then
						nowSelectRegi.image = path..'아이템등록/아이템칸.png'
						nowSelectRegi.opacity = 255
					end
					self:showBagList()
				end
			end)
			
			self.regi.pageText = Text('1/1', Rect(0, 0, pagePanel.width, pagePanel.height)){
				textSize = 12,
				textAlign = 4,
				borderEnabled = true,
				parent = pagePanel
			}
		end
		if nowSelectRegi then
			nowSelectRegi.image = path..'아이템등록/아이템칸.png'
			nowSelectRegi.opacity = 255
		end
		
		function self:showBagList()
			local t = self.regi
			for i=1, 36 do
				t.icon[i].SetOpacity(0)
				t.level[i].text = ''
				t.count[i].text = ''
				t.dataID[i] = -1
				t.uqID[i] = -1
			end
			
			local page = (self.nowBagPage-1)
			local maxCount = self.nowBagPage*36 > self.bagIdx and self.bagIdx or self.nowBagPage*36
			local idx = 1
			for i=page*36+1, maxCount do
				local v = self.bagData
				
				t.icon[idx].SetImageID(getItem(v.dataID[i]).imageID)
				t.icon[idx].SetOpacity(255)
				t.level[idx].text = v.level[i]>0 and '<color=#00FF00>+'..v.level[i]..'</color>' or ''
				t.count[idx].text = v.count[i]
				t.dataID[idx], t.uqID[idx] = v.dataID[i], v.uqID[i]
				t.op[idx] = {t={}, i={}, v={}}
				for j, b in ipairs(v.op[i].t) do
					t.op[idx].t[j] = b
					t.op[idx].i[j] = v.op[i].t[j]
					t.op[idx].v[j] = v.op[i].v[j]
				end
				idx = idx+1
			end
		end
		
		
		self.nowBagPage = 1
		self.bagData = {dataID={}, level={}, count={}, uqID={}, op={}}
		self.bagIdx = 0
		local data = self.bagData
		for _, item in ipairs(me.GetItems()) do
			if getItem(item.dataID).type == self.menu[self.menuSelectNum].type and getItem(item.dataID).canTrade then
				self.bagIdx = self.bagIdx+1
				local idx = self.bagIdx
				data.dataID[idx] = item.dataID
				data.level[idx] = item.level
				data.count[idx] = item.count
				data.uqID[idx] = item.id
				data.op[idx] = {t={}, i={}, v={}}
				for i, v in ipairs(item.options) do
					data.op[idx].t[i] = v.type
					data.op[idx].i[i] = v.statID
					data.op[idx].v[i] = v.value
				end
			end
		end
		
		local maxPage = math.ceil(self.bagIdx/36)
		self.regi.pageText.text = self.nowBagPage..'/'..(maxPage==0 and 1 or maxPage)
		self.registerDark.visible = true
		self.registerTitle.text = '<color=#B7B7B7>아이템 등록 - </color><color=#ffcc00>'..self.menu[self.menuSelectNum].name..'</color>'
		self:showBagList()
		roading(false)
	end
	
	self.mainPanel.GetChild('sortButton_1').onClick.Add(registerItem)
	
	local findPanel = Image(path..'검색패널.png', Rect(-10, -8, 187, 27)){
		anchor = 8,
		pivot = Point(1, 1),
		parent = self.mainPanel
	}
	local lensBut = Button('', Rect(-2, 0, 27, 27)){
		opacity = 0,
		anchor = 2,
		pivotX = 1,
		parent = findPanel
	}
	lensBut.AddChild(Image(path..'돋보기.png', Rect(-5, 0, 15, 16)){
		anchor = 5,
		pivot = Point(1, 0.5),
	})
	local findItemInputField = InputField(Rect(2, 0, 156, 32)){
		color = Color(234, 234, 234),
		textSize = 12,
		placeholder = '<color=#B5B5B5>아이템 검색</color>',
		characterLimit = 16,
		parent = findPanel
	}
	
	
	
	
	
	local mainPageLeft = Button('', Rect(-310, -9, 34, 25)){
		opacity = 0,
		anchor = 8,
		pivot = Point(1, 1),
		parent = self.mainPanel
	}
	mainPageLeft.AddChild(Image(path..'아이템등록/좌측버튼.png', Rect(0, 0, mainPageLeft.width, mainPageLeft.height)))
	
	local mainPageRight = Button('', Rect(-218, mainPageLeft.y, 34, mainPageLeft.height)){
		opacity = 0,
		anchor = 8,
		pivot = Point(1, 1),
		parent = self.mainPanel
	}
	mainPageRight.AddChild(Image(path..'아이템등록/우측버튼.png', Rect(0, 0, mainPageRight.width, mainPageRight.height)))
	
	mainPageLeft.onClick.Add(function()
		buttonSE()
		if self.nowPage > 1 then
			self.nowPage = self.nowPage-1
			
			self:showList()
		end
	end)
	mainPageRight.onClick.Add(function()
		buttonSE()
		if self.itemList then
			local tbl = self.findMode and self.filteredList or self.itemList
			if self.nowPage < math.ceil(#tbl/self.maxList) then
				self.nowPage = self.nowPage+1
				self:showList()
			end
		end
	end)
	
	local mainPagePanel = Panel(Rect(-256, mainPageLeft.y, 50, mainPageLeft.height)){
		color = Color.white,
		opacity = 23,
		anchor = 8,
		pivot = Point(1, 1),
		parent = self.mainPanel
	}
	
	self.mainPageText = Text('1/1', Rect(0, 0, mainPagePanel.width, mainPagePanel.height)){
		textSize = 12,
		textAlign = 4,
		borderEnabled = true,
		parent = mainPagePanel
	}
	
	--[[function self.offFindMode()
		findItemInputField.text = ''
		self.filteredList = {}
		lensBut.children[1].DOColor(Color.white, 0)
		self.findMode = false
	end]]
	
	function self.filter()
		buttonSE()
		self.filteredList = {}
		local text = findItemInputField.text
		
		if self.itemList then
			if text~='' then
				lensBut.children[1].DOColor(Color.cyan, 0)
				for i, v in ipairs(self.itemList) do
					if string.find(getItem(v.I).name, text) then
						table.insert(self.filteredList, v)
					end
				end
				self.findMode = true
			else
				lensBut.children[1].DOColor(Color.white, 0)
				self.findMode = false
			end
			self:showList()
		end
	end
	
	lensBut.onClick.Add(self.filter)
	findItemInputField.onValueChanged.Add(self.filter)
end

local typeMapping = {
	['등록'] = 1,
	['구매'] = 2
}
function exchange.registerItemPrice(uqID, tradeTypeText)
	exchange.tradingType = typeMapping[tradeTypeText]
	
	local item = nil
	if exchange.tradingType==1 then
		exchange.registerDark.visible = false
		item = me.GetItem(uqID)
	
		if not item then
			Client.ShowAlert('<size=18>선택하신 아이템이 없습니다.</size>')
			return
		end
		exchange.itemUqID = uqID
	else
		if not uqID then
			Client.ShowAlert('<size=18>선택하신 아이템이 없습니다.</size>')
			return
		end
		item = {
			dataID = uqID.I,
			level = uqID.lv,
			count = uqID.c
		}
		exchange.buyItemData = {
			t = uqID.t, u = uqID.u, s = uqID.s
		}
	end
	
	
	if not exchange.dataMask then
		exchange.dataMask = Panel(Rect(0, 0, Client.width, Client.height)){
			showOnTop = true,
			color = Color.black,
			opacity = 200
		}
		exchange.sellData = {
			nowInput = 1, -- buttonTarget
			price={1, 1}, -- realPrice
			txt={}, pal={}, inTxt={}, -- objTable
			info = {
				text = {
					{'판매수량', '개당 판매금액', '평균 거래가', '총 판매금액', '────┼   판매정보 입력   ┼────', '판매수량 입력'},
					{'구매수량', '개당 구매금액', '평균 거래가', '총 구매금액', '────┼   구매정보 입력   ┼────', '구매수량 입력'}
				},
				y = {72, 106, 140, 184},	
			}
		}
		local t = exchange.sellData
		
		local bgImg = Image(path..'makeBGpanel.png', Rect(0, 0, 600, 400))
		bgImg.style = centerStyle
		bgImg.SetParent(exchange.dataMask)
		
		exchange.titleText = Text('', Rect(0, 24, bgImg.width, 50)){
			textAlign = 1,
			textSize = 20,
			parent = bgImg
		}
		
		local itemInfoBG = Panel(Rect(20, 70, 350, 310)){
			color = Color.black,
			opacity = 50,
			parent = bgImg
		}
		
		local itemBgImg = Image(path..'itemBg.png', Rect(11, 12, 48, 48)){
			parent = itemInfoBG
		}
		t.itemIcon = Image(path..'itemBg.png', Rect(0, 0, 40, 40))
		t.itemIcon.style = centerStyle
		t.itemIcon.SetParent(itemBgImg)
		t.itemCount = Text('1', Rect(2, 2, 44, 44)){
			textAlign = 8,
			textSize = 10,
			borderEnabled = true,
			parent = itemBgImg
		}
		t.itemLevel = Text('1', Rect(1, 1, 46, 46)){
			textSize = 11,
			borderEnabled = true,
			parent = itemBgImg
		}
		t.itemIconText = Text('item name', Rect(itemBgImg.width+8, 0, 200, itemBgImg.height)){
			anchor = 3,
			pivotY = 0.5,
			textAlign = 3,
			textSize = 14,
			borderEnabled = true,
			parent = itemBgImg
		}
		
		
		for i=1, 4 do
			t.txt[i] = Text('', Rect(19, t.info.y[i], 120, 26)){
				textAlign = 3,
				textSize = 13,
				borderEnabled = true,
				parent = itemInfoBG
			}
			
			if i <= 2 then
				local but = Button('', Rect(124, t.info.y[i], 200, t.txt[i].height)){
					opacity = 88,
					parent = itemInfoBG
				}
				-- but.name = 'inputBut_'..i
				
				t.pal[i] = Panel(Rect(0, 0, but.width, but.height)){
					color = Color.black,
					opacity = 88,
					parent = but
				}
				local img = Image(path..'sellButton.png', Rect(0, 0, t.pal[i].width, t.pal[i].height)){ 
					visible = false,
					parent = t.pal[i]
				}
				but.onClick.Add(function()
					buttonSE()
					if not img.visible then
						t.nowInput = i
					end
				end)
			else
				t.pal[i] = Panel(Rect(124, t.info.y[i], 200, t.txt[i].height)){
					color = Color.black,
					opacity = 88,
					parent = itemInfoBG
				}
				local img = Image(path..'sellButton.png', Rect(0, 0, t.pal[i].width, t.pal[i].height)){ 
					parent = t.pal[i]
				}
			end
			
			t.inTxt[i] = Text('1', Rect(0, 0, t.pal[i].width, t.pal[i].height)){
				textAlign = 4,
				textSize = 12,
				borderEnabled = true,
				parent = t.pal[i]
			}
		end
		
		t.noticeText = Text(''){
			rect = Rect(0, 225, itemInfoBG.width, 30),
			textAlign = 4,
			textSize = 12,
			parent = itemInfoBG
		}
		local function notice(text)
			t.noticeText.text = text
			t.noticeText.DOColor(Color(255, 180, 0, 255), 0)
			t.noticeText.DOColor(Color(255, 180, 0, 255), 1)
			t.noticeText.DOColor(Color(255, 180, 0, 0), 2).SetDelay(1)
		end
		
		
		local but1 = Button('', Rect(0, 265, 115, 30)){
			anchor = 1,
			pivotX = 1.2,
			opacity = 0,
			parent = itemInfoBG
		}
		but1.AddChild(Image(path..'sortButton.png', Rect(0, 0, but1.width, but1.height)))
		but1.AddChild(Text('취 소', Rect(0, 0, but1.width, but1.height)){
			textAlign = 4,
			borderEnabled = true,
		})
		local but2 = Button('', Rect(0, 265, 115, 30)){
			anchor = 1,
			pivotX = -0.2,
			opacity = 0,
			parent = itemInfoBG
		}
		but2.AddChild(Image(path..'sortButton.png', Rect(0, 0, but2.width, but2.height)))
		exchange.regiText = Text('등 록', Rect(0, 0, but2.width, but2.height)){
			textAlign = 4,
			borderEnabled = true,
			parent = but2
		}
		but1.onClick.Add(function()
			buttonSE()
			t.price[1], t.price[2] = 1, 1
			exchange.dataMask.visible = false
		end)
		but2.onClick.Add(function()
			buttonSE()
			if t.price[1] <= 0 or t.price[2] <= 0 then
				notice('* 금액이나 수량이 1 이상이어야 합니다.')
				return
			end
			
			if exchange.tradingType==1 then
				roading(true)
				Client.FireEvent('itemSell', exchange.menuSelectNum, exchange.itemUqID, t.price[1], t.price[2])
			else
				if t.price[1] < t.buyMin then
					notice('* 해당 아이템은 '..comma(t.buyMin)..'개부터 구매 가능합니다.')
					return
				end
				
				roading(true)
				local d = exchange.buyItemData
				local txt = '['..d.t..','..d.u..','..d.s..']'
				Client.FireEvent('itemBuy', exchange.menuSelectNum, exchange.buySelectNum, t.price[1], txt)
			end
		end)
		Client.GetTopic('itemSellEnd').Add(function()
			roading(false)
			exchange.dataMask.visible = false
		end)
		
		
		
		local typingInfoBG = Panel(Rect(374, itemInfoBG.y, 206, itemInfoBG.height))
		typingInfoBG.style = itemInfoBG.style
		
		t.txt[5] = Text('판매수량 입력', Rect(0, 8, typingInfoBG.width, 30)){
			textAlign = 4,
			parent = typingInfoBG
		}
		
		local typingBgPanel = Panel(Rect(6, 47, typingInfoBG.width-6*2, typingInfoBG.width-6*2)){
			color = Color.white,
			opacity = 21,
			parent = typingInfoBG
		}
		
		local boardlist = {1,2,3,'+10',4,5,6,'+50',7,8,9,'+100','MAX',0,'←','Clear'}
		local inputBtn = {}
		local butSize = 45
		for i, event in ipairs(boardlist) do
			local x = 5+46*((i%4==0 and 4 or i%4)-1)
			local y = 5+46*(math.ceil(i/4)-1)
			local but = Button('', Rect(x, y, butSize, butSize)){
				color = Color.white,
				opacity = 89,
				parent = typingBgPanel
			}
			
			but.AddChild(Text(event, Rect(0, 0, butSize, butSize)){ textAlign=4 })
			
			local function result()
				me.PlaySE('거래소/press.ogg', 1)
				local key = t.nowInput
				local sum = t.price[key]
				if key==1 then
					local count = tonumber(t.itemCount.text)
					if count < sum then
						sum = count
						notice('* 해당 아이템은 '..count..'개까지 '..((exchange.tradingType==1 and '등록') or '구매')..' 가능합니다.')
					--[[elseif exchange.tradingType==2 and t.buyMin > sum then
						sum = t.buyMin
						notice('* 해당 아이템은 '..t.buyMin..'개부터 구매 가능합니다.')]]
					end
				elseif key==2 then
					if exchange.max < sum then
						sum = exchange.max
						notice('* '..comma(exchange.max)..' 까지 설정 가능합니다.')
					end
				end
				
				if sum < 0 then
					sum = 0
				end
				t.price[key] = sum
				t.inTxt[key].text = comma(sum)
				t.inTxt[4].text = comma(t.price[1]*t.price[2])
			end
			
			local number = tonumber(event)
			if number then
				but.color = Color(114, 142, 219, 200)
				but.onClick.Add(function()
					local key = t.nowInput
					if key <= 0 then return end
					t.price[key] = number > 9 and t.price[key]+number or tonumber(t.price[key]..number)
					result()
				end)
			elseif event=='MAX' then
				but.onClick.Add(function()
					if t.nowInput <= 0 then return end
					t.price[t.nowInput] = exchange.max
					result()
				end)
			elseif event=='←' then
				but.onClick.Add(function()
					if t.nowInput <= 0 then return end
					local txt = tostring(t.price[t.nowInput])
					local var = tonumber(string.sub(txt, 1, #txt-1))
					t.price[t.nowInput] = var and var or 0
					result()
				end)
			elseif event=='Clear' then
				but.onClick.Add(function()
					if t.nowInput <= 0 then return end
					t.price[t.nowInput] = 0
					result()
				end)
			end
		end
		local noticeText2 = Text('<color=#B5B5B5>* 개인간 거래 시 발생한 문제는 \n운영팀이 개입하지 않습니다.</color>'){
			rect = Rect(0, 257, typingInfoBG.width, 32),
			textAlign = 4,
			textSize = 12,
			parent = typingInfoBG
		}
	end
	
	local data = exchange.sellData
	for i=1, 4 do
		data.txt[i].text = data.info.text[exchange.tradingType][i]
	end
	exchange.titleText.text = data.info.text[exchange.tradingType][5]
	data.txt[5].text = data.info.text[exchange.tradingType][6]
	
	
	data.itemIcon.SetImageID(getItem(item.dataID).imageID)
	data.itemLevel.text = item.level == 0 and '' or ('<color=#00FF00>+'..item.level..' </color>')
	data.itemIconText.text = getItem(item.dataID).name
	data.itemCount.text = item.count -- 필요
	
	data.pal[1].children[1].visible = false
	if getItem(item.dataID).maxCount == 1 then
		data.pal[1].children[1].visible = true
		data.nowInput = 2
	end
	
	data.price[1], data.price[2] = 1, 1
	if exchange.tradingType==1 then
		data.pal[2].children[1].visible = false
		data.inTxt[1].text = 1
		data.inTxt[2].text = 1
		data.inTxt[4].text = 1	
		exchange.regiText.text = '등 록'
	else
		data.buyMin = math.ceil(item.count/10.1)
		data.nowInput = 1
		data.pal[2].children[1].visible = true
		
		data.price[1] = data.buyMin
		data.price[2] = uqID.s
		data.inTxt[1].text = comma(data.buyMin)
		data.inTxt[2].text = comma(uqID.s)
		data.inTxt[4].text = comma(data.price[1]*data.price[2])
		exchange.regiText.text = '구 매'
	end
	
	exchange.dataMask.visible = true
end
Client.GetTopic('registerItemPrice').Add(exchange.registerItemPrice)

Client.FireEvent('exchangeData')
Client.GetTopic('exchangeData').Add(function(menuText, tradeText)
	exchange.menu = Utility.JSONParse(menuText)
	tradeData = Utility.JSONParse(tradeText)
	exchange:init()
end)

function exchange:showList()
	local t = self.listData
	for i=1, self.maxList do
		t.but[i].visible = false
	end
	
	if self.backStick then
		self.backStick.image = path..'itemListButton.png'
	end
	--[[
	self.LastList = {}
	for i, v in ipairs(self.itemList) do self.LastList[i] = v end
	if self.sortMode==1 then
		table.sort(self.LastList, function(a, b) return a.s < b.s end)
	elseif self.sortMode==2 then
		table.sort(self.LastList, function(a, b) return a.s > b.s end)
	end]]
	
	local tbl = self.findMode and self.filteredList or self.itemList--self.LastList
	
	local maxPage = math.ceil(#tbl/self.maxList)
	if maxPage > 0 and maxPage < self.nowPage then
		self.nowPage = maxPage
	elseif maxPage==0 then
		self.nowPage = 1
	end
	self.mainPageText.text = self.nowPage..'/'..(maxPage==0 and 1 or maxPage)
	
	local page, maxSum = (self.nowPage-1), self.nowPage*self.maxList
	local maxCount = maxSum > #tbl and #tbl or maxSum
	local objIdx = 1
	for i=page*self.maxList+1, maxCount do
		local v = tbl[i]
		
		t.icon[objIdx].SetImageID(getItem(v.I).imageID)
		t.icon[objIdx].visible = true
		t.level[objIdx].text = v.lv>0 and '<color=#00FF00>+'..v.lv..' </color>' or ''
		t.name[objIdx].text = getItem(v.I).name..'\n<size=11><color=#D1D1D1>(수량: '..comma(v.c)..')</color></size>'
		
		local sumTime = v.t+260000 - self.nowTime
		local hour = ''
		if sumTime < 3600 then
			hour = '<color=#D17F7F>('..math.floor(sumTime/60)..'분)</color>'
		else
			hour = '<color=#D1D1D1>('..math.floor(sumTime/3600)..'시간)</color>'
		end
		t.time[objIdx].text = hour
		t.price[objIdx].text = comma(v.s)..' <color=#F7DA22>'..tradeData.gold..'</color>'
		if playerID==v.u then
			t.but[objIdx].children[1].DOColor(Color(255, 196, 196), 0)
		else
			t.but[objIdx].children[1].DOColor(Color.white, 0)
		end
		t.but[objIdx].visible = true
		objIdx = objIdx+1
	end
	self.itemListPanel.height = 6+49*(maxCount-(page*self.maxList+1)+1)
	
	
	self.scrollBar.value = 1
end

Client.GetTopic('exchangeOpen').Add(function(txt, nowTime)
	exchange.nowTime = nowTime
	exchange.nowPage = 1
	me = Client.myPlayerUnit
	
	if txt then
		roading(true)
		exchange.itemList = Utility.JSONParse(txt)
		for i, v in ipairs(exchange.itemList) do v.index=i end
		exchange.filter()
		exchange:showList()
		roading(false)
		if #exchange.itemList > 0 then
			exchange.notItem.visible = false
		else
			exchange.notItem.visible = true
		end
	elseif exchange.menuSelectNum~=0 then
		Client.FireEvent('exchangeOpen', exchange.menuSelectNum)
	end
	
	exchange.itemDescImage.children[1].text = ''
	exchange.itemDescImage.GetChild('but1').visible = false
	exchange.itemDescImage.GetChild('but2').visible = false
	exchange.mainPanel.visible = true
end)

Client.GetTopic('dayToCount').Add(function(count) dayToCount = count end)