--
--	SowingSounds
--	Sounds for Sowing Machines (acoustic signals)
--
-- @author:  	GreenEye and gotchTOM
-- @date:			21-Dec-2014
-- @version:	v0.7
--
-- free for noncommerical-usage
--

SowingSounds = {};
-- local mod_directory = g_currentModDirectory;

function SowingSounds.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(SowingMachine, specializations);
end;

function SowingSounds:load(xmlFile)

	self.updateSoSoGUI = SpecializationUtil.callSpecializationsFunction("updateSoSoGUI");
	self.sowingSounds = {};
	self.sowingSounds.isLowered = false;
	self.sowingSounds.isRaised = false;
	self.sowingSounds.isLineActive = false;
	self.sowingSounds.isSeedLow5Percent = false;
	self.sowingSounds.isSeedLow1Percent = false;
	self.sowingSounds.isSeedEmpty = false;
	self.sowingSounds.isAllowed = true;
	self.sowingSounds.checkOnLeave = false;

	local SeSoSoundFile1 = Utils.getFilename("lower.wav", g_modsDirectory.."/ZZZ_sowingSupp/SowingSounds/");
    self.SeSoSoundId1 = createSample("SeSoSound1");
    loadSample(self.SeSoSoundId1, SeSoSoundFile1, false);

	local SeSoSoundFile2 = Utils.getFilename("raised.wav", g_modsDirectory.."/ZZZ_sowingSupp/SowingSounds/");
    self.SeSoSoundId2 = createSample("SeSoSound2");
    loadSample(self.SeSoSoundId2, SeSoSoundFile2, false);

	local SeSoSoundFile3 = Utils.getFilename("line.wav", g_modsDirectory.."/ZZZ_sowingSupp/SowingSounds/");
    self.SeSoSoundId3 = createSample("SeSoSound3");
    loadSample(self.SeSoSoundId3, SeSoSoundFile3, false);

	local SeSoSoundFile4 = Utils.getFilename("empty.wav", g_modsDirectory.."/ZZZ_sowingSupp/SowingSounds/");
    self.SeSoSoundId4 = createSample("SeSoSound4");
    loadSample(self.SeSoSoundId4, SeSoSoundFile4, false);

	self:updateSoSoGUI();
end;

function SowingSounds:delete()

	if self.sowingSounds ~= nil then
		if self.sowingSounds.isRaised then
			stopSample(self.SeSoSoundId2);
		end;
		if self.sowingSounds.isLineActive then
			stopSample(self.SeSoSoundId3);
		end;
		if self.sowingSounds.isSeedEmpty then
			stopSample(self.SeSoSoundId4);
		end;
	end;
end;

function SowingSounds:mouseEvent(posX, posY, isDown, isUp, button)
end;

function SowingSounds:keyEvent(unicode, sym, modifier, isDown)
end;

function SowingSounds:getSaveAttributesAndNodes(nodeIdent)
	local attributes = 'sowingSoundIsActiv="' .. tostring(self.activeModules.sowingSounds) ..'"';
	--print("!!!!!!!!!!!!!!SowingSounds:getSaveAttributesAndNodes_attributes = "..tostring(attributes))
	return attributes;
end;

function SowingSounds:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
	if self.activeModules ~= nil and self.activeModules.sowingSounds and not resetVehicles then
		self.activeModules.sowingSounds = Utils.getNoNil(getXMLBool(xmlFile, key .. "#sowingSoundIsActiv"), self.activeModules.sowingSounds);
		self:updateSoSoGUI();
		--print("!!!!!!!!!!!!!!SowingSounds:loadFromAttributesAndNodes_sowingSoundIsActiv = "..tostring(self.activeModules.sowingSounds))
	end;
    return BaseMission.VEHICLE_LOAD_OK;
end

function SowingSounds:update(dt)
end;

