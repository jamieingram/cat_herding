package com.pokelondon.display.components.interaction {
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

    /**
     * @author jamieingram
     */
    public class DisplayTouchHandler extends Sprite {
        
        private var _numMarkers_int:int = 2;
        private var _markers:Vector.<DisplayTouchMarker>;
        
        public function DisplayTouchHandler() {
            addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
            _markers = new Vector.<DisplayTouchMarker>();
        }
        //
        private function onAddedToStage():void {
            for (var i:int = 0 ; i < _numMarkers_int ; i++) {
                var marker:DisplayTouchMarker = new DisplayTouchMarker();
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
                var marker:DisplayTouchMarker = new DisplayTouchMarker();
                marker.visible = false;
            }
        }
        //
        private function onTouch($event:TouchEvent):void {
            var touches:Vector.<Touch> = $event.touches;
            for (var i:int = 0 ; i < _numMarkers_int ; i++) {
                var marker:DisplayTouchMarker = _markers[i];
                if (touches.length > i) {
                	var finger:Touch = touches[i];
                    switch (finger.phase) {
                        case TouchPhase.ENDED:
                        	marker.visible = false;
                        break;
                        case TouchPhase.BEGAN:
                        	marker.visible = true;
                        case TouchPhase.MOVED:
                        	marker.x = finger.globalX;
               		 		marker.y = finger.globalY;
                        break;
                    }
                }else{
                    marker.visible = false;
                }
            }
        }
    }
}
