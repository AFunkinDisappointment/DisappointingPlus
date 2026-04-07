package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.ui.FlxUIButton;

class ModuleBox extends FlxTypedSpriteGroup<FlxSprite> {
	var background:FlxSprite;
	public var nameLabel:FlxText;
	public var icon:HealthIcon;
	public var mainButton:FlxUIButton;
	public var secondaryButton:FlxUIButton;
	
	public var boxType:String = 'song';
	public function new(x:Int, y:Int, type:String, name:String = 'No Name Found', iconChar:String = 'bf') {
		super(x, y);
		scrollFactor.set(1, 1);
		background = new FlxSprite().loadGraphic('assets/images/plainbox.png');
		add(background);

		icon = new HealthIcon(iconChar);
		icon.setPosition(0, 5);
		add(icon);

		nameLabel = new FlxText(180, 0, background.width - 240, name);
		nameLabel.setFormat('assets/fonts/vcr.otf', 40, 0xFFFFFFFF, 'left');
		add(nameLabel);
	}

	public function MainButton(text:String, onClick:() -> Void) {
		mainButton = new FlxUIButton(background.width - 120, 20, text, onClick);
		add(mainButton);
	}

	public function SecondaryButton(text:String, onClick:() -> Void) {
		secondaryButton = new FlxUIButton(background.width - 120, 60, text, onClick);
		add(secondaryButton);
	}
}