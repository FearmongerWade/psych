package backend;

#if AWARDS_ALLOWED
import objects.AwardPopup;
import haxe.Exception;
import haxe.Json;

typedef Award =
{
	var name:String;
	var description:String;
	@:optional var hidden:Bool;
	@:optional var maxScore:Float;
	@:optional var maxDecimals:Int;

	//handled automatically, ignore these two
	@:optional var mod:String;
	@:optional var ID:Int; 
}

enum abstract AwardOp(String)
{
	var GET = 'get';
	var SET = 'set';
	var ADD = 'add';
}

class Awards 
{
	public static function init()
	{
		createAward('friday_night_play',		{name: "Freaky on a Friday Night", description: "Play on a Friday... Night.", hidden: true});
		#if BASE_GAME_FILES
		createAward('week1_nomiss',			{name: "She Calls Me Daddy Too", description: "Beat Week 1 on Hard with no Misses."});
		createAward('week2_nomiss',			{name: "No More Tricks", description: "Beat Week 2 on Hard with no Misses."});
		createAward('week3_nomiss',			{name: "Call Me The Hitman", description: "Beat Week 3 on Hard with no Misses."});
		createAward('week4_nomiss',			{name: "Lady Killer", description: "Beat Week 4 on Hard with no Misses."});
		createAward('week5_nomiss',			{name: "Missless Christmas", description: "Beat Week 5 on Hard with no Misses."});
		createAward('week6_nomiss',			{name: "Highscore!!", description: "Beat Week 6 on Hard with no Misses."});
		createAward('week7_nomiss',			{name: "God Effing Damn It!", description: "Beat Week 7 on Hard with no Misses."});
		createAward('weekend1_nomiss',		{name: "Just a Friendly Sparring", description: "Beat Weekend 1 on Hard with no Misses."});
		#end
		createAward('ur_bad',					{name: "What a Funkin' Disaster!", description: "Complete a Song with a rating lower than 20%."});
		createAward('ur_good',				{name: "Perfectionist", description: "Complete a Song with a rating of 100%."});
		#if BASE_GAME_FILES
		createAward('roadkill_enthusiast',	{name: "Roadkill Enthusiast", description: "Watch the Henchmen die 50 times.", maxScore: 50, maxDecimals: 0});
		#end
		createAward('oversinging', 			{name: "Oversinging Much...?", description: "Sing for 10 seconds without going back to Idle."});
		createAward('hype',					{name: "Hyperactive", description: "Finish a Song without going back to Idle."});
		createAward('two_keys',				{name: "Just the Two of Us", description: "Finish a Song pressing only two keys."});
		createAward('toastie',				{name: "Toaster Gamer", description: "Have you tried to run the game on a toaster?"});
		#if BASE_GAME_FILES
		createAward('debugger',				{name: "Debugger", description: "Beat the \"Test\" Stage from the Chart Editor.", hidden: true});
		#end
		#if (TITLE_SCREEN_EASTER_EGG || PSYCH_WATERMARKS)
		createAward('pessy_easter_egg',		{name: "Engine Gal Pal", description: "Teehee, you found me~!", hidden: true});
		#end

		//dont delete this thing below
		_originalLength = _sortID + 1;
	}

	public static var awards:Map<String, Award> = new Map<String, Award>();
	public static var variables:Map<String, Float> = [];
	public static var awardsUnlocked:Array<String> = [];
	private static var _firstLoad:Bool = true;

	public static function get(name:String):Award
		return awards.get(name);
	public static function exists(name:String):Bool
		return awards.exists(name);

	public static function load():Void
	{
		if(!_firstLoad) return;

		if(_originalLength < 0) init();

		if(FlxG.save.data != null) {
			if(FlxG.save.data.awardsUnlocked != null)
				awardsUnlocked = FlxG.save.data.awardsUnlocked;

			var savedMap:Map<String, Float> = cast FlxG.save.data.awardsVariables;
			if(savedMap != null)
			{
				for (key => value in savedMap)
				{
					variables.set(key, value);
				}
			}
			_firstLoad = false;
		}
	}

	public static function save():Void
	{
		FlxG.save.data.awardsUnlocked = awardsUnlocked;
		FlxG.save.data.awardsVariables = variables;
	}
	
	public static function getScore(name:String):Float
		return _scoreFunc(name, GET);

	public static function setScore(name:String, value:Float, saveIfNotUnlocked:Bool = true):Float
		return _scoreFunc(name, SET, value, saveIfNotUnlocked);

	public static function addScore(name:String, value:Float = 1, saveIfNotUnlocked:Bool = true):Float
		return _scoreFunc(name, ADD, value, saveIfNotUnlocked);

	static function _scoreFunc(name:String, mode:AwardOp, addOrSet:Float = 1, saveIfNotUnlocked:Bool = true):Float
	{
		if(!variables.exists(name))
			variables.set(name, 0);

		if(awards.exists(name))
		{
			var award:Award = awards.get(name);
			if(award.maxScore < 1) throw new Exception('Achievement has score disabled or is incorrectly configured: $name');

			if(awardsUnlocked.contains(name)) return award.maxScore;

			var val = addOrSet;
			switch(mode)
			{
				case GET: return variables.get(name); //get
				case ADD: val += variables.get(name); //add
				default:
			}

			if(val >= award.maxScore)
			{
				unlock(name);
				val = award.maxScore;
			}
			variables.set(name, val);

			Awards.save();
			if(saveIfNotUnlocked || val >= award.maxScore) FlxG.save.flush();
			return val;
		}
		return -1;
	}

	static var _lastUnlock:Int = -999;
	public static function unlock(name:String, autoStartPopup:Bool = true):String {
		if(!awards.exists(name))
		{
			FlxG.log.error('Achievement "$name" does not exists!');
			throw new Exception('Achievement "$name" does not exists!');
			return null;
		}

		if(Awards.isUnlocked(name)) return null;

		trace('Completed achievement "$name"');
		awardsUnlocked.push(name);

		// earrape prevention
		var time:Int = openfl.Lib.getTimer();
		if(Math.abs(time - _lastUnlock) >= 100) //If last unlocked happened in less than 100 ms (0.1s) ago, then don't play sound
		{
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.5);
			_lastUnlock = time;
		}

		Awards.save();
		FlxG.save.flush();

		if(autoStartPopup) startPopup(name);
		return name;
	}

	inline public static function isUnlocked(name:String)
		return awardsUnlocked.contains(name);

	@:allow(objects.AwardPopup)
	private static var _popups:Array<AwardPopup> = [];

	public static var showingPopups(get, never):Bool;
	public static function get_showingPopups()
		return _popups.length > 0;

	public static function startPopup(achieve:String, endFunc:Void->Void = null) {
		for (popup in _popups)
		{
			if(popup == null) continue;
			popup.intendedY += 150;
		}

		var newPop:AwardPopup = new AwardPopup(achieve, endFunc);
		_popups.push(newPop);
		//trace('Giving achievement ' + achieve);
	}

	// Map sorting cuz haxe is physically incapable of doing that by itself
	static var _sortID = 0;
	static var _originalLength = -1;
	public static function createAward(name:String, data:Award, ?mod:String = null)
	{
		data.ID = _sortID;
		data.mod = mod;
		awards.set(name, data);
		_sortID++;
	}
}
#end