package;

import openfl.display.BitmapData;
import flixel.FlxSprite;
import lime.utils.Assets;
import lime.system.System;
import flash.display.BlendMode;
import tjson.TJSON;
using StringTools;

#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import sys.FileSystem;
import flash.media.Sound;
#end


class CoolUtil
{
	public static var fps:Int = 60;
	// hxs, like kotlin's kts
	public static final HSCRIPT_EXT:Array<String> = ['hscript', 'hxs'];
	public static final JSON_EXT:Array<String> = ['json', 'jsonc'];
	public static function formatCustomChars() {
		var epicCharFile:Dynamic = CoolUtil.parseJson(FNFAssets.getJson('assets/images/custom_chars/custom_chars'));
		/*
		this is what im basing off
		"template": {
			"like": "bf",
			"icons": [0,1,2,3],
			"colors": ["#149DFF"]
		},
		*/
		var finalString = '{';

		var components:Array<String> = [ // a pain to look at but I like it
			'\n  "', 
			'": {\n    "like": "', 
			'",\n    "icons": ',
			',\n    "colors": [',
			']\n  },'
		];

		var daFields = Reflect.fields(epicCharFile);
		for (i in 0...daFields.length) {
			var char = daFields[i];
			trace(char);
			var like = Reflect.field(epicCharFile, char).like;
			trace(like);
			var icons = Reflect.field(epicCharFile, char).icons.toString();
			trace(icons);
			
			var colors = Reflect.field(epicCharFile, char).colors;
			trace(colors);
			var fixedColors = '';
			for(i in 0...colors.length) {
				fixedColors += '"' + colors[i] + '"';
				if (i != colors.length-1)
					fixedColors += ',';
			}
			trace(fixedColors);

			finalString += components[0] + char + components[1] + like + components[2] + icons + components[3] + fixedColors + components[4];
		}
		finalString += '\n}';
		trace('done');
		File.saveContent('assets/images/custom_chars/custom_chars.jsonc', finalString);
	}
	public static function getSongFile(song:String, path:String, inst:Bool = true) { // 'path' is the song folder path
		var daSong = null;
		var songType = if (inst) 'Inst'; else 'Voices';
		if (sys.FileSystem.exists(haxe.io.Path.join([path, song + '_' + songType + TitleState.soundExt]))) {
			daSong = haxe.io.Path.join([path, song + "_" + songType + TitleState.soundExt]);
		} else if (sys.FileSystem.exists(haxe.io.Path.join([path, songType + TitleState.soundExt]))) {
			daSong = haxe.io.Path.join([path, songType + TitleState.soundExt]);
		} else if (sys.FileSystem.exists(haxe.io.Path.join([path, '../../music/' + song + '_' + songType + TitleState.soundExt]))) {
			daSong = haxe.io.Path.join([path, '../../music/' + song + '_' + songType + TitleState.soundExt]);
		}
		return daSong;
	}
	public static function getBlendMode(blend:String) {
		var daBlend = switch(blend) {
			case "add":
				BlendMode.ADD;
			case "alpha":
				BlendMode.ALPHA;
			case "darken":
				BlendMode.DARKEN;
			case "difference":
				BlendMode.DIFFERENCE;
			case "erase":
				BlendMode.ERASE;
			case "hardlight":
				BlendMode.HARDLIGHT;
			case "invert":
				BlendMode.INVERT;
			case "layer":
				BlendMode.LAYER;
			case "lighten":
				BlendMode.LIGHTEN;
			case "multiply":
				BlendMode.MULTIPLY;
			case "normal":
				BlendMode.NORMAL;
			case "overlay":
				BlendMode.OVERLAY;
			case "screen":
				BlendMode.SCREEN;
			case "shader":
				BlendMode.SHADER;
			case "subtract":
				BlendMode.SUBTRACT;
			default:
				null;
		}
		return daBlend;
	}
	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = FNFAssets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function coolDynamicTextFile(path:String):Array<String>
	{
		return coolTextFile(path);
	}
	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	public static function clamp(mini:Float, maxi:Float, value:Float):Float {
		return Math.min(Math.max(mini,value), maxi);
	}
	// can either return an array or a dynamic
	public static function parseJson(json:String):Dynamic {
		// the reason we do this is to make it easy to swap out json parsers
		return TJSON.parse(json);
	}
	public static function stringifyJson(json:Dynamic, ?fancy:Bool = true):String {
		// use tjson to prettify it
		var style:String = if (fancy) 'fancy' else null;
		return TJSON.encode(json,style);
	}
	// include all helper functions to keep shit in the same place
	public static function truncateFloat(number:Float, precision:Int):Float {
		return HelperFunctions.truncateFloat(number, precision);
	}
	public static function erf(x:Float):Float {
		return HelperFunctions.erf(x);
	}
	public static function getNotes():Int {
		return HelperFunctions.getNotes();
	}
	public static function getHolds():Int {
		return HelperFunctions.getHolds();
	}
	public static function getMapMaxScore():Int {
		return HelperFunctions.getMapMaxScore();
	}
	public static function wife3(maxms:Float, ts:Float)
	{
		return HelperFunctions.wife3(maxms, ts);
	}
}

class FlxTools {
	// Load a graphic and ensure it exists
	static public function loadGraphicDynamic(s:FlxSprite, path:String, animated:Bool=false, width:Int=0, height:Int=0, unique:Bool=false, ?key:String):FlxSprite {
		var sus:BitmapData = FNFAssets.getBitmapData(path);
		s.loadGraphic(sus,animated,width,height,unique,key);
		return s;
	}
}