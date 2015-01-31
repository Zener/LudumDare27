package  
{
	import org.flixel.*;
 
	public class Light extends FlxSprite 
	{
		[Embed(source="../assets/imgs/light.png")] private var LightImageClass:Class;
 
		private var darkness:FlxSprite;
    
		public function Light(x:Number, y:Number, darkness:FlxSprite):void 
		{
			super(x, y, LightImageClass);
			this.darkness = darkness;
			this.blend = "lighten"
			this.alpha = 0.3;
		}
 
		/*override public function draw():void 
		{
			var screenXY:FlxPoint = getScreenXY();
			darkness.stamp(this,screenXY.x - this.width / 2,screenXY.y - this.height / 2);
		}*/
	}

}