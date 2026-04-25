import hscript.Interp;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSort;

typedef CharacterInfo = {
	var x:Int;
	var y:Int;
	var ?camOffsetX:Int;
	var ?camOffsetY:Int;
	var ?zIndex:Int;
	var ?scrollFactor:Array<Float>;
}

class StageHelper extends FlxSpriteGroup {
	public var interp:Interp;
	public var name:String = 'stage';
	public var defaultZoom:Float = 1.05;
	public var boyfriendInfo:CharacterInfo;
	public var dadInfo:CharacterInfo;
	public var gfInfo:CharacterInfo;

	public var elements:Map<String, Dynamic> = [];
	//public var characters:Map<String, Character> = [];
	public var zIndexes:Map<FlxSprite, Int> = [];
	var highestZ:Int = 0;
	public var functions:Map<String, Dynamic> = [];
	public function new(stageName:String = 'stage', ?stageInterp:Interp) {
		super();

		dadInfo = {x: 100, y: 100};
		gfInfo = {x: 400, y: 130};
		boyfriendInfo = {x: 770, y: 450};

		name = stageName;
		if (stageInterp != null) interp = stageInterp;
	}

	public function addElement(name:String, element:Dynamic, ?zIndex:Int) {
		elements.set(name, element);

		if ((element is FlxGroup)) {
			element.forEach(function(piece) {
				this.add(piece);
				setZIndex(piece, zIndex);
			});
		} else {
			this.add(element);
			setZIndex(element, zIndex);
		}
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

	/*public function addCharacter(name:String, char:Character, ?zIndex:Int = 0) {
		characters.set(name, char);

		zIndex.set(char, zIndex);
		this.add(char);
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
	}*/

	public function getZIndex(element:String) {
		return zIndexes.get(getElement(element));
	}

	public function setZIndex(element:Dynamic, zIndex:Int = -69) {
		if ((element is String)) element = getElement(element);

		if (zIndex == -69) zIndex = highestZ + 10;

		zIndexes.set(element, zIndex);
		if (zIndex > highestZ) highestZ = zIndex;
	}

	function sortByZIndex(order:Int, Obj1:FlxSprite, Obj2:FlxSprite):Int {
		return FlxSort.byValues(order, zIndexes.get(Obj1), zIndexes.get(Obj2));
	}

	public function refresh() {
		sort(sortByZIndex, FlxSort.ASCENDING);
	}

	public function clearStage():Void {
		for (element in elements) {
			remove(element);
			element.destroy();
		}
		elements.clear();
		/*for (character in characters) {
			remove(character);
			character.destroy();
		}
		characters.clear();*/
		functions.clear();
	}

	/*override function destroy():Void {
		clearStage();

		super.destroy();
	}*/

	override function preAdd(sprite:FlxSprite):Void {
		sprite.x += x;
		sprite.y += y;
		sprite.alpha *= alpha;
		sprite.cameras = _cameras;

		if (clipRect != null)
			clipRectTransform(sprite, clipRect);
	}

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