-- SowingSupplement
--
-- a collection of several seeder modifications
--
--	@author:		gotchTOM & webalizer
--	@date: 			6-Dec-2014
--	@version: 	v0.05
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
		
		SowingSupp:loadConfigFile(self);
		
		print("SowingSupp:load - check:")
		for name,value in pairs(self.activeModules) do
			print(name," ",tostring(value))
		end;
	end;
	self.sosuHUDisActive = false;		
	self.lastNumActiveHUDs = -1;	
	SowingSupp.stopMouse = false;

	SowingSupp.snd_click = createSample("snd_click");
	loadSample(SowingSupp.snd_click, Utils.getFilename("snd/snd_click.wav", SowingSupp.path), false);
	
	-- create grids in function updateGrids(), so grids can be updated if other HUDs are on start-position and grid2 is updated if grid1 was moved 
	self.updateGrids = SpecializationUtil.callSpecializationsFunction("updateGrids");
	local xPos, yPos = g_currentMission.hudSelectionBackgroundOverlay.x, g_currentMission.hudSelectionBackgroundOverlay.y + g_currentMission.hudSelectionBackgroundOverlay.height + g_currentMission.hudBackgroundOverlay.height;
	self:updateGrids(xPos, yPos);
	

end;

function SowingSupp:delete()
end;

function SowingSupp:mouseEvent(posX, posY, isDown, isUp, button)
	self.grid1:mouseEvent(self, posX, posY, isDown, isUp, button);
	self.grid2:mouseEvent(self, posX, posY, isDown, isUp, button);
end;

function SowingSupp:keyEvent(unicode, sym, modifier, isDown)

end;

function SowingSupp:modules(grid, vehicle, guiElement, parameter)
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
			vehicle.grid2.isVisible = not vehicle.grid2.isVisible;
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
				self.grid1.isVisible = true;
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
		if self.AttacherVehicleBackup.ActiveHUDs.numActiveHUDs ~= self.lastNumActiveHUDs and self.grid1.baseX == g_currentMission.hudSelectionBackgroundOverlay.x then
			local yPos = g_currentMission.hudSelectionBackgroundOverlay.y + g_currentMission.hudSelectionBackgroundOverlay.height*(self.AttacherVehicleBackup.ActiveHUDs.numActiveHUDs+1) + g_currentMission.hudBackgroundOverlay.height;
			
			self:updateGrids(self.grid1.baseX, yPos);
			
			self.lastNumActiveHUDs = self.AttacherVehicleBackup.ActiveHUDs.numActiveHUDs;
		end;
	end;
end;	

function SowingSupp:draw()
	if SowingSupp.stopMouse then
		InputBinding.setShowMouseCursor(true);
	end;
	if self.sosuHUDisActive then
		self.grid1:render();
		self.grid2:render();
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

