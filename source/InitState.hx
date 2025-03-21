class InitState extends flixel.FlxState
{
    override function create()
    {
        super.create();

        // -- Flixel -- //

        FlxG.fixedTimestep = false;
        FlxG.game.focusLostFramerate = 10;
		FlxG.keys.preventDefaultKeys = [TAB];
        FlxG.drawFramerate = FlxG.updateFramerate = ClientPrefs.data.framerate;
        FlxG.mouse.visible = false;

        // -- Settings -- // 

        FlxG.save.bind('funkin', CoolUtil.getSavePath());

        Controls.instance = new Controls();
        ClientPrefs.loadDefaultKeys();
		ClientPrefs.loadPrefs();

        AlphaCharacter.loadAlphabetData();
        Highscore.load();

        #if ACHIEVEMENTS_ALLOWED 
        Achievements.load(); 
        #end

        if (FlxG.save.data.weekCompleted != null)
			states.StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			FlxG.fullscreen = FlxG.save.data.fullscreen;

        // count your days lua

        #if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

        // -- -- -- //

        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        @:privateAccess
            FlxG.switchState(Type.createInstance(Main.game.initialState, []));
    }
}