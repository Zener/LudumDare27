package Entities
{
	import flash.geom.Vector3D;
	
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	
	
	public class GroundEnemy extends EnemyBase
	{
		//--------------------------------------------------------------------//
		// EMBEDDED ASSETS													  //
		//--------------------------------------------------------------------//
		// Texture
		[Embed(source="../../assets/spritesheets/enemies/citizens.png")]
		private static var SpritesheetTexture:Class;
		[Embed(source="../../assets/spritesheets/enemies/zombies.png")]
		private static var SpritesheetZombieTexture:Class;
		
		
		// XML
		[Embed(source="../../assets/spritesheets/enemies/citizens.xml", mimeType="application/octet-stream")]
		private static var SpritesheetXML:Class;
		[Embed(source="../../assets/spritesheets/enemies/zombies.xml", mimeType="application/octet-stream")]
		private static var SpritesheetZombieXML:Class;
		
		
		[Embed(source="../../assets/sfx/grito02.mp3")] private var screamSound1:Class;
		[Embed(source="../../assets/sfx/grito03.mp3")] private var screamSound2:Class;
		[Embed(source="../../assets/sfx/grito04.mp3")] private var screamSound3:Class;
		
		[Embed(source = "../../assets/imgs/enemy001.png")] private var ImgPlayer:Class;	//Graphic of the enemy
		
		//--------------------------------------------------------------------//
		// CONSTANTS														  //
		//--------------------------------------------------------------------//
		private static const MAX_SPEED : int = 150;
		private static const DISTANCE_TO_PANIC : int = 250;
		private var allowJump : Boolean = true;
		private var state:int = 0;
		
		private static const ZOMBIE_SPAWN_PROBABILITY:Number = 0.045;	// [0..1]
		
		private static const ANIM_MOVE:String = "move";
		private static const ANIM_IDLE:String = "idle";
		
		public static const TYPE_PUNK_BOY:String = "boy";
		public static const TYPE_PUNK_GIRL:String = "girl";
		public static const TYPE_ZOMBIE:String = "zombie";
		
		//--------------------------------------------------------------------//
		// MEMBERS															  //
		//--------------------------------------------------------------------//
		public var mType:String;
		
		//--------------------------------------------------------------------//
		// METHODS															  //
		//--------------------------------------------------------------------//
		public function GroundEnemy()
		{
			super(0, 0);
			name = "GroundEnemy";
			maxVelocity.x = maxVelocity.y = 200;
			acceleration.x = 0;
			acceleration.y = 0;
			
			// [AOC] Load graphic and animation
			//		 Select a random type
			var types:Array = [TYPE_PUNK_BOY, TYPE_PUNK_GIRL];
			mType = types[int(Math.random() * types.length)];
			if (Math.random() < ZOMBIE_SPAWN_PROBABILITY)
			{ 
				mType = TYPE_ZOMBIE;
				loadGraphic(SpritesheetZombieTexture, true, true, 80, 80);	// Size of the first animation
				addAnimationFromXML(ANIM_MOVE, "boy" + "_run", new XML(new SpritesheetZombieXML()), 24, true);
				addAnimationFromXML(ANIM_IDLE, "boy" + "_idle", new XML(new SpritesheetZombieXML()), 24, true);
			}
			else
			{
				loadGraphic(SpritesheetTexture, true, true, 80, 80);	// Size of the first animation
				addAnimationFromXML(ANIM_MOVE, mType + "_run", new XML(new SpritesheetXML()), 24, true);
				addAnimationFromXML(ANIM_IDLE, mType + "_idle", new XML(new SpritesheetXML()), 24, true);
			}
			play(ANIM_MOVE);
		}
		
		
		override public function update():void
		{
			acceleration.y = 1200;
			
			var d:Number = distanceToPlayerSqrt();
			if (d < DISTANCE_TO_PANIC*DISTANCE_TO_PANIC && Math.abs(player.y - y) < World.TILE_HEIGHT*4)
			{
				if (state == 0)
				{
					var sfx:int = Math.random()*3;
					switch(sfx)
					{
						case 1: FlxG.play(screamSound2); break;
						case 2: FlxG.play(screamSound3); break;
						default: FlxG.play(screamSound1);
					}
					
				}
				state = 1;				
				maxVelocity.x = 200;
				maxVelocity.y = 400;
				var v:Vector3D = new Vector3D((x - player.x) / d, (y - player.y) / d);
				acceleration.x = MAX_SPEED * 100 * v.x;	
				if ( isTouching( FlxObject.FLOOR ) )
				{					
					if (allowJump) acceleration.y = (-maxVelocity.y * 38) * Math.random() * 2.5 + 1 ;
					allowJump = false;
				} 
				else
				{
					allowJump = true;
				}
			}
			else
			{
				state = 0;
				maxVelocity.x = 100;
				acceleration.x += (Math.random() - Math.random()) * 20;
				
				//detect edges
				var tX:Number
				var tY:Number
				
				tX = (x / World.TILE_WIDTH);				
				tY = (y / World.TILE_HEIGHT);
				
				var spd:Number = 0;
				
				if (velocity.x != 0)
				{
					spd= velocity.x / Math.abs(velocity.x);
				}
				
				
				if (world)
				{
					if ( tY < world.mapHeight - 3 && world.collisionMap.getTile(tX + 1.5*spd, tY + (height/World.TILE_HEIGHT)) == 0)
					{
						if ( tY < world.mapHeight - 4 && world.collisionMap.getTile(tX + 1.5*spd, tY + (height/World.TILE_HEIGHT) + 1) == 0)
						{
							velocity.x = 0;
							acceleration.x = -40*spd;//-acceleration.x;
						}
					}
					else
					{
						if (world.collisionMap.getTile(tX+1.5*spd, tY) > 0)
						{
							velocity.x = 0;
							acceleration.x = -40*spd;//-acceleration.x;
						}
					}
				}
				else
				{
					trace("world es null");
				}
			}
			
			// [AOC] Update asset's anim
			if(velocity.x != 0 || velocity.y != 0) {
				play(ANIM_MOVE);
			} else {
				play(ANIM_IDLE);
			}
			
			// [AOC] Update asset's orientation (leave the same if not moving)
			if(velocity.x > 0) {
				facing = FlxObject.LEFT;
			} else if(velocity.x < 0) {
				facing = FlxObject.RIGHT;
			}
			
			super.update();
		}
		
		public function distanceToPlayerSqrt():Number
		{
			return ((player.x - x)*(player.x - x) + (player.y - y)*(player.y - y));
		}
		
	}
}