import hscript.Interp;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSort;
import flixel.math.FlxPoint;

typedef CharacterInfo = {
	var x:Float;
	var y:Float;
	var camOffsetX:Int;
	var camOffsetY:Int;
	var scrollFactor:FlxPoint;
	var zIndex:Int;
}

class StageHelper extends FlxSpriteGroup {
	public var interp:Interp;
	public var name:String = 'stage';
	public var defaultZoom:Float = 1.05;

	public var bfInfo:CharacterInfo;
	public var dadInfo:CharacterInfo;
	public var gfInfo:CharacterInfo;

	public var elements:Map<String, Dynamic> = [];
	public var zIndexes:Map<FlxSprite, Int> = [];
	var highestZ:Int = 0;
	public var functions:Map<String, Dynamic> = [];

	public function new(stageName:String = 'stage', ?stageInterp:Interp) {
		super();

		dadInfo = defaultInfo('dad');
		gfInfo = defaultInfo('gf');
		bfInfo = defaultInfo('bf');

		name = stageName;
		if (stageInterp != null) interp = stageInterp;
	}

	// Char Infos

	public static function defaultInfo(?char:String = 'dad') {
		var info:CharacterInfo = {x: 100, y: 100, camOffsetX: 0, camOffsetY: 0, scrollFactor: FlxPoint.get(1, 1), zIndex: -69};
		switch(char) {
			case 'bf':
				info.x = 770;
				info.y = 450;
			case 'gf':
				info.x = 400;
				info.y = 130;
		}
		return info;
	}

	public function setOffsets(char:String = 'dad', offx:Float = 0, offy:Float = 0, ?addition:Bool = true) {
		var info = getInfo(char);
		if (addition) {
			offx += info.x;
			offy += info.y;
		}
		info.x = offx;
		info.y = offy;
		return this;
	}

	public function setCamOffsets(char:String = 'dad', offx:Int = 0, offy:Int = 0, ?addition:Bool = true) {
		var info = getInfo(char);
		if (addition) {
			offx += info.camOffsetX;
			offy += info.camOffsetY;
		}
		info.camOffsetX = offx;
		info.camOffsetY = offy;
		return this;
	}

	public function setScrollFactor(char:String = 'dad', scrollx:Float = 1, scrolly:Float = 1) {
		getInfo(char).scrollFactor.set(scrollx, scrolly);
		return this;
	}

	public function getInfo(char:String = 'dad') {
		switch(char) {
			case 'dad': return dadInfo;
			case 'bf' | 'boyfriend': return bfInfo;
			case 'gf': return gfInfo;
			default: return null;
		}
	}

	// Elements

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

	// Z Index

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

	// Functions

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

	// Sprite Group Stuff

	public function clearStage():Void {
		for (element in elements) {
			remove(element);
			element.destroy();
		}
		elements.clear();
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
}