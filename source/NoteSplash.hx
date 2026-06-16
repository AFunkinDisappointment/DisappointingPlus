package;
import flixel.FlxSprite;
import DynamicSprite.DynamicAtlasFrames;
import flixel.FlxG;
import Judgement.TUI;

class NoteSplash extends FlxSprite {
    public var isPixel:Bool = false;
    public var variants:Int = 0;
    public var frameRate:Int = 24;
    public function new(xPos:Float, yPos:Float, ?c:Int = 0, type:String = 'normal') {
        super(xPos, yPos);

		final curUiType:TUI = Reflect.field(Judgement.uiJson, type);
        isPixel = curUiType.isPixel;
        if (!isPixel) {
            if (FNFAssets.exists('assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.png'))
		        frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.png',
			        'assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.xml');
            else
        	    frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/normal/noteSplashes.png',
			        'assets/images/custom_ui/ui_packs/normal/noteSplashes.xml');
        } else {
            if (FNFAssets.exists('assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes-pixel.png'))
		        frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes-pixel.png',
			        'assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes-pixel.xml');
            else
        	    frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/normal/noteSplashes-pixel.png',
			        'assets/images/custom_ui/ui_packs/normal/noteSplashes-pixel.xml');
        }

        final currentKey = new NoteKeys(curUiType.uses);
        for (i in 0...Note.NOTE_AMOUNT) {
            final noteName = currentKey.getNote(i);
            final noteSplashes = currentKey.getSplashes(i);
            if (noteSplashes != null) {
                variants = noteSplashes.length;
                for (splash in 1...variants)
                    animation.addByPrefix("note${i}-" + splash, noteSplashes[splash], 24, false);
            } else {
                if (!isPixel) {
                    variants = 2;
                    animation.addByPrefix("note" + i + "-0", "note impact 1 " + noteName, 24, false);
                    animation.addByPrefix("note" + i + "-1", "note impact 2 " + noteName, 24, false);
                } else {
                    variants = 3;
                    animation.addByPrefix("note" + i + "-0", noteName + "1", 33, false);
                    animation.addByPrefix("note" + i + "-1", noteName + "2", 33, false);
                    animation.addByPrefix("note" + i + "-2", noteName + "3", 33, false);
                    frameRate = 33;
                }
            }
        }

        if (isPixel) {
            antialiasing = false;
            scale.set(4, 4);
            updateHitbox();
        } else
            antialiasing = true;

        setupNoteSplash(xPos,xPos,c);
    }

    public function setupNoteSplash(xPos:Float, yPos:Float, ?c:Int = 0) {
        setPosition(xPos, yPos);
        alpha = 0.6;
        animation.play("note" + c + "-" + FlxG.random.int(0,variants-1), true);
		animation.curAnim.frameRate = frameRate + FlxG.random.int(-2, 2);
        updateHitbox();
        if (!isPixel)
            offset.set(0.3 * width, 0.3 * height);
        else
            offset.set(0.5, 13.5);
    }

    override public function update(elapsed) {
        if (animation.curAnim.finished) {
            // club pengiun is
            kill();
        }
        super.update(elapsed);
    }
}