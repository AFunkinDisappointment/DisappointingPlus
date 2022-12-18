package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FridayHijinksTrailer extends MusicBeatState
{
	public function new():Void {
		super();
	}

	var floor:FlxSprite;
	var logo:FlxSprite;
	var lemon:FlxSprite;
	var endScreen:FlxSprite;

	override function create() {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.playMusic('assets/images/trailer/da audo.ogg', 1);
		Conductor.changeBPM(95);
		persistentUpdate = true;

		floor = new FlxSprite().loadGraphic('assets/images/trailer/Mansion Floor.png');
		floor.antialiasing = true;
		floor.screenCenter();
		floor.visible = false;
		add(floor);

		logo = new FlxSprite();
		logo.frames = FlxAtlasFrames.fromSparrow('assets/images/trailer/logo.png', 'assets/images/trailer/logo.xml');
		logo.animation.addByPrefix('idle', "idle", 24);
		logo.animation.addByPrefix('shadow', "shadow", 24);
		logo.animation.play('shadow');
		logo.antialiasing = true;
		logo.screenCenter();
		logo.y -= 180;
		logo.visible = false;
		add(logo);

		lemon = new FlxSprite();
		lemon.frames = FlxAtlasFrames.fromSparrow('assets/images/trailer/wakey wakey.png', 'assets/images/trailer/wakey wakey.xml');
		lemon.animation.addByPrefix('idle', "idle", 24);
		lemon.animation.addByPrefix('shadow', "shadow", 24);
		lemon.animation.addByPrefix('open', "open", 24, false);
		lemon.animation.play('shadow');
		lemon.antialiasing = true;
		lemon.screenCenter();
		lemon.y += 230;
		lemon.visible = false;
		add(lemon);

		endScreen = new FlxSprite().loadGraphic('assets/images/trailer/full release omg.png');
		endScreen.setGraphicSize(FlxG.width, FlxG.height);
		endScreen.updateHitbox();
		endScreen.antialiasing = true;
		endScreen.visible = false;
		add(endScreen);

		FlxG.camera.zoom = 0.5;

		super.create();
	}

	override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	override function beatHit() {
		switch(curBeat) {
			case 4:
				logo.visible = true;
				lemon.visible = true;
				FlxTween.tween(FlxG.camera, {zoom: 0.7}, 10);
			case 20:
				FlxG.camera.flash(0xFF000000, 0.5);
				logo.animation.play('idle');
				lemon.animation.play('idle');
				floor.visible = true;
			case 28:
				new FlxTimer().start(0.4, function(tmr:FlxTimer) {
					lemon.animation.play('open');
				});
			case 29:
				logo.visible = false;
				lemon.visible = false;
				floor.visible = false;
				FlxG.camera.zoom = 1;
			case 31:
				FlxG.camera.flash(0xFF000000, 2);
				endScreen.visible = true;
		}

		super.beatHit();
	}
}
