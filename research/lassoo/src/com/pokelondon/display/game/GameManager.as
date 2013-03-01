package com.pokelondon.display.game {
    import starling.events.Event;

    import com.pokelondon.display.SpriteHolder;
    import com.pokelondon.display.components.interaction.DisplayTouchHandler;

    /**
     * @author jamieingram
     */
    public class GameManager extends SpriteHolder {
        
        private var _touchHandler : DisplayTouchHandler;
        
        public function GameManager() {
            addEventListener(Event.ADDED_TO_STAGE,onGameAddedToStage);
        }
        //
        private function onGameAddedToStage():void {
        	init();
        }
        //
        private function init():void {
            _scene = new GameScene();
            addChild(_scene);
            //
            _touchHandler = new DisplayTouchHandler();
            addChild(_touchHandler);
            _touchHandler.enable();
            //
        }
    }
}
