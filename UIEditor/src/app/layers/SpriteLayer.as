package app.layers
{
	import app.common.LayerConstants;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * Sprite 层
	 * @author LOLO
	 */
	public class SpriteLayer extends Layer
	{
		/**子集列表（parent=this）*/
		protected var _children:Vector.<Layer> = new Vector.<Layer>();
		
		
		
		public function SpriteLayer()
		{
			super();
			this.type = LayerConstants.SPRITE;
		}
		
		override protected function createElement():void
		{
			this.element = new Sprite();
		}
		
		
		
		override public function set x(value:Number):void
		{
			var oValue:int = _element.x;
			_element.x = int(value);
			for(var i:int = 0; i < _children.length; i++)
				_children[i].x = _children[i].element.x - oValue;
		}
		override public function get x():Number { return _element.x; }
		
		override public function set y(value:Number):void
		{
			var oValue:int = _element.y;
			_element.y = int(value);
			for(var i:int = 0; i < _children.length; i++)
				_children[i].y = _children[i].element.y - oValue;
		}
		override public function get y():Number { return _element.y; }
		
		
		
		override public function get bounds():Rectangle
		{
			if(_children.length > 0) {
				var bounds:Rectangle = _children[0].bounds;
				for(var i:int = 1; i < _children.length; i++) {
					var b:Rectangle = _children[i].bounds;
					
					if(b.x < bounds.x) {
						bounds.width += bounds.x - b.x;
						bounds.x = b.x;
					}
					if(b.y < bounds.y) {
						bounds.height += bounds.y - b.y;
						bounds.y = b.y;
					}
					
					var w:int = b.x + b.width;
					var h:int = b.y + b.height;
					if(w > bounds.x + bounds.width) bounds.width = w - bounds.x;
					if(h > bounds.y + bounds.height) bounds.height = h - bounds.y;
				}
				return bounds;
			}
			return super.bounds;
		}
		
		
		/**
		 * 添加一个层到子集列表
		 * @param layer
		 */
		public function addChildLayer(layer:Layer):void
		{
			removeChildLayer(layer);
			_children.push(layer);
		}
		
		
		/**
		 * 从子集列表删除层
		 * @param layer
		 */
		public function removeChildLayer(layer:Layer):void
		{
			for(var i:int = 0; i < _children.length; i++) {
				if(_children[i] == layer) {
					_children.splice(i, 1);
					return;
				}
			}
		}
		//
	}
}