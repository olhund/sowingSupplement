-- Create a countainer for postitioning of multiple "windows"
SowingSupp.container = {};
function SowingSupp.container:New(baseX, baseY, isVisible)
  local obj = setmetatable ( { }, { __index = self } )
  -- baseX / baseY = start of all other positioning
  obj.baseX = baseX;
  obj.baseY = baseY;
  obj.height = 0;
  obj.width = 0;
  obj.move = false;
  obj.isVisible = isVisible;
  obj.grids = {};
  return obj;
end;

function SowingSupp.container:changeContainer(baseX, baseY)
  self.baseX = baseX;
  self.baseY = baseY;
  for k, grid in pairs(self.grids) do
    grid:changeGrid(self);
  end;
end;

-- Create a grid for easy positioning of guiElements
SowingSupp.hudGrid = {};
function SowingSupp.hudGrid:New(container, offsetX, offsetY, rows, columns, width, height, isVisible, isMaster)
  local obj = setmetatable ( { }, { __index = self } )
  -- Create background Overlay
  obj.hudBgOverlay = createImageOverlay(Utils.getFilename("img/hud_bg.dds", SowingSupp.path));

  -- offsetX / offsetY = offset from container baseX / baseY
  obj.offsetX = offsetX;
  obj.offsetY = offsetY;
  obj.rows = rows;
  obj.columns = columns;
  obj.width = width;
  obj.height = height;
  obj.isVisible = isVisible;
  obj.centerX = obj.width/2;
  obj.rightX = obj.width * obj.columns;
  obj.isMaster = isMaster;
  if obj.isMaster then
    container.height = obj.rows * obj.height;
    container.width = obj.columns * obj.width;
  end;
  obj.move = false;
  obj.elements = {};
  obj.table = {};
  for i=1, (obj.rows * obj.columns) do
    obj.table[i] = {};
  end;

  self.tempOffsetY = 0;
  local count = 1;
  for row=1, obj.rows do
    local offsetX = 0;
    for column=1, obj.columns do
      obj.table[count].x = container.baseX + obj.offsetX + offsetX;
      obj.table[count].y = container.baseY + obj.offsetY + self.tempOffsetY;
      offsetX = offsetX + obj.width;
      count = count + 1;
    end;
    self.tempOffsetY = self.tempOffsetY + obj.height;
  end;

  return obj;
end;

-- Update grid
function SowingSupp.hudGrid:changeGrid( container, offsetX, offsetY, rows, columns, width, height, isVisible)
  for k,v in pairs(self.table) do self.table[k]=nil end

  -- baseX / baseY = start of all other positioning
  self.offsetX = offsetX or self.offsetX;
  self.offsetY = offsetY or self.offsetY;
  self.rows = rows or self.rows;
  self.columns = columns or self.columns;
  self.width = width or self.width;
  self.height = height or self.height;
  self.isVisible = isVisible or self.isVisible;
  self.centerX = self.width/2;
  self.rightX = self.width * self.columns;
  if self.isMaster then
    container.height = self.rows * self.height;
    container.width = self.columns * self.width;
  end;
  self.table = {};
  for i=1, (self.rows * self.columns) do
    self.table[i] = {};
  end;

  self.tempOffsetY = 0;
  local count = 1;
  for row=1, self.rows do
    local offsetX = 0;
    for column=1, self.columns do
      self.table[count].x = container.baseX + self.offsetX + offsetX;
      self.table[count].y = container.baseY + self.offsetY + self.tempOffsetY;
      offsetX = offsetX + self.width;
      count = count + 1;
    end;
    self.tempOffsetY = self.tempOffsetY + self.height;
  end;

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
	if style == "info" or style == "separator" then
    if graphic ~= nil then
		  obj.graphic = createImageOverlay(Utils.getFilename("img/"..graphic..".dds", SowingSupp.path));
	  end;
  end;
	if obj.functionToCall ~= nil then
		obj.buttonSet = SowingSupp.buttonSet:New( obj.functionToCall, obj.style, obj.gridPos, graphic )
	end;
	return obj;
end;

