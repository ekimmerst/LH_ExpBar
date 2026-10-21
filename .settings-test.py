from pathlib import Path
import sys

addon = Path(__file__).resolve().parent
sys.path.insert(0, str(addon.parent / 'LH_Tweaks/.test-runtime'))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime()
lua.execute('''
frames={};SlashCmdList={};xp=45000;maximum=100000;bonus=150000;level=30
cursorX,cursorY,mouseDown=0,0,false
local M={}
function M:SetScript(k,v) self.scripts[k]=v end
function M:SetPoint(...) self.point={...} end
function M:ClearAllPoints() self.point=nil end
function M:SetSize(w,h) self.width=w;self.height=h end
function M:SetWidth(w) self.width=w end
function M:GetWidth() return self.width or 160 end
function M:GetEffectiveScale() return self.scale or 1 end
function M:GetCenter() return 700,400 end
function M:GetLeft() return 100 end
function M:GetTop() return 200 end
function M:GetFrameLevel() return 1 end
function M:StartMoving() self.moving=true end
function M:StopMovingOrSizing() self.moving=false end
function M:EnableMouse(v) self.mouse=v end
function M:SetFont(_,size) self.fontSize=size end
function M:SetText(v) self.text=v end
function M:SetValue(v) self.value=v end
function M:GetValue() return self.value or 0 end
function M:SetMinMaxValues(lo,hi) self.minimum=lo;self.maximum=hi end
function M:Show() self.visible=true end
function M:Hide()
 local was=self.visible;self.visible=false
 if was and self.scripts.OnHide then self.scripts.OnHide(self) end
end
function M:SetShown(v) if v then self:Show() else self:Hide() end end
function M:CreateTexture() return CreateFrame('Texture',nil,self) end
function M:CreateFontString() return CreateFrame('Font',nil,self) end
setmetatable(M,{__index=function(_,k) if k:match('^%u') then return function() end end end})
function CreateFrame(kind,name,parent)
 local f=setmetatable({kind=kind,scripts={},parent=parent},{__index=M})
 frames[#frames+1]=f;if name then _G[name]=f end;return f
end
UIParent=CreateFrame('Frame');Minimap=CreateFrame('Frame');Minimap.scale=1.5
function UnitXP() return xp end
function UnitXPMax() return maximum end
function GetXPExhaustion() return bonus end
function UnitLevel() return level end
function GetMaxPlayerLevel() return 60 end
function GetCursorPosition() return cursorX,cursorY end
function IsMouseButtonDown() return mouseDown end
C_Timer={After=function(_,fn) delayed=fn end}
GameTooltip={lines={}}
function GameTooltip:IsOwned(owner) return self.owner==owner end
function GameTooltip:SetOwner(owner) self.owner=owner end
function GameTooltip:SetText(text) self.lines={text} end
function GameTooltip:AddLine(text) table.insert(self.lines,text) end
function GameTooltip:Show() self.visible=true end
function GameTooltip:Hide() self.visible=false;self.owner=nil end
registry={};notices={};callbacks={};buttons={}
Settings={}
function Settings.RegisterVerticalLayoutSubcategory(parent,title)
 local c={parent=parent,title=title};local l={rows={}}
 function l:AddInitializer(row) table.insert(self.rows,row) end
 c.layout=l;return c,l
end
function Settings.RegisterAddOnCategory(c) registered=c end
function Settings.RegisterProxySetting(c,v,kind,label,default,get,set)
 local s={category=c,default=default,get=get,set=set};registry[v]=s;return s
end
function Settings.NotifyUpdate(v) notices[v]=(notices[v] or 0)+1 end
function Settings.CreateCheckbox(c,s,t) c.layout:AddInitializer({setting=s,tooltip=t}) end
function Settings.CreateSliderOptions(min,max,step) return {min=min,max=max,step=step,SetLabelFormatter=function() end} end
function Settings.CreateSlider(c,s,o,t) c.layout:AddInitializer({setting=s,options=o,tooltip=t}) end
function CreateSettingsListSectionHeaderInitializer(t) return {header=t} end
function CreateSettingsButtonInitializer(label,text,fn) buttons[text]=fn;return {label=label} end
MinimalSliderWithSteppersMixin={Label={Right=1}}
EventRegistry={}
function EventRegistry:RegisterCallback(event,fn,owner)
 callbacks[event]=callbacks[event] or {};table.insert(callbacks[event],{fn,owner})
end
function fire(event,...) for _,v in ipairs(callbacks[event]) do v[1](v[2],...) end end
LH_Tweaks={modules={}}
''')
core = addon.parent / 'LH_Tweaks'
source = (core / 'LH_Tweaks.lua').read_text()
registration = source.split('function Hub:RegisterModule(id, title, build)')[1].split('\nfunction Hub:RestoreDefaults')[0]
lua.execute('local Hub=LH_Tweaks\nfunction Hub:RegisterModule(id, title, build)' + registration)
source = (core / 'Settings.lua').read_text()
registration = source.split('function Hub:RegisterModulePage(id)')[1].split('\nlocal function RegisterSettings')[0]
lua.execute('local Hub=LH_Tweaks\nfunction Hub:RegisterModulePage(id)' + registration)
lua.execute((addon / 'LH_ExpBar.lua').read_text(), 'LH_ExpBar')
lua.execute('events=frames[#frames]')
lua.execute((addon / 'Settings.lua').read_text(), 'LH_ExpBar')
lua.execute('''
assert(LH_Tweaks.modules.LH_ExpBar and not registered)
events.scripts.OnEvent(events,'ADDON_LOADED','LH_ExpBar')
local a,b,h=LH_ExpBar,LH_ExpBarFrame,LH_ExpBarResizeHandle
local bars={};local label
for _,f in ipairs(frames) do
 if f.kind=='StatusBar' then bars[#bars+1]=f end
 if f.kind=='Font' then label=f end
end
local rested,gain,experience=unpack(bars)
assert(LH_ExpBarDB.locked and b.visible and b.width==240 and b.height==20)
assert(not h.visible and b.mouse and not LH_ExpBarDB.position)
assert(rested.value==maximum and experience.value==45000 and label.fontSize==12)
b.scripts.OnDragStart(b);assert(not b.moving)
b.scripts.OnEnter();assert(GameTooltip.visible)
assert(GameTooltip.lines[2]=='Current XP: 45000 / 100000 (45.00%)')
assert(GameTooltip.lines[3]=='Rested XP: 150000 (150.00% of a level)')
xp=50000;bonus=0;events.scripts.OnEvent(events,'PLAYER_XP_UPDATE','player')
assert(GameTooltip.lines[2]=='Current XP: 50000 / 100000 (50.00%)')
assert(GameTooltip.lines[3]=='Rested XP: 0 (0.00% of a level)' and not rested.visible)
experience.scripts.OnUpdate(experience,.3);assert(experience.value==49375 and gain.visible)
experience.scripts.OnUpdate(experience,.3);assert(experience.value==50000 and not gain.visible)
GameTooltip:SetOwner({});GameTooltip:Show();b.scripts.OnLeave();assert(GameTooltip.visible)
GameTooltip:Hide();b.scripts.OnEnter();b.scripts.OnLeave();assert(not GameTooltip.visible)
SlashCmdList.LH_EXPBAR(' unlock ')
assert(a:IsUnlocked() and h.visible and not LH_ExpBarDB.position)
b.scripts.OnEnter();assert(not GameTooltip.visible)
b.scale=2;b.scripts.OnDragStart(b);assert(b.moving);b.scripts.OnDragStop()
assert(LH_ExpBarDB.position.x==1400 and LH_ExpBarDB.position.y==800)
events.scripts.OnUpdate(events,.5);assert(b.width==120)
mouseDown=true;h.scripts.OnMouseDown(nil,'RightButton');cursorX=120;cursorY=-20
events.scripts.OnUpdate(events,.1);assert(LH_ExpBarDB.widthFactor==1)
cursorX,cursorY=0,0;h.scripts.OnMouseDown(nil,'LeftButton')
assert(b.point[1]=='TOPLEFT' and b.point[4]==200 and b.point[5]==400)
cursorX,cursorY=120,-20;events.scripts.OnUpdate(events,.1)
assert(LH_ExpBarDB.widthFactor==1.5 and LH_ExpBarDB.heightFactor==1.5)
assert(b.width==180 and b.height==30 and label.fontSize==12)
cursorX,cursorY=9999,-9999;events.scripts.OnUpdate(events,.1)
assert(LH_ExpBarDB.widthFactor==2 and LH_ExpBarDB.heightFactor==2)
cursorX,cursorY=-9999,9999;events.scripts.OnUpdate(events,.1)
assert(LH_ExpBarDB.widthFactor==.5 and LH_ExpBarDB.heightFactor==.5 and b.width==70)
SlashCmdList.LH_EXPBAR('lock');assert(not h.visible and not a:IsUnlocked())
cursorX=0;events.scripts.OnUpdate(events,.5);assert(LH_ExpBarDB.widthFactor==.5)
SlashCmdList.LH_EXPBAR('unlock');SlashCmdList.LH_EXPBAR('reset')
assert(a:IsUnlocked() and LH_ExpBarDB.widthFactor==1 and LH_ExpBarDB.heightFactor==1)
assert(not LH_ExpBarDB.position and b.point[1]=='TOP' and b.point[2]==Minimap)
-- The native category uses the same state and resets only this module.
LH_Tweaks.category={title='LH Tweaks'};LH_Tweaks:RegisterModulePage('LH_ExpBar')
local c=registered;assert(c.title=='LH ExpBar' and c.parent==LH_Tweaks.category)
local u,w,t=registry.LH_ExpBar_unlocked,registry.LH_ExpBar_widthFactor,registry.LH_ExpBar_heightFactor
assert(u.get() and w.get()==100 and t.get()==100)
w.set(175);t.set(75);assert(b.width==210 and b.height==15)
u.set(false);assert(not a:IsUnlocked())
SlashCmdList.LH_EXPBAR('unlock');assert(u.get() and notices.LH_ExpBar_unlocked>0)
buttons['Reset layout']();assert(u.get() and w.get()==100 and t.get()==100)
w.set(150);fire('Settings.CategoryDefaulted',{});assert(w.get()==150)
fire('Settings.CategoryDefaulted',c);assert(not u.get() and w.get()==100 and not LH_ExpBarDB.position)
-- Resize completion updates native slider values even when mouse-up is missed.
u.set(true);cursorX,cursorY=0,0;h.scripts.OnMouseDown(nil,'LeftButton')
cursorX=120;events.scripts.OnUpdate(events,.1);mouseDown=false;events.scripts.OnUpdate(events,.1)
assert(w.get()==150 and notices.LH_ExpBar_widthFactor>0)
-- Minimap changes retain the saved factor and the default anchor until moved.
buttons['Reset layout']();Minimap.width=200;events.scripts.OnUpdate(events,.5)
assert(b.width==150 and not LH_ExpBarDB.position)
maximum=0;level=60;events.scripts.OnEvent(events,'PLAYER_LEVEL_UP')
assert(b.visible and label.text=='LH ExpBar')
u.set(false);assert(not b.visible and not GameTooltip.visible)
u.set(true);assert(b.visible and h.visible)
fire('Settings.Defaulted');assert(not b.visible and not a:IsUnlocked())
-- Level-up deferral must reevaluate the new XP maximum without stale animation.
maximum=100000;level=30;xp=1000;events.scripts.OnEvent(events,'PLAYER_LEVEL_UP')
level=31;maximum=110000;xp=200;delayed()
assert(experience.value==200 and experience.maximum==110000)
''')
# Reload the existing saved position, lock and dimensions through a fresh addon load.
lua.execute('LH_ExpBarDB={position={x=500,y=300},locked=false,widthFactor=1.25,heightFactor=.75}')
lua.execute((addon / 'LH_ExpBar.lua').read_text(), 'LH_ExpBar')
lua.execute('''
local e=frames[#frames];e.scripts.OnEvent(e,'ADDON_LOADED','LH_ExpBar')
assert(LH_ExpBar:IsUnlocked() and LH_ExpBarFrame.height==15)
assert(LH_ExpBarFrame.point[4]==500 and LH_ExpBarFrame.point[5]==300)
''')
# LH_Range uses the rendered experience bar as its default width reference.
lua.execute('''
function UnitClass() return 'Shaman','SHAMAN' end
function UnitIsUnit() return false end
function UnitCanAttack() return false end
function UnitCanAssist() return false end
function UnitExists() return false end
function UnitIsDeadOrGhost() return false end
function GetSpellInfo(id) return 'Spell'..id end
''')
lua.execute((addon.parent / 'LH_Range/LH_Range.lua').read_text(), 'LH_Range')
lua.execute('''
local e=frames[#frames];e.scripts.OnEvent(e,'ADDON_LOADED','LH_Range')
assert(LH_RangeFrame.width==LH_ExpBarFrame.width)
LH_ExpBar:SetSizeFactor('widthFactor',2)
e.scripts.OnUpdate(e,.11)
assert(LH_RangeFrame.width==LH_ExpBarFrame.width and LH_RangeFrame.width==600)
''')
for ext in ('png', 'tga'):
    assert (addon / f'Media/Icon.{ext}').read_bytes() == (core / f'Icon.{ext}').read_bytes()
print('PASS: XP/rested tooltip and live refresh, gain animation, lock/drag/resize and limits, scale conversion, minimap tracking, cap preview, saved state, native controls/defaults, LH_Range width integration and shared icons')
