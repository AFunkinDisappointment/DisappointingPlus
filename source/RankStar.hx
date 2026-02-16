package;

import flixel.FlxSprite;
import lime.utils.Assets;
import lime.system.System;
import flash.display.BitmapData;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;

import sys.FileSystem;
#end
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
using StringTools;
class RankStar extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var starNum:Int = 0;
	public var selectoffset:Float = 0;

	public function new(song:String, diff:Int) {
		super();

		var rankNum = Highscore.getFCLevel(song, diff, 'best-fullcombo');

		var defaultDiff = DifficultyManager.getDefaultForDiff(diff);
		var diffName = '';
		if (FileSystem.exists('assets/images/ranks/rank' + rankNum + '-' + defaultDiff + '.png'))
			diffName = '-' + defaultDiff;

		loadGraphic(FNFAssets.getBitmapData('assets/images/ranks/rank' + rankNum + diffName + '.png'));
		//trace(song + '($diff) - ' + rankNum);
		setGraphicSize(Std.int(width * 0.4));
		antialiasing = true;
		scrollFactor.set();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + (sprTracker.width - 50) + (width * 0.4 * starNum), sprTracker.y - 10 - selectoffset);
			alpha = sprTracker.alpha;
		}
	}
}
