package com.pokelondon.application {
    import starling.core.Starling;
    import starling.events.Event;
    import starling.textures.Texture;
    import starling.utils.AssetManager;
    import starling.utils.RectangleUtil;
    import starling.utils.ScaleMode;
    import starling.utils.formatString;

    import com.pokelondon.utils.Constants;

    import flash.desktop.NativeApplication;
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.geom.Rectangle;
    import flash.system.Capabilities;
    
	[SWF(frameRate="60", backgroundColor="#000")]
	public class Loader extends Sprite {
        
        public static var SCALE_FACTOR:Number;
        //
        // Startup image for SD screens
        [Embed(source="../../../../system/startup.jpg")]
        private static var Background:Class;
        
        // Startup image for HD screens
        [Embed(source="../../../../system/startupHD.jpg")]
        private static var BackgroundHD:Class;
        //
		private var _mStarling : Starling;
        private var _background : Bitmap;
        private var _assets : AssetManager;

		public function Loader() {
            // set general properties
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            //
            var stageWidth:int   = Constants.STAGE_WIDTH;
            var stageHeight:int  = Constants.STAGE_HEIGHT;
            var iOS:Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;
            
            Starling.multitouchEnabled = true;  // useful on mobile devices
            Starling.handleLostContext = !iOS;  // not necessary on iOS. Saves a lot of memory!
            
            // create a suitable viewport for the screen size
            // 
            // we develop the game in a *fixed* coordinate system of 320x480; the game might 
            // then run on a device with a different resolution; for that case, we zoom the 
            // viewPort to the optimal size for any display and load the optimal textures.
            
            //
            var viewPort:Rectangle = RectangleUtil.fit(
                new Rectangle(0, 0, stageWidth, stageHeight),
                new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight), 
                ScaleMode.SHOW_ALL);
            
            // create the AssetManager, which handles all required assets for this resolution
            SCALE_FACTOR = viewPort.height / stageHeight;
            trace("stage: "+stageWidth+" x "+stageHeight);
            trace("full stage: "+stage.fullScreenWidth+" x "+stage.fullScreenHeight);
            trace("scale : "+SCALE_FACTOR);
            var appDir:File = File.applicationDirectory;
            _assets = new AssetManager(SCALE_FACTOR);
            //
            _assets.verbose = Capabilities.isDebugger;
            //
            _assets.enqueue(
                
            );
            
            // While Stage3D is initializing, the screen will be blank. To avoid any flickering, 
            // we display a startup image now and remove it below, when Starling is ready to go.
            // This is especially useful on iOS, where "Default.png" (or a variant) is displayed
            // during Startup. You can create an absolute seamless startup that way.
            // 
            // These are the only embedded graphics in this app. We can't load them from disk,
            // because that can only be done asynchronously (resulting in a short flicker).
            // 
            // Note that we cannot embed "Default.png" (or its siblings), because any embedded
            // files will vanish from the application package, and those are picked up by the OS!
            
            _background = SCALE_FACTOR == 1 ? new Background() : new BackgroundHD();
            Background = BackgroundHD = null; // no longer needed!
            
            _background.x = viewPort.x;
            _background.y = viewPort.y;
            _background.width  = viewPort.width;
            _background.height = viewPort.height;
            _background.smoothing = true;
            addChild(_background);
            
            // launch Starling
            
            _mStarling = new Starling(Application, stage, viewPort);
            _mStarling.stage.stageWidth  = stageWidth;  // <- same size on all devices!
            _mStarling.stage.stageHeight = stageHeight; // <- same size on all devices!
            _mStarling.simulateMultitouch  = true;
            _mStarling.enableErrorChecking = Capabilities.isDebugger;
            _mStarling.showStats = Capabilities.isDebugger;
            // set anti-aliasing (higher the better quality but slower performance)
			_mStarling.antiAliasing = 1;
            
            _mStarling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
            
            // When the game becomes inactive, we pause Starling; otherwise, the enter frame event
            // would report a very long 'passedTime' when the app is reactivated. 
            
            NativeApplication.nativeApplication.addEventListener(
                flash.events.Event.ACTIVATE, function (e:*):void { _mStarling.start(); });
            
            NativeApplication.nativeApplication.addEventListener(
                flash.events.Event.DEACTIVATE, function (e:*):void { _mStarling.stop(); });
        }
		//
		private function onRootCreated(event:Object, app:Application):void {
			_mStarling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
	        removeChild(_background);
	        var bgTexture:Texture = Texture.fromBitmap(_background, false, false, SCALE_FACTOR);
	        app.start(bgTexture, _assets);
	        _mStarling.start();
		}
    }
}