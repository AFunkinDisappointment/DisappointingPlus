package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.system.System;
import lime.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end
import haxe.Json;
import tjson.TJSON;
using StringTools;
class GameOverSubstate extends MusicBeatSubstate {
	var bf:Character;
	var camFollow:FlxObject;

	public function new(player:Character) {
		var daBf:String = player.curCharacter + '-dead';
		trace(player.curCharacter);
		
		super();
		Conductor.songPosition = 0;

		bf = new Character(player.x - player.playerOffsetX, player.y - player.playerOffsetY, daBf, true);
		bf.x += bf.playerOffsetX;
		bf.y += bf.playerOffsetY;
		bf.beingControlled = true;
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);
		if (!FNFAssets.exists('assets/sounds/${bf.deathSound}'))
			bf.deathSound = 'fnf_loss_sfx.ogg';
		if (bf.isPixel && bf.deathSound == 'fnf_loss_sfx.ogg')
			bf.deathSound = 'fnf_loss_sfx-pixel.ogg';
		FlxG.sound.play(FNFAssets.getSound('assets/sounds/' + bf.deathSound));
		Conductor.changeBPM(100);

		FlxG.camera.focusOn(PlayState.instance.camFollow.getPosition());
		FlxG.camera.target = null;

		if (bf.animation.exists('firstDeath'))
			bf.playAnim('firstDeath');
		else { // backup if the player character has no death animation
			new FlxTimer().start(0.6, function(tmr:FlxTimer) { FlxG.camera.follow(camFollow, LOCKON, 0.01); });
			new FlxTimer().start(2.1, function(tmr:FlxTimer) { playGameoverMusic(); });
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK) {
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				LoadingState.loadAndSwitchState(new StoryMenuState());
			else
				LoadingState.loadAndSwitchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath') {
			if (bf.animation.curAnim.curFrame == 12)
				FlxG.camera.follow(camFollow, LOCKON, 0.01);
			else if (bf.animation.curAnim.finished)
				playGameoverMusic();
		}

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	function playGameoverMusic() {
		if (!FNFAssets.exists('assets/music/${bf.gameoverMusic}'))
			bf.gameoverMusic = 'gameOver.ogg';
		if (bf.isPixel && bf.gameoverMusic == 'gameOver.ogg')
			bf.gameoverMusic = 'gameOver-pixel.ogg';
		FlxG.sound.playMusic(FNFAssets.getSound('assets/music/' + bf.gameoverMusic));
	}

	override function beatHit() {
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void {
		if (!isEnding) {
			isEnding = true;
			bf.playAnim('deathConfirm', true);

			FlxG.sound.music.stop();
			if (!FNFAssets.exists('assets/music/${bf.gameoverMusicEnd}'))
				bf.gameoverMusicEnd = 'gameOverEnd.ogg';
			if (bf.isPixel && bf.gameoverMusicEnd == 'gameOverEnd.ogg')
				bf.gameoverMusicEnd = 'gameOverEnd-pixel.ogg';
			FlxG.sound.play(FNFAssets.getSound('assets/music/' + bf.gameoverMusicEnd));

			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
