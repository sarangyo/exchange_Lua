local storageBox = {}


playerID, isGM = nil, false
local path = 'Pictures/거래소UI/택배보관함/'
local function buttonSE() Client.myPlayerUnit.PlaySE('거래소/click.ogg', 1) end
function storageBox:init()
	self.backPanel = Panel(Rect(0, 0, Client.width, Client.height)){
		color = Color.black,
		opacity = 111,
		showOnTop = true,
		visible = false
	}
	local mainPal = Image(path..'패널.png', Rect(0, 0, 480, 255)){
		anchor = 4,
		pivot = Point(0.5, 0.5),
		parent = self.backPanel
	}
	self.titleText = Text('배송이 완료되었습니다.', Rect(0, 0, mainPal.width, 45)){
		color = Color.black,
		textAlign = 4,
		textSize = 14,
		parent = mainPal
	}
	local innerPanel = Panel(Rect(0, 49, 440, 156)){
		opacity = 0,
		anchor = 1,
		pivotX = 0.5,
		parent = mainPal
	}
	self.itemData = {}
	for i=1, 12 do
		local x = 16+68*((i%6==0 and 6 or i%6)-1)
		local y = 15+71*(math.ceil(i/6)-1)
		local but = Button('', Rect(x, y, 56, 56)){
			opacity = 0,
			parent = innerPanel
		}
		self.itemData[i] = Image(path..'아이템배경.png', Rect(0, 0, but.width, but.height)){
			parent = but
		}
		local icon = Image(path..'아이템배경.png', Rect(0, 0, 48, 48)){
			anchor = 4,
			pivot = Point(0.5, 0.5),
			visible = false,
			parent = self.itemData[i]
		}
		icon.name = 'itemIcon'
		local count = Text('', Rect(3, 3, self.itemData[i].width-6, self.itemData[i].height-6)){
			textAlign = 8,
			textSize = 11,
			borderEnabled = true,
			parent = self.itemData[i]
		}
		count.name = 'itemCount'
		local level = Text('', Rect(2, 2, self.itemData[i].width-4, self.itemData[i].height-4)){
			textSize = 11,
			borderEnabled = true,
			parent = self.itemData[i]
		}
		level.name = 'itemLevel'
		
		but.onClick.Add(function()
			buttonSE()
			if self.data[i] then
				roading(true)
				Client.FireEvent('takeOut', i)
			end
		end)
	end
	local palY = innerPanel.y+innerPanel.height
	local pal = Panel(Rect(0, palY+3, 100, mainPal.height-palY)){
		anchor = 1,
		pivotX = 0.5,
		opacity = 0,
		parent = mainPal
	}
	local closeBut = Button('', Rect(0, 0, 90, 30)){
		opacity = 0,
		anchor = 4,
		pivot = Point(0.5, 0.5),
		parent = pal
	}
	closeBut.AddChild(Image(path..'우편확인.png', Rect(0, 0, closeBut.width, closeBut.height)))
	closeBut.AddChild(Text('확 인', Rect(0, 0, closeBut.width, closeBut.height)){
		textAlign = 4,
		borderEnabled = true,
		borderColor = Color(43, 43, 43)
	})
	closeBut.onClick.Add(function()
		buttonSE()
		self.backPanel.visible = false
	end)
	Client.FireEvent('playerID')
	Client.GetTopic('playerID').Add(function(i, j) playerID=i isGM=j end)
end
storageBox:init()

local getItem = Client.GetItem
local function showList()
	for i=1, 12 do
		local o = storageBox.itemData[i]
		o.GetChild('itemIcon').visible, o.GetChild('itemCount').text, o.GetChild('itemLevel').text = false, '', ''
	end
	
	if #storageBox.data==0 then
		storageBox.titleText.text = '배송받은 물건이 없습니다.'
		return
	else
		storageBox.titleText.text = '배송이 완료되었습니다.'
	end
	
	for i=1, #storageBox.data > 12 and 12 or #storageBox.data do
		local o = storageBox.itemData[i]
		local icon, count, level = o.GetChild('itemIcon'), o.GetChild('itemCount'), o.GetChild('itemLevel')
		local t = storageBox.data[i]
		if t.o then
			icon.image = path..'골드.png'
			count.text = comma(t.c*t.s)
			count.textSize = 10
			count.textAlign = 7
			level.text = ''
		else
			icon.SetImageID(getItem(t.I).imageID)
			count.text = t.c
			count.textSize = 11
			count.textAlign = 8
			level.text = t.lv==0 and '' or '<color=#00FF00>+'..t.lv..'</color>'
		end
		icon.visible = true
	end
end

Client.GetTopic('storageBoxOpen').Add(function(txt)
	storageBox.data = Utility.JSONParse(txt)
	showList()
	storageBox.backPanel.visible = true
end)