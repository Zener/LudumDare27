package Entities
{
	import flash.geom.Vector3D;
	
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;

	public class WaterEnemy extends EnemyBase
	{
		//--------------------------------------------------------------------//
		// EMBEDDED ASSETS													  //
		//--------------------------------------------------------------------//
		// Texture
		[Embed(source="../../assets/spritesheets/enemies/peces_animations.png")]
		private static var SpritesheetTexture:Class;
		
		// XML
		[Embed(source="../../assets/spritesheets/enemies/peces_animations.xml", mimeType="application/octet-stream")]
		private static var SpritesheetXML:Class;
		
		
		//--------------------------------------------------------------------//
		// CONSTANTS														  //
		//--------------------------------------------------------------------//
		private static const MAX_SPEED : int = 150;
		private static const DISTANCE_TO_PANIC : int = 100;
		
		private static const ANIM_MOVE:String = "move"; 
		
		public static const TYPE_SARDINE:String = "sardina";
		public static const TYPE_ABYSSAL:String = "abisal";
		
		//--------------------------------------------------------------------//
		// MEMBERS															  //
		//--------------------------------------------------------------------//
		
	
		//--------------------------------------------------------------------//
		// METHODS															  //
		//--------------------------------------------------------------------//
		/**
		 * @param _type One of the WaterEnemy.TYPE_* constants
		 */
		public function WaterEnemy(_type:String)
		{
			super(0, 0);
			name = _type;
			acceleration.x = 0;
			acceleration.y = 0;
			maxVelocity.x = 100;
			maxVelocity.y = 100;
			
			// [AOC] Load graphic and animation
			loadGraphic(SpritesheetTexture, true, true, 80, 80);	// Size of the first animation
			addAnimationFromXML(ANIM_MOVE, _type, new XML(new SpritesheetXML()), 24, true);
			play(ANIM_MOVE);
		}
		
		
		override public function update():void
		{
			var d:Number = distanceToPlayer();
			if (d < DISTANCE_TO_PANIC)
			{
				var v:Vector3D = new Vector3D((x - player.x) / d, (y - player.y) / d);
				velocity.x = MAX_SPEED*v.x;
				velocity.y = MAX_SPEED*v.y;				
			}
			
			acceleration.x += (Math.random() - Math.random())*20;
			acceleration.y += (Math.random() - Math.random())*20;
			
			var tX:Number = x / World.TILE_WIDTH;
			var tY:Number = y / World.TILE_HEIGHT;
			if (tX < 0.5  ||  tX >= world.mapWidth-1)
			{
				acceleration.x = 0;
				if (tX < 0.5)
				{
					x = 0.5 * World.TILE_WIDTH;
					velocity.x = Math.abs(velocity.x);
				}
				if (tX > world.mapWidth-1)
				{
					x = (world.mapWidth-1) * World.TILE_WIDTH;
					velocity.x = -Math.abs(velocity.x);
				}
			}
			if (tY < 1  || tY >= world.mapHeight-1)
			{
				velocity.y = -velocity.y;
				acceleration.y = 0;
			}
			
			
				
			
			// [AOC] Update asset's orientation (leave the same if not moving)
			if(velocity.x > 0) {
				facing = FlxObject.LEFT;
			} else if(velocity.x < 0) {
				facing = FlxObject.RIGHT;
			}
			
			super.update();
		}
		
		public function distanceToPlayer():Number
		{
			return Math.sqrt((player.x - x)*(player.x - x) + (player.y - y)*(player.y - y));
		}
		
	}
}