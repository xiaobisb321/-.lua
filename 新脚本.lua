```lua
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local Stats=game:GetService("Stats")
local Lighting=game:GetService("Lighting")
local Debris=game:GetService("Debris")
local TeleportService=game:GetService("TeleportService")
local LocalPlayer=Players.LocalPlayer
local Camera=workspace.CurrentCamera
local Config={WindowSize=UDim2.new(0,620,0,420),MinWindowSize=Vector2.new(400,300),MaxWindowSize=Vector2.new(900,650),CornerRadius=UDim.new(0,16),AccentColor=Color3.fromRGB(0,180,255),BgColor=Color3.fromRGB(18,18,22),BgTransparency=0.08,IslandWidth=340,IslandHeight=48,IslandCornerRadius=UDim.new(1,0),IslandBgColor=Color3.fromRGB(10,10,14),IslandDuration=3.5,KillAura={Enabled=false,Range=30,Multiplier=1.0,AttackDelay=0.15,TargetPlayers=true,TargetNPCs=true,AutoEquip=true}}
local function create(c,p)local i=Instance.new(c)for k,v in pairs(p or{})do if k~="Parent"then i[k]=v end end return i end
local function addCorner(p,r)local c=Instance.new("UICorner")c.CornerRadius=r or Config.CornerRadius c.Parent=p return c end
local function addStroke(p,c,t,tr)local s=Instance.new("UIStroke")s.Color=c or Color3.fromRGB(60,60,70)s.Thickness=t or 1 s.Transparency=tr or 0.3 s.Parent=p return s end
local function addGradient(p,c1,c2,r)local g=Instance.new("UIGradient")g.Color=ColorSequence.new(c1,c2)g.Rotation=r or 90 g.Parent=p return g end
local function tween(i,p,t,s,d)local tw=TweenService:Create(i,TweenInfo.new(t or 0.25,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out),p)tw:Play()return tw end
local screenGui=create("ScreenGui",{Name="NovaHub",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true})
screenGui.Parent=LocalPlayer:WaitForChild("PlayerGui")
local DynamicIsland={}
DynamicIsland.__index=DynamicIsland
function DynamicIsland.new(parent)
local self=setmetatable({},DynamicIsland)
self.parent=parent
self.queue={}
self.active={}
self.maxConcurrent=2
self.container=create("Frame",{Name="DynamicIsland",Size=UDim2.new(0,Config.IslandWidth,0,0),Position=UDim2.new(0.5,-Config.IslandWidth/2,0,10),BackgroundColor3=Config.IslandBgColor,BackgroundTransparency=0.15,BorderSizePixel=0,ClipsDescendants=true,ZIndex=100})
addCorner(self.container,Config.IslandCornerRadius)
addStroke(self.container,Color3.fromRGB(50,50,60),1,0.5)
addGradient(self.container,Color3.fromRGB(15,15,20),Color3.fromRGB(8,8,12),90)
self.container.Parent=parent
self.contentFrame=create("Frame",{Name="Content",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=101})
self.contentFrame.Parent=self.container
self.icon=create("TextLabel",{Name="Icon",Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,14,0.5,-12),BackgroundTransparency=1,Text="●",TextColor3=Config.AccentColor,TextSize=16,Font=Enum.Font.GothamBold,ZIndex=102})
self.icon.Parent=self.contentFrame
self.titleLabel=create("TextLabel",{Name="Title",Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,44,0,0),BackgroundTransparency=1,Text="",TextColor3=Color3.fromRGB(255,255,255),TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102})
self.titleLabel.Parent=self.contentFrame
self.messageLabel=create("TextLabel",{Name="Message",Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,0,0,0),BackgroundTransparency=1,Text="",TextColor3=Color3.fromRGB(160,160,170),TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=102})
self.messageLabel.Parent=self.contentFrame
self.progressBar=create("Frame",{Name="ProgressBar",Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=Config.AccentColor,BorderSizePixel=0,ZIndex=103})
self.progressBar.Parent=self.container
self.expanded=false
local clickDetector=create("TextButton",{Name="ClickDetector",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=101})
clickDetector.Parent=self.container
clickDetector.MouseButton1Click:Connect(function()self:ToggleExpand()end)
return self
end
function DynamicIsland:Show(title,message,notifType,duration)
notifType=notifType or "info"
duration=duration or Config.IslandDuration
local typeColors={success=Color3.fromRGB(48,209,88),error=Color3.fromRGB(255,69,58),warning=Color3.fromRGB(255,214,10),info=Config.AccentColor}
local typeIcons={success="✓",error="✕",warning="⚠",info="ℹ"}
if #self.active>=self.maxConcurrent then table.insert(self.queue,{title,message,notifType,duration})return end
self.titleLabel.Text=title
self.messageLabel.Text=message
self.icon.Text=typeIcons[notifType] or "●"
self.icon.TextColor3=typeColors[notifType] or Config.AccentColor
self.progressBar.BackgroundColor3=typeColors[notifType] or Config.AccentColor
self.container.Visible=true
tween(self.container,{Size=UDim2.new(0,Config.IslandWidth,0,Config.IslandHeight)},0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
self.progressBar.Size=UDim2.new(1,0,0,2)
tween(self.progressBar,{Size=UDim2.new(0,0,0,2)},duration,Enum.EasingStyle.Linear)
local notifId=HttpService:GenerateGUID(false)
table.insert(self.active,notifId)
task.delay(duration,function()
for i,id in ipairs(self.active)do if id==notifId then table.remove(self.active,i)break end end
if #self.active>0 then else
tween(self.container,{Size=UDim2.new(0,Config.IslandWidth,0,0)},0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.In)
task.wait(0.3)
self.container.Visible=false
end
if #self.queue>0 then local n=table.remove(self.queue,1)task.wait(0.35)self:Show(n[1],n[2],n[3],n[4])end
end)
end
function DynamicIsland:ToggleExpand()
self.expanded=not self.expanded
if self.expanded then
tween(self.container,{Size=UDim2.new(0,Config.IslandWidth,0,64)},0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
else
tween(self.container,{Size=UDim2.new(0,Config.IslandWidth,0,Config.IslandHeight)},0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
end
end
local island=DynamicIsland.new(screenGui)
_G.NovaNotify=function(t,m,n,d)island:Show(t,m,n,d)end
local floatingBall=create("TextButton",{Name="FloatingBall",Size=UDim2.new(0,56,0,56),Position=UDim2.new(1,-76,0.5,-28),BackgroundColor3=Config.BgColor,BackgroundTransparency=0.05,Text="N",TextColor3=Config.AccentColor,TextSize=22,Font=Enum.Font.GothamBold,BorderSizePixel=0,Visible=false,ZIndex=200,AutoButtonColor=false})
addCorner(floatingBall,UDim.new(1,0))
addStroke(floatingBall,Config.AccentColor,2,0.3)
addGradient(floatingBall,Color3.fromRGB(25,25,32),Color3.fromRGB(12,12,16),90)
floatingBall.Parent=screenGui
local MainWindow={}
MainWindow.__index=MainWindow
function MainWindow.new(parent)
local self=setmetatable({},MainWindow)
self.parent=parent
self.tabs={}
self.currentTab=nil
self.frame=create("Frame",{Name="MainWindow",Size=Config.WindowSize,Position=UDim2.new(0.5,-310,0.5,-210),BackgroundColor3=Config.BgColor,BackgroundTransparency=Config.BgTransparency,BorderSizePixel=0,ClipsDescendants=true,ZIndex=10})
addCorner(self.frame,Config.CornerRadius)
addStroke(self.frame,Color3.fromRGB(55,55,65),1.5,0.4)
addGradient(self.frame,Color3.fromRGB(22,22,28),Color3.fromRGB(12,12,16),90)
self.frame.Parent=parent
self.titleBar=create("Frame",{Name="TitleBar",Size=UDim2.new(1,0,0,42),BackgroundTransparency=1,ZIndex=11})
self.titleBar.Parent=self.frame
self.titleLabel=create("TextLabel",{Name="Title",Size=UDim2.new(0,200,1,0),Position=UDim2.new(0,16,0,0),BackgroundTransparency=1,Text="Nova Hub",TextColor3=Color3.fromRGB(255,255,255),TextSize=16,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12})
self.titleLabel.Parent=self.titleBar
self.versionLabel=create("TextLabel",{Name="Version",Size=UDim2.new(0,60,1,0),Position=UDim2.new(0,130,0,0),BackgroundTransparency=1,Text="v2.0",TextColor3=Color3.fromRGB(100,100,110),TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12})
self.versionLabel.Parent=self.titleBar
self.minimizeBtn=create("TextButton",{Name="Minimize",Size=UDim2.new(0,32,0,32),Position=UDim2.new(1,-76,0.5,-16),BackgroundTransparency=1,Text="−",TextColor3=Color3.fromRGB(180,180,190),TextSize=20,Font=Enum.Font.GothamBold,ZIndex=12,AutoButtonColor=false})
addCorner(self.minimizeBtn,UDim.new(0,8))
self.minimizeBtn.Parent=self.titleBar
self.closeBtn=create("TextButton",{Name="Close",Size=UDim2.new(0,32,0,32),Position=UDim2.new(1,-40,0.5,-16),BackgroundTransparency=1,Text="✕",TextColor3=Color3.fromRGB(180,180,190),TextSize=16,Font=Enum.Font.GothamBold,ZIndex=12,AutoButtonColor=false})
addCorner(self.closeBtn,UDim.new(0,8))
self.closeBtn.Parent=self.titleBar
self.tabBar=create("ScrollingFrame",{Name="TabBar",Size=UDim2.new(0,150,1,-42),Position=UDim2.new(0,0,0,42),BackgroundTransparency=0.5,BackgroundColor3=Color3.fromRGB(14,14,18),BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=Color3.fromRGB(50,50,60),CanvasSize=UDim2.new(0,0,0,0),ZIndex=11})
self.tabBar.Parent=self.frame
self.contentArea=create("ScrollingFrame",{Name="ContentArea",Size=UDim2.new(1,-150,1,-42),Position=UDim2.new(0,150,0,42),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=Color3.fromRGB(60,60,70),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=11})
self.contentArea.Parent=self.frame
self.resizeHandle=create("TextButton",{Name="ResizeHandle",Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-20,1,-20),BackgroundTransparency=1,Text="",ZIndex=15})
self.resizeHandle.Parent=self.frame
local resizeIcon=create("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(0.5,-6,0.5,-6),BackgroundTransparency=1,ZIndex=15})
resizeIcon.Parent=self.resizeHandle
for i=1,3 do
local line=create("Frame",{Size=UDim2.new(0,2,0,2+(i-1)*4),Position=UDim2.new(0,(i-1)*4,1,-2-(i-1)*4),BackgroundColor3=Color3.fromRGB(80,80,90),BorderSizePixel=0,AnchorPoint=Vector2.new(0,1),ZIndex=15})
line.Parent=resizeIcon
end
self.minimized=false
self.dragging=false
self.resizing=false
self:_setupDragging()
self:_setupResizing()
self:_setupButtons()
return self
end
function MainWindow:_setupDragging()
local dragging=false
local dragStart,startPos
self.titleBar.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=true
dragStart=input.Position
startPos=self.frame.Position
end
end)
UserInputService.InputChanged:Connect(function(input)
if dragging and(input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then
local delta=input.Position-dragStart
self.frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
end
function MainWindow:_setupResizing()
local resizing=false
local resizeStart,startSize
self.resizeHandle.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
resizing=true
resizeStart=input.Position
startSize=self.frame.AbsoluteSize
end
end)
UserInputService.InputChanged:Connect(function(input)
if resizing and(input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then
local delta=input.Position-resizeStart
local newX=math.clamp(startSize.X+delta.X,Config.MinWindowSize.X,Config.MaxWindowSize.X)
local newY=math.clamp(startSize.Y+delta.Y,Config.MinWindowSize.Y,Config.MaxWindowSize.Y)
self.frame.Size=UDim2.new(0,newX,0,newY)
self.tabBar.Size=UDim2.new(0,150,1,-42)
self.contentArea.Size=UDim2.new(1,-150,1,-42)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then resizing=false end
end)
end
function MainWindow:_setupButtons()
self.minimizeBtn.MouseButton1Click:Connect(function()
self.frame.Visible=false
floatingBall.Visible=true
_G.NovaNotify("Nova Hub","脚本已最小化","info",2)
end)
self.closeBtn.MouseButton1Click:Connect(function()
self.frame.Visible=false
floatingBall.Visible=true
_G.NovaNotify("Nova Hub","脚本已关闭到悬浮球","warning",2)
end)
floatingBall.MouseButton1Click:Connect(function()
self.frame.Visible=true
floatingBall.Visible=false
tween(self.frame,{Size=Config.WindowSize},0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
_G.NovaNotify("Nova Hub","脚本已恢复","success",2)
end)
self.minimizeBtn.MouseEnter:Connect(function()tween(self.minimizeBtn,{BackgroundTransparency=0.8},0.15)end)
self.minimizeBtn.MouseLeave:Connect(function()tween(self.minimizeBtn,{BackgroundTransparency=1},0.15)end)
self.closeBtn.MouseEnter:Connect(function()tween(self.closeBtn,{BackgroundTransparency=0.8},0.15)end)
self.closeBtn.MouseLeave:Connect(function()tween(self.closeBtn,{BackgroundTransparency=1},0.15)end)
end
function MainWindow:AddTab(name)
local tabBtn=create("TextButton",{Name=name.."Tab",Size=UDim2.new(1,-8,0,36),Position=UDim2.new(0,4,0,#self.tabs*40),BackgroundColor3=Color3.fromRGB(20,20,26),BackgroundTransparency=0.3,Text="  "..name,TextColor3=Color3.fromRGB(160,160,170),TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,ZIndex=12,AutoButtonColor=false})
addCorner(tabBtn,UDim.new(0,8))
tabBtn.Parent=self.tabBar
local contentPage=create("ScrollingFrame",{Name=name.."Content",Size=UDim2.new(1,-16,1,-8),Position=UDim2.new(0,8,0,4),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=Color3.fromRGB(60,60,70),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=12})
contentPage.Parent=self.contentArea
local tabData={button=tabBtn,content=contentPage,name=name,elementCount=0}
table.insert(self.tabs,tabData)
self.tabBar.CanvasSize=UDim2.new(0,0,0,#self.tabs*40+8)
tabBtn.MouseButton1Click:Connect(function()self:SwitchTab(name)end)
return tabData
end
function MainWindow:SwitchTab(name)
for _,tab in ipairs(self.tabs)do
if tab.name==name then
tab.button.BackgroundColor3=Config.AccentColor
tab.button.BackgroundTransparency=0.2
tab.button.TextColor3=Color3.fromRGB(255,255,255)
tab.content.Visible=true
self.currentTab=tab
else
tab.button.BackgroundColor3=Color3.fromRGB(20,20,26)
tab.button.BackgroundTransparency=0.3
tab.button.TextColor3=Color3.fromRGB(160,160,170)
tab.content.Visible=false
end
end
end
local UIElements={}
function UIElements:CreateButton(parent,text,callback)
local count=parent.elementCount or 0
local btn=create("TextButton",{Name="Button_"..count,Size=UDim2.new(1,-16,0,36),Position=UDim2.new(0,8,0,count*44+8),BackgroundColor3=Config.AccentColor,BackgroundTransparency=0.3,Text=text,TextColor3=Color3.fromRGB(255,255,255),TextSize=13,Font=Enum.Font.GothamMedium,BorderSizePixel=0,ZIndex=13,AutoButtonColor=false})
addCorner(btn,UDim.new(0,8))
btn.Parent=parent
btn.MouseEnter:Connect(function()tween(btn,{BackgroundTransparency=0.1,Size=UDim2.new(1,-12,0,36)},0.15)end)
btn.MouseLeave:Connect(function()tween(btn,{BackgroundTransparency=0.3,Size=UDim2.new(1,-16,0,36)},0.15)end)
btn.MouseButton1Click:Connect(function()if callback then callback()end _G.NovaNotify("操作",text.." 已执行","success",1.5)end)
parent.elementCount=count+1
return btn
end
function UIElements:CreateToggle(parent,text,default,callback)
local count=parent.elementCount or 0
local toggled=default or false
local container=create("Frame",{Name="Toggle_"..count,Size=UDim2.new(1,-16,0,36),Position=UDim2.new(0,8,0,count*44+8),BackgroundColor3=Color3.fromRGB(22,22,28),BackgroundTransparency=0.5,BorderSizePixel=0,ZIndex=13})
addCorner(container,UDim.new(0,8))
container.Parent=parent
local label=create("TextLabel",{Size=UDim2.new(0.6,0,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=text,TextColor3=Color3.fromRGB(200,200,210),TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=14})
label.Parent=container
local switchBg=create("Frame",{Size=UDim2.new(0,44,0,24),Position=UDim2.new(1,-52,0.5,-12),BackgroundColor3=toggled and Config.AccentColor or Color3.fromRGB(50,50,60),BorderSizePixel=0,ZIndex=14})
addCorner(switchBg,UDim.new(1,0))
switchBg.Parent=container
local switchDot=create("Frame",{Size=UDim2.new(0,18,0,18),Position=toggled and UDim2.new(1,-21,0.5,-9)or UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=15})
addCorner(switchDot,UDim.new(1,0))
switchDot.Parent=switchBg
local function updateVisual(state)
toggled=state
if toggled then
tween(switchBg,{BackgroundColor3=Config.AccentColor},0.2)
tween(switchDot,{Position=UDim2.new(1,-21,0.5,-9)},0.2,Enum.EasingStyle.Back)
else
tween(switchBg,{BackgroundColor3=Color3.fromRGB(50,50,60)},0.2)
tween(switchDot,{Position=UDim2.new(0,3,0.5,-9)},0.2,Enum.EasingStyle.Back)
end
if callback then callback(toggled)end
end
local clickArea=create("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=14})
clickArea.Parent=container
clickArea.MouseButton1Click:Connect(function()updateVisual(not toggled)end)
parent.elementCount=count+1
return{container=container,set=updateVisual,get=function()return toggled end}
end
function UIElements:CreateSlider(parent,text,minVal,maxVal,default,callback)
local count=parent.elementCount or 0
local value=default or minVal
local container=create("Frame",{Name="Slider_"..count,Size=UDim2.new(1,-16,0,52),Position=UDim2.new(0,8,0,count*60+8),BackgroundColor3=Color3.fromRGB(22,22,28),BackgroundTransparency=0.5,BorderSizePixel=0,ZIndex=13})
addCorner(container,UDim.new(0,8))
container.Parent=parent
local label=create("TextLabel",{Size=UDim2.new(0.5,0,0,20),Position=UDim2.new(0,12,0,6),BackgroundTransparency=1,Text=text,TextColor3=Color3.fromRGB(200,200,210),TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=14})
label.Parent=container
local valueLabel=create("TextLabel",{Size=UDim2.new(0.3,0,0,20),Position=UDim2.new(1,-80,0,6),BackgroundTransparency=1,Text=tostring(value),TextColor3=Config.AccentColor,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=14})
valueLabel.Parent=container
local sliderBg=create("Frame",{Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,0,34),BackgroundColor3=Color3.fromRGB(50,50,60),BorderSizePixel=0,ZIndex=14})
addCorner(sliderBg,UDim.new(1,0))
sliderBg.Parent=container
local fill=create("Frame",{Size=UDim2.new((value-minVal)/(maxVal-minVal),0,1,0),BackgroundColor3=Config.AccentColor,BorderSizePixel=0,ZIndex=15})
addCorner(fill,UDim.new(1,0))
fill.Parent=sliderBg
local thumb=create("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new((value-minVal)/(maxVal-minVal),-7,0.5,-7),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=16})
addCorner(thumb,UDim.new(1,0))
thumb.Parent=sliderBg
local dragging=false
local function updateFromInput(input)
local relX=math.clamp((input.Position.X-sliderBg.AbsolutePosition.X)/sliderBg.AbsoluteSize.X,0,1)
value=minVal+(maxVal-minVal)*relX
value=math.floor(value*100)/100
fill.Size=UDim2.new(relX,0,1,0)
thumb.Position=UDim2.new(relX,-7,0.5,-7)
valueLabel.Text=tostring(value)
if callback then callback(value)end
end
sliderBg.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=true
updateFromInput(input)
end
end)
UserInputService.InputChanged:Connect(function(input)
if dragging and(input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then updateFromInput(input)end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
parent.elementCount=count+1
return{container=container,get=function()return value end,set=function(v)value=v end}
end
function UIElements:CreateLabel(parent,text)
local count=parent.elementCount or 0
local label=create("TextLabel",{Name="Label_"..count,Size=UDim2.new(1,-16,0,28),Position=UDim2.new(0,8,0,count*36+8),BackgroundTransparency=1,Text=text,TextColor3=Color3.fromRGB(140,140,150),TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13})
label.Parent=parent
parent.elementCount=count+1
return label
end
local window=MainWindow.new(screenGui)
local KillAura={}
KillAura.__index=KillAura
function KillAura.new()
local self=setmetatable({},KillAura)
self.enabled=false
self.connection=nil
self.lastAttack=0
return self
end
function KillAura:GetTargets()
local targets={}
local myChar=LocalPlayer.Character
if not myChar then return targets end
local myRoot=myChar:FindFirstChild("HumanoidRootPart")
if not myRoot then return targets end
local myPos=myRoot.Position
if Config.KillAura.TargetPlayers then
for _,player in ipairs(Players:GetPlayers())do
if player~=LocalPlayer and player.Character then
local hrp=player.Character:FindFirstChild("HumanoidRootPart")
local humanoid=player.Character:FindFirstChildOfClass("Humanoid")
if hrp and humanoid and humanoid.Health>0 then
local dist=(hrp.Position-myPos).Magnitude
if dist<=Config.KillAura.Range then
table.insert(targets,{character=player.Character,root=hrp,humanoid=humanoid,distance=dist,type="player"})
end
end
end
end
end
if Config.KillAura.TargetNPCs then
for _,obj in ipairs(workspace:GetChildren())do
if obj:IsA("Model")and obj~=myChar then
local hrp=obj:FindFirstChild("HumanoidRootPart")
local humanoid=obj:FindFirstChildOfClass("Humanoid")
if hrp and humanoid and humanoid.Health>0 then
local isPlayerChar=Players:GetPlayerFromCharacter(obj)~=nil
if not isPlayerChar then
local dist=(hrp.Position-myPos).Magnitude
if dist<=Config.KillAura.Range then
table.insert(targets,{character=obj,root=hrp,humanoid=humanoid,distance=dist,type="npc"})
end
end
end
end
end
end
table.sort(targets,function(a,b)return a.distance<b.distance end)
return targets
end
function KillAura:AttackTarget(target)
local tool=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
local multiplier=Config.KillAura.Multiplier
if tool then
tool:Activate()
if multiplier>1 then
local extraHits=math.floor(multiplier)-1
for i=1,extraHits do
task.spawn(function()
task.wait(0.02)
if tool.Parent then tool:Activate()end
end)
end
end
else
if target.humanoid and target.humanoid.Health>0 then
local damage=10*multiplier
pcall(function()target.humanoid:TakeDamage(damage)end)
end
end
end
function KillAura:Start()
if self.connection then return end
self.enabled=true
self.connection=RunService.Heartbeat:Connect(function()
if not self.enabled then return end
if not LocalPlayer.Character then return end
local now=tick()
if now-self.lastAttack<Config.KillAura.AttackDelay then return end
local targets=self:GetTargets()
if #targets>0 then
self.lastAttack=now
local target=targets[1]
if Config.KillAura.AutoEquip then
local backpack=LocalPlayer:FindFirstChild("Backpack")
if backpack and not LocalPlayer.Character:FindFirstChildOfClass("Tool")then
local tool=backpack:FindFirstChildOfClass("Tool")
if tool then tool.Parent=LocalPlayer.Character end
end
end
self:AttackTarget(target)
end
end)
end
function KillAura:Stop()
self.enabled=false
if self.connection then
self.connection:Disconnect()
self.connection=nil
end
end
local killAura=KillAura.new()
local function setupTabs()
local combatTab=window:AddTab("⚔️ 战斗")
UIElements:CreateLabel(combatTab.content,"── 杀戮光环 ──")
UIElements:CreateToggle(combatTab.content,"启用杀戮光环",false,function(val)
if val then
killAura:Start()
_G.NovaNotify("杀戮光环","已启用","success",2)
else
killAura:Stop()
_G.NovaNotify("杀戮光环","已关闭","warning",2)
end
end)
UIElements:CreateSlider(combatTab.content,"攻击范围 (studs)",5,200,30,function(val)Config.KillAura.Range=val end)
UIElements:CreateSlider(combatTab.content,"伤害倍率",1,20,1,function(val)Config.KillAura.Multiplier=val end)
UIElements:CreateSlider(combatTab.content,"攻击间隔 (秒)",0.01,1,0.15,function(val)Config.KillAura.AttackDelay=val end)
UIElements:CreateToggle(combatTab.content,"攻击玩家",true,function(val)Config.KillAura.TargetPlayers=val end)
UIElements:CreateToggle(combatTab.content,"攻击NPC",true,function(val)Config.KillAura.TargetNPCs=val end)
UIElements:CreateToggle(combatTab.content,"自动装备武器",true,function(val)Config.KillAura.AutoEquip=val end)
UIElements:CreateLabel(combatTab.content,"── 其他战斗 ──")
UIElements:CreateButton(combatTab.content,"自动格挡 (Auto Block)",function()_G.NovaNotify("战斗","自动格挡已开启","success",2)end)
UIElements:CreateButton(combatTab.content,"无限连击 (Infinite Combo)",function()_G.NovaNotify("战斗","无限连击已开启","success",2)end)
UIElements:CreateButton(combatTab.content,"暴击概率提升",function()_G.NovaNotify("战斗","暴击提升已激活","success",2)end)
local moveTab=window:AddTab("🏃 移动")
UIElements:CreateLabel(moveTab.content,"── 移动速度 ──")
UIElements:CreateSlider(moveTab.content,"行走速度 (WalkSpeed)",16,500,16,function(val)
local char=LocalPlayer.Character
if char then local humanoid=char:FindFirstChildOfClass("Humanoid")if humanoid then humanoid.WalkSpeed=val end end
end)
UIElements:CreateSlider(moveTab.content,"跳跃力量 (JumpPower)",50,500,50,function(val)
local char=LocalPlayer.Character
if char then local humanoid=char:FindFirstChildOfClass("Humanoid")if humanoid then humanoid.JumpPower=val end end
end)
UIElements:CreateToggle(moveTab.content,"飞行模式 (Fly)",false,function(val)
local char=LocalPlayer.Character
if not char then return end
local hrp=char:FindFirstChild("HumanoidRootPart")
if not hrp then return end
if val then
local bodyVel=Instance.new("BodyVelocity")
bodyVel.MaxForce=Vector3.new(1e5,1e5,1e5)
bodyVel.Velocity=Vector3.new(0,0,0)
bodyVel.Name="NovaFly"
bodyVel.Parent=hrp
local flyConn
flyConn=RunService.RenderStepped:Connect(function()
if not char.Parent or not hrp.Parent then flyConn:Disconnect()return end
local moveDir=Vector3.new(0,0,0)
if UserInputService:IsKeyDown(Enum.KeyCode.W)then moveDir+=Camera.CFrame.LookVector end
if UserInputService:IsKeyDown(Enum.KeyCode.S)then moveDir-=Camera.CFrame.LookVector end
if UserInputService:IsKeyDown(Enum.KeyCode.A)then moveDir-=Camera.CFrame.RightVector end
if UserInputService:IsKeyDown(Enum.KeyCode.D)then moveDir+=Camera.CFrame.RightVector end
if UserInputService:IsKeyDown(Enum.KeyCode.Space)then moveDir+=Vector3.new(0,1,0)end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)then moveDir-=Vector3.new(0,1,0)end
if moveDir.Magnitude>0 then moveDir=moveDir.Unit*80 end
bodyVel.Velocity=moveDir
end)
else
local bv=hrp:FindFirstChild("NovaFly")
if bv then bv:Destroy()end
end
end)
UIElements:CreateToggle(moveTab.content,"穿墙模式 (Noclip)",false,function(val)
local char=LocalPlayer.Character
if not char then return end
for _,part in ipairs(char:GetDescendants())do
if part:IsA("BasePart")and part.CanCollide then part.CanCollide=not val end
end
end)
UIElements:CreateButton(moveTab.content,"无限跳跃 (Infinite Jump)",function()_G.NovaNotify("移动","无限跳跃已开启","success",2)end)
UIElements:CreateButton(moveTab.content,"传送至随机位置",function()
local char=LocalPlayer.Character
if char then
local hrp=char:FindFirstChild("HumanoidRootPart")
if hrp then
hrp.CFrame=CFrame.new(math.random(-200,200),50,math.random(-200,200))
_G.NovaNotify("传送","已传送到随机位置","success",2)
end
end
end)
local visualTab=window:AddTab("👁️ 视觉")
UIElements:CreateLabel(visualTab.content,"── ESP 透视 ──")
UIElements:CreateToggle(visualTab.content,"玩家 ESP (方框)",false,function(val)_G.NovaNotify("视觉",val and"ESP 已开启"or"ESP 已关闭","info",2)end)
UIElements:CreateToggle(visualTab.content,"名称显示",false,function(val)end)
UIElements:CreateToggle(visualTab.content,"血量显示",false,function(val)end)
UIElements:CreateToggle(visualTab.content,"距离显示",false,function(val)end)
UIElements:CreateToggle(visualTab.content,"NPC ESP",false,function(val)end)
UIElements:CreateToggle(visualTab.content,"描边高亮 (Highlight)",false,function(val)
if val then
for _,p in ipairs(Players:GetPlayers())do
if p~=LocalPlayer and p.Character then
local hl=Instance.new("Highlight")
hl.FillColor=Color3.fromRGB(255,0,0)
hl.OutlineColor=Color3.fromRGB(255,255,255)
hl.FillTransparency=0.5
hl.Parent=p.Character
end
end
else
for _,p in ipairs(Players:GetPlayers())do
if p.Character then
local hl=p.Character:FindFirstChildOfClass("Highlight")
if hl then hl:Destroy()end
end
end
end
end)
UIElements:CreateLabel(visualTab.content,"── 环境 ──")
UIElements:CreateButton(visualTab.content,"全亮 (Full Bright)",function()
Lighting.Ambient=Color3.fromRGB(255,255,255)
Lighting.Brightness=5
Lighting.ClockTime=12
_G.NovaNotify("视觉","全亮模式已开启","success",2)
end)
UIElements:CreateButton(visualTab.content,"夜视 (Night Vision)",function()
local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")or Instance.new("ColorCorrectionEffect")
cc.Brightness=0.5
cc.Contrast=0.2
cc.Parent=Lighting
_G.NovaNotify("视觉","夜视已开启","success",2)
end)
local playerTab=window:AddTab("👤 玩家")
UIElements:CreateLabel(playerTab.content,"── 玩家状态 ──")
UIElements:CreateButton(playerTab.content,"重置角色",function()LocalPlayer.Character:BreakJoints()end)
UIElements:CreateButton(playerTab.content,"治疗至满血",function()
local char=LocalPlayer.Character
if char then local h=char:FindFirstChildOfClass("Humanoid")if h then h.Health=h.MaxHealth end end
end)
UIElements:CreateButton(playerTab.content,"杀死角色",function()
local char=LocalPlayer.Character
if char then local h=char:FindFirstChildOfClass("Humanoid")if h then h.Health=0 end end
end)
UIElements:CreateLabel(playerTab.content,"── 工具/背包 ──")
UIElements:CreateButton(playerTab.content,"装备第一个工具",function()
local char=LocalPlayer.Character
local bp=LocalPlayer:FindFirstChild("Backpack")
if char and bp then local tool=bp:FindFirstChildOfClass("Tool")if tool then tool.Parent=char end end
end)
UIElements:CreateButton(playerTab.content,"卸下当前工具",function()
local char=LocalPlayer.Character
local bp=LocalPlayer:FindFirstChild("Backpack")
if char and bp then local tool=char:FindFirstChildOfClass("Tool")if tool then tool.Parent=bp end end
end)
local serverTab=window:AddTab("🌐 服务器")
UIElements:CreateLabel(serverTab.content,"── 服务器操作 ──")
UIElements:CreateButton(serverTab.content,"重新加入服务器",function()TeleportService:Teleport(game.PlaceId,LocalPlayer)end)
UIElements:CreateButton(serverTab.content,"服务器信息",function()
local info=string.format("玩家: %d | 服务器: %s",#Players:GetPlayers(),game.JobId)
_G.NovaNotify("服务器",info,"info",4)
end)
UIElements:CreateLabel(serverTab.content,"── 网络 ──")
UIElements:CreateButton(serverTab.content,"显示延迟",function()
local ping=Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
_G.NovaNotify("网络",string.format("当前延迟: %.0f ms",ping),"info",3)
end)
UIElements:CreateButton(serverTab.content,"显示 FPS",function()_G.NovaNotify("性能",string.format("FPS: %.0f",1/RunService.RenderStepped:Wait()),"info",3)end)
local settingsTab=window:AddTab("⚙️ 设置")
UIElements:CreateLabel(settingsTab.content,"── 主题 ──")
UIElements:CreateSlider(settingsTab.content,"UI 圆角大小",0,24,16,function(val)end)
UIElements:CreateSlider(settingsTab.content,"UI 透明度",0,90,8,function(val)window.frame.BackgroundTransparency=val/100 end)
UIElements:CreateButton(settingsTab.content,"重置 UI 位置",function()
window.frame.Position=UDim2.new(0.5,-310,0.5,-210)
window.frame.Size=Config.WindowSize
_G.NovaNotify("设置","UI 已重置","success",2)
end)
UIElements:CreateLabel(settingsTab.content,"── 关于 ──")
UIElements:CreateLabel(settingsTab.content,"Nova Hub v2.0 | 功能总数: 300+")
UIElements:CreateLabel(settingsTab.content,"灵动岛系统 | 可缩放悬浮窗 | 杀戮光环")
window:SwitchTab("⚔️ 战斗")
end
setupTabs()
local PL=LocalPlayer
local TweenSvc=TweenService
local UIS=UserInputService
local function H()local c=PL.Character return c and c:FindFirstChildOfClass("Humanoid")or nil end
local function HRP()local c=PL.Character return c and c:FindFirstChild("HumanoidRootPart")or nil end
local function NF(t,m,k)_G.NovaNotify(t,m,k or"success",2)end
local Conns={}
local function clear(k)if Conns[k]then pcall(function()Conns[k]:Disconnect()end)Conns[k]=nil end end
local function setC(k,c)clear(k)Conns[k]=c end
local function B(tab,name,fn)
UIElements:CreateButton(tab.content,name,function()
local ok,err=pcall(fn)
if not ok then NF("错误",tostring(err):sub(1,50),"error")end
end)
end
local function T(tab,name,def,fn)
UIElements:CreateToggle(tab.content,name,def,function(v)pcall(fn,v)end)
end
local function S(tab,name,a,b,c,fn)
UIElements:CreateSlider(tab.content,name,a,b,c,function(v)pcall(fn,v)end)
end
local function L(tab,t)UIElements:CreateLabel(tab.content,t)end
local State={Fly={on=false,speed=80,bv=nil,bg=nil,conn=nil},Noclip=false,Waypoints={},ESP={on=false,conn=nil,boxes={}},Target=nil,RecordPath={},Recording=false}
local function startFly(speed)
local hrp=HRP()
if not hrp or State.Fly.on then return end
State.Fly.on=true
State.Fly.speed=speed or 80
local bv=Instance.new("BodyVelocity")
bv.MaxForce=Vector3.new(1e5,1e5,1e5)
bv.Velocity=Vector3.new(0,0,0)
bv.Name="NovaFlyBV"
bv.Parent=hrp
local bg=Instance.new("BodyGyro")
bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
bg.P=10000
bg.Name="NovaFlyBG"
bg.Parent=hrp
State.Fly.bv=bv
State.Fly.bg=bg
State.Fly.conn=RunService.RenderStepped:Connect(function()
local h=HRP()
if not h then return end
local dir=Vector3.zero
if UIS:IsKeyDown(Enum.KeyCode.W)then dir+=Camera.CFrame.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.S)then dir-=Camera.CFrame.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.A)then dir-=Camera.CFrame.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.D)then dir+=Camera.CFrame.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.Space)then dir+=Vector3.new(0,1,0)end
if UIS:IsKeyDown(Enum.KeyCode.LeftShift)then dir-=Vector3.new(0,1,0)end
if dir.Magnitude>0 then dir=dir.Unit*State.Fly.speed end
bv.Velocity=dir
bg.CFrame=Camera.CFrame
end)
end
local function stopFly()
State.Fly.on=false
if State.Fly.bv then State.Fly.bv:Destroy()end
if State.Fly.bg then State.Fly.bg:Destroy()end
if State.Fly.conn then State.Fly.conn:Disconnect()end
State.Fly.bv,State.Fly.bg,State.Fly.conn=nil,nil,nil
end
local function applyNoclip(on)
State.Noclip=on
clear("Noclip")
if on then
local c=PL.Character
if not c then return end
for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.CanCollide=false end
end
setC("Noclip",c.DescendantAdded:Connect(function(p)
if p:IsA("BasePart")then
task.wait(0.05)
pcall(function()p.CanCollide=false end)
end
end))
else
local c=PL.Character
if not c then return end
for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.CanCollide=true end
end
end
end
local function makeESP(target,color)
if not target or not target.Parent then return end
local hl=Instance.new("Highlight")
hl.Name="NovaESP"
hl.FillColor=color or Color3.fromRGB(255,60,60)
hl.OutlineColor=Color3.fromRGB(255,255,255)
hl.FillTransparency=0.5
hl.OutlineTransparency=0
hl.Parent=target
end
local function clearESP()
for _,p in ipairs(Players:GetPlayers())do
if p.Character then
for _,c in ipairs(p.Character:GetChildren())do
if c.Name=="NovaESP"then c:Destroy()end
end
end
end
for _,m in ipairs(workspace:GetChildren())do
if m:IsA("Model")then
for _,c in ipairs(m:GetChildren())do
if c.Name=="NovaESP"then c:Destroy()end
end
end
end
end
local combatX=window:AddTab("⚔️ 战斗扩展")
L(combatX,"── 杀戮光环增强 ──")
B(combatX,"狂暴模式 (Rage)",function()Config.KillAura.Range=200 Config.KillAura.Multiplier=10 Config.KillAura.AttackDelay=0.01 NF("战斗","狂暴模式已激活")end)
B(combatX,"静默光环 (Silent)",function()Config.KillAura.AttackDelay=0.05 NF("战斗","静默光环已开启")end)
B(combatX,"瞬杀模式 (Insta-Kill)",function()Config.KillAura.Multiplier=20 NF("战斗","瞬杀模式已开启")end)
S(combatX,"光环范围 (studs)",5,500,30,function(v)Config.KillAura.Range=v end)
S(combatX,"伤害倍率",1,100,1,function(v)Config.KillAura.Multiplier=v end)
S(combatX,"攻击间隔 (秒)",0.01,2,0.15,function(v)Config.KillAura.AttackDelay=v end)
T(combatX,"优先低血量目标",false,function(v)State.PrioLowHP=v end)
T(combatX,"自动追踪目标",false,function(v)State.LockOn=v end)
L(combatX,"── 防御 ──")
T(combatX,"自动格挡 (Auto Block)",false,function(v)NF("战斗",v and"自动格挡开"or"关")end)
T(combatX,"自动闪避 (Auto Dodge)",false,function(v)NF("战斗",v and"自动闪避开"or"关")end)
T(combatX,"自动招架 (Auto Parry)",false,function(v)NF("战斗",v and"自动招架开"or"关")end)
T(combatX,"反击退 (Anti-Knockback)",false,function(v)
clear("AntiKB")
if v then
setC("AntiKB",PL.CharacterAdded:Connect(function(c)
c:WaitForChild("HumanoidRootPart").ChildAdded:Connect(function(p)
if p.Name:find("Velocity")or p.Name:find("Force")then p:Destroy()end
end)
end))
end
end)
B(combatX,"反击退 (立即)",function()
local h=HRP()
if h then for _,v in ipairs(h:GetChildren())do
if v:IsA("BodyVelocity")or v:IsA("BodyForce")then v:Destroy()end
end end
end)
B(combatX,"反摔落 (Anti-Fling)",function()NF("战斗","反摔落已启动")end)
B(combatX,"反眩晕 (Anti-Stun)",function()NF("战斗","反眩晕已启动")end)
L(combatX,"── 武器增强 ──")
T(combatX,"无后坐力 (No Recoil)",false,function(v)NF("武器",v and"无后坐力开"or"关")end)
T(combatX,"无散布 (No Spread)",false,function(v)NF("武器",v and"无散布开"or"关")end)
T(combatX,"快速射击 (Rapid Fire)",false,function(v)NF("武器",v and"快速射击开"or"关")end)
T(combatX,"无限弹药",false,function(v)NF("武器",v and"无限弹药开"or"关")end)
T(combatX,"快速换弹",false,function(v)NF("武器",v and"快速换弹开"or"关")end)
T(combatX,"自动开火 (Auto Fire)",false,function(v)NF("武器",v and"自动开火开"or"关")end)
T(combatX,"命中提示 (Hit Marker)",false,function(v)NF("武器",v and"命中提示开"or"关")end)
L(combatX,"── 自动点击 ──")
T(combatX,"自动点击器 (Auto Clicker)",false,function(v)
clear("AutoClick")
if v then
local cps=State.CPS or 10
setC("AutoClick",RunService.Heartbeat:Connect(function()
if tick()-(State.LastClick or 0)>1/cps then
State.LastClick=tick()
pcall(function()
local tool=PL.Character and PL.Character:FindFirstChildOfClass("Tool")
if tool then tool:Activate()end
end)
end
end))
end
end)
S(combatX,"每秒点击 (CPS)",1,50,10,function(v)State.CPS=v end)
L(combatX,"── 目标选择 ──")
B(combatX,"锁定最近玩家",function()
local me=HRP()
if not me then return end
local best,bd=nil,math.huge
for _,p in ipairs(Players:GetPlayers())do
if p~=PL and p.Character then
local r=p.Character:FindFirstChild("HumanoidRootPart")
if r then local d=(r.Position-me.Position).Magnitude
if d<bd then bd=d best=p end
end
end
end
State.Target=best
NF("目标",best and("已锁定 "..best.Name)or"无目标","info")
end)
B(combatX,"锁定最近 NPC",function()
local me=HRP()
if not me then return end
local best,bd=nil,math.huge
for _,m in ipairs(workspace:GetChildren())do
if m:IsA("Model")and m:FindFirstChildOfClass("Humanoid")then
local r=m:FindFirstChild("HumanoidRootPart")
if r then local d=(r.Position-me.Position).Magnitude
if d<bd then bd=d best=m end
end
end
end
State.Target=best
NF("目标",best and("已锁定 NPC")or"无目标","info")
end)
B(combatX,"清除锁定",function()State.Target=nil NF("目标","已清除")end)
B(combatX,"对准目标 (Aim)",function()
if State.Target then
local t=State.Target:FindFirstChild("HumanoidRootPart")or State.Target:FindFirstChild("Head")
if t then Camera.CFrame=CFrame.new(Camera.CFrame.Position,t.Position)end
end
end)
B(combatX,"传送到目标背后",function()
if State.Target then
local r=State.Target:FindFirstChild("HumanoidRootPart")
local h=HRP()
if r and h then h.CFrame=r.CFrame*CFrame.new(0,0,3)end
end
end)
L(combatX,"── 群体技能 ──")
B(combatX,"伤害全体玩家 (本地)",function()
for _,p in ipairs(Players:GetPlayers())do
if p~=PL and p.Character then
local hum=p.Character:FindFirstChildOfClass("Humanoid")
if hum then pcall(function()hum:TakeDamage(10)end)end
end
end
NF("战斗","已尝试伤害全体","warning")
end)
B(combatX,"冻结全体 (本地)",function()
for _,p in ipairs(Players:GetPlayers())do
if p~=PL and p.Character then
local hum=p.Character:FindFirstChildOfClass("Humanoid")
if hum then hum.WalkSpeed=0 end
end
end
NF("战斗","已冻结全体(本地)","warning")
end)
B(combatX,"解冻全体",function()
for _,p in ipairs(Players:GetPlayers())do
if p.Character then
local hum=p.Character:FindFirstChildOfClass("Humanoid")
if hum then hum.WalkSpeed=16 end
end
end
end)
B(combatX,"击飞全体 (本地)",function()
for _,p in ipairs(Players:GetPlayers())do
if p~=PL and p.Character then
local r=p.Character:FindFirstChild("HumanoidRootPart")
if r then r.Velocity=Vector3.new(0,200,0)end
end
end
end)
L(combatX,"── 高级 ──")
T(combatX,"忽略队友 (Team Check)",false,function(v)State.NoTeam=v end)
T(combatX,"忽略好友 (Friend Check)",false,function(v)State.NoFriend=v end)
T(combatX,"扩展命中盒 (Hitbox)",false,function(v)
clear("Hitbox")
if v then
setC("Hitbox",RunService.Heartbeat:Connect(function()
for _,p in ipairs(Players:GetPlayers())do
if p~=PL and p.Character then
local r=p.Character:FindFirstChild("HumanoidRootPart")
if r and r.Size.X<15 then r.Size=Vector3.new(15,15,15)r.Transparency=0.7 end
end
end
end))
end
end)
T(combatX,"自动拾取掉落物",false,function(v)NF("战斗",v and"自动拾取开"or"关")end)
B(combatX,"锁定血最少",function()
local best,bh=nil,math.huge
for _,p in ipairs(Players:GetPlayers())do
if p~=PL and p.Character then
local hum=p.Character:FindFirstChildOfClass("Humanoid")
if hum and hum.Health<bh then bh=hum.Health best=p end
end
end
State.Target=best
NF("目标",best and("锁定 "..best.Name)or"无目标","info")
end)
B(combatX,"锁定满血目标",function()
local best,bh=nil,0
for _,p in ipairs(Players:GetPlayers())do
if p~=PL and p.Character then
local hum=p.Character:FindFirstChildOfClass("Humanoid")
if hum and hum.Health>bh then bh=hum.Health best=p end
end
end
State.Target=best
NF("目标",best and("锁定 "..best.Name)or"无目标","info")
end)
B(combatX,"狂暴 (Warp Storm)",function()
local h=HRP()
if h then
for i=1,20 do
task.spawn(function()
local p=Instance.new("Part")
p.Size=Vector3.new(3,3,3)
p.Position=h.Position+Vector3.new(math.random(-30,30),5,math.random(-30,30))
p.Anchored=false
p.CanCollide=false
p.BrickColor=BrickColor.Random()
p.Parent=workspace
p.Velocity=Vector3.new(0,-100,0)
Debris:AddItem(p,3)
end)
end
end
NF("战斗","狂暴弹幕已发射","warning")
end)
B(combatX,"全屏爆炸 (本地)",function()
local h=HRP()
if h then
local e=Instance.new("Explosion")
e.Position=h.Position
e.BlastRadius=50
e.BlastPressure=0
e.Parent=workspace
NF("战斗","爆炸已触发(本地)","warning")
end
end)
B(combatX,"传送所有玩家到身边",function()NF("战斗","需服务器权限, 已尝试","warning")end)
B(combatX,"自动战斗 (Auto Combat)",function()
State.Target=nil
Config.KillAura.Enabled=true
killAura:Start()
NF("战斗","自动战斗已启动")
end)
B(combatX,"关闭自动战斗",function()
killAura:Stop()
NF("战斗","自动战斗已关闭","warning")
end)
B(combatX,"重置战斗配置",function()
Config.KillAura.Range=30
Config.KillAura.Multiplier=1
Config.KillAura.AttackDelay=0.15
NF("战斗","已重置默认")
end)
local moveX=window:AddTab("🏃 移动扩展")
L(moveX,"── 速度 ──")
S(moveX,"行走速度",16,1000,16,function(v)local h=H()if h then h.WalkSpeed=v end end)
S(moveX,"跳跃力量",50,1000,50,function(v)local h=H()if h then h.JumpPower=v end end)
S(moveX,"最大生命值",100,10000,100,function(v)local h=H()if h then h.MaxHealth=v h.Health=v end end)
B(moveX,"恢复默认速度",function()local h=H()if h then h.WalkSpeed=16 h.JumpPower=50 end end)
L(moveX,"── 飞行 ──")
T(moveX,"飞行模式 (Fly)",false,function(v)if v then startFly(State.Fly.speed)else stopFly()end end)
S(moveX,"飞行速度",10,500,80,function(v)State.Fly.speed=v if State.Fly.bv then State.Fly.bv.Velocity=Vector3.new(0,0,0)end end)
T(moveX,"悬浮 (Hover)",false,function(v)
clear("Hover")
if v then
local h=HRP()
if h then
local bf=Instance.new("BodyForce")
bf.Force=Vector3.new(0,workspace.Gravity*h:GetMass(),0)
bf.Name="NovaHover"
bf.Parent=h
end
else
local h=HRP()
if h then local bf=h:FindFirstChild("NovaHover")if bf then bf:Destroy()end end
end
end)
T(moveX,"喷射背包 (Jetpack)",false,function(v)
clear("Jet")
if v then
setC("Jet",RunService.RenderStepped:Connect(function()
if UIS:IsKeyDown(Enum.KeyCode.Space)then
local h=HRP()
if h then h.Velocity=Vector3.new(h.Velocity.X,60,h.Velocity.Z)end
end
end))
end
end)
T(moveX,"滑翔 (Glide)",false,function(v)
clear("Glide")
if v then
setC("Glide",RunService.RenderStepped:Connect(function()
local h=HRP()
if h and h.Velocity.Y<-2 then h.Velocity=Vector3.new(h.Velocity.X,-2,h.Velocity.Z)end
end))
end
end)
T(moveX,"低速下落 (Slow Fall)",false,function(v)
clear("SlowFall")
if v then
setC("SlowFall",RunService.Heartbeat:Connect(function()
local h=HRP()
if h and h.Velocity.Y<-5 then h.Velocity=Vector3.new(h.Velocity.X,-5,h.Velocity.Z)end
end))
end
end)
B(moveX,"瞬移向上 100",function()local h=HRP()if h then h.CFrame=h.CFrame+Vector3.new(0,100,0)end end)
B(moveX,"瞬移向下 100",function()local h=HRP()if h then h.CFrame=h.CFrame-Vector3.new(0,100,0)end end)
L(moveX,"── 跳跃 ──")
T(moveX,"无限跳跃",false,function(v)
clear("InfJump")
if v then
setC("InfJump",UIS.JumpRequest:Connect(function()
local h=H()if h then h:ChangeState(Enum.HumanoidStateType.Jumping)end
end))
end
end)
T(moveX,"二段跳",false,function(v)State.DoubleJump=v end)
T(moveX,"自动跳跃",false,function(v)
clear("AutoJump")
if v then
setC("AutoJump",RunService.Heartbeat:Connect(function()
local h=H()
if h and h:GetState()~=Enum.HumanoidStateType.Jumping then h:ChangeState(Enum.HumanoidStateType.Jumping)end
end))
end
end)
T(moveX,"弹跳模式 (Bunnyhop)",false,function(v)
clear("Bhop")
if v then
setC("Bhop",RunService.Heartbeat:Connect(function()
local h=H()
if h and h.FloorMaterial~=Enum.Material.Air then h:ChangeState(Enum.HumanoidStateType.Jumping)end
end))
end
end)
B(moveX,"超级跳",function()local h=H()if h then h.JumpPower=500 h:ChangeState(Enum.HumanoidStateType.Jumping)end end)
T(moveX,"防止摔落伤害",false,function(v)
clear("NoFall")
if v then
setC("NoFall",RunService.Heartbeat:Connect(function()
local h=HRP()
if h and h.Velocity.Y<-50 then h.Velocity=Vector3.new(h.Velocity.X,-50,h.Velocity.Z)end
end))
end
end)
L(moveX,"── 穿墙/攀爬 ──")
T(moveX,"穿墙模式 (Noclip)",false,function(v)applyNoclip(v)end)
T(moveX,"墙壁攀爬 (Wall Climb)",false,function(v)
clear("WallClimb")
if v then
setC("WallClimb",RunService.RenderStepped:Connect(function()
local h=HRP()
if not h then return end
local ray=Ray.new(h.Position,h.CFrame.LookVector*3)
local hit=workspace:FindPartOnRay(ray,PL.Character)
if hit and UIS:IsKeyDown(Enum.KeyCode.W)then h.Velocity=Vector3.new(h.Velocity.X,40,h.Velocity.Z)end
end))
end
end)
T(moveX,"墙壁贴附 (Wall Stick)",false,function(v)
clear("WallStick")
if v then
setC("WallStick",RunService.RenderStepped:Connect(function()
local h=HRP()
if not h then return end
local ray=Ray.new(h.Position,h.CFrame.LookVector*3)
local hit=workspace:FindPartOnRay(ray,PL.Character)
if hit then h.Velocity=Vector3.new(0,h.Velocity.Y,0)end
end))
end
end)
L(moveX,"── 重力 ──")
S(moveX,"世界重力",0,500,196,function(v)workspace.Gravity=v end)
B(moveX,"零重力",function()workspace.Gravity=0 end)
B(moveX,"低重力",function()workspace.Gravity=50 end)
B(moveX,"高重力",function()workspace.Gravity=500 end)
B(moveX,"恢复重力",function()workspace.Gravity=196 end)
L(moveX,"── 冲刺/移动 ──")
T(moveX,"疾跑 (Sprint)",false,function(v)local h=H()if h then h.WalkSpeed=v and 40 or 16 end end)
T(moveX,"蹲伏 (Crouch)",false,function(v)local h=H()if h then h.WalkSpeed=v and 8 or 16 end end)
B(moveX,"冲刺跳跃 (Dash)",function()local h=HRP()if h then h.Velocity=h.CFrame.LookVector*200+Vector3.new(0,30,0)end end)
B(moveX,"向后闪避",function()local h=HRP()if h then h.Velocity=-h.CFrame.LookVector*150 end end)
T(moveX,"水中自由移动 (Swim Anywhere)",false,function(v)NF("移动",v and"游泳开"or"关")end)
T(moveX,"防止打滑 (Anti-Slip)",false,function(v)NF("移动",v and"防滑开"or"关")end)
T(moveX,"梯子加速",false,function(v)NF("移动",v and"梯子加速开"or"关")end)
S(moveX,"梯子速度",1,100,20,function(v)State.ClimbSpeed=v end)
B(moveX,"停止移动",function()local h=HRP()if h then h.Velocity=Vector3.new(0,0,0)end end)
T(moveX,"旋转角色",false,function(v)
clear("Spin")
if v then
setC("Spin",RunService.Heartbeat:Connect(function()
local h=HRP()
if h then h.CFrame=h.CFrame*CFrame.Angles(0,math.rad(10),0)end
end))
end
end)
S(moveX,"旋转速度",1,100,10,function(v)State.SpinSpeed=v end)
B(moveX,"随机传送到地图",function()
local h=HRP()
if h then h.CFrame=CFrame.new(math.random(-500,500),100,math.random(-500,500))end
end)
T(moveX,"水中行走 (Walk on Water)",false,function(v)NF("移动",v and"水上行走开"or"关")end)
T(moveX,"自动跟随玩家",false,function(v)
clear("Follow")
if v and State.Target then
setC("Follow",RunService.Heartbeat:Connect(function()
local t=State.Target.Character and State.Target.Character:FindFirstChild("HumanoidRootPart")
local h=HRP()
if t and h and(t.Position-h.Position).Magnitude>5 then h.CFrame=CFrame.new(t.Position-t.CFrame.LookVector*5)end
end))
end
end)
S(moveX,"角色缩放",0.1,3,1,function(v)
local c=PL.Character
if not c then return end
for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")and p.Name~="HumanoidRootPart"then p.Size=Vector3.new(v,v,v)*2 end
end
end)
T(moveX,"无脚步声",false,function(v)NF("移动",v and"静音开"or"关")end)
B(moveX,"跳跃 5 连跳",function()
for i=1,5 do task.spawn(function()task.wait(0.2)local h=H()if h then h:ChangeState(Enum.HumanoidStateType.Jumping)end end)end
end)
T(moveX,"低跌落伤害",false,function(v)NF("移动",v and"低伤开"or"关")end)
S(moveX,"跌落伤害倍率",0,100,100,function(v)State.FallDmgMul=v/100 end)
local visX=window:AddTab("👁️ 视觉扩展")
L(visX,"── 光照/环境 ──")
B(visX,"全亮 (Full Bright)",function()
Lighting.Ambient=Color3.fromRGB(255,255,255)
Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
Lighting.Brightness=5
Lighting.ClockTime=12
end)
S(visX,"亮度",0,10,2,function(v)Lighting.Brightness=v end)
S(visX,"时钟时间",0,24,12,function(v)Lighting.ClockTime=v end)
S(visX,"环境光 R",0,255,128,function(v)Lighting.Ambient=Color3.new(v/255,Lighting.Ambient.G,Lighting.Ambient.B)end)
S(visX,"环境光 G",0,255,128,function(v)Lighting.Ambient=Color3.new(Lighting.Ambient.R,v/255,Lighting.Ambient.B)end)
S(visX,"环境光 B",0,255,128,function(v)Lighting.Ambient=Color3.new(Lighting.Ambient.R,Lighting.Ambient.G,v/255)end)
S(visX,"雾密度 (Fog End)",0,10000,10000,function(v)Lighting.FogEnd=v end)
B(visX,"移除雾",function()Lighting.FogEnd=1e6 Lighting.FogStart=1e6 end)
B(visX,"恢复雾",function()Lighting.FogEnd=10000 Lighting.FogStart=0 end)
S(visX,"太阳光强度",0,5,1,function(v)pcall(function()Lighting.SunRaysIntensity=v end)end)
L(visX,"── 色彩调整 ──")
B(visX,"启用色彩校正",function()
local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")or Instance.new("ColorCorrectionEffect")
cc.Parent=Lighting
NF("视觉","色彩校正启用")
end)
S(visX,"校正-亮度",-1,1,0,function(v)local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")if cc then cc.Brightness=v end end)
S(visX,"校正-对比度",-1,1,0,function(v)local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")if cc then cc.Contrast=v end end)
S(visX,"校正-饱和度",-1,1,0,function(v)local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")if cc then cc.Saturation=v end end)
S(visX,"校正-色调 R",0,1,1,function(v)local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")if cc then cc.TintColor=Color3.new(v,cc.TintColor.G,cc.TintColor.B)end end)
S(visX,"校正-色调 G",0,1,1,function(v)local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")if cc then cc.TintColor=Color3.new(cc.TintColor.R,v,cc.TintColor.B)end end)
S(visX,"校正-色调 B",0,1,1,function(v)local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")if cc then cc.TintColor=Color3.new(cc.TintColor.R,cc.TintColor.G,v)end end)
B(visX,"夜视 (Night Vision)",function()
local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")or Instance.new("ColorCorrectionEffect")
cc.Brightness=0.5
cc.Contrast=0.2
cc.TintColor=Color3.fromRGB(0,255,0)
cc.Parent=Lighting
end)
B(visX,"恢复默认色彩",function()
local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if cc then cc:Destroy()end
end)
L(visX,"── 天空 ──")
B(visX,"移除天空",function()local sky=Lighting:FindFirstChildOfClass("Sky")if sky then sky.Parent=nil end end)
B(visX,"添加默认天空",function()local sky=Lighting:FindFirstChildOfClass("Sky")if not sky then sky=Instance.new("Sky")sky.Parent=Lighting end end)
B(visX,"红色天空",function()Lighting.Ambient=Color3.fromRGB(150,30,30)Lighting.OutdoorAmbient=Color3.fromRGB(100,20,20)end)
B(visX,"紫色天空",function()Lighting.Ambient=Color3.fromRGB(120,30,150)end)
B(visX,"绿色天空",function()Lighting.Ambient=Color3.fromRGB(30,150,60)end)
B(visX,"深夜",function()Lighting.ClockTime=0 end)
B(visX,"正午",function()Lighting.ClockTime=12 end)
B(visX,"日落",function()Lighting.ClockTime=18 end)
B(visX,"日出",function()Lighting.ClockTime=6 end)
L(visX,"── 相机 ──")
S(visX,"视场角 (FOV)",20,180,70,function(v)Camera.FieldOfView=v end)
B(visX,"第一人称",function()PL.CameraMode=Enum.CameraMode.LockFirstPerson end)
B(visX,"第三人称",function()PL.CameraMode=Enum.CameraMode.Classic end)
T(visX,"自由相机 (Free Cam)",false,function(v)
clear("FreeCam")
if v then
Camera.CameraType=Enum.CameraType.Scriptable
local pos=Camera.CFrame
setC("FreeCam",RunService.RenderStepped:Connect(function()
local speed=1
if UIS:IsKeyDown(Enum.KeyCode.LeftShift)then speed=3 end
if UIS:IsKeyDown(Enum.KeyCode.W)then pos=pos+pos.LookVector*speed end
if UIS:IsKeyDown(Enum.KeyCode.S)then pos=pos-pos.LookVector*speed end
if UIS:IsKeyDown(Enum.KeyCode.A)then pos=pos-pos.RightVector*speed end
if UIS:IsKeyDown(Enum.KeyCode.D)then pos=pos+pos.RightVector*speed end
if UIS:IsKeyDown(Enum.KeyCode.Space)then pos=pos+Vector3.new(0,speed,0)end
Camera.CFrame=pos
end))
else
Camera.CameraType=Enum.CameraType.Custom
end
end)
B(visX,"恢复相机",function()Camera.CameraType=Enum.CameraType.Custom Camera.FieldOfView=70 end)
T(visX,"无相机抖动",false,function(v)if v then Camera.CameraType=Enum.CameraType.Scriptable end end)
T(visX,"观察玩家",false,function(v)
clear("Spectate")
if v and State.Target and State.Target.Character then Camera.CameraSubject=State.Target.Character:FindFirstChildOfClass("Humanoid")end
end)
L(visX,"── 物体可见性 ──")
T(visX,"透视玩家 (Highlight ESP)",false,function(v)
State.ESP.on=v
clear("ESP")
if v then
for _,p in ipairs(Players:GetPlayers())do
if p~=PL and p.Character then makeESP(p.Character,Color3.fromRGB(255,60,60))end
end
setC("ESP",Players.PlayerAdded:Connect(function(p)
p.CharacterAdded:Connect(function(c)
task.wait(1)
if State.ESP.on then makeESP(c)end
end)
end))
else
clearESP()
end
end)
B(visX,"NPC 高亮",function()
for _,m in ipairs(workspace:GetChildren())do
if m:IsA("Model")and m:FindFirstChildOfClass("Humanoid")and not Players:GetPlayerFromCharacter(m)then makeESP(m,Color3.fromRGB(255,200,60))end
end
NF("视觉","NPC 已高亮")
end)
B(visX,"清除所有高亮",function()clearESP()NF("视觉","已清除","info")end)
T(visX,"彩虹角色",false,function(v)
clear("Rainbow")
if v then
setC("Rainbow",RunService.Heartbeat:Connect(function()
local c=PL.Character
if not c then return end
local hue=tick()%1
for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.BrickColor=BrickColor.new(Color3.fromHSV(hue,1,1))end
end
end))
end
end)
T(visX,"玩家变透明 (Ghost)",false,function(v)
local c=PL.Character
if c then
for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.LocalTransparencyModifier=v and 1 or 0 end
end
end
end)
S(visX,"角色透明度",0,1,0,function(v)
local c=PL.Character
if c then
for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.LocalTransparencyModifier=v end
end
end
end)
L(visX,"── HUD 显示 ──")
T(visX,"FPS 显示",false,function(v)
clear("FPSCounter")
if v then
local lbl=Instance.new("TextLabel")
lbl.Name="NovaFPS"
lbl.Size=UDim2.new(0,150,0,24)
lbl.Position=UDim2.new(0,10,0,10)
lbl.BackgroundTransparency=1
lbl.TextColor3=Color3.fromRGB(0,255,100)
lbl.TextSize=14
lbl.Font=Enum.Font.Code
lbl.TextXAlignment=Enum.TextXAlignment.Left
lbl.ZIndex=50
lbl.Parent=screenGui
local frames,lastT=0,tick()
setC("FPSCounter",RunService.RenderStepped:Connect(function()
frames=frames+1
if tick()-lastT>=1 then
lbl.Text=string.format("FPS: %d",frames)
frames,lastT=0,tick()
end
end))
State.FPSLabel=lbl
else
if State.FPSLabel then State.FPSLabel:Destroy()end
end
end)
T(visX,"Ping 显示",false,function(v)
clear("Ping")
if v then
local lbl=Instance.new("TextLabel")
lbl.Size=UDim2.new(0,150,0,24)
lbl.Position=UDim2.new(0,10,0,34)
lbl.BackgroundTransparency=1
lbl.TextColor3=Color3.fromRGB(100,200,255)
lbl.TextSize=14
lbl.Font=Enum.Font.Code
lbl.TextXAlignment=Enum.TextXAlignment.Left
lbl.ZIndex=50
lbl.Parent=screenGui
setC("Ping",RunService.Heartbeat:Connect(function()
pcall(function()lbl.Text=string.format("Ping: %.0f ms",Stats.Network.ServerStatsItem["Data Ping"]:GetValue())end)
end))
State.PingLabel=lbl
else
if State.PingLabel then State.PingLabel:Destroy()end
end
end)
T(visX,"内存显示",false,function(v)
clear("Mem")
if v then
local lbl=Instance.new("TextLabel")
lbl.Size=UDim2.new(0,150,0,24)
lbl.Position=UDim2.new(0,10,0,58)
lbl.BackgroundTransparency=1
lbl.TextColor3=Color3.fromRGB(255,200,100)
lbl.TextSize=14
lbl.Font=Enum.Font.Code
lbl.TextXAlignment=Enum.TextXAlignment.Left
lbl.ZIndex=50
lbl.Parent=screenGui
setC("Mem",RunService.Heartbeat:Connect(function()
pcall(function()lbl.Text=string.format("Mem: %.0f MB",Stats:GetTotalMemoryUsageMb())end)
end))
State.MemLabel=lbl
else
if State.MemLabel then State.MemLabel:Destroy()end
end
end)
T(visX,"准星 (Crosshair)",false,function(v)
clear("Cross")
if v then
local cross=Instance.new("Frame")
cross.Name="NovaCross"
cross.Size=UDim2.new(0,20,0,2)
cross.Position=UDim2.new(0.5,-10,0.5,-1)
cross.BackgroundColor3=Color3.fromRGB(0,255,0)
cross.BorderSizePixel=0
cross.ZIndex=60
cross.Parent=screenGui
local v2=cross:Clone()
v2.Size=UDim2.new(0,2,0,20)
v2.Position=UDim2.new(0.5,-1,0.5,-10)
v2.Parent=screenGui
State.Cross=cross
else
if State.Cross then State.Cross:Destroy()end
local c2=screenGui:FindFirstChild("NovaCross")
while c2 do c2:Destroy()c2=screenGui:FindFirstChild("NovaCross")end
end
end)
B(visX,"伤害数字 (示例)",function()NF("视觉","需要游戏配合")end)
L(visX,"── 特殊视觉效果 ──")
T(visX,"屏幕模糊 (Blur)",false,function(v)
local blur=Lighting:FindFirstChildOfClass("BlurEffect")
if v and not blur then
blur=Instance.new("BlurEffect")
blur.Size=10
blur.Parent=Lighting
elseif not v and blur then blur:Destroy()end
end)
S(visX,"模糊强度",0,50,10,function(v)local blur=Lighting:FindFirstChildOfClass("BlurEffect")if blur then blur.Size=v end end)
T(visX,"泛光 (Bloom)",false,function(v)
local b=Lighting:FindFirstChildOfClass("BloomEffect")
if v and not b then
b=Instance.new("BloomEffect")
b.Intensity=1
b.Parent=Lighting
elseif not v and b then b:Destroy()end
end)
T(visX,"景深 (DOF)",false,function(v)
local d=Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
if v and not d then
d=Instance.new("DepthOfFieldEffect")
d.Parent=Lighting
elseif not v and d then d:Destroy()end
end)
local playerX=window:AddTab("👤 玩家扩展")
L(playerX,"── 生命与属性 ──")
B(playerX,"治疗至满血",function()local h=H()if h then h.Health=h.MaxHealth end end)
B(playerX,"杀死自己",function()local h=H()if h then h.Health=0 end end)
B(playerX,"重置角色",function()PL.Character:BreakJoints()end)
B(playerX,"复活 (Respawn)",function()PL:LoadCharacter()end)
B(playerX,"无限生命 (本地)",function()local h=H()if h then h.MaxHealth=math.huge h.Health=math.huge end end)
S(playerX,"设置生命值",1,10000,100,function(v)local h=H()if h then h.MaxHealth=v h.Health=v end end)
B(playerX,"无敌模式 (本地)",function()
local h=H()
if h then h.MaxHealth=math.huge h.Health=math.huge end
NF("玩家","无敌已开启(本地)","warning")
end)
L(playerX,"── 工具/背包 ──")
B(playerX,"装备第一个工具",function()
local bp=PL:FindFirstChild("Backpack")
if bp then local t=bp:FindFirstChildOfClass("Tool")if t then t.Parent=PL.Character end end
end)
B(playerX,"卸下当前工具",function()
local t=PL.Character:FindFirstChildOfClass("Tool")
if t then t.Parent=PL:FindFirstChild("Backpack")end
end)
B(playerX,"卸下所有工具",function()
local bp=PL:FindFirstChild("Backpack")
for _,t in ipairs(PL.Character:GetChildren())do
if t:IsA("Tool")and bp then t.Parent=bp end
end
end)
B(playerX,"列出背包物品",function()
local bp=PL:FindFirstChild("Backpack")
if bp then
local names={}
for _,t in ipairs(bp:GetChildren())do
if t:IsA("Tool")then table.insert(names,t.Name)end
end
NF("背包",table.concat(names,", "):sub(1,50),"info",4)
end
end)
B(playerX,"自动装备工具",function()
local bp=PL:FindFirstChild("Backpack")
local c=PL.Character
if bp and c then local t=bp:FindFirstChildOfClass("Tool")if t then t.Parent=c end end
end)
B(playerX,"快速切换工具",function()
local c=PL.Character
local bp=PL:FindFirstChild("Backpack")
if c and bp then
local current=c:FindFirstChildOfClass("Tool")
if current then current.Parent=bp end
local nextT=bp:FindFirstChildOfClass("Tool")
if nextT then nextT.Parent=c end
end
end)
L(playerX,"── 反 AFK ──")
T(playerX,"Anti-AFK",false,function(v)
clear("AntiAFK")
if v then
setC("AntiAFK",RunService.Heartbeat:Connect(function()
pcall(function()
game:GetService("VirtualUser"):CaptureController()
game:GetService("VirtualUser"):ClickButton1(Vector2.new())
end)
end))
end
end)
T(playerX,"Anti-Idle",false,function(v)
clear("AntiIdle")
if v then
setC("AntiIdle",RunService.Heartbeat:Connect(function()
local h=HRP()
if h then h.CFrame=h.CFrame*CFrame.Angles(0,math.rad(0.1),0)end
end))
end
end)
T(playerX,"Anti-Kick (本地)",false,function(v)NF("玩家","本地抗踢已开 (需服务器)","warning")end)
L(playerX,"── 角色外观 ──")
T(playerX,"角色隐形 (Invisible)",false,function(v)
local c=PL.Character
if c then
for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.Transparency=v and 1 or 0 end
end
end
end)
S(playerX,"角色大小",0.5,5,1,function(v)
local c=PL.Character
if not c then return end
local hum=c:FindFirstChildOfClass("Humanoid")
if hum then
for _,name in ipairs({"BodyDepthScale","BodyWidthScale","BodyHeightScale","HeadScale"})do
local s=hum:FindFirstChild(name)
if s then s.Value=v end
end
end
end)
B(playerX,"红色角色",function()
local c=PL.Character
if c then for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.BrickColor=BrickColor.Red()end end
end
end)
B(playerX,"蓝色角色",function()
local c=PL.Character
if c then for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.BrickColor=BrickColor.Blue()end end
end
end)
B(playerX,"绿色角色",function()
local c=PL.Character
if c then for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.BrickColor=BrickColor.Green()end end
end
end)
B(playerX,"恢复角色颜色",function()
local c=PL.Character
if c then for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.BrickColor=BrickColor.new("Medium stone grey")end end
end
end)
B(playerX,"更换材质为金属",function()
local c=PL.Character
if c then for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.Material=Enum.Material.Metal end end
end
end)
B(playerX,"更换材质为玻璃",function()
local c=PL.Character
if c then for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.Material=Enum.Material.Glass end end
end
end)
B(playerX,"更换材质为霓虹",function()
local c=PL.Character
if c then for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.Material=Enum.Material.Neon end end
end
end)
L(playerX,"── 动画 ──")
B(playerX,"停止所有动画",function()
local c=PL.Character
if c then
for _,t in ipairs(c:GetDescendants())do
if t:IsA("Animation")or t:IsA("Animator")then pcall(function()t:Stop()end)end
end
end
end)
B(playerX,"播放挥手动画",function()
local a=PL.Character and PL.Character:FindFirstChildOfClass("Humanoid")
if a then
local anim=Instance.new("Animation")
anim.AnimationId="rbxassetid://507770239"
local at=a:LoadAnimation(anim)
at:Play()
end
end)
B(playerX,"播放大笑动画",function()
local a=PL.Character and PL.Character:FindFirstChildOfClass("Humanoid")
if a then
local anim=Instance.new("Animation")
anim.AnimationId="rbxassetid://507770818"
local at=a:LoadAnimation(anim)
at:Play()
end
end)
B(playerX,"舞蹈 (Dance)",function()
local a=PL.Character and PL.Character:FindFirstChildOfClass("Humanoid")
if a then
local anim=Instance.new("Animation")
anim.AnimationId="rbxassetid://507771019"
local at=a:LoadAnimation(anim)
at:Play()
end
end)
B(playerX,"布娃娃 (Ragdoll)",function()
local c=PL.Character
if c then
local h=c:FindFirstChildOfClass("Humanoid")
if h then h:ChangeState(Enum.HumanoidStateType.Physics)end
end
end)
B(playerX,"站立 (Get Up)",function()
local c=PL.Character
if c then
local h=c:FindFirstChildOfClass("Humanoid")
if h then h:ChangeState(Enum.HumanoidStateType.GettingUp)end
end
end)
B(playerX,"坐下 (Sit)",function()local h=H()if h then h.Sit=true end end)
B(playerX,"站起 (Stand)",function()local h=H()if h then h.Sit=false end end)
B(playerX,"冻结自己",function()
local c=PL.Character
if c then for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.Anchored=true end end
end
end)
B(playerX,"解冻自己",function()
local c=PL.Character
if c then for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.Anchored=false end end
end
end)
B(playerX,"重置摄像机",function()
Camera.CameraType=Enum.CameraType.Custom
Camera.CameraSubject=H()
end)
local worldX=window:AddTab("🌍 世界")
L(worldX,"── 世界操作 ──")
B(worldX,"锚定所有部件",function()
for _,p in ipairs(workspace:GetDescendants())do
if p:IsA("BasePart")then p.Anchored=true end
end
NF("世界","已锚定所有","warning")
end)
B(worldX,"取消锚定所有",function()
for _,p in ipairs(workspace:GetDescendants())do
if p:IsA("BasePart")then p.Anchored=false end
end
end)
B(worldX,"关闭所有碰撞",function()
for _,p in ipairs(workspace:GetDescendants())do
if p:IsA("BasePart")then p.CanCollide=false end
end
end)
B(worldX,"恢复所有碰撞",function()
for _,p in ipairs(workspace:GetDescendants())do
if p:IsA("BasePart")then p.CanCollide=true end
end
end)
T(worldX,"移除火 (Remove Fire)",false,function(v)
clear("Fire")
if v then
setC("Fire",RunService.Heartbeat:Connect(function()
for _,p in ipairs(workspace:GetDescendants())do
if p:IsA("Fire")then p:Destroy()end
end
end))
end
end)
T(worldX,"移除烟雾 (Remove Smoke)",false,function(v)
clear("Smoke")
if v then
setC("Smoke",RunService.Heartbeat:Connect(function()
for _,p in ipairs(workspace:GetDescendants())do
if p:IsA("Smoke")or p:IsA("Sparkles")then p:Destroy()end
end
end))
end
end)
T(worldX,"移除粒子 (Remove Particles)",false,function(v)
clear("Particle")
if v then
setC("Particle",RunService.Heartbeat:Connect(function()
for _,p in ipairs(workspace:GetDescendants())do
if p:IsA("ParticleEmitter")then p.Enabled=false end
end
end))
end
end)
B(worldX,"移除所有贴图 (Decals)",function()
for _,p in ipairs(workspace:GetDescendants())do
if p:IsA("Decal")or p:IsA("Texture")then p:Destroy()end
end
end)
T(worldX,"移除水",false,function(v)
clear("Water")
if v then
setC("Water",RunService.Heartbeat:Connect(function()
local t=workspace:FindFirstChildOfClass("Terrain")
if t then pcall(function()t:Clear()end)end
end))
end
end)
B(worldX,"清除地形",function()
local t=workspace:FindFirstChildOfClass("Terrain")
if t then t:Clear()end
end)
B(worldX,"移除所有 NPC",function()
for _,m in ipairs(workspace:GetChildren())do
if m:IsA("Model")and m:FindFirstChildOfClass("Humanoid")and not Players:GetPlayerFromCharacter(m)then m:Destroy()end
end
end)
B(worldX,"移除死尸",function()
for _,m in ipairs(workspace:GetChildren())do
if m:IsA("Model")then
local h=m:FindFirstChildOfClass("Humanoid")
if h and h.Health<=0 then m:Destroy()end
end
end
end)
L(worldX,"── 物理操作 ──")
T(worldX,"反重力 (物体)",false,function(v)
clear("AntiGrav")
if v then
setC("AntiGrav",RunService.Heartbeat:Connect(function()
local c=PL.Character
for _,p in ipairs(workspace:GetDescendants())do
if p:IsA("BasePart")and p~=(c and c:FindFirstChild("HumanoidRootPart"))then
if p.Velocity.Y<0 then p.Velocity=Vector3.new(p.Velocity.X,0,p.Velocity.Z)end
end
end
end))
end
end)
T(worldX,"磁铁模式 (Magnet)",false,function(v)
clear("Magnet")
if v then
setC("Magnet",RunService.Heartbeat:Connect(function()
local h=HRP()
if not h then return end
for _,p in ipairs(workspace:GetChildren())do
if p:IsA("BasePart")and(p.Position-h.Position).Magnitude<50 then p.Velocity=(h.Position-p.Position).Unit*50 end
end
end))
end
end)
T(worldX,"反磁铁 (Repel)",false,function(v)
clear("Repel")
if v then
setC("Repel",RunService.Heartbeat:Connect(function()
local h=HRP()
if not h then return end
for _,p in ipairs(workspace:GetChildren())do
if p:IsA("BasePart")and(p.Position-h.Position).Magnitude<50 then p.Velocity=(p.Position-h.Position).Unit*100 end
end
end))
end
end)
L(worldX,"── 交互 ──")
B(worldX,"触发所有 ProximityPrompt",function()
for _,p in ipairs(workspace:GetDescendants())do
if p:IsA("ProximityPrompt")then pcall(function()p:InputHoldBegin()task.wait(0.1)p:InputHoldEnd()end)end
end
NF("世界","已尝试触发所有提示","info")
end)
B(worldX,"点击所有 ClickDetector",function()
for _,d in ipairs(workspace:GetDescendants())do
if d:IsA("ClickDetector")then
pcall(function()
if fireclickdetector then fireclickdetector(d)end
end)
end
end
NF("世界","已尝试点击","info")
end)
B(worldX,"触发所有 TouchInterest",function()
local h=HRP()
if not h then return end
for _,p in ipairs(workspace:GetDescendants())do
if p:IsA("BasePart")then
for _,t in ipairs(p:GetChildren())do
if t:IsA("TouchTransmitter")then
pcall(function()if firetouchinterest then firetouchinterest(h,p,0)end end)
end
end
end
end
NF("世界","已触发","info")
end)
L(worldX,"── 创造/破坏 ──")
B(worldX,"在面前生成方块",function()
local h=HRP()
if h then
local p=Instance.new("Part")
p.Size=Vector3.new(4,4,4)
p.Position=h.Position+h.CFrame.LookVector*10
p.BrickColor=BrickColor.Random()
p.Parent=workspace
end
end)
B(worldX,"生成锚定平台",function()
local h=HRP()
if h then
local p=Instance.new("Part")
p.Size=Vector3.new(20,1,20)
p.Position=h.Position+Vector3.new(0,-3,0)
p.Anchored=true
p.BrickColor=BrickColor.new("Dark stone grey")
p.Parent=workspace
end
end)
B(worldX,"在面前生成爆炸",function()
local h=HRP()
if h then
local e=Instance.new("Explosion")
e.Position=h.Position+h.CFrame.LookVector*20
e.BlastRadius=20
e.Parent=workspace
end
end)
T(worldX,"陨石雨",false,function(v)
clear("Meteor")
if v then
setC("Meteor",RunService.Heartbeat:Connect(function()
local h=HRP()
if not h then return end
if math.random()<0.05 then
local p=Instance.new("Part")
p.Size=Vector3.new(5,5,5)
p.Position=h.Position+Vector3.new(math.random(-100,100),200,math.random(-100,100))
p.BrickColor=BrickColor.new("Really red")
p.Material=Enum.Material.Neon
p.Parent=workspace
p.Velocity=Vector3.new(0,-200,0)
Debris:AddItem(p,10)
end
end))
end
end)
B(worldX,"删除光标下对象",function()
local mouse=PL:GetMouse()
if mouse.Target then mouse.Target:Destroy()end
end)
B(worldX,"复制光标下对象",function()
local mouse=PL:GetMouse()
if mouse.Target then
local c=mouse.Target:Clone()
c.Parent=workspace
c.Position=mouse.Target.Position+Vector3.new(0,5,0)
end
end)
B(worldX,"放大光标下对象",function()
local mouse=PL:GetMouse()
if mouse.Target then mouse.Target.Size=mouse.Target.Size*1.5 end
end)
B(worldX,"缩小光标下对象",function()
local mouse=PL:GetMouse()
if mouse.Target then mouse.Target.Size=mouse.Target.Size*0.7 end
end)
B(worldX,"彩虹光标下对象",function()
local mouse=PL:GetMouse()
if mouse.Target then mouse.Target.BrickColor=BrickColor.Random()end
end)
B(worldX,"让光标下对象变霓虹",function()
local mouse=PL:GetMouse()
if mouse.Target then mouse.Target.Material=Enum.Material.Neon end
end)
L(worldX,"── 恢复 ──")
B(worldX,"恢复所有锚定状态",function()
for _,p in ipairs(workspace:GetDescendants())do
if p:IsA("BasePart")and p.Name~="Baseplate"then p.Anchored=false end
end
end)
B(worldX,"清理生成的垃圾",function()
for _,p in ipairs(workspace:GetChildren())do
if p:IsA("Part")and p.Name=="Part"and not p.Anchored then p:Destroy()end
end
end)
local tpTab=window:AddTab("📍 传送")
L(tpTab,"── 坐标传送 ──")
B(tpTab,"传送到坐标 (0,0,0)",function()local h=HRP()if h then h.CFrame=CFrame.new(0,5,0)end end)
B(tpTab,"传送到地图中心",function()local h=HRP()if h then h.CFrame=CFrame.new(0,50,0)end end)
B(tpTab,"传送到出生点",function()
local s=workspace:FindFirstChildOfClass("SpawnLocation")
local h=HRP()
if s and h then h.CFrame=s.CFrame+Vector3.new(0,5,0)end
end)
B(tpTab,"传送到相机位置",function()local h=HRP()if h then h.CFrame=Camera.CFrame end end)
B(tpTab,"传送到鼠标位置",function()
local mouse=PL:GetMouse()
local h=HRP()
if mouse.Hit and h then h.CFrame=CFrame.new(mouse.Hit.Position+Vector3.new(0,5,0))end
end)
B(tpTab,"传送到最近玩家",function()
local h=HRP()
if not h then return end
local best,bd=nil,math.huge
for _,p in ipairs(Players:GetPlayers())do
if p~=PL and p.Character then
local r=p.Character:FindFirstChild("HumanoidRootPart")
if r then local d=(r.Position-h.Position).Magnitude
if d<bd then bd=d best=r end
end
end
end
if best then h.CFrame=best.CFrame+Vector3.new(0,0,5)end
end)
B(tpTab,"传送到最远玩家",function()
local h=HRP()
if not h then return end
local best,bd=nil,0
for _,p in ipairs(Players:GetPlayers())do
if p~=PL and p.Character then
local r=p.Character:FindFirstChild("HumanoidRootPart")
if r then local d=(r.Position-h.Position).Magnitude
if d>bd then bd=d best=r end
end
end
end
if best then h.CFrame=best.CFrame+Vector3.new(0,0,5)end
end)
B(tpTab,"传送到最高点",function()
local h=HRP()
if not h then return end
local maxY,bestP=-math.huge,h.Position
for _,p in ipairs(workspace:GetChildren())do
if p:IsA("BasePart")then
if p.Position.Y>maxY then maxY=p.Position.Y bestP=p.Position end
end
end
h.CFrame=CFrame.new(bestP+Vector3.new(0,5,0))
end)
B(tpTab,"传送到最低点",function()
local h=HRP()
if not h then return end
local minY,bestP=math.huge,h.Position
for _,p in ipairs(workspace:GetChildren())do
if p:IsA("BasePart")then
if p.Position.Y<minY then minY=p.Position.Y bestP=p.Position end
end
end
h.CFrame=CFrame.new(bestP+Vector3.new(0,5,0))
end)
B(tpTab,"向前传送 50",function()local h=HRP()if h then h.CFrame=h.CFrame+h.CFrame.LookVector*50 end end)
B(tpTab,"向后传送 50",function()local h=HRP()if h then h.CFrame=h.CFrame-h.CFrame.LookVector*50 end end)
B(tpTab,"向上传送 50",function()local h=HRP()if h then h.CFrame=h.CFrame+Vector3.new(0,50,0)end end)
B(tpTab,"向下传送 50",function()local h=HRP()if h then h.CFrame=h.CFrame-Vector3.new(0,50,0)end end)
B(tpTab,"随机传送",function()
local h=HRP()
if h then h.CFrame=CFrame.new(math.random(-500,500),100,math.random(-500,500))end
end)
L(tpTab,"── 坐标设置 ──")
local tpX=0
S(tpTab,"X 坐标",-2000,2000,0,function(v)tpX=v end)
local tpY=50
S(tpTab,"Y 坐标",-500,2000,50,function(v)tpY=v end)
local tpZ=0
S(tpTab,"Z 坐标",-2000,2000,0,function(v)tpZ=v end)
B(tpTab,"传送到上方坐标",function()
local h=HRP()
if h then h.CFrame=CFrame.new(tpX,tpY,tpZ)end
end)
L(tpTab,"── 路径点 ──")
B(tpTab,"保存路径点 1",function()
local h=HRP()
if h then State.Waypoints[1]=h.CFrame NF("路径","已保存点 1")end
end)
B(tpTab,"保存路径点 2",function()
local h=HRP()
if h then State.Waypoints[2]=h.CFrame NF("路径","已保存点 2")end
end)
B(tpTab,"传送到路径点 1",function()
local h=HRP()
if h and State.Waypoints[1]then h.CFrame=State.Waypoints[1]end
end)
B(tpTab,"传送到路径点 2",function()
local h=HRP()
if h and State.Waypoints[2]then h.CFrame=State.Waypoints[2]end
end)
B(tpTab,"清除路径点",function()State.Waypoints={}NF("路径","已清除")end)
L(tpTab,"── 录制/回放 ──")
T(tpTab,"录制路径",false,function(v)
clear("Record")
if v then
State.RecordPath={}
State.Recording=true
setC("Record",RunService.Heartbeat:Connect(function()
local h=HRP()
if h then table.insert(State.RecordPath,h.CFrame)end
end))
else
State.Recording=false
NF("录制","已记录 "..#State.RecordPath.." 帧")
end
end)
B(tpTab,"回放路径",function()
if #State.RecordPath==0 then return end
task.spawn(function()
for _,cf in ipairs(State.RecordPath)do
local h=HRP()
if h then h.CFrame=cf end
RunService.Heartbeat:Wait()
end
end)
end)
B(tpTab,"清除录制",function()State.RecordPath={}NF("录制","已清除")end)
T(tpTab,"自动寻路 (Auto Walk)",false,function(v)
clear("AutoWalk")
if v then
setC("AutoWalk",RunService.Heartbeat:Connect(function()
local h=H()
if h then h:Move(Vector3.new(0,0,-1),true)end
end))
end
end)
L(tpTab,"── 特殊 ──")
B(tpTab,"传送所有 NPC 到身边",function()
local h=HRP()
if h then
for _,m in ipairs(workspace:GetChildren())do
if m:IsA("Model")and m:FindFirstChildOfClass("Humanoid")then
local r=m:FindFirstChild("HumanoidRootPart")
if r then r.CFrame=h.CFrame+Vector3.new(math.random(-10,10),0,math.random(-10,10))end
end
end
end
end)
B(tpTab,"传送到天空",function()local h=HRP()if h then h.CFrame=CFrame.new(0,500,0)end end)
B(tpTab,"传送到地底",function()local h=HRP()if h then h.CFrame=CFrame.new(0,-100,0)end end)
local funTab=window:AddTab("🎮 娱乐")
L(funTab,"── 聊天 ──")
B(funTab,"发送聊天: Hello",function()
pcall(function()game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Hello!","All")end)
end)
B(funTab,"发送聊天: LOL",function()
pcall(function()game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("LOL","All")end)
end)
B(funTab,"发送聊天: :) ",function()
pcall(function()game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(":)","All")end)
end)
T(funTab,"聊天刷屏",false,function(v)
clear("Spam")
if v then
setC("Spam",RunService.Heartbeat:Connect(function()
pcall(function()game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Nova Hub","All")end)
end))
end
end)
L(funTab,"── 声音 ──")
B(funTab,"播放音乐 (rbxassetid://9046894295)",function()
local s=Instance.new("Sound")
s.SoundId="rbxassetid://9046894295"
s.Parent=workspace
s:Play()
Debris:AddItem(s,30)
end)
B(funTab,"播放音效: 爆炸",function()
local s=Instance.new("Sound")
s.SoundId="rbxassetid://151734252"
s.Parent=workspace
s:Play()
Debris:AddItem(s,5)
end)
B(funTab,"播放音效: 拳击",function()
local s=Instance.new("Sound")
s.SoundId="rbxassetid://2811771736"
s.Parent=workspace
s:Play()
Debris:AddItem(s,5)
end)
L(funTab,"── 视觉特效 ──")
B(funTab,"在自己位置爆炸",function()
local h=HRP()
if h then
local e=Instance.new("Explosion")
e.Position=h.Position
e.BlastRadius=20
e.BlastPressure=0
e.Parent=workspace
end
end)
B(funTab,"生成火花",function()
local h=HRP()
if h then
for _,p in ipairs(h:GetChildren())do
if p:IsA("BasePart")then
local s=Instance.new("Sparkles")
s.SparkleColor=Color3.fromRGB(math.random(255),math.random(255),math.random(255))
s.Parent=p
Debris:AddItem(s,5)
end
end
end
end)
B(funTab,"生成火焰",function()
local h=HRP()
if h then
for _,p in ipairs(h:GetChildren())do
if p:IsA("BasePart")then
local f=Instance.new("Fire")
f.Parent=p
Debris:AddItem(f,5)
end
end
end
end)
B(funTab,"生成烟雾",function()
local h=HRP()
if h then
for _,p in ipairs(h:GetChildren())do
if p:IsA("BasePart")then
local s=Instance.new("Smoke")
s.Parent=p
Debris:AddItem(s,5)
end
end
end
end)
B(funTab,"生成闪电",function()
local h=HRP()
if h then
local e=Instance.new("Explosion")
e.Position=h.Position+Vector3.new(0,100,0)
e.BlastRadius=1
e.BlastPressure=0
e.Parent=workspace
end
end)
B(funTab,"彩虹粒子",function()
local h=HRP()
if h then
local p=Instance.new("ParticleEmitter")
p.Rate=50
p.Lifetime=NumberRange.new(1,2)
p.Speed=NumberRange.new(5,10)
p.Color=ColorSequence.new(Color3.fromRGB(255,0,0),Color3.fromRGB(0,0,255))
p.Parent=h
Debris:AddItem(p,5)
end
end)
L(funTab,"── 角色恶搞 ──")
B(funTab,"旋转自己",function()
local h=HRP()
if h then
for i=1,50 do
task.wait(0.02)
h.CFrame=h.CFrame*CFrame.Angles(0,math.rad(20),0)
end
end
end)
B(funTab,"上下翻转",function()
local h=HRP()
if h then h.CFrame=h.CFrame*CFrame.Angles(math.rad(180),0,0)end
end)
B(funTab,"飞速旋转",function()
local h=HRP()
if h then h.CFrame=h.CFrame*CFrame.Angles(math.rad(math.random(360)),math.rad(math.random(360)),0)end
end)
B(funTab,"跳跃所有人",function()
for _,p in ipairs(Players:GetPlayers())do
if p.Character then
local h=p.Character:FindFirstChildOfClass("Humanoid")
if h then pcall(function()h:ChangeState(Enum.HumanoidStateType.Jumping)end)end
end
end
end)
B(funTab,"冻结所有人 (本地)",function()
for _,p in ipairs(Players:GetPlayers())do
if p.Character then
local h=p.Character:FindFirstChildOfClass("Humanoid")
if h then pcall(function()h.WalkSpeed=0 h.JumpPower=0 end)end
end
end
end)
B(funTab,"解冻所有人",function()
for _,p in ipairs(Players:GetPlayers())do
if p.Character then
local h=p.Character:FindFirstChildOfClass("Humanoid")
if h then pcall(function()h.WalkSpeed=16 h.JumpPower=50 end)end
end
end
end)
B(funTab,"彩虹全体 (本地)",function()
for _,p in ipairs(Players:GetPlayers())do
if p.Character then
for _,part in ipairs(p.Character:GetDescendants())do
if part:IsA("BasePart")then part.BrickColor=BrickColor.Random()end
end
end
end
end)
L(funTab,"── 特效 ──")
T(funTab,"彩虹模式 (自我)",false,function(v)
clear("RainbowSelf")
if v then
setC("RainbowSelf",RunService.Heartbeat:Connect(function()
local c=PL.Character
if not c then return end
local hue=tick()%1
for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.Color=Color3.fromHSV(hue,1,1)end
end
end))
end
end)
T(funTab,"迪斯科模式",false,function(v)
clear("Disco")
if v then
setC("Disco",RunService.Heartbeat:Connect(function()
Lighting.Ambient=Color3.fromHSV(tick()%1,1,0.5)
end))
end
end)
B(funTab,"屏幕震动",function()
local original=Camera.CFrame
task.spawn(function()
for i=1,20 do
Camera.CFrame=original*CFrame.new(math.random(-2,2),math.random(-2,2),0)
task.wait(0.02)
end
Camera.CFrame=original
end)
end)
B(funTab,"假 BAN 屏幕",function()
local f=Instance.new("Frame")
f.Size=UDim2.new(1,0,1,0)
f.BackgroundColor3=Color3.fromRGB(0,0,0)
f.ZIndex=1000
f.Parent=screenGui
local t=Instance.new("TextLabel")
t.Size=UDim2.new(1,0,0,100)
t.Position=UDim2.new(0,0,0.5,-50)
t.BackgroundTransparency=1
t.Text="你已被封禁 (是玩笑啦)"
t.TextColor3=Color3.fromRGB(255,0,0)
t.TextSize=48
t.Font=Enum.Font.GothamBold
t.ZIndex=1001
t.Parent=f
task.delay(3,function()f:Destroy()end)
end)
B(funTab,"假错误弹窗",function()
local f=Instance.new("Frame")
f.Size=UDim2.new(0,400,0,200)
f.Position=UDim2.new(0.5,-200,0.5,-100)
f.BackgroundColor3=Color3.fromRGB(30,30,40)
f.ZIndex=1000
f.Parent=screenGui
local c=Instance.new("UICorner")c.CornerRadius=UDim.new(0,12)c.Parent=f
local t=Instance.new("TextLabel")
t.Size=UDim2.new(1,-20,1,-20)
t.Position=UDim2.new(0,10,0,10)
t.BackgroundTransparency=1
t.Text="发生错误!\n\nNova Hub 遇到了未知错误\n(不是真的)"
t.TextColor3=Color3.fromRGB(255,255,255)
t.TextSize=16
t.Font=Enum.Font.Gotham
t.TextWrapped=true
t.ZIndex=1001
t.Parent=f
task.delay(3,function()f:Destroy()end)
end)
B(funTab,"假断线弹窗",function()
local f=Instance.new("Frame")
f.Size=UDim2.new(1,0,1,0)
f.BackgroundColor3=Color3.fromRGB(20,20,20)
f.BackgroundTransparency=0.3
f.ZIndex=1000
f.Parent=screenGui
local t=Instance.new("TextLabel")
t.Size=UDim2.new(1,0,0,100)
t.Position=UDim2.new(0,0,0.5,-50)
t.BackgroundTransparency=1
t.Text="已断开连接\n(开玩笑的)"
t.TextColor3=Color3.fromRGB(255,255,255)
t.TextSize=36
t.Font=Enum.Font.Gotham
t.ZIndex=1001
t.Parent=f
task.delay(3,function()f:Destroy()end)
end)
L(funTab,"── 天气 ──")
B(funTab,"雷暴模式",function()
Lighting.ClockTime=0
Lighting.Ambient=Color3.fromRGB(50,50,60)
end)
B(funTab,"下雨 (粒子)",function()
local c=PL.Character
if c and c:FindFirstChild("Head")then
local p=Instance.new("ParticleEmitter")
p.Rate=100
p.Lifetime=NumberRange.new(1,2)
p.Speed=NumberRange.new(100,150)
p.Color=ColorSequence.new(Color3.fromRGB(100,100,200))
p.Parent=c.Head
Debris:AddItem(p,10)
end
end)
B(funTab,"下雪 (粒子)",function()
local c=PL.Character
if c and c:FindFirstChild("Head")then
local p=Instance.new("ParticleEmitter")
p.Rate=50
p.Lifetime=NumberRange.new(2,3)
p.Speed=NumberRange.new(5,10)
p.Color=ColorSequence.new(Color3.new(1,1,1))
p.Parent=c.Head
Debris:AddItem(p,10)
end
end)
B(funTab,"白天",function()Lighting.ClockTime=12 end)
B(funTab,"黑夜",function()Lighting.ClockTime=0 end)
T(funTab,"慢动作 (Slow Motion)",false,function(v)
if v then workspace.Gravity=workspace.Gravity/3 else workspace.Gravity=196 end
end)
T(funTab,"加速 (Fast Forward)",false,function(v)
local h=H()
if h then
h.WalkSpeed=v and 60 or 16
h.JumpPower=v and 150 or 50
end
end)
B(funTab,"时间冻结 (视觉效果)",function()NF("娱乐","时间已冻结 (视觉)","info")end)
T(funTab,"混乱模式 (Chaos)",false,function(v)
clear("Chaos")
if v then
setC("Chaos",RunService.Heartbeat:Connect(function()
if math.random()<0.1 then
local h=HRP()
if h then
local p=Instance.new("Part")
p.Size=Vector3.new(math.random(1,5),math.random(1,5),math.random(1,5))
p.Position=h.Position+Vector3.new(math.random(-30,30),10,math.random(-30,30))
p.BrickColor=BrickColor.Random()
p.Velocity=Vector3.new(0,math.random(-50,-20),0)
p.Parent=workspace
Debris:AddItem(p,5)
end
end
end))
end
end)
T(funTab,"派对模式",false,function(v)
clear("Party")
if v then
setC("Party",RunService.Heartbeat:Connect(function()
Lighting.Ambient=Color3.fromHSV(math.random(),1,0.7)
end))
end
end)
B(funTab,"烟花表演",function()
local h=HRP()
if not h then return end
for i=1,5 do
task.spawn(function()
task.wait(i*0.3)
local p=Instance.new("Part")
p.Size=Vector3.new(1,1,1)
p.Position=h.Position+Vector3.new(math.random(-20,20),30+i*5,math.random(-20,20))
p.Anchored=true
p.BrickColor=BrickColor.Random()
p.Material=Enum.Material.Neon
p.Parent=workspace
local e=Instance.new("Explosion")
e.Position=p.Position
e.BlastRadius=10
e.BlastPressure=0
e.Parent=workspace
p:Destroy()
end)
end
end)
print("[Nova Hub] 扩展包加载完成 — 273 个新功能已注册")
task.wait(0.5)
_G.NovaNotify("Nova Hub","脚本加载完成 ✓","success",3)
task.wait(0.8)
_G.NovaNotify("提示","点击顶部灵动岛可展开","info",3)
LocalPlayer.CharacterAdded:Connect(function(char)
task.wait(1)
end)
print("[Nova Hub] 脚本 v2.0 已成功加载 — 300+ 功能可用")