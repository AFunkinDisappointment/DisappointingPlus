import hscript.Interp;
import flixel.group.FlxSpriteGroup;

typedef CharacterInfo = {
	var x:Int;
	var y:Int;
	var ?scrollFactor:Array<Float>;
}

class StageHelper /*extends FlxSpriteGroup*/ {
	public var interp:Interp;
	public var name:String = 'stage';
	public var defaultZoom:Float = 1.05;
	//public var boyfriendInfo:CharacterInfo;
	//public var dadInfo:CharacterInfo;
	//public var gfInfo:CharacterInfo;

	public var elements:Map<String, Dynamic> = [];
	public var characters:Map<String, Character> = [];
	//public var zIndex:Map<String, Int> = [];
	public var functions:Map<String, Dynamic> = [];
	public function new(stageName:String = 'stage', ?stageInterp:Interp) {
		//super();

		name = stageName;
		if (stageInterp != null) interp = stageInterp;
	}

	public function addElement(name:String, element:Dynamic/*, ?zIndex:Int*/) {
		elements.set(name, element);
		//if (zIndex != null) zIndex.set(name, zIndex);
		//this.add(element);
	}

	public function getElement(name:String) {
		return elements.get(name);
	}

	public function removeElement(name:String, ?destroy:Bool = true) {
		var element = getElement(name);

		if (element != null) {
			elements.remove(name);
			if (destroy) element.destroy();
		}
	}

	public function addCharacter(name:String, char:Character) {
		characters.set(name, char);

		//this.add(char);
	}

	public function getCharacter(name:String) {
		return characters.get(name);
	}

	public function removeCharacter(name:String, ?destroy:Bool = true) {
		var char = getCharacter(name);

		if (char != null) {
			characters.remove(name);
			if (destroy) char.destroy();
		}
	}

	/*function sortByZIndex(Obj1, Obj2):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1, Obj2);
	}

	public function refresh() {
		sort(sortByZIndex);
	}*/

	public function clearStage():Void {
		for (element in elements) {
			//remove(element);
			element.destroy();
		}
		elements.clear();
		for (character in characters) {
			//remove(character);
			character.destroy();
		}
		characters.clear();
		functions.clear();
	}

	/*override function destroy():Void {
		clearStage();

		super.destroy();
	}*/

	public function addFunction(name:String, afunction:Dynamic) {
		functions.set(name, afunction);
	}

	public function getFunction(name:String) {
		return functions.get(name);
	}

	public function doFunction(name:String) {
		var method = getFunction(name);
		return method();
	}
}