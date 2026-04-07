package;

import flixel.FlxG;
import flixel.FlxSprite;
import lime.utils.Assets;
import lime.system.System;
import flash.display.BitmapData;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIButton;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;

import sys.FileSystem;
#end
import flixel.math.FlxMath;
import hscript.Expr;
import hscript.Interp;
import hscript.ParserEx;
import haxe.xml.Parser;
import hscript.InterpEx;
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
using StringTools;

class ChartCharDropdown extends FlxTypedSpriteGroup<FlxSprite> {
	public var searchBox:FlxUIInputText;
	var clearSearch:FlxUIButton;
	var box:FlxSprite;
	var bg:FlxSprite;
	var upButton:FlxUIButton;
	var downButton:FlxUIButton;
	var exitButton:FlxUIButton;

	public var charType = 'bf';
	var charButtons:Array<Dynamic> = [];
	var stageButtons:Array<Dynamic> = [];

	var buttonHeight = 3;
	var buttonWidth = 3;

	public function new(daX:Int, daY:Int, charTypee:String = 'bf') {
		super(daX, daY);

		var epicCharFile:Dynamic = CoolUtil.parseJson(FNFAssets.getJson('assets/images/custom_chars/custom_chars'));
		var allChars:Array<Dynamic> = Reflect.fields(epicCharFile);
		allChars.sort(sortAlph);

		var epicStageFile:Dynamic = CoolUtil.parseJson(FNFAssets.getJson('assets/images/custom_stages/custom_stages'));
		var allStages:Array<Dynamic> = Reflect.fields(epicStageFile);
		allStages.sort(sortAlph);

		charType = charTypee;
		scroll = 0;

		bg = new FlxSprite(daX + 15, daY + 50).makeGraphic(170, 170, 0xFF808080);
		add(bg);

		var charIcon = new HealthIcon('bf');
		charIcon.setGraphicSize(45, 45);

		for (char in allChars) {
			charIcon.switchAnim(char);
			var charButton = new FlxUIButton(10, 10, char, function():Void {
				ChartingState.setCharacter(char, charType);
			});
			var charButtonLabel = charButton.getLabel();
			//charButtonLabel.text = StringTools.replace(charButtonLabel.text, '-', ' ');
			charButtonLabel.offset.y -= 10;
			charButtonLabel.setFormat('assets/fonts/vcr.ttf', 10, 0xFFFFFFFF, 'center', OUTLINE, 0xFF404040);
			charButton.resize(50, 50);
			charButton.addIcon(charIcon);
			charButtons.push(charButton);
			add(charButton);
		}

		for (stage in allStages) {
			var stageButton = new FlxUIButton(10, 10, stage, function():Void {
				ChartingState.setCharacter(stage, charType);
			});
			var stageButtonLabel = stageButton.getLabel();
			stageButtonLabel.setFormat('assets/fonts/vcr.ttf', 8, 0xFFFFFFFF, 'center', OUTLINE, 0xFF404040);
			stageButton.resize(50, 50);
			stageButtons.push(stageButton);
			add(stageButton);
		}

		box = new FlxSprite(daX, daY).loadGraphic('assets/images/charDropdown.png');
		add(box);

		searchBox = new FlxUIInputText(daX + 20, daY + 15, 100, '', 12);
		add(searchBox);

		clearSearch = new FlxUIButton(daX + 125, daY + 15, 'x', function():Void {
			searchBox.text = '';
		});
		clearSearch.resize(15, 15);
		add(clearSearch);

		upButton = new FlxUIButton(daX + 190, daY + 50, 'Up', function():Void {
			scroll -= 55;
		});
		upButton.resize(40, 40);
		add(upButton);
		downButton = new FlxUIButton(daX + 190, daY + 100, 'Down', function():Void {
			scroll += 55;
		});
		downButton.resize(40, 40);
		add(downButton);

		exitButton = new FlxUIButton(daX + 200, daY + 10, 'Exit', function():Void {
			ChartingState.setCharacter(ChartingState._song.player1, 'bf');
		});
		exitButton.resize(30, 20);
		add(exitButton);
	}

	function sortAlph(a:String, b:String) { // might have borrowed this :)
		a = a.toUpperCase();
		b = b.toUpperCase();
		return a == b ? 0 : a > b ? 1 : -1;
	}

	override function destroy() {
		for (button in charButtons) {
			charButtons.remove(button);
			button.destroy();
		}
		for (button in stageButtons) {
			stageButtons.remove(button);
			button.destroy();
		}
		searchBox.destroy();
		clearSearch.destroy();
		bg.destroy();
		box.destroy();
		upButton.destroy();
		downButton.destroy();
		exitButton.destroy();
	}

	var scroll = 0;
	override function update(elapsed:Float) {
		super.update(elapsed);

		if (scroll < 0)
			scroll = 0;
		var totalButtons = [1, 1];
		var shownButtons = charButtons;
		switch(charType) {
			case 'bf' | 'dad' | 'gf':
				for (button in stageButtons) {
					button.y = -2500;
				}
			case 'stage':
				shownButtons = stageButtons;
				for (button in charButtons) {
					button.y = -2500;
				}
		}
		for (button in shownButtons) {
			if (button.getLabel().text.indexOf(searchBox.text) != -1) {
				button.x = searchBox.x + 55 * ((totalButtons[0] - 1) % buttonWidth);
				if (totalButtons[0] - 1 >= buttonWidth) {
					totalButtons[0] = 1;
					totalButtons[1] += 1;
				}
				button.y = searchBox.y + 40 - scroll + 55 * (totalButtons[1] - 1);
				if (button.y < searchBox.y + 15 || button.y > searchBox.y + 180)
					button.y = -2500;		
				totalButtons[0] += 1;
			} else
				button.y = -2500;
		}
		if (scroll > (totalButtons[1] - buttonHeight) * 55 && totalButtons[1] > buttonHeight)
			scroll = (totalButtons[1] - buttonHeight) * 55;
		else if (totalButtons[1] <= buttonHeight)
			scroll = 0;
	}
}
