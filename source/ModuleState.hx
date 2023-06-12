package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIButton;
import flixel.ui.FlxSpriteButton;
import flixel.system.FlxSound;
import openfl.media.Sound;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxCamera;
import lime.system.System;
import lime.ui.FileDialog;
import lime.app.Event;
import haxe.Json;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import sys.FileSystem;
import flash.media.Sound;
#end
import tjson.TJSON;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import lime.ui.FileDialogType;
using StringTools;
import NewSongState.TDifficulty;
import NewSongState.TDifficulties;
import Song.SwagSong;

typedef ExistBox = {
	var background:FlxSprite;
	var nameText:FlxText;
	var replaceButton:FlxUIButton;
	var renameButton:FlxUIButton;
	var cancelButton:FlxUIButton;
	var nameRename:FlxUIInputText;
	var acceptRename:FlxUIButton;
	var cancelRename:FlxUIButton;
}

typedef ImportBox = {
	var background:FlxSprite;
	var icon:HealthIcon;
	var nameText:FlxText;
	var importButton:FlxUIButton;
	var miscButton:FlxUIButton;
}

class ModuleState extends MusicBeatState {
	var ModuleUi:FlxUI;
	var newChar:FlxUIButton;
	var newStage:FlxUIButton;
	var newSong:FlxUIButton;
	var newWeek:FlxUIButton;
	var importSongs:FlxUIInputText;
	var importSongsButton:FlxUIButton;
	var songVocals:FlxSound;
	var selectMode:FlxText;

	var songs:Array<String> = [];
	var characters:Array<String> = [];
	var stages:Array<String> = [];
	var weeks:Array<String> = [];

	var songBoxes:Array<ImportBox> = [];
	var charBoxes:Array<ImportBox> = [];
	var stageBoxes:Array<ImportBox> = [];
	var weekBoxes:Array<ImportBox> = [];

	var songsLoaded = false;
	var moduleMode:String = 'none';
	var transferPath:String = '';
	var importButton:FlxUIButton;
	var exportButton:FlxUIButton;
	var transferButton:FlxUIButton;

	var camFollow:FlxObject;
	var gameFollow:FlxObject;
	var scrollNum:Array<Float> = [0, 0, 0, 0];
	var section:Int = 0;

	var camHUD:FlxCamera;
	var camGame:FlxCamera;

	var bf:Character;
	var gf:Character;
	override function create() {
		ModuleUi = new FlxUI();
		FlxG.mouse.visible = true;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camHUD];

		var bg:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuBGBlue.png');
		bg.scrollFactor.set();
		bg.cameras = [camGame];
		add(bg);

		gf = new Character(-150, 0, 'gf');
		gf.beingControlled = true;
		gf.scrollFactor.set(0.95, 0.95);
		gf.cameras = [camGame];
		add(gf);

		bf = new Character(250, 350, 'bf', true);
		bf.beingControlled = true;
		bf.cameras = [camGame];
		add(bf);

		newChar = new FlxUIButton(10, 10, "New Char", function():Void {
			LoadingState.loadAndSwitchState(new NewCharacterState());
		});
		newStage = new FlxUIButton(10, 40, "New Stage", function():Void {
			LoadingState.loadAndSwitchState(new NewStageState());
		});
		newSong = new FlxUIButton(10, 70, "New Song", function():Void {
			LoadingState.loadAndSwitchState(new NewSongState());
		});
		newWeek = new FlxUIButton(10, 100, "New Week", function():Void {
			LoadingState.loadAndSwitchState(new NewWeekState());
		});

		selectMode = new FlxText(0, 200, FlxG.width, "Select Module Mode");
		selectMode.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		selectMode.alignment = 'center';

