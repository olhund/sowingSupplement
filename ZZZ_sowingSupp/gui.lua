-- Create a grid for easy positioning of guiElements
-- v0.02
function SowingSupp:initGUI()
  SowingSupp.grid = {};
  SowingSupp.grid.rows = 8;
  SowingSupp.grid.colums = 3;
  -- baseX / baseY = start of all other positioning
  SowingSupp.grid.baseX = g_currentMission.weatherTimeBackgroundOverlay.x;--g_currentMission.hudSelectionBackgroundOverlay.x;--0.8265;
  SowingSupp.grid.baseY =  g_currentMission.weatherTimeBackgroundOverlay.y - g_currentMission.hudSelectionBackgroundOverlay.height * SowingSupp.grid.rows;--g_currentMission.hudSelectionBackgroundOverlay.y + g_currentMission.hudSelectionBackgroundOverlay.height + g_currentMission.hudBackgroundOverlay.height;--0.1875;
  
  SowingSupp.grid.width = (g_currentMission.weatherTimeBackgroundOverlay.width + g_currentMission.moneyBackgroundOverlay.width)/3;--g_currentMission.hudSelectionBackgroundOverlay.width/3;--0.058;
  SowingSupp.grid.height = g_currentMission.hudSelectionBackgroundOverlay.height;--0.03;
  for i=1, (SowingSupp.grid.rows * SowingSupp.grid.colums) do
    SowingSupp.grid[i] = {};
  end;

  SowingSupp.grid[1].x = SowingSupp.grid.baseX;
  SowingSupp.grid[1].y = SowingSupp.grid.baseY;
  SowingSupp.grid[2].x = SowingSupp.grid.baseX + SowingSupp.grid.width;
  SowingSupp.grid[2].y = SowingSupp.grid.baseY;
  SowingSupp.grid[3].x = SowingSupp.grid.baseX + (SowingSupp.grid.width * 2);
  SowingSupp.grid[3].y = SowingSupp.grid.baseY;

  SowingSupp.grid[4].x = SowingSupp.grid.baseX;
  SowingSupp.grid[4].y = SowingSupp.grid.baseY + SowingSupp.grid.height;
  SowingSupp.grid[5].x = SowingSupp.grid.baseX + SowingSupp.grid.width;
  SowingSupp.grid[5].y = SowingSupp.grid.baseY + SowingSupp.grid.height;
  SowingSupp.grid[6].x = SowingSupp.grid.baseX + (SowingSupp.grid.width * 2);
  SowingSupp.grid[6].y = SowingSupp.grid.baseY + SowingSupp.grid.height;

  SowingSupp.grid[7].x = SowingSupp.grid.baseX;
  SowingSupp.grid[7].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 2);
  SowingSupp.grid[8].x = SowingSupp.grid.baseX + SowingSupp.grid.width;
  SowingSupp.grid[8].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 2);
  SowingSupp.grid[9].x = SowingSupp.grid.baseX + (SowingSupp.grid.width * 2);
  SowingSupp.grid[9].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 2);

  SowingSupp.grid[10].x = SowingSupp.grid.baseX;
  SowingSupp.grid[10].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 3);
  SowingSupp.grid[11].x = SowingSupp.grid.baseX + SowingSupp.grid.width;
  SowingSupp.grid[11].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 3);
  SowingSupp.grid[12].x = SowingSupp.grid.baseX + (SowingSupp.grid.width * 2);
  SowingSupp.grid[12].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 3);

  SowingSupp.grid[13].x = SowingSupp.grid.baseX;
  SowingSupp.grid[13].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 4);
  SowingSupp.grid[14].x = SowingSupp.grid.baseX + SowingSupp.grid.width;
  SowingSupp.grid[14].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 4);
  SowingSupp.grid[15].x = SowingSupp.grid.baseX + (SowingSupp.grid.width * 2);
  SowingSupp.grid[15].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 4);

  SowingSupp.grid[16].x = SowingSupp.grid.baseX;
  SowingSupp.grid[16].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 5);
  SowingSupp.grid[17].x = SowingSupp.grid.baseX + SowingSupp.grid.width;
  SowingSupp.grid[17].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 5);
  SowingSupp.grid[18].x = SowingSupp.grid.baseX + (SowingSupp.grid.width * 2);
  SowingSupp.grid[18].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 5);

  SowingSupp.grid[19].x = SowingSupp.grid.baseX;
  SowingSupp.grid[19].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 6);
  SowingSupp.grid[20].x = SowingSupp.grid.baseX + SowingSupp.grid.width;
  SowingSupp.grid[20].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 6);
  SowingSupp.grid[21].x = SowingSupp.grid.baseX + (SowingSupp.grid.width * 2);
  SowingSupp.grid[21].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 6);

  SowingSupp.grid[22].x = SowingSupp.grid.baseX;
  SowingSupp.grid[22].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 7);
  SowingSupp.grid[23].x = SowingSupp.grid.baseX + SowingSupp.grid.width;
  SowingSupp.grid[23].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 7);
  SowingSupp.grid[24].x = SowingSupp.grid.baseX + (SowingSupp.grid.width * 2);
  SowingSupp.grid[24].y = SowingSupp.grid.baseY + (SowingSupp.grid.height * 7);
  -- Create background
  SowingSupp.hudBgOverlay2 = Overlay:new("hudBgOverlay2", Utils.getFilename("img/hud_bg.dds", SowingSupp.path), SowingSupp.grid.baseX, SowingSupp.grid.baseY, (SowingSupp.grid[2].x - SowingSupp.grid.baseX) * 3, (SowingSupp.grid[7].y - SowingSupp.grid.baseY) * 4);

  SowingSupp.snd_click = createSample("snd_click");
  loadSample(SowingSupp.snd_click, Utils.getFilename("snd/snd_click.wav", SowingSupp.path), false);

  return self;

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
	print("value: "..tostring(value))
	obj.isVisible = isVisible;
	obj.textSize = textSize;
	if graphic ~= nil then
		local overlayWidth = g_currentMission.hudSelectionBackgroundOverlay.width * .086434573;--0.015;
		local overlayHeight = g_currentMission.hudSelectionBackgroundOverlay.height * .57744362;--0.015;
		local posOffset = g_currentMission.hudSelectionBackgroundOverlay.height * 0.153984962406015;--0.004
		obj.graphic = Overlay:new("overlayGraphic", Utils.getFilename("img/"..graphic, SowingSupp.path), SowingSupp.grid[gridPos].x + posOffset, SowingSupp.grid[gridPos].y + posOffset, overlayWidth, overlayHeight);
	end;
	if obj.functionToCall ~= nil then
		obj.buttonSet = SowingSupp.buttonSet:New(obj.functionToCall, obj.style, obj.gridPos)
	end;
	return obj;
