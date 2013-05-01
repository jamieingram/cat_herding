package com.pokelondon.display.game {
    import nape.callbacks.CbEvent;
    import nape.callbacks.CbType;
    import nape.callbacks.InteractionCallback;
    import nape.callbacks.InteractionListener;
    import nape.callbacks.InteractionType;
    import nape.dynamics.Arbiter;
    import nape.dynamics.ArbiterList;
    import nape.geom.Vec2;
    import nape.phys.Body;
    import nape.phys.BodyType;
    import nape.shape.Circle;
    import nape.shape.Polygon;
    import nape.space.Space;
    import nape.util.BitmapDebug;

    import starling.animation.Transitions;
    import starling.animation.Tween;
    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;

    import com.emibap.textureAtlas.DynamicAtlas;
    import com.pokelondon.application.Loader;
    import com.pokelondon.forces.Force;
    import com.pokelondon.forces.ForceType;
    import com.pokelondon.utils.Constants;

    import flash.display.MovieClip;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;

    //
    /**
     * @author jamieingram
     */
    public class GameScene extends Sprite {
        private var _background_image : Image;
        private var _space : Space;
        private var _cats : GameCats;
        private var _scene_mc:MovieClip;
        private var _background_spr : Sprite;
        private var _debug : BitmapDebug;
        private var _forces : Dictionary;
        private var _attractors : Vector.<Force>;
        private var _hazards : Vector.<Force>;
        private var _collision_listener : InteractionListener;
        private var _exit_listener : InteractionListener;
        private var _hazardSensorType : CbType;
        private var _catSensorType : CbType;
        private var _overlay_spr : Sprite;
        private var _exitSensorType : CbType;
        private var _exitAnim_mc : starling.display.MovieClip;
        private var _exitBody : Body;
        private var _currentLevel_str : String;
        private var _numCatsRescued_int:int;
        private var _numCatsRemaining_int:int;
        private var _numCatsStart_int:int;

        public function GameScene() {
            addEventListener(Event.ADDED_TO_STAGE, onGameAddedToStage);
            _forces = new Dictionary();
            _attractors = new Vector.<Force>();
            _hazards = new Vector.<Force>();
            _currentLevel_str = "";
        }

        //
        private function onGameAddedToStage() : void {
            removeEventListener(Event.ADDED_TO_STAGE, onGameAddedToStage);
            _space = new Space(new Vec2(0, 0));
            _background_spr = new Sprite();
            addChild(_background_spr);
            //
            _cats = new GameCats();
            _cats.space = _space;
            addChild(_cats);
            //
            _overlay_spr = new Sprite();
            addChild(_overlay_spr);
            //
            if (Constants.DEBUG_ENABLED == true) {
                _debug = new BitmapDebug(stage.stageWidth * 2, stage.stageHeight * 2, 0, true);
                Starling.current.nativeOverlay.addChild(_debug.display);
            }
            //
            _hazardSensorType = new CbType();
            _catSensorType = new CbType();
            _collision_listener = new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, _hazardSensorType, _catSensorType, onCatCollision);
            //
            _exitSensorType = new CbType();
            _exit_listener = new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, _exitSensorType, _catSensorType, onCatFlapEnter);
           
        }

        //
        public function loadLevel($level_str:String) : void {
            //
            var current_array:Array = _currentLevel_str.split(".");
            var level_array:Array = $level_str.split(".");
            var pos_int:int = 1;
            //
            _currentLevel_str = $level_str;
            //
            //destroy all elements in the level (except the background)
            removeLevelElements();
            //
            if (current_array[0] != level_array[0]) {
                // remove the existing background
            	if (_currentLevel_str != "" && _background_image != null) {
               		_background_spr.removeChild(_background_image);
                	_background_image.dispose();
            	}
                //
                //we have requested a new level - find the correct background and immediately move background to correct position
	            switch (int(level_array[0])) {
	                case 1:
	                    _scene_mc = new MovieClipScene1();
	                    break;
	                case 2:
	                    _scene_mc = new MovieClipScene2();
	                    break;
	            }
	            var background_ta : TextureAtlas = DynamicAtlas.fromMovieClipContainer(_scene_mc.background_mc, Loader.SCALE_FACTOR);
	            var textures : Vector.<Texture> = background_ta.getTextures();
	            _background_image = new Image(textures[0]);
	            _background_image.width = stage.stageWidth;
	            _background_image.scaleY = _background_image.scaleX;
	            _background_spr.addChild(_background_image);
                //
                // put the background at the correct position
                if (int(level_array[1]) > 0) pos_int = int(level_array[1]);
	        	_background_image.y = -_background_image.height + (pos_int * stage.stageHeight);
                //
                populateLevel();
            	//
            	start();
            }else{
                populateLevel();
                //use the existing background - just animate to the correct position
                if (int(level_array[1]) > 0) pos_int = int(level_array[1]);
                var destY_int:int = -_background_image.height + (pos_int * stage.stageHeight);
                // create a Tween object
				var t1:Tween = new Tween(_background_image, 2, Transitions.EASE_IN_OUT);
                t1.onComplete = onSceneAnimateComplete;
                t1.moveTo(0, destY_int);
                //
                _overlay_spr.y = -stage.stageHeight;
                var t2:Tween = new Tween(_overlay_spr, 2, Transitions.EASE_IN_OUT);
                t2.moveTo(0, 0);
                //
                _cats.y = -stage.stageHeight;
                var t3:Tween = new Tween(_cats, 2, Transitions.EASE_IN_OUT);
                t3.moveTo(0, 0);
				//add tweens to the Juggler
				Starling.juggler.add(t1);
                Starling.juggler.add(t2);
                Starling.juggler.add(t3);
            }
        }
        //
        private function onSceneAnimateComplete():void {
            start();
        }
        //
        private function removeLevelElements():void {
            stop();
            _cats.destroy();
            _space.bodies.clear();
            for (var i:int = 0 ; i < _overlay_spr.numChildren ; i++) {
                _overlay_spr.removeChildAt(i);
            }
        }
        //
        private function populateLevel():void {
          	
            var current_array:Array = _currentLevel_str.split(".");
            var stage_mc:MovieClip = _scene_mc["stage"+current_array[1]+"_mc"];
            //
            createWalls(stage_mc.walls_mc);
            //
            var attractors_mc:MovieClip = stage_mc.attractors_mc;
            if (attractors_mc != null) createStaticForces(stage_mc.attractors_mc, ForceType.ATTRACTOR);
            //
            var hazards_mc:MovieClip = stage_mc.hazards_mc;
            if (hazards_mc != null) createStaticForces(stage_mc.hazards_mc, ForceType.HAZARD);
            //
            createExit(stage_mc.extras_mc);
            //
            //TODO define the cats available in this level
            _numCatsStart_int = _numCatsRemaining_int = 5;
            _numCatsRescued_int = 0;
            var safeArea_mc:MovieClip = stage_mc.safeArea_mc;
            _cats.create(_numCatsStart_int, CatType.NORMAL, _catSensorType);
            _cats.randomisePosition(new Rectangle(safeArea_mc.x, safeArea_mc.y, safeArea_mc.width, safeArea_mc.height));
            //
        }
        //
        public function start() : void {
            if (!_space.listeners.has(_collision_listener)) {
	            _space.listeners.add(_collision_listener);
	            _space.listeners.add(_exit_listener);
            }
            //
            if (!hasEventListener(Event.ENTER_FRAME)) addEventListener(Event.ENTER_FRAME, updateScene);
        }

        //
        public function stop() : void {
            _space.listeners.remove(_collision_listener);
            _space.listeners.remove(_exit_listener);
            removeEventListener(Event.ENTER_FRAME, updateScene);
        }
		//
		public function destroy():void {
            removeLevelElements();
            stop();
        }
        //
        private function updateScene() : void {
            _space.step(1 / Constants.FPS_INT);
            applyForces();
            _cats.updatePositions();
            //
            if (Constants.DEBUG_ENABLED == true) {
                _debug.clear();
                _debug.draw(_space);
                _debug.flush();
            }
        }

        //
        public function updateForces($forces : Vector.<Force>) : void {
            for (var i : int = 0; i < $forces.length; i++) {
                var force : Force = $forces[i];
                if (force.remove == true) {
                    delete _forces[force.id_str];
                } else {
                    // TODO cater for different types
                    _forces[force.id_str] = force;
                }
            }
        }

        //
        private function createWalls($walls_mc : MovieClip) : void {
            //
            var walls : Body = new Body(BodyType.STATIC);
            walls.userData.name = "walls";
            //
            for (var i : String in $walls_mc) {
                var wall_mc : MovieClip = $walls_mc[i];
                var wall : Array = Polygon.rect(wall_mc.x, wall_mc.y, wall_mc.width, wall_mc.height);
                walls.shapes.add(new Polygon(wall));
            }
            walls.space = _space;
        }

        //
        private function createStaticForces($ref_mc : MovieClip, $type_str : String) : void {
            var counter_int : int = 0;
            for (var i : String in $ref_mc) {
                var attractor_mc : MovieClip = $ref_mc[i];
                var body : Body = new Body(BodyType.STATIC);
                var force : Force = new Force();
                //
                switch (attractor_mc.name) {
                    case "circle":
                        body.allowMovement = body.allowRotation = false;
                        var shape : Circle = new Circle(attractor_mc.width >> 1);
                        if ($type_str == ForceType.HAZARD) {
                            shape.sensorEnabled = true;
                        }
                        body.shapes.add(shape);
                        body.position.x = attractor_mc.x;
                        body.position.y = attractor_mc.y;
                        body.space = _space;
                        body.userData.name = "force_" + counter_int;
                        force.x = body.position.x;
                        force.y = body.position.y;
                        force.influence = attractor_mc.width;
                        force.strength = 5;
                        force.body = body;
                        break;
                }
                //
                switch ($type_str) {
                    case ForceType.ATTRACTOR:
                        _attractors.push(force);
                        break;
                    case ForceType.HAZARD:
                        body.cbTypes.add(_hazardSensorType);
                        _hazards.push(force);
                        break;
                }
                counter_int++;
            }
        }
        //
        private function applyForces() : void {
            _cats.applyForces(_forces);
            _cats.checkAttractors(_attractors);
        }
        //
        private function onCatCollision($callback : InteractionCallback) : void {
            // a cat has collided with a hazard - play the remove animation, and deactivate it
            var list : ArbiterList = $callback.arbiters;
            var i : int = 0;
            while (i < list.length) {
                var obj : Arbiter = list.at(i);
                var cat : Cat;
                if (obj.body1.userData.name == "cat") {
                    cat = obj.body1.userData.cat;
                } else if (obj.body2.userData.name == "cat") {
                    cat = obj.body2.userData.cat;
                }
                if (cat != null) {
                    cat.remove();
                    break;
                } else i++;
            }
        }

        //
        private function onCatFlapEnter($callback : InteractionCallback) : void {
            var list : ArbiterList = $callback.arbiters;
            var i : int = 0;
            while (i < list.length) {
                var obj : Arbiter = list.at(i);
                var cat : Cat;
                if (obj.body1.userData.name == "cat") {
                    cat = obj.body1.userData.cat;
                } else if (obj.body2.userData.name == "cat") {
                    cat = obj.body2.userData.cat;
                }
                if (cat != null) {
                    //a cat has been saved
                    cat.hide();
                    _numCatsRescued_int++;
                    var event:Event = new Event(Constants.EVENT_SCORE);
                    dispatchEvent(event);
                    break;
                } else i++;
            }
            Starling.juggler.remove(_exitAnim_mc);
            _exitAnim_mc.currentFrame = 1;
            _exitAnim_mc.play();
            Starling.juggler.add(_exitAnim_mc);
        }

        //
        private function createExit($holder_mc : MovieClip) : void {
            var exit_ta : TextureAtlas = DynamicAtlas.fromMovieClipContainer($holder_mc, Loader.SCALE_FACTOR);
            var exit_mc : MovieClip = $holder_mc.exit_mc;
            var exit_textures : Vector.<Texture> = exit_ta.getTextures("exit_mc");
            _exitAnim_mc = new starling.display.MovieClip(exit_textures, 30);
            _exitAnim_mc.scaleX = _exitAnim_mc.scaleY = 1 / Loader.SCALE_FACTOR;
            _exitAnim_mc.loop = false;
            _exitAnim_mc.stop();
            _exitAnim_mc.x = exit_mc.x;
            _exitAnim_mc.y = exit_mc.y - 12;
            _overlay_spr.addChild(_exitAnim_mc);
            //
            _exitBody = new Body();
            var exit_array:Array = Polygon.rect(exit_mc.x, exit_mc.y - 20, exit_mc.width, 5);
            var exit:Polygon = new Polygon(exit_array);
            exit.sensorEnabled = true;
            _exitBody.shapes.add(exit);
            _exitBody.cbTypes.add(_exitSensorType);
            _exitBody.space = _space;
        }

        public function get numCatsRemaining():int {
            return _numCatsRemaining_int;
        }
        //
        public function get numCatsRescued():int {
            return _numCatsRescued_int;
        }
        //
        public function get numCatsStart():int {
            return _numCatsStart_int;
        }
        //
    }
}
