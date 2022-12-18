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

		gf = new Character(-50, 0, 'gf');
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
			generateSongs();
			removeModeButtons();
			remove(selectMode);
			songsLoaded = true;
		});
		exportButton = new FlxUIButton(600, (FlxG.height / 2) - 100, "Export", function():Void {
			selectMode.text = 'Loading...';
			moduleMode = 'Export';
			generateSongs();
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
					generateSongs();
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
	var currentBoxNum = 0;
	override function update(elapsed:Float) {
		Conductor.songPosition += FlxG.elapsed * 1000;

		if (FlxG.keys.justPressed.G)
			syncVocals();

		if (FlxG.keys.justPressed.R && bf.animation.curAnim.name != 'firstDeath') {
			bf.playAnim('firstDeath', true);
			FlxG.sound.play('assets/sounds/fnf_loss_sfx' + TitleState.soundExt, 0.5);
		}

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
			LoadingState.loadAndSwitchState(new SaveDataState());

		switch(section) {
			case 0:
				currentBoxNum = songBoxes.length + 1;
			case 1:
				currentBoxNum = stageBoxes.length + 1;
			case 2:
				currentBoxNum = charBoxes.length + 1;
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
			gameFollow.setPosition(FlxG.width / 2 + FlxG.width * section, FlxG.height / 2);
		}
		

		if (songBoxes.length > 0) {
			for (i in 0...songBoxes.length) {
				songBoxes[i].background.y = 10 + (180 * i) + scrollNum[0];
				songBoxes[i].icon.y = songBoxes[i].background.y + 10;
				songBoxes[i].nameText.y = songBoxes[i].background.y + 10;
				songBoxes[i].importButton.y = songBoxes[i].background.y + 20;
				songBoxes[i].miscButton.y = songBoxes[i].background.y + 60;
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
						var info = CoolUtil.coolTextFile(haxe.io.Path.join([path, '/info.txt']));
						for (i in 0...info.length) {
							var data:Array<String> = info[i].split(':');
							switch(data[0]) { // this is probably unnecessary
								case 'songname':
									songName = data[1];
								case 'player2':
									iconP2 = data[1];
							}
						}
					} else {
						if (FileSystem.exists(haxe.io.Path.join([path, '../../data/' + song + '/' + song + '-hard.json']))) {
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
		} else if (moduleMode != 'Import') {
			var dataFolder = haxe.io.Path.join([daFolding, 'data/']);
			for (song in FileSystem.readDirectory(dataFolder)) {
				var path = haxe.io.Path.join([dataFolder, song]);
				if (sys.FileSystem.isDirectory(path)) {
					songs.push(path);
					var songName = 'null';
					var iconP2 = 'bf';
					if (FileSystem.exists(haxe.io.Path.join([path, '/' + song + '-hard.json']))) {
						var data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '/' + song + '-hard.json'])));
						songName = data.song;
						iconP2 = data.player2;
					} else if (FileSystem.exists(haxe.io.Path.join([path, '/' + song + '.json']))) {
						var data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '/' + song + '.json'])));
						songName = data.song;
						iconP2 = data.player2;
					} else if (FileSystem.exists(haxe.io.Path.join([path, '/' + song + '-easy.json']))) {
						var data = Song.parseJSONshit(File.getContent(haxe.io.Path.join([path, '/' + song + '-easy.json'])));
						songName = data.song;
						iconP2 = data.player2;
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
							importSong(daName);
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
				var charPath = 'assets/songs/';
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
			if (sys.FileSystem.exists(haxe.io.Path.join([path, '/' + song + '_Inst' + TitleState.soundExt]))) {
				inst = haxe.io.Path.join([path, '/' + song + "_Inst" + TitleState.soundExt]);
			} else if (sys.FileSystem.exists(haxe.io.Path.join([path, '/Inst' + TitleState.soundExt]))) {
				inst = haxe.io.Path.join([path, '/Inst' + TitleState.soundExt]);
			} else {
				inst = haxe.io.Path.join([path, '../../music/' + song + '_Inst' + TitleState.soundExt]);
			}
			if (sys.FileSystem.exists(haxe.io.Path.join([path, '/' + song + '_Voices' + TitleState.soundExt]))) {
				voices = haxe.io.Path.join([path, '/' + song + "_Voices" + TitleState.soundExt]);
			} else if (sys.FileSystem.exists(haxe.io.Path.join([path, '/Voices' + TitleState.soundExt]))) {
				voices = haxe.io.Path.join([path, '/Voices' + TitleState.soundExt]);
			} else {
				voices = haxe.io.Path.join([path, '../../music/' + song + '_Voices' + TitleState.soundExt]);
			}
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

	function convertToBool(theInfo:String) {
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
			if (FileSystem.exists("assets/module/import/songs/" + path)) {
				var songData:ModuleFunctions.SongImport = {
					name:'Bopeebo',
					p1:'bf',
					p2:'dad',
					gf:'gf',
					stage:'stage',
					ui:'normal',
					cutscene:'none',
					category:'Base Game',
					isHey:false,
					isCheer:false,
					isMoody:false,
					isSpooky:false,
					stageID:0,
					week:0,
					char:'dad',
					display:'null',
					inst:null,
					voices:null,
					dialog:null,
					modchart:null,
					diffFiles:[]
				};

				var infoText:Array<String> = CoolUtil.coolTextFile(basePath + '/info.txt');
				for (i in 0...infoText.length) {
					var data:Array<String> = infoText[i].split(':');
					switch(data[0]) {
						case 'songname':
							songData.name = data[1];
						case 'player1':
							songData.p1 = data[1];
						case 'player2':
							songData.p2 = data[1];
						case 'gf':
							songData.gf = data[1];
						case 'stage':
							songData.stage = data[1];
						case 'uiType':
							songData.ui = data[1];
						case 'cutsceneType':
							songData.cutscene = data[1];
						case 'category':
							songData.category = data[1];
						case 'isHey':
							songData.isHey = convertToBool(data[1]);
						case 'isCheer':
							songData.isCheer = convertToBool(data[1]);
						case 'isMoody':
							songData.isMoody = convertToBool(data[1]);
						case 'isSpooky':
							songData.isSpooky = convertToBool(data[1]);
						case 'stageID':
							songData.stageID = Std.int(Std.parseFloat(data[1]));
						case 'week':
							songData.week = Std.int(Std.parseFloat(data[1]));
						case 'char':
							songData.char = data[1];
						case 'display':
							songData.display = data[1];
					}
				}
	
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
			}
		} else {
			if (!FileSystem.exists('assets/songs/' + path))
				FileSystem.createDirectory('assets/songs/' + path);

			if (FileSystem.exists(haxe.io.Path.join([assets, 'songs/' + path + '/Inst.ogg']))) {
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
			}

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
	function importChar(path:String, rename = null) {
		
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