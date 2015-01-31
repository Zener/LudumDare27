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
	public class FirstState  extends FlxState
	{
		//--------------------------------------------------------------------//
		// EMBEDDED RESOURCES												  //
		//--------------------------------------------------------------------//
		[Embed(source = '../assets/tilemaps/state1/mar_bg.png')]private static const backgroundImg:Class;
		
		// Tileset that works with AUTO mode (best for thin walls)
		[Embed(source = '../assets/tilemaps/state1/tileset.png')]private static const auto_tiles:Class;
		// Default tilemaps. Embedding text files is a little weird.
		[Embed(source = '../assets/tilemaps/state1/mar_tilemap_export.json', mimeType = 'application/octet-stream')]private static var tilemap:Class;
		
		// Intro cinematic
		[Embed(source = "../assets/cinematics/cine_01_b.swf", symbol="cine_01")]
		private static const IntroCinematic:Class;
		
		// Music
		[Embed(source="../assets/sfx/brownninjas.mp3")] private const musicTheme:Class;
		
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
		//private static const STATE_TUTORIAL_POPUP:int = 7;
		
		// Others
		private static const TARGET_ENEMIES:int = 15;
		
		//--------------------------------------------------------------------//
		// MEMBERS															  //
		//--------------------------------------------------------------------//
		protected var player : Player;
		protected var ui : UI;
		protected var world  : World;
		protected var enemies : FlxGroup;
		private var whitePixel:FlxParticle; 
		private var theEmitter:FlxEmitter;
		private var darkness:FlxSprite;
		private var playerLight : Light;
		private var tutorialPopup:SimplePopup;
		
		private var mShowIntro:Boolean;
		private var mLastIntroFrame:int;
		
		protected var mState:int;
		protected var mStateTimer:Number;
		protected var mPreviousMS:Number;
		
		//--------------------------------------------------------------------//
		// METHODS															  //
		//--------------------------------------------------------------------//
		/**
		 * 
		 */
		public function FirstState(_showIntro:Boolean) 
		{
			mShowIntro = _showIntro;			
			changeState(STATE_LOADING);
			FlxG.mouse.hide();
		}
		
		/**
		 * 
		 */
		override public function create():void
		{
			var background:FlxSprite = new FlxSprite(0,0, backgroundImg);//(FlxG.width / 2 , FlxG.height / 2, ImgPlayer);
			add (background);
			
			player =  new Player(0);
			player.controlSystem = 0;
			
			FlxG.camera.follow(player);
			FlxG.camera.setBounds( 0, 0, 900, 900);
			
			// [AOC] Initialize dash effect
			var dashFX:FlxEmitter = new FlxEmitter(0, 0, 200);
			player.setDashFXEmitter(dashFX);
			add(dashFX);
			
			var data:String = new tilemap();
			var rawData:Object = JSON.parse(data);
			world = new World(rawData, auto_tiles);
			
			add( world );
			player.setWorld(world);
			
			enemies = new FlxGroup;
			add(enemies);
			
			createBloodParticleEmitter();
			
			createDarkness();
			
			world.collisionMap.visible = false;
			
			// Add player after everything else
			add(player);
			
			// Add HUD
			ui =  new UI(UI.ENEMY_TYPE_FISH);
			add(ui);
			
			if(mShowIntro) {
				changeState(STATE_INTRO);
			} else {
				changeState(STATE_COUNTDOWN);
			}
		}
		
		override public function destroy():void
		{
			FlxSpecialFX.clear();
		}
		
		/**
		 * 
		 */
		private function createDarkness() : void
		{
			/*darkness = new FlxSprite(0,0);
			darkness.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
			darkness.scrollFactor.x = darkness.scrollFactor.y = 0;
			darkness.blend = "multiply";*/
			
			playerLight = new Light(FlxG.width / 2, FlxG.height / 2, darkness);
			playerLight.scale.x = 7;
			playerLight.scale.y = 7;
			
			add(playerLight);
			
			//add(darkness);
			
		}
		
		/**
		 * 
		 */
		override public function draw():void 
		{
//			darkness.fill(0x00000000);
			super.draw();
		}
		
		/**
		 * 
		 */
		override public function update():void
		{
			// Compute elapsed time
			var date:Date = new Date();
			var currentMS:Number = date.getTime();
			var deltaMS:int = currentMS - mPreviousMS;
			mPreviousMS = currentMS;
			
			// Update player's collision with the world
			FlxG.collide( player, world.collisionMap );
			
			// Update enemy's collision with the world
			var sp1 : EnemyBase
			var i:int;
			for each(sp1  in enemies.members ) {
				if ( sp1 != null) {
					FlxG.collide( sp1, world.collisionMap );
				}
			}
			
			// Update particles collision with the world
			FlxG.collide(theEmitter, world.collisionMap);
			
			// Update player light position
			playerLight.x = player.x + 20;
			playerLight.y = player.y + 20;
			
			// Update FSM
			stateUpdate(deltaMS);
			
			// If ESC key is pressed, go back to main menu
			if(FlxG.keys.ESCAPE) {
				FlxG.switchState(new MenuState());
			}
			
			// Call parent
			super.update();
		}
		
		/**
		 * FSM State Change.
		 */
		protected function changeState(_newState:int) : void
		{
			switch(_newState) {
				case STATE_LOADING:
					break;
				
				//case STATE_TUTORIAL_POPUP:
					//break;
				
				case STATE_INTRO:
					// Launch cinematic - do some black magic to correct position
					var cinematicMC:MovieClip = new IntroCinematic();
					cinematicMC.name = "phase1Cinematic";
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
					tutorialPopup = new SimplePopup(this, 180, 500, 600, 200);
					tutorialPopup.setText("Eat everything!\n\nControls:\n - Cursor keys or ASWD\n - Space to Dash");
					
					// Start timer
					mStateTimer = 5000;
					
					// Show countdown
					ui.resetCountdown(mStateTimer);
					ui.changeState(UI.STATE_INTRO);
					break;
				
				case STATE_PLAYING:
					// Spawn enemies
					for (var i:int = 0; i < TARGET_ENEMIES; i++) {
						spawnEnemy(WaterEnemy.TYPE_SARDINE);
					}
					
					// Change UI state
					ui.changeState(UI.STATE_PLAYING);
					ui.resetCountdown();
					ui.setAmount(0, TARGET_ENEMIES);
					break;
				
				case STATE_FINAL_BOSS:
					// Spawn final boss
					spawnEnemy(WaterEnemy.TYPE_ABYSSAL);
					break;
				
				case STATE_CLEARED:
					// Hide emmiter and light
					theEmitter.on = false;
					playerLight.visible = false;
					
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
					
					// Hide light
					playerLight.visible = false;
					
					// Change UI state
					ui.changeState(UI.STATE_FINISHED);
					
					// Show text feedback
					var defeatTxt1:FlxText = new FlxText(0, 30, FlxG.stage.width, "DEFEAT!");
					defeatTxt1.size = 40;
					defeatTxt1.alignment = "center";
					defeatTxt1.scrollFactor.x = defeatTxt1.scrollFactor.y = 0;
					add(defeatTxt1);
					
					var defeatTxt2:FlxText = new FlxText(0, 30 + defeatTxt1.size, FlxG.stage.width, "Eat all fishes before running out of stamina!");
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
					var cinematicMC:MovieClip = FlxG.stage.getChildByName("phase1Cinematic") as MovieClip;
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
						tutorialPopup.close();
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
						changeState(STATE_FINAL_BOSS);
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
					// Wait for the timer before showing the cinematic
					if(mStateTimer <= 0) {
						// Go to next stage
						FlxG.switchState(new SecondState(true));
					}
					break;
					
				case STATE_DYING:
					if(mStateTimer <= 0) {
						FlxG.switchState(new FirstState(false));	// Restart phase
					}
					break;
			}
		}
		
		/**
		 * @param _type One of the WaterEnemy.TYPE_* constants
		 */
		private function spawnEnemy(_type:String) : void
		{
			var enemy1:EnemyBase = new WaterEnemy(_type);
			enemy1.setPlayer(player);
			enemy1.setWorld(world);
			enemies.add(enemy1);
			enemy1.x = Math.random() * world.collisionMap.width;
			enemy1.y = Math.random() * world.collisionMap.height;
			
			while (world.collisionMap.overlaps(enemy1) )
			{
				enemy1.x = Math.random() * world.collisionMap.width;
				enemy1.y = Math.random() * world.collisionMap.height;					
			}
		}
		
		/**
		 *
		 */
		private function eatEnemy(_enemy:EnemyBase) : void
		{
			player.eatEnemy( _enemy );
			enemies.remove( _enemy );
			
			theEmitter.x = _enemy.x;
			theEmitter.y = _enemy.y;
			theEmitter.lifespan = 5;						
			for(var i:int = 0; i < 40; i++) {
				theEmitter.emitParticle();
			}
			
			// Update UI
			ui.resetCountdown();
			ui.setAmount(player.numEnemiesEaten, TARGET_ENEMIES);
		}
		
		/**
		 * 
		 */
		public function createBloodParticleEmitter():void
		{
			theEmitter = new FlxEmitter(10, FlxG.height / 2, 200);
			
			theEmitter.setXSpeed(-100, 100);
			
			theEmitter.setYSpeed( -100, 100);
			
			//Let's also make our pixels rebound off surfaces
			theEmitter.bounce = .2;
								
			
			add(theEmitter);			
			
			//Now it's almost ready to use, but first we need to give it some pixels to spit out!
			//Lets fill the emitter with some white pixels
			for (var i:int = 0; i < theEmitter.maxSize/2; i++) 
			{
				whitePixel = new FlxParticle();
				whitePixel.makeGraphic(3, 3, 0xaFa00000);
				whitePixel.visible = false; //Make sure the particle doesn't show up at (0, 0)
				theEmitter.add(whitePixel);
				whitePixel = new FlxParticle();
				whitePixel.makeGraphic(2, 2, 0xaFa00000);
				whitePixel.visible = false;
				theEmitter.add(whitePixel);
				
			} 
		}
	}

}