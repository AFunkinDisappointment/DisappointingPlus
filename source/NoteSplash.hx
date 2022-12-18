package;
import flixel.FlxSprite;
import DynamicSprite.DynamicAtlasFrames;
import flixel.FlxG;
import Judgement.TUI;
class NoteSplash extends FlxSprite {
    public function new(xPos:Float,yPos:Float,?c:Int) {
        if (c == null) c = 0;
        super(xPos,yPos);
		var curUiType:TUI = Reflect.field(Judgement.uiJson, PlayState.SONG.uiType);
        if (FNFAssets.exists('assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.png')) {
		    frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.png',
			    'assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.xml');
        } else {
        	frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/normal/noteSplashes.png',
			    'assets/images/custom_ui/ui_packs/normal/noteSplashes.xml');
        }
        var notePresets;
		if (FNFAssets.exists('assets/images/custom_ui/ui_packs/' + curUiType.uses + '/multiNotePresets.json')) {
			notePresets = CoolUtil.parseJson(FNFAssets.getText('assets/images/custom_ui/ui_packs/' + curUiType.uses + '/multiNotePresets.json'));
		} else {
			notePresets = CoolUtil.parseJson(FNFAssets.getText('assets/data/defaultNotePresets.json'));
		}
		var currentKey = Reflect.field(notePresets, 'key' + Note.NOTE_AMOUNT);
        for (i in 0...Note.NOTE_AMOUNT) {
            var noteName = currentKey[i].note;
            animation.addByPrefix("note" + i + "-0", "note impact 1 " + noteName, 24, false);
            animation.addByPrefix("note" + i + "-1", "note impact 2 " + noteName, 24, false);
        }
        setupNoteSplash(xPos,xPos,c);
    }
    public function setupNoteSplash(xPos:Float, yPos:Float, ?c:Int) {
        if (c == null) c = 0;
        setPosition(xPos, yPos);
        alpha = 0.6;
        animation.play("note" + c + "-" + FlxG.random.int(0,1), true);
		animation.curAnim.frameRate += FlxG.random.int(-2, 2);
        updateHitbox();
        offset.set(0.3 * width, 0.3 * height);
    }
    override public function update(elapsed) {
        if (animation.curAnim.finished) {
            // club pengiun is
            kill();
        }
        super.update(elapsed);
    }
}