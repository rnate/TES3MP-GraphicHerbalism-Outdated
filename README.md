# TES3MP-GraphicHerbalism
Due to them relying on global player variables, none of the popular 'Graphic Herbalism' mods work in TES3MP. This transfers it to a server script, so it can run without issue.

# Installation
Save this file in the mp-stuff\scripts\ directory.<br />
These edits will be made in the same directory in the eventHandler.lua file.

1) Add: `graphicHerbalism = require("graphicHerbalism")`<br />
under: `commandHandler = require("commandHandler")` ~line 3

2) Add: `graphicHerbalism.OnPlayerConnect()`<br />
under: `tes3mp.StartTimer(Players[pid].loginTimerId)` ~line 49

3) Add: `graphicHerbalism.OnCellLoad(pid, cellDescription)`<br />
under: `logicHandler.LoadCellForPlayer(pid, cellDescription)` ~line 490

4) Add: <pre>if graphicHerbalism.CanPickPlant(objectRefId) then
			     &nbsp;&nbsp;&nbsp;&nbsp;graphicHerbalism.OnObjectActivate(objectRefId, pid, objectUniqueIndex)
			     &nbsp;&nbsp;&nbsp;&nbsp;isValid = false --disable inventory screen
		      end
        </pre>
under: `objectUniqueIndex = tes3mp.GetObjectRefNum(index) .. "-" .. tes3mp.GetObjectMpNum(index)` ~line 600

If you'd like to change the default 3 in game day plant respawn, you can edit the `local growthDays = 3` variable on line 26 of my script.

# Technical
After installing the script, the first player to join will initiate the json file creation.

After it is created, when a player activates a plant, that plant is set to disabled and the entry is added to the json file by cell.

When a player changes cells (OnCellLoad) the json file is checked, if the player is in a cell from the file, the plants are checked. If a plant should be unhidden, it is then set to unhidden and the packet is created and set to other players. When the plant is unhidden, the entry is removed from the json file, and if the cell has no plants the entire cell entry is deleted from the json file.
