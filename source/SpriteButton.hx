package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxClickArea;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;

class SpriteButton extends FlxSprite
{
	var button:FlxClickArea;

	public function new(x:Float, y:Float) {
	}

	public function loadGraphicButton(path:String) {
		loadGraphic(path);
		button = new FlxClickArea(sprite.x, sprite.y, sprite.width, sprite.height);
	}
}