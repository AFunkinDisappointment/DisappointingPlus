package;

import lime.utils.Assets;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import sys.FileSystem;
import flash.media.Sound;
#end

typedef SongImport = {
	var name:String;
	var p1:String;
	var p2:String;
	var gf:String;
	var stage:String;
	var ui:String;
	var cutscene:String;
	var category:String;
	var isHey:Bool;
	var isCheer:Bool;
	var isMoody:Bool;
	var isSpooky:Bool;
	var stageID:Int;
	var week:Int;
	var char:String;
	var display:String;
	var inst:String;
	var voices:String;
	var dialog:String;
	var modchart:String;
	var diffFiles:Array<String>;
}
typedef StageImport = {
	var name:String;
	var like:String;
	var likePath:String;
	var assets:Array<String>;
}
typedef CharImport = {
	var name:String;
	var like:String;
	var likePath:String;
	var assets:Dynamic;
	var iconNums:Array<Float>;
	var colors:String;
}
typedef WeekImport = {
	var name:String;
	var desc:String;
	var like:String;
	var songs:Array<String>;
	var bf:String;
	var gf:String;
	var dad:String;
	var assets:Dynamic;
}

class ModuleFunctions {
	static public function importSong(songData:SongImport) {
		if (!FileSystem.exists('assets/data/' + songData.name.toLowerCase()))
			FileSystem.createDirectory('assets/data/' + songData.name.toLowerCase());

		for (i in 0...songData.diffFiles.length) {
			if (songData.diffFiles[i] != null) {
				var coolSong:Dynamic = CoolUtil.parseJson(File.getContent(songData.diffFiles[i]));
				var coolSongSong:Dynamic = coolSong.song;
				coolSongSong.song = songData.name;
				coolSongSong.player1 = songData.p1;
				coolSongSong.player2 = songData.p2;
				coolSongSong.gf = songData.gf;
				coolSongSong.stage = songData.stage;
				coolSongSong.uiType = songData.ui;
				coolSongSong.cutsceneType = songData.cutscene;
				coolSongSong.isMoody = songData.isMoody;
				coolSongSong.isHey = songData.isHey;
				coolSongSong.isCheer = songData.isCheer;
				coolSongSong.isSpooky = songData.isSpooky;
				coolSongSong.stageID = Std.int(songData.stageID);
				coolSong.song = coolSongSong;

				File.saveContent('assets/data/' + songData.name.toLowerCase() + '/' + songData.name.toLowerCase() + DifficultyIcons.getEndingFP(i) + '.json', CoolUtil.stringifyJson(coolSong));
			}
		}
		// probably breaks on non oggs haha weeeeeeeeeee
		if (!FileSystem.exists('assets/songs/' + songData.name.toLowerCase()))
			FileSystem.createDirectory('assets/songs/' + songData.name.toLowerCase());
		File.copy(songData.inst, 'assets/songs/' + songData.name.toLowerCase() + '/Inst.ogg');
		if (FileSystem.exists(songData.voices))
			File.copy(songData.voices, 'assets/songs/' + songData.name.toLowerCase() + '/Voices.ogg');
		if (FileSystem.exists(songData.dialog))
			File.copy(songData.dialog, 'assets/data/' + songData.name.toLowerCase() + '/dialog.txt');
		if (songData.modchart != null)
			File.copy(songData.modchart, 'assets/data/' + songData.name.toLowerCase() + '/modchart.hscript');
		if (songData.char == 'null')
			songData.char == songData.p2;
		var coolSongListFile:Array<Dynamic> = CoolUtil.parseJson(Assets.getText('assets/data/freeplaySongJson.jsonc'));
		var foundSomething:Bool = false;
		for (coolCategory in coolSongListFile) {
			if (coolCategory.name == songData.category) {
				foundSomething = true;
				if (songData.display == 'null')
					coolCategory.songs.push({"name": songData.name, "character": songData.char, "week": songData.week});
				else
					coolCategory.songs.push({"name": songData.name, "character": songData.char, "week": songData.week, "display": songData.display});
				break;
			}
		}
		if (!foundSomething) {
			// must be a new category
			if (songData.display == 'null')
				coolSongListFile.push({"name": songData.category, "songs": [{"name": songData.name, "character": songData.char, "week": songData.week}]});
			else
				coolSongListFile.push({"name": songData.category, "songs": [{"name": songData.name, "character": songData.char, "week": songData.week, "display": songData.display}]});
		}
		File.saveContent('assets/data/freeplaySongJson.jsonc', CoolUtil.stringifyJson(coolSongListFile));
	}

