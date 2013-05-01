package com.pokelondon.display.components.interaction {
    import starling.display.Image;
    import starling.events.Event;
    import starling.textures.Texture;

    import com.pokelondon.display.SpriteHolder;

    import flash.display.BitmapData;
    import flash.display.Sprite;
    /**
     * @author jamieingram
     */
    public class TouchMarker extends SpriteHolder {
        public function TouchMarker() {
            addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
        }
        //
        private function onAddedToStage($event:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            // create a vector shape (Graphics) to use as an offscreen canvas
            var radius:int = 10;
			var shape:flash.display.Sprite = new flash.display.Sprite();
            shape.graphics.beginFill(0xFF0000);
			shape.graphics.drawCircle(radius,radius,radius);
            shape.graphics.endFill();
			// create a BitmapData buffer
			var bmd:BitmapData = new BitmapData(radius * 2, radius * 2, true, 0);
			// draw the shape on the bitmap
			bmd.draw(shape);
			// create a Texture out of the BitmapData
			var texture:Texture = Texture.fromBitmapData(bmd);
            // create an Image out of the texture
			var image:Image = new Image(texture);
            // set the registration point
			image.pivotX = image.width >> 1;
            image.pivotY = image.height >> 1;
            addChild(image);
        }
    }
}
