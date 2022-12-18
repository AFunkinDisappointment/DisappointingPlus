package;

import flash.display.BitmapData;
import Judgement.TUI;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.typeLimit.OneOfTwo;
import lime.system.System;
import DynamicSprite.DynamicAtlasFrames;
using StringTools;

#if sys
import flash.media.Sound;
import haxe.io.Path;
import lime.media.AudioBuffer;
import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;
#end


class EdtNote extends FlxSprite
{
	public var mustBeUpdated:Bool = false;
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var duoMode:Bool = false;
	public var oppMode:Bool = false;
	public var sustainLength:Float = 0;

	public var funnyMode:Bool = false;
	public var noteScore:Float = 1;
	public var altNote:Bool = false;
	public var altNum:Int = 0;
	public var isPixel:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;
	public static var NOTE_AMOUNT:Int = 4;

	public var rating = "miss";
	public var isLiftNote:Bool = false;
	public var mineNote:Bool = false;
	public var healMultiplier:Float = 1;
	public var damageMultiplier:Float = 1;
	// Whether to always do the same amount of healing for hitting and the same amount of damage for missing notes
	public var consistentHealth:Bool = false;
	// How relatively hard it is to hit the note. Lower numbers are harder, with 0 being literally impossible
	public var timingMultiplier:Float = 1;
	// whether to play the sing animation for hitting this note
	public var shouldBeSung:Bool = true;
	public var ignoreHealthMods:Bool = false;
	public var nukeNote = false;
	public var drainNote = false;

	var currentKey = null; // I tried pulling this from Playstate but it was being weird...

	static var coolCustomGraphics:Array<FlxGraphic> = [];

	// altNote can be int or bool. int just determines what alt is played
	// format: [strumTime:Float, noteDirection:Int, sustainLength:Float, altNote:Union<Bool, Int>, isLiftNote:Bool, healMultiplier:Float, damageMultipler:Float, consistentHealth:Bool, timingMultiplier:Float, shouldBeSung:Bool, ignoreHealthMods:Bool, animSuffix:Union<String, Int>]
	public function new(strumTime:Float, noteData:Int, ?LiftNote:Bool = false)
	{
		super();
		// uh oh notedata sussy :flushed:
		isLiftNote = LiftNote;
		if (isLiftNote)
			shouldBeSung = false;
		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		NOTE_AMOUNT = ChartingState._song.preferredNoteAmount;

		var notePresets = CoolUtil.parseJson(FNFAssets.getText('assets/data/defaultNotePresets.json'));
		currentKey = Reflect.field(notePresets, 'key' + NOTE_AMOUNT);

		this.noteData = noteData;
		var sussy:Bool = false;
		if (noteData >= NOTE_AMOUNT * 2 && noteData < NOTE_AMOUNT * 4) {
			mineNote = true;
		} else if (noteData >= NOTE_AMOUNT * 4 && noteData < NOTE_AMOUNT * 6) {
			isLiftNote = true;
		} else if (noteData >= NOTE_AMOUNT * 6 && noteData < NOTE_AMOUNT * 8) {
			nukeNote = true;
		} else if (noteData >= NOTE_AMOUNT * 8 && noteData < NOTE_AMOUNT * 10) {
			drainNote = true;
		} else if (noteData >= NOTE_AMOUNT * 10) {
			sussy = true;
		}

		frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/normal/NOTE_assets.png',
			'assets/images/custom_ui/ui_packs/normal/NOTE_assets.xml');
		if (sussy) {
			// we need to load a unique instance
			// we only need 1 unique instance per number so we do save the graphics
			var sussyInfo = Math.floor(noteData / (NOTE_AMOUNT * 2)) - 5;
			if (coolCustomGraphics[sussyInfo] == null)
				coolCustomGraphics[sussyInfo] = FlxGraphic.fromAssetKey('assets/images/custom_ui/ui_packs/normal/NOTE_assets.png', true);

			frames = FlxAtlasFrames.fromSparrow(coolCustomGraphics[sussyInfo], 'assets/images/custom_ui/ui_packs/normal/NOTE_assets.xml');
		}

		var noteName = currentKey[noteData % NOTE_AMOUNT].note;
		if (isLiftNote)
			animation.addByPrefix('Scroll', noteName + ' lift');
		else if (nukeNote)
			animation.addByPrefix('Scroll', noteName + ' nuke');
		else if (mineNote)
			animation.addByPrefix('Scroll', noteName + ' mine');
		else
			animation.addByPrefix('Scroll', noteName + '0');

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;

		x += swagWidth * (noteData % NOTE_AMOUNT);
		animation.play('Scroll');

		if (noteData >= NOTE_AMOUNT * 10)
		{
			var sussyInfo = Math.floor(noteData / (NOTE_AMOUNT * 2));
			sussyInfo -= 4;
			var text = new FlxText(0, 0, 0, cast sussyInfo, 64);
			stamp(text, Std.int(this.width / 2), 20);
		}
	}
}