	static public function exportSong(daSong:String) {
		var diffJson:NewSongState.TDifficulties = CoolUtil.parseJson(Assets.getText("assets/images/custom_difficulties/difficulties.json"));
		var exportPath:String = "assets/module/export/songs/" + daSong;
		var musicPath:String = "assets/music/";
		var songPath:String = "assets/songs/" + daSong;
		var dataPath:String = "assets/data/" + daSong;

		if (!FileSystem.exists(exportPath))
			FileSystem.createDirectory(exportPath);

		if (FileSystem.exists(songPath + '/' + daSong + '_Inst.ogg'))
			File.copy(songPath + '/' + daSong + '_Inst.ogg', exportPath + '/Inst.ogg');
		else if (FileSystem.exists(songPath + '/Inst.ogg'))
			File.copy(songPath + '/Inst.ogg', exportPath + '/Inst.ogg');
		else if (FileSystem.exists(musicPath + daSong + '_Inst.ogg'))
			File.copy(musicPath + daSong + '_Inst.ogg', exportPath + '/Inst.ogg');

		if (FileSystem.exists(songPath + '/' + daSong + '_Voices.ogg'))
			File.copy(songPath + '/' + daSong + '_Voices.ogg', exportPath + '/Voices.ogg');
		else if (FileSystem.exists(songPath + '/Voices.ogg'))
			File.copy(songPath + '/Voices.ogg', exportPath + '/Voices.ogg');
		else if (FileSystem.exists(musicPath + daSong + '_Voices.ogg'))
			File.copy(musicPath + daSong + '_Voices.ogg', exportPath + '/Voices.ogg');

		if (FileSystem.exists(dataPath + '/dialog.txt'))
			File.copy(dataPath + '/dialog.txt', exportPath + '/dialog.txt');

		if (FileSystem.exists(dataPath + '/modchart.hscript'))
			File.copy(dataPath + '/modchart.hscript', exportPath + '/modchart.hscript');

		var daInfo:Array<String> = [];
		var songInfo = null;
		if (FileSystem.exists(dataPath + '/' + daSong + '.json'))
			songInfo = dataPath + '/' + daSong + '.json';
		else
			for (i in 0...diffJson.difficulties.length) {
				if (songInfo == null)
					switch(diffJson.difficulties[i].name) {
						case 'normal':
							//do nothing
						default:
							if (FileSystem.exists(dataPath + '/' + daSong + '-' + diffJson.difficulties[i].name + '.json'))
								songInfo = dataPath + '/' + daSong + '-' + diffJson.difficulties[i].name + '.json';
					}
			}
		var coolSong:Dynamic = CoolUtil.parseJson(File.getContent(songInfo));
		var coolSongSong:Dynamic = coolSong.song;
		//var epicCategoryJs:Array<Dynamic> = CoolUtil.parseJson(FNFAssets.getText('assets/data/freeplaySongJson.jsonc'));
		//how do I make this better???
		daInfo.push("This song info was made using Disappointing Plus");
		daInfo.push("I would recommend replacing the nulls before importing!");
		daInfo.push("It won't import properly if there is nulls (except for char and display)");
		daInfo.push("");
		daInfo.push("songname:" + coolSongSong.song);
		daInfo.push("player1:" + coolSongSong.player1);
		daInfo.push("player2:" + coolSongSong.player2);
		daInfo.push("gf:" + coolSongSong.gf);
		daInfo.push("stage:" + coolSongSong.stage);
		daInfo.push("uiType:" + coolSongSong.uiType);
		daInfo.push("cutsceneType:" + coolSongSong.cutsceneType);
		daInfo.push("isHey:" + coolSongSong.isHey);
		daInfo.push("isCheer:" + coolSongSong.isCheer);
		daInfo.push("isMoody:" + coolSongSong.isMoody);
		daInfo.push("isSpooky:" + coolSongSong.isSpooky);
		daInfo.push("category:null");
		daInfo.push("stageID:" + coolSongSong.stageID);
		daInfo.push("week:-1");
		daInfo.push("char:null");
		daInfo.push("display:null");
		//haha among us funny
		var sussyInfo = StringTools.replace(daInfo.toString(), ',', '\n');
		sussyInfo = StringTools.replace(sussyInfo, '[', '');
		sussyInfo = StringTools.replace(sussyInfo, ']', '');
		trace(sussyInfo);
		File.saveContent(exportPath + '/info.txt', sussyInfo);

		for (i in 0...diffJson.difficulties.length) {
			switch(diffJson.difficulties[i].name) {
				case 'normal':
					if (FileSystem.exists(dataPath + '/' + daSong + '.json'))
						File.copy(dataPath + '/' + daSong + '.json', exportPath + '/' + diffJson.difficulties[i].name + '.json');
				default:
					if (FileSystem.exists(dataPath + '/' + daSong + '-' + diffJson.difficulties[i].name + '.json'))
						File.copy(dataPath + '/' + daSong + '-' + diffJson.difficulties[i].name + '.json', exportPath + '/' + diffJson.difficulties[i].name + '.json');
			}
		}
	}