function SowingSounds:updateTick(dt)

	if self:getIsActive() then
		if self.activeModules ~= nil and self.activeModules.sowingSounds and self.sowingSounds ~= nil and self.sowingSounds.isAllowed and self:getIsActiveForSound() then
			-- renderText(0.1,0.3,0.02,"self.soMaIsLowered: "..tostring(self.soMaIsLowered))
			-- renderText(0.1,0.32,0.02,"self.isTurnedOn: "..tostring(self.isTurnedOn))
			-- renderText(0.1,0.34,0.02,"self.sowingSounds.isLowered: "..tostring(self.sowingSounds.isLowered))
			-- renderText(0.1,0.36,0.02,"self.sowingSounds.isSeedLow5Percent: "..tostring(self.sowingSounds.isSeedLow5Percent))
			-- renderText(0.1,0.38,0.02,"self.sowingSounds.isSeedLow1Percent: "..tostring(self.sowingSounds.isSeedLow1Percent))
			-- renderText(0.1,0.4,0.02,"self.sowingSounds.isSeedEmpty: "..tostring(self.sowingSounds.isSeedEmpty))
			if not self.sowingSounds.checkOnLeave then
				self.sowingSounds.checkOnLeave = true;
			end;
			if self.isTurnedOn then
				if not self.sowingSounds.isLowered then
					if self.soMaIsLowered then
						playSample(self.SeSoSoundId1, 1, 1, 0);
						-- print("playSample(self.lower, 1, 1, 0);")
						self.sowingSounds.isLowered = true;
					end;
				else
					if not self.soMaIsLowered then
						self.sowingSounds.isLowered = false;
					end;
				end;

				if not self.sowingSounds.isRaised then
					if not self.soMaIsLowered then
						playSample(self.SeSoSoundId2, 0, 1, 0);
						-- print("playSample(self.raised, 0, 1, 0);")
						self.sowingSounds.isRaised = true;
					end;
				else
					if self.soMaIsLowered then
						self.sowingSounds.isRaised = false;
						stopSample(self.SeSoSoundId2);
						-- print("stopSample(self.raised);")
					end;
				end;
				if not self.sowingSounds.isLineActive then					--> falls drivingLine.lua vorhanden
					if self.drivingLineActiv then
						playSample(self.SeSoSoundId3, 0, 1, 0);
						--print("playSample(self.line, 0, 1, 0);")
						self.sowingSounds.isLineActive = true;
					end;
				else
					if not self.drivingLineActiv then
						self.sowingSounds.isLineActive = false;
						stopSample(self.SeSoSoundId3);
						--print("stopSample(self.line);")
					end;
				end;

				if not self.sowingSounds.isSeedLow5Percent then
					if self.fillLevel <= 0.05 * self.capacity then
						playSample(self.SeSoSoundId4, 1, 1, 0);
						-- print("playSample(self.empty, 0, 1, 0);")
						self.sowingSounds.isSeedLow5Percent = true;
					end;
				else
					if self.fillLevel > 0.05 * self.capacity then
						self.sowingSounds.isSeedLow5Percent = false;
					end;
				end;

				if not self.sowingSounds.isSeedLow1Percent then
					if self.fillLevel <= 0.01 * self.capacity then
						playSample(self.SeSoSoundId4, 1, 1, 0);
						-- print("playSample(self.empty, 0, 1, 0);")
						self.sowingSounds.isSeedLow1Percent = true;
					end;
				else
					if self.fillLevel > 0.01 * self.capacity then
						self.sowingSounds.isSeedLow1Percent = false;
					end;
				end;

				if not self.sowingSounds.isSeedEmpty then
					if self.fillLevel == 0 then
						playSample(self.SeSoSoundId4, 0, 1, 0);
						-- print("playSample(self.empty, 0, 1, 0);")
						self.sowingSounds.isSeedEmpty = true;
					end;
				else
					if self.fillLevel ~= 0 then
						self.sowingSounds.isSeedEmpty = false;
						stopSample(self.SeSoSoundId4);
						-- print("stopSample(self.empty);")
					end;
				end;
			else								--> Deaktivieren beim Abschalten
				if self.sowingSounds.isRaised then
					self.sowingSounds.isRaised = false;
					stopSample(self.SeSoSoundId2);
					-- print("stopSample(self.raised);")
				end;
				if self.sowingSounds.isLineActive then
					self.sowingSounds.isLineActive = false;
					stopSample(self.SeSoSoundId3);
					-- print("stopSample(self.line);")
				end;
				if self.sowingSounds.isSeedEmpty then
					self.sowingSounds.isSeedEmpty = false;
					stopSample(self.SeSoSoundId4);
					-- print("stopSample(self.empty);")
				end;
			end;
		else										--> Deaktivieren beim Verbieten des Sounds
			if self.sowingSounds.isRaised then
				self.sowingSounds.isRaised = false;
				stopSample(self.SeSoSoundId2);
				-- print("stopSample(self.raised);")
			end;
			if self.sowingSounds.isLineActive then
				self.sowingSounds.isLineActive = false;
				stopSample(self.SeSoSoundId3);
				-- print("stopSample(self.line);")
			end;
			if self.sowingSounds.isSeedEmpty then
				self.sowingSounds.isSeedEmpty = false;
				stopSample(self.SeSoSoundId4);
				-- print("stopSample(self.empty);")
			end;
		end;
	else 											--> Deaktivieren beim Aussteigen
		if self.sowingSounds ~= nil and self.sowingSounds.checkOnLeave then
			if self.sowingSounds.isRaised then
				self.sowingSounds.isRaised = false;
				stopSample(self.SeSoSoundId2);
				-- print("stopSample(self.raised);")
			end;
			if self.sowingSounds.isLineActive then
				self.sowingSounds.isLineActive = false;
				stopSample(self.SeSoSoundId3);
					-- print("stopSample(self.line);")
			end;
			if self.sowingSounds.isSeedEmpty then
				self.sowingSounds.isSeedEmpty = false;
				stopSample(self.SeSoSoundId4);
				-- print("stopSample(self.empty);")
			end;
			self.sowingSounds.checkOnLeave = false;
		end;
	end;
end;

function SowingSounds:draw()
end;

function SowingSounds:updateSoSoGUI()
	if self.activeModules ~= nil then
		if self.activeModules.sowingSounds then
			self.hud1.grids.main.elements.sowingSound.value = self.sowingSounds.isAllowed;
			self.hud1.grids.main.elements.sowingSound.isVisible = true;
		else
			self.hud1.grids.main.elements.sowingSound.isVisible = false;
			self.hud1.grids.config.elements.soSoModul.value = false;
		end;
	end;
end;
