--
-- DrivingLine
-- Specialization for driving lines of sowing machines
--
--	@author:		gotchTOM & webalizer
--	@date: 			22-Dec-2014
--	@version: 	v1.5.8a
--	@history:		v1.0 	- initial implementation (17-Jun-2012)
--							v1.5  - SowingSupplement implementation


DrivingLine = {};

-- local modD = g_currentModDirectory;
-- source(modD.."DrivingLine/drivingLine_Events.lua");
source(g_modsDirectory.."/ZZZ_sowingSupp/DrivingLine/drivingLine_Events.lua");

function DrivingLine.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(SowingMachine, specializations);
end;

function DrivingLine:load(xmlFile)

	self.setDrivingLine = SpecializationUtil.callSpecializationsFunction("setDrivingLine");
	self.setSPworkwidth = SpecializationUtil.callSpecializationsFunction("setSPworkwidth");
	self.setPeMarker = SpecializationUtil.callSpecializationsFunction("setPeMarker");
	self.updateDriLiGUI = SpecializationUtil.callSpecializationsFunction("updateDriLiGUI");

	local numDrivingLines = Utils.getNoNil(getXMLInt(xmlFile, "vehicle.drivingLines#count"),0);
	-- print("numDrivingLines = "..tostring(numDrivingLines))--!!!
	local numPeMarkerLines = Utils.getNoNil(getXMLInt(xmlFile, "vehicle.peMarkerLines#count"),0);
	-- print("numPeMarkerLines = "..tostring(numPeMarkerLines))--!!!
	if numDrivingLines == 0 or numPeMarkerLines == 0 then
		local componentNr = string.sub(getXMLString(xmlFile, "vehicle.aiLeftMarker#index"),1,1) +1;
		self.dlRootNode = self.components[componentNr].node;
		local workAreas = self.workAreaByType[2];
		DrivingLine:workAreaMinMaxHeight(self,workAreas);
		-- print("xMin: "..tostring(self.xMin).."  xMax: "..tostring(self.xMax).."  yStart: "..tostring(self.yStart).."  zHeight: "..tostring(self.zHeight))
		local workWidth = math.abs(self.xMax-self.xMin);
		self.smWorkwith = math.floor(workWidth + 0.5);
		-- print("self.smWorkwith: "..tostring(self.smWorkwith))
		if workWidth > .1 then
			self.wwCenter = (self.xMin+self.xMax)/2;
			if math.abs(self.wwCenter) < 0.1 then
				self.wwCenter = 0;
			end;
		end;
		self.wwCenterPoint = createTransformGroup("wwCenterPoint");
		link(self.dlRootNode, self.wwCenterPoint);
		setTranslation(self.wwCenterPoint,self.wwCenter,self.yStart,self.zHeight-.2);
	end;

	if numDrivingLines > 0 then
		self.drivingLines = {}
		for i=1, numDrivingLines do
			self.drivingLines[i] = {};
			local areanamei = string.format("vehicle.drivingLines.drivingLine" .. "%d", i);
			self.drivingLines[i].start = Utils.indexToObject(self.components, getXMLString(xmlFile, areanamei .. "#startIndex"));
			self.drivingLines[i].width = Utils.indexToObject(self.components, getXMLString(xmlFile, areanamei .. "#widthIndex"));
			self.drivingLines[i].height = Utils.indexToObject(self.components, getXMLString(xmlFile, areanamei .. "#heightIndex"));
		end;
		self.drivingLinePresent = true;
	else
		self.createDrivingLines = SpecializationUtil.callSpecializationsFunction("self.createDrivingLines");
		self.createDrivingLines = DrivingLine.createDrivingLines;
		local worldToDensity = g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize;
		self.dlLaneWidth = .07*worldToDensity--0.4;--0.8;
		self.drivingLineWidth = .6*worldToDensity+self.dlLaneWidth/2--1.2;--1.375;
		self.drivingLines = {}
		self.drivingLines = self:createDrivingLines();
	end;

	if numPeMarkerLines > 0 then
		self.peMarkerLines = {}
		for i=1, numPeMarkerLines do
			self.peMarkerLines[i] = {};
			local areanamei = string.format("vehicle.peMarkerLines.peMarkerLine" .. "%d", i);
			self.peMarkerLines[i].start = Utils.indexToObject(self.components, getXMLString(xmlFile, areanamei .. "#startIndex"));
			self.peMarkerLines[i].width = Utils.indexToObject(self.components, getXMLString(xmlFile, areanamei .. "#widthIndex"));
			self.peMarkerLines[i].height = Utils.indexToObject(self.components, getXMLString(xmlFile, areanamei .. "#heightIndex"));
		end;
		self.peMarkerPresent = true;
	else
		self.createPeMarkerLines = SpecializationUtil.callSpecializationsFunction("self.createPeMarkerLines");
		self.createPeMarkerLines = DrivingLine.createPeMarkerLines;
		self.peMarkerLines = {}
		self.peMarkerLines = self:createPeMarkerLines();
	end;

	if self.peMarkerPresent then
		self.peMarkerActiv = false;
		self.allowPeMarker = true;
	end;

	if self.drivingLinePresent then
		self.drivingLineActiv = false;
		self.IsLoweredBackUp = false;
		-- self.dlAllowUpdate = true;
		self.isPaused = false;
		self.dlCheckOnLeave = false;
		self.hasChanged = false;

		self.dlMode = 0; -- 0 = manual, 1 = semiAutomatic, 2 = automatic
		self.currentLane = 1; --currentDrive
		-- self.smWorkwith = 3;
		self.nSMdrives = 3;
		if (self.nSMdrives%2 == 0) then -- gerade Zahl
			self.num_DrivingLine = (self.nSMdrives / 2) + 1;
		elseif (self.nSMdrives%2 ~= 0) then -- ungerade Zahl
			self.num_DrivingLine = (self.nSMdrives + 1) / 2;
		end;
		-- self.dlWarning = 0;
		self.dlCultivatorDelay = 0;
	end;

	--test
	-- self.dlLastFillLevel = 0;--self.fillLevel;
	-- self.dlLastTime = 0;--g_currentMission.time;
	-- self.diff = 0;
	-- self.testFaktor = .07;
end;

function DrivingLine:delete()
end;