	static public function importStage(stageData:StageImport) {
		#if sys
		if (!FileSystem.exists('assets/images/custom_stages/' + stageData.name)) {
			FileSystem.createDirectory('assets/images/custom_stages/' + stageData.name);
		}
		for (epicFile in stageData.assets) {
			var coolPath:Path = new Path(epicFile);
			coolPath.dir = 'assets/custom_stages/' + stageData.name;
			var pathString:String = coolPath.dir + '/' + coolPath.file + '.' + coolPath.ext;
			File.copy(epicFile, pathString);
		}
		
		if (stageData.likePath != null && !FileSystem.exists('assets/images/custom_stages/' + stageData.like + '.hscript'))
			File.copy(stageData.likePath, 'assets/images/custom_stages/' + stageData.like + '.hscript');

		var epicStageFile:Dynamic = CoolUtil.parseJson(FNFAssets.getText('assets/images/custom_stages/custom_stages'));
		Reflect.setField(epicStageFile, stageData.name, stageData.like);

		File.saveContent('assets/images/custom_stages/custom_stages.json', CoolUtil.stringifyJson(epicStageFile));
		#end
	}
	static public function exportStage(daStage:String) {
		var exportPath = 'assets/module/export/stages/' + daStage + '/';
		var stagePath = 'assets/images/custom_stages/';

		var epicStageFile:Dynamic = CoolUtil.parseJson(FNFAssets.getText('assets/images/custom_stages/custom_stages'));

		if (!FileSystem.exists(exportPath + daStage)) {
			FileSystem.createDirectory(exportPath + daStage);
		}

		for (asset in FileSystem.readDirectory(stagePath + daStage)) {
			File.copy(stagePath + daStage + asset, exportPath + daStage + asset);
		}
	}

	static public function importChar(charData:CharImport) {
		#if sys
		if (!FileSystem.exists('assets/images/custom_chars/' + charData.name)) {
			FileSystem.createDirectory('assets/images/custom_chars/' + charData.name);
		}
		File.copy(charData.assets.charpng, 'assets/images/custom_chars/' + charData.name + '/char.png');

		if (StringTools.endsWith(charData.assets.charxml, "xml"))
			File.copy(charData.assets.charxml, 'assets/images/custom_chars/' + charData.name + '/char.xml');
		else
			File.copy(charData.assets.charxml, 'assets/images/custom_chars/' + charData.name + '/char.txt');

		if (charData.assets.deadpng != null) {
			File.copy(charData.assets.deadpng, 'assets/images/custom_chars/' + charData.name + '/dead.png');
			File.copy(charData.assets.deadxml, 'assets/images/custom_chars/ '+ charData.name + '/dead.xml');
		}
		if (charData.assets.crazypng != null) {
			File.copy(charData.assets.crazypng,'assets/images/custom_chars/' + charData.name + '/crazy.png');
			File.copy(charData.assets.crazyxml,'assets/images/custom_chars/' + charData.name + '/crazy.xml');
		}
		if (charData.assets.icons != null )
			File.copy(charData.assets.icons, "assets/images/custom_chars/" + charData.name + '/icons.png');

		if (charData.likePath != null && !FileSystem.exists('assets/images/custom_chars/' + charData.like + '.hscript'))
			File.copy(charData.likePath, 'assets/images/custom_chars/' + charData.like + '.hscript');

		var epicCharFile:Dynamic = CoolUtil.parseJson(FNFAssets.getJson('assets/images/custom_chars/custom_chars'));
		var commaSeperatedColors = charData.colors.split(",");
		Reflect.setField(epicCharFile, charData.name,{like:charData.like,icons: [Std.int(charData.iconNums[0]),Std.int(charData.iconNums[1]),Std.int(charData.iconNums[2]),Std.int(charData.iconNums[3])], colors: commaSeperatedColors});

		File.saveContent('assets/images/custom_chars/custom_chars.jsonc', CoolUtil.stringifyJson(epicCharFile));
		#end
	}

	static public function importWeek(weekData:WeekImport) {
		#if sys
		var parsedWeekJson:StoryMenuState.StorySongsJson = CoolUtil.parseJson(FNFAssets.getJson("assets/data/storySonglist"));
		
		File.copy(weekData.assets.png, 'assets/images/campaign-ui-week/' + weekData.name + '.png');

		File.copy(weekData.assets.xml, 'assets/images/campaign-ui-week/' + weekData.name + '.xml');

		var coolObject:StoryMenuState.WeekInfo = {animation: weekData.like, name: weekData.name, desc: weekData.desc, bf: weekData.bf, gf: weekData.gf, dad: weekData.dad, songs: weekData.songs};
		parsedWeekJson.weeks.push(coolObject);
		
		File.saveContent('assets/data/storySonglist.json', CoolUtil.stringifyJson(parsedWeekJson));
		#end
	}
}