package toolbox.controls
{
	import mx.core.UIComponent;
	
	/**
	 * 格子样式的舞台背景
	 * @author LOLO
	 */
	public class GridBackground extends UIComponent
	{
		public static const GRID_WIDTH:int = 8;
		public static const GRID_HEIGHT:int = 8;
		
		private var _hollow:Boolean = false;
		
		
		public function GridBackground()
		{
			this.cacheAsBitmap = true;
		}
		
		
		public function draw():void
		{
			this.graphics.clear();
			this.graphics.beginFill(0, 0);
			this.graphics.lineStyle(1, 0x666666);
			this.graphics.drawRect(0, 0, width, height);
			this.graphics.lineStyle(0, 0, 0);
			this.graphics.endFill();
			
			if(_hollow) return;
			
			var h:int = Math.ceil((width - 2) / GRID_WIDTH);	
			var v:int = Math.ceil((height - 2) / GRID_HEIGHT);
			var x:int, y:int;
			var gx:int, gy:int, gw:int, gh:int;
			for(y = 0; y < v; y++) {
				for(x = 0; x < h; x++) {
					if(y % 2 == 0) {
						this.graphics.beginFill((x % 2 == 0) ? 0xFFFFFF : 0xDFDFDF);
					}
					else {
						this.graphics.beginFill((x % 2 == 1) ? 0xFFFFFF : 0xDFDFDF);
					}
					gx = x * GRID_WIDTH + 1;
					gy = y * GRID_HEIGHT + 1;
					gw = (x == h-1) ? (width - GRID_WIDTH * x - 2) : GRID_WIDTH;
					gh = (y == v-1) ? (height - GRID_HEIGHT * y - 2) : GRID_HEIGHT;
					this.graphics.drawRect(gx, gy, gw, gh);
				}
			}
			this.graphics.endFill();
		}
		
		
		/**
		 * 是否为镂空状态
		 */
		public function set hollow(value:Boolean):void
		{
			if(value == _hollow) return;
			_hollow = value;
			draw();
		}
		
		public function get hollow():Boolean { return _hollow; }
		
		
		
		override public function set width(value:Number):void
		{
			if(value == super.width) return;
			super.width = value;
			draw();
		}
		
		override public function set height(value:Number):void
		{
			if(value == super.height) return;
			super.height = value;
			draw();
		}
		//
	}
}