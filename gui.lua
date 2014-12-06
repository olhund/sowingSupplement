-- Create a grid for easy positioning of guiElements
SowingSupp.hudGrid = {};
function SowingSupp.hudGrid:New(baseX, baseY, rows, columns, width, height, isVisible)
  local obj = setmetatable ( { }, { __index = self } )
  -- Create background Overlay
  obj.hudBgOverlay = createImageOverlay(Utils.getFilename("img/hud_bg.dds", SowingSupp.path));

  -- baseX / baseY = start of all other positioning
  obj.baseX = baseX;
  obj.baseY = baseY;
  obj.rows = rows;
  obj.columns = columns;
  obj.width = width;
  obj.height = height;
  obj.isVisible = isVisible;
  obj.centerX = obj.width/2;
  obj.rightX = obj.width * obj.columns;
  obj.move = false;
  obj.table = {};
  for i=1, (obj.rows * obj.columns) do
    obj.table[i] = {};
  end;

  self.offsetY = 0;
  local count = 1;
  for row=1, obj.rows do
    local offsetX = 0;
    for column=1, obj.columns do
      obj.table[count].x = obj.baseX + offsetX;
      obj.table[count].y = obj.baseY + self.offsetY;
      offsetX = offsetX + obj.width;
      count = count + 1;
    end;
    self.offsetY = self.offsetY + obj.height;
  end;

  return obj;
end;

-- Update grid
function SowingSupp.hudGrid:changeGrid( baseX, baseY, rows, columns, width, height, isVisible)
  for k,v in pairs(self.table) do self.table[k]=nil end

  -- baseX / baseY = start of all other positioning
  self.baseX = baseX or self.baseX;
  self.baseY = baseY or self.baseY;
  self.rows = rows or self.rows;
  self.columns = columns or self.columns;
  self.width = width or self.width;
  self.height = height or self.height;
  self.isVisible = isVisible or self.isVisible;
  self.centerX = self.width/2;
  self.rightX = self.width * self.columns;
  self.table = {};
  for i=1, (self.rows * self.columns) do
    self.table[i] = {};
  end;

  self.offsetY = 0;
  local count = 1;
  for row=1, self.rows do
    local offsetX = 0;
    for column=1, self.columns do
      self.table[count].x = self.baseX + offsetX;
      self.table[count].y = self.baseY + self.offsetY;
      offsetX = offsetX + self.width;
      count = count + 1;
    end;
    self.offsetY = self.offsetY + self.height;
  end;
    --return self;
end;


-- Create object "guiElement"
SowingSupp.guiElement = {};
function SowingSupp.guiElement:New ( gridPos, functionToCall, parameter1, parameter2, style, label, value, isVisible, graphic, textSize)
	local obj = setmetatable ( { }, { __index = self } )
	obj.gridPos = gridPos;
	obj.functionToCall = functionToCall;
	obj.parameter1 = parameter1;
	obj.parameter2 = parameter2;
	obj.style = style;
	obj.label = label;
	obj.value = value;
	obj.isVisible = isVisible;
	obj.textSize = textSize;
	if graphic ~= nil then
		obj.graphic = createImageOverlay(Utils.getFilename("img/"..graphic, SowingSupp.path));
	end;
	if obj.functionToCall ~= nil then
		obj.buttonSet = SowingSupp.buttonSet:New( obj.functionToCall, obj.style, obj.gridPos )
	end;
	return obj;
end;

