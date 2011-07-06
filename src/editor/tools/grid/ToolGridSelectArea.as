package editor.tools.grid 
{
	import editor.Layer;
	import editor.Utils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ToolGridSelectArea extends GridTool
	{
		private const C_SELECT:uint 	= 0xFFFF00;
		private const C_SELECTION:uint	= 0x00FFFF;
		
		private var selectParent:Sprite;
		private var selectDraw:Sprite;
		private var selection:Bitmap;
		private var moving:Boolean = false;
		private var selecting:Boolean = false;
		private var startAt:Point = new Point;
		
		public function ToolGridSelectArea(layer:Layer) 
		{
			super(layer);
			
			addChild(selectParent = new Sprite);
			selectParent.addChild(selectDraw = new Sprite);
			selectParent.addChild(selection = new Bitmap);
			selectParent.visible = false;
			selectParent.alpha = 0.5;
			selectParent.scaleX = selectParent.scaleY = layer.gridSize;
		}
		
		override protected function activate(e:Event):void 
		{
			super.activate(e);
			layer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			layer.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		override protected function deactivate(e:Event):void 
		{
			super.deactivate(e);
			layer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			layer.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			Ogmo.point.x = e.stageX;
			Ogmo.point.y = e.stageY;
			Ogmo.point = globalToLocal(Ogmo.point);
			
			if (insideSelection(Ogmo.point))
			{
				Ogmo.windows.mouse = false;
				moving = true;
				startAt.x = Ogmo.point.x;
				startAt.y = Ogmo.point.y;
			}
			else if (Ogmo.point.x >= 0 && Ogmo.point.x < Ogmo.level.levelWidth && Ogmo.point.y >= 0 && Ogmo.point.y < Ogmo.level.levelHeight)
			{
				clearSelection();
				Ogmo.windows.mouse = false;
				selecting = true;
				Ogmo.point = layer.convertPoint(Ogmo.point);
				startAt.x = Ogmo.point.x;
				startAt.y = Ogmo.point.y;
			}
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			var ax:int = layer.convertX(e.localX);
			var ay:int = layer.convertY(e.localY);
			
			if (moving)
			{
				moving = false;
			}
			else if (selecting)
			{
				graphics.clear();
				selecting = false;
				
				Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, layer.gridSize);
				select(Ogmo.rect);
			}
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			var ax:int = layer.convertX(e.localX);
			var ay:int = layer.convertY(e.localY);
			
			if (moving)
			{
				
			}
			else if (selecting)
			{
				Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, layer.gridSize);
				graphics.clear();
				graphics.beginFill(C_SELECT, 0.4);
				graphics.drawRect(Ogmo.rect.x, Ogmo.rect.y, Ogmo.rect.width, Ogmo.rect.height);
				graphics.endFill();
			}
		}
		
		/* Returns whether the clicked position is within the selection rectangle. */
		private function insideSelection(pt:Point):Boolean
		{
			return (selectParent.visible && selection.bitmapData.rect.containsPoint(pt));
		}
		
		/* Selects a rectangle of the grid. */
		private function select(rect:Rectangle):void
		{
			selection.x = rect.x;
			selection.y = rect.y;
			
			rect.x /= layer.gridSize;
			rect.y /= layer.gridSize;
			rect.width /= layer.gridSize;
			rect.height /= layer.gridSize;
			
			Ogmo.point.x = Ogmo.point.y = 0;
			
			selection.bitmapData = new BitmapData(rect.width, rect.height);
			selection.bitmapData.copyPixels(gridLayer.grid.bitmapData, rect, Ogmo.point);
			
			selectDraw.graphics.clear();
			selectDraw.graphics.beginFill(C_SELECTION, 0.2);
			selectDraw.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			selectDraw.graphics.endFill();
			selectParent.visible = true;
			
			gridLayer.grid.setCellsRect(rect.x, rect.y, rect.width, rect.height, false);
		}
		
		/* Applies the selection to the area of the grid where it is currently sitting, then deselects it. */
		private function clearSelection():void
		{
			if (!selectParent.visible)
				return;
			
			Ogmo.point.x = selection.x / layer.gridSize;
			Ogmo.point.y = selection.y / layer.gridSize;
			
			gridLayer.storeUndo();
			gridLayer.grid.bitmapData.copyPixels(selection.bitmapData, selection.bitmapData.rect, Ogmo.point);
			
			selectParent.visible = false;
		}
		
	}

}