package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import DifficultyIcons;
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
import flixel.addons.ui.FlxUITabMenu;
import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import sys.FileSystem;
import flash.media.Sound;

#end
import lime.ui.FileDialog;
import lime.app.Event;
import haxe.Json;
import tjson.TJSON;
import Song.SwagSong;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import lime.ui.FileDialogType;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
using StringTools;
/*typedef TDifficulty = {
	var offset:Int;
	var anim:String;
	var name:String;
}
typedef TDifficulties = {
	var difficulties:Array<TDifficulty>;
	var defaultDiff:Int;
}*/

import Module.ImportBox;

class ModPlusCarryState extends MusicBeatState
{
	var addAssetsUi:FlxUI;
	var nameText:FlxUIInputText;
	var diffButtons:FlxTypedSpriteGroup<FlxUIButton>;
	var daSongButtons:FlxTypedSpriteGroup<FlxUIButton>;
	var assetsButton:FlxUIButton;
	var importButton:FlxButton;
	var coolDiffFiles:Array<String> = [];
	var assetsPath:String;
	var isMusic:FlxUICheckBox;
	var finishButton:FlxButton;
	var cancelButton:FlxUIButton;
	var coolFile:FileReference;
	var coolData:ByteArray;
	var epicFiles:Dynamic;
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	var importSongs:FlxUICheckBox;
	var importStages:FlxUICheckBox;
	var importCharacters:FlxUICheckBox;

