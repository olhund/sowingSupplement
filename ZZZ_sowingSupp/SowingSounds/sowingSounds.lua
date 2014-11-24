--
--	SowingSounds
--	Sounds for Sowing Machines (acoustic and visual signals) 
--
-- @author:  	GreenEye and gotchTOM
-- @date:		23-Nov-2014
-- @version:	v0.4
-- @history:	v0.1 - initial implementation
--				v0.4 - part of SowingSupplement
--
-- free for noncommerical-usage
--

SowingSounds = {};

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
	self.sowingSounds.isAllowed = false;
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
	print("!!!!!!!!!!!!!!SowingSounds:getSaveAttributesAndNodes_attributes = "..tostring(attributes))
	return attributes;
end;

function SowingSounds:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
	
	if self.activeModules ~= nil and self.activeModules.sowingSounds and not resetVehicles then 
		self.activeModules.sowingSounds = Utils.getNoNil(getXMLBool(xmlFile, key .. "#sowingSoundIsActiv"), self.activeModules.sowingCounter);
		print("!!!!!!!!!!!!!!SowingSounds:loadFromAttributesAndNodes_sowingSoundIsActiv = "..tostring(self.activeModules.sowingSounds))
		if self.activeModules.sowingSounds then
			print("!!!!!!!!!!!!!!SowingSounds:loadFromAttributesAndNodes -> self:updateSoSoGUI()")
			self:updateSoSoGUI();
		else
			self.activeModules.num = self.activeModules.num - 1;
			print("!!!!!!!!!!!!!!SowingSounds:loadFromAttributesAndNodes -> self.activeModules.num = "..tostring(self.activeModules.num))
		end;	
	end;
    return BaseMission.VEHICLE_LOAD_OK;
end

function SowingSounds:update(dt)

	-- if self:getIsActive() then
        -- if self:getIsActiveForInput() then
            -- if InputBinding.hasEvent(InputBinding.TOGGLE_SEEDERSOUNDS) then
				-- self.sowingSounds.isAllowed = not self.sowingSounds.isAllowed;
			-- end;
		-- end;
	-- end;	
end;

function SowingSounds:updateTick(dt)

	if self:getIsActive() then
		if self.sowingSounds ~= nil and self.sowingSounds.isAllowed then
			if not self.sowingSounds.checkOnLeave then
				self.sowingSounds.checkOnLeave = true;
			end;
			if self:getIsActiveForSound() then
				if not self.allowsLowering then
					if self.isTurnedOn then	
						if not self.sowingSounds.isLowered then
							playSample(self.SeSoSoundId1, 1, 1, 0);
							stopSample(self.SeSoSoundId2);
							-- print("stopSample(self.raised);")
							-- print("playSample(self.lower, 1, 1, 0);")
							self.sowingSounds.isLowered = true;
						end;
					else
						if self.sowingSounds.isLowered then
							playSample(self.SeSoSoundId2, 0, 1, 0);
							-- print("playSample(self.raised, 0, 1, 0);")
							self.sowingSounds.isRaised = true;
							self.sowingSounds.isLowered = false;
						end;
					end;
				end;
			
				if self.isTurnedOn then	
					if self.allowsLowering then
						if not self.sowingSounds.isLowered then
							if self.sowingMachineHasGroundContact then
								playSample(self.SeSoSoundId1, 1, 1, 0);
								-- print("playSample(self.lower, 1, 1, 0);")
								self.sowingSounds.isLowered = true;
							end;
						else		
							if not self.sowingMachineHasGroundContact then
								self.sowingSounds.isLowered = false;
							end;
						end;
					
						if not self.sowingSounds.isRaised then
							if not self.sowingMachineHasGroundContact then
								playSample(self.SeSoSoundId2, 0, 1, 0);
								-- print("playSample(self.raised, 0, 1, 0);")
								self.sowingSounds.isRaised = true;
							end;
						else
							if self.sowingMachineHasGroundContact then
								self.sowingSounds.isRaised = false;
								stopSample(self.SeSoSoundId2);
								-- print("stopSample(self.raised);")
							end;
						end;
					end;
				
					if not self.sowingSounds.isLineActive then					--> falls DrivingLine.lua vorhanden
						if self.drivingLineActiv then
							playSample(self.SeSoSoundId3, 0, 1, 0);
							-- print("playSample(self.line, 0, 1, 0);")
							self.sowingSounds.isLineActive = true;
						end;
					else
						if not self.drivingLineActiv then
							self.sowingSounds.isLineActive = false;
							stopSample(self.SeSoSoundId3);
							-- print("stopSample(self.line);")
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
					if self.sowingSounds.isRaised and self.allowsLowering then
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

renderText(0.1,0.1,0.02,"self.sowingSounds.isAllowed: "..tostring(self.sowingSounds.isAllowed))
end;

function SowingSounds:updateSoSoGUI()
print("!!!!!!!!!!!!!!!!!SowingSounds:updateSoSoGUI()")
	-- create gui tiles (grid position [int], function to call [string], parameter1, parameter2, style [string], label [string], value [], is visible [bool], [Grafik], textSize [float])
	self.tile.sowingSound = SowingSupp.guiElement:New( 6, "toggleOnOff", "Sounds", nil, "toggle", "Sound", self.sowingSounds.isAllowed, true);
end;
