package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
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
import flixel.sound.FlxSound;
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
import Section.SwagSection;

class NewModule extends MusicBeatState
{
	var transferButton:FlxUIButton;
	var charTextField:FlxUIInputText;

	var newName:FlxUIInputText;
	var likeness:FlxUIInputText;
	var finishTransfer:FlxUIButton;

	var metadataPath:String;
	var metadataButton:FlxUIButton;
	var metadataTxt:FlxText;
	var chartPath:String;
	var chartButton:FlxUIButton;
	var chartTxt:FlxText;
	var goodtobadChartButton:FlxUIButton;
	var codetobadChartButton:FlxUIButton;
	var clearChartsButton:FlxUIButton;
	var chartedButtons:Array<FlxUIButton> = [];
	var chartdiff:FlxUIInputText;

	var curChar:ModuleFunctions.CharCreation;

	public function new():Void {
		super();
	}

	override function create() {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic('assets/images/pauseAlt/pauseBG.png');
		add(bg);

		// Psych to Modding Plus Chars

		newName = new FlxUIInputText(500, 100, 70, 'name', 8);
		newName.visible = false;
		add(newName);

		likeness = new FlxUIInputText(500, 120, 70, 'like', 8);
		likeness.visible = false;
		add(likeness);

		finishTransfer = new FlxUIButton(500, 150, "Confirm", function():Void {
			curChar.name = newName.text;
			curChar.like = likeness.text;
			ModuleFunctions.psychToDisChar(curChar);
			curChar = null;
		});
		finishTransfer.visible = false;
		add(finishTransfer);

		transferButton = new FlxUIButton(500, (FlxG.height / 2) - 100, "Transfer", function():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN_DIRECTORY);
			coolDialog.onSelect.add(function (path:String):Void {
				getAllChars(path);
			});
		});
		add(transferButton);

		// Modern to old FNF charts

		chartButton = new FlxUIButton(700, (FlxG.height / 2) - 100, "Chart Json", function():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				chartPath = path;
			});
		});
		add(chartButton);

		chartTxt = new FlxText(chartButton.x + 110, chartButton.y, 0, "Select Chart Json", 12);
		chartTxt.borderStyle = OUTLINE;
		add(chartTxt);

		metadataButton = new FlxUIButton(700, (FlxG.height / 2) - 50, "Metadata Json", function():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				metadataPath = path;
			});
		});
		add(metadataButton);

		metadataTxt = new FlxText(metadataButton.x + 110, metadataButton.y, 0, "Select Metadata Json", 12);
		metadataTxt.borderStyle = OUTLINE;
		add(metadataTxt);

		goodtobadChartButton = new FlxUIButton(700, (FlxG.height / 2), "Goodtobad Chart", function():Void {
			if (metadataPath != null && chartPath != null)
				portNewFNFSong();
		});
		add(goodtobadChartButton);

		codetobadChartButton = new FlxUIButton(600, (FlxG.height / 2), "Codetobad Chart", function():Void {
			if (metadataPath != null && chartPath != null)
				portCodenameSong();
		});
		add(codetobadChartButton);

		clearChartsButton = new FlxUIButton(700, (FlxG.height / 2) + 50, "Clear Charts", function():Void {
			chartPath = null;
			metadataPath = null;
			for (button in chartedButtons) {
				button.destroy();
			}
			chartedButtons = [];
			songStorage = [];
		});
		add(clearChartsButton);

		super.create();
	}

	var chars:Array<Array<Dynamic>> = [];
	function getAllChars(path:String) {
		if (chars.length >= 1) {
			for (char in chars) {
				char[0].destroy();
				char[1].destroy();
			}
			chars = [];
		}
		var charPath = haxe.io.Path.join([path, 'characters/']);
		for (char in FileSystem.readDirectory(charPath)) {
			var charName = char.split('.json')[0];
			var nameText = new FlxText(50, 10 + 40*chars.length, 0, charName);
			nameText.setFormat('assets/fonts/vcr.otf', 40, 0xFFFFFFFF, 'left');
			add(nameText);
			var importButton;
			importButton = new FlxUIButton(50 + nameText.width, nameText.y, "Import", function():Void {
				curChar = ModuleFunctions.psychCharDecode(path, charName);
				newName.text = charName;
				likeness.text = charName;
				nameText.text = "~Imported!~";
				remove(importButton);
			});
			add(importButton);
			chars.push([nameText, importButton]);
		}
	}

	var scroll:Float = 0;
	override function update(elapsed:Float) {
		chartTxt.text = chartPath != null ? chartPath : 'Select Chart Path';
		metadataTxt.text = metadataPath != null ? metadataPath : 'Select Metadata Path';

		if (FlxG.keys.pressed.DOWN)
			scroll -= 1;

		if (FlxG.keys.pressed.UP)
			scroll += 1;

		for (i in 0...chars.length) {
			chars[i][0].y = 10 + 40*i + scroll;
			if (chars[i][1] != null)
				chars[i][1].y = chars[i][0].y;
		}

		if (curChar != null) {
			newName.visible = true;
			likeness.visible = true;
			finishTransfer.visible = true;
		} else {
			newName.visible = false;
			likeness.visible = false;
			finishTransfer.visible = false;
		}

		if ((FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) && !newName.hasFocus && !likeness.hasFocus) {
			FlxG.mouse.visible = false;
			LoadingState.loadAndSwitchState(new SaveDataState());
		}

		super.update(elapsed);
	}

	var songStorage:Array<Array<Dynamic>> = [];

	function portNewFNFSong() {
		var metadata = CoolUtil.parseJson(File.getContent(metadataPath));

		var basesong:SwagSong = {
			song: 'Test',
			notes: [],
			bpm: 150,
			needsVoices: true,
			player1: 'bf',
			player2: 'dad',
			stage: 'stage',
			gf: 'gf',
			isHey: false,
			isCheer: false,
			isSpooky: false,
			isMoody: false,
			speed: 1,
			cutsceneType: "none",
			uiType: 'normal',
			forceLayout: 'none',
			preferredNoteAmount: 4,
			forceJudgements: false,
			convertMineToNuke: false,
			mania: 0,
			stageID: 0
		};

		basesong.song = metadata.songName;
		basesong.bpm = metadata.timeChanges[0].bpm;

		var playdata = metadata.playData;
		var chars = playdata.characters;
		basesong.player1 = chars.player;
		basesong.player2 = chars.opponent;
		basesong.gf = chars.girlfriend;
		basesong.stage = playdata.stage;

		var difficulties:Array<String> = playdata.difficulties;
		difficulties.push('picospeaker');

		var charts = CoolUtil.parseJson(File.getContent(chartPath));

		for (diff in difficulties) {
			if (Reflect.field(charts.notes, diff) == null || Reflect.field(charts.notes, diff).length == 0)
				continue;

			var newsong:SwagSong = {
				song: basesong.song,
				notes: [],
				bpm: basesong.bpm,
				needsVoices: true,
				player1: basesong.player1,
				player2: basesong.player2,
				stage: basesong.stage,
				gf: basesong.gf,
				isHey: false,
				isCheer: false,
				isSpooky: false,
				isMoody: false,
				speed: 1,
				cutsceneType: "none",
				uiType: 'normal',
				forceLayout: 'none',
				preferredNoteAmount: 4,
				forceJudgements: false,
				convertMineToNuke: false,
				mania: 0,
				stageID: 0
			};

			newsong.speed = Reflect.field(charts.scrollSpeed, diff) != null ? Reflect.field(charts.scrollSpeed, diff) : 1;
				
			newsong.notes = [];
			var notepacket:Array<Dynamic> = Reflect.field(charts.notes, diff);
			notepacket.sort(sortByShit);

			var sillycrochet = (60 / newsong.bpm) * 4000; // sections in milliseconds
			var funnySections = Math.ceil(notepacket[notepacket.length - 1].t / sillycrochet); // the amount of sections (rounded up)
			for (i in 0...funnySections + 5) {
				var curSection:SwagSection = {
					lengthInSteps: 16,
					mustHitSection: true,
					sectionNotes: [],
					bpm: newsong.bpm,
					changeBPM: false,
					altAnim: false,
					altAnimNum: 0
				};
				newsong.notes.push(curSection);
			}

			for (note in notepacket) {
				var secNum = Math.floor(note.t/sillycrochet + 0.03125); //adding a half step
				var newnote = [note.t, note.d];
				if (note.l != null && note.l != 0)
					newnote[2] = note.l;
				if (note.k != null) {
					if (note.l == null || note.l == 0)
						newnote[2] = 0;
					newnote[3] = switch(note.k) { // most special notes can be handled with alt nums
						case 'weekend-1-kickcan' | 'weekend-1-firegun':
							2;
						case 'weekend-1-kneecan':
							3;
						default:
							1;
					};
				}
				newsong.notes[secNum].sectionNotes.push(newnote);
			}

			songStorage.push([diff, newsong]);
		}

		var events:Array<Dynamic> = charts.events;

		var dasteps:Array<Int> = [];
		//var eventnotes:Array<String> = [];
		var eventnotes:Map<Int, Array<String>>;
		eventnotes = new Map<Int, Array<String>>();
		var lastFocus = false;
		for (event in events) {
			var daStep = Std.int(Conductor.timeToSteps(event.t, true, basesong.bpm));
			if (!eventnotes.exists(daStep)) {
				eventnotes[daStep] = [];
				dasteps.push(daStep);
			}
			var info = event.v;
			var danote = null;
			switch(event.e) {
				case 'FocusCamera':
					var sillyWorkaround:String = '{';
					sillyWorkaround += info.char != null ? 'char: ' + info.char + ', ' : '';
					sillyWorkaround += (info.x != null && info.x != 0) ? 'x: ' + info.x + ', ' : '';
					sillyWorkaround += (info.y != null && info.y != 0) ? 'y: ' + info.y + ', ' : '';
					sillyWorkaround += (info.duration != null && info.duration != 4) ? 'duration: ' + info.duration + ', ' : '';
					sillyWorkaround += (info.ease != null && info.ease.toLowerCase() != 'classic') ? "ease: '" + info.ease + "', " : '';
					if (sillyWorkaround.length > 1)
						sillyWorkaround = sillyWorkaround.substr(0, sillyWorkaround.length - 2);
					sillyWorkaround += '}';
					/*if (daStep % 16 == 0 && info.x == 0 && info.y == 0 && info.ease.toLowerCase() == 'classic' && info.char < 2) {
						for (diff in songStorage) {
							var section = diff[1].notes[Std.int(daStep/16)];
							section.mustHitSection = info.char == 0 ? true : false;
							if (!section.mustHitSection) {
								var sectionNotes:Array<Dynamic> = section.sectionNotes;
								for (note in sectionNotes) {
									note[1] = (note[1] + 4) % 8;
								}
							}
						}
						if (lastFocus)
							danote = 'FocusCamera(0, 0, -2);';
						lastFocus = false;
					} else {*/
						danote = 'FocusCamera(' + sillyWorkaround + ');';
						//lastFocus = true;
					//}
				case 'ZoomCamera':
					var sillyWorkaround:String = '{';
					sillyWorkaround += (info.zoom != null && info.zoom != 1) ? 'zoom: ' + info.zoom + ', ' : '';
					sillyWorkaround += (info.duration != null && info.duration != 4) ? 'duration: ' + info.duration + ', ' : '';
					sillyWorkaround += (info.ease != null && info.ease != 'classic') ? "ease: '" + info.ease + "', " : '';
					sillyWorkaround += info.mode != null ? "mode: '" + info.mode + "', " : '';
					if (sillyWorkaround.length > 1)
						sillyWorkaround = sillyWorkaround.substr(0, sillyWorkaround.length - 2);
					sillyWorkaround += '}';
					danote = 'ZoomCamera(' + sillyWorkaround + ');';
				case 'SetCameraBop':
					var sillyWorkaround:String = '{';
					sillyWorkaround += (info.rate != null && info.rate != 4) ? 'rate: ' + info.rate + ', ' : '';
					sillyWorkaround += (info.intensity != null && info.intensity != 1) ? 'intensity: ' + info.intensity + ', ' : '';
					if (sillyWorkaround.length > 1)
					sillyWorkaround = sillyWorkaround.substr(0, sillyWorkaround.length - 2);
					sillyWorkaround += '}';
					danote = 'SetCameraBop(' + sillyWorkaround + ');';
				case 'ScrollSpeed':
					var sillyWorkaround:String = '{';
					sillyWorkaround += (info.scroll != null && info.scroll != 1) ? 'scroll: ' + info.scroll + ', ' : '';
					sillyWorkaround += info.strumline != null ? 'strumline: ' + info.strumline + ', ': '';
					sillyWorkaround += (info.duration != null && info.duration != 4) ? 'duration: ' + info.duration + ', ' : '';
					sillyWorkaround += (info.ease != null && info.ease != 'linear') ? "ease: '" + info.ease + "', " : '';
					sillyWorkaround += info.absolute != null ? "absolute: '" + info.absolute + "', " : '';
					if (sillyWorkaround.length > 1)
						sillyWorkaround = sillyWorkaround.substr(0, sillyWorkaround.length - 2);
					sillyWorkaround += '}';
				case 'PlayAnimation':
					danote = info.target + '.playAnim("' + info.anim + '", ' + info.force + ');';
				default:
					danote = '// ' + event.e + ' ' + event.v;
			}
			if (danote != null)
				eventnotes[daStep].push(danote);
			else {
				eventnotes[daStep] = null;
				dasteps.pop();
			}
		}
		dasteps.sort(function (Obj1, Obj2) {return FlxSort.byValues(FlxSort.ASCENDING, Obj1, Obj2);});

		var hscriptlayout = '';
		if (dasteps[0] == 0) {
			hscriptlayout += 'function start(song) {';
			for (event in eventnotes[0]) {
				hscriptlayout += '\n    ' + event;
			}
			hscriptlayout += '\n}\n\n';
			dasteps.shift();
		}
		hscriptlayout += 'function stepHit(step) {\n    switch(step) {';
		for (entry in dasteps) {
			hscriptlayout += '\n	case ' + entry + ':';
			for (event in eventnotes[entry]) {
				hscriptlayout += '\n		' + event;
			}
		}
		hscriptlayout += '\n    }\n}';
		songStorage.push(['events', hscriptlayout]);

		FlxTimer.wait(0.5, function() {
			for (song in 0...songStorage.length) {
				var songButton = new FlxUIButton(800, (FlxG.height / 2) + 30*song, songStorage[song][0], function():Void {
					if (songStorage[song][0] == 'events')
						FNFAssets.askToSave('modchart.hscript', songStorage[song][1]);
					else
						saveLevel(songStorage[song][1], songStorage[song][0]);
				});
				add(songButton);
				chartedButtons.push(songButton);
			}
		});
	}

	function portCodenameSong() {
		var chart = CoolUtil.parseJson(File.getContent(chartPath));
		var metadata = CoolUtil.parseJson(File.getContent(metadataPath));

		var basesong:SwagSong = {
			song: 'Test',
			notes: [],
			bpm: 150,
			needsVoices: true,
			player1: 'bf',
			player2: 'dad',
			stage: 'stage',
			gf: 'gf',
			isHey: false,
			isCheer: false,
			isSpooky: false,
			isMoody: false,
			speed: 1,
			cutsceneType: "none",
			uiType: 'normal',
			forceLayout: 'none',
			preferredNoteAmount: 4,
			forceJudgements: false,
			convertMineToNuke: false,
			mania: 0,
			stageID: 0
		};

		trace('basesong');

		basesong.song = metadata.name;
		basesong.bpm = metadata.bpm;
		basesong.speed = chart.scrollSpeed;

		var dadnotepacket:Array<Dynamic> = chart.strumLines[0].notes;
		var bfnotepacket:Array<Dynamic> = chart.strumLines[1].notes;
		dadnotepacket.sort(sortByShit);
		bfnotepacket.sort(sortByShit);

		var sillycrochet = (60 / basesong.bpm) * 4000; // sections in milliseconds
		var funnySections = Math.ceil(bfnotepacket[bfnotepacket.length - 1].time / sillycrochet); // the amount of sections (rounded up)
		for (i in 0...funnySections) {
			var curSection:SwagSection = {
				lengthInSteps: 16,
				mustHitSection: true,
				sectionNotes: [],
				bpm: basesong.bpm,
				changeBPM: false,
				altAnim: false,
				altAnimNum: 0
			};
			basesong.notes.push(curSection);
		}

		for (note in dadnotepacket) {
			note.id += 4;
		}

		var notepackets = bfnotepacket.concat(dadnotepacket);
		for (note in notepackets) {
			var secNum = Math.floor(note.time/sillycrochet + 0.03125); //adding a half step
			var newnote = [note.time, note.id];
			if (note.sLen != null && note.sLen != 0)
				newnote[2] = note.sLen;
			basesong.notes[secNum].sectionNotes.push(newnote);
		}

		songStorage.push(['idk', basesong]);

		FlxTimer.wait(0.5, function() {
			for (song in 0...songStorage.length) {
				var songButton = new FlxUIButton(800, (FlxG.height / 2) + 30*song, songStorage[song][0], function():Void {
					saveLevel(songStorage[song][1], songStorage[song][0]);
				});
				add(songButton);
				chartedButtons.push(songButton);
			}
		});
	}

	function sortByShit(Obj1, Obj2):Int {
		if (Obj1.time != null)
			return FlxSort.byValues(FlxSort.ASCENDING, Obj1.time, Obj2.time);
		else
			return FlxSort.byValues(FlxSort.ASCENDING, Obj1.t, Obj2.t);
	}

	private function saveLevel(song, diff) {
		var json = {
			"song": song
		};

		var data:String = CoolUtil.stringifyJson(json);

		if ((data != null) && (data.length > 0)) {
			FNFAssets.askToSave(song.song.toLowerCase() + '-' + diff + '.json', data);
		}
	}
}