	override function create()
	{
		addAssetsUi = new FlxUI();
		FlxG.mouse.visible = true;
		var bg:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
		add(bg);
		diffButtons = new FlxTypedSpriteGroup<FlxUIButton>(0,0);

		//var diffJson:TDifficulties = CoolUtil.parseJson(FNFAssets.getJson("assets/images/custom_difficulties/difficulties"));

		nameText = new FlxUIInputText(100,10,70,"bopeebo");

		isMusic = new FlxUICheckBox(250, 125, null, null, "Uses Songs Folder");

		importSongs = new FlxUICheckBox(100, 125, null, null, "Import Songs");
		importStages = new FlxUICheckBox(100, 150, null, null, "Import Stages");
		importCharacters = new FlxUICheckBox(100, 175, null, null, "Import Characters");

		/*for (i in 0...diffJson.difficulties.length) {
			var coolDiffButton = new FlxUIButton(10, 10 + (i * 50), diffJson.difficulties[i].name + " json", function():Void {
				var coolDialog = new FileDialog();
				coolDialog.browse(FileDialogType.OPEN);
				coolDialog.onSelect.add(function (path:String):Void {
					coolDiffFiles[i] = path;
				});
			});
			diffButtons.add(coolDiffButton);
		}*/
		finishButton = new FlxButton(FlxG.width - 170, FlxG.height - 50, "Finish", function():Void {
			//writeCharacters();
			LoadingState.loadAndSwitchState(new SaveDataState());
		});
		assetsButton = new FlxUIButton(190, 10, "Assets Folder", function():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN_DIRECTORY);
			coolDialog.onSelect.add(function (path:String):Void {
				assetsPath = path;
				/*for (song in FileSystem.readDirectory(songPath)) {
					songsLoaded.push(path);
					var info = CoolUtil.coolTextFile(haxe.io.Path.join([path, '/info.txt']));
					var songName = 'null';
					for (i in 0...info.length) {
						var data:Array<String> = info[i].split(':');
						switch(data[0]) { // this is probably unnecessary
							case 'songname':
								songName = data[1];
						}
					}
					var daBox:ImportBox = {
						background: null,
						icon: null,
						nameText: null,
						importButton: null,
						miscButton: null
					}; 
					daBox.nameText = new FlxText(600, 10 + (50 * songsLoaded.indexOf(path)), 100, songName);
					daBox.importButton = new FlxUIButton(600, daBox.nameText.y + 20, "Import Song", function():Void {
						checkFile(songName.toLowerCase(), 'song');
						remove(daBox.nameText);
						remove(daBox.importButton);
						songsLoaded.remove(path);
					});
					add(daBox.nameText);
					add(daBox.importButton);
				}*/
			});
		});
		importButton = new FlxButton(190, 50, "Import Songs", function():Void {
			importAssets();
		});
		cancelButton = new FlxUIButton(FlxG.width - 300, FlxG.height - 50, "Cancel", function():Void {
			// go back
			LoadingState.loadAndSwitchState(new SaveDataState());
		});

		//add(nameText);
		add(isMusic);
		add(diffButtons);
		add(assetsButton);
		add(importButton);

		add(importSongs);
		add(importStages);
		add(importCharacters);

		add(finishButton);
		add(cancelButton);
		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	function importAssets() {
		if (importSongs.checked) {
			var dataPath = haxe.io.Path.join([assetsPath, 'data/']);
			var songPath;
			if (isMusic.checked)
				songPath = haxe.io.Path.join([assetsPath, 'songs/']);
			else
				songPath = haxe.io.Path.join([assetsPath, 'music/']);
			trace('doing good');
			var daSongs = [];
			trace(dataPath);
			var coolSongListFile:Array<Dynamic> = CoolUtil.parseJson(haxe.io.Path.join([dataPath, 'freeplaySongJson.jsonc']));
			for (coolCategory in coolSongListFile) {
				var categorySongs:Array<Dynamic> = coolCategory.songs;
				for (coolSong in categorySongs) {
					daSongs.push({"category": coolCategory.name, "name": coolSong.name, "character": coolSong.character, "week": coolSong.week});
					//if (coolCategory.name == categoryText.text)
					//coolCategory.songs.push({"name": nameText.text, "character": p2Text.text, "week": 0});
				}
			}
			trace('songs makin');
			for (i in 0...daSongs.length) {
				var coolSongButton = new FlxUIButton(400, 10 + (i * 40), daSongs[i].name + " - add?", function():Void {
					//sussy
				});
				daSongButtons.add(coolSongButton);
				trace('button ' + i + ' added');
			}
			add(daSongButtons);
			var removeSongs = new FlxUIButton(350, 10, "Remove Song Options", function():Void {
				remove(daSongButtons);
			});
			trace('hehe done');
		}
		if (importStages.checked) {
			var stagePath:String = haxe.io.Path.join([assetsPath, 'images/custom_stages/']);
		}
		if (importCharacters.checked) {
			var charPath:String = haxe.io.Path.join([assetsPath, 'images/custom_chars/']);
		}
	}

	/*function writeCharacters() {
		// check to see if directory exists
		#if sys
		if (!FileSystem.exists('assets/data/'+nameText.text.toLowerCase())) {
			FileSystem.createDirectory('assets/data/'+nameText.text.toLowerCase());
		}
		for (i in 0...coolDiffFiles.length) {
			if (coolDiffFiles[i] != null) {
				var coolSong:Dynamic = CoolUtil.parseJson(File.getContent(coolDiffFiles[i]));
				var coolSongSong:Dynamic = coolSong.song;
				coolSongSong.song = nameText.text;
				coolSongSong.player1 = p1Text.text;
				coolSongSong.player2 = p2Text.text;
				coolSongSong.gf = gfText.text;
				coolSongSong.stage = stageText.text;
				coolSongSong.uiType = uiText.text;
				coolSongSong.cutsceneType = cutsceneText.text;
				coolSongSong.isMoody = isMoody.checked;
				coolSongSong.isHey = isHey.checked;
				coolSong.song = coolSongSong;

				File.saveContent('assets/data/'+nameText.text.toLowerCase()+'/'+nameText.text.toLowerCase()+DifficultyIcons.getEndingFP(i)+'.json',CoolUtil.stringifyJson(coolSong));
			}
		}
		// probably breaks on non oggs haha weeeeeeeeeee
		File.copy(instPath,'assets/music/'+nameText.text+'_Inst.ogg');
		if (voicePath != null) {
			File.copy(voicePath,'assets/music/'+nameText.text+'_Voices.ogg');
		}
		var coolSongListFile:Array<Dynamic> = CoolUtil.parseJson(FNFAssets.getJson('assets/data/freeplaySongJson'));
		var foundSomething:Bool = false;
		for (coolCategory in coolSongListFile) {
			if (coolCategory.name == categoryText.text) {
				foundSomething = true; 
				coolCategory.songs.push({"name": nameText.text, "character": p2Text.text, "week": 0});
				break;
			}
		}
		if (!foundSomething) {
			// must be a new category
			coolSongListFile.push({"name": categoryText.text, "songs": [nameText.text]});
		}
		File.saveContent('assets/data/freeplaySongJson.jsonc',CoolUtil.stringifyJson(coolSongListFile));
		#end
	}*/
}
