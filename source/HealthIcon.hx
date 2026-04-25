package;

import flixel.FlxSprite;
import lime.utils.Assets;
import lime.system.System;
import flash.display.BitmapData;
import flixel.graphics.frames.FlxAtlasFrames;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;

import sys.FileSystem;
#end
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import hscript.Expr;
import hscript.Interp;
import hscript.ParserEx;
import haxe.xml.Parser;
import hscript.InterpEx;
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
using StringTools;
enum abstract IconState(Int) from Int to Int {
	var Normal;
	var Dying;
	var Poisoned;
	var Winning;
}
class HealthIcon extends FlxSprite {
	public var player:Bool = false;
	public var isAnimated = false;
	public var isNormal:Bool = false;
	public var sprTracker:FlxSprite;
	public var healthColors:Array<FlxColor> = [];
	public var iconState(default, set):IconState = Normal;
	private var interp:Interp;
	function set_iconState(x:IconState):IconState {
		if (isAnimated) {
			switch (x) {
				case Normal:
					animation.play('icon');
				case Dying:
					animation.play('dying');
				case Poisoned:
					animation.play('poisoned');
				case Winning:
					animation.play('winning');
			}
		} else {
			switch (x) {
				case Normal:
					animation.curAnim.curFrame = 0;
				case Dying:
					// if we set it out of bounds it doesn't realy matter as it goes to normal anyway
					animation.curAnim.curFrame = 1;
				case Poisoned:
					// same deal it will go to dying which is good enough
					animation.curAnim.curFrame = 2;
				case Winning:
					// we DO do it here here we want to make sure it isn't silly
					if (animation.curAnim.frames.length >= 4) {
						animation.curAnim.curFrame = 3;
					} else {
						animation.curAnim.curFrame = 0;
					}
			}
		}
		return iconState = x;
	}

	var charJson:Dynamic;
	var iconJson:Dynamic;
	public function new(char:String = 'bf', isPlayer:Bool = false, ?isnormal:Bool = false) {
		charJson = CoolUtil.parseJson(FNFAssets.getJson("assets/images/custom_chars/custom_chars"));
		iconJson = CoolUtil.parseJson(FNFAssets.getJson("assets/images/custom_chars/icon_only_chars"));

		player = isPlayer;
		super();
		antialiasing = true;
		isNormal = isnormal;
		switchAnim(char);
		scrollFactor.set();
	}

	var charIconPath = 'bf';
	public function switchAnim(char:String = 'bf') {
		var iconFrames:Array<Int> = [];
		charIconPath = char;
		var daJson:Dynamic = getCharFromJsons(char);

		bopReset();

		if (daJson != null && Reflect.hasField(daJson, 'icons')) {
			iconFrames = daJson.icons;
			if (isNormal) {
				if (daJson.iconbop != null)
					interp = HealthIcon.iconBop(daJson.iconbop);
				else
					interp = HealthIcon.iconBop('default');
			}
		} else {
			iconFrames = [0, 0, 0, 0];
			if (isNormal)
				interp = HealthIcon.iconBop('default');
		}
		var charPath = 'assets/images/custom_chars/' + charIconPath + '/';
		if (FNFAssets.exists(charPath + "icons.png")) {
			if (FNFAssets.exists(charPath + 'icons.xml')) { // i guess it works :thumbsup:
				isAnimated = true;
				frames = DynamicSprite.DynamicAtlasFrames.fromSparrow(charPath + 'icons.png', charPath + 'icons.xml');
				animation.addByPrefix('icon', 'normal', 24, true);
				animation.addByPrefix('dying', 'dying', 24, true);
				animation.addByPrefix('winning', 'winning', 24, true);
				animation.addByPrefix('poisoned', 'poisoned', 24, true);
			} else {
				isAnimated = false;
				var rawPic:BitmapData = FNFAssets.getBitmapData(charPath + "icons.png");
				loadGraphic(rawPic, true, 150, 150);
				animation.add('icon', iconFrames, false, player);
			}
		} else {
			loadGraphic('assets/images/iconGrid.png', true, 150, 150);
			animation.add('icon', iconFrames, false, player);
		}
		animation.play('icon');
		if (!isAnimated)
			animation.pause();

		if (daJson != null && Reflect.hasField(daJson, 'colors')) {
			var daColors:Array<String> = daJson.colors;
			healthColors = [];
			for (color in daColors) {
				healthColors.push(FlxColor.fromString(color));
			}
		} else
			healthColors = [0xFFFFFFFF];
	}

	function getCharFromJsons(char) {
		var daChar:Dynamic = null;
		if (Reflect.hasField(charJson, char))
			daChar = Reflect.field(charJson, char);
		else if (Reflect.hasField(iconJson, char))
			daChar = Reflect.field(iconJson, char);

		if (daChar == null) return null;

		if ((daChar.icons is String)) {
			charIconPath = daChar.icons;
			daChar = getCharFromJsons(daChar.icons);
		}

		return daChar;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);

		if (interp != null)
			callInterp("update", [elapsed, this])
		else if (isNormal) {
			setGraphicSize(Std.int(FlxMath.lerp(150, width, 0.50)));
			updateHitbox();
		}
	}

	public function dance() {
		if (interp != null)
			callInterp("dance", [this]);
		else if (isNormal) {
			setGraphicSize(Std.int(width + 30));
			updateHitbox();
		}
	}

	public function bopReset() {
		if (interp != null)
			callInterp("bopReset", [this]);
		else if (isNormal) {
			setGraphicSize(150);
			updateHitbox();
		}	
	}

	function callInterp(func_name:String, args:Array<Dynamic>) {
		if (interp == null) return;
		if (!interp.variables.exists(func_name)) return;
		var method = interp.variables.get(func_name);
		switch (args.length) {
			case 0:
				method();
			case 1:
				method(args[0]);
			case 2:
				method(args[0], args[1]);
		}
	}

	public function changeIconBop(bopIcon:String) {
		interp = HealthIcon.iconBop(bopIcon);
	}

	public static function iconBop(bopIcon:String):Interp {
		var interp = PluginManager.createSimpleInterp();
		var parser = new hscript.Parser();
		var program:Expr;
		if (FNFAssets.exists('assets/images/custom_chars/iconbops/' + bopIcon, Hscript)) {
			program = parser.parseString(FNFAssets.getHscript('assets/images/custom_chars/iconbops/' + bopIcon));
			interp.variables.set("hscriptPath", 'assets/images/custom_chars/iconbops/' + bopIcon + '/');
			interp.variables.set("PlayState", PlayState);
			interp.variables.set("dance", function(icon) {});
			interp.variables.set("update", function(elapsed, icon) {});
			interp.variables.set("getUV", function(variabull:String) {
				if (PlayState.universalVar.exists(variabull))
					return PlayState.universalVar.get(variabull);
				else
					return null;
			});

			interp.variables.set("updateUV", function(variabull:String, veryable:Dynamic) {
				PlayState.universalVar[variabull] = veryable;
			});
			interp.execute(program);
		}
		trace(interp);
		return interp;
	}
}
