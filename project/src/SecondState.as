package  
{
	import Entities.*;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	/**
	 * ...
	 * @author Miguel Ángel Linares
	 */
	public class SecondState  extends FlxState
	{
		//--------------------------------------------------------------------//
		// EMBEDDED RESOURCES												  //
		//--------------------------------------------------------------------//	
		[Embed(source = '../assets/tilemaps/state2/city_bg.png')]private static var backgroundImg:Class;
		
		// Tileset that works with AUTO mode (best for thin walls)
		[Embed(source = '../assets/tilemaps/test_1/tileset.png')]private static var auto_tiles:Class;
		
		// Default tilemaps. Embedding text files is a little weird.
		[Embed(source = '../assets/tilemaps/state2/mar_tilemap_export.json', mimeType = 'application/octet-stream')]private static var tilemap:Class;
		
		// End of phase cinematic
		[Embed(source = "../assets/cinematics/cine_02_b.swf", symbol="cine_02")]
		private static var IntroCinematic:Class;
		
		// Music
		[Embed(source="../assets/sfx/pinkandfighting.mp3")] private var musicTheme:Class;
		
		//--------------------------------------------------------------------//
		// CONSTANTS														  //
		//--------------------------------------------------------------------//
		// FSM
		private static const STATE_LOADING:int = 0;
		private static const STATE_INTRO:int = 1;
		private static const STATE_COUNTDOWN:int = 2;
		private static const STATE_PLAYING:int = 3;
		private static const STATE_FINAL_BOSS:int = 4;
		private static const STATE_CLEARED:int = 5;
		private static const STATE_DYING:int = 6;
		
		// Others
		private static const TARGET_ENEMIES:int = 150;
		private static const NUM_ENEMIES_POOL:int = 30;
		
		
		//--------------------------------------------------------------------//
		// MEMBERS															  //
		//--------------------------------------------------------------------//
		protected var player : Player;
		protected var ui : UI;
		protected var world  : World;
		protected var enemies : FlxGroup;
		protected var dynamicObjects : FlxGroup;
		private var theEmitter:FlxEmitter;
		private var whitePixel:FlxParticle; 
		protected var endGame : Boolean = false;
		
		private var mShowIntro:Boolean;
		private var mLastIntroFrame:int;
		
		protected var mState:int;
		protected var mStateTimer:Number;
		protected var mPreviousMS:Number;
		
		public function SecondState(_showIntro:Boolean) 
		{
			mShowIntro = _showIntro;
			changeState(STATE_LOADING);
			FlxG.mouse.hide();
		}
		
		override public function create():void
		{
			var background:FlxSprite = new FlxSprite(0,0, backgroundImg);//(FlxG.width / 2 , FlxG.height / 2, ImgPlayer);
			add (background);
			
			dynamicObjects = new FlxGroup();
			var elevator : Elevator = new Elevator( 2750, 600 );
			dynamicObjects.add(elevator);
			add(dynamicObjects);
			
			player =  new Player(1);
			player.controlSystem = 1;
			FlxG.camera.follow(player);
			
			// [AOC] Initialize dash effect
			var dashFX:FlxEmitter = new FlxEmitter(0, 0, 200);
			player.setDashFXEmitter(dashFX);
			add(dashFX);
			
			var data:String = new tilemap();
			var rawData:Object = JSON.parse(data);
			world = new World(rawData, auto_tiles);
			add( world );
			world.collisionMap.visible = false;
			world.platformsMaps.visible = false;
			
			player.setWorld(world);
			
			//player.x = 20;
			//player.y = (world.mapHeight*World.TILE_HEIGHT)-120;
			
			player.x = 50;
			player.y = (world.mapHeight * World.TILE_HEIGHT) - 300;
			player.facing = FlxObject.RIGHT;
			player.velocity.x = 0.01;
		
			player.width = player.width / 2;			
			
			enemies = new FlxGroup;
			add(enemies);
			
			createBloodParticleEmitter();
			
			// Add player after everything else
			add(player);

			// Add HUD
			ui =  new UI(UI.ENEMY_TYPE_HUMAN);			
			add(ui);
			
			if(mShowIntro) {
				changeState(STATE_INTRO);
			} else {
				changeState(STATE_COUNTDOWN);
			}
		}
		
		
		override public function update():void
		{
			// PLAYER COLLISIONS
			player.allowCollisions = FlxObject.DOWN;
			FlxG.collide( player, world.platformsMaps );
			
			player.allowCollisions = FlxObject.ANY;
			FlxG.collide( player, world.collisionMap );
			
			FlxG.collide( player, dynamicObjects );
			
			// ENEMIES COLLISIONS
			var sp1 : EnemyBase
			for each(sp1  in enemies.members )
			{
				if ( sp1 != null)
				{
					if (Math.abs(player.x - sp1.x) > 960 || Math.abs(player.y - sp1.y) > 720)
					{
						spawnInNewPosition(sp1);
					}
					else
					{
						sp1.allowCollisions = FlxObject.DOWN;
						FlxG.collide( sp1, world.platformsMaps );
						
						sp1.allowCollisions = FlxObject.ANY;
						FlxG.collide( sp1, world.collisionMap );
						
						//FlxG.collide( sp1, dynamicObjects );
					}
					
					// Detect eating collision - only if playing
					if(mState == STATE_PLAYING) {
						// if ( FlxCollision.pixelPerfectCheck( sp1.currentCollision, player ) )
						if ( sp1 != null && FlxG.overlap(sp1,player, null,null) )
						{
							eatEnemy(sp1);
							/*theEmitter.x = sp1.x;
							theEmitter.y = sp1.y;
							theEmitter.lifespan = 5;						
							for(var i:int = 0; i < 30; i++)
							{
								theEmitter.emitParticle();						
							}
							
							player.eatEnemy( sp1 );
							ui.resetCountdown();
							*/
							
							//enemies.remove( sp1 );	
							//spawnInNewPosition(sp1);
							break;
						}
					}
					
					/*if (Math.abs(player.x - sp1.x) > 480 && !sp1.onScreen())
					{
						spawnInNewPosition(sp1);
					}*/
				}
			}
			
			//FlxG.collide(theEmitter, world.collisionMap);		
					
			// Update FSM
			stateUpdate(FlxG.elapsed * 1000);
			
			// If ESC key is pressed, go back to main menu
			if(FlxG.keys.ESCAPE) {
				FlxG.switchState(new MenuState());
			}
			
			super.update();
		}
		
		
		public function spawnInNewPosition(enemy1:EnemyBase):void
		{
			enemy1.x = -10;
			
			//return;
			var cam:FlxCamera = FlxG.camera;
			var sxStart:int = cam.scroll.x;
			var sxEnd:int = sxStart + 960;
			
			//First the X
			while (enemy1.x < World.TILE_WIDTH*3 || enemy1.x > (world.mapWidth-4)*World.TILE_WIDTH || (enemy1.x > sxStart && enemy1.x < sxEnd))
			{
				enemy1.y = World.TILE_HEIGHT*3 + (Math.random() * world.collisionMap.height - (World.TILE_HEIGHT*3)) ;

				if (Math.random() >= 0.5)
				{
					enemy1.x = sxEnd + Math.random() * 480;
				}
				else 
				{
					enemy1.x = sxStart - Math.random() * 480;
				}				
			}
		
			//trace("enemy1.x "+enemy1.x);
			// Then the Y
			
			enemy1.y = player.y -  ((Math.random() - Math.random()) * 800);
			while (world.collisionMap.overlaps(enemy1) || enemy1.y < World.TILE_HEIGHT*3 || enemy1.y > (world.mapHeight-3) *World.TILE_HEIGHT)
			{
				enemy1.y = player.y + (Math.random()-Math.random()) * 800;
				//Math.random() * world.collisionMap.height;				
			}
			
			//Now get them to the ground!				
			while (!world.collisionMap.overlaps(enemy1) &&  enemy1.y < (world.mapHeight-4) *World.TILE_WIDTH)
			{
				enemy1.y += 16;				
			}
			enemy1.y -= 16;
		}
		
		
		public function createBloodParticleEmitter():void
		{
			theEmitter = new FlxEmitter(10, FlxG.height / 2, 200);
			
			theEmitter.setXSpeed(-200, 200);
			
			theEmitter.setYSpeed( -250, 10);
			
			//Let's also make our pixels rebound off surfaces
			//theEmitter.bounce = 0;
			
			
			theEmitter.gravity = 400; 
			
			add(theEmitter);			
			
			//Now it's almost ready to use, but first we need to give it some pixels to spit out!
			//Lets fill the emitter with some white pixels
			for (var i:int = 0; i < theEmitter.maxSize/2; i++) 
			{
				whitePixel = new FlxParticle();
				whitePixel.makeGraphic(4, 4, 0xaFaa0000);
				whitePixel.visible = false; //Make sure the particle doesn't show up at (0, 0)
				theEmitter.add(whitePixel);
				whitePixel = new FlxParticle();
				whitePixel.makeGraphic(3, 3, 0xaFac0000);
				whitePixel.visible = false;
				theEmitter.add(whitePixel);
			} 
		}
		
		/**
		 * FSM State Change.
		 */
		protected function changeState(_newState:int) : void
		{
			switch(_newState) {
				case STATE_LOADING:
					break;
				
				case STATE_INTRO:
					// Launch cinematic - do some black magic to correct position
					var cinematicMC:MovieClip = new IntroCinematic();
					cinematicMC.name = "phase2Cinematic";
					var posRefDO:DisplayObject = cinematicMC.getChildByName("pos_ref");
					cinematicMC.x = -posRefDO.x;
					cinematicMC.y = -posRefDO.y;
					posRefDO.visible = false;
					FlxG.stage.addChild(cinematicMC);
					cinematicMC.play();
					mLastIntroFrame = 0;
					
					// Start music
					if (FlxG.music) FlxG.music.stop();
					FlxG.play(musicTheme,1,true);
					
					// Adjust the framerate to the animation speed
					FlxG.flashFramerate = 24;
					break;
				
				case STATE_COUNTDOWN:
					// Start timer
					mStateTimer = 5000;
					
					// Show countdown
					ui.resetCountdown(mStateTimer);
					ui.changeState(UI.STATE_INTRO);
					break;
				
				case STATE_PLAYING:
					// Spawn enemies
					for (var i:int = 0; i < NUM_ENEMIES_POOL;i++)
					{
						var enemy1:EnemyBase = new GroundEnemy();
						enemy1.setPlayer(player);
						enemies.add(enemy1);
						enemy1.setWorld(world);
						enemy1.x = Math.random() * 960*2;
						enemy1.y = Math.random() * world.collisionMap.height;
						
						while (world.collisionMap.overlaps(enemy1) )
						{
							enemy1.x = 140 + Math.random() * 960*2;
							enemy1.y = Math.random() * world.collisionMap.height;	
						}
						
						//Now get them to the ground!				
						while (!world.collisionMap.overlaps(enemy1) )
						{
							enemy1.y += 32;
						}
						enemy1.y -= 32;
					}
					
					// Change UI state
					ui.changeState(UI.STATE_PLAYING);
					ui.resetCountdown();
					ui.setAmount(0, TARGET_ENEMIES);
					break;
				
				case STATE_FINAL_BOSS:
					// Spawn final boss
					// spawnEnemy(WaterEnemy.TYPE_ABYSSAL);
					break;
				
				case STATE_CLEARED:
					// Hide emmiter
					theEmitter.on = false;
					
					// Change UI state
					ui.changeState(UI.STATE_FINISHED);
					
					// Show victory feedback
					var victoryTxt:FlxText = new FlxText(0, 30, FlxG.stage.width, "VICTORY!");
					victoryTxt.size = 40;
					victoryTxt.alignment = "center";
					victoryTxt.scrollFactor.x = victoryTxt.scrollFactor.y = 0;
					add(victoryTxt);
					
					// Play success sound
					FlxG.play(EmbeddedAssets.SuccessSFX);
					
					// Start timer
					mStateTimer = 3000;
					break;
				
				case STATE_DYING:
					// Start timer
					mStateTimer = 5000;
					
					// Show end game
					player.die();
					theEmitter.x = player.x + player.width/2;
					theEmitter.y = player.y + player.height/2;
					theEmitter.start(false);
					for(i = 0; i < 100; i++)
					{
						theEmitter.emitParticle();
					}
					
					// Change UI state
					ui.changeState(UI.STATE_FINISHED);
					
					// Show text feedback
					var defeatTxt1:FlxText = new FlxText(0, 30, FlxG.stage.width, "DEFEAT!");
					defeatTxt1.size = 40;
					defeatTxt1.alignment = "center";
					defeatTxt1.scrollFactor.x = defeatTxt1.scrollFactor.y = 0;
					add(defeatTxt1);
					
					var defeatTxt2:FlxText = new FlxText(0, 30 + defeatTxt1.size, FlxG.stage.width, "Eat all humans before running out of stamina!");
					defeatTxt2.size = 20;
					defeatTxt2.alignment = "center";
					defeatTxt2.scrollFactor.x = defeatTxt2.scrollFactor.y = 0;
					add(defeatTxt2);
					
					// Play failure sound
					FlxG.play(EmbeddedAssets.FailureSFX);
					break;
			}
			
			mState = _newState;
		}
		
		/**
		 * FSM State Update
		 */
		protected function stateUpdate(_deltaMS:int) : void
		{
			// Aux vars
			var enemy:EnemyBase;
			var i:int;
			
			// Update timer
			mStateTimer -= _deltaMS;
			
			// Perform different actions depending on current state
			switch(mState) {
				case STATE_LOADING:
					break;
				
				case STATE_INTRO:
					// Check if the cinematic has finished and go to the next phase
					var cinematicMC:MovieClip = FlxG.stage.getChildByName("phase2Cinematic") as MovieClip;
					if(cinematicMC != null) {
						if(mLastIntroFrame > cinematicMC.currentFrame) {
							// Clear cinematic
							FlxG.stage.removeChild(cinematicMC);
							
							// Start phase
							changeState(STATE_COUNTDOWN);
							
							// Restore framerate
							FlxG.flashFramerate = 60;
						}
						
						// Update last frame
						mLastIntroFrame = cinematicMC.currentFrame;
					}
					break;
				
				case STATE_COUNTDOWN:
					if(mStateTimer <= 0) {
						changeState(STATE_PLAYING);
					}
					break;
				
				case STATE_PLAYING:
					// Detect collision of the player with the enemies
					for each(enemy in enemies.members) {
						// if ( FlxCollision.pixelPerfectCheck( sp1.currentCollision, player ) )
						if(enemy != null && FlxG.overlap(enemy, player, null, null)) {
							eatEnemy(enemy);
							break;	// Only one enemy at a time
						}
					}
					
					// All enemies eaten?
					if(player.numEnemiesEaten >= TARGET_ENEMIES) {
						// Change to next stage
						//changeState(STATE_FINAL_BOSS);
						changeState(STATE_CLEARED);	// [AOC] TODO!! Final boss
					}

					// Time out?
					if(ui.hasFinished()) {
						changeState(STATE_DYING);
					}
					break;
				
				case STATE_FINAL_BOSS:
					// Detect collision of the player with the boss
					for each(enemy in enemies.members) {
						// if ( FlxCollision.pixelPerfectCheck( enemy.currentCollision, player ) )
						if(enemy != null 
						&& enemy.name == WaterEnemy.TYPE_ABYSSAL 
						&& FlxG.overlap(enemy, player, null, null)) {
							eatEnemy(enemy);
							changeState(STATE_CLEARED);
							break;	// Only one enemy at a time
						}
					}
					break;
				
				case STATE_CLEARED:
					// Wait for the timer before going to the credits sequence
					if(mStateTimer <= 0) {
						FlxG.switchState(new CreditsState());
					}
					break;
				
				case STATE_DYING:
					if(mStateTimer <= 0) {
						FlxG.switchState(new SecondState(false));	// Restart phase
					}
					break;
			}
		}
		
		/**
		 *
		 */
		private function eatEnemy(_enemy:EnemyBase) : void
		{
			player.eatEnemy( _enemy );
			//enemies.remove( _enemy );
			
			theEmitter.x = _enemy.x;
			theEmitter.y = _enemy.y;
			theEmitter.lifespan = 1.5;						
			for(var i:int = 0; i < 30; i++) {
				theEmitter.emitParticle();
			}
			
			// Update UI
			ui.resetCountdown();
			 ui.setAmount(player.numEnemiesEaten, TARGET_ENEMIES);
			//ui.setAmount(player.numEnemiesEaten, 40);
			
			spawnInNewPosition(_enemy);
		}
	}

}