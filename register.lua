SpecializationUtil.registerSpecialization("sowingSupp", "SowingSupp", g_currentModDirectory.."sowingSupp.lua")
SpecializationUtil.registerSpecialization("sowingCounter", "SowingCounter", g_currentModDirectory.."SowingCounter/sowingCounter.lua")
SpecializationUtil.registerSpecialization("sowingSounds", "SowingSounds", g_currentModDirectory.."SowingSounds/sowingSounds.lua")

SowingSupp_Register = {};

function SowingSupp_Register:loadMap(name)
	if self.firstRun == nil then
		self.firstRun = false;

		for k, v in pairs(VehicleTypeUtil.vehicleTypes) do
			if v ~= nil then
				for i = 1, table.maxn(v.specializations) do
					local vs = v.specializations[i];
					if vs ~= nil and vs == SpecializationUtil.getSpecialization("sowingMachine") then
						local allowInsertion = true;
						local v_name_string = v.name
						local point_location = string.find(v_name_string, ".", nil, true)
						if point_location ~= nil then
							local _name = string.sub(v_name_string, 1, point_location-1);
							if rawget(SpecializationUtil.specializations, string.format("%s.sowingSupp", _name)) ~= nil then
								allowInsertion = false;
								print(tostring(v.name)..": Specialization sowingSupp is present! SowingSupp was not inserted!");
							end;
							if rawget(SpecializationUtil.specializations, string.format("%s.SowingSupp", _name)) ~= nil then
								allowInsertion = false;
								print(tostring(v.name)..": Specialization SowingSupp is present! SowingSupp was not inserted!");
							end;
							if rawget(SpecializationUtil.specializations, string.format("%s.F_35", _name)) ~= nil then
								allowInsertion = false;
								print(tostring(v.name)..": Specialization F_35 is present! SowingSupp was not inserted!");
							end;
						end;
						if allowInsertion then
							-- print("adding SowingSupp to:"..tostring(v.name));
							table.insert(v.specializations, SpecializationUtil.getSpecialization("sowingSupp"));
							vs.SOWINGSUPP_HUDon = g_i18n:getText("SOWINGSUPP_HUDon");
							vs.SOWINGSUPP_HUDoff = g_i18n:getText("SOWINGSUPP_HUDoff");
							vs.SowingCounter = g_i18n:getText("SowingCounter");
							vs.SowingSounds = g_i18n:getText("SowingSounds");
							table.insert(v.specializations, SpecializationUtil.getSpecialization("sowingCounter"));
							table.insert(v.specializations, SpecializationUtil.getSpecialization("sowingSounds"));
						end;
					end;
				end;
			end;
		end;
	end;
end;

function SowingSupp_Register:deleteMap()

end;

function SowingSupp_Register:keyEvent(unicode, sym, modifier, isDown)

end;

function SowingSupp_Register:mouseEvent(posX, posY, isDown, isUp, button)

end;

function SowingSupp_Register:update(dt)

end;

function SowingSupp_Register:draw()

end;

addModEventListener(SowingSupp_Register);
