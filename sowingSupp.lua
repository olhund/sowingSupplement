-- SowingSupplement
--
-- a collection of several seeder modifications
--
--	@author:		gotchTOM & webalizer
--	@date: 			6-Dec-2014
--	@version: 	v0.06
--
-- included modules: sowingCounter, sowingSounds
--
-- added modules:
-- 		sowingCounter:			hectar counter for seeders
-- 		sowingSounds:			acoustic signals for seeders
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
		-- self.activeModules.num = 0;
		self.activeModules.sowingCounter = true;
		self.activeModules.sowingSounds = true;
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

	-- create gui elements ( grid position [int], function to call [string], parameter1, parameter2, style [string], label [string], value [], is visible [bool], [Grafik], textSize [float])
	self.hud1.grids.main.elements.titleBar = SowingSupp.guiElement:New( 25, "titleBar", "configHud", "close", "titleBar", "Sowing Supplement", nil, true, nil, g_currentMission.missionStatusTextSize*0.8);
	self.hud1.grids.main.elements.sowingSound = SowingSupp.guiElement:New( 3, "toggleSound", nil, nil, "toggle", "Sounds", true, self.activeModules.sowingSounds, "button_Sound", g_currentMission.cruiseControlTextSize);
	self.hud1.grids.main.elements.scSession = SowingSupp.guiElement:New( 1, nil, nil, nil, "info", nil, "0.00ha   (0.0ha/h)", self.activeModules.sowingCounter, "SowingCounter_sessionHUD", g_currentMission.fillLevelTextSize);
	self.hud1.grids.main.elements.scTotal = SowingSupp.guiElement:New( 4, nil, nil, nil, "info", nil, "0.0ha", self.activeModules.sowingCounter, "SowingCounter_totalHUD", g_currentMission.fillLevelTextSize);

	-- self.hud1.grids.main.elements.dlMode = SowingSupp.guiElement:New( 19, "changeMode", -1, 1, "arrow", "Mode", "AUTO", true, nil);
	-- self.hud1.grids.main.elements.changeSomething = SowingSupp.guiElement:New( 20, "changeSomething", -3, 1, "plusminus", "Verschieben", 21, true, nil);

	self.hud1.grids.config.elements.soCoModul = SowingSupp.guiElement:New( 1, "toggleSoCoModul", nil, nil, "option", SowingMachine.SowingCounter, self.activeModules.sowingCounter, true, "button_Option", g_currentMission.fillLevelTextSize);
	self.hud1.grids.config.elements.soSoModul = SowingSupp.guiElement:New( 4, "toggleSoSoModul", nil, nil, "option", SowingMachine.SowingSounds, self.activeModules.sowingSounds, true, "button_Option", g_currentMission.fillLevelTextSize);
	self.hud1.grids.config.elements.separator1 = SowingSupp.guiElement:New( 4, nil, nil, nil, "separator", nil, nil, true, "row_bg", nil);
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
	if guiElement.functionToCall == "changeMode" then
		if parameter == 1 then
			guiElement.value = "erhöht";

		elseif parameter == -1 then
			guiElement.value = "vermindert";
		end;
	end;

	if guiElement.functionToCall == "changeSomething" then
		guiElement.value = guiElement.value + parameter;
		if guiElement.value <= 1 then
			guiElement.value = 1;
			guiElement.buttonSet.button1IsActive = false;
		else
			guiElement.buttonSet.button1IsActive = true;
		end;
		if guiElement.value >= 21 then
			guiElement.value = 21;
			guiElement.buttonSet.button2IsActive = false;
		else
			guiElement.buttonSet.button2IsActive = true;
		end;
		grid.elements.toggleFunction.gridPos = guiElement.value;
	end;

	if guiElement.functionToCall == "toggleOnOff" then
		guiElement.value = not guiElement.value;
	end;
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
end;

function SowingSupp:update(dt)

	if self:getIsActiveForInput() then
		-- switch HUD
		if InputBinding.hasEvent(InputBinding.SOWINGSUPP_HUD) then
			self.sosuHUDisActive = not self.sosuHUDisActive;
			if self.sosuHUDisActive then
				self.hud1.isVisible = true;
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

function SowingSupp:onAttach(attacherVehicle)
	--self.AttacherVehicleBackup = attacherVehicle;
	-- can we use this for the part in updateTick??
end;

function SowingSupp:updateTick(dt)
	-- update y-position if HUD is on initial position (exact x-position) and there are other HUDs (like ThreshingCounter or OperatingHours of AGes Sonnenschein)
	if self:getIsActive() and self.sosuHUDisActive then
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

	local moduleList = {"sowingCounter","sowingSounds"};

	for _,field in pairs(moduleList) do
		local XmlField = string.upper(string.sub(field,1,1))..string.sub(field,2);

		local res = getXMLBool(Xml, "sowingSupplement.Modules."..XmlField);

		if res ~= nil then
			self.activeModules[field] = res;
			if res then
				-- self.activeModules.num = self.activeModules.num + 1;
				print("sowingSupplement module "..field.." started")
			else
				print("sowingSupplement module "..field.." not started");
			end;
		else
			setXMLBool(Xml, "sowingSupplement.Modules."..XmlField, true);
			-- self.activeModules.num = self.activeModules.num + 1;
			print("sowingSupplement module "..field.." inserted into xml and started");
		end;
	end;

	saveXMLFile(Xml);
end;
