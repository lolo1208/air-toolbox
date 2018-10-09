package toolbox.controls
{
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	
	/**
	 * 时间轴
	 * @author LOLO
	 */
	public class Timeline extends UIComponent
	{
		private var _frameArrow:Sprite;
		private var _frameText:TextField;
		
		private var _frameWidth:uint = 7;
		private var _contentFrameNum:uint;
		private var _currentFrame:uint;
		private var _maxFrame:int;
		
		
		
		public function Timeline()
		{
			_frameArrow = new Sprite();
			_frameArrow.x = _frameArrow.y = -1;
			this.addChild(_frameArrow);
			
			_frameText = new TextField();
			_frameText.selectable = _frameText.mouseEnabled = false;
			_frameText.x = -10;
			_frameText.y = -18;
			_frameText.width = 30;
			_frameText.height = 16;
			_frameText.filters = [new GlowFilter()];
			_frameText.defaultTextFormat = new TextFormat("Arial", 12, 0xFFFFFF, true, null, null, null, null, "center");
			_frameArrow.addChild(_frameText);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
		}
		
		
		private function mouseEventHandler(event:Event):void
		{
			switch(event.type)
			{
				case MouseEvent.MOUSE_DOWN:
					this.addEventListener(MouseEvent.MOUSE_MOVE, mouseEventHandler);
					stage.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
					break;
				
				case MouseEvent.MOUSE_UP:
					this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseEventHandler);
					stage.removeEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
					break;
			}
			
			var n:int = mouseX / (_frameWidth + 1) + 1;
			if(n < 0) n = 0;
			if(n <= _contentFrameNum && n <= _maxFrame) {
				currentFrame = n;
				this.dispatchEvent(new DataEvent(DataEvent.DATA, false, false, String(_currentFrame)));
			}
		}
		
		
		
		/**
		 * 当前帧
		 */
		public function set currentFrame(value:uint):void
		{
			_currentFrame = value;
			var n:int = value - 1;
			if(n < 0) value = 0;
			if(n > _contentFrameNum) n = _contentFrameNum;
			if(n > _maxFrame) n = _maxFrame;
			
			_frameArrow.x = n * (_frameWidth + 1) - 1;
			TweenMax.killTweensOf(_frameText);
			_frameText.text = String(_currentFrame);
			_frameText.alpha = 1;
			TweenMax.to(_frameText, 0.5, { delay:0.5, alpha:0 });
		}
		
		public function get currentFrame():uint { return _currentFrame; }
		
		
		
		
		public function draw():void
		{
			_frameArrow.x = -1;
			_frameArrow.graphics.clear();
			_frameArrow.graphics.beginFill(0xCC0000);
			_frameArrow.graphics.drawRect(0, 0, _frameWidth + 4, height + 2);
			_frameArrow.graphics.beginFill(0xFF9999);
			_frameArrow.graphics.drawRect(1, 1, _frameWidth + 2, height);
			_frameArrow.graphics.endFill();
			
			this.graphics.clear();
			this.graphics.beginFill(0x666666);
			this.graphics.drawRect(0, 0, width, height);
			this.graphics.endFill();
			
			this.graphics.lineStyle(0, 0, 0);
			_maxFrame = Math.ceil((width - 2) / (_frameWidth + 1));
			for(var i:int = 0; i < _maxFrame; i++) {
				var fw:int = (i == _maxFrame - 1) ? (width - 2 - (_frameWidth + 1) * i) : _frameWidth;
				this.graphics.beginFill((i < _contentFrameNum) ? 0xCCCCCC : 0xFFFFFF);
				this.graphics.drawRect(i * (_frameWidth + 1) + 1, 1, fw, height - 2);
			}
			this.graphics.endFill();
		}
		
		
		
		/**
		 * 根据宽度计算出来的最大帧数
		 */
		public function get maxFrame():uint { return _maxFrame; }
		
		
		
		/**
		 * 帧宽度
		 */
		public function set frameWidth(value:uint):void
		{
			if(value == _frameWidth) return;
			_frameWidth = value;
			draw();
		}
		public function get frameWidth():uint { return _frameWidth; }
		
		
		/**
		 * 有内容的帧的数量
		 */
		public function set contentFrameNum(value:uint):void
		{
			if(value == _contentFrameNum) return;
			_contentFrameNum = value;
			draw();
		}
		public function get contentFrameNum():uint { return _contentFrameNum; }
		
		
		
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