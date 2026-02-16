package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;

class CustomStateState extends MusicBeatState {
	private var interp:Interp;

	public var stateName:String = 'customstate';
	public var stateReplaced:String = 'none';

	public static var stringToState = [
		'MainMenuState' => MainMenuState,
		'VictoryLoopState' => VictoryLoopState,
		'StoryMenuState' => StoryMenuState
	];

	public function new():Void {
		super();
	}

	override function create() {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (FNFAssets.exists('assets/images/custom_states/' + stateName, Hscript)) {
			interp = newState();

			newState(stateName);
			callInterp("create", [this]);
		} else {
			var bg:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
			add(bg);

			var txt:FlxText = new FlxText(0, 0, 0, "The custom state '" + stateName + "' does not exist and could not replace this state. Press ESCAPE to go to the normal state.", 32)
			txt.setFormat("assets/fonts/vcr.ttf", 32, 0xFFFFFFFF, RIGHT, OUTLINE, 0xFF000000);
			txt.screenCenter();
			add(txt);
		}

		super.create();
	}

	override function update(elapsed:Float) {
		callInterp("update", [elapsed, this]);

		if (FlxG.keys.pressed.ESCAPE) {
			LoadingState.loadAndSwitchState(stringToState[stateReplaced]);
		}

		super.update(elapsed);
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

	public static function newState(stateName:String):Interp {
		var interp = PluginManager.createSimpleInterp();
		var parser = new hscript.Parser();
		var program:Expr;
		program = parser.parseString(FNFAssets.getHscript('assets/images/custom_states/' + stateName));
		interp.variables.set("hscriptPath", 'assets/images/custom_states/' + stateName + '/');
		interp.variables.set("create", function(state) {});
		interp.variables.set("update", function(elapsed, state) {});
		interp.variables.set("LoadingState", LoadingState);
		interp.execute(program);
		trace(interp);
		return interp;
	}
}
