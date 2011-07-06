package editor 
{
	import flash.display.Sprite;

	public class Node extends Sprite
	{
		private var object:GameObject;
		private var drawObject:Sprite;
		private var drawDot:Sprite;
		
		public function Node( object:GameObject, x:int, y:int ) 
		{
			this.object = object;
			this.x 		= x;
			this.y 		= y;
			
			if (object.definition.nodesDefinition.drawObject)
			{
				addChild( drawObject = new Sprite );
				drawObject.alpha = 0.5;
				drawObject.x = -object.definition.originX;
				drawObject.y = -object.definition.originY;
			}
			
			addChild( drawDot = new Sprite );
			
			updateImage();
		}
		
		public function move( h:int, v:int ):void
		{
			x = Math.max( Math.min( x + h, Ogmo.level.levelWidth - Ogmo.level.currentLayer.gridSize ), 0 );
			y = Math.max( Math.min( y + v, Ogmo.level.levelHeight - Ogmo.level.currentLayer.gridSize ), 0 );
		}
		
		public function updateImage():void
		{
			if (drawObject)
			{
				drawObject.graphics.clear();
				drawObject.graphics.beginBitmapFill( object.definition.bitmapData );
				if (object.definition.tile)
				{
					drawObject.graphics.drawRect( 0, 0, object.objWidth, object.objHeight );
				}
				else
				{
					drawObject.graphics.drawRect( 0, 0, object.definition.imgWidth, object.definition.imgHeight );
					drawObject.scaleX = object.objWidth / object.definition.imgWidth;
					drawObject.scaleY = object.objHeight / object.definition.imgHeight;
				}
				drawObject.graphics.endFill();
			}
			
			drawDot.graphics.clear();
			drawDot.graphics.beginFill( object.definition.nodesDefinition.color );
			drawDot.graphics.drawRect( -3, -3, 6, 6 );
			drawDot.graphics.endFill();
		}
		
		public function get xml():XML
		{
			var xml:XML = <node/>;
			
			xml.@x = x + object.x;
			xml.@y = y + object.y;
			
			return xml;
		}
		
	}

}