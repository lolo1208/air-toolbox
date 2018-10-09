package app.canvasGroup
{
	import app.common.AppCommon;
	import app.skinListGroup.SkinItemRenderer;
	
	import com.greensock.TweenMax;
	
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import lolo.core.Common;
	import lolo.display.Skin;
	
	import mx.controls.ColorPicker;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;
	
	import toolbox.Toolbox;
	import toolbox.controls.GridBackground;
	
	/**
	 * 画布容器
	 * @author LOLO
	 */
	public class CanvasGroup extends Group
	{
		public var colorCB:CheckBox;
		public var colorCP:ColorPicker;
		public var focusBtn:Button;
		
		public var stateLabel:Label;
		public var stateGroup:HGroup;
		public var stateNameText:Label;
		public var stateSNText:TextInput;
		
		private var _gridBG:GridBackground;
		private var _colorBG:UIComponent;
		
		private var _uic:UIComponent;
		private var _uicMask:UIComponent;
		private var _loader:Loader;
		
		private var _stateTimeLine:StateTimeline;
		
		private var _currentStates:Array;
		private var _currentSN:String;
		/**上次更新拖动位置的坐标*/
		private var _lastUpdateDragPosition:Point;
		
		
		
		
		public function CanvasGroup()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			colorCB.tabFocusEnabled = false;
			colorCP.tabFocusEnabled = false;
			focusBtn.tabFocusEnabled = false;
			stateSNText.tabFocusEnabled = false;
			
			_gridBG = new GridBackground();
			_gridBG.x = _gridBG.y = 10;
			this.addElementAt(_gridBG, 0);
			
			_colorBG = new UIComponent();
			this.addElementAt(_colorBG, 1);
			
			_uic = new UIComponent();
			_uic.x = _uic.y = 100;
			this.addElementAt(_uic, 2);
			
			_uicMask = new UIComponent();
			_uicMask.x = _uicMask.y = 11;
			_uic.mask = _uicMask;
			this.addElement(_uicMask);
			
			_loader = new Loader();
			_uic.addChild(_loader);
			
			var centerPoint:Shape = new Shape();
			centerPoint.graphics.lineStyle(3, 0xFFFFFF);
			centerPoint.graphics.moveTo(2, 4);
			centerPoint.graphics.lineTo(7, 4);
			centerPoint.graphics.moveTo(4, 2);
			centerPoint.graphics.lineTo(4, 7);
			centerPoint.graphics.lineStyle(1, 0x0);
			centerPoint.graphics.moveTo(4, 0);
			centerPoint.graphics.lineTo(4, 9);
			centerPoint.graphics.moveTo(0, 4);
			centerPoint.graphics.lineTo(9, 4);
			centerPoint.x = centerPoint.y = -4;
			_uic.addChild(centerPoint);
			
			_stateTimeLine = new StateTimeline();
			_stateTimeLine.x = 50;
			this.addElement(_stateTimeLine);
			
			
			_stateTimeLine.addEventListener(DataEvent.DATA, stateTimeLine_dataHandler);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_eventHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_eventHandler);
			
			_gridBG.addEventListener(MouseEvent.MOUSE_DOWN, bg_mouseEventHandler);
			_colorBG.addEventListener(MouseEvent.MOUSE_DOWN, bg_mouseEventHandler);
			_uic.addEventListener(MouseEvent.MOUSE_DOWN, bg_mouseEventHandler);
			
			_gridBG.addEventListener(MouseEvent.ROLL_OVER, bg_RollEventHandler);
			_colorBG.addEventListener(MouseEvent.ROLL_OVER, bg_RollEventHandler);
			_uic.addEventListener(MouseEvent.ROLL_OVER, bg_RollEventHandler);
			_gridBG.addEventListener(MouseEvent.ROLL_OUT, bg_RollEventHandler);
			_colorBG.addEventListener(MouseEvent.ROLL_OUT, bg_RollEventHandler);
			_uic.addEventListener(MouseEvent.ROLL_OUT, bg_RollEventHandler);
			
			
			stateTimeLine_dataHandler();
		}
		
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			if(_gridBG == null) return;
			
			_gridBG.width = width;
			_gridBG.height = height - 85;
			
			_stateTimeLine.width = width - 40;
			_stateTimeLine.y = height - 65;
			
			_uicMask.graphics.clear();
			_uicMask.graphics.beginFill(0x660000, 1);
			_uicMask.graphics.drawRect(0, 0, _gridBG.width - 1, _gridBG.height - 1);
			_uicMask.graphics.endFill();
			
			colorCB.x = width - 83;
			colorCP.x = width - 65;
			focusBtn.x = width - 25;
			colorBG_eventHandler();
			
			stateLabel.y = height - 55;
			stateGroup.y = height - 25;
			changeStateTimeLinePosition();
		}
		
		
		/**
		 * 鼠标拖动舞台
		 * @param event
		 */
		private function bg_mouseEventHandler(event:MouseEvent):void
		{
			switch(event.type)
			{
				case MouseEvent.MOUSE_DOWN:
					this.setFocus();
					Common.stage.addEventListener(MouseEvent.MOUSE_UP, bg_mouseEventHandler);
					Common.stage.addEventListener(MouseEvent.MOUSE_MOVE, bg_mouseEventHandler);
					_lastUpdateDragPosition = new Point(mouseX, mouseY);
					break;
				
				case MouseEvent.MOUSE_MOVE:
					break;
				
				case MouseEvent.MOUSE_UP:
					Common.stage.removeEventListener(MouseEvent.MOUSE_UP, bg_mouseEventHandler);
					Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, bg_mouseEventHandler);
					break;
			}
			
			_uic.x += mouseX - _lastUpdateDragPosition.x;
			_uic.y += mouseY - _lastUpdateDragPosition.y;
			_lastUpdateDragPosition = new Point(mouseX, mouseY);
		}
		
		
		private function bg_RollEventHandler(event:MouseEvent):void
		{
			Mouse.cursor = (event.type == MouseEvent.ROLL_OVER) ? MouseCursor.HAND : MouseCursor.ARROW;
		}
		
		
		
		
		
		
		/**
		 * 显示皮肤各状态
		 * @param states
		 */
		public function show(states:Array):void
		{
			_currentStates = states;
			_stateTimeLine.stateList = states;
			update();
		}
		
		
		/**
		 * 更新显示
		 */
		private function update():void
		{
			if(_currentStates == null) return;
			
			var state:String = _stateTimeLine.state;
			var sn:String = _currentStates[_stateTimeLine.currentStateIndex];
			stateSNText.text = sn;
			stateSNText.prompt = sn;
			
			if(sn == "") {
				if(state == Skin.SELECTED_OVER || state == Skin.SELECTED_DOWN || state == Skin.SELECTED_DISABLED) {
					sn = _currentStates[_stateTimeLine.getStateIndex(Skin.SELECTED_UP)];
					stateSNText.prompt = sn;
				}
			}
			if(sn == "") {
				sn = _currentStates[_stateTimeLine.getStateIndex(Skin.UP)];
				stateSNText.prompt = sn;
			}
			updatePromptTextColor();
			
			if(sn == _currentSN) return;
			_currentSN = sn;
			
			var url:String = sn.replace(/\./g, "/");
			url = Toolbox.resRootDir + "ui/" + url + ".png";
			_loader.load(new URLRequest(url));
			
			var p:Point = AppCommon.app.skinListGroup.getOffsetPoint(sn);
			if(p != null) {
				_loader.x = p.x;
				_loader.y = p.y;
			}
		}
		
		
		/**
		 * loader 相关事件
		 * @param event
		 */
		private function loader_eventHandler(event:Event):void
		{
			stateSNText.setStyle("color", (event.type == Event.COMPLETE) ? 0x0 : 0xCC0000);
			updatePromptTextColor();
		}
		
		
		private function updatePromptTextColor():void
		{
			if(stateSNText.promptDisplay == null) return;
			stateSNText.promptDisplay["setStyle"]("color", 0x666666);
		}
		
		
		
		/**
		 * 切换状态
		 * @param event
		 */
		private function stateTimeLine_dataHandler(event:DataEvent=null):void
		{
			stateNameText.text = _stateTimeLine.state + "：";
			stateNameText.toolTip = _stateTimeLine.currentStateTips;
			changeStateTimeLinePosition();
			update();
		}
		
		private function changeStateTimeLinePosition():void
		{
			if(width < 0) return;
			var w:uint = 350;
			if(w + stateNameText.width > width) w = width - stateNameText.width;
			stateSNText.width = w;
		}
		
		
		
		
		/**
		 * 修改状态的 sourceName
		 * @param event
		 */
		protected function stateSNText_changeHandler(event:TextOperationEvent):void
		{
			if(_currentStates == null) {
				stateSNText.text = "";
				return;
			}
			
			_currentStates[_stateTimeLine.currentStateIndex] = stateSNText.text;
			show(_currentStates);
			
			var skinList:List = AppCommon.app.skinListGroup.skinList;
			var item:SkinItemRenderer = skinList.dataGroup.getElementAt(skinList.selectedIndex) as SkinItemRenderer;
			if(item != null) item.checkSourceName();
		}
		
		
		
		
		
		/**
		 * 聚焦元件
		 * @param event
		 */
		protected function focusBtn_clickHandler(event:MouseEvent=null):void
		{
			this.setFocus();
			_uic.x = width - _loader.width >> 1;
			_uic.y = height - 80 - _loader.height >> 1;
		}
		
		
		
		/**
		 * 绘制纯色背景
		 * @param event
		 */
		protected function colorBG_eventHandler(event:Event=null):void
		{
			this.setFocus();
			colorCP.enabled = colorCB.selected;
			
			_colorBG.graphics.clear();
			if(colorCB.selected) {
				_colorBG.graphics.beginFill(colorCP.selectedColor);
				_colorBG.graphics.drawRect(_gridBG.x + 1, _gridBG.y + 1, _gridBG.width - 1, _gridBG.height - 1);
				_colorBG.graphics.endFill();
			}
		}
		
		
		
		/**
		 * 元件的半透效果
		 * @param event
		 */
		protected function alpha_mouseEventHandler(event:MouseEvent):void
		{
			var element:Object = event.currentTarget;
			TweenMax.killTweensOf(element);
			TweenMax.to(element, 0.3, { alpha:(event.type == MouseEvent.MOUSE_OVER ? 1 : 0.5) });
		}
		
		
		
		public function get stateTimeLine():StateTimeline { return _stateTimeLine; }
		
		
		
		
		
		public function reset():void
		{
			_currentSN = null;
			_currentStates = null;
			
			try { _loader.unload(); }
			catch(error:Error) {}
			
			var arr:Array = [];
			arr.length = 8;
			_stateTimeLine.stateList = arr;
			
			stateSNText.text = "";
			stateSNText.prompt = "";
		}
		//
	}
}