function DrivingLine:readStream(streamId, connection)
	if self.drivingLinePresent then
		self.drivingLineActiv = streamReadBool(streamId);
		self.dlMode = streamReadInt8(streamId);
		self.currentLane = streamReadInt8(streamId);
		self.nSMdrives = streamReadInt8(streamId);
		if (self.nSMdrives%2 == 0) then -- gerade Zahl
			self.num_DrivingLine = (self.nSMdrives / 2) + 1;
		elseif (self.nSMdrives%2 ~= 0) then -- ungerade Zahl
			self.num_DrivingLine = (self.nSMdrives + 1) / 2;
		end;
		-- print("DrivingLine:readStream self.nSMdrives: "..tostring(self.nSMdrives))
		self.isPaused = streamReadBool(streamId);
		self.allowPeMarker = streamReadBool(streamId);
		--print("DrivingLine:readStream self.allowPeMarker: "..tostring(self.allowPeMarker))
		self:updateDriLiGUI();
	end;
end;

function DrivingLine:writeStream(streamId, connection)
	if self.drivingLinePresent then
		streamWriteBool(streamId, self.drivingLineActiv);
		streamWriteInt8(streamId, self.dlMode);
		streamWriteInt8(streamId, self.currentLane);
		streamWriteInt8(streamId, self.nSMdrives);
		-- print("DrivingLine:writeStream self.nSMdrives: "..tostring(self.nSMdrives))
		streamWriteBool(streamId, self.isPaused);
		streamWriteBool(streamId, self.allowPeMarker);
		--print("DrivingLine:writeStream self.allowPeMarker: "..tostring(self.allowPeMarker))
	end;
end;

function DrivingLine:getSaveAttributesAndNodes(nodeIdent)
	local attributes = 'drivingLineIsActiv="'..tostring(self.activeModules.drivingLine)..'" nSMdrives="'..tostring(self.nSMdrives)..'" dlMode="'..tostring(self.dlMode)..'" allowPeMarker="'..tostring(self.allowPeMarker)..'" currentLane="'..tostring(self.currentLane)..'"';
	-- print("!!!!!!!!!!!!!!DrivingLine:getSaveAttributesAndNodes_attributes = "..tostring(attributes))
	return attributes;
end;

function DrivingLine:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
	if self.activeModules ~= nil and self.activeModules.drivingLine and not resetVehicles then
		self.activeModules.drivingLine = Utils.getNoNil(getXMLBool(xmlFile, key .. "#drivingLineIsActiv"), self.activeModules.drivingLine);
		self.nSMdrives = Utils.getNoNil(getXMLInt(xmlFile, key .. "#nSMdrives"), self.nSMdrives);
		-- print("DrivingLine:loadFromAttributesAndNodes self.nSMdrives: "..tostring(self.nSMdrives))
		self.dlMode = Utils.getNoNil(getXMLInt(xmlFile, key .. "#dlMode"), self.dlMode);
		self.allowPeMarker = Utils.getNoNil(getXMLBool(xmlFile, key .. "#allowPeMarker"), self.allowPeMarker);
		self.currentLane = Utils.getNoNil(getXMLInt(xmlFile, key .. "#currentLane"), self.currentLane);
		if (self.nSMdrives%2 == 0) then -- gerade Zahl
			self.num_DrivingLine = (self.nSMdrives / 2) + 1;
		elseif (self.nSMdrives%2 ~= 0) then -- ungerade Zahl
			self.num_DrivingLine = (self.nSMdrives + 1) / 2;
		end;
		self:updateDriLiGUI();
		-- print("!!!!!!!!!!!!!!DrivingLine:loadFromAttributesAndNodes_drivingLineIsActiv = "..tostring(self.activeModules.drivingLine))
		-- print("!!!!!!!!!!!!!!DrivingLine:loadFromAttributesAndNodes_nSMdrives = "..tostring(self.nSMdrives))
		-- print("!!!!!!!!!!!!!!DrivingLine:loadFromAttributesAndNodes_dlMode = "..tostring(self.dlMode))
		-- print("!!!!!!!!!!!!!!DrivingLine:loadFromAttributesAndNodes_allowPeMarker = "..tostring(self.allowPeMarker))
		-- print("!!!!!!!!!!!!!!DrivingLine:loadFromAttributesAndNodes_currentLane = "..tostring(self.currentLane))
	end;
    return BaseMission.VEHICLE_LOAD_OK;
end

function DrivingLine:mouseEvent(posX, posY, isDown, isUp, button)
end;

function DrivingLine:keyEvent(unicode, sym, modifier, isDown)
end;

function DrivingLine:update(dt)

	if self:getIsActiveForInput() then
		if self.drivingLinePresent and self.activeModules ~= nil and self.activeModules.drivingLine then
			-- switch driving line / current drive / pause manually
			if InputBinding.hasEvent(InputBinding.DRIVINGLINE) then
				if self.dlMode == 0 then
					if self.drivingLineActiv then
						self:setDrivingLine(false, self.dlMode, self.currentLane, self.isPaused, self.nSMdrives, self.smWorkwith, self.allowPeMarker);
						-- print("InputBinding.hasEvent(InputBinding.DRIVINGLINE) self:setDrivingLine(false);")
						-- if self.allowPeMarker and self.peMarkerActiv then
							-- self:setPeMarker(false);
						-- end;
					else
						self:setDrivingLine(true, self.dlMode, self.currentLane, self.isPaused, self.nSMdrives, self.smWorkwith, self.allowPeMarker);
						-- print("InputBinding.hasEvent(InputBinding.DRIVINGLINE) self:setDrivingLine(true);")
						self.dlCultivatorDelay = g_currentMission.time + 1000;
						-- if not self.peMarkerActiv then
							-- self:setPeMarker(true);
						-- end;
					end;
				elseif self.dlMode == 1 then
					if self.currentLane < self.nSMdrives then
						self.currentLane = self.currentLane + 1;
					else
						self.currentLane = 1;
					end;
				elseif self.dlMode == 2 then
					self.isPaused = not self.isPaused;
					-- self.hasChanged = true;
				end;
				self:updateDriLiGUI();
			end;
			
			-- if InputBinding.hasEvent(InputBinding.TOGGLE_TURNSIGNAL_RIGHT) then
				-- self.testFaktor = self.testFaktor + .01;
				-- local worldToDensity = g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize;
				-- self.dlLaneWidth = self.testFaktor*worldToDensity;
				-- self.drivingLines = self:createDrivingLines();
			-- end;
			-- if InputBinding.hasEvent(InputBinding.TOGGLE_TURNSIGNAL_LEFT) then
				-- self.testFaktor = self.testFaktor - .01;
				-- local worldToDensity = g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize;
				-- self.dlLaneWidth = self.testFaktor*worldToDensity;
				-- self.drivingLines = self:createDrivingLines();
			-- end;
			
		end;


		--test
		-- if self.isTurnedOn and self.dlLastTime < g_currentMission.time - 1000 then
			-- self.diff = self.fillLevel - self.dlLastFillLevel;

			-- self.dlLastFillLevel = self.fillLevel;
			-- self.dlLastTime = g_currentMission.time;
		-- end;
	end;
