--[[Graphic Herbalism Server Scripts 1.23 - Developed with tes3mp 0.7.0-alpha
This is necessary because graphic herbalism mods work using a global player variable that is not saved correctly

Installation

Save this file in the mp-stuff\scripts\ directory.
These edits will be made in the same directory in the serverCore.lua file.

1a) Add: graphicHerbalism = require("graphicHerbalism")
under: menuHelper = require("menuHelper") ~line 14

1b) Add: graphicHerbalism.OnServerPostInit()
under: ResetAdminCounter() ~line 285

1c) Add: graphicHerbalism.OnCellLoad(pid, cellDescription)
under: eventHandler.OnCellLoad(pid, cellDescription) ~line 460

Save/close serverCore.lua and open eventHandler.lua

2a) Add: if graphicHerbalism.CanPickPlant(objectRefId) then
		    graphicHerbalism.OnObjectActivate(objectRefId, pid, objectUniqueIndex)
		 	isValid = false --disable inventory screen
		 end
under: objectUniqueIndex = tes3mp.GetObjectRefNum(index) .. "-" .. tes3mp.GetObjectMpNum(index) ~line 609

If you'd like to change the default 3 in game day plant respawn, you can edit the 'local growthDays = 3' variable on line 33 of this script.

The line numbers are approximations and can change in the future.
-------------------------------------------------------------------------]]

local jsonInterface = require("jsonInterface")
local pickData = nil
local growthDays = 3 --How many in game days it takes for the plant to respawn, tracked to the hour. Decimal numbers will not work
--					   (e.g. if you pick a plant at 11pm on day 1, it will not respawn until 11pm on day 4)

local function SaveJSON(pickData)
	jsonInterface.save("graphicHerbalism.json", pickData)
end

