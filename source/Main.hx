package;

import flixel.FlxGame;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;

import lime.graphics.Image;

// Crash Handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end

class Main extends Sprite
{
	private static var game = {
		width: 1280,
		height: 720,
		initialState: states.TitleState, 
		framerate: 60, 
		skipSplash: true, 
		startFullscreen: false 
	};

	public static var fpsVar:FPSCounter;
	public static var psychVersion:String = '1.0.3';

	public static var muteKeys:Array<FlxKey> = [FlxKey.NUMPADZERO, FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public function new()
	{
		super();

		addChild(new FlxGame(game.width, game.height, InitState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		addChild(fpsVar = new FPSCounter(10, 3, 0xFFFFFF));
		fpsVar.visible = Settings.data.showFPS;

		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0")  ['--no-lua'] #end);
		#end

		#if (cpp && windows)
		backend.Native.fixScaling();
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) 
		{
		    if (FlxG.cameras != null) 
			{
			   for (cam in FlxG.cameras.list)
			   {
				if (cam == null || cam.filters == null) 
					continue;
				resetSpriteCache(cam.flashSprite);
			   }
			}

			if (FlxG.game != null) resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void 
	{
		@:privateAccess 
		{
		    sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	/*
		Crash Handler written by @squirradotdev
		I only did some cleanup
	*/
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		e.preventDefault();
		e.stopPropagation();

		var errMsg:String = e.error+'\n\n';
		var date:String = '${Date.now()}'.replace(":", "'");

		for (stackItem in CallStack.exceptionStack(true))
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += 'Called from $file:$line\n';
				default:
					Sys.println(stackItem);
			}
		}

		if (!FileSystem.exists("./crash/")) FileSystem.createDirectory("./crash/");

		File.saveContent('./crash/$date.txt', '$errMsg\n');
		Sys.println('\n$errMsg');

		Application.current.window.alert(errMsg, "Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end
}
