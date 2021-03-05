package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flash.display.BitmapData;
import lime.utils.Assets;
import lime.system.System;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;
	public var like:String = "senpai";
	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;
	var isPixel:Array<Bool> = [true,true,true];
	var senpaiColor:FlxColor = FlxColor.WHITE;
	var textColor:FlxColor = 0xFF3F2021;
	var dropColor:FlxColor = 0xFFD89494;
	var senpaiVisible = true;
	var hasDialog:Bool;
	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();
		if (dialogueList != null)
			hasDialog = true;
		switch (PlayState.SONG.cutsceneType)
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'spirit':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'angry-senpai':
				// do nothing
			default:
				// see if the song has one
				if (FileSystem.exists('assets/data/'+PlayState.SONG.song.toLowerCase()+'/Lunchbox.ogg')) {
					var lunchboxSound = Sound.fromFile(Paths.file(''));
					FlxG.sound.playMusic(lunchboxSound, 0);
					FlxG.sound.music.fadeIn(1,0,0.8);
				// otherwise see if there is an ogg file in the dialog
			} else if (FileSystem.exists('assets/images/custom_ui/dialog_boxes/'+PlayState.SONG.cutsceneType+'/Lunchbox.ogg')) {
					var lunchboxSound = Sound.fromFile('assets/images/custom_ui/dialog_boxes/'+PlayState.SONG.cutsceneType+'/Lunchbox.ogg');
					FlxG.sound.playMusic(lunchboxSound, 0);
					FlxG.sound.music.fadeIn(1,0,0.8);
				}
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		portraitLeft = new FlxSprite(-20, 40);
		if (FileSystem.exists(Paths.file('characters/'+PlayState.SONG.player2+'/portrait.png', 'custom'))) {
			// if a  custom character portrait exists, use that
			var coolP2Json = Character.getAnimJson(PlayState.SONG.player2);
			// do false because it be kinda weird like that tho
			isPixel[1] = if (Reflect.hasField(coolP2Json, "isPixel")) coolP2Json.isPixel else false;
			var rawPic = BitmapData.fromFile(Paths.file('characters/' + PlayState.SONG.player2 + '/portrait.png', 'custom'));
			var rawXml = File.getContent(Paths.file('characters/' + PlayState.SONG.player2 + '/portrait.png', "custom"));
			portraitLeft.frames = FlxAtlasFrames.fromSparrow(rawPic, rawXml);
		} else {
			// otherwise, use senpai
			portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait', 'week6');

		}
		portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		trace(portraitLeft.animation.getByName('enter').frames);
		if (isPixel[1]) {
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		} else {
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 0.9));
		}

		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		portraitRight = new FlxSprite(0, 40);
		if (FileSystem.exists(Paths.file('characters/'+PlayState.SONG.player1+'/portrait.png','custom'))) {
			var coolP1Json = Character.getAnimJson(PlayState.SONG.player1);
			isPixel[0] = if (Reflect.hasField(coolP1Json, "isPixel")) coolP1Json.isPixel else false;
			var rawPic = BitmapData.fromFile(Paths.file('characters/'+PlayState.SONG.player1+'/portrait.png','custom'));
			var rawXml = File.getContent(Paths.file('characters/' + PlayState.SONG.player1 + '/portrait.png', 'custom'));
			portraitRight.frames = FlxAtlasFrames.fromSparrow(rawPic, rawXml);
		} else {
			portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait', 'week6');
		}

		portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
		// allow player to use non pixel portraits. this means the image size can be around 6 times the size, based on the pixel zoom
		if (isPixel[0]) {
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
		} else {
			portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.9));
		}

		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;

		box = new FlxSprite(-20, 45);

		switch (PlayState.SONG.cutsceneType)
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				like = "senpai";
			case 'angry-senpai':
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);
				senpaiVisible = false;
				like = "angry-senpai";
			case 'spirit':
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
				textColor = FlxColor.WHITE;
				dropColor = FlxColor.BLACK;
				senpaiColor = FlxColor.BLACK;
				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
				like = "spirit";
			case 'none':
				// do nothing
			case 'monster':
				// do nothing
			default:
				if (FileSystem.exists(Paths.file('ui/dialog_boxes/'+PlayState.SONG.cutsceneType+'/box.png', 'custom'))) {
					var rawPic = BitmapData.fromFile(Paths.file('ui/dialog_boxes/' + PlayState.SONG.cutsceneType + '/box.png', 'custom'));
					var rawXml = File.getContent(Paths.file('ui/dialog_boxes/' + PlayState.SONG.cutsceneType + '/box.xml', 'custom'));
					box.frames = FlxAtlasFrames.fromSparrow(rawPic,rawXml);
					var coolJsonFile:Dynamic = CoolUtil.parseJson(Assets.getText(Paths.json('dialog_boxes', 'preload')));
					var coolAnimFile = CoolUtil.parseJson(File.getContent(Paths.file('ui/dialog_boxes/'+Reflect.field(coolJsonFile,PlayState.SONG.cutsceneType).like+'.json', 'custom')));
					isPixel[2] = coolAnimFile.isPixel;
					senpaiVisible = coolAnimFile.senpaiVisible;
					senpaiColor = FlxColor.fromString(coolAnimFile.senpaiColor);
					textColor = FlxColor.fromString(coolAnimFile.textColor);
					dropColor = FlxColor.fromString(coolAnimFile.dropColor);
					if (coolAnimFile.like == "senpai") {
						box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
						box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
						like = "senpai";
					} else if (coolAnimFile.like == "senpai-angry") {
						// should i keep this?
						if (FileSystem.exists(Paths.file('ui/dialog_boxes/' + PlayState.SONG.cutsceneType + '/angry.ogg', 'custom'))) {
							var coolSound:Sound = Sound.fromFile(Paths.file('ui/dialog_boxes/' + PlayState.SONG.cutsceneType + '/angry.ogg', 'custom'));
							FlxG.sound.play(coolSound);
						} else {
							FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
						}
						
						box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
						box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);
						like = "angry-senpai";
					} else if (coolAnimFile.like == "spirit") {
						box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
						box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
						if (FileSystem.exists('assets/images/custom_ui/dialog_boxes/'+PlayState.SONG.cutsceneType+'/face.png')) {
							var facePic = BitmapData.fromFile('assets/images/custom_ui/dialog_boxes/'+PlayState.SONG.cutsceneType+'/face.png');
							var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(facePic);
							if (isPixel[2]) {
								face.setGraphicSize(Std.int(face.width * 6));
							}

							add(face);
						}
						// NO ELSE TO SUPPORT CUSTOM PORTRAITS
						like = "spirit";
					}
				}
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
		
		box.animation.play('normalOpen');
		if (isPixel[2]) {
			box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		} else {
			box.setGraphicSize(Std.int(box.width * 0.9));
		}

		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
		add(handSelect);


		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// NOT HARD CODING CAUSE I BIG BBRAIN
		portraitLeft.color = senpaiColor;
		dropText.color = dropColor;
		swagDialogue.color = textColor;

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}
		// suss

		// when the music state is sus
		if (PlayerSettings.player1.controls.SECONDARY) 
		{
			// skip all this shit
			if (!isEnding)
			{
				isEnding = true;

				if (like == "senpai" || like == "spirit")
					FlxG.sound.music.fadeOut(2.2, 0);

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					box.alpha -= 1 / 5;
					bgFade.alpha -= 1 / 5 * 0.7;
					portraitLeft.visible = false;
					portraitRight.visible = false;
					swagDialogue.alpha -= 1 / 5;
					dropText.alpha = swagDialogue.alpha;
				}, 5);

				new FlxTimer().start(1.2, function(tmr:FlxTimer)
				{
					finishThing();
					kill();
				});
			}
		} else if (FlxG.keys.justPressed.ANY)
		{
			remove(dialogue);
				
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (like == "senpai" || like == "spirit")
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		switch (curCharacter)
		{
			case 'dad':
				portraitRight.visible = false;
				if (!portraitLeft.visible && senpaiVisible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'bf':
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
