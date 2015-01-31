package 
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	
	import org.flixel.*;
	
	public class UI extends FlxGroup
	{
		//--------------------------------------------------------------------//
		// EMBEDDED RESOURCES												  //
		//--------------------------------------------------------------------//
		[Embed(source="../assets/sfx/countdown.mp3")] private var CountdownSound:Class;
		[Embed(source="../assets/sfx/ticking.mp3")] private var TickingSound:Class;
		
		[Embed(source="../assets/imgs/fish.png")] private var FishIcon:Class;
		[Embed(source="../assets/imgs/humans.png")] private var HumanIcon:Class;
		[Embed(source="../assets/imgs/stamina.png")] private var StaminaIcon:Class;
		
		//--------------------------------------------------------------------//
		// CONSTANTS														  //
		//--------------------------------------------------------------------//
		public static const BAR_Y:int = 20;
		public static const BAR_WIDTH:int = 400;
		public static const BAR_HEIGHT:int = 20;
		
		public static const COUNTDOWN_TIME:int = 10*1000;
		
		public static const STATE_IDLE:int = 0;
		public static const STATE_INTRO:int = 1;
		public static const STATE_PLAYING:int = 2;
		public static const STATE_FINISHED:int = 3;
		
		public static const ENEMY_TYPE_FISH:int = 0;
		public static const ENEMY_TYPE_HUMAN:int = 1;
		
		//--------------------------------------------------------------------//
		// MEMBERS															  //
		//--------------------------------------------------------------------//
		private var date:Date = new Date();
		private var countdown:int;
		private var previousTimeMilis:int;
		private var staminaFrame:FlxSprite;
		private var staminaInside:FlxSprite;
		private var staminaBar:FlxSprite;
		
		private var mState:int;
		
		private var mStaminaIcon:FlxSprite;
		private var mStaminaTxt:FlxText;
		private var mCountdownTxt:FlxText;
		
		private var mAmountIcon:FlxSprite;
		private var mAmountTxt:FlxText;
		
		private var mTickingSound:FlxSound;
		
		//--------------------------------------------------------------------//
		// METHODS															  //
		//--------------------------------------------------------------------//
		public function UI(_enemyType:int)
		{
			// Aux vars
			var stageWidth:Number = FlxG.stage.width;
			var barX:Number = stageWidth/2 - BAR_WIDTH/2;
			
			// Create Stamina bar
			staminaFrame = new FlxSprite(barX, BAR_Y);
			staminaFrame.makeGraphic(BAR_WIDTH+2, BAR_HEIGHT+2); //White frame for the health bar
			staminaFrame.scrollFactor.x = staminaFrame.scrollFactor.y = 0;
			add(staminaFrame);
			
			staminaInside = new FlxSprite(barX+1, BAR_Y+1);
			staminaInside.makeGraphic(BAR_WIDTH,BAR_HEIGHT,0xff000000); //Black interior, 48 pixels wide
			staminaInside.scrollFactor.x = staminaInside.scrollFactor.y = 0;
			add(staminaInside);
			
			staminaBar = new FlxSprite(barX+1, BAR_Y+1);
			staminaBar.makeGraphic(1, BAR_HEIGHT, 0xffffffff); //The red bar itself
			
			staminaBar.scrollFactor.x = staminaBar.scrollFactor.y = 0;
			staminaBar.origin.x = staminaBar.origin.y = 0; //Zero out the origin
			staminaBar.scale.x = BAR_WIDTH; //Fill up the health bar all the way
			add(staminaBar);
			
			// Stamina icon
			mStaminaIcon = new FlxSprite(barX - 43 - 10, 16, StaminaIcon);
			mStaminaIcon.scrollFactor.x = mStaminaIcon.scrollFactor.y = 0;
			add(mStaminaIcon);
			
			// Stamina label
			var labelWidth:Number = stageWidth * 0.25;
			mStaminaTxt = new FlxText(mStaminaIcon.x - labelWidth - 10, 19, labelWidth, "Stamina");
			mStaminaTxt.size = 16;
			mStaminaTxt.alignment = "right";
			mStaminaTxt.scrollFactor.x = mStaminaTxt.scrollFactor.y = 0;
			add(mStaminaTxt);
			
			// [AOC] Countdown
			labelWidth = stageWidth * 0.10;
			mCountdownTxt = new FlxText(barX + BAR_WIDTH/2 - labelWidth/2, BAR_Y + 20, labelWidth, "");
			mCountdownTxt.size = 50;
			mCountdownTxt.alignment = "center";
			mCountdownTxt.scrollFactor.x = mCountdownTxt.scrollFactor.y = 0;
			add(mCountdownTxt);
			
			// Amount Icon - depending on enemy type
			if(_enemyType == ENEMY_TYPE_FISH) {
				mAmountIcon = new FlxSprite(stageWidth - 43 - 50, 16, FishIcon);
			} else {
				mAmountIcon = new FlxSprite(stageWidth - 34 - 50, 10, HumanIcon);
			}
			mAmountIcon.scrollFactor.x = mAmountIcon.scrollFactor.y = 0;
			add(mAmountIcon);
			
			// Amount
			labelWidth = 100;
			mAmountTxt = new FlxText(mAmountIcon.x - 5 - labelWidth, 19, labelWidth, "0/0");
			mAmountTxt.size = 16;
			mAmountTxt.alignment = "right";
			mAmountTxt.scrollFactor.x = mAmountTxt.scrollFactor.y = 0;
			add(mAmountTxt);
			
			// Countdown initialization
			mTickingSound = FlxG.loadSound(TickingSound);
			resetCountdown();
			
			changeState(STATE_IDLE);
		}
		
		override public function update():void
		{
			super.update();
			
			var current:Number = currentTimeMillis();
			var delta:int = current - previousTimeMilis;
			previousTimeMilis = current;			
			
			// Hack for pause
			if (delta > 1000)
			{
				delta = 30;
			}
			
			// Update countdown (only in some states)
			if(mState == STATE_INTRO || mState == STATE_PLAYING) {
				var previousCountdown:Number = countdown;
				countdown -= delta;	 
				if(countdown < 0) {
					countdown = 0;				
				}
				
				// [AOC] Update countdown txt
				var remainingSec:Number = countdown/1000;
				mCountdownTxt.text = String(Math.ceil(remainingSec));
				
				// Scale FX
				var countdownDelta:Number = remainingSec - Math.floor(remainingSec);
				var minScale:Number = 1;
				var maxScale:Number = remainingSec > 5 ? 1.5 : 2;	// Bigger scale for the last 5 seconds
				var scaleAnimDuration:Number = 0.25;
				var scaleDelta:Number = 0;
				if(countdownDelta >= (1 - scaleAnimDuration)) {
					scaleDelta = (countdownDelta - (1 - scaleAnimDuration))/scaleAnimDuration;
				}
				var targetScale:Number = minScale + (maxScale - minScale) * scaleDelta;
				mCountdownTxt.scale = new FlxPoint(targetScale, targetScale);
				
				// Color FX - only if playing
				if(mState == STATE_PLAYING) {
					if(remainingSec <= 5) {
						// Merge between red and white
						mCountdownTxt.color = 0xFFFFFFFF - ((countdownDelta * 0xFF) << 8) - (countdownDelta * 0xFF);
					} else {
						mCountdownTxt.color = 0xFFFFFFFF;
					}
				}
				
				// Sound FX
				if(mState == STATE_INTRO) {
					// Start playback when remaining seconds go from 4 to 3
					if(previousCountdown > 3000 && countdown <= 3000) {
						FlxG.play(CountdownSound);
					}
				} else if(mState == STATE_PLAYING) {
					// Start playback when remaining seconds go from 4 to 3
					if(previousCountdown > 3000 && countdown <= 3000) {
						mTickingSound.play(true);
					}
				}
			}
			
			// Update stamina bar if playing
			if(mState == STATE_PLAYING) {
				staminaBar.scale.x = (countdown / COUNTDOWN_TIME)*BAR_WIDTH;
				staminaBar.color = 0xffff0000 + (((countdown / COUNTDOWN_TIME)*0xff)<<8) - (((countdown / COUNTDOWN_TIME)*0xff)<<16);
			}
		}
		
		/**
		 * FSM State Change.
		 */
		public function changeState(_newState:int) : void
		{
			mState = _newState;
			
			switch(_newState) {
				case STATE_INTRO:
					// Only show countdown
					staminaFrame.visible = false;
					staminaInside.visible = false;
					staminaBar.visible = false;
					mStaminaIcon.visible = false;
					mStaminaTxt.visible = false;
					
					mAmountIcon.visible = false;
					mAmountTxt.visible = false;
				
					mCountdownTxt.visible = true;
					break;
				
				case STATE_PLAYING:
					// Show everything
					staminaFrame.visible = true;
					staminaInside.visible = true;
					staminaBar.visible = true;
					mStaminaIcon.visible = true;
					mStaminaTxt.visible = true;
					
					mAmountIcon.visible = true;
					mAmountTxt.visible = true;
					
					mCountdownTxt.visible = true;
					break;
				
				case STATE_IDLE:
				case STATE_FINISHED:
					// Hide everything
					staminaFrame.visible = false;
					staminaInside.visible = false;
					staminaBar.visible = false;
					mStaminaIcon.visible = false;
					mStaminaTxt.visible = false;
					
					mAmountIcon.visible = false;
					mAmountTxt.visible = false;
					
					mCountdownTxt.visible = false;
					mTickingSound.stop();
					break;
			}
		}
		
		public function resetCountdown(_amountMS:Number = COUNTDOWN_TIME):void
		{
			countdown = _amountMS;
			previousTimeMilis = currentTimeMillis();
			
			mCountdownTxt.text = String(Math.ceil(countdown/1000));
			
			// Stop ticking sound
			mTickingSound.stop();
		}
		
		public function setAmount(_amount:int, _maxAmount:int = 0) : void
		{
			var amountText:String = String(_amount);
			if(_maxAmount != 0) {
				amountText += "/" + _maxAmount;
			}
			mAmountTxt.text = amountText;
			
			GTweener.removeTweens(mAmountTxt);
			mAmountTxt.scaleX = 1;
			mAmountTxt.scaleY = 1;
			new GTween(mAmountTxt, 1, {scaleX:1.5, scaleY:1.5}, {duration:0.25, repeatCount:2, reflect:true});
		}
		
		public function hasFinished() : Boolean
		{
			return countdown <= 0;
		}
		
		private function currentTimeMillis():Number
		{
			date = new Date();
			return date.getTime();
		}
	}
}