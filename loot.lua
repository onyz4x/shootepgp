local T = AceLibrary("Tablet-2.0")
local D = AceLibrary("Dewdrop-2.0")
local C = AceLibrary("Crayon-2.0")

local BC = AceLibrary("Babble-Class-2.2")
local L = AceLibrary("AceLocale-2.2"):new("shootyepgp")

sepgp_loot = sepgp:NewModule("sepgp_loot", "AceDB-2.0")

local shooty_loot_export = CreateFrame("Frame", "shooty_loot_exportframe", UIParent)
shooty_loot_export:SetWidth(250)
shooty_loot_export:SetHeight(150)
shooty_loot_export:SetPoint('TOP', UIParent, 'TOP', 0,-80)
shooty_loot_export:SetFrameStrata('DIALOG')
shooty_loot_export:Hide()
shooty_loot_export:SetBackdrop({
  bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
  edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
  tile = true,
  tileSize = 16,
  edgeSize = 16,
  insets = {left = 5, right = 5, top = 5, bottom = 5}
  })
shooty_loot_export:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
shooty_loot_export:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
shooty_loot_export.action = CreateFrame("Button","shooty_loot_exportaction", shooty_loot_export, "UIPanelButtonTemplate")
shooty_loot_export.action:SetWidth(100)
shooty_loot_export.action:SetHeight(22)
shooty_loot_export.action:SetPoint("BOTTOM",0,-20)
shooty_loot_export.action:SetText("Import")
shooty_loot_export.action:Hide()
shooty_loot_export.action:SetScript("OnClick",function() sepgp_standings.import() end)
shooty_loot_export.title = shooty_loot_export:CreateFontString(nil,"OVERLAY")
shooty_loot_export.title:SetPoint("TOP",0,-5)
shooty_loot_export.title:SetFont("Fonts\\ARIALN.TTF", 12)
shooty_loot_export.title:SetWidth(200)
shooty_loot_export.title:SetJustifyH("LEFT")
shooty_loot_export.title:SetJustifyV("CENTER")
shooty_loot_export.title:SetShadowOffset(1, -1)
shooty_loot_export.edit = CreateFrame("EditBox", "shooty_loot_exportedit", shooty_loot_export)
shooty_loot_export.edit:SetMultiLine(true)
shooty_loot_export.edit:SetAutoFocus(true)
shooty_loot_export.edit:EnableMouse(true)
shooty_loot_export.edit:SetMaxLetters(0)
shooty_loot_export.edit:SetHistoryLines(1)
shooty_loot_export.edit:SetFont('Fonts\\ARIALN.ttf', 12, 'THINOUTLINE')
shooty_loot_export.edit:SetWidth(290)
shooty_loot_export.edit:SetHeight(190)
shooty_loot_export.edit:SetScript("OnEscapePressed", function() 
  shooty_loot_export.edit:SetText("")
  shooty_loot_export:Hide() 
  end)
  shooty_loot_export.edit:SetScript("OnEditFocusGained", function()
    shooty_loot_export.edit:HighlightText()
end)
shooty_loot_export.edit:SetScript("OnCursorChanged", function() 
  shooty_loot_export.edit:HighlightText()
end)
shooty_loot_export.AddSelectText = function(txt)
  shooty_loot_export.edit:SetText(txt)
  shooty_loot_export.edit:HighlightText()
end
shooty_loot_export.scroll = CreateFrame("ScrollFrame", "shooty_loot_exportscroll", shooty_loot_export, 'UIPanelScrollFrameTemplate')
shooty_loot_export.scroll:SetPoint('TOPLEFT', shooty_loot_export, 'TOPLEFT', 8, -30)
shooty_loot_export.scroll:SetPoint('BOTTOMRIGHT', shooty_loot_export, 'BOTTOMRIGHT', -30, 8)
shooty_loot_export.scroll:SetScrollChild(shooty_loot_export.edit)
sepgp:make_escable("shooty_loot_exportframe","add")

function shooty_loot_export:Export()
  shooty_loot_export.action:Hide()
  shooty_loot_export.title:SetText(C:Gold(L["Ctrl-C to copy. Esc to close."]))
  -- local t = {}
  -- for i = 1, GetNumGuildMembers(1) do
  --   local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
  --   local ep = (sepgp:get_ep_v3(name,officernote) or 0) 
  --   local gp = (sepgp:get_gp_v3(name,officernote) or sepgp.VARS.basegp) 
  --   if ep > 0 then
  --     table.insert(t,{name,ep,gp,ep/gp})
  --   end
  -- end 
  -- table.sort(t, function(a,b)
  --     return tonumber(a[4]) > tonumber(b[4])
  --   end)
  shooty_loot_export:Show()
  local txt = "时间;player_color;itemLink;itemId;bind;price;off_price;action\n"
  for i,val in pairs(sepgp_looted) do
    local itemId = tonumber(strmatch(val[4], "item:(%d+):"));
    txt = string.format("%s%s;%s;%s;%s;%s;%d;%d;%s\n",txt,val[1],val[3],val[4],itemId,val[5],val[6],val[7],val[8])
  end
  shooty_loot_export.AddSelectText(txt)