-- Create object "buttonSet"
SowingSupp.buttonSet = {}
function SowingSupp.buttonSet:New ( functionToCall, style, gridPos )
  local obj = setmetatable ( { }, { __index = self } )
  obj.button1IsActive = true;
  obj.button2IsActive = true;

  -- Create button graphics
  obj.overlays = {};
  if style == "plusminus" then -- plus minus
    obj.overlays.overlayMinus = createImageOverlay(Utils.getFilename("img/button_Minus.dds", SowingSupp.path));
    obj.overlays.overlayPlus = createImageOverlay(Utils.getFilename("img/button_Plus.dds", SowingSupp.path));

  elseif style == "arrow" then -- vor zurück
    obj.overlays.overlayMinus = createImageOverlay(Utils.getFilename("img/button_Left.dds", SowingSupp.path));
    obj.overlays.overlayPlus = createImageOverlay(Utils.getFilename("img/button_Right.dds", SowingSupp.path));

  elseif style == "toggle" then -- toggle
    obj.overlays.overlayToggleOff = createImageOverlay(Utils.getFilename("img/button_Off.dds", SowingSupp.path));
    obj.overlays.overlayToggleOn = createImageOverlay(Utils.getFilename("img/button_On.dds", SowingSupp.path));
  elseif style == "toggleSound" then -- toggle
    obj.overlays.overlayToggleSndOff = createImageOverlay(Utils.getFilename("img/button_SoundOff.dds", SowingSupp.path));
    obj.overlays.overlayToggleSndOn = createImageOverlay(Utils.getFilename("img/button_SoundOn.dds", SowingSupp.path));
  elseif style == "toggleModul" then -- toggle
    obj.overlays.overlayToggleModulOff = createImageOverlay(Utils.getFilename("img/button_ModulOff.dds", SowingSupp.path));
    obj.overlays.overlayToggleModulOn = createImageOverlay(Utils.getFilename("img/button_ModulOn.dds", SowingSupp.path));
  elseif style == "titleBar" then -- toggle
    obj.overlays.overlayRowBg = createImageOverlay(Utils.getFilename("img/row_bg.dds", SowingSupp.path));
    obj.overlays.overlayConfig = createImageOverlay(Utils.getFilename("img/button_Config.dds", SowingSupp.path));
    obj.overlays.overlayClose = createImageOverlay(Utils.getFilename("img/button_Close.dds", SowingSupp.path));
  end;

  -- Create button click areas
  obj.areas = { plus = {}, minus = {}, toggle = {}, titleBar = {}, titleBarMove = {}};
  local guiElementHeight = g_currentMission.hudSelectionBackgroundOverlay.height;
  if style == "plusminus" or style == "arrow" then -- plus minus & arrow
    obj.areas.minus.xMin = -0.0145;
    obj.areas.minus.xMax = -0.0045;
    obj.areas.minus.yMin = 0.004;
    obj.areas.minus.yMax = 0.018;
    obj.areas.plus.xMin = 0.005;
    obj.areas.plus.xMax = 0.015;
    obj.areas.plus.yMin = obj.areas.minus.yMin;
    obj.areas.plus.yMax = obj.areas.minus.yMax;
  elseif style == "toggle" then
    obj.areas.toggle.xMin = -0.009;
    obj.areas.toggle.xMax = 0.01;
    obj.areas.toggle.yMin = 0.005;
    obj.areas.toggle.yMax = 0.033;
  elseif style == "toggleSound" then
    local iconWidth = 1.2 * guiElementHeight / g_screenAspectRatio;
    obj.areas.toggle.xMin = -iconWidth/2;---0.009;
    obj.areas.toggle.xMax =  iconWidth/2;--0.01;
    obj.areas.toggle.yMin = .2 * guiElementHeight;--0.005;
    obj.areas.toggle.yMax = 1.25 * guiElementHeight;--0.033;
  elseif style == "toggleModul" then
    local iconWidth = .9 * guiElementHeight / g_screenAspectRatio;
    obj.areas.toggle.xMin = -iconWidth/2;---0.009;
    obj.areas.toggle.xMax = iconWidth/2;--0.01;
    obj.areas.toggle.yMin = .1 * guiElementHeight;--0.005;
    obj.areas.toggle.yMax = .9 * guiElementHeight;--0.033;
  elseif style == "titleBar" then
    local iconWidth = .8 * guiElementHeight / g_screenAspectRatio;
		local offsetIcon = guiElementHeight * 0.1;
    obj.areas.titleBar.xMin = offsetIcon;--0.005;
    obj.areas.titleBar.xMax = offsetIcon + iconWidth;--0.015;
    obj.areas.titleBar.yMin = .15 * guiElementHeight;--0.004;
    obj.areas.titleBar.yMax = .85 * guiElementHeight;--0.018;
    obj.areas.titleBarMove.xMin = iconWidth + 3 * offsetIcon;--0.025;
    obj.areas.titleBarMove.xMax = iconWidth + 3 * offsetIcon;--0.1;
    obj.areas.titleBarMove.yMin =  .1 * guiElementHeight;--0.004;
    obj.areas.titleBarMove.yMax = .9 * guiElementHeight;--0.018;
  end;
  return obj
end;

--Render
function SowingSupp.hudGrid:render()
  if self.isVisible then
    renderOverlay(self.hudBgOverlay, self.baseX, self.baseY, (self.columns * self.width), (self.rows * self.height));
    -- Render all guiElements with own render()
    for k, guiElement in pairs(self.elements) do
      guiElement:render(self);
    end;
  end;
end;

