package;

#if windows
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import plugins.tools.MetroSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import DynamicSprite.DynamicAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import haxe.Json;
#if sys
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
import sys.FileSystem;
import Song.SwagSong;
#end
import tjson.TJSON;
import flixel.input.keyboard.FlxKey;
import hscript.Interp;
import hscript.Parser;
import hscript.Expr;
using StringTools;
typedef DiscordJson = {
	var intro:String;
	var freeplay:String;
	var mainmenu:String;
};
class TitleState extends MusicBeatState {
	static public var initialized:Bool = false;
	static public var soundExt:String = ".ogg";
	static public var firstTime = false;
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var shownWacky:Int = -1;
	var curWacky:Array<String> = [];
	var wackyEndBeat:Int = 0;
	var wackyImage:FlxSprite;
	var coolDudes:Array<String> = [];

	public static var discordStuff:DiscordJson = CoolUtil.parseJson(FNFAssets.getJson("assets/discord/presence/discord"));

	private var interp:Interp;
	function callInterp(func_name:String, args:Array<Dynamic>) {
		if (interp == null) return;
		if (!interp.variables.exists(func_name)) return;
		var method = interp.variables.get(func_name);
		switch (args.length) {
			case 0:
				method();
			case 1:
				method(args[0]);
		}
	}

