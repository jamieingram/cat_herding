package com.pokelondon.forces {
    import nape.phys.Body;
    /**
     * @author jamieingram
     */
    public class Force {
        
        public static const FORCE_CIRCLE:String = "circle";
        
        public var id_str:String;
        public var x:Number;
        public var y:Number;
        public var type:String;
        public var influence:int;
        public var strength:int;
        public var remove:Boolean = false;
        public var body:Body;
        
	    public function Force() {
	        
	    }
    }
}
