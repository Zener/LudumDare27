package FlxMovieClip
{
	
	/**
	 * FlxMovieClip
	 * 
	 * With this you can draw a Flash MovieClip just like an FlxSprite!
	 * 		(with a couple of exceptions)
	 * 
	 * WARNING! Processing intensive - only use when desired effect is
	 * impossible to achieve with FlxSprite or FlxG.stage.addChild().
	 * 
	 * Supported methods / properties:
	 * - x, y, angle, scale, offset, velocity, acceleration
	 * - antialiasing, visible, flash movieclip animations 
	 * 
	 * Unsupprted methods / properties:
	 * - alpha, blend, replaceColor, stamp, drawLine, fill
	 * - active, flixel animations
	 * 
	 * @version		1.0 - September 25th 2011
	 * @link		http://www.funstormgames.com/
	 * @author		Wolfgang @ Funstorm Ltd
	*/
	
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import org.flixel.FlxCamera;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	
	public class FlxMovieClip extends FlxSprite 
	{
		/**
		 * Internal, the <code>MovieClip</code> being rendered.
		 */
		protected var _mc:MovieClip;
		/**
		 * Internal, bitmapdata which the <code>MovieClip</code> is rendered to.
		 */
		protected var _mcBitmapData:BitmapData;
		/**
		 * Internal, used to keep track of the last <code>MovieClip</code> frame shown.
		 */
		protected var _mcLastFrame:int;
		/**
		 * Change this to false/true to start/stop the <code>MovieClip</code>.
		 * Can also use to check whether or not currently playing.
		 */
		private var _isPlaying:Boolean = false;
		/**
		 * Whether or not the <code>MovieClip</code> should restart at tbe beginning when it finishes playing.
		 */
		public var isLooping:Boolean;
		/**
		 * A function that gets called every time the <code>MovieClip</code> reaches the end of the timeline.
		 */
		public var callbackOnComplete:Function;
		
		/**
		 * Creates an empty <code>FlxMovieClip</code> at the specified position.
		 * 
		 * @param	X				The initial X position of the sprite.
		 * @param	Y				The initial Y position of the sprite.
		 */
		public function FlxMovieClip(X:Number=0,Y:Number=0) 
		{	
			super(X, Y);
		}
		
		/**
		 * Load a <code>MovieClip</code> from an embedded file.
		 * 
		 * @param	TheMovieClip		The <code>MovieClip</code> you want to use.
		 * @param	Width				The <code>MovieClip</code>'s width.
		 * @param	Height				The <code>MovieClip</code>'s height.
		 * @param	IsLooping			Whether or not to loop the <code>MovieClip</code> when playing.
		 * @param	AutoPlay			Whether or not to start playing the <code>MovieClip</code> right away.
		 * @param	CallbackOnComplete	This function gets called every time the <code>MovieClip</code> reaches the end of its timeline.
		 * 
		 * @return	This <code>FlxMovieClip</code> instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadMovieClip(TheMovieClip:MovieClip, Width:int, Height:int, IsLooping:Boolean = false, AutoPlay:Boolean=false, CallbackOnComplete:Function = null):FlxMovieClip
		{
			_mc = TheMovieClip;
			width = Width;
			height = Height;
			isPlaying = AutoPlay;
			isLooping = IsLooping;
			callbackOnComplete = CallbackOnComplete;
			
			return this;
		}
		
		/**
		 * Start / stop playing the <code>MovieClip</code>.
		 */
		public function set isPlaying(Play:Boolean):void
		{
			if (Play) _mc.play();
			else _mc.stop();
			_isPlaying = Play;
		}
		
		/**
		 * Check whether the <code>MovieClip</code> is playing.
		 */
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		/**
		 * Check whether the <code>MovieClip</code> has finished playing.
		 */
		override public function update():void 
		{
			if (isPlaying) {
				if (_mc.currentFrame == _mc.totalFrames || _mc.currentFrame < _mcLastFrame) {
					if (isLooping) _mc.gotoAndPlay(0); // loop back to beginning
					else {
						_mc.gotoAndStop(_mc.totalFrames-1); // go to last frame
						isPlaying = false; // and stop
					}
					if (callbackOnComplete != null) { callbackOnComplete(); }
				}
				_mcLastFrame = _mc.currentFrame;
			}
		}
		
		/**
		 * Draw the <code>MovieClip</code> to the camera buffer.
		 */
		override public function draw():void 
		{
			// This class is mostly copied over from FlxSprite.
			// Comments are next to any lines changed.
			if (_mc != null) { // Only draw if a movieclip has been loaded
				// create a new bitmap data with a transparent background
				// this is necessary because otherwise the movieclip frames get drawn on top of each other
				// (drawing on top works fine for movieclips with an opaque background but of course is a major problem for MCs with a transparent BG)
				_mcBitmapData = new BitmapData(width, height, true, 0);
				// draw the movieclip to the bitmapdata so we can draw it to the camera later
				_mcBitmapData.draw(_mc);
					
				if(cameras == null)
					cameras = FlxG.cameras;
				var camera:FlxCamera;
				var i:uint = 0;
				var l:uint = cameras.length;
				while(i < l)
				{
					camera = cameras[i++];
					if(!onScreen(camera))
						continue;
					_point.x = x - int(camera.scroll.x*scrollFactor.x) - offset.x;
					_point.y = y - int(camera.scroll.y*scrollFactor.y) - offset.y;
					_point.x += (_point.x > 0)?0.0000001:-0.0000001;
					_point.y += (_point.y > 0)?0.0000001: -0.0000001;
					_matrix.identity();
					_matrix.translate(-origin.x,-origin.y);
					_matrix.scale(scale.x,scale.y);
					if((angle != 0) && (_bakedRotation <= 0))
						_matrix.rotate(angle * 0.017453293);
					_matrix.translate(_point.x + origin.x, _point.y + origin.y);
					camera.buffer.draw(_mcBitmapData,_matrix,null,blend,null,antialiasing); // where the magic happens: the bitmap data gets drawn to the camera
				}
			}
		}
		
		/**
		 * Clean up memory.
		 */
		override public function destroy():void 
		{
			_mc = null;
			_mcBitmapData = null;
			callbackOnComplete = null;
			
			super.destroy();
		}
		
		/**
		 * Can't use graphics of type Class with FlxMovieClip.
		 */
		override public function loadGraphic(Graphic:Class, Animated:Boolean = false, Reverse:Boolean = false, Width:uint = 0, Height:uint = 0, Unique:Boolean = false):FlxSprite 
		{
			return null;
		}
		/**
		 * Can't use graphics of type Class with FlxMovieClip.
		 */
		override public function loadRotatedGraphic(Graphic:Class, Rotations:uint = 16, Frame:int = -1, AntiAliasing:Boolean = false, AutoBuffer:Boolean = false):FlxSprite 
		{
			return null;
		}
		/**
		 * Can't use graphics of type Class with FlxMovieClip.
		 */
		override public function makeGraphic(Width:uint, Height:uint, Color:uint = 0xffffffff, Unique:Boolean = false, Key:String = null):FlxSprite 
		{
			return null;
		}
		
	}

}