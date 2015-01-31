package Entities 
{
	
	import org.flixel.*;
	 
	
	public class Player extends FlxSprite
	{
		//--------------------------------------------------------------------//
		// CONSTANTS														  //
		//--------------------------------------------------------------------//
		// Animations
		private var ANIM_FRAMERATE:int = 24;
		public var ANIM_IDLE:String = "idle";
		public var ANIM_RUN:String = "run";
		public var ANIM_EAT:String = "eat";
		public var ANIM_JUMP:String = "jump";
		public var ANIM_DIE:String = "die";
		public var ANIM_DEAD:String = "dead";
		
		// Movement constants
		private var MAX_SPEED:Number = 500;
		private var WATER_SPEED_FACTOR:Number = 0.5;
		
		private var MAX_SPEED_DASHING:Number = MAX_SPEED * 20;
		private var DASH_DURATION:Number = 0.15;
		private var DASH_COOLDOWN:Number = 0.5;
		
		[Embed(source="../../assets/sfx/nyamsmall.mp3")] private var eatSmallSound:Class;
		[Embed(source="../../assets/sfx/nyam.mp3")] private var eatBigSound:Class;
		[Embed(source="../../assets/sfx/eatSound.mp3")] private var eatFishSound:Class;
		[Embed(source="../../assets/sfx/jump.mp3")] private var jumpSound:Class;
		[Embed(source="../../assets/sfx/rot.mp3")] private var rotSound:Class;
		[Embed(source="../../assets/sfx/dash.mp3")] private var dashSound:Class;
		[Embed(source="../../assets/sfx/dashwater.mp3")] private var dashWaterSound:Class;
		
		//--------------------------------------------------------------------//
		// MEMBERS															  //
		//--------------------------------------------------------------------//
		public var level:int = 0;	// [0..N-1]
		
		public var dashing : Number = 0;
		private var poison : Number = 0;
		private var confusion : Number = 0;
		
		public var controlSystem : Number = 0;	// 0 - Water, 1 - Earth, 2 - Sky
		private var inputVector : FlxPoint;
		private var useGravity:Boolean = true;
		private var allowJump:Boolean = true;
		private var isTouchingGround:Boolean = true;
		
		public var numEnemiesEaten : Number = 0;
		
		private var dead : Boolean = false;
		public var world:World;
		
		private var mDashFXEmitter:FlxEmitter;
		
		private var sayCooldown:Number = 0;
		
		//--------------------------------------------------------------------//
		// METHODS															  //
		//--------------------------------------------------------------------//
		/**
		 * @param _level The level of the player (0, 1, 2)
		 */
		public function Player(_level:int) 
		{
			super(FlxG.width / 2 , FlxG.height / 2);
						
			level = _level;
			
			maxVelocity.x = MAX_SPEED;
			maxVelocity.y = MAX_SPEED;
			
			drag.x = maxVelocity.x * 4;
			drag.y = maxVelocity.y * 4;
			
			controlSystem = 1;
			inputVector = new FlxPoint(0, 0);
			
			numEnemiesEaten = 0;
			
			// [AOC] Initialize asset and animations depending on level
			switch(level) {
				// Level 2
				case 1:
					loadGraphic(EmbeddedAssets.Level2Texture, true, true, 80, 80);	// Size of the first animation
					addAnimationFromXML(ANIM_IDLE, "bob_idle", new XML(new EmbeddedAssets.Level2XML()), ANIM_FRAMERATE, true);
					addAnimationFromXML(ANIM_EAT, "bob_feed", new XML(new EmbeddedAssets.Level2XML()), ANIM_FRAMERATE, false);
					addAnimationFromXML(ANIM_JUMP, "bob_jump", new XML(new EmbeddedAssets.Level2XML()), ANIM_FRAMERATE, true);
					addAnimationFromXML(ANIM_DIE, "bob_die", new XML(new EmbeddedAssets.Level2XML()), ANIM_FRAMERATE, false);
					break;
				
				// [AOC] Use level 1 assets as default
				case 0:
				case 2:
				default:
					loadGraphic(EmbeddedAssets.Level1Texture, true, true, 80, 80);	// Size of the first animation
					addAnimationFromXML(ANIM_IDLE, "bob_idle", new XML(new EmbeddedAssets.Level1XML()), ANIM_FRAMERATE, true);
					addAnimationFromXML(ANIM_RUN, "bob_move", new XML(new EmbeddedAssets.Level1XML()), ANIM_FRAMERATE, true);
					addAnimationFromXML(ANIM_EAT, "bob_feed", new XML(new EmbeddedAssets.Level1XML()), ANIM_FRAMERATE, false);
					addAnimationFromXML(ANIM_DIE, "bob_die", new XML(new EmbeddedAssets.Level1XML()), ANIM_FRAMERATE, false);
					//addAnimationFromXML(ANIM_DEAD, "bob_dead", new XML(new EmbeddedAssets.Level1XML()), ANIM_FRAMERATE, true);
					break;
			}
			
			// [AOC] Start with the idle animation
			play(ANIM_IDLE);
		}
		
		public function setControlType() : void
		{
			
		}
		
		private var db:int = 0;
		/**
		 * 
		 */
		override public function update():void
		{
			db = 1 - db;
			if (confusion > 0) confusion -= FlxG.elapsed;
			
			if (sayCooldown > 0) sayCooldown -= FlxG.elapsed;
			
			updateInputVector();
			
			if ( poison  > 0)
			{
				poison -= FlxG.elapsed;
				MAX_SPEED = 250;
				MAX_SPEED_DASHING = 500;
			}
			else
			{
				MAX_SPEED = 500;
				MAX_SPEED_DASHING = 1000;
			}
			
			if (dead)
			{
				switch( controlSystem )
				{
					case 0 : acceleration.x = 0; acceleration.y = 100; break;
					case 1 : acceleration.x = 0; acceleration.y = 1200; break;
					case 2 : acceleration.x = 0; acceleration.y = 1200; break;
				}
			}
			else
			{			
				switch( controlSystem )
				{
					case 0 : waterMovement(); break;
					case 1 : earthMovement(); break;
					case 2 : airMovement(); break;
				}
				
				// Update dash effect
				if(mDashFXEmitter) {
					if(dashing > 0) {
						// Dashing! If not already active, activate emitter
						if(!mDashFXEmitter.on) {
							mDashFXEmitter.start(false, 0.5, 0);
							mDashFXEmitter.on = true;
						}
						
						// Update emitter's position
						mDashFXEmitter.x = x;
						mDashFXEmitter.y = y;
						
						// Emit some particles
						for(var i:int = 0; i < 10; i++) {
							mDashFXEmitter.emitParticle();
						}
					} else {
						// Not dashing, stop emitter
						if(mDashFXEmitter.on) {
							mDashFXEmitter.on = false;
						}
					}
				}
			}
			
			// [AOC] Update asset's orientation (leave the same if not moving)
			if(velocity.x > 0) {
				facing = FlxObject.LEFT;
			} else if(velocity.x < 0) {
				facing = FlxObject.RIGHT;
			}
			
			// Feedback for states
			if (poison > 0)
			{
				if (poison < 0.5) blend = (db == 1)?"subtract":"normal";
				else blend = "subtract";
			}
			else if (confusion > 0)
			{
				if (confusion < 0.5) blend = (db == 1)?"invert":"normal";
				else blend = "invert";
			}
			else 
				blend = "normal";
			
			
			super.update();
		}
		
		/**
		 * 
		 */
		private function waterMovement() : void
		{
			dashing -= FlxG.elapsed;
			if (dashing <= 0)
			{			
				maxVelocity.x = MAX_SPEED * WATER_SPEED_FACTOR;
				maxVelocity.y = MAX_SPEED * WATER_SPEED_FACTOR;
				
				acceleration.x = inputVector.x * maxVelocity.x * 8;
				acceleration.y = inputVector.y * maxVelocity.y * 8;	
					
				// DASH - only allow if not on cooldown
				if(FlxG.keys.SPACE && dashing < -DASH_COOLDOWN) {					
					if(inputVector.x != 0 || inputVector.y != 0) {
						velocity.x = inputVector.x * MAX_SPEED_DASHING * WATER_SPEED_FACTOR;
						velocity.y = inputVector.y * MAX_SPEED_DASHING * WATER_SPEED_FACTOR;
						//acceleration.x = inputVector.x * MAX_SPEED_DASHING;
						//acceleration.y = inputVector.y * MAX_SPEED_DASHING;
						
						maxVelocity.x = MAX_SPEED_DASHING * WATER_SPEED_FACTOR;
						maxVelocity.y = MAX_SPEED_DASHING * WATER_SPEED_FACTOR;
				
						dashing = DASH_DURATION;
						
						FlxG.play(dashWaterSound);
					}
				}
			}
			
			var tX:Number = x / World.TILE_WIDTH;
			var tY:Number = y / World.TILE_HEIGHT;
			if (tX < 0.5  ||  tX >= world.mapWidth-1)
			{
				//velocity.x = -velocity.x;
				//acceleration.x = -acceleration.x;
				if (tX < 0.5)
				{
					x = 0.5 * World.TILE_WIDTH;
					velocity.x = Math.abs(velocity.x);
					acceleration.x = Math.abs(acceleration.x);
				}
				if (tX > world.mapWidth-1)
				{
					x = (world.mapWidth-1) * World.TILE_WIDTH;
					velocity.x = -Math.abs(velocity.x);
					acceleration.x = -Math.abs(acceleration.x);
				}				
			}
			if (tY < 1  || tY >= world.mapHeight-1)
			{
				if (tY < 1)
				{
					y = 1 * World.TILE_HEIGHT;
					velocity.y = Math.abs(velocity.y)	
					acceleration.y = Math.abs(acceleration.y);	
				}
				if (tY >= world.mapHeight-1)
				{
					velocity.y = -Math.abs(velocity.y)	
					acceleration.y = -Math.abs(acceleration.y);
					y = (world.mapHeight-1) * World.TILE_HEIGHT;
				}
				
			}	
			
			// [AOC] Update anim - although velocity is not yet calculated
			// 		 Skip if playing "EAT" animation
			//		 Will be ignored if already playing the same anim (play() method does it)
			var eating:Boolean = (_curAnim != null && _curAnim.name == ANIM_EAT);
			if(_curAnim == null || !eating) { 
				// a) More horizontal than vertical
				if(Math.abs(velocity.x) > Math.abs(velocity.y)) {
					// Run animation
					play(ANIM_RUN);
				}
				
				// b) More vertical than horizontal
				else if(Math.abs(velocity.x) < Math.abs(velocity.y)) {
					// Idle animation
					play(ANIM_IDLE);
				}
				
				// c) Stopped
				else if(velocity.x == 0 || velocity.y == 0) {
					// Idle animation
					play(ANIM_IDLE);
				}
			}
		}
		
		/**
		 * 
		 */
		private function earthMovement() : void
		{
			drag.x = maxVelocity.x * 100;
			drag.y = maxVelocity.y * 100;
			
			acceleration.y = 1200;
			
			dashing -= FlxG.elapsed;
			if (dashing <= 0) {
				maxVelocity.y = (500) * 2;
				maxVelocity.x = MAX_SPEED / 2;
			
				acceleration.x = 0;	
				//maxVelocity.x = MAX_SPEED;
				
				if (velocity.y != 0) {
					acceleration.x =  inputVector.x * maxVelocity.x * 2;							
				} else {
					acceleration.x =  inputVector.x * maxVelocity.x * 4;
				}
				
				// DASH - only allow if not on cooldown
				if(FlxG.keys.SPACE && dashing < -DASH_COOLDOWN) {					
					if(inputVector.x != 0) {
						velocity.x = inputVector.x * MAX_SPEED_DASHING;
						//acceleration.x = inputVector.x * MAX_SPEED_DASHING;						
						maxVelocity.x = MAX_SPEED_DASHING;
						dashing = DASH_DURATION;
						FlxG.play(dashSound);
					}
				}	
			}
				
			// if (velocity.y == 0)
			var jumpStarted:Boolean = false;
			isTouchingGround = isTouching(FlxObject.FLOOR);
			if ( isTouchingGround )
			{
				if( inputVector.y < 0 && confusion <= 0 || inputVector.y > 0 && confusion > 0)
				{
					if (allowJump)
					{ 
						acceleration.y = -maxVelocity.y * 38;
						FlxG.play(jumpSound); 
						jumpStarted = true;
						acceleration.y = -maxVelocity.y * 38;
					}
					allowJump = false;
				}
			} 
			else // if (velocity.y > 0) 
			{
				allowJump = true;
			}
			
			var tX:Number = x / World.TILE_WIDTH;
			var tY:Number = y / World.TILE_HEIGHT;
			if (tX < 0.5  ||  tX >= world.mapWidth-1)
			{
				velocity.x = -velocity.x;
				acceleration.x = -acceleration.x;
			}
			
			// [AOC] Update anim - although velocity is not yet calculated
			// 		 Skip if playing "EAT" animation
			//		 Will be ignored if already playing the same anim (play() method does it)
			var eating:Boolean = (_curAnim != null && _curAnim.name == ANIM_EAT);
			if(_curAnim == null || !eating) {
				// a) Idle/Walk animation (luckily for us is the same one on earth movement)
				//    Must be touching ground
				if(isTouchingGround) {
					// Wait until the jump animation is finished
					play(ANIM_IDLE);
				}
				
				// b) Jump anim - whenever we're in the air
				else {
					play(ANIM_JUMP);
				}
			}
		}
		
		/**
		 * 
		 */
		private function airMovement() : void
		{
			dashing -= FlxG.elapsed;
			if (dashing <= 0)
			{
				maxVelocity.x = MAX_SPEED;
				maxVelocity.y = MAX_SPEED;
				
				acceleration.x = 0;	
				acceleration.y = maxVelocity.y;
				
				acceleration.x =  inputVector.x * maxVelocity.x * 8;
				if (inputVector.y > 0)
					acceleration.y =  inputVector.y * maxVelocity.y * 8;
				else if ( inputVector.y < 0 )
					acceleration.y =  inputVector.y * maxVelocity.y * 6;
				
				// DASH - only allow if not on cooldown
				if(FlxG.keys.SPACE && dashing < -DASH_COOLDOWN) {					
					if(inputVector.x != 0 || inputVector.y != 0) {
						velocity.x = inputVector.x * MAX_SPEED_DASHING * WATER_SPEED_FACTOR;
						velocity.y = inputVector.y * MAX_SPEED_DASHING * WATER_SPEED_FACTOR;
						//acceleration.x = inputVector.x * MAX_SPEED_DASHING;
						//acceleration.y = inputVector.y * MAX_SPEED_DASHING;
						
						maxVelocity.x = MAX_SPEED_DASHING * WATER_SPEED_FACTOR;
						maxVelocity.y = MAX_SPEED_DASHING * WATER_SPEED_FACTOR;
						
						dashing = DASH_DURATION;
					}
				}
			}
			
			// [AOC] TODO!! Any particular behaviour
			// 		 Skip if playing "EAT" animation
			var eating:Boolean = (_curAnim != null && _curAnim.name == ANIM_EAT);
			if(_curAnim == null || !eating) { 
				// [AOC] Update anim - although velocity is not yet calculated
				// 		 Will be ignored if already playing the same anim (play() method does it)
				// Will be ignored if already playing the same anim (play() method does it)
				// Only check horizontal movement
				if(velocity.x != 0) {
					// Run animation
					play(ANIM_RUN);
				} else {
					// Idle animation
					play(ANIM_IDLE);
				}
			}	
		}
		
		/**
		 * 
		 */
		public function updateInputVector() : void
		{
			inputVector.x = inputVector.y = 0; 
			
			if (confusion > 0)
			{
				if(FlxG.keys.LEFT || FlxG.keys.A)
					inputVector.x = 1;
				if(FlxG.keys.RIGHT || FlxG.keys.D)
					inputVector.x = -1;
				if(FlxG.keys.UP || FlxG.keys.W)
					inputVector.y = 1;
				if(FlxG.keys.DOWN || FlxG.keys.S)
					inputVector.y = -1;
			}
			else
			{			
				if(FlxG.keys.LEFT || FlxG.keys.A)
					inputVector.x = -1;
				if(FlxG.keys.RIGHT || FlxG.keys.D)
					inputVector.x = 1;
				if(FlxG.keys.UP || FlxG.keys.W)
					inputVector.y = -1;
				if(FlxG.keys.DOWN || FlxG.keys.S)
					inputVector.y = 1;
			}
		}
		
		/**
		 * 
		 */
		public function eatEnemy( e : EnemyBase ) : void
		{
			if (controlSystem == 0) FlxG.play(eatSmallSound);
			else FlxG.play(eatBigSound);
			
			numEnemiesEaten++;
			
			//dashing = 0;	Stop dashing
			
			// [AOC] Start eat animation
			play(ANIM_EAT, true);	// True to reset the anim if already playing it
			addAnimationCallback(onEatAnimFrameFinishedCB);
			
			switch( e.name )
			{
				case "EnemyBase" : break;
				case "StaticEnemy" : break;
				case WaterEnemy.TYPE_SARDINE : FlxG.play(eatFishSound); break;
				case WaterEnemy.TYPE_ABYSSAL : FlxG.play(eatFishSound); break;
				case "GroundEnemy" :
					// Play sound
					FlxG.play(eatFishSound);
					
					// If zombie and not infected, apply a random infection
					if ((e as GroundEnemy).mType == GroundEnemy.TYPE_ZOMBIE && confusion <= 0 && poison <= 0)
					{
						// Confusion or poison
						var text:String;
						if (Math.random() <= 0.5)
						{
							confusion = 3;
							text = "CONFUSED!";
						}
						else
						{
							poison = 3;
							text = "POISONED!";
						}
						
						// [AOC] Show some feedback
						var txt:TextLine = new TextLine(text, this, FlxG.state);
						txt.size = 24;
						txt.color = 0xFFFF0000;
					} else {
						// Launch standard text line
						saySomething();
					}
					break;
			}
		}
		
		
		public function saySomething() : void
		{	
			if (sayCooldown > 0)
			{				
				return;
			}
			// FlxG.state
			var r : int = (int) (Math.random() * 21);
			var str : String = "";
			switch(r)
			{
				case 0 : str = "Nyam nyam"; break;
				case 1 : str = "Yummy yummy"; break;
				case 2 : str = "Very tasty"; break;
				case 3 : str = "I love when they scream"; break;
				case 4 : str = "Two beter than one"; break;
				case 5 : str = "I can eat one more"; break;
				case 6 : str = "Ready to have seconds"; break;
				case 7 : str = "Burp!";FlxG.play(rotSound);  break;
				case 8 : str = "BURP!!!";FlxG.play(rotSound);  break;
				case 9 : str = "Too bloody"; break;
				case 10 : str = "Oh, the reflux"; break;
				case 11 : str = "Not very tasty"; break;
				case 12 : str = "Delicious"; break;
				case 13 : str = "Let's go for dessets"; break;
				case 14 : str = "Another one"; break;
				case 15 : str = "I'm still hungry"; break;
				case 16 : str = "The more the better"; break;
				case 17 : str = "Not a healthy one"; break;
				case 18 : str = "Greasy"; break;
				case 19 : str = "More"; break;
				case 20 : str = "More, MOREEE!"; break;
			}
			
			new TextLine( str, this, FlxG.state);
			
			sayCooldown = 0.35;
		}
		
		/**
		 * 
		 */
		public function die() : void
		{
			dead = true;
			
			// [AOC] Start dead animation
			play(ANIM_DIE);
			addAnimationCallback(onDieAnimFrameFinishedCB);
		}
			
		public function setWorld(_world:World):void
		{
			world = _world;
		}
		
		public function setDashFXEmitter(_emitter:FlxEmitter) : void
		{
			// Store it
			mDashFXEmitter = _emitter;
			if(!_emitter) return;
			
			// Setup emitter
			_emitter.setSize(width, height);
			
			// Create particle assets
			var whitePixel:FlxParticle;
			for(var i:int = 0; i < _emitter.maxSize/2; i++) {
				whitePixel = new FlxParticle();
				whitePixel.makeGraphic(5, 5, 0x19FFFFFF);
				whitePixel.visible = false; // Make sure the particle doesn't show up at (0, 0)
				mDashFXEmitter.add(whitePixel);
				
				whitePixel = new FlxParticle();
				whitePixel.makeGraphic(3, 3, 0x7FFFFFFF);
				whitePixel.visible = false;
				mDashFXEmitter.add(whitePixel);
			} 
		}
		
		//--------------------------------------------------------------------//
		// CALLBACKS														  //
		//--------------------------------------------------------------------//
		/**
		 * Callback for when a frame of the dying animation has finished.
		 */
		public function onDieAnimFrameFinishedCB(_animName:String, _curFrame:uint, _curSheetIdx:uint) : void
		{
			// If last frame, launch dead animation
			if(_curFrame == getAnimation(_animName).frames.length - 1) {
				//play(ANIM_DEAD);	// [AOC] TODO!!
				addAnimationCallback(null);
			}
		}
		
		/**
		 * Callback for when a frame of the eating animation has finished.
		 */
		public function onEatAnimFrameFinishedCB(_animName:String, _curFrame:uint, _curSheetIdx:uint) : void
		{
			// If last frame, launch idle animation
			if(_curFrame == getAnimation(_animName).frames.length - 1) {
				// Special case for the earth control
				if(controlSystem == 1) {
					// Idle if touching ground, otherwise go to the last frame of the jump animation
					if(isTouchingGround) {
						play(ANIM_IDLE);
					} else {
						play(ANIM_JUMP);
					}
				} else {
					// Default action
					play(ANIM_IDLE);
				}
				addAnimationCallback(null);
			}
		}
	}
}