-- Create object "buttonSet"
SowingSupp.buttonSet = {}
function SowingSupp.buttonSet:New ( functionToCall, style, gridPos, graphic )
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
    obj.overlays.overlayToggleOff = createImageOverlay(Utils.getFilename("img/2_"..graphic..".dds", SowingSupp.path));
    obj.overlays.overlayToggleOn = createImageOverlay(Utils.getFilename("img/1_"..graphic..".dds", SowingSupp.path));

  elseif style == "option" then -- option on/off
    obj.overlays.overlayToggleOptionOff = createImageOverlay(Utils.getFilename("img/2_"..graphic..".dds", SowingSupp.path));
    obj.overlays.overlayToggleOptionOn = createImageOverlay(Utils.getFilename("img/1_"..graphic..".dds", SowingSupp.path));

  elseif style == "titleBar" then -- title Bar
    obj.overlays.overlayRowBg = createImageOverlay(Utils.getFilename("img/row_bg.dds", SowingSupp.path));
    obj.overlays.overlayConfig = createImageOverlay(Utils.getFilename("img/button_Config.dds", SowingSupp.path));
    obj.overlays.overlayClose = createImageOverlay(Utils.getFilename("img/button_Close.dds", SowingSupp.path));
  end;

  -- Create button click areas
  obj.areas = { plus = {}, minus = {}, toggle = {}, titleBar = {}, titleBarMove = {}};
  local baseHeight = g_currentMission.hudSelectionBackgroundOverlay.height;
  local baseWidth = baseHeight / g_screenAspectRatio;
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
    local iconWidth = 1.2 * baseWidth;
    obj.areas.toggle.xMin = -iconWidth/2;---0.009;
    obj.areas.toggle.xMax =  iconWidth/2;--0.01;
    obj.areas.toggle.yMin = .2 * baseHeight;--0.005;
    obj.areas.toggle.yMax = 1.25 * baseHeight;--0.033;
  elseif style == "option" then
    local iconWidth = .8 * baseWidth;
    local offsetIcon = baseHeight * 0.1;
    obj.areas.toggle.xMin = offsetIcon;---0.009;
    obj.areas.toggle.xMax = offsetIcon + iconWidth;--0.01;
    obj.areas.toggle.yMin = .1 * baseHeight;--0.005;
    obj.areas.toggle.yMax = .8 * baseHeight;--0.033;
  elseif style == "titleBar" then
    local iconWidth = .6 * baseWidth;
		local offsetIcon = baseHeight * 0.2;
    obj.areas.titleBar.xMin = offsetIcon;--0.005;
    obj.areas.titleBar.xMax = offsetIcon + iconWidth;--0.015;
    obj.areas.titleBar.yMin = .15 * baseHeight;--0.004;
    obj.areas.titleBar.yMax = .85 * baseHeight;--0.018;
    obj.areas.titleBarMove.xMin = iconWidth + 3 * offsetIcon;--0.025;
    obj.areas.titleBarMove.xMax = iconWidth + 3 * offsetIcon;--0.1;
    obj.areas.titleBarMove.yMin =  .1 * baseHeight;--0.004;
    obj.areas.titleBarMove.yMax = .9 * baseHeight;--0.018;
  end;
  return obj
end;

--Render
function SowingSupp.container:render()
  if self.isVisible then
    -- Render all grids with own render()
    for k, grid in pairs(self.grids) do
      grid:render(self);
    end;
  end;
end;

function SowingSupp.hudGrid:render(container)
  if self.isVisible then
    renderOverlay(self.hudBgOverlay, container.baseX + self.offsetX, container.baseY + self.offsetY, (self.columns * self.width), (self.rows * self.height));
    -- Render all guiElements with own render()
    for k, guiElement in pairs(self.elements) do
      guiElement:render(self, container);
    end;
  end;
end;

