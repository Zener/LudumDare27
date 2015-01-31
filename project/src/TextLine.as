package  
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Miguel Ángel Linares
	 */
	public class TextLine extends FlxText
	{
		
		private var duration : Number = 0;
		private var currentTime : Number = 0;
		private var yDelta : Number = 0;
		
		private var player : FlxObject;
		private var group : FlxGroup;
		
		public function TextLine( s : String,  p : FlxObject,g: FlxGroup ) 
		{
			super(0,-250,500,s);
			size = 16;
			alignment = "center";	
			duration = 1.0;
			currentTime = duration;
			
			player = p;
			group = g;
			
			group.add( this );
		}
		
		override public function update():void
		{
			currentTime -= FlxG.elapsed;
			
			if (currentTime >= 0)
			{
				alpha = currentTime / duration;
				yDelta -= FlxG.elapsed * 100;
				x = player.x - 250 + 40;
				y = player.y + yDelta;
			}
			else
			{
				group.remove(this);
				kill();
			}
			
		}
		
	}

}