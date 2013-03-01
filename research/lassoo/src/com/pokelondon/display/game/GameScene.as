package com.pokelondon.display.game {
    import starling.display.Sprite;
    import starling.events.Event;

    /**
     * @author jamieingram
     */
    public class GameScene extends Sprite {
        
        public function GameScene() {
            addEventListener(Event.ADDED_TO_STAGE, onGameAddedToStage);
        }
        //
        private function onGameAddedToStage():void {
 			_background = DynamicAtlas
        }
    }
}
