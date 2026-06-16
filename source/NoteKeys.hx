package;

typedef NoteData = {
	var note:String;
	var splashes:Array<String>;
	var idle:String;
	var pressed:String;
	var confirm:String;
	var sing:String;
}

class NoteKeys {
	public var preset:Dynamic;
	public var definitions:Dynamic;
	public var key:Dynamic;
	public var keyAmount:Int = 4;
	public var notes(get, default):Array<NoteData>;
	public function new(noteType:String, isPixel:Bool = false) {
		newKey(noteType, isPixel);
	}

	public function newKey(noteType:String, isPixel:Bool = false) {
		var presetPath:String = 'assets/images/custom_ui/ui_packs/' + noteType + '/multiNotePresets';
		if (isPixel && FNFAssets.exists(presetPath + '-pixel.json'))
			presetPath += '-pixel';
	
		presetPath += '.json';
		
		if (FNFAssets.exists(presetPath))
			preset = CoolUtil.parseJson(FNFAssets.getText(presetPath));

		keyAmount = Note.NOTE_AMOUNT;
		if (!Reflect.hasField(preset, 'key${keyAmount}') || !FNFAssets.exists(presetPath))
			preset = CoolUtil.parseJson(FNFAssets.getText('assets/data/defaultNotePresets.json'));

		key = Reflect.field(preset, 'key${keyAmount}');

		if (Reflect.hasField(preset, 'definitions'))
			definitions = Reflect.field(preset, 'definitions');
		else
			definitions = null;

		storeNotes();
	}

	public function changeKeyAmount(amount:Int = 4):Void {
		keyAmount = amount;
		key = Reflect.field(preset, 'key${amount}');
		storeNotes();
	}

	public function storeNotes():Void {
		notes = [];
		for (i in 0...keyAmount)
			notes[i] = getDataFromID(i);
	}

	public function getDataFromID(noteID:Int):NoteData {
		var note:Dynamic = key[noteID];
		var data:Null<NoteData> = null;
		if ((note is String)) {
			if (definitions != null)
				data = Reflect.field(definitions, note);
		} else if (note != null)
			data = note;

		if (data == null)
			data = {note: 'arrowDOWN', splashes: ['note impact 1 red'], idle: 'blue', pressed: 'arrowDOWN', confirm: 'arrowDOWN', sing: 'idle'};
		return data;
	}

	public function getData(noteID:Int):NoteData {
		return notes[noteID];
	}

	public function getNote(noteID:Int):String {
		return notes[noteID].note;
	}

	public function getSing(noteID:Int):String {
		return notes[noteID].sing;
	}

	public function getSplashes(noteID:Int):Array<String> {
		return notes[noteID].splashes;
	}

	function get_notes() {
		if (notes == null)
			storeNotes();
		return notes;
	}
}