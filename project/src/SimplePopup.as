package
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;

	public class SimplePopup
	{
		private var background:FlxSprite;
		private var text:FlxText;
		private var parent:FlxState;
		
		public function SimplePopup(_parent:FlxState, x:int, y:int, width:int, height:int)
		{
			parent = _parent;
			background = new FlxSprite(x, y);
			background.makeGraphic(width, height, 0x80000000);
			
			text = new FlxText( x+10, y+10, width, "");
			text.size = 24;
			text.alignment = "center";
			
			background.scrollFactor.x = background.scrollFactor.y = 0;
			text.scrollFactor.x = text.scrollFactor.y = 0;			
			
			parent.add(background);
			parent.add(text);
		}
		
		public function setText(s:String):void
		{
			text.text = s;
		}
		
		public function close():void
		{
			parent.remove(text);
			parent.remove(background);
		}
	}
}