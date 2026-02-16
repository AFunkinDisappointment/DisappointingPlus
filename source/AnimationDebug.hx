package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.input.mouse.FlxMouse;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.ui.FlxButton;

class AnimationDebug extends FlxState {
	var UI_box:FlxUITabMenu;

	var bf:Character;
	//var bfHScript = FNFAssets.getText('assets/images/custom_chars/bf/char.xml');

	var dad:Character;
	//var dadHScript = FNFAssets.getText('assets/images/custom_chars/dad/char.xml');

	var gf:Character;
	
	var char:Character;
	var charIcon:HealthIcon;

	// Current Configurator
	var dragSelect:FlxUICheckBox;
	var selectedConfig:String = 'animoffsets';

	var animOffsetsCheck:FlxUICheckBox;
	var charOffsetsCheck:FlxUICheckBox;
	var followCamCheck:FlxUICheckBox;

	// char
	var enemyOffsetX:FlxUINumericStepper;
	var enemyOffsetY:FlxUINumericStepper;
	var playerOffsetX:FlxUINumericStepper;
	var playerOffsetY:FlxUINumericStepper;
	var gfOffsetX:FlxUINumericStepper;
	var gfOffsetY:FlxUINumericStepper;

	var colorSplotch:FlxSprite;
	var red:FlxUINumericStepper;
	var green:FlxUINumericStepper;
	var blue:FlxUINumericStepper;
	var redSlider:FlxSlider;
	var greenSlider:FlxSlider;
	var blueSlider:FlxSlider;

	// swapchars
	var bfText:FlxUIInputText;
	var dadText:FlxUIInputText;
	var gfText:FlxUIInputText;
	var loadCharButton:FlxButton;

	var textAnim:FlxText;
	var textCam:FlxText;
	var camOffsetText:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var daOtherAnim:String = 'bf';
	var daSexyAnim:String = 'gf';
	var camFollow:FlxObject;
	var GridSize:Int = 10;
	var GridWidth:Int = 200;
	var GridHeight:Int = 150;

	var dragMove:Bool = false;

	private var camBG:FlxCamera;
	private var camHUD:FlxCamera;

	public function new(daAnim:String = 'spooky', daOtherAnim:String = 'bf', daSexyAnim:String = 'gf') {
		super();
		this.daAnim = daAnim;
		//dadHScript = FNFAssets.getText('assets/images/custom_chars/' + daAnim + '/char.xml');
		this.daOtherAnim = daOtherAnim;
		//bfHScript = FNFAssets.getText('assets/images/custom_chars/' + daOtherAnim + '/char.xml');
		this.daSexyAnim = daSexyAnim;
	}

