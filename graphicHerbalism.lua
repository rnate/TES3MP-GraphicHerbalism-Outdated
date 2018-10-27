--[[Graphic Herbalism Server Scripts 1.1 - Developed with tes3mp 0.7.0-alpha
This is necessary because graphic herbalism mods work using a global player variable that is not saved correctly

Installation
Save this file in the mp-stuff\scripts\ directory.
These edits will be made in the same directory in the eventHandler.lua file.

1) Add: graphicHerbalism = require("graphicHerbalism")
under: commandHandler = require("commandHandler") ~line 3

2) Add: graphicHerbalism.OnPlayerConnect()
under: tes3mp.StartTimer(Players[pid].loginTimerId) ~line 49

3) Add: graphicHerbalism.OnCellLoad(pid, cellDescription)
under: logicHandler.LoadCellForPlayer(pid, cellDescription) ~line 490

4) Add:  if graphicHerbalism.CanPickPlant(objectRefId) then
			graphicHerbalism.OnObjectActivate(objectRefId, pid, objectUniqueIndex)
			isValid = false --disable inventory screen
		end
under: objectUniqueIndex = tes3mp.GetObjectRefNum(index) .. "-" .. tes3mp.GetObjectMpNum(index) ~line 600

If you'd like to change the default 3 in game day plant respawn, you can edit the 'local growthDays = 3' variable on line 26 of my script.

The line numbers are approximations and can change in the future
-------------------------------------------------------------------------]]

local jsonInterface = require("jsonInterface")
local growthDays = 3 --How many in game days it takes for the plant to respawn, tracked to the hour. Decimal numbers will not work
--					   (e.g. if you pick a plant at 11pm on day 1, it will not respawn until 11pm on day 4)

local function SaveJSON(pickData)
	jsonInterface.save("graphicHerbalism.json", pickData)
end

local function LoadJSON()
	pickData = jsonInterface.load("graphicHerbalism.json")
end