local function GetIngredient(plantRefId) --this will return how many we need to add, the name for the message, and the reference ID
	local plantList = {
		{["checkRefId"] = "flora_ash_yam_", ["name"] = "Ash Yam", ["ingredientRefId"] = "ingred_ash_yam_01", ["chanceCount"] = 1, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_bittergreen_", ["name"] = "Bittergreen Petal", ["ingredientRefId"] = "ingred_bittergreen_petals_01", ["chanceCount"] = 2, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_black_anther_", ["name"] = "Black Anther", ["ingredientRefId"] = "ingred_black_anther_01", ["chanceCount"] = 2, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_black_lichen_", ["name"] = "Black Lichen", ["ingredientRefId"] = "ingred_black_lichen_01", ["chanceCount"] = 1, ["chanceNone"] = 3/10},
		{["checkRefId"] = "cavern_spore00", ["name"] = "Bloat", ["ingredientRefId"] = "ingred_bloat_01", ["chanceCount"] = 1, ["chanceNone"] = 3/10},
		{["checkRefId"] = "flora_bc_shelffungus_01,flora_bc_shelffungus_02", ["name"] = "Bungler's Bane", ["ingredientRefId"] = "ingred_bc_bungler", ["chanceCount"] = 1, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_bc_shelffungus_03,flora_bc_shelffungus_04", ["name"] = "Hypha Facia", ["ingredientRefId"] = "ingred_bc_hypha_facia", ["chanceCount"] = 1, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_chokeweed_02", ["name"] = "Chokeweed", ["ingredientRefId"] = "ingred_chokeweed_01", ["chanceCount"] = 1, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_comberry_01", ["name"] = "Comberry", ["ingredientRefId"] = "ingred_comberry_01", ["chanceCount"] = 1, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_bc_podplant_01,flora_bc_podplant_02", ["name"] = "Ampoule Pod", ["ingredientRefId"] = "ingred_bc_ampoule_pod", ["chanceCount"] = 1, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_bc_podplant_03,flora_bc_podplant_04", ["name"] = "Coda Flower", ["ingredientRefId"] = "ingred_bc_coda_flower", ["chanceCount"] = 1, ["chanceNone"] = 2.5/10},
		{["checkRefId"] = "flora_corkbulb", ["name"] = "Corkbulb Root", ["ingredientRefId"] = "ingred_corkbulb_root_01", ["chanceCount"] = 1, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_fire_fern_", ["name"] = "Fire Petal", ["ingredientRefId"] = "ingred_fire_petal_01", ["chanceCount"] = 1, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_gold_kanet_uni", ["name"] = "Roland's Tear", ["ingredientRefId"] = "ingred_gold_kanet_unique", ["chanceCount"] = 3, ["chanceNone"] = 0},
		{["checkRefId"] = "flora_gold_kanet_", ["name"] = "Gold Kanet", ["ingredientRefId"] = "ingred_gold_kanet_01", ["chanceCount"] = 1, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_sedge_01", ["name"] = "Golden Sedge Flower", ["ingredientRefId"] = "ingred_golden_sedge_01", ["chanceCount"] = 1, ["chanceNone"] = 3/10},
		{["checkRefId"] = "flora_green_lichen_", ["name"] = "Green Lichen", ["ingredientRefId"] = "ingred_green_lichen_01", ["chanceCount"] = 1, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_hackle", ["name"] = "Hackle-Lo Leaf", ["ingredientRefId"] = "ingred_hackle-lo_leaf_01", ["chanceCount"] = 1, ["chanceNone"] = 2.5/10},
		{["checkRefId"] = "flora_heather_01", ["name"] = "Heather", ["ingredientRefId"] = "ingred_heather_01", ["chanceCount"] = 2, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_plant_01", ["name"] = "Horn Lily Bulb", ["ingredientRefId"] = "ingred_horn_lily_bulb_01", ["chanceCount"] = 2, ["chanceNone"] = 3/10},
		{["checkRefId"] = "flora_kreshweed_", ["name"] = "Kresh Fiber", ["ingredientRefId"] = "ingred_kresh_fiber_01", ["chanceCount"] = 1, ["chanceNone"] = 2/10},
		{["checkRefId"] = "egg_kwama00", ["name"] = "Large Kwama Egg", ["ingredientRefId"] = "food_kwama_egg_02", ["chanceCount"] = 1, ["chanceNone"] = 0},
		{["checkRefId"] = "flora_bc_mushroom_01,flora_bc_mushroom_02,flora_bc_mushroom_03,flora_bc_mushroom_04,flora_bc_mushroom_05", ["name"] = "Luminous Russula", ["ingredientRefId"] = "ingred_russula_01", ["chanceCount"] = 2, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_bc_mushroom_06,flora_bc_mushroom_07,flora_bc_mushroom_08", ["name"] = "Violet Coprinus", ["ingredientRefId"] = "ingred_coprinus_01", ["chanceCount"] = 2, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_marshmerrow_", ["name"] = "Marshmerrow", ["ingredientRefId"] = "ingred_marshmerrow_01", ["chanceCount"] = 1, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_plant_04", ["name"] = "Meadow Rye", ["ingredientRefId"] = "ingred_meadow_rye_01", ["chanceCount"] = 2, ["chanceNone"] = 0},
		{["checkRefId"] = "flora_muckspunge_", ["name"] = "Muck", ["ingredientRefId"] = "ingred_muck_01", ["chanceCount"] = 1, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_plant_02", ["name"] = "Nirthfly Stalk", ["ingredientRefId"] = "ingred_nirthfly_stalks_01", ["chanceCount"] = 2, ["chanceNone"] = 3/10},
		{["checkRefId"] = "flora_sedge_02", ["name"] = "Noble Sedge Flower", ["ingredientRefId"] = "ingred_noble_sedge_01", ["chanceCount"] = 1, ["chanceNone"] = 3/10},
		{["checkRefId"] = "flora_red_lichen_", ["name"] = "Red Lichen", ["ingredientRefId"] = "ingred_red_lichen_01", ["chanceCount"] = 1, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_roobrush_", ["name"] = "Roobrush", ["ingredientRefId"] = "ingred_roobrush_01", ["chanceCount"] = 1, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_rm_scathecraw_", ["name"] = "Scathecraw", ["ingredientRefId"] = "ingred_scathecraw_01", ["chanceCount"] = 1, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_saltrice_", ["name"] = "Saltrice", ["ingredientRefId"] = "ingred_saltrice_01", ["chanceCount"] = 1, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_plant_07", ["name"] = "Scrib Cabbage", ["ingredientRefId"] = "ingred_scrib_cabbage_01", ["chanceCount"] = 2, ["chanceNone"] = 3/10},
		{["checkRefId"] = "flora_bc_fern_01", ["name"] = "Spore Pod", ["ingredientRefId"] = "ingred_bc_spore_pod", ["chanceCount"] = 3, ["chanceNone"] = 0},
		{["checkRefId"] = "flora_bc_fern_04_chuck", ["name"] = "Meteor Slime", ["ingredientRefId"] = "ingred_scrib_jelly_02", ["chanceCount"] = 1, ["chanceNone"] = 0},
		{["checkRefId"] = "flora_plant_08", ["name"] = "Lloramor Spine", ["ingredientRefId"] = "ingred_lloramor_spines_01", ["chanceCount"] = 2, ["chanceNone"] = 0},
		{["checkRefId"] = "flora_stoneflower_", ["name"] = "Stoneflower Petal", ["ingredientRefId"] = "ingred_stoneflower_petals_01", ["chanceCount"] = 1, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_plant_05,flora_plant_06", ["name"] = "Sweetpulp", ["ingredientRefId"] = "ingred_sweetpulp_01", ["chanceCount"] = 2, ["chanceNone"] = 3/10},
		{["checkRefId"] = "flora_plant_03", ["name"] = "Timsa-Come-By Flower", ["ingredientRefId"] = "ingred_timsa-come-by_01", ["chanceCount"] = 2, ["chanceNone"] = 3/10},
		{["checkRefId"] = "tramaroot_01,contain_trama_shrub_", ["name"] = "Trama Root", ["ingredientRefId"] = "ingred_trama_root_01", ["chanceCount"] = 3, ["chanceNone"] = 2/10},
		{["checkRefId"] = "tramaroot_", ["name"] = "Trama Root", ["ingredientRefId"] = "ingred_trama_root_01", ["chanceCount"] = 1, ["chanceNone"] = 2/10},
		{["checkRefId"] = "contain_trama_shrub_05,contain_trama_shrub_01", ["name"] = "ingred_trama_root_01", ["ingredientRefId"] = "ingred_trama_root_01", ["chanceCount"] = 2, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_wickwheat_", ["name"] = "Wickwheat", ["ingredientRefId"] = "ingred_wickwheat_01", ["chanceCount"] = 1, ["chanceNone"] = 1/10},
		{["checkRefId"] = "flora_willow_flower_", ["name"] = "Willow Anther", ["ingredientRefId"] = "ingred_willow_anther_01", ["chanceCount"] = 1, ["chanceNone"] = 1.5/10},
		{["checkRefId"] = "flora_bm_belladonna_03", ["name"] = "ripened Belladonna Berries", ["ingredientRefId"] = "ingred_belladonna_01", ["chanceCount"] = 1, ["chanceNone"] = 0},
		{["checkRefId"] = "flora_bm_belladonna_", ["name"] = "unripened Belladonna Berries", ["ingredientRefId"] = "ingred_belladonna_02", ["chanceCount"] = 1, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_bm_holly_", ["name"] = "Holly Berries", ["ingredientRefId"] = "ingred_holly_01", ["chanceCount"] = 1, ["chanceNone"] = 2/10},
		{["checkRefId"] = "flora_bm_wolfsbane_01", ["name"] = "Wolfsbane Petal", ["ingredientRefId"] = "ingred_wolfsbane_01", ["chanceCount"] = 1, ["chanceNone"] = 0}
	}
	
	local ingredient = {}
	ingredient.Count = 0
	
	local ingredientChanceCount = 0
	local ingredientChanceNone = 0
	
	for _, value in pairs(plantList) do
		local multipleRefId = value["checkRefId"]:split(",")
		
		for _, valueRefId in pairs(multipleRefId) do --if there are multiple ref ID's, they will all be checked
			if string.match(plantRefId, valueRefId) then
				ingredient.Name = value["name"]
				ingredient.RefId = value["ingredientRefId"]
				ingredientChanceCount = value["chanceCount"]
				ingredientChanceNone = value["chanceNone"]
				break
			end
		end
	end
	
	for i = 1, ingredientChanceCount, 1 do
		if math.random() > ingredientChanceNone then --this is run in a loop to calculate 'for each' like vanilla
			ingredient.Count = ingredient.Count + 1
		end
	end
	
	return ingredient
end

local function InventoryManagement(plantRefId, pid)
	local ingredient = GetIngredient(plantRefId)
	
	if ingredient.Count > 0 then
		inventoryHelper.addItem(Players[pid].data.inventory, ingredient.RefId, ingredient.Count, -1, -1, "")
		
		local item = {}
		item.refId = ingredient.RefId
		item.charge = -1
		item.enchantmentCharge = -1
		item.count = ingredient.Count
		item.soul = ""
		
		Players[pid]:LoadItemChanges({item}, enumerations.inventory.ADD)
		
		local message = ""
		
		if ingredient.Count > 1 then
			message = "You harvested %d %ss."
			
			local lastLetter = string.sub(ingredient.Name, -1)
			if lastLetter == "s" then
				ingredient.Name = ingredient.Name .. "'" --if it ends in s, change to s'
				message = "You harvested %d %s."
			end
		else
			message = "You harvested %d %s."
		end
		
		tes3mp.MessageBox(pid, -1, string.format(message, ingredient.Count, ingredient.Name))
		tes3mp.PlaySpeech(pid, "Fx/item/item.wav")
	else
		tes3mp.MessageBox(pid, -1, "You failed to harvest anything useful.")
		tes3mp.PlaySpeech(pid, "Fx/item/blunt.wav")
	end
end

local GraphicHerbalism = {}

function GraphicHerbalism.OnServerPostInit() --load the file or create if necessary
	local jsonFile = io.open(os.getenv("MOD_DIR") .. "/graphicHerbalism.json", "r")
	io.close()
	
	if jsonFile == nil then
		pickData = {}
		SaveJSON(pickData)
	else
		pickData = jsonInterface.load("graphicHerbalism.json")
	end
end

function GraphicHerbalism.CanPickPlant(plantRefId)
	local plants = {"cavern_spore00", "contain_trama_shrub_", "egg_kwama00", "flora_", "tramaroot_"}
	
	local result = false
	
	for _, value in pairs(plants) do
		if string.match(plantRefId, value) then
			result = true
			break
		else
			result = false
		end
	end
	
	return result
end

function GraphicHerbalism.OnCellLoad(pid, cellDescription)
	if pickData[cellDescription] ~= nil then
		local deletedCount = 0
		local loopCount = 0
		tes3mp.ClearObjectList()
		tes3mp.SetObjectListPid(pid)
		tes3mp.SetObjectListCell(cellDescription)
		
		for uniqueIndex, plant in pairs(pickData[cellDescription]) do
			loopCount = loopCount + 1
			
			--if this is the day it should respawn we need to check the hour
			if WorldInstance.data.time.daysPassed - plant['daysPassed'] == growthDays and math.floor(WorldInstance.data.time.hour) - plant['hour'] >= 0 or WorldInstance.data.time.daysPassed - plant['daysPassed'] >= growthDays + 1 then
				if LoadedCells[cellDescription].data.objectData[uniqueIndex] ~= nil then
					local splitIndex = uniqueIndex:split("-")
					
					logicHandler.RunConsoleCommandOnObject("Enable", cellDescription, plant['plantRefId'], splitIndex[1], splitIndex[2])
					
					local objectData = {}
					objectData.refId = plant['plantRefId']
					objectData.state = true
					
					packetBuilder.AddObjectState(uniqueIndex, objectData)
					LoadedCells[cellDescription].data.objectData[uniqueIndex].state = true
					tes3mp.SendObjectState()
					
					pickData[cellDescription][uniqueIndex] = nil --delete reference
					
					deletedCount = deletedCount + 1
				else
					pickData[cellDescription][uniqueIndex] = nil
					deletedCount = deletedCount + 1
				end
			end
		end
		
		if loopCount == deletedCount then
			pickData[cellDescription] = nil --delete cell from json if there are no references in it
		end
		
		if deletedCount > 0 then
			SaveJSON(pickData)
		end
	end
end

function GraphicHerbalism.OnObjectActivate(plantRefId, pid, uniqueIndex)
	local cellDescription = tes3mp.GetCell(pid)
	
	if pickData == nil then
		pickData = {}
	end
	
	if pickData[cellDescription] == nil then
		pickData[cellDescription] = {}
	end
	
	if pickData[cellDescription][uniqueIndex] == nil then
		pickData[cellDescription][uniqueIndex] = {}
	end
	
	pickData[cellDescription][uniqueIndex].plantRefId = plantRefId
	pickData[cellDescription][uniqueIndex].daysPassed = WorldInstance.data.time.daysPassed
	pickData[cellDescription][uniqueIndex].hour = math.floor(WorldInstance.data.time.hour)
	
	local splitIndex = uniqueIndex:split("-")
	logicHandler.RunConsoleCommandOnObject("Disable", cellDescription, plantRefId, splitIndex[1], splitIndex[2])
	
	InventoryManagement(plantRefId, pid)
	
	SaveJSON(pickData)
end

return GraphicHerbalism