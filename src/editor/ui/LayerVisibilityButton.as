package editor.ui 
{
	import editor.Layer;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class LayerVisibilityButton extends Sprite
	{
		[Embed(source = '../../../assets/eye_closed.png')]
		static private const ImgClosed:Class;
		[Embed(source = '../../../assets/eye_open.png')]
		static private const ImgOpen:Class;
		
		public var layerNum:uint;
		private var image:Bitmap;
		
		public function LayerVisibilityButton(layerNum:uint) 
		{
			this.layerNum = layerNum;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function destroy(e:Event):void
		{
			removeEventListener(MouseEvent.CLICK, onClick);
			removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		private function onClick(e:MouseEvent):void
		{
			var layer:Layer = Ogmo.level.layers.getChildAt(layerNum) as Layer;
				
			if (e.ctrlKey)
			{
				var i:int;
				for (i = 0; i < Ogmo.level.layers.numChildren; i++)
					(Ogmo.level.layers.getChildAt(i) as Layer).enabled = false;
				
				layer.enabled = true;
				
				for (i = 0; i < Ogmo.windows.windowLayersVisibilities.numChildren; i++)
					(Ogmo.windows.windowLayersVisibilities.getChildAt(i) as LayerVisibilityButton).setImage();
			}
			else
			{
				layer.enabled = !layer.enabled;
				setImage();
			}
		}
		
		public function setImage():void
		{	
			if (image)
				removeChild(image);
				
			var layer:Layer = Ogmo.level.layers.getChildAt(layerNum) as Layer;
			
			if (layer.enabled)
				addChild(image = new ImgOpen);
			else
				addChild(image = new ImgClosed);
		}
		
	}

}