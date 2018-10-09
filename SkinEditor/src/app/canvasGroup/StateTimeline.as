package app.canvasGroup
{
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import lolo.display.Skin;
	
	import mx.core.UIComponent;
	
	/**
	 * 皮肤状态时间轴
	 * @author LOLO
	 */
	public class StateTimeline extends UIComponent
	{
		private var _arrow:Sprite;
		
		/**当前状态*/
		private var _state:String;
		/**设置的宽度*/
		private var _width:uint = 200;
		/**设置的高度*/
		private var _height:uint = 30;
		/**根据设置的宽度，计算出来的帧宽度*/
		private var _frameWidth:uint;
		
		/**设置的帧状态信息列表*/
		private var _stateList:Array;
		
		/**状态文本列表*/
		private var _stateTextList:Array;
		
		
		
		public function StateTimeline()
		{
			super();
			_stateList = [];
			_stateList.length = 8;
			_stateTextList = [];
			_state = Skin.UP;
			
			_arrow = new Sprite();
			_arrow.x = _arrow.y = -1;
			this.addChild(_arrow);
			
			for(var i:int = 0; i < _stateList.length; i++)
			{
				var text:TextField = new TextField();
				text.selectable = text.mouseEnabled = false;
				text.defaultTextFormat = new TextFormat("宋体", 12, 0x666666, null, null, null, null, null, "center");
				text.height = 16;
				text.text = getStateName(i);
				this.addChild(text);
				_stateTextList[i] = text;
			}
			
			draw();
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
		}
		
		private function mouseEventHandler(event:MouseEvent):void
		{
			stage.focus = this;
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
			
			var n:int = mouseX / (_frameWidth + 1);
			if(n < 0) n = 0;
			if(n >= _stateList.length) n = _stateList.length - 1;
			state = getStateName(n);
			this.dispatchEvent(new DataEvent(DataEvent.DATA, false, false, _state));
		}
		
		
		
		/**
		 * 当前状态
		 */
		public function set state(state:String):void
		{
			_state = state;
			_arrow.x = getStateIndex(state) * (_frameWidth + 1) - 1;
		}
		
		public function get state():String { return _state; }
		
		
		
		/**
		 * 当前状态的索引
		 */
		public function set currentStateIndex(index:uint):void
		{
			state = getStateName(index);
			this.dispatchEvent(new DataEvent(DataEvent.DATA, false, false, _state));
		}
		
		public function get currentStateIndex():uint { return getStateIndex(_state); }
		
		
		
		
		private function draw():void
		{
			_frameWidth = (_width - 9) / _stateList.length;
			
			_arrow.graphics.clear();
			_arrow.graphics.beginFill(0xCC0000);
			_arrow.graphics.drawRect(0, 0, _frameWidth + 4, height + 2);
			_arrow.graphics.beginFill(0xFF9999);
			_arrow.graphics.drawRect(1, 1, _frameWidth + 2, height);
			_arrow.graphics.endFill();
			
			this.graphics.clear();
			this.graphics.beginFill(0x666666);
			this.graphics.drawRect(0, 0, _frameWidth * _stateList.length + 9, _height);
			
			for(var i:int = 0; i < _stateList.length; i++)
			{
				var x:uint = i * (_frameWidth + 1) + 1;
				var sn:String = _stateList[i];
				this.graphics.beginFill((sn != "" && sn != null) ? 0xCCCCCC : 0xFFFFFF);
				this.graphics.drawRect(x, 1, _frameWidth, height - 2);
				
				var text:TextField = _stateTextList[i];
				text.width = _frameWidth;
				text.x = x;
				text.y = _height - text.height >> 1;
			}
			this.graphics.endFill();
			
			state = _state;
		}
		
		
		
		/**
		 * 设置状态对应的 sourceName
		 * @param state
		 * @param sourceName
		 */
		public function set stateList(value:Array):void
		{
			_stateList = value;
			draw();
		}
		
		public function get stateList():Array { return _stateList; }
		
		
		
		override public function set width(value:Number):void
		{
			_width = value;
			draw();
		}
		override public function get width():Number { return _width; }
		
		
		override public function set height(value:Number):void
		{
			_height = value;
			draw();
		}
		override public function get height():Number { return _height; }
		
		
		
		
		public function getStateIndex(state:String):uint
		{
			switch(state)
			{
				case Skin.UP: return 0;
				case Skin.OVER: return 1;
				case Skin.DOWN: return 2;
				case Skin.DISABLED: return 3;
				case Skin.SELECTED_UP: return 4;
				case Skin.SELECTED_OVER: return 5;
				case Skin.SELECTED_DOWN: return 6;
				case Skin.SELECTED_DISABLED: return 7;
			}
			return 0;
		}
		
		
		public function getStateName(index:uint):String
		{
			switch(index)
			{
				case 0: return Skin.UP;
				case 1: return Skin.OVER;
				case 2: return Skin.DOWN;
				case 3: return Skin.DISABLED;
				case 4: return Skin.SELECTED_UP;
				case 5: return Skin.SELECTED_OVER;
				case 6: return Skin.SELECTED_DOWN;
				case 7: return Skin.SELECTED_DISABLED;
			}
			return null;
		}
		
		
		public function getStateTips(state:String):String
		{
			switch(state)
			{
				case Skin.UP: return "状态 - 正常";
				case Skin.OVER: return "状态 - 鼠标移上来";
				case Skin.DOWN: return "状态 - 鼠标按下";
				case Skin.DISABLED: return "状态 - 禁用";
				case Skin.SELECTED_UP: return "状态 - 选中：正常";
				case Skin.SELECTED_OVER: return "状态 - 选中：鼠标移上来";
				case Skin.SELECTED_DOWN: return "状态 - 选中：鼠标按下";
				case Skin.SELECTED_DISABLED: return "状态 - 选中：禁用";
			}
			return "";
		}
		
		public function get currentStateTips():String { return getStateTips(_state); }
		//
	}
}