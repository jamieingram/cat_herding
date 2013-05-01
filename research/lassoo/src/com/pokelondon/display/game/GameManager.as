package com.pokelondon.display.game {
    import com.pokelondon.application.Application;
    import com.pokelondon.display.components.DisplayStatus;
    import starling.events.Event;

    import com.pokelondon.display.SpriteHolder;
    import com.pokelondon.display.components.interaction.TouchHandler;
    import com.pokelondon.forces.Force;
    import com.pokelondon.utils.Constants;

    /**
     * @author jamieingram
     */
    public class GameManager extends SpriteHolder {
        
        private var _touchHandler:TouchHandler;
        private var _scene:GameScene;
        private var _gameStatus : DisplayStatus;
        private var _navigateTo_array : Array;
        
        public function GameManager() {
            addEventListener(Event.ADDED_TO_STAGE,onGameAddedToStage);
        }
        //
        private function onGameAddedToStage():void {
            removeEventListener(Event.ADDED_TO_STAGE, onGameAddedToStage);
        	init();
        }
        //
        private function init():void {
            _scene = new GameScene();
            _scene.addEventListener(Constants.EVENT_SCORE, onScoreUpdated);
            addChild(_scene);
            //
            _touchHandler = new TouchHandler();
            addChild(_touchHandler);
            _touchHandler.enable();
            _touchHandler.addEventListener(Constants.EVENT_TOUCH,onTouchEvent);
            //
            _gameStatus = new DisplayStatus();
            addChild(_gameStatus);
        }
        //
        public override function navigateTo($navigateTo_array:Array):void {
            _navigateTo_array = $navigateTo_array;
            var level_str:String = $navigateTo_array.join(".");
            _gameStatus.init(level_str);
            _scene.loadLevel(level_str);
            _gameStatus.updateScore(0, _scene.numCatsRemaining);
        }
        //
        private function onTouchEvent($event:Event):void {
            var forces:Vector.<Force> = $event.data as Vector.<Force>;
            _scene.updateForces(forces);
        }
        //
        private function onScoreUpdated($event:Event):void {
            _gameStatus.updateScore(_scene.numCatsRescued, _scene.numCatsRemaining);
            if (_scene.numCatsRescued == _scene.numCatsRemaining) {
               //level complete - move to next stage
               var stage_int:int = int(_navigateTo_array[1]);
               stage_int += 1;
               Application.GET_INSTANCE().navigateTo("game/"+_navigateTo_array[0]+"/"+stage_int);  
            }
        }
        //
    }
}