function SowingSupp:updateGrids(xPos, yPos)

	local gridWidth = g_currentMission.hudSelectionBackgroundOverlay.width/3;
	local gridHeight = g_currentMission.hudSelectionBackgroundOverlay.height;
	
	self.grid1 = {};
	self.grid1 = SowingSupp.hudGrid:New(xPos, yPos, 9, 3, gridWidth, gridHeight, true);

	self.grid2 = {};
	self.grid2 = SowingSupp.hudGrid:New(self.grid1.baseX - g_currentMission.hudSelectionBackgroundOverlay.width - gridHeight*.038, self.grid1.baseY, 8, 3, gridWidth, gridHeight, false);
		

	self.texts = {};
	-- self.texts.dlMode = "Modus";

	self.grid1.elements = {};
	-- create gui elements ( grid position [int], function to call [string], parameter1, parameter2, style [string], label [string], value [], is visible [bool], [Grafik], textSize [float])
	self.grid1.elements.titleBar = SowingSupp.guiElement:New( 25, "titleBar", "configHud", "close", "titleBar", "Sowing Supplement", nil, true, nil, g_currentMission.missionStatusTextSize);
	if self.activeModules.sowingSounds then	
		self.grid1.elements.sowingSound = SowingSupp.guiElement:New( 3, "toggleSound", nil, nil, "toggleSound", "Sounds", true, true, nil, g_currentMission.cruiseControlTextSize);
	else		
		self.grid1.elements.sowingSound = SowingSupp.guiElement:New( 3, "toggleSound", nil, nil, "toggleSound", "Sounds", false, false, nil, g_currentMission.cruiseControlTextSize);
	end;
	if self.activeModules.sowingCounter then	
		self.grid1.elements.scSession = SowingSupp.guiElement:New( 1, nil, nil, nil, "infoSoCoSession", nil, "0.00ha   (0.0ha/h)", true, "SowingCounter_sessionHUD.dds", g_currentMission.fillLevelTextSize);
		self.grid1.elements.scTotal = SowingSupp.guiElement:New( 4, nil, nil, nil, "infoSoCoTotal", nil, "0.0ha", true, "SowingCounter_totalHUD.dds", g_currentMission.fillLevelTextSize);
	else	
		self.grid1.elements.scSession = SowingSupp.guiElement:New( 1, nil, nil, nil, "infoSoCoSession", nil, "0.00ha   (0.0ha/h)", false, "SowingCounter_sessionHUD.dds", g_currentMission.fillLevelTextSize);
		self.grid1.elements.scTotal = SowingSupp.guiElement:New( 4, nil, nil, nil, "infoSoCoTotal", nil, "0.0ha", false, "SowingCounter_totalHUD.dds", g_currentMission.fillLevelTextSize);
	end;
	
	self.grid1.elements.test1 = SowingSupp.guiElement:New( 1, nil, nil, nil, "infoTEST", nil, "___________________________________________", true, nil, g_currentMission.cruiseControlTextSize);
	self.grid1.elements.test2 = SowingSupp.guiElement:New( 4, nil, nil, nil, "infoTEST", nil, "___________________________________________", true, nil, g_currentMission.cruiseControlTextSize);
	self.grid1.elements.test3 = SowingSupp.guiElement:New( 7, nil, nil, nil, "infoTEST", nil, "___________________________________________", true, nil, g_currentMission.cruiseControlTextSize);
	
	-- self.grid1.elements.scSession = SowingSupp.guiElement:New( 1, nil, nil, nil, "info", nil, "0.5 ha", true, "SowingCounter_sessionHUD.dds");
	-- self.grid1.elements.scTotal = SowingSupp.guiElement:New( 2, nil, nil, nil, "info", nil, "25.0 ha", true, "SowingCounter_totalHUD.dds");
	-- self.grid1.elements.scInfo = SowingSupp.guiElement:New( 4, nil, nil, nil, "info", nil, "Dies ist ein Test-Text!", true, nil);
	-- self.grid1.elements.dlMode = SowingSupp.guiElement:New( 19, "changeMode", -1, 1, "arrow", self.texts.dlMode, "AUTO", true, nil);
	-- self.grid1.elements.changeSomething = SowingSupp.guiElement:New( 20, "changeSomething", -3, 1, "plusminus", "Verschieben", 21, true, nil);
	-- self.grid1.elements.toggleFunction = SowingSupp.guiElement:New( 21, "toggleOnOff", nil, nil, "toggle", "Toggle", true, true, nil);

	
	self.grid2.elements = {};
	-- create gui elements (self, grid position [int], function to call [string], parameter1, parameter2, style [string], label [string], value [], is visible [bool], [Grafik], textSize [float])
	self.grid2.elements.soCoModulIcon = SowingSupp.guiElement:New( 1, "toggleSoCoModul", nil, nil, "toggleModul", "", self.activeModules.sowingCounter, true, nil);
	self.grid2.elements.soCoModulText = SowingSupp.guiElement:New( 2, nil, nil, nil, "infoModul", nil, SowingMachine.SowingCounter, true, nil, g_currentMission.fillLevelTextSize);
	self.grid2.elements.soSoModulIcon = SowingSupp.guiElement:New( 4, "toggleSoSoModul", nil, nil, "toggleModul", "", self.activeModules.sowingSounds, true, nil);
	self.grid2.elements.soSoModulText = SowingSupp.guiElement:New( 5, nil, nil, nil, "infoModul", nil,  SowingMachine.SowingSounds, true, nil, g_currentMission.fillLevelTextSize);
	
	self.grid2.elements.test1 = SowingSupp.guiElement:New( 1, nil, nil, nil, "infoTEST", nil, "___________________________________________", true, nil, g_currentMission.cruiseControlTextSize);
	self.grid2.elements.test2 = SowingSupp.guiElement:New( 4, nil, nil, nil, "infoTEST", nil, "___________________________________________", true, nil, g_currentMission.cruiseControlTextSize);
	self.grid2.elements.test3 = SowingSupp.guiElement:New( 7, nil, nil, nil, "infoTEST", nil, "___________________________________________", true, nil, g_currentMission.cruiseControlTextSize);
	
	-- self.grid2.elements.scInfo = SowingSupp.guiElement:New( 4, nil, nil, nil, "info", nil, "Weiterer Test-Text!", true, nil);
	-- self.grid2.elements.dlMode = SowingSupp.guiElement:New( 19, "changeMode", -1, 1, "arrow", self.texts.dlMode, "AUTO", true, nil);
	-- self.grid2.elements.changeSomething = SowingSupp.guiElement:New( 20, "changeSomething", -3, 1, "plusminus", "Plus/Minus", 21, true, nil);
	-- self.grid2.elements.toggleFunction = SowingSupp.guiElement:New( 21, "toggleOnOff", nil, nil, "toggle", "Toggle", true, true, nil);
end;
