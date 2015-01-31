package Entities 
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Miguel Ángel Linares
	 */
	public class EnemyBase extends FlxSprite
	{
		public var player:Player;
		public var world:World;
		public var name : String = "";	// To differenciate enemy types
		
		
		public function EnemyBase(X:Number=0,Y:Number=0,SimpleGraphic:Class=null)
		{
			super(X, Y, SimpleGraphic);
			name = "EnemyBase";
		}
		
		public function setPlayer(_player:Player):void
		{
			player = _player;
		}
		
		public function setWorld(_world:World):void
		{
			world = _world;
			if (world == null)
			{
				trace("fdsgfdsfdsfsfffffffffffffffff");
			}
		}
	}

}