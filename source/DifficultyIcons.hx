package;

import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flash.display.BitmapData;
import lime.system.System;
#if sys
import haxe.io.Path;
import openfl.utils.ByteArray;
#end
import haxe.Json;
import tjson.TJSON;
import haxe.format.JsonParser;
using StringTools;
class DifficultyIcons {
  public var group:FlxTypedGroup<FlxSprite>;
  public var width:Float = 0;
  public var difficulty(default,null):Int = 1;
  public final defaultDiff:Int;
  public final difficulties:Array<String>;
  public var activeDiff(get,never):FlxSprite;
  public function new(diff:Array<String>, ?defaultDifficulty:Int = 1,x:Float = 0, y:Float = 0) {
    group = new FlxTypedGroup<FlxSprite>();
    difficulties = diff;
    defaultDiff = defaultDifficulty;
		var diffJson = CoolUtil.parseJson(FNFAssets.getText(Paths.file('custom_difficulties/difficulties.json', 'custom')));
    trace(diff.length);
    for( level in 0...difficulties.length ) {
      var sprDiff = new FlxSprite(x,y);
      sprDiff.offset.x = diffJson.difficulties[level].offset;
      var diffPic:BitmapData;
      var diffXml:String;
			if (FNFAssets.exists(Paths.file('custom_difficulties/' + diffJson.difficulties[level].name + '/.png', 'custom'))) {
				diffPic = FNFAssets.getBitmapData(Paths.file('custom_difficulties/' + diffJson.difficulties[level].name + '/.png', 'custom'));
      } else {
         // fall back on base game file to avoid crashes
				diffPic = FNFAssets.getBitmapData(Paths.image("campaign_menu_UI_assets", 'preload'));
      }
			if (FNFAssets.exists(Paths.file('custom_difficulties/' + diffJson.difficulties[level].name + '/.xml', 'custom'))) {
				diffXml = FNFAssets.getText(Paths.file('custom_difficulties/' + diffJson.difficulties[level].name + '/.xml', 'custom'));
      } else {
         // fall back on base game file to avoid crashes
         diffXml = FNFAssets.getText(Paths.file("images/campaign_menu_UI_assets.png", 'preload'));
      }
      sprDiff.frames = FlxAtlasFrames.fromSparrow(diffPic,diffXml);
      sprDiff.animation.addByPrefix('diff', diffJson.difficulties[level].anim);
      sprDiff.animation.play('diff');
      if (defaultDifficulty != level) {
        sprDiff.visible = false;
      }
      trace(sprDiff);
      group.add(sprDiff);
    }
    difficulty = defaultDiff;
    changeDifficulty();
  }
  public function changeDifficulty(?change:Int = 0):Void {
    trace("line 58");
    difficulty += change;
    if (difficulty > difficulties.length - 1) {
      difficulty = 0;
    }
    if (difficulty < 0) {
      difficulty = difficulties.length - 1;
    }
    group.forEach(function (sprite:FlxSprite) {
      sprite.visible = false;
    });
    trace(difficulty);
    trace(group.members);
    group.members[difficulty].visible = true;
    trace("hello");
  }
  public static function changeDifficultyFreeplay(difficultyFP:Int, ?change:Int = 0):Dynamic {
    trace("line 73");
		var diffJson = CoolUtil.parseJson(FNFAssets.getText(Paths.file('custom_difficulties/difficulties.json', 'custom')));
    var difficultiesFP:Array<Dynamic> = diffJson.difficulties;
    var freeplayDiff = difficultyFP;
    freeplayDiff += change;
    if (freeplayDiff > difficultiesFP.length - 1) {
      freeplayDiff = 0;
    }
    if (freeplayDiff < 0) {
      freeplayDiff = difficultiesFP.length - 1;
    }
    trace("line 84");
    var text = difficultiesFP[freeplayDiff].name.toUpperCase();
    trace("lube :flushed:");
    return {difficulty: freeplayDiff, text: text};
  }
  function get_activeDiff():FlxSprite {
    trace("91");
    return group.members[difficulty];
  }
  public function getDiffEnding():String {
    var ending = "";
    if (difficulty != defaultDiff) {
      ending = "-"+difficulties[difficulty];
    }
    return ending;
  }
  public static function getEndingFP(fpDiff:Int):String {
		var diffJson = CoolUtil.parseJson(FNFAssets.getText(Paths.file('custom_difficulties/difficulties.json', 'custom')));
    var difficultiesFP:Array<Dynamic> = diffJson.difficulties;
    var ending = "";
    if (fpDiff != diffJson.defaultDiff) {
      ending = "-"+difficultiesFP[fpDiff].name;
    }
    trace(ending);
    return ending;
  }
  public static function getDefaultDiffFP():Int {
		var diffJson = CoolUtil.parseJson(FNFAssets.getText(Paths.file('custom_difficulties/difficulties.json', 'custom')));
    return diffJson.defaultDiff;
  }
}
