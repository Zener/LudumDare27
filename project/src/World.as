package  
{
	import flash.display.Bitmap;
	import org.flixel.system.FlxTile;
	
	import org.flixel.*;

	/**
	 * ...
	 * @author Miguel Ángel Linares
	 */
	public class World extends FlxGroup
	{
		// Tileset that works with AUTO mode (best for thin walls)
		[Embed(source = '../assets/tilemaps/test_1/auto_tiles.png')]private static var auto_tiles:Class;
		
		// Tileset that works with ALT mode (best for thicker walls)
		[Embed(source = '../assets/tilemaps/test_1/alt_tiles.png')]private static var alt_tiles:Class;
		
		// Tileset that works with OFF mode (do what you want mode)
		[Embed(source = '../assets/tilemaps/test_1/empty_tiles.png')]private static var empty_tiles:Class;
		
		// Default tilemaps. Embedding text files is a little weird.
		[Embed(source = '../assets/tilemaps/test_1/default_auto.txt', mimeType = 'application/octet-stream')]private static var default_auto:Class;
		[Embed(source = '../assets/tilemaps/test_1/default_alt.txt', mimeType = 'application/octet-stream')]private static var default_alt:Class;
		[Embed(source = '../assets/tilemaps/test_1/default_empty.txt', mimeType = 'application/octet-stream')]private static var default_empty:Class;

		
		// Some static constants for the size of the tilemap tiles
		public static const TILE_WIDTH:uint = 32;
		public static const TILE_HEIGHT:uint = 32;
		
		
		// The FlxTilemap we're using
		public var collisionMap : FlxTilemap;
		public var platformsMaps : FlxGroup;
		
		public var mapWidth:int;
		public var mapHeight:int;
		
		public function World(rawData:Object, tiles:Class) 
		{
			// Creates a new tilemap with no arguments
			collisionMap = new FlxTilemap();
			
			//var data:String = new tilemap();
			//var rawData:Object = JSON.parse(data);

			mapWidth =  rawData.width; 
			mapHeight = rawData.height;
			
			platformsMaps = new FlxGroup;
			add( platformsMaps );
			for each( var l : Object in rawData.layers )
			{
				var flixerMap:String = convertToFlixerMap(l.data, rawData.width, rawData.height);
				
				if ( l.name == "colisiones" )
				{
					// Initializes the map using the generated string, the tile images, and the tile size
					collisionMap.loadMap(flixerMap, tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.OFF, 0,1, 1);
					add( collisionMap );
					collisionMap.visible = true;
				}
				else if (l.name == "plataformas")
				{
					var platMap : FlxTilemap = new FlxTilemap();
					platMap.loadMap(flixerMap, tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.OFF, 0,1, 1);
					platformsMaps.add( platMap );
					platMap.visible = true;
				}
				else
				{
					var visualMap : FlxTilemap = new FlxTilemap();
					visualMap.loadMap(flixerMap, tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.OFF, 0,1, 1);
					add( visualMap );
					visualMap.visible = true;
				}
			}
			
			
			
			FlxG.camera.setBounds(0,0,mapWidth*TILE_WIDTH,mapHeight*TILE_HEIGHT,true);
		}


		// Adds returns for each map line
		public function convertToFlixerMap(inCVS:String, w:int, h:int):String
		{
			var out:String = "";
			
			var i:int = 0;
			var c:String;
			var k:int = 0;
			while (i < inCVS.length)
			{
				c = inCVS.charAt(i++);
				if (c == ",") k++;
				if (k == w){ out = out + "\n";k = 0; }
				else out = out + c;				
			}
			
			return out;
		}
	}

}