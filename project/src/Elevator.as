package  
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Miguel Ángel Linares
	 */
	public class Elevator extends FlxSprite
	{
		[Embed(source = "../assets/imgs/elevator1.png")] private var Img:Class;	//Graphic of the player
		
		public var speed : Number = 0.1;
		public var currentTime : Number = 0;
		public var initialY : Number = 0;
		public var amplitude : Number = 200;
		
		public function Elevator( _x : Number, _y:Number ) 
		{
			initialY = _y;
			super(_x, _y, Img);
			
			solid = true;
			immovable = true;
		}
		
		override public function update():void
		{
			currentTime += FlxG.elapsed;
			// y = initialY + Math.sin( currentTime ) * amplitude;
			// acceleration.x = acceleration.y = 0;
			velocity.y = Math.sin( currentTime ) * amplitude;;
		}
		
	}

}