end;

-- Create object "buttonSet"
SowingSupp.buttonSet = {}
function SowingSupp.buttonSet:New ( functionToCall, style, gridPos)
	local obj = setmetatable ( { }, { __index = self } )
	obj.minusIsActive = true;
	obj.plusIsActive = true;

	-- Position graphics from center
	local centerX = SowingSupp.grid.width/2;

	-- Create button graphics
	obj.overlays = {};
	if style == "plusminus" then -- plus minus
		obj.overlays.overlayMinus = Overlay:new("overlayMinus", Utils.getFilename("img/button_Minus.dds", SowingSupp.path), SowingSupp.grid[gridPos].x + centerX - 0.015, SowingSupp.grid[gridPos].y + 0.005, 0.01, 0.015);
		obj.overlays.overlayMinusInactive = Overlay:new("overlayMinusInactive", Utils.getFilename("img/button_Minus_inactive.dds", SowingSupp.path), SowingSupp.grid[gridPos].x + centerX - 0.015, SowingSupp.grid[gridPos].y + 0.005, 0.01, 0.015);
		obj.overlays.overlayPlus = Overlay:new("overlayPlus", Utils.getFilename("img/button_Plus.dds", SowingSupp.path), SowingSupp.grid[gridPos].x + centerX + 0.005, SowingSupp.grid[gridPos].y + 0.005, 0.01, 0.015);
		obj.overlays.overlayPlusInactive = Overlay:new("overlayPlusInactive", Utils.getFilename("img/button_Plus_inactive.dds", SowingSupp.path), SowingSupp.grid[gridPos].x + centerX + 0.005, SowingSupp.grid[gridPos].y + 0.005, 0.01, 0.015);

	elseif style == "arrow" then -- vor zurück
		obj.overlays.overlayMinus = Overlay:new("overlayMinus", Utils.getFilename("img/button_Left.dds", SowingSupp.path), SowingSupp.grid[gridPos].x + centerX - 0.015, SowingSupp.grid[gridPos].y + 0.005, 0.01, 0.015);
		obj.overlays.overlayMinusInactive = Overlay:new("overlayMinusInactive", Utils.getFilename("img/button_Left_inactive.dds", SowingSupp.path), SowingSupp.grid[gridPos].x + centerX - 0.015, SowingSupp.grid[gridPos].y + 0.005, 0.01, 0.015);
		obj.overlays.overlayPlus = Overlay:new("overlayPlus", Utils.getFilename("img/button_Right.dds", SowingSupp.path), SowingSupp.grid[gridPos].x + centerX + 0.005, SowingSupp.grid[gridPos].y + 0.005, 0.01, 0.015);
		obj.overlays.overlayPlusInactive = Overlay:new("overlayPlusInactive", Utils.getFilename("img/button_Right_inactive.dds", SowingSupp.path), SowingSupp.grid[gridPos].x + centerX + 0.005, SowingSupp.grid[gridPos].y + 0.005, 0.01, 0.015);

	elseif style == "toggle" then -- toggle
		obj.overlays.overlayToggleOff = Overlay:new("overlayToggleOff", Utils.getFilename("img/button_Off.dds", SowingSupp.path), SowingSupp.grid[gridPos].x + centerX - 0.01, SowingSupp.grid[gridPos].y + 0.005, 0.02, 0.03);
		obj.overlays.overlayToggleOn = Overlay:new("overlayToggleOn", Utils.getFilename("img/button_On.dds", SowingSupp.path), SowingSupp.grid[gridPos].x + centerX - 0.01, SowingSupp.grid[gridPos].y + 0.005, 0.02, 0.03);
	end;

	-- Create button click areas
	obj.areas = { plus = {}, minus = {}, toggle = {}};
	if style == "plusminus" or style == "arrow" then -- plus minus & arrow
		obj.areas.minus.xMin = SowingSupp.grid[gridPos].x + centerX - 0.0145;
		obj.areas.minus.xMax = SowingSupp.grid[gridPos].x + centerX - 0.0045;
		obj.areas.minus.yMin = SowingSupp.grid[gridPos].y + 0.004;
		obj.areas.minus.yMax = SowingSupp.grid[gridPos].y + 0.018;
		obj.areas.plus.xMin = SowingSupp.grid[gridPos].x + centerX + 0.005;
		obj.areas.plus.xMax = SowingSupp.grid[gridPos].x + centerX + 0.015;
		obj.areas.plus.yMin = obj.areas.minus.yMin;
		obj.areas.plus.yMax = obj.areas.minus.yMax;
	elseif style == "toggle" then
		obj.areas.toggle.xMin = SowingSupp.grid[gridPos].x + centerX - 0.009;
		obj.areas.toggle.xMax = SowingSupp.grid[gridPos].x + centerX + 0.01;
		obj.areas.toggle.yMin = SowingSupp.grid[gridPos].y + 0.005;
		obj.areas.toggle.yMax = SowingSupp.grid[gridPos].y + 0.033;
	end;
	return obj
