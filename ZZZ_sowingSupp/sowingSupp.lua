-- SowingSupplement
--
-- a collection of several seeder modifications
--
--	@author:		gotchTOM & webalizer
--	@date: 			23-Nov-2014
--	@version: 		v0.02
--
-- included modules: sowingCounter
-- 
-- added modules: 
-- 		sowingCounter:			hectar counter for seeders
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
		self.activeModules.num = 0;
		self.activeModules.sowingCounter = true;
		self.activeModules.sowingSounds = true;
		
		SowingSupp:loadConfigFile(self);
		
		print("SowingSupp:load - check:")
		for name,value in pairs(self.activeModules) do
			print(name," ",tostring(value))
		end;
	end;
	self.sosuHUDisActive = false;
	self.stopMouse = false;
	
	SowingSupp:initGUI();

	self.texts = {};
	self.texts.dlMode = "Modus";

	self.tile = {};
	-- create gui tiles (grid position [int], function to call [string], parameter1, parameter2, style [string], label [string], value [], is visible [bool], [Grafik], textSize [float])
	
	-- self.tile.scSession = SowingSupp.guiElement:New( 1, nil, nil, nil, "info", nil, "0,00ha", true, "SowingCounter_sessionHUD.dds");
	-- self.tile.scHaPerHour = SowingSupp.guiElement:New( 2, nil, nil, nil, "info", nil, "(0,0ha/h)", true, nil);
	-- self.tile.scTotal = SowingSupp.guiElement:New( 3, nil, nil, nil, "info", nil, "0,0ha", true, "SowingCounter_totalHUD.dds");
	
	
	-- self.tile.scSession = SowingSupp.guiElement:New( 1, nil, nil, nil, "info", nil, "0.5 ha", true, "SowingCounter_sessionHUD.dds");
	-- self.tile.scTotal = SowingSupp.guiElement:New( 2, nil, nil, nil, "info", nil, "25.0 ha", true, "SowingCounter_totalHUD.dds");
	-- self.tile.scInfo = SowingSupp.guiElement:New( 4, nil, nil, nil, "info", nil, "Dies ist ein Test-Text!", true, nil);
	-- self.tile.dlMode = SowingSupp.guiElement:New( 19, "changeMode", -1, 1, "arrow", self.texts.dlMode, "AUTO", true, nil);
	-- self.tile.changeSomething = SowingSupp.guiElement:New( 20, "changeSomething", -3, 1, "plusminus", "Plus/Minus", 5, true, nil);
	-- self.tile.toggleFunction = SowingSupp.guiElement:New( 21, "toggleOnOff", nil, nil, "toggle", "Toggle", true, true, nil);
	
end;

-- function SowingSupp:postLoad(xmlFile)
-- end;

function SowingSupp:delete()
end;

function SowingSupp:mouseEvent(posX, posY, isDown, isUp, button)
	for k, guiElement in pairs(self.tile) do
		guiElement:mouseEvent(posX, posY, isDown, isUp, button);
	end;
end;

function SowingSupp:keyEvent(unicode, sym, modifier, isDown)

end;

function SowingSupp:modules(guiElement, parameter)
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
		if guiElement.value <= 0 then
			guiElement.value = 0;
			guiElement.buttonSet.minusIsActive = false;
		else
			guiElement.buttonSet.minusIsActive = true;
		end;
	end;

	if guiElement.functionToCall == "toggleOnOff" then
		guiElement.value = not guiElement.value;
		if guiElement.parameter1 == "Sounds" then
			self.sowingSounds.isAllowed = guiElement.value;
		end;
	end;
end;

function SowingSupp:update(dt)

	if self:getIsActiveForInput() then
		-- switch HUD
		if InputBinding.hasEvent(InputBinding.SOWINGSUPP_HUD) and self.activeModules.num > 0 then
			self.sosuHUDisActive = not self.sosuHUDisActive;
		end;
		if InputBinding.isPressed(InputBinding.SOWINGSUPP_MOUSE) and self.sosuHUDisActive then 
			if not self.stopMouse then
				self.stopMouse = true;
				InputBinding.setShowMouseCursor(true);
			end;
		else
			if self.stopMouse then
				self.stopMouse = false;
				InputBinding.setShowMouseCursor(false);
			end;
		end;
	end;	
end;

function SowingSupp:updateTick(dt)
end;

function SowingSupp:draw()
	if self.stopMouse then
		InputBinding.setShowMouseCursor(true);
	end;
	if self.activeModules.num > 0 then
		if self.sosuHUDisActive then
			if SowingSupp.grid.baseX ~= g_currentMission.weatherTimeBackgroundOverlay.x then
				print("SowingSupp:draw() -> SowingSupp:initGUI();")
				SowingSupp:initGUI();
				if self.activeModules.sowingCounter then
					print("SowingSupp:draw() -> self:updateSoCoGUI()")
					self:updateSoCoGUI();
				end;
				if self.activeModules.sowingSounds then
					print("SowingSupp:draw() -> self:updateSoSoGUI()")
					self:updateSoSoGUI();
				end;		
			end;	
			SowingSupp.hudBgOverlay2:render();
			-- Render all guiElements with own render()
			for k, guiElement in pairs(self.tile) do
				guiElement:render();
			end;
			g_currentMission:addHelpButtonText(SowingMachine.SOWINGSUPP_HUDoff, InputBinding.SOWINGSUPP_HUD);
		else
			g_currentMission:addHelpButtonText(SowingMachine.SOWINGSUPP_HUDon, InputBinding.SOWINGSUPP_HUD);
		end;
	end;
	
-- renderText(0.1,0.1,0.02,"g_currentMission.weatherTimeBackgroundOverlay.x: "..tostring(g_currentMission.weatherTimeBackgroundOverlay.x))
-- renderText(0.1,0.12,0.02,"SowingSupp.grid.baseX: "..tostring(SowingSupp.grid.baseX))
	
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
				self.activeModules.num = self.activeModules.num + 1;
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
