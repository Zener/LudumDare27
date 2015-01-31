package
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Quadratic;
	
	import flash.display.BitmapData;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Point;
	
	import org.flixel.*;

	public class MenuState extends FlxState
	{
		[Embed(source="../assets/sfx/apearandogres.mp3")] private var musicTheme:Class;
		[Embed(source = '../assets/tilemaps/state1/mar_bg.png')]private static var backgroundImg:Class;
		
		private var option1:FlxText;
		private var option2:FlxText;
		private var option3:FlxText;
		
		private var disp:DisplacementMapFilter;
		private var fxData:BitmapData;
		private var fxDataVector:Vector.<BitmapData> = new Vector.<BitmapData>;
		private var filterPt:Point;
		private var flxFilterPt:FlxPoint;
		private var offsets:Array = [new Point(0, 0), new Point(0, 0)];
		private var background:FlxSprite;
	
		
		override public function create():void
		{
			background = new FlxSprite(0,0, backgroundImg);
			add (background);
			
			var t:FlxText;
			t = new FlxText(0,FlxG.height/2-220,FlxG.width,"Bloody Bob");
			t.size = 64;
			t.alignment = "center";
			add(t);
			
			new GTween(t, 1, {y:t.y + 25}, {ease:Quadratic.easeIn, repeatCount:0, reflect:true});
			
			option1 = new FlxText(FlxG.width/2-200,FlxG.height-230,400,"Click to start");
			option1.size = 24;
			option1.alignment = "center";
			add(option1);

			/*option2 = new FlxText(FlxG.width/2-200,FlxG.height-180,400,"click to play second state");
			option2.size = 16;
			option2.alignment = "center";
			add(option2);*/
			
			
			FlxG.mouse.show();
			
			if (FlxG.music) FlxG.music.stop();
			FlxG.play(musicTheme,1,true);
		
			/*fxData = new BitmapData(960, 800);
			filterPt = new Point(0, 0);
			flxFilterPt = new FlxPoint(0, 0);
			disp = new DisplacementMapFilter(fxData, filterPt, 1, 2, 20, 25, DisplacementMapFilterMode.CLAMP);  

			
			
			for(var i:int = 0; i < 5; i++)
			{				
				offsets[0].x -=1;  // animate effect points
				offsets[1].y -= 1;  
				var bp:BitmapData = new BitmapData(960, 800);
				bp.perlinNoise(10, 10, 1 , 0, false, false, 7, true, offsets);  
				fxDataVector[i] = bp;
			}
			for(var i:int = 0; i < 5; i++)
			{
				fxDataVector[5+i] = fxDataVector[4-i];
			}*/
		}

		
		//var k:int = 0;
		override public function update():void
		{
			super.update();

			/*fxData.copyPixels(fxDataVector[(k++)%10],new Rectangle(0,0,960,800), new Point());	
			
			FlxG.camera.getContainerSprite().filters = [disp];*/
			
			var nextState:FlxState = null; 
			if(FlxG.mouse.justPressed())
			{
				//if (FlxMath.pointInFlxRect(FlxG.mouse.x, FlxG.mouse.y, new FlxRect(option1.x, option1.y, option1.width, option1.height)) == true)
				{
					nextState = new FirstState(true);
				}
				/*if (FlxMath.pointInFlxRect(FlxG.mouse.x, FlxG.mouse.y, new FlxRect(option2.x, option2.y, option2.width, option2.height)) == true)
				{
					nextState = new SecondState(true);
				}*/
					
			}
			
			if(FlxG.keys.F1) {
				nextState = new CreditsState(true);
			} else if (FlxG.keys.any()) {
				nextState = new FirstState(true);
			}	
			
			if(nextState != null) {
				if (FlxG.music) FlxG.music.stop();
				FlxG.switchState(nextState);
			}
		}
	}
}
