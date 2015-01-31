package 
{
	/**
	 * Enum class to group all the player's embedded assets.
	 * @author Alger Ortín Castellví
	 */
	final public class EmbeddedAssets
	{
		//--------------------------------------------------------------------//
		// PLAYER ASSETS													  //
		//--------------------------------------------------------------------//
		// Level 1 spritesheet
		// Texture
		[Embed(source="../assets/spritesheets/player/level1/bob_animations.png")]
		public static const Level1Texture:Class;
		
		// XML
		[Embed(source="../assets/spritesheets/player/level1/bob_animations.xml", mimeType="application/octet-stream")]
		public static const Level1XML:Class;
		
		// [AOC] TODO!!
		// Level 2 spritesheet
		// Texture
		[Embed(source="../assets/spritesheets/player/level2/bob02_animations.png")]
		public static const Level2Texture:Class;
		
		// XML
		[Embed(source="../assets/spritesheets/player/level2/bob02_animations.xml", mimeType="application/octet-stream")]
		public static const Level2XML:Class;
		
		// [AOC] TODO!!
		// Level 3 spritesheet
		/*
		// Texture
		[Embed(source="../assets/spritesheets/player/level3/bob_animations.png")]
		public static var Level3Texture:Class;
		
		// XML
		[Embed(source="../assets/spritesheets/player/level3/bob_animations.xml", mimeType="application/octet-stream")]
		public static var Level3XML:Class;
		*/
		
		//--------------------------------------------------------------------//
		// SOUND FX															  //
		//--------------------------------------------------------------------//
		// Some sound FX
		[Embed(source="../assets/sfx/success.mp3")]
		public static const SuccessSFX:Class;
		
		[Embed(source="../assets/sfx/failure.mp3")] 
		public static const FailureSFX:Class;
	}
}