local function GetIngredient(plantRefId) --this will return how many we need to add, the name for the message, and the reference ID
	local Ingredient = {}
	Ingredient.Count = 0

	local ingredientChanceCount = 0
	local ingredientChanceNone = 0

	if string.match(plantRefId, "flora_ash_yam_") then
		Ingredient.Name = "Ash Yam"
		Ingredient.RefId = "ingred_ash_yam_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_bittergreen_") then
		Ingredient.Name = "Bittergreen Petal"
		Ingredient.RefId = "ingred_bittergreen_petals_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_black_anther_") then
		Ingredient.Name = "Black Anther"
		Ingredient.RefId = "ingred_black_anther_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_black_lichen_") then
		Ingredient.Name = "Black Lichen"
		Ingredient.RefId = "ingred_black_lichen_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 3/10
	elseif string.match(plantRefId, "cavern_spore00") then
		Ingredient.Name = "Bloat"
		Ingredient.RefId = "ingred_bloat_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 3/10
	elseif string.match(plantRefId, "flora_bc_shelffungus_01") or string.match(plantRefId, "flora_bc_shelffungus_02") then
		Ingredient.Name = "Bungler's Bane"
		Ingredient.RefId = "ingred_bc_bungler's_bane"
		ingredientChanceCount = 1
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_bc_shelffungus_03") or string.match(plantRefId, "flora_bc_shelffungus_04") then
		Ingredient.Name = "Hypha Facia"
		Ingredient.RefId = "ingred_bc_hypha_facia"
		ingredientChanceCount = 1
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_chokeweed_02") then
		Ingredient.Name = "Chokeweed"
		Ingredient.RefId = "ingred_chokeweed_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_comberry_01") then
		Ingredient.Name = "Comberry"
		Ingredient.RefId = "ingred_comberry_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_bc_podplant_01") or string.match(plantRefId, "flora_bc_podplant_02") then
		Ingredient.Name = "Ampoule Pod"
		Ingredient.RefId = "ingred_bc_ampoule_pod"
		ingredientChanceCount = 1
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_bc_podplant_03") or string.match(plantRefId, "flora_bc_podplant_04") then
		Ingredient.Name = "Coda Flower"
		Ingredient.RefId = "ingred_bc_coda_flower"
		ingredientChanceCount = 1
		ingredientChanceNone = 2.5/10
	elseif string.match(plantRefId, "flora_corkbulb") then
		Ingredient.Name = "Corkbulb Root"
		Ingredient.RefId = "ingred_corkbulb_root_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_fire_fern_") then
		Ingredient.Name = "Fire Petal"
		Ingredient.RefId = "ingred_fire_petal_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_gold_kanet_") and string.match(plantRefId, "_uni") then --this is a unique version of this plant for a quest
		Ingredient.Name = "Roland's Tear"
		Ingredient.RefId = "ingred_gold_kanet_unique"
		ingredientChanceCount = 3
		ingredientChanceNone = 0
	elseif string.match(plantRefId, "flora_gold_kanet_") then
		Ingredient.Name = "Gold Kanet"
		Ingredient.RefId = "ingred_gold_kanet_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_sedge_01") then
		Ingredient.Name = "Golden Sedge Flower"
		Ingredient.RefId = "ingred_golden_sedge_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 3/10
	elseif string.match(plantRefId, "flora_green_lichen_") then
		Ingredient.Name = "Green Lichen"
		Ingredient.RefId = "ingred_green_lichen_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_hackle") then
		Ingredient.Name = "Hackle-Lo Leaf"
		Ingredient.RefId = "ingred_hackle-lo_leaf_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 2.5/10
	elseif string.match(plantRefId, "flora_heather_01") then
		Ingredient.Name = "Heather"
		Ingredient.RefId = "ingred_heather_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_plant_01") then
		Ingredient.Name = "Horn Lily Bulb"
		Ingredient.RefId = "ingred_horn_lily_bulb_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 3/10
	elseif string.match(plantRefId, "flora_kreshweed_") then
		Ingredient.Name = "Kresh Fiber"
		Ingredient.RefId = "ingred_kresh_fiber_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "egg_kwama00") then
		Ingredient.Name = "Large Kwama Egg"
		Ingredient.RefId = "food_kwama_egg_02"
		ingredientChanceCount = 1
		ingredientChanceNone = 0
	elseif string.match(plantRefId, "flora_bc_mushroom_01") or string.match(plantRefId, "flora_bc_mushroom_02") or string.match(plantRefId, "flora_bc_mushroom_03") or string.match(plantRefId, "flora_bc_mushroom_04") or string.match(plantRefId, "flora_bc_mushroom_05") then
		Ingredient.Name = "Luminous Russula"
		Ingredient.RefId = "ingred_russula_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_bc_mushroom_06") or string.match(plantRefId, "flora_bc_mushroom_07") or string.match(plantRefId, "flora_bc_mushroom_08") then
		Ingredient.Name = "Violet Coprinus"
		Ingredient.PluralName = "Violet Coprinus'"
		Ingredient.RefId = "ingred_coprinus_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_marshmerrow_") then
		Ingredient.Name = "Marshmerrow"
		Ingredient.RefId = "ingred_marshmerrow_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_plant_04") then
		Ingredient.Name = "Meadow Rye"
		Ingredient.RefId = "ingred_meadow_rye_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 0
	elseif string.match(plantRefId, "flora_muckspunge_") then
		Ingredient.Name = "Muck"
		Ingredient.RefId = "ingred_muck_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_plant_02") then
		Ingredient.Name = "Nirthfly Stalk"
		Ingredient.RefId = "ingred_nirthfly_stalks_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 3/10
	elseif string.match(plantRefId, "flora_sedge_02") then
		Ingredient.Name = "Noble Sedge Flower"
		Ingredient.RefId = "ingred_noble_sedge_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 3/10
	elseif string.match(plantRefId, "flora_red_lichen_") then
		Ingredient.Name = "Red Lichen"
		Ingredient.RefId = "ingred_red_lichen_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_roobrush_") then
		Ingredient.Name = "Roobrush"
		Ingredient.RefId = "ingred_roobrush_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_rm_scathecraw_") then
		Ingredient.Name = "Scathecraw"
		Ingredient.RefId = "ingred_scathecraw_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_saltrice_") then
		Ingredient.Name = "Saltrice"
		Ingredient.RefId = "ingred_saltrice_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_plant_07") then
		Ingredient.Name = "Scrib Cabbage"
		Ingredient.RefId = "ingred_scrib_cabbage_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 3/10
	elseif string.match(plantRefId, "flora_bc_fern_01") then
		Ingredient.Name = "Spore Pod"
		Ingredient.RefId = "ingred_bc_spore_pod"
		ingredientChanceCount = 3
		ingredientChanceNone = 0
	elseif string.match(plantRefId, "flora_bc_fern_04_chuck") then
		Ingredient.Name = "Meteor Slime"
		Ingredient.RefId = "ingred_scrib_jelly_02"
		ingredientChanceCount = 1
		ingredientChanceNone = 0
	elseif string.match(plantRefId, "flora_plant_08") then
		Ingredient.Name = "Lloramor Spine"
		Ingredient.RefId = "ingred_lloramor_spines_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 0
	elseif string.match(plantRefId, "flora_stoneflower_") then
		Ingredient.Name = "Stoneflower Petal"
		Ingredient.RefId = "ingred_stoneflower_petals_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_plant_05") or string.match(plantRefId, "flora_plant_06") then
		Ingredient.Name = "Sweetpulp"
		Ingredient.RefId = "ingred_sweetpulp_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 3/10
	elseif string.match(plantRefId, "flora_plant_03") then
		Ingredient.Name = "Timsa-Come-By Flower"
		Ingredient.RefId = "ingred_timsa-come-by_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 3/10
	elseif string.match(plantRefId, "tramaroot_01") then
		Ingredient.Name = "Trama Root"
		Ingredient.RefId = "ingred_trama_root_01"
		ingredientChanceCount = 3
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "tramaroot_") then
		Ingredient.Name = "Trama Root"
		Ingredient.RefId = "ingred_trama_root_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "contain_trama_shrub_05") or string.match(plantRefId, "contain_trama_shrub_01") then
		Ingredient.Name = "Trama Root"
		Ingredient.RefId = "ingred_trama_root_01"
		ingredientChanceCount = 2
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "contain_trama_shrub_") then
		Ingredient.Name = "Trama Root"
		Ingredient.RefId = "ingred_trama_root_01"
		ingredientChanceCount = 3
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_wickwheat_") then
		Ingredient.Name = "Wickwheat"
		Ingredient.RefId = "ingred_wickwheat_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 1/10
	elseif string.match(plantRefId, "flora_willow_flower_") then
		Ingredient.Name = "Willow Anther"
		Ingredient.RefId = "ingred_willow_anther_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 1.5/10
	elseif string.match(plantRefId, "flora_bm_belladonna_03") then
		Ingredient.Name = "ripened Belladonna Berries"
		Ingredient.RefId = "ingred_belladonna_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 0
	elseif string.match(plantRefId, "flora_bm_belladonna_") then
		Ingredient.Name = "unripened Belladonna Berries"
		Ingredient.RefId = "ingred_belladonna_02"
		ingredientChanceCount = 1
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_bm_holly_") then
		Ingredient.Name = "Holly Berries"
		Ingredient.RefId = "ingred_holly_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 2/10
	elseif string.match(plantRefId, "flora_bm_wolfsbane_01") then
		Ingredient.Name = "Wolfsbane Petal"
		Ingredient.RefId = "ingred_wolfsbane_01"
		ingredientChanceCount = 1
		ingredientChanceNone = 0
	end
	
	for i = 1, ingredientChanceCount, 1 do
		if math.random() > ingredientChanceNone then --this is run in a loop to calculate 'for each' like vanilla
			Ingredient.Count = Ingredient.Count + 1
		end
	end
	
	return Ingredient