end;

function DrivingLine:updateTick(dt)
	if self.drivingLinePresent then
		if self:getIsActive() then
			if self.isServer then
				if self.drivingLineActiv then
					local allowDrivingLine = self.soMaIsLowered;
					--[[local allowDrivingLine = false;
					if self.needsActivation then
						if self.soMaIsLowered and self.isTurnedOn then
							allowDrivingLine = true;
						end;
					else
						if self.soMaIsLowered then
							allowDrivingLine = true;
						end;
					end;]]
					if allowDrivingLine and self.dlCultivatorDelay <= g_currentMission.time then
						local drivingLinesSend = {};
						for i=1, 2 do
							local area = self.drivingLines[i];
							local x,y,z = getWorldTranslation(area.start);
								if g_currentMission:getIsFieldOwnedAtWorldPos(x,z) then
									local x1,y1,z1 = getWorldTranslation(area.width);
									local x2,y2,z2 = getWorldTranslation(area.height);
									-- local wx,wz = x1-x, z1-z;
									-- local hx,hz = x2-x, z2-z;

									local worldToDensity = g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize;

									local lcx,_,lcz = worldToLocal(self.wwCenterPoint,x,y,z);
									local xc,yc,zc = getWorldTranslation(self.wwCenterPoint);
									local diffStartXCenter = lcx--math.abs(xc) - math.abs(x)
									local diffStartZCenter = lcx--math.abs(zc) - math.abs(z)

									local xTemp = math.floor(x*worldToDensity+0.5)/worldToDensity;
									local zTemp = math.floor(z*worldToDensity+0.5)/worldToDensity;
									local diffStartXCenterTemp = math.abs(xc) - math.abs(xTemp)
									local diffStartZCenterTemp = math.abs(zc) - math.abs(zTemp)

									--[[local worldToDensity = g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize;
									x = math.floor(x*worldToDensity+0.5)/worldToDensity;
									z = math.floor(z*worldToDensity+0.5)/worldToDensity;
									x1, z1 = x+wx, z+wz;
									x2, z2 = x+hx, z+hz;
									local rx,ry,rz = getTranslation(area.start)
									local rx1,ry1,rz1 = getTranslation(area.width);
									local rx2,ry2,rz2 = getTranslation(area.height);
									local rwx,rwz = rx1-rx, rz1-rz;
									local rhx,rhz = rx2-rx, rz2-rz;
									local terrainHeight = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, y, z)]]

									if i == 1 then
										-- renderText(0.1,0.3,0.015,"diffStartXCTemp = "..tostring(diffStartXCenterTemp))
										-- renderText(0.1,0.32,0.015,"diffStartXCenter = "..tostring(math.abs(diffStartXCenter)))
										-- renderText(0.1,0.34,0.015,"diffStartZCTemp = "..tostring(math.abs(diffStartZCenterTemp)))
										-- renderText(0.1,0.36,0.015,"diffStartZCenter = "..tostring(math.abs(diffStartZCenter)))
										-- renderText(0.1,0.38,0.015,"x_a = "..tostring(x))
										-- renderText(0.1,0.42,0.015,"z_a = "..tostring(z))
										-- renderText(0.1,0.46,0.015,"wx = "..tostring(wx))
										-- renderText(0.1,0.48,0.015,"wz = "..tostring(wz))
										-- renderText(0.1,0.5,0.015,"hx = "..tostring(hx))
										-- renderText(0.1,0.52,0.015,"hz = "..tostring(hz))
										if math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter) and math.abs(diffStartXCenter) > 1 then
											-- renderText(0.1,0.62,0.015,"math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter)")
											x = math.floor(x*worldToDensity)/worldToDensity;
										else
											x = xTemp;
										end;
										if math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter) and math.abs(diffStartZCenter) > 1 then
											-- renderText(0.1,0.64,0.015,"math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter)")
											z = math.floor(z*worldToDensity)/worldToDensity;
										else
											z = zTemp;
										end;
										-- renderText(0.1,0.4,0.015,"x_b = "..tostring(x))
										-- renderText(0.1,0.44,0.015,"z_b = "..tostring(z))
									elseif i == 2 then
										-- renderText(0.6,0.3,0.015,"diffStartXCTemp = "..tostring(diffStartXCenterTemp))
										-- renderText(0.6,0.32,0.015,"diffStartXCenter = "..tostring(math.abs(diffStartXCenter)))
										-- renderText(0.6,0.34,0.015,"diffStartZCTemp = "..tostring(math.abs(diffStartZCenterTemp)))
										-- renderText(0.6,0.36,0.015,"diffStartZCenter = "..tostring(math.abs(diffStartZCenter)))
										-- renderText(0.6,0.38,0.015,"x_a = "..tostring(x))
										-- renderText(0.6,0.42,0.015,"z_a = "..tostring(z))
										-- renderText(0.6,0.46,0.015,"wx = "..tostring(wx))
										-- renderText(0.6,0.48,0.015,"wz = "..tostring(wz))
										-- renderText(0.6,0.5,0.015,"hx = "..tostring(hx))
										-- renderText(0.6,0.52,0.015,"hz = "..tostring(hz))
										if math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter) and math.abs(diffStartXCenter) > .9 then
											-- renderText(0.6,0.62,0.015,"math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter)")
											x = math.floor(x*worldToDensity)/worldToDensity;
										else
											x = xTemp;
										end;
										if math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter) and math.abs(diffStartZCenter) > .9 then
											-- renderText(0.6,0.64,0.015,"math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter)")
											z = math.floor(z*worldToDensity)/worldToDensity;
										else
											z = zTemp;
										end;
										-- renderText(0.6,0.4,0.015,"x_b = "..tostring(x))
										-- renderText(0.6,0.44,0.015,"z_b = "..tostring(z))
									end;
									
									x1, z1 = x+self.dlLaneWidth, z+self.dlLaneWidth;
									x2, z2 = x+self.dlLaneWidth, z+self.dlLaneWidth;
									-- x1, z1 = x+wx, z+wz;
									-- x2, z2 = x+hx, z+hz;
									table.insert(drivingLinesSend, {x,z,x1,z1,x2,z2});
								end;
						end;
						--[[for _,area in pairs(self.drivingLines) do
							-- if self:getIsAreaActive(area) then
								local x,y,z = getWorldTranslation(area.start);
								if g_currentMission:getIsFieldOwnedAtWorldPos(x,z) then
									local x1,y1,z1 = getWorldTranslation(area.width);
									local x2,y2,z2 = getWorldTranslation(area.height);

									local wx,wz = x1-x, z1-z;
									local hx,hz = x2-x, z2-z;

									local worldToDensity = g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize;
									x = math.floor(x*worldToDensity+0.5)/worldToDensity;
									z = math.floor(z*worldToDensity+0.5)/worldToDensity;

									x1, z1 = x+wx, z+wz;
									x2, z2 = x+hx, z+hz;
									-- x1, z1 = x+self.dlLaneWidth, z+self.dlLaneWidth;
									-- x2, z2 = x+.1, z+.1;
									table.insert(drivingLinesSend, {x,z,x1,z1,x2,z2});
								end;
							-- end;
						end;]]
						if table.getn(drivingLinesSend) > 0 then
							--[[ local limitToField = self.cultivatorLimitToField or self.cultivatorForceLimitToField;
							-- if not g_currentMission.allowClientsCreateFields then
								-- local owner = self:getOwner();
								-- if owner ~= nil and not owner:getIsLocal() then
									-- limitToField = true;
								-- end;
							-- end;]]
							DrivingLineAreaEvent.runLocally(drivingLinesSend, true);
							g_server:broadcastEvent(DrivingLineAreaEvent:new(drivingLinesSend, true));
						end;
						if self.peMarkerActiv then
							local peMarkerLinesSend = {};
							-- renderText(0.1,0.64,0.015,"self.xMin = "..tostring(self.xMin))
							-- renderText(0.1,0.66,0.015,"self.xMax = "..tostring(self.xMax))
							-- renderText(0.1,0.68,0.015,"self.zHeight = "..tostring(self.zHeight))
							for i=1, 2 do
								local area = self.peMarkerLines[i];
								local x,y,z = getWorldTranslation(area.start);
								if g_currentMission:getIsFieldOwnedAtWorldPos(x,z) then
									local x1,y1,z1 = getWorldTranslation(area.width);
									local x2,y2,z2 = getWorldTranslation(area.height);
									local wx,wz = x1-x, z1-z;
									local hx,hz = x2-x, z2-z;

									local worldToDensity = g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize;

									local lcx,_,lcz = worldToLocal(self.wwCenterPoint,x,y,z);
									local xc,yc,zc = getWorldTranslation(self.wwCenterPoint);
									local diffStartXCenter = lcx--math.abs(xc) - math.abs(x)
									local diffStartZCenter = lcx--math.abs(zc) - math.abs(z)

									local xTemp = math.floor(x*worldToDensity+0.5)/worldToDensity;
									local zTemp = math.floor(z*worldToDensity+0.5)/worldToDensity;
									local diffStartXCenterTemp = math.abs(xc) - math.abs(xTemp)
									local diffStartZCenterTemp = math.abs(zc) - math.abs(zTemp)
									-- local lcxTemp,_,lczTemp = worldToLocal(self.wwCenterPoint,xTemp,y,zTemp);

									if i == 1 then
										-- renderText(0.1,0.3,0.015,"diffStartXCTemp = "..tostring(diffStartXCenterTemp))
										-- renderText(0.1,0.32,0.015,"diffStartXCenter = "..tostring(math.abs(diffStartXCenter)))
										-- renderText(0.1,0.34,0.015,"diffStartZCTemp = "..tostring(math.abs(diffStartZCenterTemp)))
										-- renderText(0.1,0.36,0.015,"diffStartZCenter = "..tostring(math.abs(diffStartZCenter)))
										-- renderText(0.1,0.38,0.015,"x_a = "..tostring(x))
										-- renderText(0.1,0.42,0.015,"z_a = "..tostring(z))
										-- renderText(0.1,0.46,0.015,"wx = "..tostring(wx))
										-- renderText(0.1,0.48,0.015,"wz = "..tostring(wz))
										-- renderText(0.1,0.5,0.015,"hx = "..tostring(hx))
										-- renderText(0.1,0.52,0.015,"hz = "..tostring(hz))
										-- local as,bs,cs = getTranslation(area.start)
										-- local aw,bw,cw = getTranslation(area.width)
										-- local ah,bh,ch = getTranslation(area.height)
										-- renderText(0.1,0.54,0.015,"as = "..tostring(as))
										-- renderText(0.1,0.56,0.015,"aw = "..tostring(aw))
										-- renderText(0.1,0.58,0.015,"ch = "..tostring(ch))
										if math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter) and math.abs(diffStartXCenter) > 1 then
											-- renderText(0.1,0.62,0.015,"math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter)")
											x = math.floor(x*worldToDensity)/worldToDensity;
										else
											x = xTemp;
										end;
										if math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter) and math.abs(diffStartZCenter) > 1 then
											-- renderText(0.1,0.64,0.015,"math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter)")
											z = math.floor(z*worldToDensity)/worldToDensity;
										else
											z = zTemp;
										end;
										--[[ if math.abs(diffStartXCenter) > math.abs(diffStartZCenter) then
											if math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter) then
												renderText(0.1,0.62,0.015,"math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter)")
												x = math.floor(x*worldToDensity)/worldToDensity;
												z = math.floor(z*worldToDensity)/worldToDensity;
											else
												x = xTemp;
												z = zTemp;
											end;
										elseif math.abs(diffStartXCenter) < math.abs(diffStartZCenter) then
											if math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter) then
												renderText(0.1,0.64,0.015,"math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter)")
												x = math.floor(x*worldToDensity)/worldToDensity;
												z = math.floor(z*worldToDensity)/worldToDensity;
											else
												x = xTemp;
												z = zTemp;
											end;
										end;]]
										--[[ if math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter) or  math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter) then
											renderText(0.1,0.62,0.015,"math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter)")
											x = math.floor(x*worldToDensity)/worldToDensity;
											z = math.floor(z*worldToDensity)/worldToDensity;
										else
											x = xTemp;
											z = zTemp;
										end;]]

										-- renderText(0.1,0.4,0.015,"x_b = "..tostring(x))
										-- renderText(0.1,0.44,0.015,"z_b = "..tostring(z))
									elseif i == 2 then
										-- renderText(0.6,0.3,0.015,"diffStartXCTemp = "..tostring(diffStartXCenterTemp))
										-- renderText(0.6,0.32,0.015,"diffStartXCenter = "..tostring(math.abs(diffStartXCenter)))
										-- renderText(0.6,0.34,0.015,"diffStartZCTemp = "..tostring(math.abs(diffStartZCenterTemp)))
										-- renderText(0.6,0.36,0.015,"diffStartZCenter = "..tostring(math.abs(diffStartZCenter)))
										-- renderText(0.6,0.38,0.015,"x_a = "..tostring(x))
										-- renderText(0.6,0.42,0.015,"z_a = "..tostring(z))
										-- renderText(0.6,0.46,0.015,"wx = "..tostring(wx))
										-- renderText(0.6,0.48,0.015,"wz = "..tostring(wz))
										-- renderText(0.6,0.5,0.015,"hx = "..tostring(hx))
										-- renderText(0.6,0.52,0.015,"hz = "..tostring(hz))
										-- local as,bs,cs = getTranslation(area.start)
										-- local aw,bw,cw = getTranslation(area.width)
										-- local ah,bh,ch = getTranslation(area.height)
										-- renderText(0.6,0.54,0.015,"as = "..tostring(as))
										-- renderText(0.6,0.56,0.015,"aw = "..tostring(aw))
										-- renderText(0.6,0.58,0.015,"ch = "..tostring(ch))
										if math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter) and math.abs(diffStartXCenter) > .9 then
											-- renderText(0.6,0.62,0.015,"math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter)")
											x = math.floor(x*worldToDensity)/worldToDensity;
										else
											x = xTemp;
										end;
										if math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter) and math.abs(diffStartZCenter) > .9 then
											-- renderText(0.6,0.64,0.015,"math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter)")
											z = math.floor(z*worldToDensity)/worldToDensity;
										else
											z = zTemp;
										end;
										--[[
										-- if math.abs(lcxTemp) > math.abs(lcx) then
										if math.abs(lcxTemp) > math.abs(diffStartXCenter) then
											renderText(0.6,0.62,0.015,"math.abs(lcxTemp) > math.abs(diffStartXCenter)")
											x = math.floor(x*worldToDensity)/worldToDensity;
										else
											x = xTemp;
										end;
										-- if math.abs(lczTemp) > math.abs(lcz) then
										if math.abs(lczTemp) > math.abs(diffStartZCenter) then
											renderText(0.6,0.64,0.015,"math.abs(lczTemp) > math.abs(diffStartZCenter)")
											z = math.floor(z*worldToDensity)/worldToDensity;
										else
											z = zTemp;
										end;]]
										--[[ if math.abs(diffStartXCenter) > math.abs(diffStartZCenter) then
											if math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter) then
												renderText(0.6,0.62,0.015,"math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter)")
												x = math.floor(x*worldToDensity)/worldToDensity;
												z = math.floor(z*worldToDensity)/worldToDensity;
											else
												x = xTemp;
												z = zTemp;
											end;
										elseif math.abs(diffStartXCenter) < math.abs(diffStartZCenter) then
											if math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter) then
												renderText(0.6,0.64,0.015,"math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter)")
												x = math.floor(x*worldToDensity)/worldToDensity;
												z = math.floor(z*worldToDensity)/worldToDensity;
											else
												x = xTemp;
												z = zTemp;
											end;
										end;]]
										--[[ if math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter) or  math.abs(diffStartZCenterTemp) > math.abs(diffStartZCenter) then
											renderText(0.6,0.62,0.015,"math.abs(diffStartXCenterTemp) > math.abs(diffStartXCenter)")
											x = math.floor(x*worldToDensity)/worldToDensity;
											z = math.floor(z*worldToDensity)/worldToDensity;
										else
											x = xTemp;
											z = zTemp;
										end;]]
										-- renderText(0.6,0.4,0.015,"x_b = "..tostring(x))
										-- renderText(0.6,0.44,0.015,"z_b = "..tostring(z))
									end;

									--[[local xc,yc,zc = getWorldTranslation(self.wwCenterPoint);
									local lcx,_,lcz = worldToLocal(self.wwCenterPoint,x,y,z);
									-- local lcx1,_,lcz1 = worldToLocal(self.wwCenterPoint,x1,y1,z1);

									if i == 1 then
										local diffStartXCenter = math.abs(xc) - math.abs(x)
										local diffStartZCenter = math.abs(zc) - math.abs(z)
										renderText(0.1,0.3,0.015,"lcx = "..tostring(lcx))
										renderText(0.1,0.32,0.015,"diffStartXCenter = "..tostring(diffStartXCenter))
										renderText(0.1,0.34,0.015,"lcz = "..tostring(lcz))
										renderText(0.1,0.36,0.015,"diffStartZCenter = "..tostring(diffStartZCenter))
										renderText(0.1,0.38,0.015,"x_a = "..tostring(x))
										renderText(0.1,0.42,0.015,"z_a = "..tostring(z))
										if math.abs(diffStartXCenter) > math.abs(lcx) then--or math.abs(diffStartZCenter) > math.abs(lcz) then
											renderText(0.1,0.62,0.015,"math.abs(diffStartXCenter) > self.drivingLineWidth")
											x = math.floor(x*worldToDensity)/worldToDensity;
											z = math.floor(z*worldToDensity)/worldToDensity;
										else
											x = math.floor(x*worldToDensity+0.5)/worldToDensity;
											z = math.floor(z*worldToDensity+0.5)/worldToDensity;
										end;
										renderText(0.1,0.4,0.015,"x_b = "..tostring(x))
										renderText(0.1,0.44,0.015,"z_b = "..tostring(z))
									elseif i == 2 then
										local diffStartXCenter = math.abs(xc) - math.abs(x)
										local diffStartZCenter = math.abs(zc) - math.abs(z)
										renderText(0.6,0.3,0.015,"lcx = "..tostring(lcx))
										renderText(0.6,0.32,0.015,"diffStartXCenter = "..tostring(diffStartXCenter))
										renderText(0.6,0.34,0.015,"lcz = "..tostring(lcz))
										renderText(0.6,0.36,0.015,"diffStartZCenter = "..tostring(diffStartZCenter))
										renderText(0.6,0.38,0.015,"x_a = "..tostring(x))
										renderText(0.6,0.42,0.015,"z_a = "..tostring(z))
										if math.abs(diffStartXCenter) > math.abs(lcx) then--or math.abs(diffStartZCenter) > math.abs(lcz) then
										renderText(0.6,0.62,0.015,"math.abs(diffStartXCenter) > self.drivingLineWidth")
											x = math.floor(x*worldToDensity)/worldToDensity;
											z = math.floor(z*worldToDensity)/worldToDensity;
										else
											x = math.floor(x*worldToDensity+0.5)/worldToDensity;
											z = math.floor(z*worldToDensity+0.5)/worldToDensity;
										end;
										renderText(0.6,0.4,0.015,"x_b = "..tostring(x))
										renderText(0.6,0.44,0.015,"z_b = "..tostring(z))
									end;	]]

									x1, z1 = x+wx, z+wz;
									x2, z2 = x+hx, z+hz;
									table.insert(peMarkerLinesSend, {x,z,x1,z1,x2,z2});
								end;
							end;
							--[[for _,area in pairs(self.peMarkerLines) do
								-- if self:getIsAreaActive(area) then
									local x,y,z = getWorldTranslation(area.start);
									if g_currentMission:getIsFieldOwnedAtWorldPos(x,z) then
										local x1,y1,z1 = getWorldTranslation(area.width);
										local x2,y2,z2 = getWorldTranslation(area.height);


										local wx,wz = x1-x, z1-z;
										local hx,hz = x2-x, z2-z;

										local worldToDensity = g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize;
										x = math.floor(x*worldToDensity+0.5)/worldToDensity;
										z = math.floor(z*worldToDensity+0.5)/worldToDensity;

										x1, z1 = x+wx, z+wz;
										x2, z2 = x+hx, z+hz;

										table.insert(peMarkerLinesSend, {x,z,x1,z1,x2,z2});
									end;
								-- end;
							end;]]
							if table.getn(peMarkerLinesSend) > 0 then
								--[[ local limitToField = self.cultivatorLimitToField or self.cultivatorForceLimitToField;
								-- if not g_currentMission.allowClientsCreateFields then
									-- local owner = self:getOwner();
									-- if owner ~= nil and not owner:getIsLocal() then
										-- limitToField = true;
									-- end;
								-- end;

								-- renderText(0.1,0.2,0.015,"limitToField = "..tostring(limitToField))
								]]
								CultivatorAreaEvent.runLocally(peMarkerLinesSend, true);
								g_server:broadcastEvent(CultivatorAreaEvent:new(peMarkerLinesSend, true));
							end;
						end;
					end;
				end;
			end;
			if self.dlMode > 0 then
				if self.currentLane > self.nSMdrives then
					self.currentLane = 1;
				elseif self.currentLane < 1 then
					self.currentLane = self.nSMdrives;
				end;

				if self.currentLane == self.num_DrivingLine and not self.drivingLineActiv then--and self.dlCultivatorDelay <= g_currentMission.time then
					self:setDrivingLine(true, self.dlMode, self.currentLane, self.isPaused, self.nSMdrives, self.smWorkwith, self.allowPeMarker);
						--print("self.currentLane == self.num_DrivingLine self:setDrivingLine(true); self.num_DrivingLine: "..tostring(self.num_DrivingLine))
					if self.allowPeMarker and not self.peMarkerActiv then
						self:setPeMarker(true);
					end;
				elseif self.currentLane ~= self.num_DrivingLine and self.drivingLineActiv then--and self.dlCultivatorDelay <= g_currentMission.time then
					self:setDrivingLine(false, self.dlMode, self.currentLane, self.isPaused, self.nSMdrives, self.smWorkwith, self.allowPeMarker);
						--print("self.currentLane ~= self.num_DrivingLine self:setDrivingLine(false); self.num_DrivingLine: "..tostring(self.num_DrivingLine))
					if self.peMarkerActiv then
						self:setPeMarker(false);
					end;
				end;
			end;
			if self.IsLoweredBackUp ~= self.soMaIsLowered then
				if not self.soMaIsLowered then
					if self.dlMode == 2 and not self.isPaused then
						if self.currentLane < self.nSMdrives then
							self.currentLane = self.currentLane + 1;
						else
							self.currentLane = 1;
						end;
						self:updateDriLiGUI();
					end;
				else	
					self.dlCultivatorDelay = g_currentMission.time + 1000;
				end;
				self.IsLoweredBackUp = self.soMaIsLowered;
			end;
		end;
		if self:getIsActiveForInput() then
			if not self.dlCheckOnLeave then
				self.dlCheckOnLeave = true;
			end;
		else
			if self.dlCheckOnLeave then
				if self.hasChanged then
					self:setDrivingLine(self.drivingLineActiv, self.dlMode, self.currentLane, self.isPaused, self.nSMdrives, self.smWorkwith, self.allowPeMarker);
					--print("not self:getIsActiveForInput(),dlCheckOnLeave, hasChanged self:setDrivingLine(nil, "..tostring(self.dlMode)..", "..tostring(self.currentLane)..", "..tostring(self.isPaused)..", "..tostring(self.nSMdrives)..", "..tostring(self.smWorkwith))
					self.hasChanged = false;
				end;
				self.dlCheckOnLeave = false;
			end;
		end;
	end;
