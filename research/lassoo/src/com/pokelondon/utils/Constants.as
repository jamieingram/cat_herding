package com.pokelondon.utils {
    
    import starling.errors.AbstractClassError;

    public class Constants {
        public function Constants() { throw new AbstractClassError(); }
        // 
        // To use landscape mode, exchange the values of width and height, and 
        // set the "aspectRatio" element in the config XML to "landscape". (You'll also have to
        // update the background, startup- and "Default" graphics accordingly.)
        
        public static const DEBUG_ENABLED:Boolean = false;
        public static const STAGE_WIDTH:int  = 480;
        public static const STAGE_HEIGHT:int = 320;
        //
        public static const FPS_INT:int = 60;
        //
        public static const EVENT_TOUCH:String = "touch_event";
        public static const EVENT_SCORE:String = "score_event";
    }
}