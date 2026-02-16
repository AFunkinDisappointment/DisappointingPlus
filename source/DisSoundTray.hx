package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.events.Event;
import flixel.util.FlxTimer;

class DisSoundTray extends Sprite {
	private var soundTray:Bitmap;
	private var mutedTxt:TextField;
	private var vols:Array<Bitmap> = [];
	private var activated:Bool = false;
	private var distime:Float = 200;
	private var lastVol:Float = 0;
	public function new() {
		super();

		lastVol = FlxG.sound.volume;

		//soundTray = new FlxSprite(FlxG.width, FlxG.height - 200).makeGraphic(120, 200, 0xFF404040);
		soundTray = new Bitmap(new BitmapData(70, 150, true, 0x7F404040));
		soundTray.visible = false;
		soundTray.x = FlxG.width;
		soundTray.y = FlxG.height - 150;
		addChild(soundTray);

		for (i in 0...10) {
			var vol = new Bitmap(new BitmapData(20 + 2*i, 10, false, 0xFF808080));
			vol.x = soundTray.x + 10 + 2*i;
			vol.y = soundTray.y + 120 - 12*i;
			vols.push(vol);
			addChild(vol);
		}

		//mutedTxt = new FlxText(FlxG.width, FlxG.height, 0, "MUTED", 24);
		mutedTxt = new TextField();
		mutedTxt.text = 'MUTED';
		mutedTxt.width = 100;
		mutedTxt.height = 30;
		var dtf:TextFormat = new TextFormat('assets/fonts/vcr.ttf', 24, 0xffffff);
		mutedTxt.defaultTextFormat = dtf;
		mutedTxt.x = FlxG.width - mutedTxt.width;
		mutedTxt.y = FlxG.height - mutedTxt.height;
		mutedTxt.visible = false;
		addChild(mutedTxt);

		addEventListener(Event.ENTER_FRAME, update);
	}

	private function update(_) {
		if (!activated) {
			distime -= 1;
			if (distime <= 0)
				activated = true;
		}

		if (soundTray.x < FlxG.width && activated) {
			soundTray.x += soundTray.width * 0.02;
			if (soundTray.x >= FlxG.width) {
				soundTray.visible = false;
				if (FlxG.save.isBound) {
					FlxG.save.data.mute = FlxG.sound.muted;
					FlxG.save.data.volume = FlxG.sound.volume;
				}
			}
		}

		if (lastVol != FlxG.sound.volume) {
			activated = false;
			soundTray.x = FlxG.width - soundTray.width;
			soundTray.visible = true;
			FlxG.sound.play('assets/sounds/clickText' + TitleState.soundExt, 0.8);
			distime = 200;
		}

		for (i in 0...vols.length) {
			vols[i].x = soundTray.x + 10 + i;
			if (i + 1 <= Math.round(FlxG.sound.volume * 10))
				vols[i].alpha = 1;
			else
				vols[i].alpha = 0.5;
		}
		mutedTxt.visible = FlxG.sound.muted;
		lastVol = FlxG.sound.volume;
	}
}