end;

function DrivingLine:draw()

	if self.drivingLinePresent and self.activeModules ~= nil and self.activeModules.drivingLine then
		if self.dlMode == 0 then
			if self.drivingLineActiv then
				g_currentMission:addHelpButtonText(SowingMachine.DRIVINGLINE_OFF, InputBinding.DRIVINGLINE);
			else
				g_currentMission:addHelpButtonText(SowingMachine.DRIVINGLINE_ON, InputBinding.DRIVINGLINE);
			end;
		elseif self.dlMode == 1 then
			g_currentMission:addHelpButtonText(SowingMachine.DRIVINGLINE_SHIFT, InputBinding.DRIVINGLINE);
		elseif self.dlMode == 2 then
			if self.isPaused then
				g_currentMission:addHelpButtonText(SowingMachine.DRIVINGLINE_ENABLE, InputBinding.DRIVINGLINE);
			else
				g_currentMission:addHelpButtonText(SowingMachine.DRIVINGLINE_PAUSE, InputBinding.DRIVINGLINE);
			end;
		end;
		-- setTextColor(1,1,1,1);
		-- if self.dlCultivatorDelay > g_currentMission.time then
			-- renderText(0.1,0.16,0.015,"self.dlCultivatorDelay > g_currentMission.time")
		-- end;
		-- local worldToDensity = g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize;
		-- renderText(0.1,0.1,0.015,"g_currentMission.terrainDetailMapSize = "..tostring(g_currentMission.terrainDetailMapSize))
		-- renderText(0.1,0.12,0.015,"g_currentMission.terrainSize = "..tostring(g_currentMission.terrainSize))
		-- renderText(0.1,0.14,0.015,"self.drivingLineActiv = "..tostring(self.drivingLineActiv))
		-- renderText(0.1,0.16,0.015,"self.dlLaneWidth = "..tostring(self.dlLaneWidth))
		-- renderText(0.1,0.18,0.015,"self.hasChanged = "..tostring(self.hasChanged))
	end;