end

local function InventoryManagement(plantRefId, pid)
	local ingredient = GetIngredient(plantRefId)
	
	if ingredient.Count > 0 then
		inventoryHelper.addItem(Players[pid].data.inventory, ingredient.RefId, ingredient.Count, nil, nil, nil)

		local item = {}
		item.refId = ingredient.RefId
		item.count = ingredient.Count
		item.charge = -1
		item.enchantmentCharge = -1
		item.soul = -1
		
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

function GraphicHerbalism.OnPlayerConnect() --create the file if necessary
	local jsonFile = io.open(os.getenv("MOD_DIR") .. "/graphicHerbalism.json", "r")
	io.close()
	
	if jsonFile ~= nil then
		LoadJSON()
	else
		local pickData = {}
		SaveJSON(pickData)
	end
end

function GraphicHerbalism.CanPickPlant(plantRefId)
	local plants = {"egg_kwama00", "cavern_spore00", "contain_trama_shrub_", "flora_ash_yam_", "flora_bc_fern_", "flora_bc_mushroom_", "flora_bc_podplant_", "flora_bc_shelffungus_", "flora_bittergreen_", "flora_black_anther_", "flora_black_lichen_",
	"flora_chokeweed_02", "flora_comberry_01", "flora_corkbulb", "flora_fire_fern_", "flora_gold_kanet_", "flora_green_lichen_", "flora_hackle", "flora_heather_01", "flora_kreshweed_", "flora_marshmerrow_", "flora_muckspunge_",
	"flora_plant_01", "flora_plant_02", "flora_plant_03", "flora_plant_04", "flora_plant_05", "flora_plant_06", "flora_plant_07", "flora_plant_08", "flora_red_lichen_", "flora_rm_scathecraw_", "flora_roobrush_","flora_saltrice_",
	"flora_sedge_01", "flora_sedge_02", "flora_stoneflower_", "flora_wickwheat_", "flora_willow_flower_", "tramaroot_", "tramaroot_01", "flora_bm_belladonna_", "flora_bm_holly_", "flora_bm_wolfsbane_01"}
	
	local result = false
	
	for key, value in pairs(plants) do
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
	LoadJSON()

	if pickData ~= nil and pickData[cellDescription] ~= nil then
		for cell, value in pairs(pickData) do
			if cell == cellDescription then
				local deletedCount = 0
				local loopCount = 0
				tes3mp.ClearObjectList()
				tes3mp.SetObjectListPid(pid)
				tes3mp.SetObjectListCell(cellDescription)
				
				for uniqueIndex, value2 in pairs(value) do
					loopCount = loopCount + 1
					
					--if this is the day it should respawn we need to check the hour
					if WorldInstance.data.time.daysPassed - value2['daysPassed'] == growthDays and math.floor(WorldInstance.data.time.hour) - value2['hour'] >= 0 or WorldInstance.data.time.daysPassed - value2['daysPassed'] >= growthDays + 1 then
						local splitIndex = uniqueIndex:split("-")
						
						logicHandler.RunConsoleCommandOnObject("Enable", cellDescription, value2['plantRefId'], splitIndex[1], splitIndex[2])
						
						objectData = {}
						objectData.refId = value2['plantRefId']
						objectData.state = true
						
						packetBuilder.AddObjectState(uniqueIndex, objectData)
						LoadedCells[cellDescription].data.objectData[uniqueIndex].state = true
						tes3mp.SendObjectState()
						
						pickData[cellDescription][uniqueIndex] = nil --delete reference
						
						deletedCount = deletedCount + 1
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
	end
end

function GraphicHerbalism.OnObjectActivate(plantRefId, pid, uniqueIndex)
	LoadJSON()

	cellDescription = tes3mp.GetCell(pid)

	if pickData == nil then
		pickData = {}
	end

	if pickData[cellDescription] == nil then
		pickData[cellDescription] = {}
	end

	if pickData[cellDescription][uniqueIndex] == nil then
		pickData[cellDescription][uniqueIndex] = {}
	end
	
	pickData[cellDescription][uniqueIndex]['plantRefId'] = plantRefId
	pickData[cellDescription][uniqueIndex]['daysPassed'] = WorldInstance.data.time.daysPassed
	pickData[cellDescription][uniqueIndex]['hour'] = math.floor(WorldInstance.data.time.hour)

	local splitIndex = uniqueIndex:split("-")

	logicHandler.RunConsoleCommandOnObject("Disable", cellDescription, plantRefId, splitIndex[1], splitIndex[2])

	InventoryManagement(plantRefId, pid)

	SaveJSON(pickData)
end

return GraphicHerbalism