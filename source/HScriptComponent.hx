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

// functions normally ending with (), typically with variables inserted
typedef BasicFunction = {
	var name:String;
	var vars:Array<String>;
}
// a basic variable modification: var = this;
typedef BasicVariable = {
	var name:String;
	var value:String;
}
// encompasses multiple types involving {}, like if, for, and editable functions
typedef BasicContainer = {
	var name:String;
	var conditions:Array<String>;
	var children:Array<HScriptComponent>;
}
// as the name implies, it's for switch
typedef SwitchContainer = {
	var condition:String;
	var cases:Map<String, HScriptComponent>;
	var default:HScriptComponent;
}

class HScriptComponent {
	var rawCode:String;
	var editCode:Dynamic;

	var codeType:String;

	public function new(codeString:String = '') {
		rawCode = codeString;
	}

	function analyzeType() {
		
	}

	function regenerateRawString() {
		
	}

	public function getData(codeString:String) {
		if (codeString == null) codeString = rawCode;
		switch(codeType) {
			case 'BasicVariable':
				var daData:BasicVariable = {name = 'null', value = ''};
				var splitEquals = StringTools.replace(rawCode.split('='), ';', '');
				daData.name = splitEquals[0];
				daData.value = splitEquals[1];

				return daData;
			case 'BasicFunction':
				var daData:BasicFunction = {name = 'null', vars = []};
				var splitPrents = StringTools.replace(rawCode.split('('), ');', '');
				daData.name = splitPrents[0];
				daData.vars = splitPrents[1].split(',');

				return daData;
			case 'BasicContainer':
				var daData:BasicContainer = {name = 'null', conditions = [], children = []};
				var splitPrents = StringTools.replace(rawCode.split('('), ');', '');
				daData.name = splitPrents[0];
				daData.conditions = splitPrents[1].split(',');

				return daData;
			default:
				return false;
		}
	}
}

/*
im so bad at finding a starting point so ima just write some shiz down and see if i can figure it out

char.frames = blahblah;
BasicVariable:
name = "char.frames"
value = "blahblah"
 - very basic and cool

char.animation.addByPrefix('yomama', 'sjrgoiarjgh', 42, faue);
BasicFunction:
name = "char.animation.addByPrefix"
vars = ["'yomama'", "'sjrgoiarjgh'", "42", "faue"]
 - da () is generated with it

if (thiscompleted) {
	havefunediting = true;
	makethings(verycool);
}
BasicContainer:
name = 'if'
children = [component[havefunediting = true], component[makethings(verycool)]]
 - da {} is generated with it
 - those components are the BasicFunctions/BasicVariables, they'll have their respective components
 - how da funk am i going to handle else

switch(definitelyaswitch) {
	case 'top':
		thatscool();
	case 'bottom':
		ofcourse(nosurprise);
	default:
		okiguessyoreaswitch = true;
}
SwitchContainer:
condition = 'definitelyaswitch'
cases = {'top'=>component[thatcools()], 'bottom'=>component[ofcourse(nosurprise)]}
default = component[okiguessyoreaswitch = true]
 - da {} is generated with it
 - those components are the BasicFunctions/BasicVariables, they'll have their respective components
 - obviously, default wont generate if there isnt a default

*/