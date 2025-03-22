class InitState extends flixel.FlxState
{
    override function create()
    {
        super.create();

        // -- Flixel -- //

        FlxG.fixedTimestep = false;
        FlxG.game.focusLostFramerate = 10;
		FlxG.keys.preventDefaultKeys = [TAB];
        FlxG.drawFramerate = FlxG.updateFramerate = Settings.data.framerate;
        FlxG.mouse.visible = false;

        // -- Settings -- // 

        FlxG.save.bind('funkin', Util.getSavePath());

        Controls.instance = new Controls();
        Settings.loadDefaultKeys();
		Settings.load();

        AlphaCharacter.loadAlphabetData();
        Highscore.load();

        #if AWARDS_ALLOWED 
        Awards.load(); 
        #end

        if (FlxG.save.data.weekCompleted != null)
			states.menus.StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			FlxG.fullscreen = FlxG.save.data.fullscreen;

		Mods.loadTopMod();

        // -- -- -- //

        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        @:privateAccess
            FlxG.switchState(Type.createInstance(Main.game.initialState, []));
    }
}