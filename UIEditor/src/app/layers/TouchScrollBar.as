package app.layers
{
	import flash.display.Sprite;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.display.BitmapSprite;

	
	/**
	 * H5项目中，touch内容进行滚动的滚动条
	 * @author LOLO
	 */
	public class TouchScrollBar extends Sprite
	{
		private var _thumb:BitmapSprite;
		private var _direction:String;
		private var _size:uint = 100;
		private var _thumbMinSize:uint = 15;
		
		public var scrollPolicy:String = "auto";
		public var bounces:Boolean = true;
		public var enabled:Boolean = true;
		
		
		
		public function TouchScrollBar()
		{
			_thumb = new BitmapSprite();
			this.addChild(_thumb);
			
			_direction = Constants.VERTICAL;
		}
		
		
		public function set style(value:Object):void
		{
			if(value.thumbSourceName != null) _thumb.sourceName = value.thumbSourceName;
			if(value.thumbMinSize != null) _thumbMinSize = value.thumbMinSize;
			if(value.direction != null) _direction = value.direction;
			if(value.scrollPolicy != null) scrollPolicy = value.scrollPolicy;
			if(value.bounces != null) bounces = value.bounces;
			update();
		}
		
		
		public function set styleName(value:String):void
		{
			style = Common.config.getStyle(value);
		}
		
		
		public function set viewableArea(value:Object):void {}
		public function get viewableArea():Object { return null; }
		
		
		public function set size(value:uint):void
		{
			_size = value;
			update();
		}
		public function get size():uint { return _size; }
		
		
		public function set thumbMinSize(value:uint):void
		{
			_thumbMinSize = value;
			update();
		}
		public function get thumbMinSize():uint { return _thumbMinSize; }
		
		
		
		public function set direction(value:String):void
		{
			_direction = value;
			update();
		}
		public function get direction():String { return _direction; }
		
		
		
		public function update():void
		{
			var isVertical:Boolean = _direction == Constants.VERTICAL;
			var info:Object = BitmapSprite.getConfigInfo(_thumb.sourceName);
			
			this.graphics.clear();
			this.graphics.beginFill(0x0, 0.3);
			if(isVertical) {
				_thumb.width = info.width;
				this.graphics.drawRect(0, 0, _thumb.width, _size);
				_thumb.height = Math.max(_thumbMinSize, (_size - _thumbMinSize) * 0.4);
				_thumb.x = 0;
				_thumb.y = Math.round((size - _thumb.height) * 0.3);
			}
			else {
				_thumb.height = info.height;
				this.graphics.drawRect(0, 0, _size, _thumb.height);
				_thumb.width = Math.max(_thumbMinSize, (_size - _thumbMinSize) * 0.4);
				_thumb.x = Math.round((_size - _thumb.width) * 0.3);
				_thumb.y = 0;
			}
			this.graphics.endFill();
		}
		
		
		//
	}
}
