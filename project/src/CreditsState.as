package
{
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;

	/**
	 * Test class to do experiments.
	 * @author Alger Ortín Castellví
	 */
	public class CreditsState extends FlxState
	{
		//--------------------------------------------------------------------//
		// EMBEDDED RESOURCES												  //
		//--------------------------------------------------------------------//
		// Credits cinematic - 3 parts
		[Embed(source = "../assets/cinematics/cine_03_01_b.swf", symbol="cine_03_01")]
		private static const Cinematic1:Class;
		
		[Embed(source = "../assets/cinematics/cine_03_02_b.swf", symbol="cine_03_02")]
		private static const Cinematic2:Class;
		
		[Embed(source = "../assets/cinematics/cine_03_03_b.swf", symbol="cine_03_03")]
		private static const Cinematic3:Class;
		
		// Music
		[Embed(source="../assets/sfx/brownninjas.mp3")]
		private static const CreditsMusic:Class;
		
		//--------------------------------------------------------------------//
		// MEMBERS															  //
		//--------------------------------------------------------------------//
		private var mAnimSequence:Array;
		private var mCurrentAnimIdx:int;
		private var mCurrentAnimMC:MovieClip;
		private var mLastFrame:int;
		
		private var mInputCountdown:Number;
		
		//--------------------------------------------------------------------//
		// METHODS															  //
		//--------------------------------------------------------------------//
		/**
		 * @param _justCredits Wheter to show the full anim sequence including the game's ending or just the final credits part.
		 */
		public function CreditsState(_justCredits:Boolean = false)
		{
			// Show full anim sequence or just credits?
			if(_justCredits) {
				mAnimSequence = [Cinematic3];
			} else {
				mAnimSequence = [Cinematic1, Cinematic2, Cinematic3];
			}
		}
		
		/**
		 * This function is called after the game engine successfully switches states.
		 * Override this function, NOT the constructor, to initialize or set up your game state.
		 * We do NOT recommend overriding the constructor, unless you want some crazy unpredictable things to happen!
		 */
		override public function create() : void
		{
			// Launch 1st cinematic
			launchAnim(0);
			
			// Start music
			if(FlxG.music) FlxG.music.stop();
			FlxG.playMusic(CreditsMusic);
			
			// Adjust the framerate to the animation speed
			FlxG.flashFramerate = 24;
			
			// Wait some time before allowing the user to skip the credits
			mInputCountdown = 10;	// 10 sec
		}
		
		/**
		 * 
		 */
		override public function update() : void
		{
			// Check if the current anim has finished
			if(mCurrentAnimMC != null) {
				//if(mCurrentAnimMC.currentFrame == mCurrentAnimMC.totalFrames) {
				if(mLastFrame > mCurrentAnimMC.currentFrame) {
					// If it's not the last animation in the sequence, launch next one
					if(mCurrentAnimIdx < mAnimSequence.length - 1) {
						// Clear current cinematic
						FlxG.stage.removeChild(mCurrentAnimMC);
						launchAnim(mCurrentAnimIdx + 1);
					} else {
						// Sequence has finished, stop anim and wait for user input
						mCurrentAnimMC.gotoAndStop(mCurrentAnimMC.totalFrames - 1);
					}
				}
				
				// Update last frame
				mLastFrame = mCurrentAnimMC.currentFrame;
			}
			
			// If user presses any key, go to main menu
			mInputCountdown -= FlxG.elapsed;
			if(FlxG.keys.any() && mInputCountdown < 0) {
				// Clear current cinematic
				FlxG.stage.removeChild(mCurrentAnimMC);
				
				// Stop music
				if(FlxG.music) FlxG.music.stop();
				
				// Restore framerate
				FlxG.flashFramerate = 60;
				
				// Go back to the main menu
				FlxG.switchState(new MenuState());
			}
		}
		
		/**
		 * 
		 */
		private function launchAnim(_animIdx:int) : void
		{
			// Update index
			mCurrentAnimIdx = _animIdx;
			
			// Create MC
			mCurrentAnimMC = new mAnimSequence[_animIdx]();
			
			// Do some black magic to correct position
			var posRefDO:DisplayObject = mCurrentAnimMC.getChildByName("pos_ref");
			mCurrentAnimMC.x = -posRefDO.x;
			mCurrentAnimMC.y = -posRefDO.y;
			posRefDO.visible = false;
			
			// Add it to stage and play
			FlxG.stage.addChild(mCurrentAnimMC);
			mCurrentAnimMC.play();
			mLastFrame = 0;
		}
	}
}