function SowingSupp.guiElement:render(grid)
  if self.isVisible then
    setTextColor(1,1,1,1);
    setTextBold(false);
	local guiElementHeight = g_currentMission.hudSelectionBackgroundOverlay.height;

    if self.style == "plusminus" or self.style == "arrow" then
      setTextAlignment(RenderText.ALIGN_CENTER);
      renderText((grid.table[self.gridPos].x + grid.centerX), (grid.table[self.gridPos].y + 0.045), 0.01, tostring(self.label));
      renderText((grid.table[self.gridPos].x + grid.centerX), (grid.table[self.gridPos].y + 0.026), 0.018, tostring(self.value));
      if not self.buttonSet.button1IsActive then
        setOverlayColor(self.buttonSet.overlays.overlayMinus, 1, 1, 1, 0.1);
      else
        setOverlayColor(self.buttonSet.overlays.overlayMinus, 1, 1, 1, 1);
      end;
      renderOverlay(self.buttonSet.overlays.overlayMinus, grid.table[self.gridPos].x + grid.centerX - 0.015, grid.table[self.gridPos].y + 0.005, 0.01, 0.015);
      if not self.buttonSet.button2IsActive then
        setOverlayColor(self.buttonSet.overlays.overlayPlus, 1, 1, 1, 0.1);
      else
        setOverlayColor(self.buttonSet.overlays.overlayPlus, 1, 1, 1, 1);
        end;
      renderOverlay(self.buttonSet.overlays.overlayPlus, grid.table[self.gridPos].x + grid.centerX + 0.005, grid.table[self.gridPos].y + 0.005, 0.01, 0.015);

    -- elseif self.style == "toggle" then
      -- setTextAlignment(RenderText.ALIGN_CENTER);
      -- renderText((grid.table[self.gridPos].x + grid.centerX), (grid.table[self.gridPos].y + 0.045), 0.01, tostring(self.label));
      -- if self.value then
        -- renderOverlay(self.buttonSet.overlays.overlayToggleOn, grid.table[self.gridPos].x + grid.centerX - 0.01, grid.table[self.gridPos].y + 0.005, 0.02, 0.03)
      -- else
        -- renderOverlay(self.buttonSet.overlays.overlayToggleOff, grid.table[self.gridPos].x + grid.centerX - 0.01, grid.table[self.gridPos].y + 0.005, 0.02, 0.03);
      -- end;
    elseif self.style == "toggleSound" then
      setTextAlignment(RenderText.ALIGN_CENTER);
	  local iconHeight = 1.2 * guiElementHeight;
	  local iconWidth = iconHeight / g_screenAspectRatio;
	  local yOffsetIcon = guiElementHeight * 0.15;
	  local yOffsetText = yOffsetIcon + 1.1 * iconHeight;
      renderText((grid.table[self.gridPos].x + grid.centerX), (grid.table[self.gridPos].y + yOffsetText), self.textSize, tostring(self.label));
      if self.value then
        renderOverlay(self.buttonSet.overlays.overlayToggleSndOn, grid.table[self.gridPos].x + grid.centerX - iconWidth/2, grid.table[self.gridPos].y + yOffsetIcon, iconWidth, iconHeight);
      else
        renderOverlay(self.buttonSet.overlays.overlayToggleSndOff, grid.table[self.gridPos].x + grid.centerX - iconWidth/2, grid.table[self.gridPos].y + yOffsetIcon, iconWidth, iconHeight)
      end;
	  
    elseif self.style == "toggleModul" then
      setTextAlignment(RenderText.ALIGN_CENTER);
	  local iconHeight = .9 * guiElementHeight;
	  local iconWidth = iconHeight / g_screenAspectRatio;
	  local yOffsetIcon = guiElementHeight * .76;--0.02;
      if self.value then
        renderOverlay(self.buttonSet.overlays.overlayToggleModulOn, grid.table[self.gridPos].x + grid.centerX - iconWidth/2, grid.table[self.gridPos].y + yOffsetIcon * guiElementHeight, iconWidth, iconHeight);
      else
        renderOverlay(self.buttonSet.overlays.overlayToggleModulOff, grid.table[self.gridPos].x + grid.centerX - iconWidth/2, grid.table[self.gridPos].y + yOffsetIcon * guiElementHeight, iconWidth, iconHeight);
      end;

    -- elseif self.style == "info" then
      -- setTextAlignment(RenderText.ALIGN_LEFT);
      -- if self.graphic ~= nil then
        -- renderOverlay(self.graphic, grid.table[self.gridPos].x + 0.004, grid.table[self.gridPos].y + 0.004, 0.012, 0.018);
        -- renderText((grid.table[self.gridPos].x + 0.018), (grid.table[self.gridPos].y + 0.006), self.textSize, tostring(self.value));
      -- else
        -- renderText((grid.table[self.gridPos].x + 0.004), (grid.table[self.gridPos].y + 0.006), self.textSize, tostring(self.value));
      -- end;
	
	-- elseif self.style == "infoTEST" then
      -- setTextAlignment(RenderText.ALIGN_LEFT);
      -- renderText((grid.table[self.gridPos].x), (grid.table[self.gridPos].y), self.textSize, tostring(self.value));
	  
	elseif self.style == "infoSoCoSession" then
      setTextAlignment(RenderText.ALIGN_LEFT);
	  local iconHeight = .8 * guiElementHeight;
	  local iconWidth = iconHeight / g_screenAspectRatio;
	  local offsetIcon = guiElementHeight * 0.05;
      renderOverlay(self.graphic, grid.table[self.gridPos].x + offsetIcon, grid.table[self.gridPos].y + offsetIcon, iconWidth, iconHeight);
	  local xOffsetText = guiElementHeight * .84;
	  local yOffsetText = guiElementHeight * .28;--yOffsetText fillLevelTextSize
      renderText((grid.table[self.gridPos].x + xOffsetText), (grid.table[self.gridPos].y + yOffsetText), self.textSize, tostring(self.value));
	
	elseif self.style == "infoSoCoTotal" then
      setTextAlignment(RenderText.ALIGN_LEFT);
	  local iconHeight = .8 * guiElementHeight;
	  local iconWidth = iconHeight / g_screenAspectRatio;
	  local offsetIcon = guiElementHeight * 0.05;
      renderOverlay(self.graphic, grid.table[self.gridPos].x + offsetIcon, grid.table[self.gridPos].y + offsetIcon, iconWidth, iconHeight);
	  local xOffsetText = guiElementHeight * .84;
	  local yOffsetText = guiElementHeight * .28;--yOffsetText fillLevelTextSize
      renderText((grid.table[self.gridPos].x + xOffsetText), (grid.table[self.gridPos].y + yOffsetText), self.textSize, tostring(self.value));
	
	elseif self.style == "infoModul" then
      setTextAlignment(RenderText.ALIGN_LEFT);
	  local offsetText = guiElementHeight * .28;--yOffsetText fillLevelTextSize
      renderText((grid.table[self.gridPos].x - offsetText), (grid.table[self.gridPos].y + offsetText), self.textSize, tostring(self.value));
	  
    elseif self.style == "titleBar" then
      renderOverlay(self.buttonSet.overlays.overlayRowBg, grid.table[self.gridPos].x, grid.table[self.gridPos].y, grid.rightX, grid.height);
      setTextAlignment(RenderText.ALIGN_CENTER);
	  local yOffsetText = guiElementHeight * 0.269;--yOffsetText missionStatusTextSize
      renderText((grid.table[self.gridPos].x + g_currentMission.hudSelectionBackgroundOverlay.width/2), (grid.table[self.gridPos].y + yOffsetText), self.textSize, tostring(self.label));
      if not self.buttonSet.button1IsActive then
        setOverlayColor(self.buttonSet.overlays.overlayConfig, 1, 1, 1, 0);
      else
        setOverlayColor(self.buttonSet.overlays.overlayConfig, 1, 1, 1, 1);
      end;
	  local iconHeight = .8 * guiElementHeight;
	  local iconWidth = iconHeight / g_screenAspectRatio;
	  local offsetIcon = guiElementHeight * 0.1;
      renderOverlay(self.buttonSet.overlays.overlayConfig, grid.table[self.gridPos].x + offsetIcon, grid.table[self.gridPos].y + offsetIcon, iconWidth, iconHeight);
      if not self.buttonSet.button2IsActive then
        setOverlayColor(self.buttonSet.overlays.overlayClose, 1, 1, 1, 0);
      else
        setOverlayColor(self.buttonSet.overlays.overlayClose, 1, 1, 1, 1);
      end;
      renderOverlay(self.buttonSet.overlays.overlayClose, grid.table[self.gridPos].x + grid.rightX - offsetIcon - iconWidth, grid.table[self.gridPos].y + offsetIcon, iconWidth, iconHeight);
    end;
  end;
