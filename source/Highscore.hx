package;

import OptionsHandler.TOptions;
import Judge.Jury;
import flixel.FlxG;
@:forward
enum abstract FCLevel(Int) from Int to Int {
	var None;
	var Clear;
	var Sdcb;
	var Bad;
	var Good;
	var Sick;
	@:op(A > B) static function _(_,_):Bool;
	@:op(A >= B) static function _(_, _):Bool;
	@:op(A < B) static function _(_, _):Bool;
	@:op(A <= B) static function _(_, _):Bool;
	@:op(A == B) static function _(_, _):Bool;
}
class Highscore {
	public static var songScores:Map<String, Int> = new Map();
	public static var songAccuracy:Map<String, Float> = new Map();
	public static var songCompletions:Map<String, Bool> = new Map();
	public static var songFCLevels:Map<String, Int> = new Map();
	public static var songJudge:Map<String, Int> = new Map();
	public static var songOptionsUsed:Map<String, OptionsHandler.TOptions> = new Map();
	public static var songModifiersUsed:Map<String, Dynamic> = new Map();

	static var saveCategories = ['best-score', 'recent', 'best-accuracy', 'best-fullcombo', 'best'];

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?accuracy:Float = 0, ?rating:FCLevel, ?judge:Jury):Void {
		// we don't need the current options or modifiers as we can assume they haven't changed
		var daSong:String = formatSong(song, diff, "best-score");
		var recentSong:String = formatSong(song, diff, "recent");
		var bestAccuracy:String = formatSong(song, diff, "best-accuracy");
		var bestFC:String = formatSong(song, diff, "best-fullcombo");
		var bestOfAll:String = formatSong(song, diff, "best");
		var curOptions = OptionsHandler.options;
		var modifierDynamic = ModifierState.namedModifiers;
		setScore(recentSong, score);
		setAccuracy(recentSong, accuracy);
		setFCLevel(recentSong, rating);
		setJudge(recentSong, judge);
		setOptionsUsed(recentSong, curOptions);
		setModifiersUsed(recentSong, modifierDynamic);
		if (songScores.exists(daSong)) {
			if (songScores.get(daSong) < score) {
				setScore(daSong, score);
				setAccuracy(daSong, accuracy);
				setFCLevel(daSong, rating);
				setJudge(daSong,judge);
				setOptionsUsed(daSong, curOptions);
				setModifiersUsed(daSong, modifierDynamic);
				setScore(bestOfAll, score);
			}
		} else {
			setScore(daSong, score);
			setAccuracy(daSong, accuracy);
			setFCLevel(daSong, rating);
			setJudge(daSong, judge);
			setOptionsUsed(daSong, curOptions);
			setModifiersUsed(daSong, modifierDynamic);
			setScore(bestOfAll, score);
		}
		if (songAccuracy.exists(bestAccuracy)) {
			if (songAccuracy.get(bestAccuracy) < accuracy) {
				setScore(bestAccuracy, score);
				setAccuracy(bestAccuracy, accuracy);
				setFCLevel(bestAccuracy, rating);
				setJudge(bestAccuracy, judge);
				setOptionsUsed(bestAccuracy, curOptions);
				setModifiersUsed(bestAccuracy, modifierDynamic);
				setAccuracy(bestOfAll, accuracy);
			}
		} else {
			setScore(bestAccuracy, score);
			setAccuracy(bestAccuracy, accuracy);
			setFCLevel(bestAccuracy, rating);
			setJudge(bestAccuracy, judge);
			setOptionsUsed(bestAccuracy, curOptions);
			setModifiersUsed(bestAccuracy, modifierDynamic);
			setAccuracy(bestOfAll, accuracy);
		}
		
		if (songFCLevels.exists(bestFC)) {
			if (songFCLevels.get(bestFC) <= rating) {
				setScore(bestFC, score);
				setAccuracy(bestFC, accuracy);
				setFCLevel(bestFC, rating);
				setJudge(bestFC, judge);
				setOptionsUsed(bestFC, curOptions);
				setModifiersUsed(bestFC, modifierDynamic);
				if (!songFCLevels.exists(bestOfAll) || songFCLevels.get(bestOfAll) <= rating )
					setFCLevel(bestOfAll, rating);
			}
		} else {
			setScore(bestFC, score);
			setAccuracy(bestFC, accuracy);
			setFCLevel(bestFC, rating);
			setJudge(bestFC, judge);
			setOptionsUsed(bestFC, curOptions);
			setModifiersUsed(bestFC, modifierDynamic);
			if (!songFCLevels.exists(bestOfAll) || songFCLevels.get(bestOfAll) <= rating)
				setFCLevel(bestOfAll, rating);
		}
		songFlush();
	}
	public static function saveWeekScore(week:String = 'Tutorial', score:Int = 0, ?diff:Int = 0, ?accuracy:Float = 0, ?saving:String = "best"):Void {
		var daWeek:String = formatSong('week-' + week, diff, saving);

		if (songScores.exists(daWeek)) {
			if (songScores.get(daWeek) < score) {
				setScore(daWeek, score);
				setAccuracy(daWeek, accuracy);
			} 	
		} else {
			setScore(daWeek, score);
			setAccuracy(daWeek, accuracy);
		}
		songFlush();
	}

	public static function deleteSongScore(song:String = 'Tutorial', ?diff:Int = 0):Void {
		for (saveCode in saveCategories) {
			var daSong:String = formatSong(song, diff, saveCode);
			songScores.remove(daSong);
			songAccuracy.remove(daSong);
			songCompletions.remove(daSong);
			songFCLevels.remove(daSong);
			songJudge.remove(daSong);
			songOptionsUsed.remove(daSong);
			songModifiersUsed.remove(daSong);
		}
		songFlush();
	}
	public static function deleteWeekScore(week:String = 'Tutorial', ?diff:Int = 0):Void {
		var daWeek:String = formatSong('week-' + week, diff, 'best');
		setScore(daWeek, 0);
		setAccuracy(daWeek, 0);
		songFlush();
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void {
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		//FlxG.save.data.songScores = songScores;
		//FlxG.save.flush();
	}
	public static function setComplete(song:String, combo:Bool) {
		songCompletions.set(song, combo);
		//FlxG.save.data.songCompletions = songCompletions;
		//FlxG.save.flush();
	}
	public static function setAccuracy(song:String, accuracy:Float):Void {
		songAccuracy.set(song,accuracy);
		//FlxG.save.data.songAccuracy = songAccuracy;
		//FlxG.save.flush();
	}
	static function setFCLevel(song:String, level:Int ):Void {
		songFCLevels.set(song, level);
		//FlxG.save.data.songFCLevels = songFCLevels;
		//FlxG.save.flush();
	}
	static function setJudge(song:String, judge:Int):Void {
		songJudge.set(song, judge);
		//FlxG.save.data.songJudge = songJudge;
		//FlxG.save.flush();
	}
	static function setOptionsUsed(song:String, options:TOptions):Void {
		songOptionsUsed.set(song, options);
		//FlxG.save.data.songOptionsUsed = songOptionsUsed;
		//FlxG.save.flush();
	}
	static function setModifiersUsed(song:String, modifiers:Dynamic):Void {
		songModifiersUsed.set(song, modifiers);
		//FlxG.save.data.songModifiersUsed = songModifiersUsed;
		//FlxG.save.flush();
	}
	static function songFlush():Void {
		FlxG.save.data.songScores = songScores;
		FlxG.save.data.songCompletions = songCompletions;
		FlxG.save.data.songAccuracy = songAccuracy;
		FlxG.save.data.songFCLevels = songFCLevels;
		FlxG.save.data.songJudge = songJudge;
		FlxG.save.data.songOptionsUsed = songOptionsUsed;
		FlxG.save.data.songModifiersUsed = songModifiersUsed;
		FlxG.save.flush();
	}
	public static function formatSong(song:String, diff:Int, saving:String):String {
		// saving is just an extra thing
		// so like "recent"
		// "best-score"
		// "best-accuracy"
		var daSong:String = song;
		daSong += DifficultyIcons.getEndingFP(diff);
		if (saving != "best")
			daSong += "-" + saving;
		return daSong;
	}

	public static function getScore(song:String, diff:Int, useFor:String = "best"):Int {
		var daSong:String = formatSong(song, diff, useFor);
		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}
	public static function getOptionsUsed(song:String, diff:Int, useFor:String = "best"):TOptions {
		var daSong:String = formatSong(song, diff, useFor);
		if (!songOptionsUsed.exists(daSong))
			setOptionsUsed(daSong, OptionsHandler.options);

		return songOptionsUsed.get(daSong);
	}
	public static function getModifiersUsed(song:String, diff:Int, useFor:String = "best"):Dynamic {
		var daSong:String = formatSong(song, diff, useFor);
		if (!songModifiersUsed.exists(daSong))
			setModifiersUsed(daSong, ModifierState.namedModifiers);

		return songModifiersUsed.get(daSong);
	}
	public static function getAccuracy(song:String, diff:Int, useFor:String = "best"):Float {
		var daSong:String = formatSong(song, diff, useFor);
		if (!songAccuracy.exists(daSong))
			setAccuracy(daSong, 0);

		return songAccuracy.get(daSong);
	}
	public static function getComplete(song:String, diff:Int, useFor:String = "best"):Bool {
		var daSong:String = formatSong(song, diff, useFor);
		if (!songCompletions.exists(daSong))
			setComplete(daSong, false);

		return songCompletions.get(daSong);
	}
	public static function getFCLevel(song:String, diff:Int, useFor:String = "best"):Int {
		var daSong:String = formatSong(song, diff, useFor);
		if (!songFCLevels.exists(daSong))
			setFCLevel(daSong, cast None);

		return songFCLevels.get(daSong);
	}
	public static function getJudge(song:String, diff:Int, useFor:String = "best"):Int {
		var daSong:String = formatSong(song, diff, useFor);
		if (!songJudge.exists(daSong))
			setJudge(daSong, cast Classic);

		return songJudge.get(daSong);
	}

	public static function getTotalScore():Int {
		var totalScore:Int = 0;
		for (key in songScores.keys()) {
			totalScore += songScores.get(key);
		}
		return totalScore;
	}
	public static function getWeekScore(week:String, diff:Int, useFor:String = "best"):Int {
		if (!songScores.exists(formatSong('week-' + week, diff, useFor)))
			setScore(formatSong('week-' + week, diff, useFor), 0);

		return songScores.get(formatSong('week-' + week, diff, useFor));
	}
	public static function getWeekAccuracy(week:String, diff:Int, useFor:String = "best"):Float {
		if (!songAccuracy.exists(formatSong('week-' + week, diff, useFor)))
			setAccuracy(formatSong('week-' + week, diff, useFor), 0);

		return songAccuracy.get(formatSong('week-' + week, diff, useFor));
	}

	public static function load():Void {
		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;

		if (FlxG.save.data.songAccuracy != null) {
			songAccuracy = FlxG.save.data.songAccuracy;
		} else {
			songAccuracy = [];
			FlxG.save.data.songAccuracy = songAccuracy;
		}

		if (FlxG.save.data.songFCLevels != null)
			songFCLevels = FlxG.save.data.songFCLevels;
		else
			songFCLevels = [];

		if (FlxG.save.data.songJudge != null)
			songJudge = FlxG.save.data.songJudge;
		else
			songJudge = [];

		if (FlxG.save.data.songModifiersUsed != null)
			songModifiersUsed = FlxG.save.data.songModifiersUsed;
		else
			songModifiersUsed = [];

		if (FlxG.save.data.songOptionsUsed != null)
			songOptionsUsed = FlxG.save.data.songOptionsUsed;
		else
			songOptionsUsed = [];
	}
}
