package com.pokelondon.display.game {
    import nape.callbacks.CbType;
    import nape.geom.Vec2;
    import nape.space.Space;

    import starling.display.MovieClip;
    import starling.display.Sprite;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
    import starling.utils.deg2rad;

    import com.emibap.textureAtlas.DynamicAtlas;
    import com.pokelondon.application.Loader;
    import com.pokelondon.forces.Force;
    import com.pokelondon.utils.Constants;

    import flash.geom.Rectangle;
    import flash.utils.Dictionary;

    /**
     * @author jamieingram
     */
    public class GameCats extends Sprite {
        
        private var _space:Space;
        private var _cats:Vector.<Cat>;
        //
        public function GameCats() {
            _cats = new Vector.<Cat>();
        }
        //
        public function create($num_int:int,$type_str:String,$callbackType:CbType):void {
            //
            _cats = new Vector.<Cat>();
            //
            var cat_mc:MovieClipCat = new MovieClipCat();
            var cat_ta:TextureAtlas = DynamicAtlas.fromMovieClipContainer(cat_mc,Loader.SCALE_FACTOR);
            var walking_textures:Vector.<Texture> = cat_ta.getTextures("cat_mc");
            var sleeping_textures:Vector.<Texture> = cat_ta.getTextures("sleeping_mc");
            var falling_textures:Vector.<Texture> = cat_ta.getTextures("falling_mc");
            //
            for (var i:int = 0 ; i < $num_int ; i++) {
                var catAnim_mc:MovieClip = new MovieClip(walking_textures,30);
                catAnim_mc.scaleX = catAnim_mc.scaleY = 1 / Loader.SCALE_FACTOR;
                var cat:Cat = new Cat($type_str,catAnim_mc,_space,$callbackType);
                //
                var sleepAnim_mc:MovieClip = new MovieClip(sleeping_textures,30);
                sleepAnim_mc.scaleX = sleepAnim_mc.scaleY = 1 / Loader.SCALE_FACTOR;
                sleepAnim_mc.loop = false;
                cat.setAnimation("sleep",sleepAnim_mc);
                //
                var fallAnim_mc:MovieClip = new MovieClip(falling_textures,24);
                fallAnim_mc.scaleX = fallAnim_mc.scaleY = 1 / Loader.SCALE_FACTOR;
                fallAnim_mc.loop = false;
                cat.setAnimation("fall",fallAnim_mc);
                //
                _cats.push(cat);
                addChild(cat);
            }
        }
        //
        public function updatePositions():void {
        	for (var i:int = 0 ; i < _cats.length ; i++) {
                var cat:Cat = _cats[i];
                cat.update();
            }
        }
        //
        public function applyForces($forces:Dictionary):void {
            //
        	for (var i:String in $forces) {
                var force:Force = $forces[i];
                var pos:Vec2 = new Vec2(force.x,force.y);
                for (var j:int = 0 ; j < _cats.length ; j++) {
                    var cat:Cat = _cats[j];
                    var distance:Number = Vec2.distance(cat.pos,pos);
                    if (distance < force.influence) {
                        //this cat is effected by the force
                        var power:Number = force.strength - ((distance / force.influence) * force.strength);
                        var velocity:Vec2 = cat.pos.sub(pos);
                        velocity = velocity.normalise();
                        velocity = velocity.mul(power);
                        cat.addVelocity(velocity);
                    }
                }
            }
        }
        //
        public function checkAttractors($attractors:Vector.<Force>):void {
            var forcePos:Vec2 = Vec2.get();
        	for (var i:int = 0 ; i < $attractors.length ; i++) {
                var force:Force = $attractors[i];
                for (var j:int = 0 ; j < _cats.length ; j++) {
                    var cat:Cat = _cats[j];
                    forcePos.x = force.x;
                    forcePos.y = force.y;
                    var distance:Number = Vec2.distance(cat.pos,forcePos);
                    if (distance < force.influence) {
                        //this cat should be effected by the attractor
                        var velocity:Vec2 = forcePos.sub(cat.pos);
                        velocity.length = cat.body.mass * 1e6 / (distance * distance);
                        velocity = velocity.mul(force.strength * (1 / Constants.FPS_INT));
                        cat.addVelocity(velocity);
                    }
                }
            }
        }
        //
        public function randomisePosition($rect:Rectangle):void {
            for (var i:int = 0 ; i < _cats.length ; i++) {
                var cat:Cat = _cats[i];
                var pos:Vec2 = new Vec2($rect.x + Math.round($rect.width * Math.random()),$rect.y + Math.round($rect.height * Math.random()));
                cat.setPosition(pos);
                var rotation_num:Number = deg2rad(Math.random() * 360);
                cat.setRotation(rotation_num);
                cat.update();
            }
        }
        //
        public function destroy():void {
            for (var i:int = 0 ; i < _cats.length ; i++) {
                var cat:Cat = _cats[i];
                cat.destroy();
            }
            //
            _cats = new Vector.<Cat>();
        }
        //
        public function set space($space:Space):void {
			_space = $space;
        }
        //
    }
}
