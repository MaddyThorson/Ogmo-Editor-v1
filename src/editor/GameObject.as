package editor 
{
	import editor.ui.*;
	import editor.definitions.*;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class GameObject extends Sprite
	{
		private var _selected:Boolean;
		private var draw:Sprite;
		private var layer:ObjectLayer;
		private var holder:Sprite;
		private var bg:Sprite;
		public var selBox:SelBox;
		public var grabbed:Point;
		public var resizing:Boolean;
		
		public var definition:ObjectDefinition;
		public var objWidth:int;
		public var objHeight:int;
		public var values:Vector.<Value>;
		public var nodes:Sprite;
		public var lines:Sprite;
		
		public function GameObject( layer:ObjectLayer, objDef:ObjectDefinition = null ) 
		{
			this.layer 	= layer;
			grabbed 	= null;
			_selected	= false;
			
			//The colored background drawn behind selected objects
			bg = new Sprite;
			addChild( bg );
			
			//Holds the actual drawn object image, rotates
			holder = new Sprite;
			addChild( holder );
			
			//The actual drawn object image
			draw = new Sprite;
			holder.addChild( draw );
			
			//The colored hollow rectangle around each object
			selBox = new SelBox( 8, 8, 1, SelBox.OBJECT_NOTSELECTED );
			addChild( selBox );
			
			addChild( nodes = new Sprite );
			addChild( lines = new Sprite );
			
			if (objDef)
				init( objDef );	
		}
		
		private function init( objDef:ObjectDefinition ):void
		{	
			definition = objDef;
			setSize( objDef.width, objDef.height );
			
			draw.x = -definition.originX;
			draw.y = -definition.originY;
			bg.x = -definition.originX;
			bg.y = -definition.originY;
			selBox.x = -definition.originX;
			selBox.y = -definition.originY;
			
			//Get values
			if (objDef.values)
			{
				values = new Vector.<Value>;
				for each ( var vd:ValueDefinition in objDef.values )
					values.push( vd.getValue() );
			}
			
			//Enforce object limits
			if (definition.limit > 0)
			{
				var amount:int = layer.getAmountType( definition.name );
				if (amount >= definition.limit)
					layer.removeType( definition.name, amount + 1 - definition.limit );
			}
		}
		
		private function drawBG():void
		{
			bg.graphics.clear();
			bg.graphics.beginFill( 0xFFFFFF, 0.2 );
			bg.graphics.drawRect( 0, 0, objWidth, objHeight );
			bg.graphics.endFill();
		}
		
		private function clearBG():void
		{
			bg.graphics.clear();
		}
		
		public function move( h:int, v:int ):void
		{
			var oldX:int = x;
			var oldY:int = y;
			
			x = Math.max( 0, Math.min( x + h, Ogmo.level.levelWidth - objWidth + definition.originX ) );
			y = Math.max( 0, Math.min( y + v, Ogmo.level.levelHeight - objHeight + definition.originY ) );
		}
		
		public function setSize( width:int, height:int ):void
		{
			width 	= Math.max( definition.width, width );
			width 	= Math.min( Ogmo.level.levelWidth - x, width );
			if (!definition.resizableX)
				width = definition.width;
			
			height 	= Math.max( definition.height, height );
			height 	= Math.min( Ogmo.level.levelHeight - y, height );
			if (!definition.resizableY)
				height = definition.height;
			
			objWidth 	= width;
			objHeight	= height;
			
			draw.graphics.clear();
			draw.graphics.beginBitmapFill( definition.bitmapData );
			if (definition.tile)
			{
				draw.graphics.drawRect( 0, 0, objWidth, objHeight );
			}
			else
			{
				draw.graphics.drawRect( 0, 0, definition.imgWidth, definition.imgHeight );
				draw.scaleX = objWidth / definition.imgWidth;
				draw.scaleY = objHeight / definition.imgHeight;
			}
			draw.graphics.endFill();
			
			selBox.setSize( objWidth, objHeight );
			drawBG();
			
			refreshNodes();
		}
		
		public function setAngle( to:Number ):void
		{
			if (definition.rotatable)
			{
				var go:Number = Math.round( to / definition.rotationPrecision ) * definition.rotationPrecision;
				angle = go;
				angle = angle % 360;
			}
		}
		
		public function rotate( dir:int = 1 ):void
		{
			if (definition.rotatable)
				angle = (angle + 360 + (definition.rotationPrecision * dir)) % 360;
		}
		
		public function collidesWithPoint( x:int, y:int ):Boolean
		{
			return (rect.contains( x, y ));
		}
		
		public function collidesWithObject( other:GameObject ):Boolean
		{
			return (rect.intersects( other.rect ));
		}
		
		public function collidesWithRectangle( other:Rectangle ):Boolean
		{
			return (rect.intersects( other ));
		}
		
		/* ========================== NODES ========================== */
		
		public function addNode( node:Node ):void
		{
			nodes.addChild( node );
			node.x -= x;
			node.y -= y;
			refreshLines();
		}
		
		public function removeNode( node:Node ):void
		{
			nodes.removeChild( node );
			refreshLines();
		}
		
		public function removeAllNodes():void
		{
			while (nodes.numChildren > 0)
				nodes.removeChildAt( 0 );
			refreshLines();
		}
		
		public function removeFirstNode( times:uint = 1 ):void
		{
			for ( var i:int = 0; i < times; i++ )
				nodes.removeChildAt( 0 );
			refreshLines();
		}
		
		public function getAmountOfNodes():uint
		{
			return nodes.numChildren;
		}
		
		public function hasNodeAt( x:int, y:int ):Boolean
		{
			for ( var i:int = 0; i < nodes.numChildren; i++ )
			{
				if (nodes.getChildAt( i ).x == x - this.x && nodes.getChildAt( i ).y == y - this.y)
					return true;
			}
			return false;
		}
		
		public function removeNodeAt( x:int, y:int ):void
		{
			for ( var i:int = 0; i < nodes.numChildren; i++ )
			{
				if (nodes.getChildAt( i ).x == x - this.x && nodes.getChildAt( i ).y == y - this.y)
				{
					nodes.removeChildAt( i );
					refreshLines();
					return;
				}
			}
		}
		
		private function refreshNodes():void
		{
			for ( var i:int = 0; i < nodes.numChildren; i++ )
			{
				(nodes.getChildAt( i ) as Node).updateImage();
			}
			refreshLines();
		}
		
		private function refreshLines():void
		{
			if (definition.nodesDefinition == null || definition.nodesDefinition.lineMode == NodesDefinition.NONE)
				return;
			
			lines.graphics.clear();
			
			var color:uint = definition.nodesDefinition.color;
			var n:Node;
			var i:int;
			
			lines.graphics.lineStyle( 1, color );
			if (definition.nodesDefinition.lineMode == NodesDefinition.PATH || definition.nodesDefinition.lineMode == NodesDefinition.CIRCUIT)
			{
				lines.graphics.moveTo( 0, 0 );
				for ( i = 0; i < nodes.numChildren; i++ )
				{
					n = nodes.getChildAt( i ) as Node;
					lines.graphics.lineTo( n.x, n.y );
				}
				
				if (nodes.numChildren > 0 && definition.nodesDefinition.lineMode == NodesDefinition.CIRCUIT)
					lines.graphics.lineTo( 0, 0 ); 
			}
			else if (definition.nodesDefinition.lineMode == NodesDefinition.FAN)
			{
				for ( i = 0; i < nodes.numChildren; i++ )
				{
					n = nodes.getChildAt( i ) as Node;
					lines.graphics.moveTo( 0, 0 );
					lines.graphics.lineTo( n.x, n.y );
				}
			}
		}
		
		/* ========================== GETS/SETS ========================== */
		
		public function deepCopy():GameObject
		{
			var o:GameObject = new GameObject( layer, definition );
			o.x = x;
			o.y = y;
			
			o.setAngle( angle );			
			o.setSize( objWidth, objHeight );
			
			var i:int;
			
			//Copy the values
			if (values)
			{
				for ( i = 0; i < values.length; i++ )
					o.values[ i ].value = values[ i ].value;
			}
			
			//Copy the nodes
			for ( i = 0; i < nodes.numChildren; i++ )
			{
				o.addNode( new Node( o, nodes.getChildAt( i ).x, nodes.getChildAt( i ).y ) );
			}
				
			return o;
		}
		
		public function get angle():Number
		{
			return holder.rotation;
		}
		
		public function set angle( to:Number ):void
		{
			holder.rotation = to;
		}
		
		public function set selected( to:Boolean ):void
		{
			_selected = to;
			if (to)
			{
				nodes.alpha = 1;
				lines.alpha = 1;
				selBox.setColor( SelBox.OBJECT_SELECTED );
				drawBG();
			}
			else
			{
				nodes.alpha = 0.4;
				lines.alpha = 0.4;
				selBox.setColor( SelBox.OBJECT_NOTSELECTED );
				clearBG();
			}
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function get xml():XML
		{
			var xml:XML = <object/>;
			
			//basics
			xml.setName( definition.name );
			xml.@x 		= x;
			xml.@y		= y;
			
			//Size if resizable
			if (definition.resizableX)
				xml.@width	= objWidth;
			if (definition.resizableY)
				xml.@height	= objHeight;
				
			//Angle if rotatable
			if (definition.rotatable)
			{
				if (definition.exportRadians)
					xml.@angle = Utils.degToRad( angle );
				else
					xml.@angle = angle;
			}
				
			//values
			Reader.writeValues( xml, values );
			
			//nodes
			for ( var i:int = 0; i < nodes.numChildren; i++ )
			{
				var node:XML = (nodes.getChildAt( i ) as Node).xml;
				xml.appendChild( node );
			}
			
			return xml;
		}
		
		public function set xml( to:XML ):void
		{
			var o:ObjectDefinition = Ogmo.project.getObjectDefinitionByName( to.name().localName );
			if (o)
				init( o );
			else
				throw new Error( "Object not defined: \"" + to.name().localName + "\"" );
			
			x = (int)(to.@x);
			y = (int)(to.@y);
			
			//Set the size
			var w:int, h:int;	
			if (definition.resizableX)
				w = to.@width;
			else
				w = definition.width;
				
			if (definition.resizableY)
				h = to.@height;
			else
				h = definition.height;
				
			setSize( w, h );
			
			//Angle if rotatable
			if (definition.rotatable)
			{
				if (definition.exportRadians)
					angle = Utils.radToDeg( Number( to.@angle ) );
				else
					angle = Number( to.@angle );
			}
			
			//set the values
			Reader.readValues( to, values );
			
			//create the nodes
			for each ( var n:XML in to.node )
				addNode( new Node( this, n.@x, n.@y ) );
		}
		
		public function get rect():Rectangle
		{
			return new Rectangle( x - definition.originX, y - definition.originY, objWidth, objHeight );
		}
		
	}

}