end

function sepgp_loot:OnEnable()
  if not T:IsRegistered("sepgp_loot") then
    T:Register("sepgp_loot",
      "children", function()
        T:SetTitle(L["shootyepgp loot info"])
        self:OnTooltipUpdate()
      end,
      "showTitleWhenDetached", true,
      "showHintWhenDetached", true,
      "cantAttach", true,
      "menu", function()
        D:AddLine(
          "text", L["Refresh"],
          "tooltipText", L["Refresh window"],
          "func", function() sepgp_loot:Refresh() end
        )
        D:AddLine(
          "text", L["Clear"],
          "tooltipText", L["Clear Loot."],
          "func", function() sepgp_looted = {} sepgp_loot:Refresh() end
        )    
        D:AddLine(
          "text", L["Export"],
          "tooltipText", L["Export standings to csv."],
          "func", function() shooty_loot_export:Export() end
        )    
      end      
    )
  end
  if not T:IsAttached("sepgp_loot") then
    T:Open("sepgp_loot")
  end
end

function sepgp_loot:OnDisable()
  T:Close("sepgp_loot")
end

function sepgp_loot:Refresh()
  T:Refresh("sepgp_loot")
end

function sepgp_loot:setHideScript()
  local i = 1
  local tablet = getglobal(string.format("Tablet20DetachedFrame%d",i))
  while (tablet) and i<100 do
    if tablet.owner ~= nil and tablet.owner == "sepgp_loot" then
      sepgp:make_escable(string.format("Tablet20DetachedFrame%d",i),"add")
      tablet:SetScript("OnHide",nil)
      tablet:SetScript("OnHide",function()
          if not T:IsAttached("sepgp_loot") then
            T:Attach("sepgp_loot")
            this:SetScript("OnHide",nil)
          end
        end)
      break
    end    
    i = i+1
    tablet = getglobal(string.format("Tablet20DetachedFrame%d",i))
  end  
end

function sepgp_loot:Top()
  if T:IsRegistered("sepgp_loot") and (T.registry.sepgp_loot.tooltip) then
    T.registry.sepgp_loot.tooltip.scroll=0
  end  
end

function sepgp_loot:Toggle(forceShow)
  self:Top()
  if T:IsAttached("sepgp_loot") then
    T:Detach("sepgp_loot") -- show
    if (T:IsLocked("sepgp_loot")) then
      T:ToggleLocked("sepgp_loot")
    end
    self:setHideScript()
  else
    if (forceShow) then
      sepgp_loot:Refresh()
    else
      T:Attach("sepgp_loot") -- hide
    end
  end  
end

function sepgp_loot:BuildLootTable()
  table.sort(sepgp_looted, function(a,b)
    if (a[1] ~= b[1]) then return a[1] > b[1]
    else return a[2] > b[2] end
  end)
  return sepgp_looted
end

function sepgp_loot:OnClickItem(data,row)
  print('onClickItem')
  print(data[1][1])
end

function sepgp_loot:OnTooltipUpdate()
  local cat = T:AddCategory(
      "columns", 5,
      "text",  C:Orange(L["Time"]),   "child_textR",    1, "child_textG",    1, "child_textB",    1, "child_justify",  "LEFT",
      "text2", C:Orange(L["Item"]),     "child_text2R",   1, "child_text2G",   1, "child_text2B",   0, "child_justify2", "LEFT",
      "text3", C:Orange(L["Binds"]),  "child_text3R",   0, "child_text3G",   1, "child_text3B",   0, "child_justify3", "CENTER",
      "text4", C:Orange(L["Looter"]),  "child_text4R",   0, "child_text4G",   1, "child_text4B",   0, "child_justify4", "RIGHT",
      "text5", C:Orange(L["GP Action"]),  "child_text5R",   0, "child_text5G",   1, "child_text5B",   0, "child_justify5", "RIGHT"         
    )
  local t = self:BuildLootTable()
  for i = 1, table.getn(t) do
    local timestamp,player,player_color,itemLink,bind,price,off_price,action = unpack(t[i])
    cat:AddLine(
      "text", timestamp,
      "text2", itemLink,
      "text3", bind,
      "text4", player_color,
      "text5", action,
      "func", "OnClickItem", "arg1", self, "arg2", t[i]
    )
  end
end

-- GLOBALS: sepgp_saychannel,sepgp_groupbyclass,sepgp_groupbyarmor,sepgp_groupbyrole,sepgp_raidonly,sepgp_decay,sepgp_minep,sepgp_reservechannel,sepgp_main,sepgp_progress,sepgp_discount,sepgp_log,sepgp_dbver,sepgp_looted
-- GLOBALS: sepgp,sepgp_prices,sepgp_standings,sepgp_bids,sepgp_loot,sepgp_reserves,sepgp_alts,sepgp_logs
