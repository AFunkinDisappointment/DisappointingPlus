package;

import flixel.input.gamepad.mappings.XInputMapping;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
using Lambda;
class ControlsState extends MusicBeatState {
    var askToBind:FlxTypedSpriteGroup<FlxSprite>;
    var bindTxt:FlxText;
    var askingToBind:Bool = false;
    var grpBind:FlxTypedGroup<Alphabet>;
    var awaitingFor:Int = -1;
    var curSelected:Int = 0;
	var curKey:Int = 4;
	var curKeyText:FlxText;
	var editableControls:Array<Array<Dynamic>> = [
		['Left', FlxG.save.data.keys.left],
		['Down', FlxG.save.data.keys.down],
		['Up', FlxG.save.data.keys.up],
		['Right', FlxG.save.data.keys.right],
		['Sync Vocals', FlxG.save.data.keys.syncVocals],
		['Volume Up', FlxG.save.data.keys.volUp],
		['Volume Down', FlxG.save.data.keys.volDown]
	];
    override function create() {
        var bg:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/menuBG.png');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg); 

        askToBind = new FlxTypedSpriteGroup<FlxSprite>();
        var askGraphic = new FlxSprite().makeGraphic(Std.int(FlxG.width/2),Std.int(FlxG.height/2), FlxColor.YELLOW);
        bindTxt = new FlxText(60, 20, 0, "Waiting for input\n (press esc or enter to stop binding)");
        bindTxt.setFormat(null, 24, FlxColor.BLACK);
        askToBind.add(askGraphic);
        askToBind.add(bindTxt);
        askToBind.visible = false;
		askToBind.screenCenter();
        grpBind = new FlxTypedGroup<Alphabet>();
        add(grpBind);

        for (i in 0...editableControls.length) {
			var coolText = editableControls[i][0] + ': ' + getControls(editableControls[i][1]);
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, coolText, true, false, false, null, null, null, true);
			songText.itemType = "Classic";
			songText.isMenuItem = true;
			songText.targetY = i;
			grpBind.add(songText);
        }
        add(askToBind);

		curKeyText = new FlxText(0, 0, 0, 'Currently editing 4 key controls\n ');
        curKeyText.setFormat('assets/fonts/funkin.otf', 52, FlxColor.BLACK);
		add(curKeyText);

