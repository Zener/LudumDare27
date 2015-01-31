package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGame;
	import org.flixel.plugin.photonstorm.FlxSpecialFX;
	
	[SWF(width = "960", height = "720", backgroundColor = "#000000")] //Set the size and color of the Flash file
	
	/**
	 * ...
	 * @author Miguel Ángel Linares
	 */
	dynamic public class Main extends FlxGame
	{
		
		public function Main():void 
		{
			super(960, 720, MenuState, 1, 60, 60);
			
			// [AOC] Add the plugins we need
			if (FlxG.getPlugin(FlxSpecialFX) == null) {
				FlxG.addPlugin(new FlxSpecialFX);
			}
		}
	}
	
}