end;

function SowingSupp.guiElement:render()
	if self.isVisible then
		setTextColor(1,1,1,1);
		setTextBold(false);
		-- create a centered x position based on gridwidth
		local centerX = SowingSupp.grid.width/2;

		if self.style == "plusminus" or self.style == "arrow" then
			setTextAlignment(RenderText.ALIGN_CENTER);
			renderText((SowingSupp.grid[self.gridPos].x + centerX), (SowingSupp.grid[self.gridPos].y + 0.045), 0.01, tostring(self.label));
			renderText((SowingSupp.grid[self.gridPos].x + centerX), (SowingSupp.grid[self.gridPos].y + 0.026), 0.018, tostring(self.value));
			if self.buttonSet.minusIsActive then
				self.buttonSet.overlays.overlayMinus:render();
			else
				self.buttonSet.overlays.overlayMinusInactive:render();
			end;
			if self.buttonSet.plusIsActive then
				self.buttonSet.overlays.overlayPlus:render();
			else
				self.buttonSet.overlays.overlayPlusInactive:render();
			end;

		elseif self.style == "toggle" then
			setTextAlignment(RenderText.ALIGN_CENTER);
			renderText((SowingSupp.grid[self.gridPos].x + centerX), (SowingSupp.grid[self.gridPos].y + 0.045), 0.01, tostring(self.label));
			if self.value then
				self.buttonSet.overlays.overlayToggleOn:render();
			else
				self.buttonSet.overlays.overlayToggleOff:render();
			end;

		elseif self.style == "info" then
			setTextAlignment(RenderText.ALIGN_LEFT);
			if self.graphic ~= nil then
				self.graphic:render();
				renderText((SowingSupp.grid[self.gridPos].x + 0.018), (SowingSupp.grid[self.gridPos].y + 0.006), self.textSize, tostring(self.value));
			else
				renderText((SowingSupp.grid[self.gridPos].x + 0.004), (SowingSupp.grid[self.gridPos].y + 0.006), self.textSize, tostring(self.value));
			end;
		end;
	end;
end;

-- Create mouseEvents & call functions
function SowingSupp.guiElement:mouseEvent(posX, posY, isDown, isUp, button)
	if self.isVisible then
		if self.style == "plusminus" or self.style == "arrow" then
			if isDown and button == 1 then
				if self.buttonSet.minusIsActive then
					if self.buttonSet.areas.minus.xMax > posX and self.buttonSet.areas.minus.xMin < posX and self.buttonSet.areas.minus.yMax > posY and self.buttonSet.areas.minus.yMin < posY then
						SowingSupp:modules(self, self.parameter1);
					end;
				end;
				if self.buttonSet.plusIsActive then
					if self.buttonSet.areas.plus.xMax > posX and self.buttonSet.areas.plus.xMin < posX and self.buttonSet.areas.plus.yMax > posY and self.buttonSet.areas.plus.yMin < posY then
						SowingSupp:modules(self, self.parameter2);
					end;
				end;
			end;
		elseif self.style == "toggle" then
			if isDown and button == 1 then
				if self.buttonSet.areas.toggle.xMax > posX and self.buttonSet.areas.toggle.xMin < posX and self.buttonSet.areas.toggle.yMax > posY and self.buttonSet.areas.toggle.yMin < posY then
					SowingSupp:modules(self, self.parameter1);
				end;
			end;
		end;
	end;
end;
