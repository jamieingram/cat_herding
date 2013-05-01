package com.pokelondon.display.components {
    import starling.core.Starling;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.text.TextField;

    /**
     * @author jamieingram
     */
    public class DisplayStatus extends Sprite {
        private var _levelName_txt : TextField;
        private var _score_txt : TextField;
        
        
        public function DisplayStatus() {
            _levelName_txt = new TextField(100, 30, "Level 0", "Verdana", 24, 0x000000);
            _levelName_txt.border = true;
            addChild(_levelName_txt);
            _levelName_txt.visible = false;
            //
            _score_txt = new TextField(50, 20, "0/0", "Verdana", 16, 0xFFFFFF);
            addChild(_score_txt);
            //
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        //
        private function onAddedToStage():void {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            _levelName_txt.x = (stage.stageWidth - _levelName_txt.width) * 0.5;
            _levelName_txt.y = (stage.stageHeight - _levelName_txt.height) * 0.5;
            _score_txt.x = stage.stageWidth - _score_txt.width;
        }
        //
        public function init($level_str:String):void {
        	  //reset the score
        	  _levelName_txt.text = $level_str;
              _levelName_txt.visible = true;
              Starling.juggler.delayCall(hideLevelInfo, 1);
        }
        //
        public function updateScore($saved_int:int,$total_int:int):void {
            _score_txt.text = $saved_int+"/"+$total_int;
        }
        //
        private function hideLevelInfo():void {
            _levelName_txt.visible = false;
        }
    }
}