end;

--[[function DrivingLine:setIsTurnedOn()
  if self.drivingLinePresent then
		local rootAttacherVehicle = self:getRootAttacherVehicle();
		if rootAttacherVehicle ~= nil then
			if not self.allowsLowering	and self.dlMode == 2 and not self.isPaused and not self.isTurnedOn
			and (rootAttacherVehicle.isControlled or rootAttacherVehicle.isHired) then
				if self.currentLane < self.nSMdrives then
					self.currentLane = self.currentLane + 1;
				else
					self.currentLane = 1;
				end;
				-- self.hasChanged = true;
				self:updateDriLiGUI();
			end;
		end;
	end;
end;]]

function DrivingLine:setDrivingLine(drivingLineActiv, dlMode, currentLane, isPaused, nSMdrives, smWorkwith, allowPeMarker, noEventSend)
--print("DrivingLine:setDrivingLine(drivingLineActiv: "..tostring(drivingLineActiv)..", dlMode: "..tostring(dlMode)..", currentLane: "..tostring(currentLane)..", isPaused: "..tostring(isPaused)..", nSMdrives: "..tostring(nSMdrives)..", smWorkwith: "..tostring(smWorkwith)..", noEventSend: "..tostring(noEventSend)..")")
	if noEventSend == nil or noEventSend == false then
		SetDrivingLineEvent.sendEvent(self, drivingLineActiv, dlMode, currentLane, isPaused, nSMdrives, smWorkwith, allowPeMarker, noEventSend);
	end;
	if drivingLineActiv ~= nil then
		self.drivingLineActiv = drivingLineActiv;
	end;
	if dlMode ~= nil then
		self.dlMode = dlMode;
	end;
	if currentLane ~= nil then
		self.currentLane = currentLane;
	end;
	if isPaused ~= nil then
		self.isPaused = isPaused;
	end;
	if nSMdrives ~= nil then
		self.nSMdrives = nSMdrives;
	end;
	if smWorkwith ~= nil then
		self.smWorkwith = smWorkwith;
	end;
	if allowPeMarker ~= nil then
		self.allowPeMarker = allowPeMarker;
	end;
	

	-- Kuhn Moduliner
	if self.drivemark ~= nil then
		self.drivemark = self.drivingLineActiv;
	end;