	override function create() {
	    camBG = new FlxCamera();
		camHUD = new FlxCamera();

		FlxG.cameras.reset(camHUD);

		FlxG.cameras.add(camBG, false);
		FlxG.cameras.remove(camHUD, false);
		FlxG.cameras.add(camHUD);
		camHUD.bgColor.alpha = 0;

		//FlxCamera.defaultCameras = [camHUD];

		FlxG.sound.music.stop();

		var gridBG:FlxSprite = FlxGridOverlay.create(GridSize, GridSize, GridSize * GridWidth, GridSize * GridHeight);
		gridBG.setPosition(-300, -200);
		//gridBG.setPosition((GridSize * GridWidth / 2 * -1) + 400, (GridSize * GridHeight / 2 * -1) + -100);
		gridBG.scrollFactor.set(0.8, 0.8);
		gridBG.cameras = [camBG];
		add(gridBG);

		createCharacters();

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		var tabs = [
			{name: "Char", label: 'Char'},
			{name: "Camera", label: 'Camera'},
			{name: "Anims", label: 'Anims'},
			{name: "Swap", label: 'Swap Chars'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(300, 400);
		UI_box.x = FlxG.width * (3 / 4);
		UI_box.y = 20;
		add(UI_box);

		animsTab();
		charTab();
		cameraTab();
		swapcharsTab();

		var dragMoveCheck = new FlxUICheckBox(UI_box.x, UI_box.y + 415, null, null, "Drag Move", 100);
		dragMoveCheck.callback = function() {
			dragMove = dragMoveCheck.checked;
		}
		add(dragMoveCheck);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		add(textAnim);

		genBoyOffsets();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		textCam = new FlxText(500, 16);
		textCam.size = 14;
		textCam.scrollFactor.set();
		add(textCam);

		camOffsetText = new FlxText(500, 46);
		camOffsetText.size = 14;
		camOffsetText.scrollFactor.set();
		add(camOffsetText);

		charIcon = new HealthIcon(dad.curCharacter);
		charIcon.scale.x = 0.6;
		charIcon.scale.y = 0.6;
		charIcon.updateHitbox();
		charIcon.setPosition(UI_box.x - charIcon.width - 10, UI_box.y -10);
		add(charIcon);

		FlxG.mouse.visible = true;
		camBG.follow(camFollow);

		super.create();
	}

	function newSelector(daSelector:FlxUICheckBox) {
		animOffsetsCheck.checked = false;
		charOffsetsCheck.checked = false;
		followCamCheck.checked = false;
		daSelector.checked = true;
	}

	function animsTab() {
		var tab_group_anims = new FlxUI(null, UI_box);
		tab_group_anims.name = "Anims";

		animOffsetsCheck = new FlxUICheckBox(10, 70, null, null, "Move Anim Offsets", 100);
		animOffsetsCheck.callback = function() {
			newSelector(animOffsetsCheck);
			selectedConfig = 'animoffsets';
		}

		var createShadowButton = new FlxButton(5, 105, "Char Shadow", function():Void {
		    createShadow();
		});

		var createDefaultShadowButton = new FlxButton(5, 125, "Default Shadow", function():Void {
		    createShadow(true);
		});

		var removeShadowButton = new FlxButton(5, 145, "Remove Shadow", function():Void {
			if (currentShadow != null)
				currentShadow.destroy();
		});

		tab_group_anims.add(animOffsetsCheck);

		tab_group_anims.add(createShadowButton);
		tab_group_anims.add(createDefaultShadowButton);
		tab_group_anims.add(removeShadowButton);
		UI_box.addGroup(tab_group_anims);
	}

	function cameraTab() {
		var tab_group_camera = new FlxUI(null, UI_box);
		tab_group_camera.name = "Camera";

		followCamCheck = new FlxUICheckBox(10, 10, null, null, "Move Follow Cam", 100);
		followCamCheck.callback = function() {
			newSelector(followCamCheck);
			selectedConfig = 'followcam';
		}

		tab_group_camera.add(followCamCheck);
		UI_box.addGroup(tab_group_camera);
	}

	function charTab() {
		//stageID = new FlxUINumericStepper(120, 180, 1, _song.stageID, 0, 999, 0);
		var tab_group_char = new FlxUI(null, UI_box);
		tab_group_char.name = "Char";

		var testicon = new HealthIcon(dad.curCharacter);

		colorSplotch = new FlxSprite(10, 250).makeGraphic(80, 100, 0xFFFFFFFF);

		red = new FlxUINumericStepper(10, 200, 1, 255, 0, 255, 0);
		green = new FlxUINumericStepper(10, 215, 1, 255, 0, 255, 0);
		blue = new FlxUINumericStepper(10, 230, 1, 255, 0, 255, 0);

		if (testicon.healthColors.length > 0) {
			red.value = testicon.healthColors[0].red;
			green.value = testicon.healthColors[0].green;
			blue.value = testicon.healthColors[0].blue;
		}

		redSlider = new FlxSlider(red, 'value', 100, 250, 0, 255, 150);
		redSlider.setTexts('Red', false);
		greenSlider = new FlxSlider(green, 'value', 100, 280, 0, 255, 150);
		greenSlider.setTexts('Green', false);
		blueSlider = new FlxSlider(blue, 'value', 100, 310, 0, 255, 150);
		blueSlider.setTexts('Blue', false);

		enemyOffsetX = new FlxUINumericStepper(10, 10, 10, 0);
		enemyOffsetY = new FlxUINumericStepper(70, 10, 10, 0);

		playerOffsetX = new FlxUINumericStepper(10, 25, 10, 0);
		playerOffsetY = new FlxUINumericStepper(70, 25, 10, 0);

		gfOffsetX = new FlxUINumericStepper(10, 40, 10, 0);
		gfOffsetY = new FlxUINumericStepper(70, 40, 10, 0);

		charOffsetsCheck = new FlxUICheckBox(150, 10, null, null, "Move Char Offsets", 100);
		charOffsetsCheck.callback = function() {
			newSelector(charOffsetsCheck);
			selectedConfig = 'charoffsets';
		}

		tab_group_char.add(enemyOffsetX);
		tab_group_char.add(enemyOffsetY);
		tab_group_char.add(playerOffsetX);
		tab_group_char.add(playerOffsetY);
		tab_group_char.add(gfOffsetX);
		tab_group_char.add(gfOffsetY);
		tab_group_char.add(charOffsetsCheck);

		tab_group_char.add(colorSplotch);
		tab_group_char.add(red);
		tab_group_char.add(green);
		tab_group_char.add(blue);
		tab_group_char.add(redSlider);
		tab_group_char.add(greenSlider);
		tab_group_char.add(blueSlider);
		UI_box.addGroup(tab_group_char);
	}

	function swapcharsTab() {
		var tab_group_swap = new FlxUI(null, UI_box);
		tab_group_swap.name = "Swap";

		dadText = new FlxUIInputText(10, 15, 70, 'dad');
		dadText.text = daAnim;

		bfText = new FlxUIInputText(10, 45, 70, 'bf');
		bfText.text = daOtherAnim;

		gfText = new FlxUIInputText(10, 75, 70, 'gf');
		gfText.text = daSexyAnim;

		loadCharButton = new FlxButton(5, 105, "Load Chars", function():Void {
		    daAnim = dadText.text;
			daOtherAnim = bfText.text;
			daSexyAnim = gfText.text;
		    createCharacters(true);
			updateCharInfo();
			charIcon.switchAnim(dad.curCharacter);
			curAnim = 0;
			animList = [];
			updateTexts();
			genBoyOffsets();
			char.playAnim(animList[curAnim]);
		});

		tab_group_swap.add(dadText);
		tab_group_swap.add(bfText);
		tab_group_swap.add(gfText);
		tab_group_swap.add(loadCharButton);

		UI_box.addGroup(tab_group_swap);
	}

	var currentShadow:Character;
	function createShadow(useDefault:Bool = false) {
		if (currentShadow != null)
			currentShadow.destroy();

		var charShadow = char.curCharacter;
		if (useDefault) {
			if (char == bf)
				charShadow = 'bf';
			else if (char == gf)
				charShadow = 'gf';
			else
				charShadow = 'dad';
		}

		var shadow = new Character(char.x, char.y, charShadow, char.isPlayer);
		shadow.alpha = 0.4;
		if (useDefault) {
			switch(charShadow) {
				case 'bf':
					shadow.setPosition(770, 450);
				case 'gf':
					shadow.setPosition(400, 130);
				case 'dad':
					shadow.setPosition(100, 100);
			}
			shadow.dance();
		} else
			shadow.playAnim(char.animation.curAnim.name);
		shadow.beNormal = false;
		shadow.cameras = [camBG];
		add(shadow);
		currentShadow = shadow;
	}

	function genBoyOffsets(pushList:Bool = true):Void {
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets) {
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = if (anim == char.animation.curAnim.name) 
					FlxColor.RED;
				else
					FlxColor.BLUE;
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function updateTexts():Void {
		dumbTexts.forEach(function(text:FlxText) {
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	function updateCharacter():Void {
		if (enemyOffsetX == null) return;
		char.enemyOffsetX = Std.int(enemyOffsetX.value);
		char.enemyOffsetY = Std.int(enemyOffsetY.value);
		char.playerOffsetX = Std.int(playerOffsetX.value);
		char.playerOffsetY = Std.int(playerOffsetY.value);
		char.gfOffsetX = Std.int(gfOffsetX.value);
		char.gfOffsetY = Std.int(gfOffsetY.value);

		if (char == dad) {
			char.x = 100 + char.enemyOffsetX;
			char.y = 100 + char.enemyOffsetY;
		} else if (char == gf) {
			char.x = 400 + char.gfOffsetX;
			char.y = 130 + char.gfOffsetY;
		} else {
			char.x = 770 + char.playerOffsetX;
			char.y = 450 + char.playerOffsetY;
		}
	}

	function updateCharInfo():Void {
		if (enemyOffsetX == null) return;
		enemyOffsetX.value = char.enemyOffsetX;
		enemyOffsetY.value = char.enemyOffsetY;
		playerOffsetX.value = char.playerOffsetX;
		playerOffsetY.value = char.playerOffsetY;
		gfOffsetX.value = char.gfOffsetX;
		gfOffsetY.value = char.gfOffsetY;

		var testicon = new HealthIcon(char.curCharacter);

		if (testicon.healthColors.length > 0) {
			red.value = testicon.healthColors[0].red;
			green.value = testicon.healthColors[0].green;
			blue.value = testicon.healthColors[0].blue;
		}
	}

	function createCharacters(replace:Bool = false) {
		if (replace) remove(gf);
		gf = new Character(400, 130, daSexyAnim);
		gf.debugMode = true;
		gf.x += gf.gfOffsetX;
		gf.y += gf.gfOffsetY;
		gf.cameras = [camBG];
		add(gf);

	    if (replace) remove(dad);
	    dad = new Character(100, 100, daAnim);
		dad.debugMode = true;
		dad.x += dad.enemyOffsetX;
		dad.y += dad.enemyOffsetY;
		dad.cameras = [camBG];
		add(dad);
		//dadHScript = FNFAssets.getText('assets/images/custom_chars/' + daAnim + '/char.xml');

		if (replace) remove(bf);
		bf = new Character(770, 450, daOtherAnim, true);
		bf.debugMode = true;
		bf.x += bf.playerOffsetX;
		bf.y += bf.playerOffsetY;
		bf.cameras = [camBG];
		add(bf);
		//bfHScript = FNFAssets.getText('assets/images/custom_chars/' + daOtherAnim + '/char.xml');

		char = dad;
		updateCharInfo();
	}

	function swapToChar(swapchar:Character) {
		updateTexts();
		char = swapchar;
		charIcon.switchAnim(swapchar.curCharacter);
		
		curAnim = 0;
		animList = [];
		updateTexts();
		genBoyOffsets();
		updateCharInfo();
		char.playAnim(animList[curAnim]);
	}

	override function update(elapsed:Float) {
		/*
		TODO

		make cam offset editing better

		 */
		textAnim.text = char.animation.curAnim.name;

		textCam.text = camFollow.x + ", " + camFollow.y;

		camOffsetText.text = ((bf.followCamX - camFollow.x) + ", " + (bf.followCamY - camFollow.y));
		// you're gonna need some math to fix these camera offsets!

		redSlider.color.red = Std.int(red.value);
		greenSlider.color.green = Std.int(green.value);
		blueSlider.color.blue = Std.int(blue.value);
		colorSplotch.color = FlxColor.fromRGB(Std.int(red.value), Std.int(green.value), Std.int(blue.value));

		if (!bfText.hasFocus && !dadText.hasFocus && !gfText.hasFocus) {
			if (FlxG.keys.justPressed.E)
				camBG.zoom += (0.25 * 0.25); // this could either make zooming better or break it entirely
			if (FlxG.keys.justPressed.Q)
				camBG.zoom -= (0.25 * 0.25);

			camBG.zoom += FlxG.mouse.wheel * 0.125;

			var holdShift = FlxG.keys.pressed.SHIFT;
			var holdCtrl = FlxG.keys.pressed.CONTROL;
			var multiplier = 1;
			if (holdShift)
				multiplier = 10;
			if (holdCtrl)
				multiplier = 100;

			if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L) {
				if (FlxG.keys.pressed.I)
					camFollow.velocity.y = -90 * multiplier;
				else if (FlxG.keys.pressed.K)
					camFollow.velocity.y = 90 * multiplier;
				else
					camFollow.velocity.y = 0;

				if (FlxG.keys.pressed.J)
					camFollow.velocity.x = -90 * multiplier;
				else if (FlxG.keys.pressed.L)
					camFollow.velocity.x = 90 * multiplier;
				else
					camFollow.velocity.x = 0;
			} else if (FlxG.keys.pressed.F)
				if (!holdShift)
					camFollow.setPosition(char.getMidpoint().x + char.followCamX, char.getMidpoint().y + char.followCamY);
				else
					camFollow.setPosition(char.getMidpoint().x, char.getMidpoint().y);
			else
				camFollow.velocity.set();

			if (FlxG.keys.justPressed.W)
				curAnim -= 1;

			if (FlxG.keys.justPressed.S)
				curAnim += 1;

			if (curAnim < 0)
				curAnim = animList.length - 1;

			if (curAnim >= animList.length)
				curAnim = 0;

			if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE) {
				char.playAnim(animList[curAnim], true);

				updateTexts();
				genBoyOffsets(false);
			}

			if (FlxG.keys.justPressed.G)
				bf.flipX = !bf.flipX;

			if (FlxG.keys.justPressed.H)
				dad.flipX = !dad.flipX;

			if (FlxG.keys.justPressed.Y) { //camera origin
				camFollow.x = 0;
				camFollow.y = 0;
			}

			if (FlxG.keys.justPressed.T) { // this is supposed to swap the character whose anims ur editing, i dont know why its not working
				//it didn't work because you did 'char == bf' instead of 'char = bf' bruh
		
				if (char == dad)
					swapToChar(bf);
				else if (char == bf)
					swapToChar(gf);
				else
					swapToChar(dad);
			}

			if (FlxG.keys.justPressed.ENTER) {
				FlxG.mouse.visible = false;
				if (holdShift)
					LoadingState.loadAndSwitchState(new FreeplayState());
				else
					LoadingState.loadAndSwitchState(new PlayState());
			}


			var upP = FlxG.keys.anyJustPressed([UP]);
			var rightP = FlxG.keys.anyJustPressed([RIGHT]);
			var downP = FlxG.keys.anyJustPressed([DOWN]);
			var leftP = FlxG.keys.anyJustPressed([LEFT]);

			if (upP || rightP || downP || leftP) {
				updateTexts();
				if (upP)
					char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
				if (downP)
					char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
				if (leftP)
					char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
				if (rightP)
					char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

				updateTexts();
				genBoyOffsets(false);
				char.playAnim(animList[curAnim]);
			}
			if (FlxG.mouse.justPressed && !holdCtrl && holdShift) {
				if (FlxG.mouse.overlaps(bf, camBG) && char != bf)
					swapToChar(bf);
				else if (FlxG.mouse.overlaps(dad, camBG) && char != dad)
					swapToChar(dad);
				else if (FlxG.mouse.overlaps(gf, camBG)  && char != gf)
					swapToChar(gf);
			}
			if (FlxG.mouse.pressed && (holdCtrl || dragMove)) { 
				switch(selectedConfig) {
					case 'animoffsets':
						char.animOffsets.get(animList[curAnim])[0] -= Math.round(FlxG.mouse.deltaX / camBG.zoom);
						char.animOffsets.get(animList[curAnim])[1] -= Math.round(FlxG.mouse.deltaY / camBG.zoom);
						updateTexts();
						genBoyOffsets(false);
						char.playAnim(animList[curAnim]);
					case 'charoffsets':
						if (char == dad) {
							enemyOffsetX.value += Math.round(FlxG.mouse.deltaX / camBG.zoom);
							enemyOffsetY.value += Math.round(FlxG.mouse.deltaY / camBG.zoom);
						} else if (char == gf) {
							gfOffsetX.value += Math.round(FlxG.mouse.deltaX / camBG.zoom);
							gfOffsetY.value += Math.round(FlxG.mouse.deltaY / camBG.zoom);
						} else {
							playerOffsetX.value += Math.round(FlxG.mouse.deltaX / camBG.zoom);
							playerOffsetY.value += Math.round(FlxG.mouse.deltaY / camBG.zoom);
						}
						updateCharacter();
					case 'followcam':
							
				}
			}
			if (FlxG.mouse.pressedMiddle) {
				camFollow.x -= FlxG.mouse.deltaX / camBG.zoom;
				camFollow.y -= FlxG.mouse.deltaY / camBG.zoom;
			}
		}

		updateCharacter();

		super.update(elapsed);
	}
}
