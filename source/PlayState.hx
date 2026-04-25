package;

#if web
import js.lib.intl.RelativeTimeFormat.RelativeTimeUnit;
#end
import openfl.Lib;
import flixel.util.typeLimit.OneOfTwo;
import Character.EpicLevel;
import flixel.ui.FlxButton.FlxTypedButton;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import openfl.geom.Matrix;
import flixel.FlxGame;
import flixel.FlxObject;
#if desktop
import Sys;
import sys.FileSystem;
#end
#if cpp
import Discord.DiscordClient;
#end
import DifficultyIcons;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.input.keyboard.FlxKey;
import flixel.FlxState;
import flixel.FlxSubState;
import flash.display.BitmapData;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.math.FlxAngle;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import lime.system.System;
import openfl.media.Sound;
import flixel.group.FlxGroup;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;

#end
import tjson.TJSON;
import Judgement.TUI;
using StringTools;
using CoolUtil.FlxTools;
typedef LuaAnim = {
	var prefix : String;
	@:optional var indices: Array<Int>;
	var name : String;
	@:optional var fps : Int;
	@:optional var loop : Bool;
}
enum abstract DisplayLayer(Int) from Int to Int {
	var BEHIND_GF = 1;
	var BEHIND_BF = 1 << 1;
	var BEHIND_DAD = 1 << 2;
	var BEHIND_ALL = BEHIND_GF | BEHIND_BF | BEHIND_DAD;
}
class PlayState extends MusicBeatState {
	#if windows
	public static var customPrecence = FNFAssets.getText("assets/discord/presence/play.txt");
	#end
	public var curStage:StageHelper;
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:String = 'Tutorial';
	public static var storyWeekNum:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var defaultPlaylistLength = 0;
	public static var campaignScoreDef = 0;
	public static var ss:Bool = true;
	private var inst:Dynamic;
	private var vocals:FlxSound;
	// use old bf
	private var oldMode:Bool = false;
	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	var currentKey = null;
	public var currrentKey = null; //this one is because of weird shiz, you can try to fix it >:(

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;
	var totalNotesHit:Float = 0;
	var totalPlayed:Int = 0;
	var totalNotesHitDefault:Float = 0;
	public var camFollow:FlxObject;
	private var player1Icon:String;
	private var player2Icon:String;
	public static var prevCamFollow:FlxObject;

	public static var misses:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;

	public var songPosBar:FlxBar;
	public var songPosBG:FlxSprite;
	public var songPositionBar:Float = 0;
	public var showRatings:Bool = true;
	var songLength:Float = 0.0;
	var songScoreDef:Int = 0;
	var nps:Int = 0;
	var currentTimingShown:FlxText;
	var playingAsRpc:String = "";
	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var enemyStrums:FlxTypedGroup<FlxSprite>;
	private var playerComboBreak:FlxTypedGroup<FlxSprite>;
	private var enemyComboBreak:FlxTypedGroup<FlxSprite>;
	public var shitBreakColor:FlxColor = 0xFF175DB3;
	public var wayoffBreakColor:FlxColor = 0xFFAF0000;
	public var missBreakColor:FlxColor = 0xFFDD0A93;
	
	public var camZoomRate:Int = 4;
	public var camZoomIntensity:Float = 1;
	private var camZooming:Bool = false;
	private var scriptableCamera:String = 'false';
	// scriptCamPos[0] for bf, scriptCamPos[1] for dad
	var scriptCamPos:Array<Array<Float>> = [[0, 0], [0, 0]];
	private var curSong:String = "";
	private var strumming2:Array<Bool> = [false, false, false, false];
	private var strumming1:Array<Bool> = [false, false, false, false];

	public static var universalVar:Map<String, Dynamic>;

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	private var combo:Int = 0;
	public static var daScrollSpeed:Float = 1;
	public static var duoMode:Bool = false;
	public static var soloMode:Bool = false;
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	//private var enemyColor:FlxColor = 0xFFFF0000;
	//private var opponentColor:FlxColor = 0xFFBC47FF;
	// private var playerColor:FlxColor = 0xFF66FF33;
	// private var poisonColor:FlxColor = 0xFFA22CD1;
	// private var poisonColorEnemy:FlxColor = 0xFFEA2FFF;
	// private var bfColor:FlxColor = 0xFF149DFF;
	private var barShowingPoison:Bool = false;
	private var pixelUI:Bool = false;
	#if (windows && cpp)
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var customPresence = '';
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	public static var startingPosition:Float = 0;
	public static var startPosSong = 'none';
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public var doof:DialogueBox;

	var talking:Bool = true;
	var songScore:Int = 0;
	var trueScore:Int = 0;
	var scoreTxt:FlxText;
	var healthTxt:FlxText;
	var accuracyTxt:FlxText;
	var difficTxt:FlxText;
	// hehe fuck around with these lamo
	public static var oldx:Float;
	public static var oldy:Float;

	public static var campaignScore:Int = 0;
	public static var campaignAccuracy:Float = 0;

	public var defaultCamZoom:Float = 1.05;
	public var camSpeed:Float = 0.08;
	public var disableScoreChange:Bool = false;
	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public static var daPixelZoom:Float = 6;
	// for note sustains on bpm changes
	var initialStepCrochet:Float;

	var bfoffset = [0.0, 0.0];
	var gfoffset = [0.0, 0.0];
	var dadoffset = [0.0, 0.0];
	var swapOffsets = [770.0, 450.0, 400.0, 130.0, 100.0, 100.0];
	public var dadCamOffset = [0, 0];
	public var bfCamOffset = [-100, -100];
	var dadcam = [0, 0];
	var bfcam = [0, 0];
	var skipCountdown:Bool = false;
	var inCutscene:Bool = false;
	var alwaysDoCutscenes = false;
	var fullComboMode:Bool = false;
	var perfectMode:Bool = false;
	var practiceMode:Bool = false;
	public static var healthLossMultiplier:Float = 1;
	public static var healthGainMultiplier:Float = 1;
	var poisonExr:Bool = false;
	var poisonPlus:Bool = false;
	var beingPoisioned:Bool = false;
	var poisonTimes:Int = 0;
	public static var flippedNotes:Bool = false;
	var noteSpeed:Float = 0.45;
	var practiceDied:Bool = false;
	var practiceDieIcon:HealthIcon;
	private var regenTimer:FlxTimer;
	var sickFastTimer:FlxTimer;
	var accelNotes:Bool = false;
	var notesHit:Float = 0;
	var notesPassing:Int = 0;
	var vnshNotes:Bool = false;
	var invsNotes:Bool = false;
	var snakeNotes:Bool = false;
	var snekNumber:Float = 0;
	var drunkNotes:Bool = false;
	var alcholTimer:FlxTimer;
	var notesHitArray:Array<Date> = [];
	var alcholNumber:Float = 0;
	var inALoop:Bool = false;
	var useVictoryScreen:Bool = true;
	var demoMode:Bool = false;
	var downscroll:Bool = false;
	var midscroll:Bool = false;
	var luaRegistered:Bool = false;
	var currentFrames:Int = 0;
	var supLove:Bool = false;
	var loveMultiplier:Float = 0;
	var poisonMultiplier:Float = 0;
	var goodCombo:Bool = false;
	public var player1GoodHitSignal:Signal<Note>;
	public var player2GoodHitSignal:Signal<Note>;
	private var judgementList:Array<String> = [];
	private var preferredJudgement:String = '';

	public static var opponentPlayer:Bool = false;