	var customMenuConfirm: Array<Array<String>>;
	var customMenuScroll: Array<Array<String>>;
	override public function create():Void {
		#if windows
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode) {
			DiscordClient.shutdown();
		});
		// Updating Discord Rich Presence
		var customPrecence = discordStuff.intro;
		Discord.DiscordClient.changePresence(customPrecence, null);
		#end
		
		PluginManager.init();
		DifficultyManager.init();
		ModifierState.init();
		curWacky = FlxG.random.getObject(getIntroTextShit());
		// DEBUG BULLSHIT
		super.create();
		FlxG.mouse.visible = false;
		FlxG.save.bind("preferredSave", "bulbyVR");
		var preferredSave:Int = 0;
		if (Reflect.hasField(FlxG.save.data, "preferredSave")) {
			preferredSave = FlxG.save.data.preferredSave;
		} else {
			FlxG.save.data.preferredSave = 0;
		}

		FlxG.save.close();
		FlxG.save.bind("save"+preferredSave, 'bulbyVR');
		PlayerSettings.init();
		Highscore.load();

		// volume stuff
		if (Reflect.hasField(FlxG.save.data, 'volume')) {
			FlxG.sound.volume = FlxG.save.data.volume;
			FlxG.sound.muted = FlxG.save.data.mute;
			FlxG.sound.volumeUpKeys = FlxG.save.data.keys.volUp;
			FlxG.sound.volumeDownKeys = FlxG.save.data.keys.volDown;
		}
		FlxG.sound.soundTrayEnabled = false;

		#if FREEPLAY
		LoadingState.loadAndSwitchState(new CategoryState());
		#elseif CHARTING
		LoadingState.loadAndSwitchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer) {
			startIntro();
		});
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:MetroSprite;
	var titleText:FlxSprite;
	function startIntro() {
		if (!initialized) {
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			Main.memoryCounter.visible = OptionsHandler.options.showMemory;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			initMusic('assets/music/custom_menu_music/'
				+ CoolUtil.parseJson(FNFAssets.getText("assets/music/custom_menu_music/custom_menu_music.json")).Menu+'/freakyMenu' + TitleState.soundExt, 102);

			/*FlxG.sound.playMusic('assets/music/custom_menu_music/'
				+ CoolUtil.parseJson(FNFAssets.getText("assets/music/custom_menu_music/custom_menu_music.json")).Menu+'/freakyMenu' + TitleState.soundExt, 0);*/

			//FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		//Conductor.changeBPM(102);
		persistentUpdate = true;

		final titleJson = CoolUtil.parseJson(FNFAssets.getText("assets/data/customization.json"));
		final titleName = Reflect.field(titleJson, 'titleState');
		if (titleName != 'default' && FNFAssets.exists('assets/images/custom_states/title/' + titleName, Hscript)) {
			interp = customTitleScript(titleName);
			callInterp('start', []);
		} else
			makeBaseTitle();

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);
		// THIS SHIT DOESN'T WORK ON NEKO!
		// IDK WHY I AM TESTING IT ON NEKO!
		coolDudes = Assets.getText('assets/data/creators.txt').split("\n");
		trace(coolDudes);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic('assets/images/newgrounds_logo.png');
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function makeBaseTitle(?path:String = 'assets/images/') {
		gfDance = cast new MetroSprite(500, 50, false);
		gfDance.loadSparrow(path + 'gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.animation.play('danceLeft');
		gfDance.antialiasing = true;
		add(gfDance);
		
		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = DynamicAtlasFrames.fromSparrow(path + 'logoBumpin.png', path + 'logoBumpin.xml');
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.antialiasing = true;
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = DynamicAtlasFrames.fromSparrow(path + 'titleEnter.png', path + 'titleEnter.xml');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.animation.play('idle');
		titleText.antialiasing = true;
		add(titleText);
	}

	function initMusic(music:String, bpm:Float = 102) {
		FlxG.sound.playMusic(FNFAssets.getAssetWithBackup(music, 'assets/music/freakyMenu.ogg', SOUND), 0);
		FlxG.sound.music.fadeIn(4, 0, 0.7);
		Conductor.changeBPM(bpm);
	}

	function getIntroTextShit():Array<Array<String>> {
		var fullText:String = Assets.getText('assets/data/introText.txt');

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray) {
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	var idleStart = -1;

	override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		callInterp('update', [elapsed]);

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		if (curBeat >= 60 || idleStart > 0) {
			if (idleStart == -1)
				idleStart = FlxG.game.ticks;
			var idleSeconds = Math.floor((FlxG.game.ticks - idleStart)/1000);
			var minutesRemaining = Math.floor(idleSeconds / 60);
			var secondsRemaining = '' + idleSeconds % 60;
			if (secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining;
			Discord.DiscordClient.changePresence('Currently AFK on Title Screen', 'Time Idle: ' + minutesRemaining + ':' + secondsRemaining, 'gf');
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null) {
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro) {
			if (titleText != null)
				titleText.animation.play('press');

			callInterp('enterPressed', []);

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play('assets/sounds/custom_menu_sounds/'
				+ CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuConfirm+'/confirmMenu' + TitleState.soundExt, 0.7);

			transitioning = true;

			new FlxTimer().start(2, function(tmr:FlxTimer) {
				LoadingState.loadAndSwitchState(new MainMenuState());
			});
		}

		if (pressedEnter && !skippedIntro && curBeat > 0) {
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>) {
		for (i in 0...textArray.length) {
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String) {
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText() {
		while (textGroup.members.length > 0) {
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit() {
		super.beatHit();

		callInterp('beatHit', [curBeat]);

		if (logoBl != null)
			logoBl.animation.play('bump', true);

		if (gfDance != null)
			gfDance.dance();

		FlxG.log.add(curBeat);

		if (curBeat < 9) {
			switch (curBeat) {
				case 1:
					createCoolText(coolDudes);
				case 3:
					addMoreText('present');
				case 4:
					deleteCoolText();
				case 5:
					createCoolText(['Not in association', 'with']);
				case 7:
					addMoreText('these guys');
					ngSpr.visible = true;
				case 8:
					deleteCoolText();
					remove(ngSpr);
					ngSpr.destroy();
				case 9:
					createCoolText([curWacky[0]]);
				case 11:
					addMoreText(curWacky[1]);
				case 12:
					deleteCoolText();
				case 13:
					addMoreText('Friday');
				case 14:
					addMoreText('Night');
				case 15:
					addMoreText('Funkin');

				case 16:
					skipIntro();
			}
		} else {
			if (curBeat == 9) {
				createCoolText([curWacky[0]]);
				shownWacky = 0;
				wackyEndBeat = curBeat;
			} else if (curBeat % 2 == 1 && shownWacky + 1 < curWacky.length) {
				shownWacky += 1;
				addMoreText(curWacky[shownWacky]);
				wackyEndBeat = curBeat;
			} else if (shownWacky == curWacky.length - 1){
				trace(wackyEndBeat + " " + curBeat);
				switch (curBeat - wackyEndBeat) {
					case 1:
						deleteCoolText();
					case 2:
						addMoreText(CoolUtil.parseJson(FNFAssets.getText("assets/data/gameInfo.json")).name_1);
					case 3:
						addMoreText(CoolUtil.parseJson(FNFAssets.getText("assets/data/gameInfo.json")).name_2);
					case 4:
						addMoreText(CoolUtil.parseJson(FNFAssets.getText("assets/data/gameInfo.json")).name_3);
					case 5:
						skipIntro();
				}
			}
		}

	}

	var skippedIntro:Bool = false;

	function skipIntro():Void {
		if (!skippedIntro) {
			remove(ngSpr);
			ngSpr.destroy();

			FlxG.camera.flash(FlxColor.WHITE, 1);
			remove(credGroup);
			skippedIntro = true;
		}
	}

	public function customTitleScript(titleName:String):Interp {
		var interp = PluginManager.createSimpleInterp();
		var parser = new hscript.Parser();
		var program:Expr;
		if (FNFAssets.exists('assets/images/custom_states/title/' + titleName, Hscript)) {
			program = parser.parseString(FNFAssets.getHscript('assets/images/custom_states/title/' + titleName));
			interp.variables.set("hscriptPath", 'assets/images/custom_states/title/' + titleName + '/');
			interp.variables.set("addSprite", function(sprite) { add(sprite); });
			interp.variables.set("removeSprite", function(sprite) { remove(sprite); });
			interp.variables.set("makeBaseTitle", function(?path:String) {
				makeBaseTitle(path);
				interp.variables.set('gf', gfDance);
				interp.variables.set('logo', logoBl);
				interp.variables.set('titleText', titleText);
			});
			interp.variables.set("initMusic", initMusic);
			interp.variables.set("start", function () {});
			interp.variables.set("beatHit", function (beat) {});
			interp.variables.set("update", function(elapsed) {});
			interp.variables.set("enterPressed", function() {});
			interp.execute(program);
		}
		return interp;
	}
}
