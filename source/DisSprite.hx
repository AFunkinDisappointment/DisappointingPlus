package;

import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;
import animate.FlxAnimate;
import flixel.graphics.frames.FlxAtlasFrames;
import DynamicSprite.DynamicAtlasFrames;
import animate.FlxAnimateFrames;

import openfl.display.BlendMode;
import flixel.FlxCamera;
//import flixel.system.FlxAssets.FlxShader;

/*
 * A fancy sprite with graphic loading shortcuts and FlxSpriteGroup-type parenting
 */
class DisSprite extends FlxAnimate {
    public var children:Array<FlxSprite>; // the children tied to this sprite
    public var parentPos:Int = -1; // the z-index of the parent relative to the positions of the children array

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
	}

    // loading sprite stuff

	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String) {
        if ((Graphic is String)) {
            // show time baby
            var data = FNFAssets.getBitmapData(Graphic);
            return super.loadGraphic(data, Animated, Width, Height, Unique, Key);
        }
        return super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
    }

    public function loadSparrow(png:FlxGraphicAsset, ?xml:String) {
        if (xml == null) {
            if ((png is String)) {
                xml = png + '.xml';
                png += '.png';
            } else
                return this;
        }

        frames = DynamicAtlasFrames.fromSparrow(png, xml);
        return this;
    }
    /*public function addSparrow(png:FlxGraphicAsset, xml:String) {
        var addedFrames = DynamicAtlasFrames.fromSparrow(png, xml);
        return frames.addAtlas(addedFrames);
    }*/

    public function loadSpriteSheetPacker(png:FlxGraphicAsset, ?txt:String) {
        if (txt == null) {
            if ((png is String)) {
                txt = png + '.txt';
                png += '.png';
            } else
                return this;
        }

        frames = DynamicAtlasFrames.fromSpriteSheetPacker(png, txt);
        return this;
    }
    /*public function addSpriteSheetPacker(png:FlxGraphicAsset, txt:String) {
        if (!(frames is FlxAtlasFrames)) return this;

        var addedFrames = DynamicAtlasFrames.fromSpriteSheetPacker(png, txt);
        return frames.addAtlas(addedFrames);
    }*/

    public function loadTextureAtlas(path:String) {
        frames = FlxAnimateFrames.fromAnimate(path);
        return this;
    }
    /*public function addTextureAtlas(path:String) {
        if (!(frames is FlxAtlasFrames)) return this;

        var addedFrames = FlxAnimateFrames.fromAnimate(path);
        return frames.addAtlas(addedFrames);
    }*/

    // children stuff

    public function addChild(child:FlxSprite, ?attached:Bool = true) {
        if (children == null) initParenthood();

        children.push(child);
        if (attached) { 
            child.x += this.x;
            child.y += this.y;
            child.angle += this.angle;
            child.scrollFactor.copyFrom(this.scrollFactor);
        }
        return this;
    }

    public function removeChild(child:FlxSprite, ?unattach:Bool = true) {
        if (children == null || !children.contains(child)) return this;

        children.remove(child);
        if (unattach) {
            child.x -= this.x;
            child.y -= this.y;
            child.angle -= this.angle;
        }
        return this;
    }

    public function removeChildren(?destroy:Bool = false) {
        if (destroy)
            for (child in children) {
                // destroy child
                FlxDestroyUtil.destroy(child);
            }
        children = [];
    }

    // simple function to place the parent at the end of the currently added children (position used when drawing)
    public function insertParent() {
        if (children != null)
            parentPos = children.length;
        return this;
    }

    // for adding a child of children of its own to avoid inconsistencies
    public function adoptChildren(childHaver:DisSprite) {
        var takenParent = false;
        for (i in 0...childHaver.children.length) {
            final child = childHaver.children[i];
            if (i == childHaver.parentPos) {
                takenParent = true;
                addChild(childHaver, false);
            }
            if (child != null)
                addChild(child, false);
        }
        if (!takenParent) addChild(childHaver, false);
        childHaver.removeChildren();
    }

    // flxspritegroup stuff

    // dis sprite is gonna be a mama
    function initParenthood():Void {
        children = [];

        scrollFactor = new FlxCallbackPoint(scrollFactorCallback);
        origin = new FlxCallbackPoint(originCallback);

        scrollFactor.set(1, 1);
    }

    function scrollFactorCallback(daFactor:FlxPoint) {
        for (child in children) {
            child.scrollFactor.copyFrom(daFactor);
        }
    }
    
    function originCallback(daOrigin:FlxPoint) {
        for (child in children) {
            child.origin.copyFrom(daOrigin);
        }
    }

    override public function draw():Void {
        if (children != null && children.length > 0) {
            var drawnParent = false;
            for (i in 0...children.length) {
                final child = children[i];
                if (i == parentPos) {
                    drawnParent = true;
                    super.draw();
                }
                if (child != null && child.visible)
                    child.draw();
            }
            if (!drawnParent) super.draw();
        } else
            super.draw();
    }

    override public function update(elapsed):Void {
        if (children != null && children.length > 0) {
            for (child in children) {
                if (child != null && child.active)
                    child.update(elapsed);
            }
        }

        super.update(elapsed);
    }

    function setThingy(thingy:String, value:Dynamic, ?offseted:Bool = false) {
        if (children != null && children.length > 0) {
            for (child in children) {
                var childvar = Reflect.getProperty(child, thingy);
                if (childvar != value) {
                    if (offseted)
                        Reflect.setProperty(child, thingy, childvar + value - Reflect.getProperty(this, thingy));
                    else
                        Reflect.setProperty(child, thingy, value);
                }
            }
       }
    }

    override function set_x(value:Float):Float {
        setThingy('x', value, true);
        return x = value;
    }

    override function set_y(value:Float):Float {
        setThingy('y', value, true);
        return y = value;
    }

    override function set_angle(value:Float):Float {
        setThingy('angle', value, true);
        return super.set_angle(value);
    }

    override function set_flipX(value:Bool):Bool {
        setThingy('flipX', value);
        return flipX = value;
    }

    override function set_flipY(value:Bool):Bool {
        setThingy('flipY', value);
        return flipY = value;
    }

    override function set_alpha(value:Float):Float {
        /*if (children != null && children.length > 0) {
            if (alpha != value)
                for (child in children) child.alpha = value;
        }*/
        setThingy('alpha', value);
        return super.set_alpha(value);
    }

    override function set_visible(value:Bool):Bool {
        setThingy('visible', value);
        return super.set_visible(value);
    }

    override function set_camera(value:FlxCamera):FlxCamera {
        setThingy('camera', value);
        return super.set_camera(value);
    }

    override function set_cameras(value:Array<FlxCamera>):Array<FlxCamera> {
        setThingy('_cameras', value);
        return super.set_cameras(value);
    }

    override function set_color(value:Int):Int {
        setThingy('color', value);
        return super.set_color(value);
    }

    override function set_blend(value:BlendMode):BlendMode {
        setThingy('blend', value);
        return blend = value;
    }

    override public function destroy():Void {
        if (children != null) {
            removeChildren();
            scrollFactor = FlxDestroyUtil.destroy(scrollFactor);
            origin = FlxDestroyUtil.destroy(origin);
        }

        super.destroy();
    }
}