		importButton = new FlxUIButton(500, (FlxG.height / 2) - 100, "Import", function():Void {
			selectMode.text = 'Loading...';
			moduleMode = 'Import';
			generateStuff();
			removeModeButtons();
			remove(selectMode);
			songsLoaded = true;
		});
		exportButton = new FlxUIButton(600, (FlxG.height / 2) - 100, "Export", function():Void {
			selectMode.text = 'Loading...';
			moduleMode = 'Export';
			generateStuff();
			removeModeButtons();
			remove(selectMode);
			songsLoaded = true;
		});
		transferButton = new FlxUIButton(700, (FlxG.height / 2) - 100, "Transfer", function():Void {
			selectMode.text = 'Select assets folder of Modding Plus to transfer.';
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN_DIRECTORY);
			coolDialog.onSelect.add(function (path:String):Void {
				if (StringTools.endsWith(path, 'assets')) {
					selectMode.text = 'Loading...';
					moduleMode = 'Transfer';
					transferPath = path;
					generateStuff();
					removeModeButtons();
					remove(selectMode);
					songsLoaded = true;
				} else {
					selectMode.text = 'Incorrect File. Please try again.';
				}
			});
		});
		add(selectMode);
		add(importButton);
		add(exportButton);
		add(transferButton);
		add(newChar);
		add(newStage);
		add(newSong);
		add(newWeek);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(FlxG.width / 2, FlxG.height / 2);
		add(camFollow);

		camHUD.follow(camFollow, LOCKON, 0.04);
		camHUD.focusOn(camFollow.getPosition());

		gameFollow = new FlxObject(0, 0, 1, 1);
		gameFollow.setPosition(FlxG.width / 2, FlxG.height / 2);
		add(gameFollow);

		camGame.follow(gameFollow, LOCKON, 0.04);
		camGame.focusOn(gameFollow.getPosition());

		super.create();
	}
	function removeModeButtons() {
		remove(importButton);
		remove(exportButton);
		remove(transferButton);
	}
	function generateStuff() {
		generateSongs();
		generateChars();
		generateStages();
		generateWeeks();
		generateOther();
	}
	var currentBoxNum = 0;
	override function update(elapsed:Float) {
		Conductor.songPosition += FlxG.elapsed * 1000;

		if (FlxG.keys.justPressed.G)
			syncVocals();

		if (FlxG.keys.justPressed.R && bf.animation.curAnim.name != 'firstDeath') {
			bf.playAnim('firstDeath', true);
			FlxG.sound.play('assets/sounds/fnf_loss_sfx' + TitleState.soundExt, 0.5);
		}

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) {
			FlxG.mouse.visible = false;
			LoadingState.loadAndSwitchState(new SaveDataState());
		}

		switch(section) {
			case 0:
				currentBoxNum = songBoxes.length + 1;
			case 1:
				currentBoxNum = charBoxes.length + 1;
			case 2:
				currentBoxNum = stageBoxes.length + 1;
			case 3:
				currentBoxNum = weekBoxes.length + 1;
		}

		if (songsLoaded) {
			if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S) {
				scrollNum[section] -= 10;
				if (FlxG.keys.pressed.SHIFT)
					scrollNum[section] -= 15;
				if (scrollNum[section] < -180 * (currentBoxNum - 5) && currentBoxNum > 4)
					scrollNum[section] = -180 * (currentBoxNum - 5);
			} else if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W) {
				scrollNum[section] += 10;
				if (FlxG.keys.pressed.SHIFT)
					scrollNum[section] += 15;
				if (scrollNum[section] > 0)
					scrollNum[section] = 0;
			}

			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A) {
				if (section > -1) {
					section -= 1;
					FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);
				}
			} else if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D) {
				if (section < 4) {
					section += 1;
					FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);
				}
			}
		}

		camFollow.setPosition(FlxG.width / 2 + FlxG.width * section, FlxG.height / 2);
		if (section == -1) {
			gameFollow.setPosition(300, 375); // 301.5, 324 + 50
		} else {
			gameFollow.setPosition(FlxG.width / 2, FlxG.height / 2);
		}
		
		for (ibox in 0...3) {
			var curBox = switch(ibox) {
				case 0:
					songBoxes;
				case 1:
					charBoxes;
				case 2:
					stageBoxes;
				case 3:
					weekBoxes;
				default:
					[];
			}
			if (curBox.length > 0) {
				for (i in 0...curBox.length) {
					var daBox = curBox[i];
					daBox.background.y = 60 + (180 * i) + scrollNum[ibox];
					daBox.icon.y = daBox.background.y + 10;
					daBox.nameText.y = daBox.background.y + 10;
					daBox.importButton.x = daBox.background.x + daBox.background.width - 120 - camHUD.scroll.x;
					daBox.importButton.y = daBox.background.y + 20;
					daBox.miscButton.x = daBox.background.x + daBox.background.width - 120 - camHUD.scroll.x;
					daBox.miscButton.y = daBox.background.y + 60;

					if (daBox.background.y > FlxG.height || daBox.background.y + daBox.background.height < 0-FlxG.height 
						|| daBox.background.x - camHUD.scroll.x  > FlxG.width || daBox.background.x + daBox.background.width - camHUD.scroll.x < 0-FlxG.width) {
						// this feels like its overcomplicated
						daBox.background.active = false;
						daBox.background.visible = false;
						daBox.icon.active = false;
						daBox.icon.visible = false;
						daBox.nameText.active = false;
						daBox.nameText.visible = false;
						daBox.importButton.active = false;
						daBox.importButton.visible = false;
						daBox.miscButton.active = false;
						daBox.miscButton.visible = false;
					} else {
						daBox.background.active = true;
						daBox.icon.active = true;
						daBox.nameText.active = true;
						daBox.importButton.active = true;
						daBox.miscButton.active = true;

						daBox.background.visible = true;
						daBox.icon.visible = true;
						daBox.nameText.visible = true;
						daBox.importButton.visible = true;
						daBox.miscButton.visible = true;
					}
				}
			}
		}

		super.update(elapsed);
	}
	function generateSongs() {
		var daFolding:String = '';
		switch(moduleMode) {
			case 'Import':
				daFolding = 'assets/module/import/';
			case 'Export':
				daFolding = 'assets/';
			case 'Transfer':
				daFolding = transferPath;
		}
		if (FileSystem.exists(haxe.io.Path.join([daFolding, 'songs/']))) {
			var songFolder = haxe.io.Path.join([daFolding, 'songs/']);
			for (song in FileSystem.readDirectory(songFolder)) {
				var path = haxe.io.Path.join([songFolder, song]);
				if (moduleMode != 'Import' || (sys.FileSystem.isDirectory(path) && moduleMode == 'Import' && FileSystem.exists(haxe.io.Path.join([path, '/info.txt'])))) {
					songs.push(path);
					var songName = 'null';
					var iconP2 = 'bf';
					if (moduleMode == 'Import') {
						var info = ModuleFunctions.processInfo(haxe.io.Path.join([path, '/info.txt']));
						songName = info.get('songname');
						iconP2 = info.get('iconP2');
					} else {
						var data = null;
						if (FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-hard.json']))) {
							data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-hard.json'])));
						} else if (FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '.json']))) {
							data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '.json'])));
						} else if (FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-easy.json']))) {
							data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-easy.json'])));
						}
						if (data != null) {
							songName = data.song;
							iconP2 = data.player2;
						}
					}
					var daBox:ImportBox = {
						background: null,
						icon: null,
						nameText: null,
						importButton: null,
						miscButton: null
					}; 
					daBox.background = new FlxSprite(650, 10 + (180 * songs.indexOf(path))).loadGraphic('assets/images/plainbox.png');
					daBox.icon = new HealthIcon(iconP2);
					daBox.icon.x = daBox.background.x + 5;
					daBox.icon.scrollFactor.set(1, 1);
					daBox.nameText = new FlxText(daBox.background.x + 180, daBox.background.y, daBox.background.width - 240, songName);
					daBox.nameText.setFormat('assets/fonts/vcr.otf', 40, 0xFFFFFFFF, 'left');
					daBox.importButton = new FlxUIButton(daBox.background.x + daBox.background.width - 120, daBox.background.y + 20, moduleMode + " Song", function():Void {
						if (moduleMode != 'Export')
							checkFile(songName.toLowerCase(), 'song', song);
						else
							ModuleFunctions.exportSong(songName);
					});
					daBox.miscButton = new FlxUIButton(daBox.background.x + daBox.background.width - 120, daBox.background.y + 60, "Listen", function():Void {
						if (songPlaying != song)
							listenSong(path, song);
						else
							endSong();
					});
					add(daBox.background);
					add(daBox.icon);
					add(daBox.nameText);
					add(daBox.importButton);
					add(daBox.miscButton);
					songBoxes.push(daBox);
				}
			}
		} else if (moduleMode != 'Import') {
			var dataFolder = haxe.io.Path.join([daFolding, 'data/']);
			for (song in FileSystem.readDirectory(dataFolder)) {
				var path = haxe.io.Path.join([dataFolder, song]);
				if (sys.FileSystem.isDirectory(path)) {
					songs.push(path);
					var data = null;
					if (FileSystem.exists(haxe.io.Path.join([path, '/' + song + '-hard.json']))) {
						data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '/' + song + '-hard.json'])));
					} else if (FileSystem.exists(haxe.io.Path.join([path, '/' + song + '.json']))) {
						data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '/' + song + '.json'])));
					} else if (FileSystem.exists(haxe.io.Path.join([path, '/' + song + '-easy.json']))) {
						data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '/' + song + '-easy.json'])));
					}
					var songName = data.song;
					var iconP2 = data.player2;
					var daBox:ImportBox = {
						background: null,
						icon: null,
						nameText: null,
						importButton: null,
						miscButton: null
					}; 
					daBox.background = new FlxSprite(650, 10 + (180 * songs.indexOf(path))).loadGraphic('assets/images/plainbox.png');
					daBox.icon = new HealthIcon(iconP2);
					daBox.icon.x = daBox.background.x + 5;
					daBox.icon.scrollFactor.set(1, 1);
					daBox.nameText = new FlxText(daBox.background.x + 180, daBox.background.y, daBox.background.width - 240, songName);
					daBox.nameText.setFormat('assets/fonts/vcr.otf', 40, 0xFFFFFFFF, 'left');
					daBox.importButton = new FlxUIButton(daBox.background.x + daBox.background.width - 120, daBox.background.y + 20, moduleMode + " Song", function():Void {
						if (moduleMode != 'Export')
							checkFile(songName.toLowerCase(), 'song', daFolding);
						else
							ModuleFunctions.exportSong(songName);
					});
					daBox.miscButton = new FlxUIButton(daBox.background.x + daBox.background.width - 120, daBox.background.y + 60, "Listen", function():Void {
						if (songPlaying != song)
							listenSong(path, song);
						else
							endSong();
					});
					add(daBox.background);
					add(daBox.icon);
					add(daBox.nameText);
					add(daBox.importButton);
					add(daBox.miscButton);
					songBoxes.push(daBox);
				}
			}
		}

		var backdrop = new FlxSprite(650, 0).makeGraphic(FlxG.width - 650, 50, 0xFF808080);
		backdrop.alpha = 0.7;
		add(backdrop);

		var songText = new FlxText(650, 0, FlxG.width - 650, "Songs", 40);
		songText.alignment = 'center';
		add(songText);
	}
	function generateChars() {
		var daFolding:String = '';
		switch(moduleMode) {
			case 'Import':
				daFolding = 'assets/module/import/characters/';
			case 'Export':
				daFolding = 'assets/images/custom_chars/';
			case 'Transfer':
				daFolding =  haxe.io.Path.join([transferPath, 'images/custom_chars/']);
		}
		for (char in FileSystem.readDirectory(daFolding)) {
			var path = haxe.io.Path.join([daFolding, char]);
			if (sys.FileSystem.isDirectory(path)) {
				if (moduleMode != 'Import' || (moduleMode == 'Import' && FileSystem.exists(haxe.io.Path.join([path, '/info.txt'])))) {
					characters.push(path);
					var charName = 'null';
					var iconNum1 = 0;
					if (moduleMode == 'Import') {
						var info = ModuleFunctions.processInfo(haxe.io.Path.join([path, '/info.txt']));
						charName = info.get('charname');
						iconNum1 = Std.int(info.get('iconnums').split(',')[0]);
					} else {
						charName = char;
						/*if (FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-hard.json']))) {
							var data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-hard.json'])));
							songName = data.song;
							iconP2 = data.player2;
						} else if (FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '.json']))) {
							var data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '.json'])));
							songName = data.song;
							iconP2 = data.player2;
						} else if (FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-easy.json']))) {
							var data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-easy.json'])));
							songName = data.song;
							iconP2 = data.player2;
						}*/
					}
					var daBox:ImportBox = {
						background: null,
						icon: null,
						nameText: null,
						importButton: null,
						miscButton: null
					}; 
					daBox.background = new FlxSprite(650 + FlxG.width, 60 + (180 * characters.indexOf(path))).loadGraphic('assets/images/plainbox.png');
					daBox.icon = new HealthIcon(charName);
					daBox.icon.x = daBox.background.x + 5;
					daBox.icon.scrollFactor.set(1, 1);
					daBox.nameText = new FlxText(daBox.background.x + 180, daBox.background.y, daBox.background.width - 240, charName);
					daBox.nameText.setFormat('assets/fonts/vcr.otf', 40, 0xFFFFFFFF, 'left');
					daBox.importButton = new FlxUIButton(daBox.background.x + daBox.background.width - 120, daBox.background.y + 20, moduleMode + " Char", function():Void {
						if (moduleMode != 'Export')
							importChar(char);
						else {
							//make later
							//ModuleFunctions.exportChar(charName);
						}
					});
					daBox.miscButton = new FlxUIButton(daBox.background.x + daBox.background.width - 120, daBox.background.y + 60, "Load Character", function():Void {
						if (songPlaying != null)
							endSong();
						var newbf = new Character(250, 350, charName, true);
						newbf.beingControlled = true;
						newbf.cameras = [camGame];
						newbf.x += newbf.playerOffsetX;
						newbf.y += newbf.playerOffsetY;
						var oldbf = bf;
						remove(bf);
						bf = newbf;
						oldbf.destroy();
						add(bf);
					});
					add(daBox.background);
					add(daBox.icon);
					add(daBox.nameText);
					add(daBox.importButton);
					add(daBox.miscButton);
					charBoxes.push(daBox);
				}
			}
		}

		var backdrop = new FlxSprite(650 + FlxG.width, 0).makeGraphic(FlxG.width - 650, 50, 0xFF808080);
		backdrop.alpha = 0.7;
		add(backdrop);

		var charText = new FlxText(650 + FlxG.width, 0, FlxG.width - 650, "Characters", 40);
		charText.alignment = 'center';
		add(charText);
	}
	function generateStages() {
		var daFolding:String = '';
		switch(moduleMode) {
			case 'Import':
				daFolding = 'assets/module/import/stages/';
			case 'Export':
				daFolding = 'assets/images/custom_stages/';
			case 'Transfer':
				daFolding =  haxe.io.Path.join([transferPath, 'images/custom_stages/']);
		}
		for (stage in FileSystem.readDirectory(daFolding)) {
			var path = haxe.io.Path.join([daFolding, stage]);
			if (sys.FileSystem.isDirectory(path)) {
				if (moduleMode != 'Import' || (moduleMode == 'Import' && FileSystem.exists(haxe.io.Path.join([path, '/info.txt'])))) {
					stages.push(path);
					var stageName = 'null';
					if (moduleMode == 'Import') {
						var info = ModuleFunctions.processInfo(haxe.io.Path.join([path, '/info.txt']));
						stageName = info.get('stagename');
					} else {
						stageName = stage;
						/*if (FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-hard.json']))) {
							var data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-hard.json'])));
							songName = data.song;
							iconP2 = data.player2;
						} else if (FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '.json']))) {
							var data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '.json'])));
							songName = data.song;
							iconP2 = data.player2;
						} else if (FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-easy.json']))) {
							var data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-easy.json'])));
							songName = data.song;
							iconP2 = data.player2;
						}*/
					}
					var daBox:ImportBox = {
						background: null,
						icon: null,
						nameText: null,
						importButton: null,
						miscButton: null
					}; 
					daBox.background = new FlxSprite(650 + FlxG.width*2, 10 + (180 * stages.indexOf(path))).loadGraphic('assets/images/plainbox.png');
					daBox.icon = new HealthIcon('bf');
					daBox.icon.x = daBox.background.x + 5;
					daBox.icon.scrollFactor.set(1, 1);
					daBox.nameText = new FlxText(daBox.background.x + 180, daBox.background.y, daBox.background.width - 240, stageName);
					daBox.nameText.setFormat('assets/fonts/vcr.otf', 40, 0xFFFFFFFF, 'left');
					daBox.importButton = new FlxUIButton(daBox.background.x + daBox.background.width - 120, daBox.background.y + 20, moduleMode + " Stage", function():Void {
						if (moduleMode != 'Export')
							importStage(stage);
						else {
							//make later
							//ModuleFunctions.exportStage(stageName);
						}
					});
					daBox.miscButton = new FlxUIButton(daBox.background.x + daBox.background.width - 120, daBox.background.y + 60, "Nothing", function():Void {
						// just cuz
					});
					add(daBox.background);
					add(daBox.icon);
					add(daBox.nameText);
					add(daBox.importButton);
					add(daBox.miscButton);
					stageBoxes.push(daBox);
				}
			}
		}

		var backdrop = new FlxSprite(650 + FlxG.width*2, 0).makeGraphic(FlxG.width - 650, 50, 0xFF808080);
		backdrop.alpha = 0.7;
		add(backdrop);

		var stageText = new FlxText(650 + FlxG.width*2, 0, FlxG.width - 650, "Stages", 40);
		stageText.alignment = 'center';
		add(stageText);
	}
	function generateWeeks() {
		var backdrop = new FlxSprite(650 + FlxG.width*3, 0).makeGraphic(FlxG.width - 650, 50, 0xFF808080);
		backdrop.alpha = 0.7;
		add(backdrop);

		var weekText = new FlxText(650 + FlxG.width*3, 0, FlxG.width - 650, "Weeks", 40);
		weekText.alignment = 'center';
		add(weekText);
	}
	function generateOther() {
		var backdrop = new FlxSprite(650 + FlxG.width*4, 0).makeGraphic(FlxG.width - 650, 50, 0xFF808080);
		backdrop.alpha = 0.7;
		add(backdrop);

		var otherText = new FlxText(650 + FlxG.width*4, 0, FlxG.width - 650, "Other", 40);
		otherText.alignment = 'center';
		add(otherText);
	}
	function removeDaBox(box) {
		remove(box.background);
		remove(box.icon);
		remove(box.nameText);
		remove(box.importButton);
		remove(box.miscButton);
	}
	var fileNum = 0;
	function fileExists(daName:String, pathType:String) {
		var daBox:ExistBox = {
			background: null,
			nameText: null,
			replaceButton: null,
			renameButton: null,
			cancelButton: null,
			nameRename: null,
			acceptRename: null,
			cancelRename: null
		};
		//daBox.background = new FlxSprite(500, 10 + (130 * fileNum)).loadGraphic();
		daBox.nameText = new FlxText(500, 10 + (130 * fileNum), 70, daName + ' already exists! Select an option.');
		fileNum += 1;
		daBox.replaceButton = new FlxUIButton(daBox.nameText.x, daBox.nameText.y + 50, "Replace", function():Void {
			switch(pathType) {
				case 'song':
					importSong(daName);
				case 'char':
					importChar(daName);
			}
			remove(daBox.nameText);
			remove(daBox.replaceButton);
			remove(daBox.renameButton);
			remove(daBox.cancelButton);
			fileNum -= 1;
		});
		daBox.renameButton = new FlxUIButton(daBox.nameText.x, daBox.nameText.y + 80, "Rename", function():Void {
			remove(daBox.nameText);
			remove(daBox.replaceButton);
			remove(daBox.renameButton);
			remove(daBox.cancelButton);
			add(daBox.nameRename);
			add(daBox.acceptRename);
			add(daBox.cancelRename);
		});
		daBox.cancelButton = new FlxUIButton(daBox.nameText.x, daBox.nameText.y + 110, "Cancel", function():Void {
			remove(daBox.nameText);
			remove(daBox.replaceButton);
			remove(daBox.renameButton);
			remove(daBox.cancelButton);
			fileNum -= 1;
		});
		daBox.nameRename = new FlxUIInputText(daBox.nameText.x, daBox.nameText.y, 70, daName);
		daBox.acceptRename = new FlxUIButton(daBox.nameText.x, daBox.nameText.y + 30, "Accept", function():Void {
			switch(pathType) {
				case 'song':
					importSong(daName, daBox.nameRename.text);
				case 'char':
					importChar(daName, daBox.nameRename.text);
			}
			remove(daBox.nameRename);
			remove(daBox.acceptRename);
			remove(daBox.cancelRename);
			fileNum -= 1;
		});
		daBox.cancelRename = new FlxUIButton(daBox.nameText.x, daBox.nameText.y + 60, "Cancel", function():Void {
			remove(daBox.nameRename);
			remove(daBox.acceptRename);
			remove(daBox.cancelRename);
			add(daBox.nameText);
			add(daBox.replaceButton);
			add(daBox.renameButton);
			add(daBox.cancelButton);
		});
		add(daBox.nameText);
		add(daBox.replaceButton);
		add(daBox.renameButton);
		add(daBox.cancelButton);
	}
	function checkFile(daName:String, pathType:String, path:String) {
		switch(pathType) {
			case 'song':
				var songPath = 'assets/songs/';
				var dataPath = 'assets/data/';
				if (moduleMode == 'Import') {
					if (FileSystem.exists('assets/module/import/songs/' + daName + '/info.txt')) {
						if (FileSystem.exists(songPath + daName) || FileSystem.exists(dataPath + daName)) {
							var daSongName = 'Null';
							var infoText:Array<String> = CoolUtil.coolTextFile('assets/module/import/songs/' + daName + '/info.txt');
							for (i in 0...infoText.length) {
								var data:Array<String> = infoText[i].split(':');
								switch(data[0]) {
									case 'songname':
										daSongName = data[1];
								}
							}
							fileExists(daName, 'song');
						} else {
							importSong(path);
						}
					}
				} else {
					if (FileSystem.exists(songPath + daName) || FileSystem.exists(dataPath + daName)) {
						fileExists(daName, 'song');
					} else {
						importSong(daName, null, path);
					}
				}
			case 'week':
			
			case 'stage':

			case 'char':
				var charPath = 'assets/images/custom_chars/';
				if (FileSystem.exists(charPath + daName)) {
					var daCharName = 'Null';
					var infoText:Array<String> = CoolUtil.coolTextFile('assets/module/import/characters/' + daName + '/info.txt');
					for (i in 0...infoText.length) {
						var data:Array<String> = infoText[i].split(':');
						switch(data[0]) {
							case 'charname':
								daCharName = data[1];
						}
					}
					fileExists(daName, 'char');
				} else {
					importChar(daName);
				}
		}
	}
	var songPlaying = null;
	function listenSong(path:String, song:String) {
		songPlaying = song;
		FlxG.sound.music.stop();
		if (songVocals != null)
			songVocals.stop();
		var inst:String = '';
		var voices:String = '';
		var songJson:SwagSong = null;
		trace('about to load songs');
		if (moduleMode == 'Import') {
			inst = haxe.io.Path.join([path, '/Inst.ogg']);
			voices = haxe.io.Path.join([path, '/Voices.ogg']);
			for (i in 0...2) { // im too lazy to find the proper function for difficulty lol
				switch (i) {
					case 2:
						if (sys.FileSystem.exists(haxe.io.Path.join([path, '/easy.json']))) {
							songJson = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '/easy.json'])));
							break;
						}
					case 1:
						if (sys.FileSystem.exists(haxe.io.Path.join([path, '/normal.json']))) {
							songJson = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '/normal.json'])));
							break;
						}
					case 0:
						if (sys.FileSystem.exists(haxe.io.Path.join([path, '/hard.json']))) {
							songJson = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '/hard.json'])));
							break;
						}
				}
			}
		} else {
			inst = CoolUtil.getSongFile(song, path);
			voices = CoolUtil.getSongFile(song, path, false);
			for (i in 0...2) { // im too lazy to find the proper function for difficulty lol
				switch (i) {
					case 2:
						if (sys.FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-easy.json']))) {
							songJson = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-easy.json'])));
							break;
						}
					case 1:
						if (sys.FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '.json']))) {
							songJson = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '.json'])));
							break;
						}
					case 0:
						if (sys.FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-hard.json']))) {
							songJson = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-hard.json'])));
							break;
						}
				}
			}
		}
		trace('song loaded');
		var songInst = Sound.fromFile(inst);
		File.copy(voices, 'assets/module/tempVocals.ogg'); //this kills me to do
		var vocalSound = Sound.fromFile('assets/module/tempVocals.ogg');
		songVocals = new FlxSound().loadEmbedded(vocalSound);
		FlxG.sound.list.add(songVocals);
		FlxG.sound.playMusic(songInst);
		songVocals.play();
		Conductor.mapBPMChanges(songJson);
		Conductor.changeBPM(songJson.bpm);
		syncVocals();

		FlxG.sound.music.onComplete = endSong;

		bf.loadMappedAnims(songJson, 'bf');
		gf.loadMappedAnims(songJson, 'dad');
	}
	var musicJson:Dynamic = CoolUtil.parseJson(FNFAssets.getText("assets/music/custom_menu_music/custom_menu_music.json"));
	function endSong() {
		songPlaying = null;
		FlxG.sound.music.stop();
		//songVocals.stop();
		songVocals.pause();
		bf.animationNotes = [];
		gf.animationNotes = [];
		Conductor.changeBPM(125);
		FlxG.sound.playMusic(FNFAssets.getSound('assets/music/custom_menu_music/'
			+ musicJson.Options
			+ '/options'
			+ TitleState.soundExt));
	}
	override function stepHit() {
		super.stepHit();
		if (songVocals != null) {
			if (songVocals.time > Conductor.songPosition + 10 || songVocals.time < Conductor.songPosition - 10) {
				syncVocals();
			}
		}
	}

	override function beatHit() {
		super.beatHit();
		if ((!bf.animation.curAnim.name.startsWith("sing") && bf.animation.curAnim.name != 'firstDeath') || bf.animation.finished)
			bf.dance();
		if (!gf.animation.curAnim.name.startsWith("sing") || gf.animation.finished)
			gf.dance();
	}

	function convertToBool(theInfo:String) { //this is stupid but i don't know the proper function
		var daBool:Bool = false;
		switch(theInfo) {
			case 'false':
				daBool = false;
			case 'true':
				daBool = true;
		}
		return daBool;
	}

	function importSong(path:String, rename = null, ?assets:String) {
		#if sys
		if (moduleMode == 'Import') {
			var basePath = "assets/module/import/songs/" + path;

			var info = ModuleFunctions.processInfo(basePath + '/info.txt');

			var songData:ModuleFunctions.SongImport = {
				name: info.get('songname'),
				p1: info.get('player1'),
				p2: info.get('player2'),
				gf: info.get('gf'),
				stage: info.get('stage'),
				ui: info.get('uiType'),
				cutscene: info.get('cutsceneType'),
				category: info.get('category'),
				isHey: convertToBool(info.get('isHey')),
				isCheer: convertToBool(info.get('isCheer')),
				isMoody: convertToBool(info.get('isMoody')),
				isSpooky: convertToBool(info.get('isSpooky')),
				stageID: Std.int(Std.parseFloat(info.get('stageID'))),
				week: Std.int(Std.parseFloat(info.get('week'))),
				char: info.get('char'),
				display: info.get('display'),
				inst:null,
				voices:null,
				dialog:null,
				modchart:null,
				diffFiles:[]
			};
	
			if (rename != null)
				songData.name = rename;

			songData.inst = basePath + '/Inst.ogg';
			if (FileSystem.exists(basePath + '/Voices.ogg'))
				songData.voices = basePath + '/Voices.ogg';
			if (FileSystem.exists(basePath + '/dialog.txt'))
				songData.dialog = basePath + '/dialog.txt';
			if (FileSystem.exists(basePath + '/modchart.hscript'))
				songData.modchart = basePath + '/modchart.hscript';

			var coolDiffFiles:Array<String> = [];
			var diffJson:TDifficulties = CoolUtil.parseJson(Assets.getText("assets/images/custom_difficulties/difficulties.json"));
			for (i in 0...diffJson.difficulties.length) {
				if (FileSystem.exists(basePath + '/' + diffJson.difficulties[i].name + '.json'))
					coolDiffFiles[i] = basePath + '/' + diffJson.difficulties[i].name + '.json';
			}
			songData.diffFiles = coolDiffFiles;
			ModuleFunctions.importSong(songData);
		} else {
			if (!FileSystem.exists('assets/songs/' + path))
				FileSystem.createDirectory('assets/songs/' + path);

			File.copy(CoolUtil.getSongFile(path, haxe.io.Path.join([assets, 'songs/'])), 'assets/songs/' + path + '/Inst.ogg');
			File.copy(CoolUtil.getSongFile(path, haxe.io.Path.join([assets, 'songs/']), false), 'assets/songs/' + path + '/Voices.ogg');
			
			/*if (FileSystem.exists(haxe.io.Path.join([assets, 'songs/' + path + '/Inst.ogg']))) {
				File.copy(haxe.io.Path.join([assets, 'songs/' + path + '/Inst.ogg']), 'assets/songs/' + path + '/Inst.ogg');
			} else if (FileSystem.exists(haxe.io.Path.join([assets, 'songs/' + path + '/' + path + '_Inst.ogg']))) {
				File.copy(haxe.io.Path.join([assets, 'songs/' + path + '/' + path + '_Inst.ogg']), 'assets/songs/' + path + '/Inst.ogg');
			} else {
				File.copy(haxe.io.Path.join([assets, 'music/' + path + '_Inst.ogg']), 'assets/songs/' + path + '/Inst.ogg');
			}

			if (FileSystem.exists(haxe.io.Path.join([assets, 'songs/' + path + '/Voices.ogg']))) {
				File.copy(haxe.io.Path.join([assets, 'songs/' + path + '/Voices.ogg']), 'assets/songs/' + path + '/Voices.ogg');
			} else if (FileSystem.exists(haxe.io.Path.join([assets, 'songs/' + path + '/' + path + '_Voices.ogg']))) {
				File.copy(haxe.io.Path.join([assets, 'songs/' + path + '/' + path + '_Voices.ogg']), 'assets/songs/' + path + '/Voices.ogg');
			} else {
				File.copy(haxe.io.Path.join([assets, 'music/' + path + '_Voices.ogg']), 'assets/songs/' + path + '/Voices.ogg');
			}*/

			if (!FileSystem.exists('assets/data/' + path))
				FileSystem.createDirectory('assets/data/' + path);
			if (FileSystem.exists(haxe.io.Path.join([assets, 'data/' + path + '/dialog.txt'])))
				File.copy(haxe.io.Path.join([assets, 'data/' + path + '/dialog.txt']), 'assets/data/' + path + '/dialog.txt');
			if (FileSystem.exists(haxe.io.Path.join([assets, 'data/' + path + '/modchart.hscript'])))
				File.copy(haxe.io.Path.join([assets, 'data/' + path + '/modchart.hscript']), 'assets/data/' + path + '/modchart.hscript');

			var diffJson:TDifficulties = CoolUtil.parseJson(Assets.getText("assets/images/custom_difficulties/difficulties.json"));
			for (i in 0...diffJson.difficulties.length) {
				switch(diffJson.difficulties[i].name) {
					case 'normal':
						if (FileSystem.exists(haxe.io.Path.join([assets, 'data/' + path + '/' + path + '.json'])))
							File.copy(haxe.io.Path.join([assets, 'data/' + path + '/' + path + '.json']), 'assets/data/' + path + '/' + path + '.json');
					default:
						if (FileSystem.exists(haxe.io.Path.join([assets, 'data/' + path + '/' + path + '-' + diffJson.difficulties[i].name + '.json'])))
							File.copy(haxe.io.Path.join([assets, 'data/' + path + '/' + path + '-' + diffJson.difficulties[i].name + '.json']), 'assets/data/' + path + '/' + path + '-' + diffJson.difficulties[i].name + '.json');
				}
			}
		}
		#end
	}
	function importChar(path:String, rename = null, ?assets:String) {
		#if sys
		if (moduleMode == 'Import') {
			var basePath = "assets/module/import/characters/" + path;

			var info = ModuleFunctions.processInfo(basePath + '/info.txt');

			var numArray:Array<Float> = [];

			var theNums = info.get('iconnums').split(',');
			for (i in 0...theNums.length)
				numArray.push(Std.parseFloat(theNums[i]));

			var assets = {
				"charpng": null,
				"charxml": null,
				"deadpng": null,
				"deadxml": null,
				"crazyxml": null,
				"crazypng": null,
				"icons": null
			};

			assets.charpng = basePath + '/char.png';
			if (FileSystem.exists(basePath + '/char.txt'))
				assets.charxml = basePath + '/char.txt';
			else
				assets.charxml = basePath + '/char.xml';

			if (FileSystem.exists(basePath + '/dead.png'))
				assets.deadpng = basePath + '/dead.png';
			if (FileSystem.exists(basePath + '/dead.xml'))
				assets.deadxml = basePath + '/dead.xml';

			if (FileSystem.exists(basePath + '/crazy.png'))
				assets.crazypng = basePath + '/crazy.png';
			if (FileSystem.exists(basePath + '/crazy.xml'))
				assets.crazyxml = basePath + '/crazy.xml';

			assets.icons = basePath + '/icons.png';

			var likePath = null;

			if (FileSystem.exists(basePath + '/like.hscript'))
				likePath = basePath + '/like.hscript';

			var charData:ModuleFunctions.CharImport = {
				name: info.get('charname'),
				like: info.get('like'),
				likePath: likePath,
				assets: assets,
				iconNums: numArray,
				colors: info.get('colors')
			};

			ModuleFunctions.importChar(charData);
		} else {
			var basePath = haxe.io.Path.join([assets, 'images/custom_chars/' + path]);

			/*if (FileSystem.exists(haxe.io.Path.join([assets, 'songs/' + path + '/Inst.ogg']))) {
				File.copy(haxe.io.Path.join([assets, 'songs/' + path + '/Inst.ogg']), 'assets/songs/' + path + '/Inst.ogg');
			*/
		}
		#end
	}
	function importStage(path:String, rename = null) {
		
	}
	function importWeek(path:String, rename = null) {
		
	}
	function syncVocals() {
		if (songPlaying != null) {
			songVocals.pause();

			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time;
			songVocals.time = Conductor.songPosition;
			songVocals.play();
		}
	}
}