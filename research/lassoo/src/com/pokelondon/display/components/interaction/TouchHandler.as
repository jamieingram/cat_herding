package com.pokelondon.display.components.interaction {
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    import com.pokelondon.forces.Force;
    import com.pokelondon.utils.Constants;

    /**
     * @author jamieingram
     */
    public class TouchHandler extends Sprite {
        
        private var _numMarkers_int:int;
        private var _markers : Vector.<TouchMarker>;
        private var _strength_int : int;

        public function TouchHandler() {
            addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
            _markers = new Vector.<TouchMarker>();
            _numMarkers_int = 2;
        }
        //
        private function onAddedToStage():void {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            for (var i:int = 0 ; i < _numMarkers_int ; i++) {
                var marker:TouchMarker = new TouchMarker();
                addChild(marker);
                _markers.push(marker);
                marker.visible = false;
            }
        }
        //
        public function enable():void {
            stage.addEventListener(TouchEvent.TOUCH, onTouch);
        }
        //
        public function disable():void {
            stage.removeEventListener(TouchEvent.TOUCH, onTouch);
            for (var i:int = 0 ; i < _numMarkers_int ; i++) {
                var marker:TouchMarker = new TouchMarker();
                marker.visible = false;
            }
        }
        //
        private function onTouch($event:TouchEvent):void {
            var touches:Vector.<Touch> = $event.touches;
            var dispatchEvent_bool:Boolean = false;
            var repellers:Vector.<Force> = new Vector.<Force>();
            //
            for (var i:int = 0 ; i < _numMarkers_int ; i++) {
                var marker:TouchMarker = _markers[i];
                if (touches.length > i) {
                    var repeller:Force = new Force();
                    repeller.id_str = "finger"+i;
                	var finger:Touch = touches[i];
                    switch (finger.phase) {
                        case TouchPhase.ENDED:
                        	marker.visible = false;
                            repeller.remove = true;
                            repellers.push(repeller);
                            dispatchEvent_bool = true;
                        break;
                        case TouchPhase.BEGAN:
                        	marker.visible = true;
                            _strength_int = 20;
                            repeller.strength = _strength_int;
                        case TouchPhase.MOVED:
                        	marker.x = finger.globalX;
               		 		marker.y = finger.globalY;
                            repeller.type = Force.FORCE_CIRCLE;
                            repeller.x = marker.x;
                            repeller.y = marker.y;
                            repeller.influence = 100;
                            if (_strength_int > 3) _strength_int--;
                            repeller.strength = _strength_int;
                            repellers.push(repeller);
                            dispatchEvent_bool = true;
                            trace(repeller.strength);
                        break;
                    }
                }else{
                    marker.visible = false;
                }
            }
            if (dispatchEvent_bool == true) {
                dispatchEventWith(Constants.EVENT_TOUCH,false,repellers);
            }
        }
    }
}
