package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;
#if typebuild
import plugins.ExamplePlugin;
import plugins.ExamplePlugin.ExampleCharPlugin;
#end
class Main extends Sprite {
	#if sys
	public static var cwd:String;
	#end
	public static var distray:DisSoundTray;
	public static var memoryCounter:MemoryCounter;
	public function new() {
		#if typebuild
			// god is dead
			ExamplePlugin;
			ExampleCharPlugin;
		#end
		super();
		#if sys
		cwd = Sys.getCwd();
		#end
		addChild(new FlxGame(0, 0, TitleState, OptionsHandler.options.fpsCap, OptionsHandler.options.fpsCap, true));

		distray = new DisSoundTray();
		addChild(distray);
		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		memoryCounter = new MemoryCounter(10, 3, 0xFFFFFF);
		memoryCounter.visible = false;
		addChild(memoryCounter);
		#end
	}
}
