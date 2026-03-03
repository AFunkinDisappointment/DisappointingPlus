package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import tjson.TJSON;
#if sys
import sys.io.File;
import lime.system.System;
import haxe.io.Path;
#end
using StringTools;

typedef SwagSong = {
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var stage:String;
	var gf:String;
	var isMoody:Null<Bool>;
	var cutsceneType:String;
	var uiType:String;
	var isSpooky:Null<Bool>;
	var isHey:Null<Bool>;
	var isCheer:Null<Bool>;
	var preferredNoteAmount:Null<Int>;
	var forceJudgements:Null<Bool>;
	var forceLayout:Null<String>;
	var convertMineToNuke:Null<Bool>;
	var mania:Null<Int>;
	var stageID:Null<Int>;
}

class Song {
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var stage:String = 'stage';
	public var gf:String = 'gf';
	public var isMoody:Null<Bool> = false;
	public var isSpooky:Null<Bool> = false;
	public var cutsceneType:String = "none";
	public var uiType:String = 'normal';
	public var isHey:Null<Bool> = false;
	public var isCheer:Null<Bool> = false;
	public function new(song, notes, bpm) {
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong {
		var rawJson:String = "";
		var diffSplit = jsonInput.split('-');
		var diffName = diffSplit[diffSplit.length - 1];
		var daDefault = '-' + DifficultyManager.getDefaultFromName(diffName);
		if (jsonInput != folder + daDefault && FNFAssets.exists("assets/data/" + folder.toLowerCase() + "/" + folder.toLowerCase() + daDefault + ".json")) {
			// means this isn't normal difficulty
			// raw json 

			rawJson = FNFAssets.getText("assets/data/" + folder.toLowerCase() + "/" + folder.toLowerCase() + daDefault + ".json").trim();
		} else {
			rawJson = FNFAssets.getText("assets/data/" + folder.toLowerCase() + "/" + jsonInput.toLowerCase() + '.json').trim();
		}
		
		while (!rawJson.endsWith("}")) {
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}
		var parsedJson = parseJSONshit(rawJson);
		if (parsedJson.stage == null) {
			// sw-switch case :fuckboy:
			parsedJson.stage = switch (parsedJson.song.toLowerCase()) {
				case 'spookeez' | 'monster' | 'south':
					'spooky';
				case 'philly' | 'pico' | 'blammed':
					'philly';
				case 'milf' | 'high' | 'satin-panties':
					'limo';
				case 'cocoa' | 'eggnog':
					'mall';
				case 'winter-horrorland':
					'mallEvil';
				case 'senpai' | 'roses':
					'school';
				case 'thorns':
					'schoolEvil';
				case 'ugh' | 'stress' | 'guns':
					'tank';
				case 'darnell' | 'lit-up' | '2hot':
					'philly-streets';
				default:
					'stage';
			}
		}
		if (parsedJson.isHey == null) {
			parsedJson.isHey = false;
			if (parsedJson.song.toLowerCase() == 'bopeebo')
				parsedJson.isHey = true;
		}
		if (parsedJson.isCheer = null) {
			parsedJson.isCheer = false;
			if (parsedJson.song.toLowerCase() == "tutorial")
				parsedJson.isCheer = true;
		}

		if (parsedJson.gf == null) {
			switch (parsedJson.stage) {
				case 'limo':
					parsedJson.gf = 'gf-car';
				case 'mall' | 'mallEvil':
					parsedJson.gf = 'gf-christmas';
				case 'school' | 'schoolEvil':
					parsedJson.gf = 'gf-pixel';
				case 'tank':
					parsedJson.gf = 'gf-tankmen';
					if (parsedJson.song.toLowerCase() == "stress")
						parsedJson.gf = "pico-speaker";
				default:
					parsedJson.gf = 'gf';
			}

		}
		if (parsedJson.isMoody == null) {
			if (parsedJson.song.toLowerCase() == 'roses')
				parsedJson.isMoody = true;
			else
				parsedJson.isMoody = false;
		}
		// is spooky means trails on spirit
		if (parsedJson.isSpooky == null) {
			if (parsedJson.stage.toLowerCase() == 'schoolEvil')
				parsedJson.isSpooky = true;
			else
				parsedJson.isSpooky = false;
		}
		if (parsedJson.song.toLowerCase() == 'winter-horrorland')
			parsedJson.cutsceneType = "monster";

		if (parsedJson.forceJudgements == null)
			parsedJson.forceJudgements = false;

		if (parsedJson.forceLayout == null)
			parsedJson.forceLayout = 'none';

		if (parsedJson.cutsceneType == null) {
			parsedJson.cutsceneType = switch (parsedJson.song.toLowerCase()) {
				case 'roses':
					"angry-senpai";
				case 'senpai':
					"senpai";
				case 'thorns':
					'spirit';
				case 'winter-horrorland':
					'monster';
				default:
					'none';
			}
		}
		if (parsedJson.convertMineToNuke == null) {
			if (parsedJson.song.toLowerCase() == "expurgation")
				parsedJson.convertMineToNuke = true;
			else
				parsedJson.convertMineToNuke = false;
		}
		if (parsedJson.uiType == null) {
			parsedJson.uiType = switch (parsedJson.song.toLowerCase()) {
				case 'roses' | 'senpai' | 'thorns':
					'pixel';
				default:
					'normal';
			}
		}
		if (parsedJson.stageID == null) {
			parsedJson.stageID = switch(diffName.toLowerCase()) {
				case 'erect' | 'nightmare' | 'pico':
					1;
				default:
					0;
			}
			
		}
		if (parsedJson.preferredNoteAmount == null) {
			parsedJson.preferredNoteAmount =  switch (parsedJson.mania) {
				case 1:
					6;
				case 2:
					9;
				default:
					4;
			}
		}
		if (parsedJson.mania == null) {
			parsedJson.mania = switch (parsedJson.preferredNoteAmount) {
				case 6:
					1;
				case 9:
					2;
				default:
					0;
			}
		}
		if (parsedJson.player1 == "bf-pixel" && OptionsHandler.options.stressTankmen) {
			parsedJson.player1 = "bulb-pixel";
		}
		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/*
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daSections = songData.sections;
				daBpm = songData.bpm;
				daSectionLengths = songData.sectionLengths; */
		if (jsonInput != folder + daDefault) {
			// means this isn't (daDefault) difficulty
			// lets finally overwrite notes
			var realJson = parseJSONshit(FNFAssets.getText("assets/data/" + folder.toLowerCase() + "/" + jsonInput.toLowerCase() + '.json').trim());
			parsedJson.song = realJson.song;
			parsedJson.notes = realJson.notes;
			parsedJson.bpm = realJson.bpm;
			parsedJson.needsVoices = realJson.needsVoices;
			parsedJson.speed = realJson.speed;
			parsedJson.mania = realJson.mania;
			parsedJson.preferredNoteAmount = realJson.preferredNoteAmount;
			if (parsedJson.preferredNoteAmount == null) {
				parsedJson.preferredNoteAmount = switch (parsedJson.mania) {
					case 1:
						6;
					case 2:
						9;
					default:
						4;
				}
			}
			if (parsedJson.mania == null) {
				parsedJson.mania = switch (parsedJson.preferredNoteAmount) {
					case 6:
						1;
					case 9:
						2;
					default:
						0;
				}
			}
		}
		return parsedJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong {
		var swagShit:SwagSong = cast CoolUtil.parseJson(rawJson).song;
		return swagShit;
	}
}
