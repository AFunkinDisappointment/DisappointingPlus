package;

#if sys
import sys.FileSystem;
import sys.io.File;
#end
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import haxe.io.Path;
import flixel.FlxG;
import flash.net.FileReference;
import flash.events.Event;
import haxe.io.Bytes;
import openfl.utils.AssetType;
using StringTools;

class HScriptInterface {
	var hscript:Dynamic;
	public var components:Array<HScriptComponent> = [];

	public function new() {
		
	}

	public function analyzeHScript() {
		seperatedText = CoolUtil.coolTextFile(hscript);
		for (i in 0...seperatedText.length) {
			// if find ';' then it's a normal component
			// if find '{' then it's a container function of some sort
			// and, of course, '}' indicates the end of a container function
			var txt = seperatedText[i];
			var component:HScriptComponent;
			if (txt.contains(';')) {
				if (txt.contains(');'))
					component = new HScriptComponent(txt, 'BasicFunction');
				else
					component = new HScriptComponent(txt);
			} else if (txt.contains('{')) {
				if (txt.contains('switch'))
					component = new HScriptComponent(txt, 'SwitchContainer');
				else
					component = new HScriptComponent(txt, 'BasicContainer');
			}
		}
	}
}