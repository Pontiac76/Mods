
-- WuvItUp
-- Upgrades your 

-- Exposed variables to game
local Amazing = 10
local MaxSpeed = false

function Expose()

end

function ExposedCallback( param )

end

function SpeedCallback( param )

	ModDebug.Log("Param: ", param)
	
end

function GenericCallback( param )

end

function SteamDetails()

	-- Setting of Steam details
	ModBase.SetSteamWorkshopDetails("BerryGoodMod V3", "Mega Berry Maker. Adds converter for berries along with recipe.", {"berries", "berry converter"}, "BerryLogo.png")
	
end

function BeforeLoad()

	-- Before Load Function - The majority of calls go here
	
	ModDebug.Log("MOD - Create Berry Recipe - All Converters - 1 stick = 10 berries produced") 
	ModVariable.SetIngredientsForRecipe("FolkHeart2", {"FolkHeart"}, {10}, 1)	
	ModVariable.SetIngredientsForRecipe("FolkHeart3", {"FolkHeart2"}, {10}, 1)	
	ModVariable.SetIngredientsForRecipe("FolkHeart4", {"FolkHeart3"}, {10}, 1)	
	ModVariable.SetIngredientsForRecipe("FolkHeart5", {"FolkHeart4"}, {10}, 1)	
	ModVariable.SetIngredientsForRecipe("FolkHeart6", {"FolkHeart5"}, {10}, 1)	
	ModVariable.SetIngredientsForRecipe("FolkHeart7", {"FolkHeart6"}, {10}, 1)	
	
  
	
end

function AfterLoad()

	-- After Load Function
	
	-- ModDebug.Log("MOD - Spawn Berries")
	-- ModBase.SpawnItem("Berries", 50, 50)
	
end

function AfterLoad_CreatedWorld()
end

function AfterLoad_LoadedWorld()
end

function Creation()
	
	-- Creation of any new converters or buildings etc. go here
	
	-- ModDebug.Log("MOD - Create a new Berry Converter")
	ModConverter.CreateConverter("Wuv It Upgrades", {"FolkHeart2","FolkHeart3","FolkHeart4","FolkHeart5","FolkHeart6","FolkHeart7"}, 
    {"Log","Plank","Pole"}, {4,4,8}, 
    "ObjCrates/wooden boxes pack", {-1,-1}, {1,0}, {0,1}, {1,1})
	
end

function OnUpdate()

	-- Update Loop
	
end