function SowingSupp.guiElement:render(grid, container)
  if self.isVisible then
    setTextColor(1,1,1,1);
    setTextBold(false);
    local baseHeight = g_currentMission.hudSelectionBackgroundOverlay.height;

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

    elseif self.style == "toggle" then
      setTextAlignment(RenderText.ALIGN_CENTER);
      local iconHeight = 1.2 * baseHeight;
      local iconWidth = iconHeight / g_screenAspectRatio;
      local yOffsetIcon = baseHeight * 0.15;
      local yOffsetText = yOffsetIcon + 1.1 * iconHeight;
      renderText((grid.table[self.gridPos].x + grid.centerX), (grid.table[self.gridPos].y + yOffsetText), self.textSize, tostring(self.label));
      if self.value then
        renderOverlay(self.buttonSet.overlays.overlayToggleOn, grid.table[self.gridPos].x + grid.centerX - iconWidth/2, grid.table[self.gridPos].y + yOffsetIcon, iconWidth, iconHeight);
      else
        renderOverlay(self.buttonSet.overlays.overlayToggleOff, grid.table[self.gridPos].x + grid.centerX - iconWidth/2, grid.table[self.gridPos].y + yOffsetIcon, iconWidth, iconHeight)
      end;

    elseif self.style == "option" then
      local iconHeight = .8 * baseHeight;
      local iconWidth = iconHeight / g_screenAspectRatio;
      local offsetIcon = baseHeight * 0.11;
      if self.value then
        renderOverlay(self.buttonSet.overlays.overlayToggleOptionOn, grid.table[self.gridPos].x + offsetIcon, grid.table[self.gridPos].y + offsetIcon, iconWidth, iconHeight);
      else
        renderOverlay(self.buttonSet.overlays.overlayToggleOptionOff, grid.table[self.gridPos].x + offsetIcon, grid.table[self.gridPos].y + offsetIcon, iconWidth, iconHeight);
      end;
      setTextAlignment(RenderText.ALIGN_LEFT);
      local xOffsetText =  iconWidth + 3 * offsetIcon;--baseHeight * .84;
      local yOffsetText = baseHeight * .28;--yOffsetText fillLevelTextSize
      renderText((grid.table[self.gridPos].x + xOffsetText), (grid.table[self.gridPos].y + yOffsetText), self.textSize, tostring(self.label));

    elseif self.style == "info" then
      setTextAlignment(RenderText.ALIGN_LEFT);
      local iconHeight = .8 * baseHeight;
      local iconWidth = iconHeight / g_screenAspectRatio;
      local offsetIcon = baseHeight * 0.05;
      renderOverlay(self.graphic, grid.table[self.gridPos].x + offsetIcon, grid.table[self.gridPos].y + offsetIcon, iconWidth, iconHeight);
      local xOffsetText =  iconWidth + 3 * offsetIcon;--baseHeight * .84;
      local yOffsetText = baseHeight * .28;--yOffsetText fillLevelTextSize
      renderText((grid.table[self.gridPos].x + xOffsetText), (grid.table[self.gridPos].y + yOffsetText), self.textSize, tostring(self.value));

    elseif self.style == "separator" then
      local offsetSep = baseHeight * 0.1;
      --renderOverlay(self.graphic, grid.table[self.gridPos].x + offsetSep, grid.table[self.gridPos].y, sepWidth - offsetSep, 0.01);
      setOverlayColor(self.graphic, 1, 1, 1, 0.25);
      renderOverlay(self.graphic, container.baseX + grid.offsetX + offsetSep, grid.table[self.gridPos].y, grid.columns * grid.width - (2*offsetSep), 0.001);

    elseif self.style == "titleBar" then
      setOverlayColor(self.buttonSet.overlays.overlayRowBg, .01, .01, .01, 1);
      renderOverlay(self.buttonSet.overlays.overlayRowBg, grid.table[self.gridPos].x, grid.table[self.gridPos].y, grid.rightX, grid.height);
      setTextAlignment(RenderText.ALIGN_CENTER);
      local yOffsetText = baseHeight * 0.269;--yOffsetText missionStatusTextSize
      renderText((grid.table[self.gridPos].x + g_currentMission.hudSelectionBackgroundOverlay.width/2), (grid.table[self.gridPos].y + yOffsetText), self.textSize, tostring(self.label));
      if not self.buttonSet.button1IsActive then
        setOverlayColor(self.buttonSet.overlays.overlayConfig, 1, 1, 1, 0);
      else
        setOverlayColor(self.buttonSet.overlays.overlayConfig, 1, 1, 1, 1);
      end;
      local iconHeight = .6 * baseHeight;
      local iconWidth = iconHeight / g_screenAspectRatio;
      local offsetIcon = baseHeight * 0.2;
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
function SowingSupp.container:mouseEvent(vehicle, posX, posY, isDown, isUp, button)
  if self.isVisible then
    if self.move then
      self:changeContainer(math.min(posX,g_currentMission.hudSelectionBackgroundOverlay.x), math.min(posY, 1 - self.height));
    end;
    for k, grid in pairs(self.grids) do
      grid:mouseEvent(self, vehicle, posX, posY, isDown, isUp, button);
    end;
  end;
end;

function SowingSupp.hudGrid:mouseEvent(container, vehicle, posX, posY, isDown, isUp, button)
  if self.isVisible then
    for k, guiElement in pairs(self.elements) do
      guiElement:mouseEvent(self, container, vehicle, posX, posY, isDown, isUp, button);
    end;
  end;
end;