end;

--Mouse Events
function SowingSupp.hudGrid:mouseEvent(vehicle, posX, posY, isDown, isUp, button)
  if self.isVisible then
    if self.move then
	  -- 
      self:changeGrid(math.min(posX,g_currentMission.hudSelectionBackgroundOverlay.x), math.min(posY, 1 - (self.rows * self.height)));
    end;
    for k, guiElement in pairs(self.elements) do
      guiElement:mouseEvent(self, vehicle, posX, posY, isDown, isUp, button);
    end;
  end;
end;

-- Create mouseEvents & call functions
function SowingSupp.guiElement:mouseEvent(grid, vehicle, posX, posY, isDown, isUp, button)
  if self.isVisible then
    local dlHudchangedJet = false;
    if self.style == "plusminus" or self.style == "arrow" then
      if isDown and button == 1 then
        if self.buttonSet.button1IsActive then
          if (grid.table[self.gridPos].x + grid.centerX + self.buttonSet.areas.minus.xMax) > posX
          and (grid.table[self.gridPos].x + grid.centerX + self.buttonSet.areas.minus.xMin) < posX
          and (grid.table[self.gridPos].y + self.buttonSet.areas.minus.yMax) > posY
          and (grid.table[self.gridPos].y + self.buttonSet.areas.minus.yMin) < posY then
            SowingSupp:modules(grid, vehicle, self, self.parameter1);
          end;
        end;
        if self.buttonSet.button2IsActive then
          if (grid.table[self.gridPos].x + grid.centerX + self.buttonSet.areas.plus.xMax) > posX
          and (grid.table[self.gridPos].x + grid.centerX + self.buttonSet.areas.plus.xMin) < posX
          and (grid.table[self.gridPos].y + self.buttonSet.areas.plus.yMax) > posY
          and (grid.table[self.gridPos].y + self.buttonSet.areas.plus.yMin) < posY then
            SowingSupp:modules(grid, vehicle, self, self.parameter2);
          end;
        end;
      end;
    elseif self.style == "toggle" or self.style == "toggleSound" or self.style == "toggleModul" then
      if isDown and button == 1 then
        if (grid.table[self.gridPos].x + grid.centerX + self.buttonSet.areas.toggle.xMax) > posX
         and (grid.table[self.gridPos].x + grid.centerX + self.buttonSet.areas.toggle.xMin) < posX
         and (grid.table[self.gridPos].y + self.buttonSet.areas.toggle.yMax) > posY
         and (grid.table[self.gridPos].y + self.buttonSet.areas.toggle.yMin < posY) then
          SowingSupp:modules(grid, vehicle, self);
        end;
      end;
    elseif self.style == "titleBar" then
      if isDown and button == 1 then
        if grid.move then
          grid.move = false;
          dlHudchangedJet = true;
					vehicle:updateGrids(math.min(posX,g_currentMission.hudSelectionBackgroundOverlay.x), math.min(posY, 1 - (grid.rows * grid.height)))
        end;
        if not dlHudchangedJet then
          if (grid.table[self.gridPos].x + grid.rightX - self.buttonSet.areas.titleBarMove.xMax) > posX
          and (grid.table[self.gridPos].x + self.buttonSet.areas.titleBarMove.xMin) < posX
          and (grid.table[self.gridPos].y + self.buttonSet.areas.titleBarMove.yMax) > posY
          and (grid.table[self.gridPos].y + self.buttonSet.areas.titleBarMove.yMin) < posY then
            grid.move = true;
						vehicle.grid2.isVisible = false;
          end;
        end;
        if self.buttonSet.button1IsActive then
          if (grid.table[self.gridPos].x + self.buttonSet.areas.titleBar.xMax) > posX
          and (grid.table[self.gridPos].x + self.buttonSet.areas.titleBar.xMin) < posX
          and (grid.table[self.gridPos].y + self.buttonSet.areas.titleBar.yMax) > posY
          and (grid.table[self.gridPos].y + self.buttonSet.areas.titleBar.yMin) < posY then
            SowingSupp:modules(grid, vehicle, self, self.parameter1);
          end;
        end;
        if self.buttonSet.button2IsActive then
					local guiElementHeight = g_currentMission.hudSelectionBackgroundOverlay.height;
					local iconWidth = .8 * guiElementHeight / g_screenAspectRatio;
					local offsetIcon = guiElementHeight * 0.1;
          if (grid.table[self.gridPos].x + grid.rightX - offsetIcon - iconWidth + self.buttonSet.areas.titleBar.xMax) > posX
          and (grid.table[self.gridPos].x + grid.rightX - offsetIcon - iconWidth + self.buttonSet.areas.titleBar.xMin) < posX
          and (grid.table[self.gridPos].y + self.buttonSet.areas.titleBar.yMax) > posY
          and (grid.table[self.gridPos].y + self.buttonSet.areas.titleBar.yMin) < posY then
            SowingSupp:modules(grid, vehicle, self, self.parameter2);
          end;
        end;
      end;
    end;
  end;
end;