end;

function DrivingLine:setSPworkwidth(raise, noEventSend)
-- print("DrivingLine:setSPworkwidth(raise, noEventSend)")
	if not raise then
		if self.nSMdrives > 3 and self.spWorkwith < 61 then
			self.nSMdrives = self.nSMdrives - 1;
			if self.currentLane > self.nSMdrives then
				self.currentLane = self.nSMdrives;
			end;
		end;
	else
		if self.spWorkwith < 57 then
			self.nSMdrives = self.nSMdrives + 1;
		end;
	end;
	self:updateDriLiGUI();

	-- if noEventSend == nil or noEventSend == false then
		-- SetSPworkwidthEvent.sendEvent(self, raise, noEventSend);
	-- end;
end;

function DrivingLine:setPeMarker(peMarkerActiv, noEventSend)
-- print("DrivingLine:setPeMarker(peMarkerActiv, noEventSend)")
	if noEventSend == nil or noEventSend == false then
		SetPeMarkerEvent.sendEvent(self, peMarkerActiv, noEventSend);
		-- print("DrivingLine:setPeMarker->SetPeMarkerEvent.sendEvent(self, peMarkerActiv, noEventSend);")
	end;
	self.peMarkerActiv = peMarkerActiv;
end;

function DrivingLine:workAreaMinMaxHeight(self,areas)
	self.xMin = 0;
	self.xMax = 0;
	self.yStart = 0;
	self.zHeight = 0;
	if areas ~= nil then
		for _,workArea in pairs(areas) do
			local x1,y1,z1 = getWorldTranslation(workArea.start);
			local x2,y2,z2 = getWorldTranslation(workArea.width);
			local x3,y3,z3 = getWorldTranslation(workArea.height);
			local lx1,ly1,lz1 = worldToLocal(self.dlRootNode,x1,y1,z1);
			local lx2,ly2,lz2 = worldToLocal(self.dlRootNode,x2,y2,z2);
			local lx3,ly3,lz3 = worldToLocal(self.dlRootNode,x3,y3,z3);

			if lx1 < self.xMin then
				self.xMin = lx1;
			end
			if lx1 > self.xMax then
				self.xMax = lx1;
			end
			if lx2 < self.xMin then
				self.xMin = lx2;
			end
			if lx2 > self.xMax then
				self.xMax = lx2;
			end
			if lx3 < self.xMin then
				self.xMin = lx3;
			end;
			if lx3 > self.xMax then
				self.xMax = lx3;
			end
			self.yStart = ly1;
			self.zHeight = lz3;
		end
	end
