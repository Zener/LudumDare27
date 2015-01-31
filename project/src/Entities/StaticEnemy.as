package Entities 
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Miguel Ángel Linares
	 */
	public class StaticEnemy extends EnemyBase
	{
		[Embed(source = "../../assets/imgs/enemy001.png")] private var ImgPlayer:Class;	//Graphic of the player
		
		
		public function StaticEnemy() 
		{
			super(0, 0, ImgPlayer);
			name = "StaticEnemy";
		}
		
	}

}