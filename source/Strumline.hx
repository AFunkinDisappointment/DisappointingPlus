package;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if desktop
import Sys;
import sys.FileSystem;
#end

class Strumline extends FlxTypedSpriteGroup<StrumNote> {
	var currentKey:Dynamic;
	public function new(x:Float, y:Float, type:String = 'normal', ?transition:Bool = false) {
		super(x, y);

		changeType(type, transition);
	}

	public function changeType(type:String = 'normal', ?transition:Bool = false) {
		if (this.length > 0)
			forEach(function(spr:StrumNote) {
				remove(spr);
				spr.destroy();
			});

		var daType = Reflect.field(Judgement.uiJson, type);

		var presetJson:String = 'assets/data/defaultNotePresets.json';
		if (FNFAssets.exists('assets/images/custom_ui/ui_packs/' + daType.uses + '/multiNotePresets.json'))
			presetJson = 'assets/images/custom_ui/ui_packs/' + daType.uses + '/multiNotePresets.json';

		var notePresets = CoolUtil.parseJson(FNFAssets.getText(presetJson));
		currentKey = Reflect.field(notePresets, 'key' + Note.NOTE_AMOUNT);

		for (i in 0...Note.NOTE_AMOUNT) {
			var babyArrow:StrumNote = new StrumNote(Note.swagWidth * i, 0, i, type, currentKey);
			add(babyArrow);
		}

		if (transition)
			transIn();
	}

	public function transIn() {
		for (i in 0...this.length)  {
			var arrow = members[i];
			arrow.y -= 10;
			arrow.alpha = 0;
			FlxTween.tween(arrow, {y: arrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
		}
	}

	public function resetStrums() {
		forEach(function(spr:StrumNote) {
			spr.x = Note.swagWidth * spr.ID;
			if (Note.NOTE_AMOUNT > 4)
				spr.x -= 10 + 15 * (Note.NOTE_AMOUNT - 4) + (20 + (7 * (Note.NOTE_AMOUNT - 5))) * ID;
			spr.y = 0;
			spr.resetStrumSize();
		});
	}
}

class StrumNote extends FlxSprite {
	public var type:String = 'normal';
	public var isPixel:Bool = false;
	public var normalSize:Float = 0.7;

	public function new(x:Float = 0, y:Float = 0, noteId:Int = 0, type:String = 'normal', ?currentKey:Dynamic) {
		super(x, y);

		var daType = Reflect.field(Judgement.uiJson, type);

		if (currentKey == null) {
			var notePresets = CoolUtil.parseJson(FNFAssets.getText('assets/data/defaultNotePresets.json'));
			currentKey = Reflect.field(notePresets, 'key' + Note.NOTE_AMOUNT);
		}

		this.ID = noteId;
		this.type = type;
		this.isPixel = daType.isPixel;

		var notePic;
		var noteXml:String = null;
		if (!isPixel) {
			notePic = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + daType.uses + "/NOTE_assets.png");
			noteXml = FNFAssets.getText('assets/images/custom_ui/ui_packs/' + daType.uses + "/NOTE_assets.xml");
		} else {
			notePic = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + daType.uses + "/arrows-pixels.png");
			if (FNFAssets.exists('assets/images/custom_ui/ui_packs/' + daType.uses + "/arrows-pixels.xml")) 
				noteXml = FNFAssets.getText('assets/images/custom_ui/ui_packs/' + daType.uses + "/arrows-pixels.xml");
		}

		if (noteXml != null) {
			frames = FlxAtlasFrames.fromSparrow(notePic, noteXml);

			final frameRateMult = isPixel ? 0.5 : 1;
			
			final flippedID = PlayState.flippedNotes ? Note.NOTE_AMOUNT - (ID + 1) : ID;
			var currentNote = currentKey[flippedID];
			animation.addByPrefix('static', currentNote.idle, 24 * frameRateMult);
			animation.addByPrefix('pressed', currentNote.pressed, 24 * frameRateMult, false);
			animation.addByPrefix('confirm', currentNote.confirm, 24 * frameRateMult, false);
			animation.play('static');
			
			antialiasing = !isPixel;
			if (isPixel)
				setGraphicSize(Std.int(width * 6));
			else
				setGraphicSize(Std.int(width * 0.7));
		} else {
			// old pixeling
		}

		normalSize = scale.x;

		if (Note.NOTE_AMOUNT > 4) {
			this.x -= 10 + 15 * (Note.NOTE_AMOUNT - 4) + (20 + (7 * (Note.NOTE_AMOUNT - 5))) * ID;
			if (isPixel) {
				scale.x = scale.x - 0.05 * (Note.NOTE_AMOUNT - 5) * 6;
				scale.y = scale.y - 0.05 * (Note.NOTE_AMOUNT - 5) * 6;
			} else {
				scale.x = scale.x - 0.05 * (Note.NOTE_AMOUNT - 5);
				scale.y = scale.y - 0.05 * (Note.NOTE_AMOUNT - 5);
			}
		} else if (Note.NOTE_AMOUNT < 4) {
			// maybe later
		}

		updateHitbox();
		scrollFactor.set();
	}

	public function playAnim(anim:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		animation.play(anim, force, reversed, frame);

		if (animation.curAnim != null && animation.curAnim.name == 'confirm' && !isPixel) {
			centerOffsets();
			offset.x -= 13;
			offset.y -= 13;
		} else
			centerOffsets();
	}

	public function resetStrumSize() {
		scale.x = scale.y = normalSize;
	}
}