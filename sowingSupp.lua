-- SowingSupplement
--
-- a collection of several seeder modifications
--
--	@author:		gotchTOM & webalizer
--	@date: 			25-Nov-2015
--	@version: 	v0.08
--
-- included modules: sowingCounter, sowingSounds
--
-- added modules:
-- 		sowingCounter:			hectar counter for seeders
-- 		sowingSounds:				acoustic signals for seeders
--		drivingLine:
--
-- changes in modules:
--


SowingSupp = {}
SowingSupp.path = g_currentModDirectory;
source(SowingSupp.path.."gui.lua");

function SowingSupp.prerequisitesPresent(specializations)
		return SpecializationUtil.hasSpecialization(SowingMachine, specializations);
end;

function SowingSupp:load(xmlFile)
	if self.activeModules == nil then
		self.activeModules = {};
		self.activeModules.sowingCounter = true;
		self.activeModules.sowingSounds = true;
		self.activeModules.drivingLine = true;
		if SowingSupp.isDedi == nil then
			SowingSupp.isDedi = SowingSupp:checkIsDedi();
		end;
		if not SowingSupp.isDedi then
			SowingSupp:loadConfigFile(self);
		end;

		print("SowingSupp: load - check:")
		for name,value in pairs(self.activeModules) do
			print(name," ",tostring(value))
		end;
	end;
	self.sosuHUDisActive = false;
	self.lastNumActiveHUDs = -1;
	SowingSupp.stopMouse = false;
	self.soMaIsLowered = false;
	-- self.soMaHasGroundContact = false; -- is required by sowingSounds and drivingLine, because self.sowingMachineHasGroundContact doesn´t work like it should :(

	SowingSupp.snd_click = createSample("snd_click");
	loadSample(SowingSupp.snd_click, Utils.getFilename("snd/snd_click.wav", SowingSupp.path), false);

	local xPos, yPos = g_currentMission.hudSelectionBackgroundOverlay.x, g_currentMission.hudSelectionBackgroundOverlay.y + g_currentMission.hudSelectionBackgroundOverlay.height + g_currentMission.hudBackgroundOverlay.height;

	self.hud1 = {};
	self.hud1 = SowingSupp.container:New(xPos, yPos, true);

	local gridWidth = g_currentMission.hudSelectionBackgroundOverlay.width/3;
	local gridHeight = g_currentMission.hudSelectionBackgroundOverlay.height;

	-- create grid (container [table], offset x [int], offset y [int], rows [int], columns [int], width [int], height [int] is visible [bool], is master [bool])
	self.hud1.grids.main = {};
	self.hud1.grids.main = SowingSupp.hudGrid:New(self.hud1, 0, 0, 9, 3, gridWidth, gridHeight, true, true);

	self.hud1.grids.config = {};
	self.hud1.grids.config = SowingSupp.hudGrid:New(self.hud1, -self.hud1.width - (gridHeight*.038), 0, 8, 3, gridWidth, gridHeight, false, false);

	-- create gui elements ( grid position [int], function to call [string], parameter1, parameter2, style [string], label [string], value [], is visible [bool], [Grafik], textSize [float], textAlignment [])
	-- main
	self.hud1.grids.main.elements.titleBar = SowingSupp.guiElement:New( 25, "titleBar", "configHud", "close", "titleBar", "Sowing Supplement", nil, true, nil, g_currentMission.missionStatusTextSize*0.8);
	self.hud1.grids.main.elements.sowingSound = SowingSupp.guiElement:New( 3, "toggleSound", nil, nil, "toggle", SowingMachine.SOWINGSOUNDS_SIGNAL, true, self.activeModules.sowingSounds, "button_Sound", g_currentMission.timeScaleTextSize);
	self.hud1.grids.main.elements.scSession = SowingSupp.guiElement:New( 1, nil, nil, nil, "info", nil, "0.00ha   (0.0ha/h)", self.activeModules.sowingCounter, "SowingCounter_sessionHUD", g_currentMission.fillLevelTextSize, RenderText.ALIGN_LEFT);
	self.hud1.grids.main.elements.scTotal = SowingSupp.guiElement:New( 4, nil, nil, nil, "info", nil, "0.0ha", self.activeModules.sowingCounter, "SowingCounter_totalHUD", g_currentMission.fillLevelTextSize, RenderText.ALIGN_LEFT);
	
	self.hud1.grids.main.elements.info_numDrivingLine = SowingSupp.guiElement:New( 14, nil, nil, nil, "info_ww_numDriLi", SowingMachine.DRIVINGLINE_NUMDRILINE, 0, true, nil);
	
	self.hud1.grids.main.elements.driLiPeMarker = SowingSupp.guiElement:New( 15, "togglePeMarker", nil, nil, "toggle", "peMarker", true, true, "button_peMarker", g_currentMission.timeScaleTextSize);
	
	self.hud1.grids.main.elements.info_workWidth = SowingSupp.guiElement:New( 17, nil, nil, nil, "info_ww_numDriLi", SowingMachine.DRIVINGLINE_WORKWIDTH, 0, true, nil);
	
	self.hud1.grids.main.elements.driLiMode = SowingSupp.guiElement:New( 19, "changeDriLiMode", -1, 1, "arrow", SowingMachine.DRIVINGLINE_MODE, SowingMachine.DRIVINGLINE_MANUAL, true, nil);
	
	
	self.hud1.grids.main.elements.driLiSpWorkWidth = SowingSupp.guiElement:New( 20, "changeSpWorkWidth", -1, 1, "plusminus", SowingMachine.DRIVINGLINE_SPWORKWIDTH, 0, true, nil);

	self.hud1.grids.main.elements.driLiCurDrive = SowingSupp.guiElement:New( 21, "changeCurDrive", -1, 1, "plusminus", SowingMachine.DRIVINGLINE_CURRENTLANE, 1, true, nil);
	
	-- self.hud1.grids.main.elements.separator1 = SowingSupp.guiElement:New( 19, nil, nil, nil, "separator", nil, nil, true, "row_bg", nil);	
	
	-- self.hud1.grids.main.elements.changeSomething = SowingSupp.guiElement:New( 20, "changeSomething", -3, 1, "plusminus", "Verschieben", 21, true, nil);
	
	-- config
	self.hud1.grids.config.elements.soCoModul = SowingSupp.guiElement:New( 13, "toggleSoCoModul", nil, nil, "option", SowingMachine.SOWINGCOUNTER, self.activeModules.sowingCounter, true, "button_Option", g_currentMission.fillLevelTextSize);
	self.hud1.grids.config.elements.separator1 = SowingSupp.guiElement:New( 13, nil, nil, nil, "separator", nil, nil, true, "row_bg", nil);
	self.hud1.grids.config.elements.soSoModul = SowingSupp.guiElement:New( 16, "toggleSoSoModul", nil, nil, "option", SowingMachine.SOWINGSOUNDS, self.activeModules.sowingSounds, true, "button_Option", g_currentMission.fillLevelTextSize);
	self.hud1.grids.config.elements.separator2 = SowingSupp.guiElement:New( 16, nil, nil, nil, "separator", nil, nil, true, "row_bg", nil);
	self.hud1.grids.config.elements.driLiModul = SowingSupp.guiElement:New( 19, "toggleDriLiModul", nil, nil, "option", SowingMachine.DRIVINGLINE, self.activeModules.drivingLine, true, "button_Option", g_currentMission.fillLevelTextSize);
	self.hud1.grids.config.elements.separator3 = SowingSupp.guiElement:New( 19, nil, nil, nil, "separator", nil, nil, true, "row_bg", nil);
	
	
	self.hud1.grids.config.elements.configLabel = SowingSupp.guiElement:New( 23, nil, nil, nil, "info", nil, SowingMachine.SOWINGSUPP_CONFIGLABEL, true, nil, g_currentMission.missionStatusTextSize*0.8, RenderText.ALIGN_CENTER);
	
end;

function SowingSupp:checkIsDedi()
	local pixelX, pixelY = getScreenModeInfo(getScreenMode());
	return pixelX*pixelY < 1;
end;

function SowingSupp:delete()
end;

function SowingSupp:mouseEvent(posX, posY, isDown, isUp, button)
	self.hud1:mouseEvent(self, posX, posY, isDown, isUp, button);
	--self.hud1.grids.config:mouseEvent(self, posX, posY, isDown, isUp, button);
end;

function SowingSupp:keyEvent(unicode, sym, modifier, isDown)

end;

function SowingSupp:modules(grid, container, vehicle, guiElement, parameter)
	playSample(SowingSupp.snd_click, 1, 1, 0);
	-- Call other functions instead of doing it directly
	-- if guiElement.functionToCall == "changeMode" then
		-- if parameter == 1 then
			-- guiElement.value = "erhöht";

		-- elseif parameter == -1 then
			-- guiElement.value = "vermindert";
		-- end;
	-- end;
	if guiElement.functionToCall == "changeDriLiMode" then
		if parameter == 1 then
			if vehicle.dlMode == 0 then
				vehicle.dlMode = 1;
				guiElement.value = SowingMachine.DRIVINGLINE_SEMIAUTO;
			elseif vehicle.dlMode == 1 then
				vehicle.dlMode = 2;
				guiElement.value = SowingMachine.DRIVINGLINE_AUTO;
			else --vehicle.dlMode = 2
				vehicle.dlMode = 0;
				guiElement.value = SowingMachine.DRIVINGLINE_MANUAL;
				if vehicle.isPaused then
					vehicle.isPaused = false;
				end;
			end;
		elseif parameter == -1 then
			if vehicle.dlMode == 0 then
				vehicle.dlMode = 2;
				guiElement.value = SowingMachine.DRIVINGLINE_AUTO;
			elseif vehicle.dlMode == 1 then
				vehicle.dlMode = 0;
				guiElement.value = SowingMachine.DRIVINGLINE_MANUAL;
			else --vehicle.dlMode = 2
				vehicle.dlMode = 1;
				guiElement.value = SowingMachine.DRIVINGLINE_SEMIAUTO;
				if vehicle.isPaused then
					vehicle.isPaused = false;
				end;
			end;
		end;
		vehicle:updateDriLiGUI();
		-- vehicle.hasChanged = true;
	end;
	if guiElement.functionToCall == "changeSpWorkWidth" then
		if parameter == 1 then
			vehicle:setSPworkwidth(true);
		elseif parameter == -1 then
			vehicle:setSPworkwidth(false);
		end;
	end;
	if guiElement.functionToCall == "changeCurDrive" then
		if parameter == 1 then
			if vehicle.currentLane < vehicle.nSMdrives then
				vehicle.currentLane = vehicle.currentLane + 1;
			else
				vehicle.currentLane = 1;
			end;
		elseif parameter == -1 then
			if vehicle.currentLane > 1 then
				vehicle.currentLane = vehicle.currentLane - 1;
			else
				vehicle.currentLane = vehicle.nSMdrives;
			end;
		end;
		vehicle:updateDriLiGUI();
	end;

	-- if guiElement.functionToCall == "changeSomething" then
		-- guiElement.value = guiElement.value + parameter;
		-- if guiElement.value <= 1 then
			-- guiElement.value = 1;
			-- guiElement.buttonSet.button1IsActive = false;
		-- else
			-- guiElement.buttonSet.button1IsActive = true;
		-- end;
		-- if guiElement.value >= 21 then
			-- guiElement.value = 21;
			-- guiElement.buttonSet.button2IsActive = false;
		-- else
			-- guiElement.buttonSet.button2IsActive = true;
		-- end;
		-- grid.elements.toggleFunction.gridPos = guiElement.value;
	-- end;
	-- if guiElement.functionToCall == "toggleOnOff" then
		-- guiElement.value = not guiElement.value;
	-- end;
	
	if guiElement.functionToCall == "titleBar" then
		if parameter == "configHud" then
			vehicle.hud1.grids.config.isVisible = not vehicle.hud1.grids.config.isVisible;
		end;
		if parameter == "close" then
			vehicle.sosuHUDisActive = false;
			InputBinding.setShowMouseCursor(false);
		end;
	end;
	if guiElement.functionToCall == "toggleSound" then
		guiElement.value = not guiElement.value;
		vehicle.sowingSounds.isAllowed = guiElement.value;
	end;
	if guiElement.functionToCall == "toggleSoCoModul" then
		guiElement.value = not guiElement.value;
		vehicle.activeModules.sowingCounter = guiElement.value;
		vehicle:updateSoCoGUI();
	end;
	if guiElement.functionToCall == "toggleSoSoModul" then
		guiElement.value = not guiElement.value;
		vehicle.activeModules.sowingSounds = guiElement.value;
		vehicle:updateSoSoGUI();
	end;
	if guiElement.functionToCall == "toggleDriLiModul" and vehicle.drivingLinePresent then
		guiElement.value = not guiElement.value;
		vehicle.activeModules.drivingLine = guiElement.value;
		vehicle:updateDriLiGUI();
	end;
	if guiElement.functionToCall == "togglePeMarker" then
		guiElement.value = not guiElement.value;
		vehicle.allowPeMarker = guiElement.value;
		if not vehicle.allowPeMarker and vehicle.peMarkerActiv then
			vehicle.peMarkerActiv = vehicle.allowPeMarker;
		end;
		-- vehicle:setDrivingLine(vehicle.drivingLineActiv, vehicle.dlMode, vehicle.currentLane, vehicle.isPaused, vehicle.nSMdrives, vehicle.smWorkwith, vehicle.allowPeMarker);
		-- if vehicle.allowPeMarker then
			-- if vehicle.drivingLineActiv then
				-- vehicle:setPeMarker(true);
			-- end;
		-- else
			-- if vehicle.drivingLineActiv then
				-- vehicle:setPeMarker(false);
			-- end;
		-- end;
		vehicle:updateDriLiGUI();
	end;
end;

function SowingSupp:update(dt)

	if self:getIsActiveForInput() then
		-- switch HUD
		if InputBinding.hasEvent(InputBinding.SOWINGSUPP_HUD) then
			self.sosuHUDisActive = not self.sosuHUDisActive;
			if self.sosuHUDisActive then
				self.hud1.isVisible = true;
				if self.activeModules.drivingLine then
					self:updateDriLiGUI();
				end;
			end;
		end;
		if InputBinding.isPressed(InputBinding.SOWINGSUPP_MOUSE) and self.sosuHUDisActive then
			if not SowingSupp.stopMouse then
				SowingSupp.stopMouse = true;
				InputBinding.setShowMouseCursor(true);
			end;
		else
			if SowingSupp.stopMouse then
				SowingSupp.stopMouse = false;
				InputBinding.setShowMouseCursor(false);
			end;
		end;
	end;
end;

-- function SowingSupp:onAttach(attacherVehicle)
	-- self.AttacherVehicleBackup = attacherVehicle;
-- end;

function SowingSupp:updateTick(dt)
	-- update y-position if HUD is on initial position (exact x-position) and there are other HUDs (like OperatingHours of AGes Sonnenschein)
	if self:getIsActive() then
		if self.sosuHUDisActive then
			if self.AttacherVehicleBackup == nil then
				local attacherVehicle = self:getRootAttacherVehicle();
				self.AttacherVehicleBackup = attacherVehicle;
			end;
			if self.AttacherVehicleBackup.ActiveHUDs == nil then
				self.AttacherVehicleBackup.ActiveHUDs = {};
				self.AttacherVehicleBackup.ActiveHUDs.numActiveHUDs = 0;
			end;
			if self.AttacherVehicleBackup.ActiveHUDs.numActiveHUDs ~= self.lastNumActiveHUDs and self.hud1.baseX == g_currentMission.hudSelectionBackgroundOverlay.x then
				local yPos = g_currentMission.hudSelectionBackgroundOverlay.y + g_currentMission.hudSelectionBackgroundOverlay.height * (self.AttacherVehicleBackup.ActiveHUDs.numActiveHUDs+1) + g_currentMission.hudSelectionBackgroundOverlay.height * .038 + g_currentMission.hudBackgroundOverlay.height;
				self.hud1:changeContainer(self.hud1.baseX, yPos);
				self.lastNumActiveHUDs = self.AttacherVehicleBackup.ActiveHUDs.numActiveHUDs;
			end;
		end;
		if self.activeModules.sowingSounds or self.activeModules.drivingLine then
			self.soMaIsLowered = self:isLowered();
		end;
	end;
end;

function SowingSupp:draw()
	if SowingSupp.stopMouse then
		InputBinding.setShowMouseCursor(true);
	end;
	if self.sosuHUDisActive then
		self.hud1:render();
		g_currentMission:addHelpButtonText(SowingMachine.SOWINGSUPP_HUDoff, InputBinding.SOWINGSUPP_HUD);
	else
		g_currentMission:addHelpButtonText(SowingMachine.SOWINGSUPP_HUDon, InputBinding.SOWINGSUPP_HUD);
	end;
end;

function SowingSupp:loadConfigFile(self)
	-- local path = getUserProfileAppPath();
	local Xml;
	local file = g_modsDirectory.."/sowingSupplement_config.xml";

	if fileExists(file) then
		print("loading "..file.." for sowingSupplement-Mod configuration");
		Xml = loadXMLFile("sowingSupplement_XML", file, "sowingSupplement");
	else
		print("creating "..file.." for sowingSupplement-Mod configuration");
		Xml = createXMLFile("sowingSupplement_XML", file, "sowingSupplement");
	end;

	local moduleList = {"sowingCounter","sowingSounds","drivingLine"};

	for _,field in pairs(moduleList) do
		local XmlField = string.upper(string.sub(field,1,1))..string.sub(field,2);

		local res = getXMLBool(Xml, "sowingSupplement.Modules."..XmlField);

		if res ~= nil then
			self.activeModules[field] = res;
			if res then
				print("sowingSupplement module "..field.." started")
			else
				print("sowingSupplement module "..field.." not started");
			end;
		else
			setXMLBool(Xml, "sowingSupplement.Modules."..XmlField, true);
			print("sowingSupplement module "..field.." inserted into xml and started");
		end;
	end;

	saveXMLFile(Xml);
end;
