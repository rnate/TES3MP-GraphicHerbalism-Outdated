# TES3MP-GraphicHerbalism
Due to them relying on global player variables, none of the popular 'Graphic Herbalism' mods work in TES3MP. This transfers it to a server script, so it can run without issue.

# Installation
Save this file in the mp-stuff\scripts\ directory.<br />
These edits will be made in the same directory in the serverCore.lua file.

1a) Add: `graphicHerbalism = require("graphicHerbalism")`<br />
under: `menuHelper = require("menuHelper")` ~line 14

1b) Add: `graphicHerbalism.OnServerPostInit()`<br />
under: `ResetAdminCounter()` ~line 285

1c) Add: `graphicHerbalism.OnCellLoad(pid, cellDescription)`<br />
under: `eventHandler.OnCellLoad(pid, cellDescription)` ~line 460

Save/close serverCore.lua and open eventHandler.lua

2a) Add: <pre>if graphicHerbalism.CanPickPlant(objectRefId) then
			     &nbsp;&nbsp;&nbsp;&nbsp;graphicHerbalism.OnObjectActivate(objectRefId, pid, objectUniqueIndex)
			     &nbsp;&nbsp;&nbsp;&nbsp;isValid = false --disable inventory screen
		      end
        </pre>
under: `objectUniqueIndex = tes3mp.GetObjectRefNum(index) .. "-" .. tes3mp.GetObjectMpNum(index)` ~line 600

If you'd like to change the default 3 in game day plant respawn, you can edit the `local growthDays = 3` variable on line 33 of my script.

The line numbers are approximations and can change in the future.

# Technical
After installing the script, json file will be created after the server is started (OnServerPostInit).

After it is created, when a player activates a plant, that plant is set to disabled and the entry is added to the json file by cell.

When a player changes cells (OnCellLoad) the json file is checked, if the player is in a cell from the file, the plants are checked. If a plant should be unhidden, it is then set to unhidden and the packet is created and set to other players. When the plant is unhidden, the entry is removed from the json file, and if the cell has no plants the entire cell entry is deleted from the json file.