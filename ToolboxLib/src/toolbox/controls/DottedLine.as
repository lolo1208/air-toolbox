package toolbox.controls
{
	import mx.core.UIComponent;
	
	/**
	 * 九切片辅助线
	 * @author LOLO
	 */
	public class DottedLine extends UIComponent
	{
		/**水平方向进行绘制*/
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		/**垂直方向进行绘制*/
		public static const DIRECTION_VERTICAL:String = "vertical";
		
		public var space:uint = 4;
		private var _direction:String;
		private var _size:uint;
		
		
		public function DottedLine(direction:String="horizontal", size:uint=100)
		{
			super();
			_direction = direction
			_size = size;
			draw();
		}
		
		
		
		public function draw():void
		{
			this.graphics.clear();
			this.graphics.beginFill(0, 0);
			isHorizontal ? graphics.drawRect(0, -3, _size, 7) : graphics.drawRect(-3, 0, 7, _size);
			this.graphics.endFill();
			
			this.graphics.lineStyle(1, 0x555555);
			this.graphics.moveTo(0, 0);
			var v:uint, b:Boolean;
			while(v < _size) {
				b = !b;
				v += space;
				if(v > _size) v = _size;
				if(isHorizontal) {
					b ? graphics.lineTo(v, 0) : graphics.moveTo(v, 0)
				}
				else {
					b ? graphics.lineTo(0, v) : graphics.moveTo(0, v)
				}
			}
		}
		
		
		public function set direction(value:String):void
		{
			_direction = value;
			draw();
		}
		public function get direction():String { return _direction; }
		
		
		public function get isHorizontal():Boolean
		{
			return _direction == DIRECTION_HORIZONTAL;
		}
		
		
		public function set size(value:uint):void
		{
			_size = value;
			draw();
		}
		public function get size():uint { return _size; }
		
		override public function set width(value:Number):void
		{
			if(_direction == DIRECTION_HORIZONTAL) {
				size = value;
			}
		}
		
		override public function set height(value:Number):void
		{
			if(_direction == DIRECTION_VERTICAL) {
				size = value;
			}
		}
		
		
		override public function set x(value:Number):void
		{
			if(id == "v2DL") super.x = value - 1;
			else super.x = value;
		}
		override public function get x():Number
		{
			if(id == "v2DL") return super.x + 1;
			return super.x;
		}
		
		
		override public function set y(value:Number):void
		{
			if(id == "h1DL") super.y = value + 1;
			else super.y = value;
		}
		override public function get y():Number
		{
			if(id == "h1DL") return super.y - 1;
			return super.y;
		}
		//
	}
}