	//Auto update note x pos to be under their correct strumline pos. 
	public var snapToStrumline:Bool = true;
	// this is just so i can collapse it lol
	#if true
	var hscriptStates:Map<String, Interp> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];
	function callHscript(func_name:String, args:Array<Dynamic>, usehaxe:String) {
		// if function doesn't exist
		if (!hscriptStates.get(usehaxe).variables.exists(func_name)) {
			trace("Function doesn't exist, silently skipping...");
			return;
		}
		var method = hscriptStates.get(usehaxe).variables.get(func_name);
		switch(args.length) {
			case 0:
				method();
			case 1:
				method(args[0]);
			case 2:
				method(args[0], args[1]);
			case 3:
				method(args[0], args[1], args[2]);
		}
	}
	function callAllHScript(func_name:String, args:Array<Dynamic>) {
		for (key in hscriptStates.keys()) {
			callHscript(func_name, args, key);
		}
	}
	function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		hscriptStates.get(usehaxe).variables.set(name,value);
	}
	function getHaxeVar(name:String, usehaxe:String):Dynamic {
		return hscriptStates.get(usehaxe).variables.get(name);
	}
	function setAllHaxeVar(name:String, value:Dynamic) {
		for (key in hscriptStates.keys())
			setHaxeVar(name, value, key);
	}
	function getHaxeActor(name:String):Dynamic {
		switch (name) {
			case "boyfriend" | "bf":
				return boyfriend;
			case "girlfriend" | "gf":
				return gf;
			case "dad":
				return dad;
			default:
				return strumLineNotes.members[Std.parseInt(name)];
		}
	}
	function makeHaxeState(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getHscript(path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("BEHIND_GF", BEHIND_GF);
		interp.variables.set("BEHIND_BF", BEHIND_BF);
		interp.variables.set("BEHIND_DAD", BEHIND_DAD);
		interp.variables.set("BEHIND_ALL", BEHIND_ALL);
		interp.variables.set("BEHIND_NONE", 0);
		interp.variables.set("switchCharacter", switchCharacter);
		interp.variables.set("difficulty", storyDifficulty);
		interp.variables.set("duoMode", duoMode);
		interp.variables.set("soloMode", soloMode);
		interp.variables.set("opponentPlayer", opponentPlayer);
		interp.variables.set("demoMode", demoMode);
		interp.variables.set("Math", Math);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("songData", SONG);
		interp.variables.set("curSong", SONG.song);
		interp.variables.set("downscroll", downscroll);
		interp.variables.set("middlescroll", midscroll);
		interp.variables.set("scrollSpeed", daScrollSpeed);
		interp.variables.set("tweenScrollSpeed", tweenScrollSpeed);
		interp.variables.set("curStep", 0);
		interp.variables.set("curBeat", 0);
		interp.variables.set("camHUD", camHUD);

		interp.variables.set("WiggleEffect", WiggleEffect);

		interp.variables.set("getUV", getUV);
		interp.variables.set("updateUV", updateUV);
		
		interp.variables.set("setPresence", function (to:String) {
			#if (windows && cpp)
			customPrecence = to == '' ? detailsText : to;
			updatePrecence();
			#else 
			FlxG.log.warn("Ignoring hscript setPresence as we aren't on windows");
			#end
		});
		
		interp.variables.set("showOnlyStrums", false);
		interp.variables.set("playerStrums", playerStrums);
		interp.variables.set("enemyStrums", enemyStrums);
		interp.variables.set("changeNoteType", function(player, type, trans) {
			generateStaticArrows(0, type, trans);
			generateStaticArrows(1, type, trans);
			uiSmelly = Reflect.field(Judgement.uiJson, type);
			pixelUI = uiSmelly.isPixel;
		});
		interp.variables.set("mustHit", false);
		interp.variables.set("strumLineY", strumLine.y);
		interp.variables.set("hscriptPath", path);
		interp.variables.set("startShader", function (shader:String) { 
			return (new ShaderHandler(shader)); // wigglestuff
		});
		interp.variables.set("boyfriend", boyfriend);
		interp.variables.set("gf", gf);
		interp.variables.set("dad", dad);
		interp.variables.set("stage", curStage);
		interp.variables.set("vocals", vocals);
		interp.variables.set("gfSpeed", gfSpeed);
		interp.variables.set("tweenCamIn", tweenCamIn);
		interp.variables.set("health", health);
		interp.variables.set("healthChange", healthChange);
		interp.variables.set("iconP1", iconP1);
		interp.variables.set("iconP2", iconP2);
		interp.variables.set("currentPlayState", this);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("paused", paused);
		interp.variables.set("window", Lib.application.window);
		// give them access to save data, everything will be fine ;)
		interp.variables.set("isInCutscene", function () return inCutscene);
		interp.variables.set("endSong", function () {if (endingSong) endForReal();}); // for cutscenes at the end of a song
		trace("set vars");
		interp.variables.set("camZooming", false);
		interp.variables.set('FocusCamera', FocusCamera);
		interp.variables.set('ZoomCamera', ZoomCamera);
		interp.variables.set('SetCameraBop', SetCameraBop);
		interp.variables.set("camSpeed", 0.08);
		interp.variables.set("skipCountdown", function() skipCountdown = true);
		interp.variables.set("scriptableCamera", 'false');
		interp.variables.set("scriptCamPos", scriptCamPos);
		// callbacks
		interp.variables.set("start", function (song) {});
		interp.variables.set("songStart", function (song) {});
		interp.variables.set("beatHit", function (beat) {});
		interp.variables.set("update", function (elapsed) {});
		interp.variables.set("onPause", function () {});
		interp.variables.set("onResume", function () {});
		interp.variables.set("stepHit", function(step) {});
		interp.variables.set("playerTwoTurn", function () {});
		interp.variables.set("playerTwoMiss", function () {});
		interp.variables.set("playerTwoSing", function () {});
		interp.variables.set("playerOneTurn", function() {});
		interp.variables.set("playerOneMiss", function() {});
		interp.variables.set("playerOneSing", function() {});
		interp.variables.set("noteLoaded", function (note) {});
		interp.variables.set("noteHit", function(player1:Bool, note:Note, wasGoodHit:Bool) {});
		interp.variables.set("onCharacterAdded", function(char:Character, type:String) {});
		interp.variables.set("addSprite", function (sprite, position) {
			// sprite is a FlxSprite
			// position is a Int
			if (position & BEHIND_GF != 0)
				remove(gf);
			if (position & BEHIND_DAD != 0)
				remove(dad);
			if (position & BEHIND_BF != 0)
				remove(boyfriend);
			add(sprite);
			if (position & BEHIND_GF != 0)
				add(gf);
			if (position & BEHIND_DAD != 0)
				add(dad);
			if (position & BEHIND_BF != 0)
				add(boyfriend); 
		});
		interp.variables.set("add", add);
		interp.variables.set("remove", remove);
		interp.variables.set("insert", insert);
		interp.variables.set("setDefaultZoom", function(zoom:Float){
			defaultCamZoom = zoom;
			FlxG.camera.zoom = zoom;
			if (usehaxe == 'stage') curStage.defaultZoom = zoom;
		});
		interp.variables.set("removeSprite", function(sprite) {
			remove(sprite);
		});
		interp.variables.set("getHaxeActor", getHaxeActor);
		interp.variables.set("instancePluginClass", instanceExClass);
		interp.variables.set("scaleChar", function (char:String, amount:Float) {
			switch(char) {
				case 'boyfriend':
					remove(boyfriend);
					boyfriend.setGraphicSize(Std.int(boyfriend.width * amount));
					boyfriend.y *= amount;
					add(boyfriend);
				case 'dad':
					remove(dad);
					dad.setGraphicSize(Std.int(dad.width * amount));
					dad.y *= amount;
					add(dad);
				case 'gf':
					remove(gf);
					gf.setGraphicSize(Std.int(gf.width * amount));
					gf.y *= amount;
					add(gf);
			}
		});

		//the impostor
		interp.variables.set("swapChar", switchCharacter);

		//no sus here
		interp.variables.set("addCharacter", addCharacter);
		interp.variables.set('switchToChar', switchToChar);
		interp.variables.set("switchCharacter", switchCharacter);
		interp.variables.set("setSwapOffsets", function(char:String, daoffsets:Array<Float>, ?additive:Bool = true) {
			switch(char) {
				case 'boyfriend' | 'bf' | 'player1':
					if (additive) {
						swapOffsets[0] += daoffsets[0];
						swapOffsets[1] += daoffsets[1];
					} else {
						swapOffsets[0] = daoffsets[0];
						swapOffsets[1] = daoffsets[1];
					}
				case 'dad' | 'opponent' | 'player2':
					if (additive) {
						swapOffsets[4] += daoffsets[0];
						swapOffsets[5] += daoffsets[1];
					} else {
						swapOffsets[4] = daoffsets[0];
						swapOffsets[5] = daoffsets[1];
					}
				case 'gf' | 'girlfriend':
					if (additive) {
						swapOffsets[2] += daoffsets[0];
						swapOffsets[3] += daoffsets[1];
					} else {
						swapOffsets[2] = daoffsets[0];
						swapOffsets[3] = daoffsets[1];
					}
			}
		});
		interp.variables.set("swapOffsets", swapOffsets);

		trace("set stuff");
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("start", [SONG.song], usehaxe);
		trace('executed');
	}

	// move this later
	function getUV(variabull:String) {
		if (universalVar.exists(variabull))
				return universalVar.get(variabull);
			else
				return null;
	}

	function updateUV(variabull:String, veryable:Dynamic) {
		universalVar[variabull] = veryable;
	}

	function makeHaxeStateUI(usehaxe:String, path:String, filename:String) {
		// I need to merge this with the other makeHaxeState
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getText(path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("difficulty", storyDifficulty);
	    interp.variables.set("Math", Math);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("songData", SONG);
		interp.variables.set("curSong", SONG.song);
		interp.variables.set("curStep", 0);
		interp.variables.set("curBeat", 0);
		interp.variables.set("duoMode", duoMode);
		interp.variables.set("soloMode", soloMode);
		interp.variables.set("opponentPlayer", opponentPlayer);
		interp.variables.set("demoMode", demoMode);
		interp.variables.set("disableScoreChange", function(funny:Bool) {disableScoreChange = funny;});
		interp.variables.set("camHUD", camHUD);
		interp.variables.set("downscroll", downscroll);
		interp.variables.set("middlescroll", midscroll);
		interp.variables.set("playerStrums", playerStrums);
		interp.variables.set("enemyStrums", enemyStrums);
		interp.variables.set("changeNoteType", function(player, type, trans) {
			generateStaticArrows(player, type, trans);
		});

		interp.variables.set("getUV", getUV);
		interp.variables.set("updateUV", updateUV);

		interp.variables.set("strumLineY", strumLine.y);
		interp.variables.set("hscriptPath", path);
		interp.variables.set("health", health);
		interp.variables.set("scoreTxt", scoreTxt);
		interp.variables.set("difficTxt", difficTxt);
		interp.variables.set('useSongBar', useSongBar);
		interp.variables.set("songPosBG", songPosBG);
		interp.variables.set("songPosBar", songPosBar);
		interp.variables.set("songName", songName);
		interp.variables.set("NewBar", function (daX:Float, daY:Float, width:Int, height:Int, min:Float, max:Float, barColor:Bool = true) {
			var daBar = new FlxBar(daX, daY, LEFT_TO_RIGHT, width, height, this, 'songPositionBar', min, max);
			if (barColor) {
				var leftSideFill = opponentPlayer ? dad.opponentColor : dad.enemyColor;
				if (duoMode)
					leftSideFill = dad.opponentColor;
				var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.playerColor;
				if (duoMode)
					rightSideFill = boyfriend.bfColor;
				daBar.createFilledBar(leftSideFill, rightSideFill);
			} else
				daBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
			return daBar;
		});
		interp.variables.set("healthBar", healthBar);
		interp.variables.set("healthBarBG", healthBarBG);
		//interp.variables.set("currentTimingShown", currentTimingShown);
		interp.variables.set("iconP1", iconP1);
		interp.variables.set("iconP2", iconP2);
		interp.variables.set("currentPlayState", this);
		interp.variables.set("PlayState", PlayState);

		//funny numbers (how do I make them read only????????)
		interp.variables.set("songScore", songScore);
		interp.variables.set("songScoreDef", songScoreDef);
		interp.variables.set("nps", nps);
		interp.variables.set("accuracy", accuracy);
		interp.variables.set("combo", combo);

		interp.variables.set("start", function (song) {});
		interp.variables.set("songStart", function (song) {});
		interp.variables.set("update", function (elapsed) {});
		interp.variables.set("onPause", function () {});
		interp.variables.set("onResume", function () {});
		interp.variables.set("beatHit", function (beat) {});
		interp.variables.set("stepHit", function(step) {});
		interp.variables.set("playerTwoTurn", function () {});
		interp.variables.set("playerTwoMiss", function () {});
		interp.variables.set("playerTwoSing", function () {});
		interp.variables.set("playerOneTurn", function() {});
		interp.variables.set("playerOneMiss", function() {});
		interp.variables.set("playerOneSing", function() {});
		interp.variables.set("noteLoaded", function (note) {});
		interp.variables.set("noteHit", function(player1:Bool, note:Note, wasGoodHit:Bool) {});
		interp.variables.set("addSprite", function (sprite) {add(sprite);});
		interp.variables.set("removeSprite", function(sprite) {remove(sprite);});
		interp.variables.set("replaceSprite", function(sprite, replaced) {replace(sprite, replaced);});
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("HelperFunctions", HelperFunctions);
		interp.variables.set("instancePluginClass", instanceExClass);
		trace("set stuff");
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("start", [SONG.song], usehaxe);
		trace('executed');
	}

	function instanceExClass(classname:String, args:Array<Dynamic> = null) {
		return exInterp.createScriptClassInstance(classname, args);
	}
	function makeHaxeExState(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseModule(FNFAssets.getHscript(path + filename));
		trace("set stuff");
		exInterp.registerModule(program);

		trace('executed');
	}
	#end
	var useCustomInput:Bool = false;
	var showMisses:Bool = false;
	var useSongBar:Bool = true;
	var useTimings:Bool = true;
	var useNoteSplashes:Bool = true;
	var camNotes:Bool = false;
	var songName:FlxText;
	var uiSmelly:TUI;
	override public function create() {
		#if desktop
		// pre lowercasing the song name (create)
        var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
        switch (songLowercase) {
            case 'dad-battle': songLowercase = 'dadbattle';
        }
		#end
		Note.getFrames = true;
		Note.getSpecialFrames = true;
		Note.specialNoteJson = null;
		universalVar = new Map<String, Dynamic>();
		if (FNFAssets.exists('assets/data/${SONG.song.toLowerCase()}/noteInfo.json')) {
			Note.specialNoteJson = CoolUtil.parseJson(FNFAssets.getText('assets/data/${SONG.song.toLowerCase()}/noteInfo.json'));
		}
		Judgement.uiJson = CoolUtil.parseJson(FNFAssets.getText('assets/images/custom_ui/ui_packs/ui.json'));
		uiSmelly = Reflect.field(Judgement.uiJson, SONG.uiType);
		misses = 0;
		bads = 0;
		goods = 0;
		sicks = 0;
		shits = 0;
		ss = true;
		// use current note amount
		Note.NOTE_AMOUNT = SONG.preferredNoteAmount;
		var notePresets;
		if (FNFAssets.exists('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/multiNotePresets.json')) {
			notePresets = CoolUtil.parseJson(FNFAssets.getText('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/multiNotePresets.json'));
		} else {
			notePresets = CoolUtil.parseJson(FNFAssets.getText('assets/data/defaultNotePresets.json'));
		}
		currentKey = Reflect.field(notePresets, 'key' + Note.NOTE_AMOUNT);
		currrentKey = Reflect.field(notePresets, 'key' + Note.NOTE_AMOUNT);
		judgementList = CoolUtil.coolTextFile('assets/data/judgements.txt');
		preferredJudgement = judgementList[OptionsHandler.options.preferJudgement];
		if (preferredJudgement == 'none' || SONG.forceJudgements) {
			preferredJudgement = SONG.uiType;
			// if it is not using its own folder make preferred judgement
			if (Reflect.hasField(Judgement.uiJson, preferredJudgement) && Reflect.field(Judgement.uiJson, preferredJudgement).uses != preferredJudgement)
				preferredJudgement = Reflect.field(Judgement.uiJson, preferredJudgement).uses;
		}
		#if windows
		// Making difficulty text for Discord Rich Presence.
		// I JUST REALIZED THIS IS NOT VERY COMPATIBILE
		/*
		switch (storyDifficulty) 
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}
		*/
		storyDifficultyText = DifficultyManager.getDiffName(storyDifficulty);
		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC) {
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
			detailsText = "Story Mode: Week " + storyWeek;
		else
			detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(customPrecence
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
		
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		//FlxCamera.defaultCameras = [camGame];
		persistentUpdate = true;
		persistentDraw = true;
		alwaysDoCutscenes = OptionsHandler.options.alwaysDoCutscenes;
		useCustomInput = OptionsHandler.options.useCustomInput;
		useVictoryScreen = !OptionsHandler.options.skipVictoryScreen;
		downscroll = OptionsHandler.options.downscroll;
		midscroll = OptionsHandler.options.midscroll;
		useSongBar = OptionsHandler.options.showSongPos;
		useTimings = OptionsHandler.options.showTimings;
		useNoteSplashes = OptionsHandler.options.showNoteSplashes;
		camNotes = OptionsHandler.options.camNotes;
		Judge.setJudge(cast OptionsHandler.options.judge);
		pixelUI = uiSmelly.isPixel;
		if (!OptionsHandler.options.skipModifierMenu) {
			fullComboMode = ModifierState.namedModifiers.fc.value;
			goodCombo = ModifierState.namedModifiers.gfc.value;
			perfectMode = ModifierState.namedModifiers.mfc.value;
			practiceMode = ModifierState.namedModifiers.practice.value;
			flippedNotes = ModifierState.namedModifiers.flipped.value;
			accelNotes = ModifierState.namedModifiers.accel.value;
			vnshNotes = ModifierState.namedModifiers.vanish.value;
			invsNotes = ModifierState.namedModifiers.invis.value;
			snakeNotes = ModifierState.namedModifiers.snake.value;
			drunkNotes = ModifierState.namedModifiers.drunk.value;
			inALoop = ModifierState.namedModifiers.loop.value;
			duoMode = ModifierState.namedModifiers.duo.value;
			soloMode = ModifierState.namedModifiers.nos.value;
			opponentPlayer = ModifierState.namedModifiers.oppnt.value;
			demoMode = ModifierState.namedModifiers.demo.value;
			if (ModifierState.namedModifiers.healthloss.value)
				healthLossMultiplier = ModifierState.namedModifiers.healthloss.amount;
			if (ModifierState.namedModifiers.healthgain.value)
				healthGainMultiplier = ModifierState.namedModifiers.healthgain.amount;
			if (ModifierState.namedModifiers.slow.value)
				noteSpeed = 0.3;
			if (accelNotes) {
				noteSpeed = 0.45;
				trace("accel arrows");
			}

			if (ModifierState.namedModifiers.fast.value)
				noteSpeed = 0.9;
			if (ModifierState.namedModifiers.regen.value) {
				loveMultiplier = ModifierState.namedModifiers.regen.amount;
				supLove = true;
			}
			if (ModifierState.namedModifiers.degen.value) {
				poisonMultiplier = ModifierState.namedModifiers.degen.amount;
				poisonExr = true;
			}
			poisonPlus = ModifierState.namedModifiers.poison.value;
		} else {
			ModifierState.scoreMultiplier = 1;
		}
		player1GoodHitSignal = new Signal<Note>();
		player2GoodHitSignal = new Signal<Note>();
		// rebind always, to support multi-key
		if (!opponentPlayer && !duoMode) {
			controls.setKeyboardScheme(Solo(Note.NOTE_AMOUNT));
		}
		if (opponentPlayer) {
			controlsPlayerTwo.setKeyboardScheme(Solo(Note.NOTE_AMOUNT));
		} else {
			controlsPlayerTwo.setKeyboardScheme(Duo(false));
		}
		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var sploosh = new NoteSplash(100, 100, 0);
		sploosh.alpha = 0.1;
		grpNoteSplashes.add(sploosh);
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		initialStepCrochet = Conductor.stepCrochet;
		var dialogSuffix = "";
		if (OptionsHandler.options.stressTankmen) {
			dialogSuffix = "-shit";
		}
		// if this is skipped when love is on, that means love is less than or equal to fright so
		else if (supLove && poisonMultiplier < loveMultiplier) {
			dialogSuffix = "-love";
		} else if (poisonExr && poisonMultiplier < 50) {
			dialogSuffix = "-uneasy";
		} else if (poisonExr && poisonMultiplier >= 50 && poisonMultiplier < 100) {
			dialogSuffix = "-scared";
		} else if (poisonExr && poisonMultiplier >= 100 && poisonMultiplier < 200) {
			dialogSuffix = "-terrified";
		} else if (poisonExr && poisonMultiplier >= 200) {
			dialogSuffix = "-depressed";
		} else if (practiceMode) {
			dialogSuffix = "-practice";
		} else if (perfectMode || fullComboMode || goodCombo) {
			dialogSuffix = "-perfect";
		}
		var filename:Null<String> = null;
		var acceptableFiles:Array<String> = [
			'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog.txt',
			'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialogue.txt',
			'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog.txt',
			'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialogue.txt',
			'assets/data/' + SONG.song.toLowerCase() + '/dialog.txt',
			'assets/data/' + SONG.song.toLowerCase() + '/dialogue.txt'
		];
		if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog.txt')) {	
			filename = 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog.txt';
			if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog'+dialogSuffix+'.txt'))
				filename = 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog' + dialogSuffix + '.txt';
		} else if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog.txt')) {
			filename = 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog.txt';
			if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt')) {
				filename = 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt';
			}
			// if no player dialog, use default
		} else if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialog.txt')) {
			filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialog.txt';
			if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt')) {
				filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt';
			}
		} else if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialogue.txt')) {
			filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialogue.txt';
			if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt')) {
				filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt';
			}
		}
		var goodDialog:String;
		if (filename != null) {
			goodDialog = FNFAssets.getText(filename);
		} else {
			goodDialog = ':dad: The game tried to get a dialog file but couldn\'t find it. Please make sure there is a dialog file named "dialog.txt".';
		}

		#if desktop
		if (FileSystem.exists('assets/data/' + songLowercase  + "/preload.txt")) {
			var characters:Array<String> = CoolUtil.coolTextFile('assets/data/' + songLowercase  + "/preload.txt");
			for (i in 0...characters.length) {
				// this way of preload sux
				// I will make a better version later <3
			}
		}
		#end

		daScrollSpeed = OptionsHandler.options.scrollSpeed == 1 ? daScrollSpeed = SONG.speed : OptionsHandler.options.scrollSpeed;
		
		trace(SONG.gf);
		gf = addCharacter(SONG.gf, 'gf');
		
		dad = addCharacter(SONG.player2, 'dad');
		if (duoMode || opponentPlayer || soloMode)
			dad.beingControlled = true;

		var camPos:FlxPoint = new FlxPoint(dad.getMidpoint().x + 300, dad.getMidpoint().y);
		camPos.x += dad.camOffsetX;
		camPos.y += dad.camOffsetY;

		if (dad.likeGf) {
			dad.setPosition(gf.x, gf.y);
			gf.visible = false;
			if (isStoryMode) {
				tweenCamIn();
			}
		}

		boyfriend = addCharacter(SONG.player1, 'bf');
		if (!opponentPlayer && !demoMode)
			boyfriend.beingControlled = true;

		if (boyfriend.likeGf && !dad.likeGf) {
			boyfriend.setPosition(gf.x, gf.y);
			gf.visible = false;
			if (isStoryMode) {
				tweenCamIn();
			}
		}

		// REPOSITIONING PER STAGE
		boyfriend.x += bfoffset[0];
		boyfriend.y += bfoffset[1];
		gf.x += gfoffset[0];
		gf.y += gfoffset[1];
		dad.x += dadoffset[0];
		dad.y += dadoffset[1];
		trace('befpre spoop check');
		if (SONG.isSpooky) {
			trace("WOAH SPOOPY");
			var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			evilTrail.framesEnabled = false;
			// evilTrail.changeValuesEnabled(false, false, false, false);
			// evilTrail.changeGraphic()
			trace(evilTrail);
			add(evilTrail);
		}
		add(gf);
		trace('dad');
		add(dad);
		trace('dy UWU');
		add(boyfriend);
		trace('bf cheeks');

		doof = new DialogueBox(false, goodDialog);
		trace('doofensmiz');
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;
		trace('prepare your strumlime');
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		if (downscroll)
			strumLine.y = FlxG.height - 165;

		playerComboBreak = new FlxTypedGroup<FlxSprite>();
		enemyComboBreak = new FlxTypedGroup<FlxSprite>();
		playerComboBreak.cameras = [camHUD];
		enemyComboBreak.cameras = [camHUD];
		add(playerComboBreak);
		add(enemyComboBreak);
		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);
		add(grpNoteSplashes);
		playerStrums = new FlxTypedGroup<FlxSprite>();
		enemyStrums = new FlxTypedGroup<FlxSprite>();
		
		// startCountdown();
		trace('before generate');
		generateSong(SONG.song);

		// add(strumLine);
		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, camSpeed);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.scroll.x = camPos.x;
		FlxG.camera.scroll.y = camPos.y;

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		trace('gay');
		songPosBG = new FlxSprite(0, 10).loadGraphic('assets/images/healthBar.png');
		if (downscroll)
			songPosBG.y = FlxG.height * 0.9 + 45;
		songPosBG.screenCenter(X);
		songPosBG.scrollFactor.set();
		songPosBG.cameras = [camHUD];

		songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
			'songPositionBar', 0, 1);
		songPosBar.scrollFactor.set();
		songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
		songPosBar.numDivisions = 1000;
		songPosBar.cameras = [camHUD];

		songName = new FlxText(songPosBG.x, songPosBG.y, songPosBG.width, StringTools.replace(SONG.song, '-', ' '), 16);
		if (downscroll)
			songName.y -= 3;
		songName.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songName.scrollFactor.set();
		songName.cameras = [camHUD];

		if (useSongBar) {
			add(songPosBG);
			add(songPosBar);
			add(songName);
		}

		if (FNFAssets.exists('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/healthBar.png'))
			healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/healthBar.png'));
		else
			healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(FNFAssets.getBitmapData('assets/images/healthBar.png'));
		if (downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(0, healthBarBG.y + 40, FlxG.width, "", 200);
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		healthTxt = new FlxText(healthBarBG.x + healthBarBG.width - 300, scoreTxt.y, 0, "", 200);
		healthTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		healthTxt.scrollFactor.set();
		healthTxt.visible = false;

		accuracyTxt = new FlxText(healthBarBG.x, scoreTxt.y, 0, "", 200);
		accuracyTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		accuracyTxt.scrollFactor.set();
		// shitty work around but okay
		accuracyTxt.visible = false;

		difficTxt = new FlxText(10, FlxG.height, 0, "", 150);
		difficTxt.setFormat("assets/fonts/vcr.ttf", 15, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		difficTxt.scrollFactor.set();
		difficTxt.y -= difficTxt.height;
		if (downscroll)
			difficTxt.y = 0;
		difficTxt.text = storyDifficultyText + ' - Disappointing+ ${MainMenuState.version}';
		
		iconP1 = new HealthIcon(SONG.player1, true, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false, true);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		updateHealthColors();

		practiceDieIcon = new HealthIcon('bf-old', false, true);
		practiceDieIcon.y = healthBar.y - (practiceDieIcon.height / 2);
		practiceDieIcon.x = healthBar.x - 130;
		practiceDieIcon.animation.curAnim.curFrame = 1;
		add(practiceDieIcon);

		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		practiceDieIcon.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		healthTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		accuracyTxt.cameras = [camHUD];
		difficTxt.cameras = [camHUD];
		practiceDieIcon.visible = false;

		add(scoreTxt);
		add(difficTxt);

		startingSong = true;
		trace('finish uo');
		
		var stageJson = CoolUtil.parseJson(FNFAssets.getText("assets/images/custom_stages/custom_stages.json"));
		if (Reflect.hasField(stageJson, SONG.stage)) {
			curStage = new StageHelper(SONG.stage);
			makeHaxeState("stage", "assets/images/custom_stages/" + SONG.stage + "/", "../"+Reflect.field(stageJson, SONG.stage));
			curStage.interp = hscriptStates.get('stage');
		} else
			curStage = new StageHelper('Invalid Stage: ' + SONG.stage);
		setAllHaxeVar('stage', curStage);
		//add(curStage);

		trace('stage done');
		
		var uiJson = CoolUtil.parseJson(FNFAssets.getText("assets/images/custom_ui/ui_layouts/ui.json"));
		if (SONG.forceLayout != 'none')
			makeHaxeStateUI("uilayout", "assets/images/custom_ui/ui_layouts/" + SONG.forceLayout + "/", "../" + SONG.forceLayout + ".hscript");
		else if (Reflect.field(uiJson, 'layout') != 'none')
			makeHaxeStateUI("uilayout", "assets/images/custom_ui/ui_layouts/" + Reflect.field(uiJson, 'layout') + "/", "../" + Reflect.field(uiJson, 'layout') + ".hscript");

		trace('ui done');

	if (alwaysDoCutscenes || isStoryMode) {
		switch (SONG.cutsceneType) {
				/*
				case "monster":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer) {
						remove(blackScreen);
						FlxG.sound.play('assets/sounds/Lights_Turn_On' + TitleState.soundExt);
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer) {
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween) {
									startCountdown();
								}
							});
						});
					});
				*/
				case 'senpai':
					schoolIntro(doof);
				case 'angry-senpai':
					schoolIntro(doof);
				case 'none':
					startCountdown();
				default:
					// schoolIntro(doof);
					customIntro(doof);
			}
		} else {
			startCountdown();
		}

		super.create();
	}

	function customIntro(?dialogueBox:DialogueBox) {
		var goodJson = CoolUtil.parseJson(FNFAssets.getText('assets/images/custom_cutscenes/cutscenes.json'));
		if (!Reflect.hasField(goodJson, SONG.cutsceneType)) {
			schoolIntro(dialogueBox);
			return;
		}
		makeHaxeState("cutscene", "assets/images/custom_cutscenes/"+SONG.cutsceneType+'/', "../"+Reflect.field(goodJson, SONG.cutsceneType));
	}
	function schoolIntro(?dialogueBox:DialogueBox, intro:Bool=true):Void {
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);
		/*
		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();
		var senpaiSound:Sound;
		// try and find a player2 sound first
		if (FNFAssets.exists('assets/images/custom_chars/'+SONG.player2+'/Senpai_Dies.ogg')) {
			senpaiSound = FNFAssets.getSound('assets/images/custom_chars/'+SONG.player2+'/Senpai_Dies.ogg');
		// otherwise, try and find a song one
		} else if (FNFAssets.exists('assets/data/'+SONG.song.toLowerCase()+'/Senpai_Dies.ogg')) {
			senpaiSound = FNFAssets.getSound('assets/data/'+SONG.song.toLowerCase()+'Senpai_Dies.ogg');
		// otherwise, use the default sound
		} else {
			senpaiSound = FNFAssets.getSound('assets/sounds/Senpai_Dies.ogg');
		}
		var senpaiEvil:FlxSprite = new FlxSprite();
		// dialog box overwrites character
		if (FNFAssets.exists('assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.png')) {
			var evilImage = FNFAssets.getBitmapData('assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.png');
			var evilXml = FNFAssets.getText('assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.xml');
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow(evilImage, evilXml);
		// character then takes precendence over default
		// will make things like monika way way easier
		} else if (FNFAssets.exists('assets/images/custom_chars/'+SONG.player2+'/crazy.png')) {
			var evilImage = FNFAssets.getBitmapData('assets/images/custom_chars/'+SONG.player2+'/crazy.png');
			var evilXml = FNFAssets.getText('assets/images/custom_chars/'+SONG.player2+'/crazy.xml');
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow(evilImage, evilXml);
		} else {
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow('assets/images/weeb/senpaiCrazy.png', 'assets/images/weeb/senpaiCrazy.xml');
		}

		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		if (dad.isPixel)
			senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		*/
		if (SONG.cutsceneType == 'angry-senpai')
			remove(black);

		new FlxTimer().start(0.3, function(tmr:FlxTimer) {
			black.alpha -= 0.15;

			if (black.alpha > 0) {
				tmr.reset(0.3);
			} else {
				if (dialogueBox != null) {
					inCutscene = true;
					// haha weeeee
					/*
					if (SONG.cutsceneType == 'spirit') {
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer) {
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1) {
								swagTimer.reset();
							} else {
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(senpaiSound, 1, false, null, true, function() {
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function() {
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer) {
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					*/
					add(dialogueBox);
				} else
					if (intro)
						startCountdown();
					else 
						endForReal();

				remove(black);
			}
		});
	}
	function videoIntro(filename:String) {
		startCountdown();
		/*
		var b = new FlxSprite(-200, -200).makeGraphic(2*FlxG.width,2*FlxG.height, -16777216);
		b.scrollFactor.set();
		add(b);
		trace(filename);
		new FlxVideo(filename).finishCallback = function () {
			remove(b);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet / 1000) * 5, {ease: FlxEase.quadInOut});
			startCountdown();
		}*/
	}
	var startTimer:FlxTimer;

	public function startCountdown():Void {
		inCutscene = false;

		generateStaticArrows(0, SONG.uiType, true);
		generateStaticArrows(1, SONG.uiType, true);
		var daDefault = DifficultyManager.getDefaultFromName(storyDifficultyText);
		if (daDefault == '') daDefault = storyDifficultyText.toLowerCase();
		if (FNFAssets.exists("assets/data/" + SONG.song.toLowerCase() + "/modchart-" + daDefault, Hscript))
			makeHaxeState("modchart", "assets/data/" + SONG.song.toLowerCase() + "/", "modchart-" + daDefault);
		else if (FNFAssets.exists("assets/data/" + SONG.song.toLowerCase() + "/modchart", Hscript))
			makeHaxeState("modchart", "assets/data/" + SONG.song.toLowerCase() + "/", "modchart");

		if (duoMode)
			controls.setKeyboardScheme(Duo(true));

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		if (!skipCountdown) {
			Conductor.songPosition -= Conductor.crochet * 5;

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
				if (!duoMode || opponentPlayer)
					dad.dance();
				if (opponentPlayer)
					boyfriend.dance();
				gf.dance();

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();

				for (field in Reflect.fields(Judgement.uiJson)) {
					if (Reflect.field(Judgement.uiJson, field).isPixel)
						introAssets.set(field, [
							'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/ready-pixel.png',
							'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/set-pixel.png',
							'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/date-pixel.png']);
					else
						introAssets.set(field, [
							'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/ready.png',
							'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/set.png',
							'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/go.png']);
				}

				var introAlts:Array<String> = introAssets.get('default');
				var altSuffix:String = "";
				var intro3Sound:Sound;
				var intro2Sound:Sound;
				var intro1Sound:Sound;
				var introGoSound:Sound;
				for (value in introAssets.keys()) {
					if (value == SONG.uiType) {
						introAlts = introAssets.get(value);
						// ok so apparently a leading slash means absolute soooooo
						if (pixelUI)
							altSuffix = '-pixel';
					}
				}

				// god is dead for we have killed him
				if (FNFAssets.exists("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro3' + altSuffix + '.ogg')) {
					intro3Sound = FNFAssets.getSound("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro3' + altSuffix + '.ogg');
					intro2Sound = FNFAssets.getSound("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro2' + altSuffix + '.ogg');
					intro1Sound = FNFAssets.getSound("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro1' + altSuffix + '.ogg');
					// apparently this crashes if we do it from audio buffer?
					// no it just understands 'hey that file doesn't exist better do an error'
					introGoSound = FNFAssets.getSound("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/introGo' + altSuffix + '.ogg');
				} else {
					intro3Sound = FNFAssets.getSound('assets/sounds/intro3.ogg');
					intro2Sound = FNFAssets.getSound('assets/sounds/intro2.ogg');
					intro1Sound = FNFAssets.getSound('assets/sounds/intro1.ogg');
					introGoSound = FNFAssets.getSound('assets/sounds/introGo.ogg');
				}

				switch (swagCounter) {
					case 0:
						FlxG.sound.play(intro3Sound, 0.6);
					case 1:
						// my life is a lie, it was always this simple
						countdownPopup(0, 'assets/images/' + introAlts[0]);
						FlxG.sound.play(intro2Sound, 0.6);
					case 2:
						countdownPopup(1, 'assets/images/' + introAlts[1]);
						FlxG.sound.play(intro1Sound, 0.6);
					case 3:
						countdownPopup(2, 'assets/images/' + introAlts[2]);
						FlxG.sound.play(introGoSound, 0.6);
					case 4:
						// what is this here for?
				}

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		} else {
			// this prevents the game from crashing when pausing/dying
			startTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer) {
				trace('countdown skipped');
			});
		}
		/*
		regenTimer = new FlxTimer().start(2, function (tmr:FlxTimer) {
			var bonus = drainBy;
			if (opponentPlayer) {
				bonus = -1 * drainBy;
			}
			if (poisonExr && !paused)
				health -= bonus;
			if (supLove && !paused)
				health +=  bonus;
		}, 0);
		*/
		sickFastTimer = new FlxTimer().start(2, function (tmr:FlxTimer) {
			if (accelNotes && !paused) {
				trace("tick:" + noteSpeed);
				noteSpeed += 0.01;
			}

		}, 0);
		var snekBase:Float = 0;
		var snekTimer = new FlxTimer().start(0.01, function (tmr:FlxTimer) {
			if (snakeNotes && !paused) {
				snekNumber = Math.sin(snekBase) * 100;
				snekBase += Math.PI/100;
			}

		}, 0);
	}

	public function countdownPopup(stage:Int = 0, sussyPath:String = 'none') {
		if (!FNFAssets.exists(sussyPath))
			sussyPath = switch(stage) {
				case 0:
					'assets/images/ready.png';
				case 1:
					'assets/images/set.png';
				case 2:
					'assets/images/go.png';
				default:
					'assets/images/restart.png';
			}
		
		var countImage = FNFAssets.getBitmapData(sussyPath);
		var count:FlxSprite = new FlxSprite().loadGraphic(countImage);
		count.scrollFactor.set();
		
		if (pixelUI)
			count.setGraphicSize(Std.int(count.width * daPixelZoom));

		count.updateHitbox();
		count.screenCenter();
		add(count);
		FlxTween.tween(count, {y: count.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween) {
				count.destroy();
			}
		});
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	function startSong():Void {
		startingSong = false;
		if (FlxG.sound.music != null) {
			// cuck lunchbox
			FlxG.sound.music.stop();
		}
		// : )
		previousFrameTime = FlxG.game.ticks;
		
		if (!paused)
			FlxG.sound.playMusic(inst, 1, false);
		songLength = FlxG.sound.music.length;
		updateUV('songLength', songLength);

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		callAllHScript('songStart', [SONG.song]);
		callAllHScript("stepHit", [0]);
		callAllHScript("beatHit", [0]);

		vocals.pause();
		FlxG.sound.music.pause();
		Conductor.songPosition = startingPosition;
		FlxG.sound.music.time = Conductor.songPosition;
		vocals.time = Conductor.songPosition;
		FlxG.sound.music.play();
		vocals.play();
	}

	private function generateSong(dataPath:String):Void {
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		var useInst = null; // now can use both 'Inst.ogg' and '(songname)_Inst.ogg' (and the music folder if you're still using that lol)
		if (OptionsHandler.options.stressTankmen)
			useInst = CoolUtil.getSongFile(SONG.song + "Shit", "assets/songs/" + SONG.song + '/');

		var daDefault = DifficultyManager.getDefaultFromName(storyDifficultyText);
		if (daDefault == '') daDefault = storyDifficultyText.toLowerCase();
		useInst = CoolUtil.getSongFile(SONG.song, "assets/songs/" + SONG.song + '/', true, '-' + daDefault);

		if (useInst == null)
			useInst = CoolUtil.getSongFile(SONG.song, "assets/songs/" + SONG.song + '/');

		/*
		if (FNFAssets.exists("assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "_Inst" + TitleState.soundExt)) {
			useSong = "assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "_Inst" + TitleState.soundExt;
			if (OptionsHandler.options.stressTankmen && FNFAssets.exists("assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "Shit_Inst.ogg")) {
				useSong = "assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "Shit_Inst.ogg";
			}
		} else if (FNFAssets.exists("assets/songs/" + SONG.song.toLowerCase() + '/Inst' + TitleState.soundExt)) {
			useSong = "assets/songs/" + SONG.song.toLowerCase() + '/Inst' + TitleState.soundExt;
			if (OptionsHandler.options.stressTankmen && FNFAssets.exists('assets/songs/' + SONG.song.toLowerCase() + '/Shit_Inst.ogg')) {
				useSong = "assets/songs/" + SONG.song.toLowerCase() + '/Shit_Inst.ogg';
			}
		} else {
			useSong = "assets/music/" + SONG.song + "_Inst" + TitleState.soundExt;
			if (OptionsHandler.options.stressTankmen && FNFAssets.exists("assets/music/" + SONG.song + "Shit_Inst.ogg")) {
				useSong = "assets/music/" + SONG.song + "Shit_Inst.ogg";
			}
		}
		*/

		var useVocals = null; // now can use both 'Voices.ogg' and '(songname)_Voices.ogg' (and the music folder if you're still using that lol)
		if (OptionsHandler.options.stressTankmen)
			useVocals = CoolUtil.getSongFile(SONG.song + "Shit", "assets/songs/" + SONG.song + '/', false);

		useVocals = CoolUtil.getSongFile(SONG.song, "assets/songs/" + SONG.song + '/', false, '-' + daDefault);

		if (useVocals == null)
			useVocals = CoolUtil.getSongFile(SONG.song, "assets/songs/" + SONG.song + '/', false);

		/*
		if (FNFAssets.exists("assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "_Voices" + TitleState.soundExt)) {
			useSong = "assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "_Voices" + TitleState.soundExt;
			if (OptionsHandler.options.stressTankmen && FNFAssets.exists("assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "Shit_Voices.ogg")) {
				useSong = "assets/songs/" + SONG.song.toLowerCase() + '/' + SONG.song + "Shit_Voices.ogg";
			}
		} else if (FNFAssets.exists("assets/songs/" + SONG.song.toLowerCase() + '/Voices' + TitleState.soundExt)) {
			useSong = "assets/songs/" + SONG.song.toLowerCase() + '/Voices' + TitleState.soundExt;
			if (OptionsHandler.options.stressTankmen && FNFAssets.exists("assets/songs/" + SONG.song.toLowerCase() + '/Shit_Voices.ogg')) {
				useSong = "assets/songs/" + SONG.song.toLowerCase() + '/Shit_Voices.ogg';
			}
		} else {
			useSong = "assets/music/" + SONG.song + "_Voices" + TitleState.soundExt;
			if (OptionsHandler.options.stressTankmen && FNFAssets.exists("assets/music/" + SONG.song + "Shit_Voices.ogg")) {
				useSong = "assets/music/" + SONG.song + "Shit_Voices.ogg";
			}
		}
		*/
		
		inst = Sound.fromFile(useInst);

		if (SONG.needsVoices) {
			#if sys
			var vocalSound = Sound.fromFile(useVocals);
			vocals = new FlxSound().loadEmbedded(vocalSound);
			#else
			vocals = new FlxSound().loadEmbedded(useVocals);
			#end
		} else
			vocals = new FlxSound();

		vocals.looped = false;
		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		var customImage:Null<BitmapData> = null;
		var customXml:Null<String> = null;
		var arrowEndsImage:Null<BitmapData> = null;
		if (!pixelUI) {
			trace("has this been reached");
			customImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/NOTE_assets.png');
			customXml = FNFAssets.getText('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/NOTE_assets.xml');
		} else {
			customImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/arrows-pixels.png');
			arrowEndsImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/arrowEnds.png');
		}
		
		var daSection:Int = 0;

		for (section in noteData) {
			if (daSection == 24 && curSong.toLowerCase() == 'hijinks-betadciu')
				SONG.uiType = 'pixel';

			if (daSection == 40 && curSong.toLowerCase() == 'hijinks-betadciu')
				SONG.uiType = 'normal';

			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0] + OptionsHandler.options.offset;
				if (startPosSong != SONG.song) {
					startingPosition = 0;
					startPosSong = SONG.song;
				}
				if (daStrumTime >= startingPosition) {
				var daNoteData:Int = Std.int(songNotes[1] % Note.NOTE_AMOUNT);
				var noteHeal:Float = songNotes[5] == null ? 1 : songNotes[5];
				var noteDamage:Float = songNotes[6] == null ? 1 : songNotes[6];
				var consitentNote:Bool = cast songNotes[7];
				var timeThingy:Float = songNotes[8] == null ? 1 : songNotes[8];
				// casting is not ok as default is true
				var shouldSing:Bool = if (songNotes[9] == null) true else songNotes[9];
				// casting is ok as null is falsey
				var ignoreHealthMods:Bool = cast songNotes[10];
				var animSuffix:Null<String> = songNotes[11];
				var gottaHitNote:Bool = section.mustHitSection;
				var altNote:Bool = false;
				var doTheFunny:Bool = false;
				var soloNote:Bool = false;
				if (songNotes[1] % (Note.NOTE_AMOUNT*2) > Note.NOTE_AMOUNT-1) {
					gottaHitNote = !section.mustHitSection;
				}

				if (ModifierState.namedModifiers.nos.value && !gottaHitNote) {
					gottaHitNote = true;
					soloNote = true;
				}

				/*
				if (songNotes[1] >= (Note.NOTE_AMOUNT*2) && songNotes[1] < (Note.NOTE_AMOUNT*4)) {
					// sussy fire note support? :flushed:
					// Percent in decimal divided by health thingie
					noteHeal = 0.125 / 0.04;
					consitentNote = true;
					shouldSing = false;
					timeThingy = 0.5;
					noteDamage = 0;
					ignoreHealthMods = true;
					animSuffix = "lift";
				}
				*/
				if (songNotes[3] || section.altAnim)
					altNote = true;

				// force nuke notes : )
				if (songNotes[1] >= Note.NOTE_AMOUNT * 2 && songNotes[1] < Note.NOTE_AMOUNT * 4 && SONG.convertMineToNuke) {
					songNotes[1] += Note.NOTE_AMOUNT * 4;
				}
				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				// stand back i am a professional idiot
				var swagNote:Note = new Note(daStrumTime, songNotes[1], oldNote, false, customImage, customXml, arrowEndsImage, animSuffix);
				if (!swagNote.dontEdit && !swagNote.mineNote && !swagNote.nukeNote && !swagNote.isLiftNote) {
					swagNote.shouldBeSung = shouldSing;
					swagNote.ignoreHealthMods = ignoreHealthMods;
					swagNote.timingMultiplier = timeThingy;
					swagNote.healMultiplier = noteHeal;
					swagNote.damageMultiplier = noteDamage;
					swagNote.consistentHealth = consitentNote;
				}
				swagNote.soloMode = soloNote;

				// altNote
				swagNote.altNote = altNote;
				swagNote.altNum = songNotes[3] == null ? (swagNote.altNote ? 1 : 0) : songNotes[3];

				if (duoMode)
					swagNote.duoMode = true;
				if (opponentPlayer)
					swagNote.oppMode = true;
				if (demoMode)
					swagNote.funnyMode = true;
				swagNote.sustainLength = songNotes[2] != null ? songNotes[2] : 0;
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				// when the imposter is sus XD
				if (susLength != 0 && !ModifierState.namedModifiers.nos.value) {
					for (susNote in 0...Math.floor(susLength)) { // no + 2 please and thanks <3
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						if (OptionsHandler.options.emuOsuLifts && susLength < susNote) {
							// simulate osu!mania holds by adding lifts at the end
							var liftNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, false,
								customImage, customXml, arrowEndsImage);
							if (duoMode)
								liftNote.duoMode = true;
							if (opponentPlayer)
								liftNote.oppMode = true;
							if (demoMode)
								liftNote.funnyMode = true;
							liftNote.scrollFactor.set();
							unspawnNotes.push(liftNote);
							liftNote.mustPress = gottaHitNote;
							if (liftNote.mustPress)
								liftNote.x += FlxG.width / 2;

							// how haxe works by default is exclusive?
						} else if (susLength > susNote) {
							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, songNotes[1], oldNote,
								true, customImage, customXml, arrowEndsImage);
							if (duoMode)
								sustainNote.duoMode = true;
							if (opponentPlayer)
								sustainNote.oppMode = true;
							if (demoMode)
								sustainNote.funnyMode = true;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);
							if (!sustainNote.dontEdit && !sustainNote.mineNote && !sustainNote.nukeNote && !sustainNote.isLiftNote) {
								sustainNote.shouldBeSung = shouldSing;
								sustainNote.ignoreHealthMods = ignoreHealthMods;
								sustainNote.timingMultiplier = timeThingy;
								sustainNote.healMultiplier = noteHeal;
								sustainNote.damageMultiplier = noteDamage;
								sustainNote.consistentHealth = consitentNote;
							}
							sustainNote.mustPress = gottaHitNote;

							if (sustainNote.mustPress) {
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress) {
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			}
			daSection += 1;
			daBeats += 1;
		}
		
		unspawnNotes.sort(sortByShit);
		defaultNoteWidth = unspawnNotes[0].width;
		generatedMusic = true;
	}
	var defaultNoteWidth:Float;
	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int, type:String, transition:Bool):Void {
		var daType = Reflect.field(Judgement.uiJson, type);
		if (player == 1) {
			playerStrums.forEach(function (spr) {
				spr.kill();
				//playerStrums.remove(spr, true);
				//spr.destroy();
			});
		} else {
			enemyStrums.forEach(function (spr) {
				spr.kill();
				//enemyStrums.remove(spr, true);
				//spr.destroy();
			});
		}
		for (i in 0...Note.NOTE_AMOUNT) {
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(42, strumLine.y);
			if (!daType.isPixel) {
				var noteXml = FNFAssets.getText('assets/images/custom_ui/ui_packs/' + daType.uses + "/NOTE_assets.xml");
				var notePic = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + daType.uses + "/NOTE_assets.png");
				babyArrow.frames = FlxAtlasFrames.fromSparrow(notePic, noteXml);
				var currentNote = !flippedNotes ? currentKey[i] : currentKey[Note.NOTE_AMOUNT - (i+1)];

				babyArrow.animation.addByPrefix('static', currentNote.idle);
				babyArrow.animation.addByPrefix('pressed', currentNote.pressed, 24, false);
				babyArrow.animation.addByPrefix('confirm', currentNote.confirm, 24, false);
				babyArrow.x += Note.swagWidth * i;

				babyArrow.antialiasing = true;
				babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			} else {
				if (FNFAssets.exists('assets/images/custom_ui/ui_packs/' + daType.uses + "/arrows-pixels.xml")) {
					var noteXml = FNFAssets.getText('assets/images/custom_ui/ui_packs/' + daType.uses + "/arrows-pixels.xml");
					var notePic = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + daType.uses + "/arrows-pixels.png");
					babyArrow.frames = FlxAtlasFrames.fromSparrow(notePic, noteXml);
					var currentNote = !flippedNotes ? currentKey[i] : currentKey[Note.NOTE_AMOUNT - (i+1)];

					babyArrow.animation.addByPrefix('static', currentNote.idle);
					babyArrow.animation.addByPrefix('pressed', currentNote.pressed, 12, false);
					babyArrow.animation.addByPrefix('confirm', currentNote.confirm, 12, false);
					babyArrow.x += Note.swagWidth * i;

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;
				} else {
					var notePic = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + daType.uses + "/arrows-pixels.png");
					babyArrow.loadGraphic(notePic, true, 17, 17);

					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);
					if (flippedNotes) {
						babyArrow.animation.add('blue', [6]);
						babyArrow.animation.add('purplel', [7]);
						babyArrow.animation.add('green', [5]);
						babyArrow.animation.add('red', [4]);
					}
					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i)) {
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
							if (flippedNotes) {
								babyArrow.animation.add('static', [1]);
								babyArrow.animation.add('pressed', [5, 9], 12, false);
								babyArrow.animation.add('confirm', [13, 17], 12, false);
							}
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
							if (flippedNotes) {
								babyArrow.animation.add('static', [0]);
								babyArrow.animation.add('pressed', [4, 8], 12, false);
								babyArrow.animation.add('confirm', [12, 16], 24, false);
							}
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
							if (flippedNotes) {
								babyArrow.animation.add('static', [2]);
								babyArrow.animation.add('pressed', [6, 10], 12, false);
								babyArrow.animation.add('confirm', [14, 18], 12, false);
							}
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
							if (flippedNotes) {
								babyArrow.animation.add('static', [3]);
								babyArrow.animation.add('pressed', [7, 11], 12, false);
								babyArrow.animation.add('confirm', [15, 19], 24, false);
							}
					}
				}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (transition) {
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			
			babyArrow.ID = i;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
				enemyStrums.add(babyArrow);

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);
			strumLineNotes.add(babyArrow);
			if ((midscroll && !duoMode) || soloMode) { // middlescroll hijinks (coming 2085)
				if (player == 0) {
					if (opponentPlayer) {
						babyArrow.x += 325;
					} else {
						babyArrow.x = -500; // gone
					}
				} else {
					if (!opponentPlayer) {
						babyArrow.x -= 315;
					} else {
						babyArrow.x = -500; // gone
					}
				}
			}
			//trace(strumLineNotes);

			if (Note.NOTE_AMOUNT > 4) {
				babyArrow.x -= 10 + 15 * (Note.NOTE_AMOUNT - 4) + (20 + (7 * (Note.NOTE_AMOUNT - 5))) * babyArrow.ID;
				if (daType.isPixel) {
					babyArrow.scale.x = babyArrow.scale.x - 0.05 * (Note.NOTE_AMOUNT - 5) * daPixelZoom;
					babyArrow.scale.y = babyArrow.scale.y - 0.05 * (Note.NOTE_AMOUNT - 5) * daPixelZoom;
				} else {
					babyArrow.scale.x = babyArrow.scale.x - 0.05 * (Note.NOTE_AMOUNT - 5);
					babyArrow.scale.y = babyArrow.scale.y - 0.05 * (Note.NOTE_AMOUNT - 5);
				}
			} else if (Note.NOTE_AMOUNT < 4) {
				// maybe later
			}

			if (player == 1) {
				playerComboBreak.forEach(function (spr) {
					spr.kill();
				});
			} else {
				enemyComboBreak.forEach(function (spr) {
					spr.kill();
				});
			}

			// does not need to be unique because it uses special thingies
			var comboBreakThing = new FlxSprite(babyArrow.x, 0).makeGraphic(Std.int(babyArrow.width), FlxG.height, FlxColor.WHITE);
			comboBreakThing.visible = false;
			comboBreakThing.alpha = 0.6;
			if (player == 1)
				playerComboBreak.add(comboBreakThing);
			else
				enemyComboBreak.add(comboBreakThing);
		}
	}
	function comboBreak(dir:Int, playerOne:Bool = true, rating:String = 'miss') {
		if (!OptionsHandler.options.showComboBreaks)
			return;
		var coolor = switch (rating) {
			case 'miss':
				missBreakColor;
			case 'wayoff':
				wayoffBreakColor;
			case 'shit':
				shitBreakColor;
			default:
				// just return, as we shouldn't even be here
				return;
		}
		var breakGroup = playerOne ? playerComboBreak : enemyComboBreak;
		dir = dir % 4;
		var thingToDisplay = breakGroup.members[dir];
		thingToDisplay.color = coolor;
		thingToDisplay.alpha = 1;
		thingToDisplay.visible = true;
		FlxTween.tween(thingToDisplay, {alpha: 0}, 1, {onComplete: function(_) {thingToDisplay.visible = false;}});
	}

	function tweenCamIn():Void {
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	// from newer fnf
	var curCamPos:FlxTween;
	function FocusCamera(eventInfo:Dynamic):Void {
		var char:Int = eventInfo.char != null ? eventInfo.char : -2;
		var x:Float = eventInfo.x != null ? eventInfo.x : 0;
		var y:Float = eventInfo.y != null ? eventInfo.y : 0;
		var duration:Float = eventInfo.duration != null ? eventInfo.duration : 4;
		var ease:String = eventInfo.ease != null ? eventInfo.ease : 'classic';
		
		var targetPos:Array<Float> = [x, y];
		switch(char) {
			case -1 | 3:
				// don't needa thing
			case 0:
				targetPos[0] += boyfriend.getMidpoint().x + bfCamOffset[0] + boyfriend.followCamX;
				targetPos[1] += boyfriend.getMidpoint().y + bfCamOffset[1] + boyfriend.followCamY;
			case 1:
				targetPos[0] += dad.getMidpoint().x + dadCamOffset[0] + dad.followCamX;
				targetPos[1] += dad.getMidpoint().y + dadCamOffset[1] + dad.followCamY;
			case 2:
				targetPos[0] += gf.getMidpoint().x + gf.followCamX;
				targetPos[1] += gf.getMidpoint().y + gf.followCamY;
			default:
				trace('cant focus on that ($char)');
		}
		if (curCamPos != null) curCamPos.cancel();
		switch(ease.toLowerCase()) {
			case 'classic':
				switch(char) {
					case -1:
						scriptableCamera = 'static';
						scriptCamPos[0] = targetPos;
					case 0:
						scriptableCamera = 'bf';
						scriptCamPos[0] = [x, y];
					case 1:
						scriptableCamera = 'dad';
						scriptCamPos[0] = [x, y];
					case 2:
						scriptableCamera = 'gf';
						scriptCamPos[0] = [x, y];
					default:
						trace('cant focus on that ($char), turning off scriptcam');
						scriptableCamera = 'false';
				}
			case 'instant':
				scriptableCamera = 'static';
				scriptCamPos[0] = targetPos;
				camFollow.x = targetPos[0];
				camFollow.y = targetPos[1];
				var realTarget = camFollow.getPosition() - FlxPoint.weak(FlxG.camera.width * 0.5, FlxG.camera.height * 0.5);
				FlxG.camera.scroll.x = realTarget.x;
				FlxG.camera.scroll.y = realTarget.y;
			default:
				scriptableCamera = 'static';
				camFollow.x = targetPos[0];
				camFollow.y = targetPos[1];
				scriptCamPos[0] = targetPos;
				var realTarget = camFollow.getPosition() - FlxPoint.weak(FlxG.camera.width * 0.5, FlxG.camera.height * 0.5);
				curCamPos = FlxTween.tween(FlxG.camera.scroll, {x: realTarget.x, y: realTarget.y}, Conductor.stepsToTime(duration)/1000, {ease: Reflect.field(FlxEase, ease), onComplete:
					function(e) {
						// uh
					}
				});
		}
	}

	var curCamZoom:FlxTween;
	function ZoomCamera(eventInfo:Dynamic):Void {
		var zoom:Float = eventInfo.zoom != null ? eventInfo.zoom : 1;
		var duration:Float = eventInfo.duration != null ? eventInfo.duration : 4;
		var ease:String = eventInfo.ease != null ? eventInfo.ease : 'linear';
		var mode:String = eventInfo.mode != null ? eventInfo.mode : 'direct';

		if (curCamZoom != null) curCamZoom.cancel();
		var daCamZom = switch(mode) {
			case 'stage':
				curStage.defaultZoom;
			default:
				1;
		}
		if (ease.toLowerCase() == 'instant' || duration <= 0) {
			FlxG.camera.zoom = zoom * daCamZom;
			defaultCamZoom = zoom * daCamZom;
		} else
			curCamZoom = FlxTween.tween(FlxG.camera, {zoom: zoom * daCamZom}, Conductor.stepsToTime(duration)/1000, {ease: Reflect.field(FlxEase, ease), onComplete: 
				function(e) {defaultCamZoom = zoom * daCamZom;}
			});
	}

	function SetCameraBop(eventInfo:Dynamic):Void {
		var rate:Int = eventInfo.rate != null ? eventInfo.rate : 4;
		var intensity:Float = eventInfo.intensity != null ? eventInfo.intensity : 1;

		if (rate != 0 && intensity != 0)
			setAllHaxeVar('camZooming', true);

		camZoomRate = rate;
		camZoomIntensity = intensity;
	}

	function tweenScrollSpeed(eventInfo:Dynamic) {
		var scroll:Float = eventInfo.scroll != null ? eventInfo.scroll : 1;
		var duration:Float = eventInfo.duration != null ? eventInfo.duration : 4;
		var ease:String = eventInfo.ease != null ? eventInfo.ease : 'linear';
		var absolute:Bool = eventInfo.absolute != null ? eventInfo.absolute : false;
		var strumline:String = eventInfo.strumline != null ? eventInfo.strumline : 'both';

		if (!absolute)
			scroll *= SONG.speed;

		if (ease.toLowerCase() == 'instant' || duration <= 0)
			daScrollSpeed = scroll;
		else
			FlxTween.tween(PlayState, {daScrollSpeed: scroll}, Conductor.stepsToTime(duration)/1000, {ease: Reflect.field(FlxEase, ease)});
	}

	function healthChange(healthVar:Float = -69, additive:Bool = false) {
		if (healthVar != -69) { //lol thats the funny number
			if (additive == true)
				health += healthVar;
			else
				health = healthVar;
		}
	}

	function switchCharacter(charTo:String, charState:String) { //the non sus version
		if (charState == 'bf' || charState == 'player1') charState = 'boyfriend';
		if (charState == 'opponent' || charState == 'player2') charState = 'dad';
		if (charState == 'girlfriend' || charState == 'player3') charState = 'gf';
	    switch(charState) {
			case 'boyfriend':
			    remove(boyfriend);
				boyfriend.destroy();
				boyfriend = new Character(swapOffsets[0], swapOffsets[1], charTo, true);
				if (!opponentPlayer && !demoMode)
					boyfriend.beingControlled = true;
				boyfriend.x += boyfriend.playerOffsetX;
				boyfriend.y += boyfriend.playerOffsetY;
				/*if (boyfriend.likeGf) {
					boyfriend.setPosition(gf.x, gf.y);
					gf.visible = false;
				} else if (!dad.likeGf) {
					gf.visible = true;
				}*/
				iconP1.switchAnim(charTo);
				iconRPC = charTo;

				// Layering nonsense
				if (dad.likeGf) {
					add(boyfriend);
				} else {
				    remove(dad);
				    add(boyfriend);
				    add(dad);
				}
				setAllHaxeVar("boyfriend", boyfriend);
				callAllHScript('onCharacterAdded', [boyfriend, charState]);
			case 'dad':
				remove(dad);
				dad.destroy();
				dad = new Character(swapOffsets[4], swapOffsets[5], charTo);
				if (duoMode || opponentPlayer || soloMode)
					dad.beingControlled = true;
				dad.x += dad.enemyOffsetX;
				dad.y += dad.enemyOffsetY;
				/*if (dad.likeGf) {
					dad.setPosition(gf.x, gf.y);
					gf.visible = false;
				} else if (!boyfriend.likeGf) {
					gf.visible = true;
				}*/
				iconP2.switchAnim(charTo);

				// Layering nonsense
				if (boyfriend.likeGf) {
				    add(dad);
				} else {
				    remove(boyfriend);
				    add(dad);
				    add(boyfriend);
				}
				setAllHaxeVar("dad", dad);
				callAllHScript('onCharacterAdded', [dad, charState]);
			case 'gf':
				remove(gf);
				gf.destroy();
				gf = new Character(swapOffsets[2], swapOffsets[3], charTo);
				gf.scrollFactor.set(0.95, 0.95);
				gf.x += gf.gfOffsetX;
				gf.y += gf.gfOffsetY;

				// Layering nonsense
				remove(boyfriend);
				remove(dad);
				add(gf);
				add(dad);
				add(boyfriend);
				setAllHaxeVar("gf", gf);
				callAllHScript('onCharacterAdded', [gf, charState]);
		}
		updateHealthColors();
	}

	function addCharacter(charTo:String = 'dad', charState:String = 'dad', ?stageName:String) {
		if (charState == 'bf' || charState == 'player1') charState = 'boyfriend';
		if (charState == 'opponent' || charState == 'player2') charState = 'dad';
		if (charState == 'girlfriend' || charState == 'player3') charState = 'gf';
		var flipChar = charState == 'boyfriend';
		var newChar = new Character(0, 0, charTo, flipChar);
		switch(charState) {
			case 'boyfriend':
			    newChar.setPosition(swapOffsets[0], swapOffsets[1]);
				newChar.x += newChar.playerOffsetX;
				newChar.y += newChar.playerOffsetY;
				if (newChar.likeGf) {
					newChar.setPosition(gf.x, gf.y);
					newChar.scrollFactor.set(0.95, 0.95);
				}
			case 'dad':
				newChar.setPosition(swapOffsets[4], swapOffsets[5]);
				newChar.x += newChar.enemyOffsetX;
				newChar.y += newChar.enemyOffsetY;
				if (newChar.likeGf) {
					newChar.setPosition(gf.x, gf.y);
					newChar.scrollFactor.set(0.95, 0.95);
				}
			case 'gf':
				newChar.setPosition(swapOffsets[2], swapOffsets[3]);
				newChar.x += newChar.gfOffsetX;
				newChar.y += newChar.gfOffsetY;
				newChar.scrollFactor.set(0.95, 0.95);
		}
		/*if (newChar.children.length > 0) {
			for (child in newChar.children) {
				add(child);
			}
		}*/
		callAllHScript('onCharacterAdded', [newChar, charState]);
		if (stageName != null) curStage.addElement(stageName, newChar);
		return newChar;
	}

	function switchToChar(daCharacter:Character, charState:String, destroy:Bool = false) {
		if ((daCharacter is String))
			daCharacter = curStage.getElement(cast daCharacter);
		if (daCharacter == null) return;
		
		if (charState == 'bf' || charState == 'player1') charState = 'boyfriend';
		if (charState == 'opponent' || charState == 'player2') charState = 'dad';
		if (charState == 'girlfriend' || charState == 'player3') charState = 'gf';
		switch(charState) {
			case 'boyfriend':
				remove(boyfriend);
				if (destroy) boyfriend.destroy();
				if (!opponentPlayer && !demoMode)
					daCharacter.beingControlled = true;
				boyfriend = daCharacter;
				iconP1.switchAnim(daCharacter.curCharacter);
				iconRPC = daCharacter.curCharacter;
				add(boyfriend);
			case 'dad':
				remove(dad);
				if (destroy) dad.destroy();
				if (duoMode || opponentPlayer || soloMode)
					daCharacter.beingControlled = true;
				dad = daCharacter;
				iconP2.switchAnim(daCharacter.curCharacter);
				add(dad);
			case 'gf':
				remove(gf);
				if (destroy) gf.destroy();
				gf = daCharacter;
				remove(boyfriend);
				remove(dad);
				add(gf);
				add(boyfriend);
				add(dad);
		}
		updateHealthColors();
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				vocals.pause();
			}
			controls.setKeyboardScheme(Solo(Note.NOTE_AMOUNT));
			#if windows
			var ae = FNFAssets.getText("assets/discord/presence/playpause.txt");
			DiscordClient.changePresence(ae
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC, null, null, playingAsRpc);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState() {
		if (paused) {
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();
			if (!opponentPlayer && !duoMode)
				controls.setKeyboardScheme(Solo(Note.NOTE_AMOUNT));
			if (duoMode)
				controls.setKeyboardScheme(Duo(true));
			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
			setAllHaxeVar("paused", paused);
			callAllHScript('onResume', []);

			CoolUtil.resumeTween(curCamPos);
			CoolUtil.resumeTween(curCamZoom);

			var currentIconState = "";
			if (opponentPlayer) {
				if (healthBar.percent > 80) {
					currentIconState = "Dying";
				} else {
					currentIconState = "Playing";
				}
				if (poisonTimes != 0) {
					currentIconState = "Being Posioned";
				}
			} else {
				if (healthBar.percent > 20) {
					currentIconState = "Dying";
				} else {
					currentIconState = "Playing";
				}
				if (poisonTimes != 0) {
					currentIconState = "Being Posioned";
				}
			}
			#if windows
			if (startTimer.finished) {
				DiscordClient.changePresence(customPrecence
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition, playingAsRpc);
			} else {
				DiscordClient.changePresence(customPrecence, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy), iconRPC,
					playingAsRpc);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void {
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
		
		#if windows
		DiscordClient.changePresence(customPrecence
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC,
			playingAsRpc);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float) {
		//setAllHaxeVar('camZooming', camZooming);
		//setAllHaxeVar('gfSpeed', gfSpeed);
		setAllHaxeVar('health', health);
		callAllHScript('update', [elapsed]);
		
		if (hscriptStates.exists("modchart")) {
			if (getHaxeVar("showOnlyStrums", "modchart")) {
				healthBarBG.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			} else {
				healthBarBG.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}
			camZooming = getHaxeVar("camZooming", "modchart");
			camSpeed = getHaxeVar("camSpeed", "modchart");
			gfSpeed = getHaxeVar("gfSpeed", "modchart");
			//health = getHaxeVar("health", "modchart");
		}

		FlxG.camera.follow(camFollow, LOCKON, camSpeed);
		
		var joe = notesHitArray.length-1;
		while (joe >= 0) {
			var mama:Date = notesHitArray[joe];
			if (mama != null && mama.getTime() + 1000 < Date.now().getTime())
				notesHitArray.remove(mama);
			else
				joe = 0;
			joe--;
		}
		nps = notesHitArray.length;
		setAllHaxeVar('nps', nps);

		super.update(elapsed);
		if (snapToStrumline) {
			notes.forEachAlive(function(daNote) {
				var noteData = daNote.noteData;
				if (daNote.mustPress)
					noteData += Note.NOTE_AMOUNT; 
				daNote.x = strumLineNotes.members[noteData].x;
				if (daNote.isSustainNote) {
					daNote.scale.x = strumLineNotes.members[noteData].scale.x;
					if (daNote.prevNote.alive && daNote.prevNote.isSustainNote) {
						if (daNote.prevNote.isPixel)
							daNote.prevNote.scale.y = daPixelZoom * (initialStepCrochet / 100 * 1.5 * daScrollSpeed);
						else
							daNote.prevNote.scale.y = 0.7 * (initialStepCrochet / 100 * 1.5 * daScrollSpeed);
					}
					daNote.updateHitbox();
					daNote.x += defaultNoteWidth / 2 - daNote.width / 2;
				} else {
					daNote.angle = strumLineNotes.members[noteData].angle;
					daNote.scale.x = strumLineNotes.members[noteData].scale.x;
					daNote.scale.y = strumLineNotes.members[noteData].scale.y;
				}
			});
			for (i in 0...playerStrums.members.length)  {
				playerComboBreak.members[i].x = playerStrums.members[i].x;
			}
			for (i in 0...enemyStrums.members.length) {
				enemyComboBreak.members[i].x = enemyStrums.members[i].x;
			}
		}
		var properHealth = opponentPlayer ? 100 - Math.round(health*50) : Math.round(health*50);
		healthTxt.text = "Health:" + properHealth + "%";
		/*
		switch (OptionsHandler.options.accuracyMode) {
			case Simple | Binary | Complex: 
				if (notesPassing != 0)
					accuracy = HelperFunctions.truncateFloat((notesHit / notesPassing) * 100, 2);
				else
					accuracy = 100;
			case None:
				accuracy = 0;
		}*/
		if (disableScoreChange == false)
			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, accuracy);

		if ((perfectMode && !Ratings.CalculateFullCombo(Sick)) ||
			(goodCombo && !Ratings.CalculateFullCombo(Good)) ||
			(fullComboMode && !Ratings.CalculateFullCombo(Bad))) {
			if (opponentPlayer)
				health = 50;
			else
				health = -50;
		}
		accuracyTxt.text = "Accuracy:" + accuracy + "%";
		if (controls.SYNC_VOCALS)
			resyncVocals();
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			setAllHaxeVar("paused", paused);
			callAllHScript('onPause', []);

			CoolUtil.pauseTween(curCamPos);
			CoolUtil.pauseTween(curCamZoom);

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camHUD));
		}

		var canShowKeys = true;
		if (FlxG.keys.justPressed.TAB && canShowKeys && !demoMode && startedCountdown) {
			canShowKeys = false;
			showKeys();
			new FlxTimer().start(6, function(tmr) {
				canShowKeys = true;
			});
		}

		if (FlxG.keys.justPressed.SEVEN && !OptionsHandler.options.danceMode) {
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			LoadingState.loadAndSwitchState(new ChartingState());
		}/* else if (FlxG.keys.justPressed.SIX && !OptionsHandler.options.danceMode) {
		#if windows
			DiscordClient.changePresence("Inside Your Home", null, null, true);
			#end
			LoadingState.loadAndSwitchState(new DialogueEditState());
		}*/
		if (FlxG.keys.justPressed.NINE) {
			oldMode = !oldMode;
			if (oldMode)
				iconP1.switchAnim(boyfriend.curCharacter + "-old");
			else
				iconP1.switchAnim(boyfriend.curCharacter);
		}
		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		//iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		//iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));
		//practiceDieIcon.setGraphicSize(Std.int(FlxMath.lerp(150, practiceDieIcon.width, 0.50)));
		//iconP1.updateHitbox();
		//iconP2.updateHitbox();
		//practiceDieIcon.updateHitbox();

		var iconOffset:Int = 26;
		
		if (poisonTimes > 0 && !barShowingPoison) {
			updateHealthColors(true);
			barShowingPoison = true;
		} else if (poisonTimes == 0 && barShowingPoison) {
			updateHealthColors();
			barShowingPoison = false;
		}

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		player1Icon = boyfriend.curCharacter;
		switch(boyfriend.curCharacter) {
			case "bf-car" | "bf-christmas" | "bf-holding-gf":
				player1Icon = "bf";
			case "monster-christmas":
				player1Icon = "monster";
			case "mom-car":
				player1Icon = "mom";
			case "pico-speaker" | "pico-christmas" | "pico-holding-nene":
				player1Icon = "pico";
			case "gf-car" | "gf-christmas" | "gf-pixel" | "gf-tankman":
				player1Icon = "gf";
		}
		if (healthBar.percent < 20) {
			iconP1.iconState = Dying;
			iconP2.iconState = Winning;
			#if windows
			iconRPC = player1Icon + "-dead";
			#end
		} else {
			iconP1.iconState = Normal;
			#if windows
			iconRPC = player1Icon;
			#end
		}
		if (!opponentPlayer && poisonTimes != 0) {
			iconP1.iconState = Poisoned;
			#if windows
			iconRPC = player1Icon + "-dazed";
			#end
		}	
		
		// duo mode shouldn't show low health
		if (properHealth < 20 && !duoMode) {
			healthTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.RED, RIGHT, OUTLINE, FlxColor.BLACK);
		} else {
			healthTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		}	
		player2Icon = dad.curCharacter;
		switch (dad.curCharacter) {
			case "bf-car" | "bf-christmas" | "bf-holding-gf":
				player1Icon = "bf";
			case "monster-christmas":
				player1Icon = "monster";
			case "mom-car":
				player1Icon = "mom";
			case "pico-speaker" | "pico-christmas" | "pico-holding-nene":
				player1Icon = "pico";
			case "gf-car" | "gf-christmas" | "gf-pixel" | "gf-tankman":
				player1Icon = "gf";
		}

		if (healthBar.percent > 80) {
			iconP2.iconState = Dying;
			if (iconP1.iconState != Poisoned) {
				iconP1.iconState = Winning;
			}
			#if windows
			if (opponentPlayer)
				iconRPC = player2Icon + "-dead";
			#end
		} else {
			iconP2.iconState = Normal;
			#if windows
			if (opponentPlayer)
				iconRPC = player2Icon;
			#end
		}
		if (healthBar.percent < 20) {
			iconP2.iconState = Winning;
		}
		if (poisonTimes != 0 && opponentPlayer) {
			iconP2.iconState = Poisoned;
			#if windows
			if (opponentPlayer)
				iconRPC = player2Icon + "-dazed";
			#end
		}

		if (FlxG.keys.justPressed.EIGHT && !OptionsHandler.options.danceMode) // stop checking for debug so i can fix my offsets!
			LoadingState.loadAndSwitchState(new AnimationDebug(SONG.player2, SONG.player1, SONG.gf));
		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		} else {
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			songLength = getUV('songLength');
			songPositionBar = Conductor.songPosition / songLength;
			if (!paused) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition) {
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camNotes) {
			if (dad.camOffsets.exists(dad.animation.curAnim.name)) {
				var daCam = dad.camOffsets.get(dad.animation.curAnim.name);
				dadcam = [daCam[0], daCam[1]];
			} else {
				var dadAnim = dad.animation.curAnim.name.split('-');
				switch(dadAnim[0]) {
					case 'singLEFT':
						dadcam = [-25, 0];
					case 'singRIGHT':
						dadcam = [25, 0];
					case 'singUP':
						dadcam = [0, -25];
					case 'singDOWN':
						dadcam = [0, 25];
					default:
						dadcam = [0, 0];
				}
			}

			if (boyfriend.camOffsets.exists(boyfriend.animation.curAnim.name)) {
				var daCam = boyfriend.camOffsets.get(boyfriend.animation.curAnim.name);
				bfcam = [daCam[0], daCam[1]];
			} else {
				var boyfriendAnim = boyfriend.animation.curAnim.name.split('-');
				switch(boyfriendAnim[0]) {
					case 'singLEFT':
						bfcam = [-25, 0];
					case 'singRIGHT':
						bfcam = [25, 0];
					case 'singUP':
						bfcam = [0, -25];
					case 'singDOWN':
						bfcam = [0, 25];
					default:
						bfcam = [0, 0];
				}
			}
		}

		if (endingSong)
			return;
		if (generatedMusic && PlayState.SONG.notes[curSection] != null) {
			setAllHaxeVar("mustHit", PlayState.SONG.notes[curSection].mustHitSection);
			switch(scriptableCamera) {
				case 'static':
					camFollow.setPosition(scriptCamPos[0][0], scriptCamPos[0][1]);
				case 'bf':
					camFollow.setPosition(boyfriend.getMidpoint().x + bfCamOffset[0] + boyfriend.followCamX + bfcam[0] + scriptCamPos[0][0], boyfriend.getMidpoint().y + bfCamOffset[1] + boyfriend.followCamY + bfcam[1] + scriptCamPos[0][1]);
				case 'dad':
					camFollow.setPosition(dad.getMidpoint().x + dadCamOffset[0] + dad.followCamX + dadcam[0]  + scriptCamPos[0][0], dad.getMidpoint().y + dadCamOffset[1] + dad.followCamY + dadcam[1] + scriptCamPos[0][1]);
				case 'gf':
					camFollow.setPosition(gf.getMidpoint().x + gf.followCamX + scriptCamPos[0][0], gf.getMidpoint().y + gf.followCamY + scriptCamPos[0][1]);
				default:
					if (PlayState.SONG.notes[curSection].mustHitSection)
						camFollow.setPosition(boyfriend.getMidpoint().x + bfCamOffset[0] + boyfriend.followCamX + bfcam[0], boyfriend.getMidpoint().y + bfCamOffset[1] + boyfriend.followCamY + bfcam[1]);
					else
						camFollow.setPosition(dad.getMidpoint().x + dadCamOffset[0] + dad.followCamX + dadcam[0], dad.getMidpoint().y + dadCamOffset[1] + dad.followCamY + dadcam[1]);
			}
			if (PlayState.SONG.notes[curSection].mustHitSection) {
				callAllHScript("playerOneTurn", []);
			} else {
				callAllHScript("playerTwoTurn", []);
				vocals.volume = 1;
			}
			var currentIconState = "";
			if (opponentPlayer) {
				if (healthBar.percent > 80)
					currentIconState = "Dying";
				else
					currentIconState = "Playing";

				if (poisonTimes != 0)
					currentIconState = "Being Poisoned";
			} else {
				if (healthBar.percent < 20)
					currentIconState = "Dying";
				else
					currentIconState = "Playing";

				if (poisonTimes != 0)
					currentIconState = "Being Poisoned";
			}
			if (supLove)
				health += loveMultiplier * (opponentPlayer ? -1 : 1) / 600000;

			if (poisonExr)
				health -= poisonMultiplier * (opponentPlayer ? -1 : 1)/ 700000;

			playingAsRpc = "Playing as " + (opponentPlayer ? player2Icon : player1Icon) + " | " + currentIconState;
		}

		if (camZooming) {
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET && !duoMode) {
			if (opponentPlayer)
				health = 2;
			else
				health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT) {
			health += 1;
			trace("User is cheating!");
		}

		if (((health <= 0 && !opponentPlayer) || (health >= 2 && opponentPlayer)) && !practiceMode && !duoMode) {
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;
			setAllHaxeVar("paused", paused);

			vocals.stop();
			FlxG.sound.music.stop();
			
			if (inALoop) {
				FlxG.resetState();
			} else {
				// 1 / 1000 chance for Gitaroo Man easter egg
				if (FlxG.random.bool(0.1)) {
					// gitaroo man easter egg
					LoadingState.loadAndSwitchState(new GitarooPause());
				} else
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, getHaxeActor("bf")));
				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, null, null,
					playingAsRpc);
				#end

			}

			
			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
		else if (((health <= 0 && !opponentPlayer) || (health >= 2 && opponentPlayer)) && !practiceDied && practiceMode) {
			practiceDied = true;
			practiceDieIcon.visible = true;
		}
		health = FlxMath.bound(health,0,2);
		if (unspawnNotes[0] != null) {
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500) {
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				callAllHScript("noteLoaded", [dunceNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if (daNote.y > FlxG.height) {
					daNote.active = false;
					daNote.visible = false;
				} else {
					daNote.visible = !invsNotes;
					daNote.active = true;
				}
				var coolMustPress = daNote.mustPress;
				if (duoMode)
					coolMustPress = true;
				if (opponentPlayer)
					coolMustPress = !daNote.mustPress;

				var daNoteStrums = daNote.mustPress ? playerStrums : enemyStrums;
							
				if (downscroll) {
					daNote.y = (daNoteStrums.members[Math.floor(Math.abs(daNote.noteData))].y
						+
						0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? daScrollSpeed : FlxG.save.data.scrollSpeed,
							2));

					if (daNote.isSustainNote) {
						// Remember = minus makes notes go up, plus makes them go down
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;
							
						if ((daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
							&& (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height) >= (daNoteStrums.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2)
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							// Clip to strumline
							// upon further inspection, this is purely visual :hueh:
							var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
							swagRect.height = (daNoteStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+ Note.swagWidth / 2
								- daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = (daNoteStrums.members[Math.floor(Math.abs(daNote.noteData))].y
						- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? daScrollSpeed : FlxG.save.data.scrollSpeed,
							2));
					if (daNote.isSustainNote) {
						daNote.y -= daNote.height / 2;

						if ((daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
							&& daNote.y + daNote.offset.y * daNote.scale.y <= (daNoteStrums.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2)
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							// Clip to strumline
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (daNoteStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+ Note.swagWidth / 2
								- daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}
					/*
					if (downscroll) {
						daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(daScrollSpeed, 2)));
					} else {
						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(daScrollSpeed, 2)));
					}
					

					// i am so fucking sorry for this if condition
					if (daNote.isSustainNote
						&& (((daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2) && !downscroll)
						|| (downscroll && (daNote.y + daNote.offset.y >= strumLine.y + Note.swagWidth / 2)))
						&& (((!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) && !opponentPlayer && !duoMode)
						|| ((daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) && opponentPlayer)))
					{
						var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
						swagRect.y /= daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}*/
				
				

				if (!daNote.mustPress && daNote.wasGoodHit && ((!duoMode && !opponentPlayer) || demoMode)) {
					camZooming = true;
					dad.altAnim = "";
					dad.altNum = 0;
					if (daNote.altNote) {
						dad.altAnim = '-alt';
						dad.altNum = 1;
					}
					dad.altNum = daNote.altNum;
					if (SONG.notes[curSection] != null) {
						if ((SONG.notes[curSection].altAnimNum > 0 && SONG.notes[curSection].altAnimNum != null) || SONG.notes[curSection].altAnim)
							// backwards compatibility shit
							if (SONG.notes[curSection].altAnimNum == 1 || SONG.notes[curSection].altAnim || daNote.altNote)
								dad.altNum = 1;
							else if (SONG.notes[curSection].altAnimNum != 0)
								dad.altNum = SONG.notes[curSection].altAnimNum;
					}
					
					if (dad.altNum == 1)
						dad.altAnim = '-alt';
					else if (dad.altNum > 1)
						dad.altAnim = '-alt' + dad.altNum;
					callAllHScript("playerTwoSing", []);
					// go wild <3
					if (daNote.shouldBeSung) {
						var singAnim = currrentKey[Std.int(Math.abs(daNote.noteData % Note.NOTE_AMOUNT))].sing;
						var singNum = -1;
						switch(singAnim) {
							case 'singLEFT':
								singNum = 0;
							case 'singDOWN':
								singNum = 1;
							case 'singUP':
								singNum = 2;
							case 'singRIGHT':
								singNum = 3;
						}

						if (singNum == -1)
							dad.playAnim(singAnim, true);
						else
							dad.sing(singNum, false, daNote.altNum);

						enemyStrums.forEach(function(spr:FlxSprite) {
							if (Math.abs(daNote.noteData) == spr.ID) {
								spr.animation.play('confirm', true);
								sustain2(spr.ID, spr, daNote);
							}
						});
						if (daNote.oppntSing != null)
							boyfriend.sing(daNote.oppntSing.direction, daNote.oppntSing.miss, daNote.oppntSing.alt);

						dad.holdTimer = 0;
					}

					if (daNote.noteHit != null)
						callHscript(daNote.noteHit, [daNote], "modchart");

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				} else if (daNote.mustPress && daNote.wasGoodHit && (opponentPlayer || demoMode)) {
					camZooming = true;
					callAllHScript("playerOneSing", []);
					if (daNote.shouldBeSung) {
						var singAnim = currrentKey[Std.int(Math.abs(daNote.noteData % Note.NOTE_AMOUNT))].sing;
						var singNum = -1;
						switch(singAnim) {
							case 'singLEFT':
								singNum = 0;
							case 'singDOWN':
								singNum = 1;
							case 'singUP':
								singNum = 2;
							case 'singRIGHT':
								singNum = 3;
						}

						if (singNum == -1)
							boyfriend.playAnim(singAnim, true);
						else
							boyfriend.sing(singNum, false, daNote.altNum);

						playerStrums.forEach(function(spr:FlxSprite) {
							if (Math.abs(daNote.noteData) == spr.ID) {
								spr.animation.play('confirm', true);
								sustain2(spr.ID, spr, daNote);
							}
						});
						if (daNote.oppntSing != null) {
							dad.sing(Std.int(Math.abs(daNote.oppntSing.direction % 4)), daNote.oppntSing.miss, daNote.oppntSing.alt);
							// don't strum it because there isn't actually a note
						}

						boyfriend.holdTimer = 0;
					}

					if (daNote.noteHit != null)
						callHscript(daNote.noteHit, [daNote], "modchart");

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				var neg = downscroll ? -1 : 1;
				if (drunkNotes) {
					daNote.y = (daNoteStrums.members[Math.floor(Math.abs(daNote.noteData))].y - neg * (Conductor.songPosition - daNote.strumTime) * ((Math.sin(songTime/400)/6)+0.5) * noteSpeed * FlxMath.roundDecimal(daScrollSpeed, 2));
				} else {
					daNote.y = (daNoteStrums.members[Math.floor(Math.abs(daNote.noteData))].y - neg * (Conductor.songPosition - daNote.strumTime) * (noteSpeed * FlxMath.roundDecimal(daScrollSpeed, 2)));
				}
				if (vnshNotes)
					daNote.alpha = FlxMath.remapToRange(neg*daNote.y, neg*daNoteStrums.members[Math.floor(Math.abs(daNote.noteData))].y, FlxG.height, 0, 1);
					
				if (snakeNotes) {
					if (daNote.mustPress) {
						daNote.x = (FlxG.width/2)+snekNumber+(Note.swagWidth*daNote.noteData)+50;
					} else {
						daNote.x = snekNumber+(Note.swagWidth*daNote.noteData)+50;
					}
				}
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				// this is not work well >:(
				if ((daNote.y >= getHaxeActor('0').y - 20 && daNote.y <= getHaxeActor('0').y + 20) && daNote.noteStrum != null) {
					callHscript(daNote.noteStrum, [], "modchart");
					daNote.noteStrum = null;
				}

				if (((daNote.y < -daNote.height && !downscroll) || (daNote.y > FlxG.height + daNote.height && downscroll)) && !daNote.dontCountNote) {

						if ((daNote.tooLate || !daNote.wasGoodHit) /* && !daNote.isSustainNote */) {
							// always show the graphic
							noteMiss(daNote.noteData, daNote.mustPress, daNote, false);
							//popUpScore(Conductor.songPosition, daNote, daNote.mustPress, true);
							if (!OptionsHandler.options.dontMuteMiss)
								vocals.volume = 0;
							if (poisonPlus && poisonTimes < 3) {
								poisonTimes += 1;
								var poisonPlusTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									if (opponentPlayer)
										health += 0.04;
									else
										health -= 0.04;
								}, 0);
								// stop timer after 3 seconds
								new FlxTimer().start(3, function(tmr:FlxTimer) {
									poisonPlusTimer.cancel();
									poisonTimes -= 1;
								});
							}
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
				}
				if ((!duoMode && !opponentPlayer) || demoMode) {
					enemyStrums.forEach(function(spr:FlxSprite) {
						if (strumming2[spr.ID]) {
							spr.animation.play("confirm", true);
						}

						if (spr.animation.curAnim != null && spr.animation.curAnim.name == 'confirm' && !pixelUI) {
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						} else
							spr.centerOffsets();
					});
				} 
				if (opponentPlayer || demoMode) {
					playerStrums.forEach(function(spr:FlxSprite) {
						if (strumming1[spr.ID]) {
							spr.animation.play("confirm", true);
						}

						if (spr.animation.curAnim != null && spr.animation.curAnim.name == 'confirm' && !pixelUI) {
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						} else
							spr.centerOffsets();
					});
				}
				
			});
		}

		if (!inCutscene && !demoMode) {
			// is that why it was crashing
			if (!opponentPlayer)
				keyShit(true);
			if (duoMode || opponentPlayer)
				keyShit(false);
		}
			

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}
	function sustain2(strum:Int, spr:FlxSprite, note:Note):Void {
		var length:Float = note.sustainLength;
		/*if (length > 0)
		{
			if (opponentPlayer)
				strumming1[strum] = true;
			else
				strumming2[strum] = true;
		}*/

		var bps:Float = Conductor.bpm / 60;
		var spb:Float = 1 / bps;

		if (!note.isSustainNote) {
			new FlxTimer().start(length == 0 ? 0.2 : (length / Conductor.crochet * spb) + 0.1, function(tmr:FlxTimer) {
				if (spr.animation.curAnim.finished) {
					spr.animation.play('static', true);
				} else {
					tmr.reset(0.1);
				}

				/*if (opponentPlayer) {
					if (!strumming1[strum])
					{
						spr.animation.play("static", true);
					}
					else if (length > 0)
					{
						strumming1[strum] = false;
						spr.animation.play("static", true);
					}
				} else {
					if (!strumming2[strum])
					{
						spr.animation.play("static", true);
					}
					else if (length > 0)
					{
						strumming2[strum] = false;
						spr.animation.play("static", true);
					}
				}*/
			});
		}
	}
	function endSong():Void {
		endingSong = true;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		trace(vocals.getActualVolume());
		var dialogSuffix = "-end";
		if (OptionsHandler.options.stressTankmen) {
			dialogSuffix += "-shit";
		}
		// if this is skipped when love is on, that means love is less than or equal to fright so
		else if (supLove && poisonMultiplier < loveMultiplier) {
			dialogSuffix += "-love";
		} else if (poisonExr && poisonMultiplier < 50) {
			dialogSuffix += "-uneasy";
		} else if (poisonExr && poisonMultiplier >= 50 && poisonMultiplier < 100) {
			dialogSuffix += "-scared";
		} else if (poisonExr && poisonMultiplier >= 100 && poisonMultiplier < 200) {
			dialogSuffix += "-terrified";
		} else if (poisonExr && poisonMultiplier >= 200) {
			dialogSuffix += "-depressed";
		} else if (practiceMode) {
			dialogSuffix += "-practice";
		} else if (perfectMode || fullComboMode || goodCombo) {
			dialogSuffix += "-perfect";
		}
		var filename:Null<String> = null;
		if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog-end.txt')) {	
			filename = 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog-end.txt';
			if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog'+dialogSuffix+'.txt'))
				filename = 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog' + dialogSuffix + '.txt';
		} else if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog-end.txt')) {
			filename = 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog-end.txt';
			if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt')) {
				filename = 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt';
			}
			// if no player dialog, use default
		} else if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialog-end.txt')) {
			filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialog-end.txt';
			if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt')) {
				filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt';
			}
		} else if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialogue-end.txt')) {
			filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialogue-end.txt';
			if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt')) {
				filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt';
			}
		}
		var goodDialog:String;
		if (filename != null) {
			goodDialog = FNFAssets.getText(filename);
		} else {
			goodDialog = ':dad: The game tried to get a dialog file but couldn\'t find it. Please make sure there is a dialog file named "dialog.txt".';
		}
		// never play it if the file doesn't exist
		if ((OptionsHandler.options.alwaysDoCutscenes || isStoryMode) && filename != null) {
			doof = new DialogueBox(false, goodDialog);
			doof.scrollFactor.set();
			doof.finishThing = endForReal;

			doof.cameras = [camHUD];
			schoolIntro(doof, false);
		} else {
			endForReal();
		}
		
	}
	function endForReal() {
		#if !switch
		if (!demoMode && ModifierState.scoreMultiplier > 0)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, accuracy / 100, Ratings.CalculateFCRating(), OptionsHandler.options.judge);
		#end
		controls.setKeyboardScheme(Solo(Note.NOTE_AMOUNT));
		if (isStoryMode) {
			campaignScore += songScore;
			campaignScoreDef += songScoreDef;
			campaignAccuracy += accuracy;
			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0) {
				if (!demoMode && ModifierState.scoreMultiplier > 0)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty, campaignAccuracy / defaultPlaylistLength);
				campaignAccuracy = campaignAccuracy / defaultPlaylistLength;
				if (useVictoryScreen) {
					#if windows
					DiscordClient.changePresence("Reviewing Score -- "
						+ SONG.song
						+ " ("
						+ storyDifficultyText
						+ ") "
						+ Ratings.GenerateLetterRank(accuracy),
						"\nAcc: "
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "% | Score: "
						+ songScore
						+ " | Misses: "
						+ misses, iconRPC, playingAsRpc);
					#end
					LoadingState.loadAndSwitchState(new VictoryLoopState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y,
						gf.getScreenPosition().x, gf.getScreenPosition().y, campaignAccuracy, campaignScore, dad.getScreenPosition().x,
						dad.getScreenPosition().y));
				} else {
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;
					LoadingState.loadAndSwitchState(new StoryMenuState());
				}
				FlxG.save.flush();
			} else {
				var difficulty:String = "";

				difficulty = DifficultyIcons.getEndingFP(storyDifficulty);
				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog') {
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play('assets/sounds/Lights_Shut_off' + TitleState.soundExt);
				}

				if (SONG.song.toLowerCase() == 'senpai') {
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;
				}
				if (FNFAssets.exists('assets/data/'
					+ PlayState.storyPlaylist[0].toLowerCase() + '/' + PlayState.storyPlaylist[0].toLowerCase() + difficulty + '.json'))
					// do this to make custom difficulties not as unstable
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				else
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		} else {
			trace('WENT BACK TO FREEPLAY??');
			if (useVictoryScreen) {
				#if windows
				DiscordClient.changePresence("Reviewing Score -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, playingAsRpc);
				#end
				LoadingState.loadAndSwitchState(new VictoryLoopState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y,
					gf.getScreenPosition().x, gf.getScreenPosition().y, accuracy, songScore, dad.getScreenPosition().x, dad.getScreenPosition().y));
			} else
				LoadingState.loadAndSwitchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;
	var timeShown:Int = 0;
	private function popUpScore(strumtime:Float, daNote:Note, playerOne:Bool, forceMiss:Bool = false):Void {
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
		var noteDiffSigned:Float = Conductor.songPosition - daNote.strumTime;
		var wife:Float = HelperFunctions.wife3(noteDiffSigned, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		camZooming = true;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		
		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";
		if (daNote.mineNote)
			// make note diff sussy and harder to hit because mine notes are weird champ
			noteDiff *= 1.9;
		if (daNote.nukeNote)
			noteDiff *= 3;
		daNote.rating = Ratings.CalculateRating(noteDiff);
		daRating = daNote.rating;
		trace(daRating);
		var healthBonus = 0.0;
		// you can't really control how you hit sustains so always make em sick
		if (daNote.isSustainNote)
			daRating = 'sick';
		if (forceMiss)
			daRating = 'miss';
		if (OptionsHandler.options.accuracyMode == Complex)
			totalNotesHit += wife;
		
		// SHIT IS A COMBO BREAKER IN ETTERNA NERDS
		// GIT GUD
		var dontCountNote = daNote.dontCountNote;
		if (!daNote.mineNote) {
			switch (daRating) {
				case 'shit':
					if (!dontCountNote) {
						ss = false;
						shits++;
						
						if (OptionsHandler.options.accuracyMode == Simple) {
							totalNotesHit -= 1;
						} 
						misses++;
						setAllHaxeVar("misses", misses);
						score = -300;
						combo = 0;
						setAllHaxeVar("combo", combo);
					}

					// healthBonus -= 0.06 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;

				case 'wayoff':
					if (!dontCountNote) {
						score = -300;
						combo = 0;
						setAllHaxeVar("combo", combo);
						misses++;
						setAllHaxeVar("misses", misses);
						ss = false;
						shits++;
						if (OptionsHandler.options.accuracyMode == Simple) {
							totalNotesHit -= 1;
						}
					}

					// healthBonus -= 0.06 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;

				case 'bad':
					if (!dontCountNote) {
						score = 0;
						ss = false;
						bads++;
						if (OptionsHandler.options.accuracyMode == Simple) {
							totalNotesHit += 0.50;
						} else if (OptionsHandler.options.accuracyMode == Binary) {
							totalNotesHit += 1;
						}
					}
					daRating = 'bad';

					// healthBonus -= 0.03 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;

				case 'good':
					if (!dontCountNote) {
						score = 200;
						ss = false;
						goods++;
						if (OptionsHandler.options.accuracyMode == Simple) {
							totalNotesHit += 0.75;
						} else if (OptionsHandler.options.accuracyMode == Binary) {
							totalNotesHit += 1;
						}
					}
					daRating = 'good';

					// healthBonus += 0.03 * if (daNote.ignoreHealthMods) 1 else healthGainMultiplier * daNote.healMultiplier;

				case 'sick':
					// healthBonus += 0.07 * if (daNote.ignoreHealthMods) 1 else healthGainMultiplier * daNote.healMultiplier;
					if (!dontCountNote) {
						// if it be binary or not
						// it shall be a 1
						if (OptionsHandler.options.accuracyMode == Simple) {
							totalNotesHit += 1;
						} else if (OptionsHandler.options.accuracyMode == Binary) {
							totalNotesHit += 1;
						}
						sicks++;
					}

					if (!daNote.isSustainNote && useNoteSplashes) {
						var recycledNote = grpNoteSplashes.recycle(NoteSplash);
						recycledNote.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
						grpNoteSplashes.add(recycledNote);
					}

				case 'miss':
					// noteMiss(daNote.noteData, playerOne);
					// healthBonus = -0.04 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;
					if (!dontCountNote) {
						misses++;
						setAllHaxeVar("misses", misses);
						if (OptionsHandler.options.accuracyMode == Simple) {
							totalNotesHit -= 1;
						}
						ss = false;
						score = -5;
					}
			}
		}
		if (daNote.nukeNote && daRating != 'miss')
			// die <3
			healthBonus = -4;
		healthBonus = daNote.getHealth(daRating);
		if (daNote.dontEdit)
			trace(healthBonus);
		if (daNote.isSustainNote) {
			healthBonus  *= 0.2;
		}
		if (!playerOne)
			health -= healthBonus;
		else
			health += healthBonus;
		updateAccuracy();
		if (daNote.isSustainNote)
			return;
		if (notesHit > notesPassing)
			notesHit = notesPassing;
		if (!dontCountNote) {
			songScore += Math.round(ConvertScore.convertScore(noteDiff) * ModifierState.scoreMultiplier);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
			trueScore += Math.round(ConvertScore.convertScore(noteDiff));
		}
		comboBreak(daNote.noteData % 4, playerOne, daRating);

		setAllHaxeVar('songScore', songScore);
		setAllHaxeVar('songScoreDef', songScoreDef);

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */
		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';
		if (uiSmelly.isPixel) {
			pixelShitPart2 = '-pixel';
		}
		/*var ratingImage:BitmapData;
		ratingImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/' + daRating + pixelShitPart2 + ".png");
		trace(pixelUI);*/
		rating = new Judgement(0, 0, daRating, preferredJudgement,
			noteDiffSigned < 0, pixelUI);
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		if (OptionsHandler.options.newJudgementPos) {
			rating.cameras = [camHUD];
			rating.y = 15;
			rating.x = 0;
			if (!downscroll) {
				rating.y = FlxG.height - rating.height;
			}
		}
		if (showRatings)
			add(rating);
		rating.setGraphicSize(Std.int(rating.width * 0.7));

		/*var comboSpr:FlxSprite = new FlxSprite().loadGraphic(ratingImage);
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);*/

		var msTiming = HelperFunctions.truncateFloat(noteDiffSigned, 3);
		if (FlxG.save.data.botplay)
			msTiming = 0;
		timeShown = 0;
		if (currentTimingShown != null)
			remove(currentTimingShown);

		currentTimingShown = new FlxText(0, 0, 0, "0ms");
		switch (daRating) {
			case 'miss':
				currentTimingShown.color = FlxColor.MAGENTA;
			case 'shit' | 'bad' | 'wayoff':
				currentTimingShown.color = FlxColor.RED;
			case 'good':
				currentTimingShown.color = FlxColor.GREEN;
			case 'sick':
				currentTimingShown.color = FlxColor.CYAN;
		}
		currentTimingShown.borderStyle = OUTLINE;
		currentTimingShown.borderSize = 1;
		currentTimingShown.borderColor = FlxColor.BLACK;
		currentTimingShown.text = msTiming + "ms";
		currentTimingShown.size = 20;


		if (currentTimingShown.alpha != 1)
			currentTimingShown.alpha = 1;

		if (!demoMode && useTimings)
			add(currentTimingShown);
		//comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<String> = [];

		var stringCombo = Std.string(combo);
		for (i in 0...stringCombo.length) {
			seperatedScore.push(stringCombo.charAt(i));
		}

		/*seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);*/
		// talk about overcomplicated

		currentTimingShown.screenCenter();
		currentTimingShown.x = rating.x + 100;
		currentTimingShown.y = rating.y + 100;
		currentTimingShown.acceleration.y = 600;
		currentTimingShown.velocity.y -= 150;
		var daLoop:Int = 0;
		for (numBer in seperatedScore) {
			var numImage:BitmapData;
			if (FNFAssets.exists('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/num' + numBer + pixelShitPart2 + ".png"))
				numImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/num' + numBer + pixelShitPart2 + ".png");
			else if (uiSmelly.isPixel)
				numImage = FNFAssets.getBitmapData('assets/images/weeb/pixelUI/num' + numBer + '-pixel.png');
			else
				numImage = FNFAssets.getBitmapData('assets/images/num' + numBer + '.png');
			var numScore:FlxSprite = new FlxSprite().loadGraphic(numImage);
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!pixelUI) {
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			} else {
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (OptionsHandler.options.newJudgementPos) {
				numScore.cameras = [camHUD];
				numScore.y = 95;
				numScore.x = (43 * daLoop) + 150;
				if (!downscroll) {
					numScore.y = FlxG.height - numScore.height;
				}
			}

			if ((combo >= 10 || combo == 0) && showRatings)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		currentTimingShown.cameras = [camHUD];
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
			onUpdate: function(tween:FlxTween) {
				if (currentTimingShown != null)
					currentTimingShown.alpha -= 0.02;
				timeShown++;
			},
			onComplete: function(tween:FlxTween) {
				coolText.destroy();
				rating.destroy();
				if (currentTimingShown != null && timeShown >= 20) {
					remove(currentTimingShown);
					currentTimingShown = null;
				}
			}
		});

		/*FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween) {
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
				if (currentTimingShown != null && timeShown >= 20) {
					remove(currentTimingShown);
					currentTimingShown = null;
				}
			},
			startDelay: Conductor.crochet * 0.001
		});*/

		if (daNote.nukeNote && daRating != 'miss') {
			if (!playerOne)
				health = 69;
			else
				health = -69;
		}
	}
	function updateAccuracy() {
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		setAllHaxeVar('accuracy', accuracy);
	}
	function updateHealthColors(poison:Bool = false) {
		var leftSideFill = dad.enemyColor;
		var rightSideFill = boyfriend.bfColor;
		if (OptionsHandler.options.useCharColor) {
			leftSideFill = iconP2.healthColors[0];
			rightSideFill = iconP1.healthColors[0];
			if (poison) {
				if (opponentPlayer)
					leftSideFill = dad.poisonColorEnemy;
				else
					rightSideFill = boyfriend.poisonColor;
			}
		} else {
			if (duoMode || opponentPlayer) {
				leftSideFill = dad.opponentColor;
				rightSideFill = boyfriend.bfColor;
			} else {
				leftSideFill = dad.enemyColor;
				rightSideFill = boyfriend.playerColor;
			}

			if (poison) {
				if (opponentPlayer)
					leftSideFill = dad.poisonColorEnemy;
				else
					rightSideFill = boyfriend.poisonColor;
			}
		}
		healthBar.createFilledBar(leftSideFill, rightSideFill);
		healthBar.updateBar();
	}
	public function getKeyNames(duo:Bool = false, ?first:Bool = true) {
		var coolControls = controls;
		var deKeys:Array<Array<String>> = [];
		var alldeKeys;
		if (duo)
			alldeKeys = Controls.getDeCtrls(Duo(first));
		else
			alldeKeys = Controls.getDeCtrls(Solo(Note.NOTE_AMOUNT));
		
		for (i in 0...Note.NOTE_AMOUNT) {
			var deCtrl = alldeKeys[i].map(function(key:FlxKey) {
				return FlxKey.toStringMap.get(key);
			});
			deKeys.push(deCtrl);
		}
		return deKeys;
	}
	public function showKeys() {
		var keyTime = [];
		var keyTime2 = [];
		if (duoMode) {
			keyTime = getKeyNames(true);
			keyTime2 = getKeyNames(true, false);
		} else
			keyTime = getKeyNames();
		
		var alldeKeys:Array<FlxText> = [];
		var strums = opponentPlayer ? enemyStrums : playerStrums;
		if (duoMode) {
			for (i in 0...keyTime2.length) {
				var keyText = new FlxText(enemyStrums.members[i].x + enemyStrums.members[i].width / 2, enemyStrums.members[i].y + enemyStrums.members[i].height + 10, 0, '', 24);
				keyText.cameras = [camHUD];
				keyText.setFormat("assets/fonts/vcr.ttf", 36, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
				for (i2 in 0...keyTime2[i].length) {
					if (keyTime2[i][i2].length > 1)
						keyText.size = 20;
					keyText.text += keyTime2[i][i2] + '\n';
				}
				keyText.x -= keyText.width / 2;
				add(keyText);
				keyText.alpha = 0;
				alldeKeys.push(keyText);
			}
		}
		for (i in 0...keyTime.length) {
			var keyText = new FlxText(strums.members[i].x + strums.members[i].width / 2, strums.members[i].y + strums.members[i].height + 10, 0, '', 24);
			keyText.cameras = [camHUD];
			keyText.setFormat("assets/fonts/vcr.ttf", 36, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			for (i2 in 0...keyTime[i].length) {
				if (keyTime[i][i2].length > 1)
					keyText.size = 20;
				keyText.text += keyTime[i][i2] + '\n';
			}
			keyText.x -= keyText.width / 2;
			add(keyText);
			keyText.alpha = 0;
			alldeKeys.push(keyText);
		}
		var showThoseKeys = 0;
		new FlxTimer().start(0.1, function(tmr) {
			FlxTween.tween(alldeKeys[showThoseKeys], {alpha: 1}, 0.3);
			if (showThoseKeys < alldeKeys.length - 1) {
				showThoseKeys += 1;
				tmr.reset(0.1);
			} else {
				new FlxTimer().start(2, function(tmr) {
					for (keey in alldeKeys) {
						FlxTween.tween(keey, {alpha: 0}, 0.5, {
							onComplete: function funny(tween:FlxTween) {
								for(daText in alldeKeys) {
									remove(daText);
									daText.destroy();
								}
							}
						});
					}
				});
			}
		});
	}
	private function keyShit(?playerOne:Bool = true):Void {
		// HOLDING
		var coolControls = playerOne ? controls : controlsPlayerTwo;

		var ctrlA = coolControls.CTRLA;
		var ctrlB = coolControls.CTRLB;
		var ctrlC = coolControls.CTRLC;
		var ctrlD = coolControls.CTRLD;
		var ctrlE = coolControls.CTRLE;
		var ctrlF = coolControls.CTRLF;
		var ctrlG = coolControls.CTRLG;
		var ctrlH = coolControls.CTRLH;
		var ctrlI = coolControls.CTRLI;

		var ctrlAP = coolControls.CTRLA_P;
		var ctrlBP = coolControls.CTRLB_P;
		var ctrlCP = coolControls.CTRLC_P;
		var ctrlDP = coolControls.CTRLD_P;
		var ctrlEP = coolControls.CTRLE_P;
		var ctrlFP = coolControls.CTRLF_P;
		var ctrlGP = coolControls.CTRLG_P;
		var ctrlHP = coolControls.CTRLH_P;
		var ctrlIP = coolControls.CTRLI_P;

		var ctrlAR = coolControls.CTRLA_R;
		var ctrlBR = coolControls.CTRLB_R;
		var ctrlCR = coolControls.CTRLC_R;
		var ctrlDR = coolControls.CTRLD_R;
		var ctrlER = coolControls.CTRLE_R;
		var ctrlFR = coolControls.CTRLF_R;
		var ctrlGR = coolControls.CTRLG_R;
		var ctrlHR = coolControls.CTRLH_R;
		var ctrlIR = coolControls.CTRLI_R;

		/*var up = coolControls.UP;
		var right = coolControls.RIGHT;
		var down = coolControls.DOWN;
		var left = coolControls.LEFT;
		var upP = coolControls.UP_P;
		var rightP = coolControls.RIGHT_P;
		var downP = coolControls.DOWN_P;
		var leftP = coolControls.LEFT_P;
		var upR = coolControls.UP_R;
		var rightR = coolControls.RIGHT_R;
		var downR = coolControls.DOWN_R;
		var leftR = coolControls.LEFT_R;*/

		/*var holdArray = [left, down, up, right];
		var releaseArray = [leftR, downR, upR, rightR];
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];*/
		var holdArray = [ctrlA, ctrlB, ctrlC, ctrlD, ctrlE, ctrlF, ctrlG, ctrlH, ctrlI];
		var releaseArray = [ctrlAR, ctrlBR, ctrlCR, ctrlDR, ctrlER, ctrlFR, ctrlGR, ctrlHR, ctrlIR];
		var controlArray:Array<Bool> = [ctrlAP, ctrlBP, ctrlCP, ctrlDP, ctrlEP, ctrlFP, ctrlGP, ctrlHP, ctrlIP];
		var pressArray = controlArray;

		// FlxG.watch.addQuick('asdfa', upP);
		var actingOn:Character = playerOne ? boyfriend : dad;
		var onActing:Character = playerOne ? dad : boyfriend;
		// <3 easy way of doing it
		if (controlArray.contains(true) && !actingOn.stunned && generatedMusic) {
			if (!soloMode)
				actingOn.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var possibleBadNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note) {
				var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				if (daNote.canBeHit && coolShouldPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isLiftNote) {
					// the sorting probably doesn't need to be in here? who cares lol
					if (directionList.contains(daNote.noteData)) {
						for (coolNote in possibleNotes) {
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10) {
								dumbNotes.push(daNote);
								break;
							} else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime) {
								possibleNotes.remove(coolNote);
								/*if (daNote.dontStrum)
									possibleBadNotes.push(daNote);
								else*/
									possibleNotes.push(daNote);
								break;
							}
						}
					} else {
						/*if (daNote.dontStrum)
							possibleBadNotes.push(daNote);
						else*/
							possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}

				}
			});
			for (note in dumbNotes) {
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			//possibleBadNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var dontCheck = false;

			for (i in 0...pressArray.length) {
				if (pressArray[i] && !directionList.contains(i))
					dontCheck = true;
			}
			if ((possibleNotes.length > 0 || possibleBadNotes.length > 0) && !dontCheck) {
				var daNote;
				/*if (possibleNotes.length > 0 && possibleBadNotes.length > 0)
				    daNote = Math.abs(possibleNotes[0].strumTime - Conductor.songPosition) < Math.abs(possibleBadNotes[0].strumTime - Conductor.songPosition) ? possibleNotes[0] : possibleBadNotes[0];
				else if (possibleNotes.length == 0)
					daNote = possibleBadNotes[0];
				else*/
					daNote = possibleNotes[0];

				if (!OptionsHandler.options.useCustomInput) {
					for (shit in 0...pressArray.length) { // if a direction is hit that shouldn't be
						if (pressArray[shit] && !directionList.contains(shit))
							noteMiss(shit, playerOne);
					}
				}
				
				// Jump notes
				for (coolNote in possibleNotes) {
					// even though IT SHOULD BE ABLE TO BE HIT we do this terrible ness
					if (pressArray[coolNote.noteData] && coolNote.canBeHit && !coolNote.tooLate) {
						if (mashViolations != 0)
							mashViolations--;
						scoreTxt.color = FlxColor.WHITE;
						goodNoteHit(coolNote, playerOne);
					}
				}

			} else if (!OptionsHandler.options.useCustomInput) {
				for (shit in 0...pressArray.length)
					if (pressArray[shit])
						noteMiss(shit, playerOne);
			}
			// :shrug: idk what this for
			if (dontCheck && possibleNotes.length > 0 && OptionsHandler.options.useCustomInput && !demoMode) {
				if (mashViolations > 4) {
					trace('mash violations ' + mashViolations);
					scoreTxt.color = FlxColor.RED;
					noteMiss(0, playerOne);
				} else
					mashViolations++;
			}
		}
		// lift notes :)
		if (releaseArray.contains(true) && !actingOn.stunned && generatedMusic) {
			if (!soloMode)
				actingOn.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note) {
				var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				if (daNote.canBeHit && coolShouldPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.isLiftNote) {
					// the sorting probably doesn't need to be in here? who cares lol
					if (directionList.contains(daNote.noteData)) {
						for (coolNote in possibleNotes) {
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10) {
								dumbNotes.push(daNote);
								break;
							} else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime) {
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					} else {
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});
			for (note in dumbNotes) {
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var dontCheck = false;

			for (i in 0...releaseArray.length) {
				if (releaseArray[i] && !directionList.contains(i))
					dontCheck = true;
			}
			if (possibleNotes.length > 0 && !dontCheck) {
				var daNote = possibleNotes[0];
				/*
				if (!OptionsHandler.options.useCustomInput)
				{
					for (shit in 0...releaseArray.length)
					{ // if a direction is hit that shouldn't be
						if (releaseArray[shit] && !directionList.contains(shit))
							noteMiss(shit, playerOne);
					}
				}
				*/
				//	 Jump notes
				for (coolNote in possibleNotes) {
					if (releaseArray[coolNote.noteData]) {
						if (mashViolations != 0)
							mashViolations--;
						scoreTxt.color = FlxColor.WHITE;
						goodNoteHit(coolNote, playerOne);
					}
				}
			}
			/*
			else if (!OptionsHandler.options.useCustomInput)
			{
				for (shit in 0...releaseArray.length)
					if (releaseArray[shit])
						noteMiss(shit, playerOne);
			}
			*/
			// :shrug: idk what this for
			if (dontCheck && possibleNotes.length > 0 && OptionsHandler.options.useCustomInput && !demoMode) {
				if (mashViolations > 4) {
					trace('mash violations ' + mashViolations);
					scoreTxt.color = FlxColor.RED;
					noteMiss(0, playerOne);
				} else
					mashViolations++;
			}
		}
		if (holdArray.contains(true) && !actingOn.stunned && generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				var daRating = Ratings.CalculateRating(Math.abs(daNote.strumTime - Conductor.songPosition));
				// make sustain notes act
				// changing it to sick :blush:
				if (daNote.canBeHit && coolShouldPress && daNote.isSustainNote && (daRating == 'sick')) {
					if (holdArray[daNote.noteData])
						goodNoteHit(daNote, playerOne);
				}
			});
		}
		if (actingOn.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true)) {
			if ((actingOn.animation.curAnim.name.startsWith('sing') || actingOn.singPriority.contains(actingOn.animation.curAnim.name)) && !actingOn.animation.curAnim.name.endsWith('miss')) {
				actingOn.dance();
				trace("idle from non miss sing");
			}
		}
		if (soloMode && onActing.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true)) {
			if ((onActing.animation.curAnim.name.startsWith('sing') || onActing.singPriority.contains(onActing.animation.curAnim.name)) && !onActing.animation.curAnim.name.endsWith('miss')) {
				onActing.dance();
				trace("idle from non miss sing");
			}
		}
		var strums = playerOne ? playerStrums : enemyStrums;
		strums.forEach(function(spr:FlxSprite) {
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm') {
				spr.animation.play('pressed');
				if (useCustomInput && OptionsHandler.options.singYourHeartOut) {
					var singAnim = currrentKey[spr.ID].sing;
					var singNum = 0;
					switch(singAnim) {
						case 'singLEFT':
							singNum = 0;
						case 'singDOWN':
							singNum = 1;
						case 'singUP':
							singNum = 2;
						case 'singRIGHT':
							singNum = 3;
						default:
							singNum = -1;
					}

					if (singNum == -1)
						actingOn.playAnim(singAnim, true);
					else
						actingOn.sing(singNum);
				}
			}
			if (releaseArray[spr.ID])
				spr.animation.play('static');
			
			if (spr.animation.curAnim != null && spr.animation.curAnim.name == 'confirm' && !pixelUI) {
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			} else
				spr.centerOffsets();
		});
	}
	var mashing:Int = 0;
	var mashViolations:Int = 0;
	function noteMiss(direction:Int = 1, playerOne:Bool, ?note:Null<Note>, ?playMissSound:Bool = true):Void {
		var actingOn = playerOne ? boyfriend : dad;
		var onActing = playerOne ? dad : boyfriend;
		if (!actingOn.stunned) {
			misses += 1;
			setAllHaxeVar("misses", misses);
			if (note != null && note.noteMiss != null) {
				callHscript(note.noteMiss, [note], "modchart");
			}
			var healthBonus = -0.04 * healthLossMultiplier;
			if (note != null) {
				healthBonus = note.getHealth('miss');
			}
			if (playerOne)
				health += healthBonus;
			else
				health -= healthBonus;
			if (combo > 5 && gf.gfEpicLevel >= EpicLevel.Level_Sadness)
				gf.playAnim('sad');
			updateAccuracy();
			combo = 0;
			setAllHaxeVar("combo", combo);
			if (!practiceMode) {
				songScore -= 5;
			}
			setAllHaxeVar('songScore', songScore);
			trueScore -= 5;
			if (playMissSound)
				FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play('assets/sounds/missnote1' + TitleState.soundExt, 1, false);
			// FlxG.log.add('played imss note');

			actingOn.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer) {
				actingOn.stunned = false;
			});
			if (note != null && note.shouldBeSung) {
				var singAnim = currrentKey[note.noteData % Note.NOTE_AMOUNT].sing;
				var singNum = 0;
				switch(singAnim) {
					case 'singLEFT':
						singNum = 0;
					case 'singDOWN':
						singNum = 1;
					case 'singUP':
						singNum = 2;
					case 'singRIGHT':
						singNum = 3;
				}
				var realActor = actingOn;
				if (note.soloMode)
					realActor = onActing;
				realActor.sing(singNum, true);
				if (note != null && note.oppntSing != null) {
					onActing.sing(note.oppntSing.direction, note.oppntSing.miss, note.oppntSing.alt);
				}
			} else {
				var realActor = actingOn;
				if (note != null && note.soloMode)
					realActor = onActing;
				realActor.sing(direction, true);
			}
				
			if (playerOne) {
				callAllHScript("playerOneMiss", []);
			} else {
				callAllHScript("playerTwoMiss", []);
			}
		}
	}

	function badNoteCheck(?playerOne:Bool = true) {
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var coolControls = playerOne ? controls : controlsPlayerTwo;
		var upP = coolControls.UP_P;
		var rightP = coolControls.RIGHT_P;
		var downP = coolControls.DOWN_P;
		var leftP = coolControls.LEFT_P;

		if (leftP)
			noteMiss(0, playerOne);
		if (downP)
			noteMiss(1, playerOne);
		if (upP)
			noteMiss(2,playerOne);
		if (rightP)
			noteMiss(3,playerOne);
	}

	function noteCheck(keyP:Bool, note:Note, playerOne:Bool):Void {
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff);
		if (keyP)
			goodNoteHit(note,playerOne);
		else
			badNoteCheck(playerOne);
	}

	function goodNoteHit(note:Note, playerOne:Bool):Void {
		var actingOn = playerOne ? boyfriend : dad;
		var onActing = playerOne ? dad : boyfriend;
		if (!note.canBeHit || note.tooLate)
			return;
		if (!note.isSustainNote)
			notesHitArray.push(Date.now());
		if (!note.wasGoodHit) {
			trace("<3 was good hit");
			actingOn.altAnim = "";
			actingOn.altNum = 0;
			
			if (SONG.notes[curSection] != null) {
				if (( SONG.notes[curSection].altAnimNum != null && SONG.notes[curSection].altAnimNum > 0)
					|| SONG.notes[curSection].altAnim)
					// backwards compatibility shit
					if (SONG.notes[curSection].altAnimNum == 1
						|| SONG.notes[curSection].altAnim)
						actingOn.altNum = 1;
					else if (SONG.notes[curSection].altAnimNum > 1)
						actingOn.altNum = SONG.notes[curSection].altAnimNum;
			}
			if (note.altNote)
				actingOn.altNum = 1;
			actingOn.altNum = note.altNum;
			if (actingOn.altNum == 1) {
				actingOn.altAnim = '-alt';
			} else if (actingOn.altNum > 1) {
				actingOn.altAnim = '-alt' + actingOn.altNum;
			}
			// We pop it up even for sustains, just to update score. We don't actually show anything.
			trace("<3 pop up score");
			if (!note.dontCountNote)
				notesPassing += 1;
			popUpScore(note.strumTime, note, playerOne);
			if (!note.isSustainNote) {
				combo += 1;
				setAllHaxeVar("combo", combo);

				if (combo == 50)
					gf.playAnim('cheer', true);
				else if (combo == 200) {
					if (gf.animation.exists('fawn'))
						gf.playAnim('fawn', true);
					else
						gf.playAnim('cheer', true);
				}
			}

			if (note.shouldBeSung) {
				var singAnim = currrentKey[note.noteData % Note.NOTE_AMOUNT].sing;
				var singNum = 0;
				switch(singAnim) {
					case 'singLEFT':
						singNum = 0;
					case 'singDOWN':
						singNum = 1;
					case 'singUP':
						singNum = 2;
					case 'singRIGHT':
						singNum = 3;
					default:
						singNum = -1;
				}
				var realActor = actingOn;
				if (note.soloMode)
					realActor = onActing;
				realActor.holdTimer = 0;

				if (singNum == -1)
					realActor.playAnim(singAnim, true);
				else
					realActor.sing(singNum, false, actingOn.altNum);

				// callAllHScript("noteHit", [playerOne, note, goodhit]);
				
				if (OptionsHandler.options.hitSounds && !note.isSustainNote){
					FlxG.sound.play(FNFAssets.getSound("assets/sounds/hitSound.ogg"));
				}
				if (playerOne)
					callAllHScript("playerOneSing", []);
				else
					callAllHScript("playerTwoSing", []);
				var strums = playerOne ? playerStrums : enemyStrums;
				strums.forEach(function(spr:FlxSprite) {
					if (Math.abs(note.noteData) == spr.ID) {
						spr.animation.play('confirm', true);
					}
				});
				if (note.oppntSing != null) {
					onActing.sing(note.oppntSing.direction, note.oppntSing.miss, note.oppntSing.alt);
				}
			}

			note.wasGoodHit = true;
			var goodhit = note.wasGoodHit;
			vocals.volume = 1;
			if (playerOne)
				player1GoodHitSignal.trigger(note);
			else
				player2GoodHitSignal.trigger(note);
			callAllHScript("noteHit", [playerOne, note, goodhit]);
			if (note.noteHit != null) {
				callHscript(note.noteHit, [note], "modchart");
			}
			if (note.noteStrum != null && ((note.y < getHaxeActor('0').y - 20 && !downscroll) || (note.y > getHaxeActor('0').y + 20 && downscroll))) {
				callHscript(note.noteStrum, [], "modchart");
				note.noteStrum = null;
			}
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	var sectionSteps:Int = 0;
	override function stepHit() {
		super.stepHit();
		if (SONG.needsVoices) {
			if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20) {
				resyncVocals();
			}
		}

		setAllHaxeVar("curStep", curStep);
		callAllHScript("stepHit", [curStep]);

		// this works but prone to breaking
		/*sectionSteps += 1;
		if (sectionSteps >= PlayState.SONG.notes[curSection].lengthInSteps) {
			curSection += 1;
			sectionSteps = 0;
		}*/
		// but i think this may cause lag :shrug:
		curSection = getSection();

		songLength = FlxG.sound.music.length;

		/*if (useSongBar && songPosBar.max == 69695969) {
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic('assets/images/healthBar.png');
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
			songPosBG.cameras = [camHUD];
			if (FlxG.sound.music.length == 0) {
				songLength = 69696969;
			}
			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);
			songPosBar.cameras = [camHUD];

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
			if (downscroll)
				songName.y -= 3;
			songName.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
			
		}*/
		#if windows
		// Song duration in a float, useful for the time left feature
		

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(customPrecence
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition, playingAsRpc);
		#end
	}


	override function beatHit() {
		super.beatHit();
		
		if (generatedMusic) {
			notes.sort(FlxSort.byY, downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[curSection] != null) {
			if (SONG.notes[curSection].changeBPM) {
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
			
			// Dad doesnt interupt his own notes
			if ((!dad.animation.curAnim.name.startsWith("sing") && !dad.singPriority.contains(dad.animation.curAnim.name)) && ((!duoMode && !opponentPlayer && !soloMode) || demoMode))
				dad.dance();
			if ((!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.singPriority.contains(boyfriend.animation.curAnim.name)) && (opponentPlayer || demoMode))
				boyfriend.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[curSection].changeBPM);

		setAllHaxeVar('curBeat', curBeat);
		callAllHScript('beatHit', [curBeat]);
		
		if (!endingSong && camZooming && FlxG.camera.zoom < 1.35 && camZoomRate > 0 && curBeat % camZoomRate == 0) {
			FlxG.camera.zoom += 0.015 * camZoomIntensity;
			camHUD.zoom += 0.03 * camZoomIntensity;
		}

		iconP1.dance();
		iconP2.dance();
		practiceDieIcon.dance();
		if (curBeat % gfSpeed == 0 && !gf.animation.curAnim.name.startsWith("sing") && !gf.singPriority.contains(gf.animation.curAnim.name)) 
			gf.dance();

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.singPriority.contains(boyfriend.animation.curAnim.name) && !opponentPlayer && !demoMode)
			boyfriend.dance();

		if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.singPriority.contains(dad.animation.curAnim.name) && (duoMode || opponentPlayer || soloMode) && !demoMode)
			dad.dance();

		if (curBeat % 8 == 7 && SONG.isHey)
			boyfriend.playAnim('hey', true);

		if (curBeat % 8 == 7 && SONG.isCheer && dad.gfEpicLevel >= Character.EpicLevel.Level_Sing)
			dad.playAnim('cheer', true);

		// gf should also cheer?
		if (curBeat % 8 == 7 && SONG.isCheer && gf.gfEpicLevel >= Character.EpicLevel.Level_Sing)
			gf.playAnim('cheer', true);
	}
	function updatePrecence() {
		#if windows
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(customPrecence
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	function getSection() {
		var daSteps = -1; // dont ask me why i need this offset, only tell me how i could make this zero or go away >:(
		for (i in 0...PlayState.SONG.notes.length) {
			var section = PlayState.SONG.notes[i];
			var heyguesswhatthisisnull:Null<Int> = null; // im going to go insane
			if (section.lengthInSteps <= 0 || section.lengthInSteps == heyguesswhatthisisnull) section.lengthInSteps = 16;
			daSteps += section.lengthInSteps;
			if (daSteps >= curStep)
				return i;
		}
		return 0;
	}
}