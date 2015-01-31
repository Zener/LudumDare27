package  
{
	import Entities.*;
	
	import flash.display.ColorCorrectionSupport;
	
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	/**
	 * ...
	 * @author Miguel Ángel Linares
	 */
	public class ThirdState  extends FlxState
	{
		// Tileset that works with AUTO mode (best for thin walls)
		[Embed(source = '../assets/tilemaps/test_1/tileset.png')]private static var auto_tiles:Class;
		// Default tilemaps. Embedding text files is a little weird.
		[Embed(source = '../assets/tilemaps/test_1/mar_tilemap_export.json', mimeType = 'application/octet-stream')]private static var tilemap:Class;
		
		protected var player : Player;
		protected var ui : UI;
		protected var world  : World;
		protected var enemies : FlxGroup;
		
		public function ThirdState() 
		{
			FlxG.bgColor = 0xff801060;
		}
		
		override public function create():void
		{
			player =  new Player(2);
			player.controlSystem = 2;
			add(player);
			FlxG.camera.follow(player);
			
			var data:String = new tilemap();
			var rawData:Object = JSON.parse(data);
			world = new World(rawData, auto_tiles);
			add( world );
			player.setWorld(world);
			
			world.collisionMap.visible = true;
			
			enemies = new FlxGroup;
			add(enemies);
			
			for (var i:int = 0; i < 8;i++)
			{
				var enemy1:EnemyBase = new WaterEnemy(WaterEnemy.TYPE_SARDINE);
				enemy1.setPlayer(player);
				enemies.add(enemy1);
				enemy1.x = Math.random() * world.collisionMap.width;
				enemy1.y = Math.random() * world.collisionMap.height;
			}
			
			ui =  new UI();			
			add(ui);
		}
		
		
		override public function update():void
		{
			FlxG.collide( player, world.collisionMap );
			
			
			for each( var sp1 : EnemyBase in enemies.members )
			{
				if ( sp1 != null)
				{
					FlxG.collide( sp1, world.collisionMap );
				}
				
				// if ( FlxCollision.pixelPerfectCheck( sp1.currentCollision, player ) )
				if ( sp1 != null && FlxG.overlap(sp1,player, null,null) )
				{
					player.eatEnemy( sp1 );
					ui.resetCountdown();
					enemies.remove( sp1 );				
					break;
				}
			}
			// FlxG.collide(theEmitter, world.collisionMap);
			super.update();
			
		}
	}

}