end;

function DrivingLine:createDrivingLines()
	local drivingLines = {};
	local x = self.wwCenter + self.drivingLineWidth;
	local y = self.yStart;
	local z = self.zHeight - .2;
	local worldToDensity = g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize;
	local hz = z - self.dlLaneWidth;
	for i=1, 2 do
		local startId = createTransformGroup("start"..i);
		link(self.dlRootNode, startId);
		setTranslation(startId,x,y,z);
		-- print("DrivingLine"..tostring(i).." start x: "..tostring(x).." y: "..tostring(y).." z: "..tostring(z));
		local heightId = createTransformGroup("height"..i);
		link(self.dlRootNode, heightId);
		setTranslation(heightId,x,y,hz);
		-- print("DrivingLine"..tostring(i).." height x: "..tostring(x).." y: "..tostring(y).." hz: "..tostring(hz));
		x = x - self.dlLaneWidth;
		local widthId = createTransformGroup("width"..i);
		link(self.dlRootNode, widthId);
		setTranslation(widthId,x,y,z);
		-- print("DrivingLine"..tostring(i).." width x: "..tostring(x).." y: "..tostring(y).." z: "..tostring(z));
		x = self.wwCenter - (self.drivingLineWidth-self.dlLaneWidth);--0.65;

		table.insert(drivingLines, {foldMinLimit=0,start=startId,height=heightId,foldMaxLimit=0.2,width=widthId});
	end;
	self.drivingLinePresent = true;
	print("Created driving lines!");
	return drivingLines;