-- Create mouseEvents & call functions
function SowingSupp.guiElement:mouseEvent(grid, container, vehicle, posX, posY, isDown, isUp, button)
  if self.isVisible then
    local dlHudchangedJet = false;
    if self.style == "plusminus" or self.style == "arrow" then
      if isDown and button == 1 then
        if self.buttonSet.button1IsActive then
          if (grid.table[self.gridPos].x + grid.centerX + self.buttonSet.areas.minus.xMax) > posX
          and (grid.table[self.gridPos].x + grid.centerX + self.buttonSet.areas.minus.xMin) < posX
          and (grid.table[self.gridPos].y + self.buttonSet.areas.minus.yMax) > posY
          and (grid.table[self.gridPos].y + self.buttonSet.areas.minus.yMin) < posY then
            SowingSupp:modules(grid, container, vehicle, self, self.parameter1);
          end;
        end;
        if self.buttonSet.button2IsActive then
          if (grid.table[self.gridPos].x + grid.centerX + self.buttonSet.areas.plus.xMax) > posX
          and (grid.table[self.gridPos].x + grid.centerX + self.buttonSet.areas.plus.xMin) < posX
          and (grid.table[self.gridPos].y + self.buttonSet.areas.plus.yMax) > posY
          and (grid.table[self.gridPos].y + self.buttonSet.areas.plus.yMin) < posY then
            SowingSupp:modules(grid, container, vehicle, self, self.parameter2);
          end;
        end;
      end;
    elseif self.style == "toggle" then
      if isDown and button == 1 then
        if (grid.table[self.gridPos].x + grid.centerX + self.buttonSet.areas.toggle.xMax) > posX
         and (grid.table[self.gridPos].x + grid.centerX + self.buttonSet.areas.toggle.xMin) < posX
         and (grid.table[self.gridPos].y + self.buttonSet.areas.toggle.yMax) > posY
         and (grid.table[self.gridPos].y + self.buttonSet.areas.toggle.yMin < posY) then
          SowingSupp:modules(grid, container, vehicle, self);
        end;
      end;
    elseif self.style == "option" then
      if isDown and button == 1 then
        if (grid.table[self.gridPos].x + self.buttonSet.areas.toggle.xMax) > posX
          and (grid.table[self.gridPos].x + self.buttonSet.areas.toggle.xMin) < posX
          and (grid.table[self.gridPos].y + self.buttonSet.areas.toggle.yMax) > posY
          and (grid.table[self.gridPos].y + self.buttonSet.areas.toggle.yMin < posY) then
          SowingSupp:modules(grid, container, vehicle, self);
        end;
      end;
    elseif self.style == "titleBar" then
      if isDown and button == 1 then
        if container.move then
          container.move = false;
          dlHudchangedJet = true;
        end;
        if not dlHudchangedJet then
          if (grid.table[self.gridPos].x + grid.rightX - self.buttonSet.areas.titleBarMove.xMax) > posX
          and (grid.table[self.gridPos].x + self.buttonSet.areas.titleBarMove.xMin) < posX
          and (grid.table[self.gridPos].y + self.buttonSet.areas.titleBarMove.yMax) > posY
          and (grid.table[self.gridPos].y + self.buttonSet.areas.titleBarMove.yMin) < posY then
            container.move = true;
          end;
        end;
        if self.buttonSet.button1IsActive then
          if (grid.table[self.gridPos].x + self.buttonSet.areas.titleBar.xMax) > posX
          and (grid.table[self.gridPos].x + self.buttonSet.areas.titleBar.xMin) < posX
          and (grid.table[self.gridPos].y + self.buttonSet.areas.titleBar.yMax) > posY
          and (grid.table[self.gridPos].y + self.buttonSet.areas.titleBar.yMin) < posY then
            SowingSupp:modules(grid, container, vehicle, self, self.parameter1);
          end;
        end;
        if self.buttonSet.button2IsActive then
					local baseHeight = g_currentMission.hudSelectionBackgroundOverlay.height;
					local iconWidth = .8 * baseHeight / g_screenAspectRatio;
					local offsetIcon = baseHeight * 0.1;
          if (grid.table[self.gridPos].x + grid.rightX - offsetIcon - iconWidth + self.buttonSet.areas.titleBar.xMax) > posX
          and (grid.table[self.gridPos].x + grid.rightX - offsetIcon - iconWidth + self.buttonSet.areas.titleBar.xMin) < posX
          and (grid.table[self.gridPos].y + self.buttonSet.areas.titleBar.yMax) > posY
          and (grid.table[self.gridPos].y + self.buttonSet.areas.titleBar.yMin) < posY then
            SowingSupp:modules(grid, container, vehicle, self, self.parameter2);
          end;
        end;
      end;
    end;
  end;
end;
