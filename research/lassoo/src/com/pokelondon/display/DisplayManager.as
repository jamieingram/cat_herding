package com.pokelondon.display {
    import starling.display.Sprite;
    import starling.events.Event;

    import com.pokelondon.display.components.ProgressBar;
    import com.pokelondon.display.game.GameManager;
    import com.pokelondon.display.menu.Menu;

    /**
     * @author jamieingram
     */
    public class DisplayManager extends Sprite {
        private var _progressBar:ProgressBar;
        private var _currentSection:SpriteHolder;
        private var _sections_obj:Object;
        
        public function DisplayManager() {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            _sections_obj = {};
        }
        //
        private function onAddedToStage():void {
            _progressBar = new ProgressBar(175, 20);
            _progressBar.x = (stage.stageWidth  - _progressBar.width)  / 2;
            _progressBar.y = (stage.stageHeight - _progressBar.height) / 2;
            _progressBar.y = stage.stageHeight * 0.85;
            addChild(_progressBar);
            _progressBar.touchable = false;
            _progressBar.visible = false;
        }
        //
        public function setLoadProgress($ratio:Number):void {
          _progressBar.ratio = $ratio;
        }
        //
        public function showLoader():void {
            _progressBar.visible = true;
        }
        //
         public function hideLoader():void {
            _progressBar.removeFromParent(true);
        }
        //
        public function navigateTo($navigateTo_str:String):void {
            var spriteClass:Class;
            var navigateTo_array:Array = $navigateTo_str.split("/");
            var sectionId_str:String = navigateTo_array[0];
            var touchable:Boolean = false;
            //
            switch (sectionId_str) {
                case "menu":
                	spriteClass = Menu;
                    touchable = true;
                break;
                case "game":
                	spriteClass = GameManager;
                break;
            }
            //
            if (_currentSection == null) {
                _progressBar.removeFromParent(true);
                _progressBar = null;
                _currentSection = new spriteClass();
                _sections_obj[sectionId_str] = _currentSection;
                addChild(_currentSection);
            }else if (!(_currentSection is spriteClass)) {
                //not an instance of the correct holder
                _currentSection.removeFromParent();
                var section:SpriteHolder = _sections_obj[sectionId_str];
                if (section == null) section = new spriteClass();
                _sections_obj[sectionId_str] = section;
                _currentSection = section;
                addChild(_currentSection);
            }
           	//
           	_currentSection.touchable = touchable;
            //
            if (navigateTo_array.length > 1) {
                _currentSection.navigateTo(navigateTo_array.slice(1));
            }
        }
    }
}
