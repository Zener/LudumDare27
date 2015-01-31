package
{
	
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;

	/**
	 * Test class to do experiments.
	 * @author Alger Ortín Castellví
	 */
	public class AOCState extends FlxState
	{
		//--------------------------------------------------------------------//
		// EMBEDDED RESOURCES												  //
		//--------------------------------------------------------------------//
		// Sample spritesheet
		[Embed(source="bin/data/aoc/pez_abisal.png")]
		private static var TestSpritesheet:Class;
		
		[Embed(source="bin/data/aoc/pez_abisal.xml", mimeType="application/octet-stream")]
		private static var TestSpritesheetXML:Class;
		
		//--------------------------------------------------------------------//
		// MEMBERS															  //
		//--------------------------------------------------------------------//
		private var mTestSprite:FlxSprite;
		
		//--------------------------------------------------------------------//
		// METHODS															  //
		//--------------------------------------------------------------------//
		/**
		 * This function is called after the game engine successfully switches states.
		 * Override this function, NOT the constructor, to initialize or set up your game state.
		 * We do NOT recommend overriding the constructor, unless you want some crazy unpredictable things to happen!
		 */
		override public function create() : void
		{
			FlxG.visualDebug = true;
			
			mTestSprite = new FlxSprite();
			//mTestSprite.loadGraphic(TestSpritesheet, true, false, 122, 308);
			//mTestSprite.loadGraphic(TestSpritesheet, true, true, 236, 158);
			mTestSprite.loadGraphic(EmbeddedAssets.Level1Texture, true, true, 80, 80);
			
			//mTestSprite.addAnimationFromXML("anim", "pez_abisal", new XML(new TestSpritesheetXML()), 24, true);
			mTestSprite.addAnimationFromXML("idle", "bob_idle", new XML(new EmbeddedAssets()), 12, true);
			mTestSprite.addAnimationFromXML("eat", "bob_feed", new XML(new EmbeddedAssets()), 12, true);
			mTestSprite.addAnimationFromXML("run", "bob_move", new XML(new EmbeddedAssets()), 12, true);
			mTestSprite.addAnimationCallback(onAnimFrameFinishedCB);
			
			mTestSprite.x = FlxG.stage.stageWidth/2 - mTestSprite.width/2;
			mTestSprite.y = FlxG.stage.stageHeight/2 - mTestSprite.height/2;
			
			add(mTestSprite);
			mTestSprite.play("idle");
		}
		
		//--------------------------------------------------------------------//
		// CALLBACKS														  //
		//--------------------------------------------------------------------//
		/**
		 * Callback for when a frame of the sprite animation has finished.
		 */
		public function onAnimFrameFinishedCB(_animName:String, _curFrame:uint, _curSheetIdx:uint) : void
		{
			// If last frame, switch direction
			if(_curFrame == mTestSprite.getAnimation(_animName).frames.length - 1) {
				/*
				if(mTestSprite.facing == FlxObject.RIGHT) {
					mTestSprite.facing = FlxObject.LEFT;
				} else {
					mTestSprite.facing = FlxObject.RIGHT;
				}
				*/
				
				if(_animName == "run") {
					mTestSprite.play("eat");
				} else {
					mTestSprite.play("run");
				}
			}
		}
	}
}