package hscript;

import backend.WeekData;
import objects.Character;
import backend.StageData;

import openfl.display.BlendMode;
import Type.ValueType;

import substates.GameOverSubstate;

class HScriptUtil
{
	public static final Function_Stop:String = "##PSYCHLUA_FUNCTIONSTOP";
	public static final Function_Continue:String = "##PSYCHLUA_FUNCTIONCONTINUE";
	public static final Function_StopLua:String = "##PSYCHLUA_FUNCTIONSTOPLUA";
	public static final Function_StopHScript:String = "##PSYCHLUA_FUNCTIONSTOPHSCRIPT";
	public static final Function_StopAll:String = "##PSYCHLUA_FUNCTIONSTOPALL";

	public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic, allowMaps:Bool = false):Any
	{
		var splitProps:Array<String> = variable.split('[');
		if(splitProps.length > 1)
		{
			var target:Dynamic = null;
			if(MusicBeatState.getVariables().exists(splitProps[0]))
			{
				var retVal:Dynamic = MusicBeatState.getVariables().get(splitProps[0]);
				if(retVal != null)
					target = retVal;
			}
			else target = Reflect.getProperty(instance, splitProps[0]);

			for (i in 1...splitProps.length)
			{
				var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
				if(i >= splitProps.length-1) //Last array
					target[j] = value;
				else //Anything else
					target = target[j];
			}
			return target;
		}

		if(allowMaps && isMap(instance))
		{
			//trace(instance);
			instance.set(variable, value);
			return value;
		}

		if(instance is MusicBeatState && MusicBeatState.getVariables().exists(variable))
		{
			MusicBeatState.getVariables().set(variable, value);
			return value;
		}
		Reflect.setProperty(instance, variable, value);
		return value;
	}
	public static function getVarInArray(instance:Dynamic, variable:String, allowMaps:Bool = false):Any
	{
		var splitProps:Array<String> = variable.split('[');
		if(splitProps.length > 1)
		{
			var target:Dynamic = null;
			if(MusicBeatState.getVariables().exists(splitProps[0]))
			{
				var retVal:Dynamic = MusicBeatState.getVariables().get(splitProps[0]);
				if(retVal != null)
					target = retVal;
			}
			else
				target = Reflect.getProperty(instance, splitProps[0]);

			for (i in 1...splitProps.length)
			{
				var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
				target = target[j];
			}
			return target;
		}
		
		if(allowMaps && isMap(instance))
		{
			//trace(instance);
			return instance.get(variable);
		}

		if(instance is MusicBeatState && MusicBeatState.getVariables().exists(variable))
		{
			var retVal:Dynamic = MusicBeatState.getVariables().get(variable);
			if(retVal != null)
				return retVal;
		}
		return Reflect.getProperty(instance, variable);
	}

	public static function isMap(variable:Dynamic)
	{
		if(variable.exists != null && variable.keyValueIterator != null) return true;
		return false;
	}
	public static function getModSetting(saveTag:String, ?modName:String = null)
	{
		return null;
	}

	public static function getPropertyLoop(split:Array<String>, ?getProperty:Bool=true, ?allowMaps:Bool = false):Dynamic
	{
		var obj:Dynamic = getObjectDirectly(split[0]);
		var end = split.length;
		if(getProperty) end = split.length-1;

		for (i in 1...end) obj = getVarInArray(obj, split[i], allowMaps);
		return obj;
	}

	public static function getObjectDirectly(objectName:String, ?allowMaps:Bool = false):Dynamic
	{
		switch(objectName)
		{
			case 'this' | 'instance' | 'game':
				return PlayState.instance;
			
			default:
				var obj:Dynamic = MusicBeatState.getVariables().get(objectName);
				if(obj == null) obj = getVarInArray(MusicBeatState.getState(), objectName, allowMaps);
				return obj;
		}
	}

	public static function getBuildTarget():String
	{
		#if windows
		#if x86_BUILD
		return 'windows_x86';
		#else
		return 'windows';
		#end
		#elseif linux
		return 'linux';
		#elseif mac
		return 'mac';
		#elseif html5
		return 'browser';
		#elseif android
		return 'android';
		#elseif switch
		return 'switch';
		#else
		return 'unknown';
		#end
	}
}