end;

function DrivingLine:createPeMarkerLines()
	local peMarkerLines = {};
	local worldToDensity = g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize;
	local x = self.wwCenter + .6*worldToDensity--1.1;--self.drivingLineWidth;--1.225;
	local y = self.yStart;
	local z = self.zHeight - .2;
	local hz = z-- - .05*worldToDensity
	for i=1, 2 do
		local startId = createTransformGroup("start"..i);
		link(self.dlRootNode, startId);
		setTranslation(startId,x,y,z);
		-- print("peMarkerLine"..tostring(i).." start x: "..tostring(x).." y: "..tostring(y).." z: "..tostring(z));
		local heightId = createTransformGroup("height"..i);
		link(self.dlRootNode, heightId);
		setTranslation(heightId,x,y,hz);
		-- print("peMarkerLine"..tostring(i).." height x: "..tostring(x).." y: "..tostring(y).." hz: "..tostring(hz));
		-- x = x - .05*worldToDensity;
		local widthId = createTransformGroup("width"..i);
		link(self.dlRootNode, widthId);
		setTranslation(widthId,x,y,z);
		-- print("peMarkerLine"..tostring(i).." width x: "..tostring(x).." y: "..tostring(y).." z: "..tostring(z));
		x = self.wwCenter - .5*worldToDensity --+.025*worldToDensity;--self.drivingLineWidth-0.1--1.125;

		table.insert(peMarkerLines, {foldMinLimit=0,start=startId,height=heightId,foldMaxLimit=0.2,width=widthId});
	end;
	self.peMarkerPresent = true;
	print("Created peMarker Lines!");
	return peMarkerLines;
end;

function DrivingLine:updateDriLiGUI()
	if self.activeModules ~= nil then
		if self.activeModules.drivingLine then
			-- print("DrivingLine:updateDriLiGUI()")
			self.hud1.grids.main.elements.driLiMode.isVisible = true;
			if self.dlMode == 0 then
				self.hud1.grids.main.elements.driLiMode.value = SowingMachine.DRIVINGLINE_MANUAL;
				self.hud1.grids.main.elements.driLiMode.buttonSet.button1IsActive = false;
				self.hud1.grids.main.elements.driLiMode.buttonSet.button2IsActive = true;
			elseif self.dlMode == 2 then
				self.hud1.grids.main.elements.driLiMode.value = SowingMachine.DRIVINGLINE_AUTO;
				self.hud1.grids.main.elements.driLiMode.buttonSet.button1IsActive = true;
				self.hud1.grids.main.elements.driLiMode.buttonSet.button2IsActive = false;
			else --self.dlMode = 1
				self.hud1.grids.main.elements.driLiMode.value = SowingMachine.DRIVINGLINE_SEMIAUTO;
				self.hud1.grids.main.elements.driLiMode.buttonSet.button1IsActive = true;
				self.hud1.grids.main.elements.driLiMode.buttonSet.button2IsActive = true;
			end;
			
			self.hud1.grids.main.elements.driLiPeMarker.isVisible = true;
			self.hud1.grids.main.elements.driLiPeMarker.value = self.allowPeMarker;
			if self.allowPeMarker then
				if self.drivingLineActiv and not self.peMarkerActiv then
					self:setPeMarker(true);
				end;
			else
				if self.drivingLineActiv and self.peMarkerActiv then
					self:setPeMarker(false);
				end;
			end;
			
			self.hud1.grids.main.elements.info_workWidth.isVisible = true;
			self.hud1.grids.main.elements.info_workWidth.value = self.smWorkwith.."m";
			
			if self.dlMode > 0 then
				self.hud1.grids.main.elements.driLiSpWorkWidth.isVisible = true;
				self.spWorkwith = self.smWorkwith * self.nSMdrives;
				-- print("DrivingLine:updateDriLiGUI() "..tostring(self.spWorkwith).."="..tostring(self.smWorkwith).."*"..tostring(self.nSMdrives))
				if (self.nSMdrives%2 == 0) then -- gerade Zahl
					self.num_DrivingLine = (self.nSMdrives / 2) + 1;
				elseif (self.nSMdrives%2 ~= 0) then -- ungerade Zahl
					self.num_DrivingLine = (self.nSMdrives + 1) / 2;
				end;
				self.hud1.grids.main.elements.driLiSpWorkWidth.value = self.spWorkwith.."m";
				
				if self.nSMdrives == 3 then
					self.hud1.grids.main.elements.driLiSpWorkWidth.buttonSet.button1IsActive = false;
					self.hud1.grids.main.elements.driLiSpWorkWidth.buttonSet.button2IsActive = true;
				elseif self.spWorkwith >= 57 then
					self.hud1.grids.main.elements.driLiSpWorkWidth.buttonSet.button1IsActive = true;
					self.hud1.grids.main.elements.driLiSpWorkWidth.buttonSet.button2IsActive = false;
				else
					self.hud1.grids.main.elements.driLiSpWorkWidth.buttonSet.button1IsActive = true;
					self.hud1.grids.main.elements.driLiSpWorkWidth.buttonSet.button2IsActive = true;
				end;
				
				self.hud1.grids.main.elements.driLiCurDrive.isVisible = true;
				self.hud1.grids.main.elements.driLiCurDrive.value = self.currentLane.." / "..self.nSMdrives;
				
				self.hud1.grids.main.elements.info_numDrivingLine.isVisible = true;
				self.hud1.grids.main.elements.info_numDrivingLine.value = self.num_DrivingLine;
			else --self.dlMode = 0
				self.hud1.grids.main.elements.driLiSpWorkWidth.isVisible = false;
				self.hud1.grids.main.elements.driLiCurDrive.isVisible = false;
				self.hud1.grids.main.elements.info_numDrivingLine.isVisible = false;
			end;
			self.hasChanged = true;
		else -- = not self.activeModules.drivingLine
			self.hud1.grids.main.elements.driLiSpWorkWidth.isVisible = false;
			self.hud1.grids.main.elements.driLiMode.isVisible = false;
			self.hud1.grids.main.elements.driLiPeMarker.isVisible = false;
			self.hud1.grids.main.elements.driLiCurDrive.isVisible = false;
			self.hud1.grids.main.elements.info_workWidth.isVisible = false;
			self.hud1.grids.main.elements.info_numDrivingLine.isVisible = false;

			self.hud1.grids.config.elements.driLiModul.value = false;
		end;
	end;
end;