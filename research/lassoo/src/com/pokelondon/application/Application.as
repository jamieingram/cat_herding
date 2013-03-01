package com.pokelondon.application {
    import starling.core.Starling;
    import starling.display.Sprite;
    import starling.textures.Texture;
    import starling.utils.AssetManager;

    import com.pokelondon.display.DisplayManager;
    
    public class Application extends Sprite {
        private static var _INSTANCE:Application;
        private static var _ASSETS:AssetManager;
        
        public var lastNavigateTo_str:String;
		public var currentNavigateTo_str:String;
        //
        private var _displayManager:DisplayManager;
        
        public function Application() {
            _INSTANCE = this;
        }
        //
        public static function GET_INSTANCE():Application {
			if (_INSTANCE == null) {
				trace("ApplicationMain.GET_INSTANCE - no instance found");
			}
			//
			return _INSTANCE;
		}
		//
        public function start(background:Texture, assets:AssetManager):void {
            // the asset manager is saved as a static variable; this allows us to easily access
            // all the assets from everywhere by simply calling "Root.assets"
            _ASSETS = assets;
            // The AssetManager contains all the raw asset data, but has not created the textures
            // yet. This takes some time (the assets might be loaded from disk or even via the
            // network), during which we display a progress indicator. 
            //
            _displayManager = new DisplayManager();
            addChild(_displayManager);
            _displayManager.showLoader();
            //
            assets.loadQueue(onProgress);
        }
        //
        private function onProgress(ratio:Number):void {
			_displayManager.setLoadProgress(ratio);
                
            // a progress bar should always show the 100% for a while,
            // so we show the main menu only after a short delay. 
                
            if (ratio == 1) {
            	Starling.juggler.delayCall(onDelayComplete, 0.15);
            }
    	}
        //
        private function onDelayComplete():void {
            _displayManager.hideLoader();
            navigateTo("menu");
        }
        //
        public function navigateTo($navigateTo_str:String):void {
			if ($navigateTo_str.charAt(0) == "/") $navigateTo_str = $navigateTo_str.substr(1);
			if ($navigateTo_str.charAt($navigateTo_str.length - 1) == "/") $navigateTo_str = $navigateTo_str.substr(0, $navigateTo_str.length - 1);
			if ($navigateTo_str == currentNavigateTo_str) {
				trace("Application::navigateTo - cannot go to "+$navigateTo_str+" again");
				return;
            }
			trace("ApplicationMain::navigateTo "+$navigateTo_str);
			//
			lastNavigateTo_str = currentNavigateTo_str;
			currentNavigateTo_str = $navigateTo_str;
			//
			try {
				_displayManager.navigateTo(currentNavigateTo_str);
			} catch ($e:Error) {
				trace("ApplicationMain.navigateTo : cannot go to " + currentNavigateTo_str+"\n"+$e.message+"\n"+$e.getStackTrace());
			}
		}
		//
        public static function get assets():AssetManager { return _ASSETS; }
    }
}