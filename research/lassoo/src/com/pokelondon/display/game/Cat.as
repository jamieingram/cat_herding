package com.pokelondon.display.game {
    import nape.callbacks.CbType;
    import nape.geom.Vec2;
    import nape.phys.Body;
    import nape.phys.BodyType;
    import nape.shape.Circle;
    import nape.space.Space;

    import starling.core.Starling;
    import starling.display.MovieClip;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.utils.deg2rad;

    import flash.utils.Dictionary;

    /**
     * @author jamieingram
     */
    public class Cat extends Sprite {
        private var _type_str : String;
        private var _anim_mc :MovieClip;
        private var _space : Space;
        private var _body : Body;
        private var _energy_int:int;
        private var _isSleeping_bool:Boolean;
        private var _targetRotation_num : Number;
        private var _animations:Dictionary;
        private var _idleCount_int : int;
        private var _cbType : CbType;
        
        public function Cat($type_str:String,$cat_mc:MovieClip,$space:Space,$callbackType:CbType) {
            _type_str = $type_str;
            _space = $space;
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            _energy_int = Math.round(Math.random() * 1000);
            _animations = new Dictionary();
            _anim_mc = $cat_mc;
			_animations["default"] = $cat_mc;
            _idleCount_int = Math.round(Math.random() * 300);
            _cbType = $callbackType;
        }
        //
        private function onAddedToStage():void {
        	removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            _body = new Body(BodyType.DYNAMIC);
            _body.cbTypes.add(_cbType);
            _body.shapes.add(new Circle(_anim_mc.height >> 1));
            _body.space = _space;
            _body.userData.name = "cat";
            _body.userData.cat = this;
            addChild(_anim_mc);
            Starling.juggler.add(_anim_mc);
            _anim_mc.pivotX = _anim_mc.width >> 1;
            _anim_mc.pivotY = _anim_mc.height >> 1;
            //
            _body.velocity.set(new Vec2(Math.random() * 100 - 50,Math.random() * 100 - 50));
            _targetRotation_num = _body.velocity.angle + Math.PI;
            _body.rotation = _targetRotation_num;
            //
        }
        //
        public function setPosition($pos:Vec2):void {
        	_body.position = $pos;
        }
        //
        public function setRotation($rotation_int:int):void {
        	_body.rotation = deg2rad($rotation_int);
        }
        //
        public function addVelocity($vel:Vec2):void {
            if (_isSleeping_bool == true) {
                wake();
            }
            var targetRotation_num:Number = $vel.angle + Math.PI;
            var diff:Number = (targetRotation_num - _body.rotation) % (2 * Math.PI);
            if (Math.abs(diff) > Math.PI) {
            	diff = (diff < 0) ? diff + (Math.PI * 2) : diff - (Math.PI * 2); 
            }
            if (Math.abs(diff) < (Math.PI / 4)) {
                _body.applyImpulse($vel);
            }else{
                _body.applyImpulse($vel.mul(0.1));
            }
        }
        //
        public function setAnimation($id_str:String,$anim_mc:MovieClip,$yOffset_num:Number = 0):void {
            _animations[$id_str] = $anim_mc;
            $anim_mc.pivotX = $anim_mc.width >> 1;
            $anim_mc.pivotY = $anim_mc.height >> 1;
            $anim_mc.y += $yOffset_num;
        }
        //
        public function showAnimation($id_str:String):void {
            var anim_mc:MovieClip = _animations[$id_str];
			if (anim_mc != null) {
                anim_mc.currentFrame = 1;
			    Starling.juggler.remove(_anim_mc);
			    removeChild(_anim_mc);
			    _anim_mc = anim_mc;
			    addChild(_anim_mc);
			    Starling.juggler.add(_anim_mc);
			}
        }
        //
        public function update():void {
            //
            if (_body.space == null) return;
            //
            if (_isSleeping_bool == true) {
            	_energy_int += 5;
                if (_energy_int == 1000) {
                    _body.velocity.set(new Vec2(Math.random() * 100 - 50,Math.random() * 100 - 50));
                    wake();
                }
            }else{
	            //
	            _targetRotation_num = _body.velocity.angle + Math.PI;
                var diff:Number = (_targetRotation_num - _body.rotation) % (2 * Math.PI);
                if (Math.abs(diff) > Math.PI) {
                    diff = (diff < 0) ? diff + (Math.PI * 2) : diff - (Math.PI * 2); 
                }
	            _body.rotation += diff / 10;
	            //
	            var speed:Number = _body.velocity.length;
                //assume the speed is between 0 and 60, and that the max frame rate is 60
                _anim_mc.fps = Math.max(1,Math.round(speed));
                //
                if (speed > 20) {
                    _body.velocity.muleq(0.95);
                    _idleCount_int = 0;
                }else{
                    _idleCount_int++;
                	_energy_int--;
                	if (_energy_int == 0 || _idleCount_int == 300) sleep();
                }
	            //update the display object
		        x = _body.position.x;
		        y = _body.position.y;
		        rotation = _body.rotation;
            }
            //				
        }
        //
        public function sleep():void {
            _energy_int = 0;
            _isSleeping_bool = true;
            //play the sleeping animation
            showAnimation("sleep");
            _body.velocity.set(new Vec2(0,0));
            _body.angularVel = 0;
            _body.allowMovement = _body.allowRotation = false;
        }
        //
        public function wake():void {
            _idleCount_int = 0;
            _energy_int = 1000;
            _isSleeping_bool = false;
            showAnimation("default");
            _body.allowMovement = _body.allowRotation = true;
        }
        //
        public function remove():void {
            _body.cbTypes.remove(_cbType);
            Starling.juggler.remove(_anim_mc);
            _body.space = null;
            showAnimation("fall");
            
        }
        //
        public function hide():void {
            _body.cbTypes.remove(_cbType);
            Starling.juggler.remove(_anim_mc);
            _body.space = null;
            removeChild(_anim_mc);
        }
        //
        public function destroy():void {
            hide();
            for (var i:* in _animations) {
                var anim_mc:MovieClip = _animations[i];
                anim_mc.dispose();
            }
            _body = null;
            _animations = null;
        }
        //
        public function get pos():Vec2 {
            return _body.position;
        }
        //
        public function get body():Body {
            return _body;
        }
    }
}