        super.create();
    }
	function getControls(daControl) {
		var letters = daControl.map(function(key:FlxKey) {
			return FlxKey.toStringMap.get(key);
		}).join(",");
		return letters;
	}
	function changeSelection(change:Int = 0) {
		FlxG.sound.play('assets/sounds/custom_menu_sounds/'
			+ CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuScroll
			+ '/scrollMenu'
			+ TitleState.soundExt,
			0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpBind.length - 1;
		if (curSelected >= grpBind.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpBind.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		/*
			var dealphaedColors:Array<FlxColor> = [];
			for (color in (Reflect.field(charJson,songs[curSelected].songCharacter).colors : Array<String>)) {
				var newColor = FlxColor.fromString(color);
				newColor.alphaFloat = 0.5;
				dealphaedColors.push(newColor);
		}*/
		// remove(curOverlay);
		// curOverlay = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, dealphaedColors);
		// insert(1, curOverlay);
	}
	function changeKey(change:Int = 0) {
		curKey += change;

		if (curKey < 1)
			curKey = 9;
		if (curKey >= 10)
			curKey = 1;

		grpBind.clear();

		var newControls:Array<Array<Dynamic>> = [];
		switch (curKey) { //sorry for the hardcoded mess, I'm trying to find a better way to do this
			case 1:
				if (!Reflect.hasField(FlxG.save.data, "key1")) {
					Controls.saveDefaultKeys('1');
				}
				newControls = [['Ctrl A', FlxG.save.data.key1.ctrla]];
			case 2:
				if (!Reflect.hasField(FlxG.save.data, "key2")) {
					Controls.saveDefaultKeys('2');
				}
				newControls = [
					['Ctrl A', FlxG.save.data.key2.ctrla],
					['Ctrl B', FlxG.save.data.key2.ctrlb]
				];
			case 3:
				if (!Reflect.hasField(FlxG.save.data, "key3") || Reflect.hasField(FlxG.save.data.key3, "ctrle")) {
					Controls.saveDefaultKeys('3');
				}
				newControls = [
					['Ctrl A', FlxG.save.data.key3.ctrla],
					['Ctrl B', FlxG.save.data.key3.ctrlb],
					['Ctrl C', FlxG.save.data.key3.ctrlc]
				];
			case 4:
				newControls = [
					['Left', FlxG.save.data.keys.left],
					['Down', FlxG.save.data.keys.down],
					['Up', FlxG.save.data.keys.up],
					['Right', FlxG.save.data.keys.right]
				];
			case 5:
				if (!Reflect.hasField(FlxG.save.data, "key5")) {
					Controls.saveDefaultKeys('5');
				}
				newControls = [
					['Ctrl A', FlxG.save.data.key5.ctrla],
					['Ctrl B', FlxG.save.data.key5.ctrlb],
					['Ctrl C', FlxG.save.data.key5.ctrlc],
					['Ctrl D', FlxG.save.data.key5.ctrld],
					['Ctrl E', FlxG.save.data.key5.ctrle]
				];
			case 6:
				if (!Reflect.hasField(FlxG.save.data, "key6")) {
					Controls.saveDefaultKeys('6');
				}
				newControls = [
					['Ctrl A', FlxG.save.data.key6.ctrla],
					['Ctrl B', FlxG.save.data.key6.ctrlb],
					['Ctrl C', FlxG.save.data.key6.ctrlc],
					['Ctrl D', FlxG.save.data.key6.ctrld],
					['Ctrl E', FlxG.save.data.key6.ctrle],
					['Ctrl F', FlxG.save.data.key6.ctrlf]
				];
			case 7:
				if (!Reflect.hasField(FlxG.save.data, "key7")) {
					Controls.saveDefaultKeys('7');
				}
				newControls = [
					['Ctrl A', FlxG.save.data.key7.ctrla],
					['Ctrl B', FlxG.save.data.key7.ctrlb],
					['Ctrl C', FlxG.save.data.key7.ctrlc],
					['Ctrl D', FlxG.save.data.key7.ctrld],
					['Ctrl E', FlxG.save.data.key7.ctrle],
					['Ctrl F', FlxG.save.data.key7.ctrlf],
					['Ctrl G', FlxG.save.data.key7.ctrlg]
				];
			case 8:
				if (!Reflect.hasField(FlxG.save.data, "key8")) {
					Controls.saveDefaultKeys('8');
				}
				newControls = [
					['Ctrl A', FlxG.save.data.key8.ctrla],
					['Ctrl B', FlxG.save.data.key8.ctrlb],
					['Ctrl C', FlxG.save.data.key8.ctrlc],
					['Ctrl D', FlxG.save.data.key8.ctrld],
					['Ctrl E', FlxG.save.data.key8.ctrle],
					['Ctrl F', FlxG.save.data.key8.ctrlf],
					['Ctrl G', FlxG.save.data.key8.ctrlg],
					['Ctrl H', FlxG.save.data.key8.ctrlh]
				];
			case 9:
				if (!Reflect.hasField(FlxG.save.data, "key9")) {
					Controls.saveDefaultKeys('9');
				}
				newControls = [
					['Ctrl A', FlxG.save.data.key9.ctrla],
					['Ctrl B', FlxG.save.data.key9.ctrlb],
					['Ctrl C', FlxG.save.data.key9.ctrlc],
					['Ctrl D', FlxG.save.data.key9.ctrld],
					['Ctrl E', FlxG.save.data.key9.ctrle],
					['Ctrl F', FlxG.save.data.key9.ctrlf],
					['Ctrl G', FlxG.save.data.key9.ctrlg],
					['Ctrl H', FlxG.save.data.key9.ctrlh],
					['Ctrl I', FlxG.save.data.key9.ctrli]
				];
		}
		newControls.push(['Sync Vocals', FlxG.save.data.keys.syncVocals]);
		newControls.push(['Volume Up', FlxG.save.data.keys.volUp]);
		newControls.push(['Volume Down', FlxG.save.data.keys.volDown]);
		editableControls = newControls;

		 for (i in 0...editableControls.length) {
			var coolText = editableControls[i][0] + ': ' + getControls(editableControls[i][1]);
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, coolText, true, false, false, null, null, null, true);
			songText.itemType = "Classic";
			songText.isMenuItem = true;
			songText.targetY = i;
			grpBind.add(songText);
        }
		curKeyText.text = 'Currently editing ' + curKey + ' key controls\n ';
		changeSelection(curSelected * -1);
	}
	var currentKeys:Array<FlxKey> = [];
    override function update(elapsed:Float) {
        super.update(elapsed);
		curKeyText.setPosition(grpBind.members[0].x, grpBind.members[0].y - 80);
        if (!askingToBind) {
			if (controls.ACCEPT)
			{
				awaitingFor = curSelected;
				// SUS?
				askingToBind = true;
                askToBind.visible = true;
			}
            if (controls.UP_MENU) {
                changeSelection(-1);
            } else if (controls.DOWN_MENU) {
                changeSelection(1);
            } else if (controls.LEFT_MENU) {
				changeKey(-1);
			} else if (controls.RIGHT_MENU) {
				changeKey(1);
			}
            if (controls.BACK) {
                LoadingState.loadAndSwitchState(new SaveDataState());
            }
        } else {
			if (FlxG.keys.firstJustPressed() == ESCAPE || FlxG.keys.firstJustPressed() == ENTER) {
				if (currentKeys.length != 0) {
					switch (editableControls[awaitingFor][0]) {
						case 'Left': FlxG.save.data.keys.left = currentKeys;
						case 'Down': FlxG.save.data.keys.down = currentKeys;
						case 'Up': FlxG.save.data.keys.up = currentKeys;
						case 'Right': FlxG.save.data.keys.right = currentKeys;
						case 'Sync Vocals': FlxG.save.data.keys.syncVocals = currentKeys;
						case 'Volume Up': FlxG.save.data.keys.volUp = currentKeys;
						case 'Volume Down': FlxG.save.data.keys.volDown = currentKeys;
						case 'Ctrl A':
							switch (curKey) {
								case 1: FlxG.save.data.key1.ctrla = currentKeys;
								case 2: FlxG.save.data.key2.ctrla = currentKeys;
								case 3: FlxG.save.data.key3.ctrla = currentKeys;
								case 5: FlxG.save.data.key5.ctrla = currentKeys;
								case 6: FlxG.save.data.key6.ctrla = currentKeys;
								case 7: FlxG.save.data.key7.ctrla = currentKeys;
								case 8: FlxG.save.data.key8.ctrla = currentKeys;
								case 9: FlxG.save.data.key9.ctrla = currentKeys;
							}
						case 'Ctrl B':
							switch (curKey) {
								case 2: FlxG.save.data.key2.ctrlb = currentKeys;
								case 3: FlxG.save.data.key3.ctrlb = currentKeys;
								case 5: FlxG.save.data.key5.ctrlb = currentKeys;
								case 6: FlxG.save.data.key6.ctrlb = currentKeys;
								case 7: FlxG.save.data.key7.ctrlb = currentKeys;
								case 8: FlxG.save.data.key8.ctrlb = currentKeys;
								case 9: FlxG.save.data.key9.ctrlb = currentKeys;
							}
						case 'Ctrl C':
							switch (curKey) {
								case 3: FlxG.save.data.key3.ctrlc = currentKeys;
								case 5: FlxG.save.data.key5.ctrlc = currentKeys;
								case 6: FlxG.save.data.key6.ctrlc = currentKeys;
								case 7: FlxG.save.data.key7.ctrlc = currentKeys;
								case 8: FlxG.save.data.key8.ctrlc = currentKeys;
								case 9: FlxG.save.data.key9.ctrlc = currentKeys;
							}
						case 'Ctrl D':
							switch (curKey) {
								case 5: FlxG.save.data.key5.ctrld = currentKeys;
								case 6: FlxG.save.data.key6.ctrld = currentKeys;
								case 7: FlxG.save.data.key7.ctrld = currentKeys;
								case 8: FlxG.save.data.key8.ctrld = currentKeys;
								case 9: FlxG.save.data.key9.ctrld = currentKeys;
							}
						case 'Ctrl E':
							switch (curKey) {
								case 5: FlxG.save.data.key5.ctrle = currentKeys;
								case 6: FlxG.save.data.key6.ctrle = currentKeys;
								case 7: FlxG.save.data.key7.ctrle = currentKeys;
								case 8: FlxG.save.data.key8.ctrle = currentKeys;
								case 9: FlxG.save.data.key9.ctrle = currentKeys;
							}
						case 'Ctrl F':
							switch (curKey) {
								case 6: FlxG.save.data.key6.ctrlf = currentKeys;
								case 7: FlxG.save.data.key7.ctrlf = currentKeys;
								case 8: FlxG.save.data.key8.ctrlf = currentKeys;
								case 9: FlxG.save.data.key9.ctrlf = currentKeys;
							}
						case 'Ctrl G':
							switch (curKey) {
								case 7: FlxG.save.data.key7.ctrlg = currentKeys;
								case 8: FlxG.save.data.key8.ctrlg = currentKeys;
								case 9: FlxG.save.data.key9.ctrlg = currentKeys;
							}
						case 'Ctrl H':
							switch (curKey) {
								case 8: FlxG.save.data.key8.ctrlh = currentKeys;
								case 9: FlxG.save.data.key9.ctrlh = currentKeys;
							}
						case 'Ctrl I':
							FlxG.save.data.key9.ctrli = currentKeys;
					}
					editableControls[awaitingFor][1] = currentKeys;
					var coolText = editableControls[awaitingFor][0] + ': ' + getControls(editableControls[awaitingFor][1]);

					FlxG.sound.volumeUpKeys = FlxG.save.data.keys.volUp;
					FlxG.sound.volumeDownKeys = FlxG.save.data.keys.volDown;
					FlxG.save.flush();
					grpBind.members[awaitingFor] = new Alphabet(0, (70 * awaitingFor) + 30, coolText, true, false, false, null, null, null, true);
					grpBind.members[awaitingFor].itemType = "Classic";
					grpBind.members[awaitingFor].isMenuItem = true;
					grpBind.members[awaitingFor].targetY = 0;
				}
				
				
				// then reeset everything
				awaitingFor = -1;
				askingToBind = false;
				askToBind.visible= false;
				currentKeys = [];
			} else if (FlxG.keys.firstJustPressed() != -1) {
                // blush 
                // add the first key pressed
                currentKeys.push(FlxG.keys.firstJustPressed());
            }
        }
        
    }
}