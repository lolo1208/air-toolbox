package app.groups.canvasGroup
{
	import app.common.AppCommon;
	import app.layers.Layer;
	import app.layers.ModalBackgroundLayer;
	import app.utils.LayerUtil;
	
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import lolo.core.Common;
	
	import mx.controls.ColorPicker;
	import mx.core.UIComponent;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.CheckBox;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.events.IndexChangeEvent;
	
	import toolbox.controls.GridBackground;
	
	/**
	 * 工具栏
	 * @author LOLO
	 */
	public class Toolbar extends Group
	{
		public var toolsBB:ButtonBar;
		public var focusBtn:Button;
		public var refreshBtn:Button;
		public var zoomDDL:DropDownList;
		public var colorCB:CheckBox;
		public var colorCP:ColorPicker;
		
		private var _gridBG:GridBackground;
		private var _colorBG:UIComponent;
		private var _uic:UIComponent;
		
		/**是否是因为按下空格才切换到手型工具（在释放空格键后，是否需要恢复到箭头工具）*/
		private var _isSpaceHand:Boolean;
		/**按空格前的操作类型*/
		private var _lastIndex:int;
		
		
		
		public function Toolbar()
		{
			super();
		}
		
		
		protected function addedToStageHandler(event:Event):void
		{
			Common.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			Common.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			
			_gridBG = AppCommon.canvas.gridBG;
			_colorBG = AppCommon.canvas.colorBG;
			_uic = AppCommon.canvas.uic;
			
			var arr:Array = [_uic, _gridBG, _colorBG];
			for(var i:int = 0; i < arr.length; i++)
			{
				arr[i].addEventListener(MouseEvent.MOUSE_DOWN, container_mouseDownHandler);
				arr[i].addEventListener(MouseEvent.MOUSE_OVER, container_mouseOverHandler);
				arr[i].addEventListener(MouseEvent.MOUSE_OUT, container_mouseOutHandler);
			}
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			
			_uic.addEventListener(MouseEvent.MOUSE_DOWN, gridBG_mouseDownHandler);
			_gridBG.addEventListener(MouseEvent.MOUSE_DOWN, gridBG_mouseDownHandler);
			_colorBG.addEventListener(MouseEvent.MOUSE_DOWN, gridBG_mouseDownHandler);
		}
		
		
		/**
		 * 按下键盘
		 * @param event
		 */
		public function stage_keyDownHandler(event:KeyboardEvent):void
		{
			if(AppCommon.keyboardUsing) return;
			
			if(event.keyCode == Keyboard.SPACE)
			{
				if(toolsBB.selectedIndex != 1) {
					_isSpaceHand = true;
					_lastIndex = toolsBB.selectedIndex;
					toolsBB.selectedIndex = 1;
					Mouse.cursor = MouseCursor.HAND;
					this.setFocus();
				}
			}
		}
		
		public function stage_keyUpHandler(event:KeyboardEvent):void
		{
			if(AppCommon.keyboardUsing) return;
			
			switch(event.keyCode) {
				case Keyboard.SPACE:
					if(_isSpaceHand)
					{
						_isSpaceHand = false;
						toolsBB.selectedIndex = _lastIndex;
						Mouse.cursor = MouseCursor.ARROW;
					}
					break;
				
				case Keyboard.Z:
					toolsBB.selectedIndex = 0;
					Mouse.cursor = MouseCursor.ARROW;
					break;
				
				case Keyboard.X:
					toolsBB.selectedIndex = 1;
					Mouse.cursor = MouseCursor.HAND;
					break;
				
				case Keyboard.C:
					focusSelectedLayer();
					break;
			}
			
			if(event.ctrlKey)
			{
				var zoomIndex:int = -1;
				switch(event.keyCode) {
					case Keyboard.NUMBER_1: zoomIndex = 1; break;
					case Keyboard.NUMBER_2: zoomIndex = 2; break;
					case Keyboard.NUMBER_3: zoomIndex = 3; break;
					case Keyboard.NUMBER_4: zoomIndex = 4; break;
					case Keyboard.NUMBER_5: zoomIndex = 0; break;
				}
				if(zoomIndex != -1) {
					zoomDDL.selectedIndex = zoomIndex;
					changeZoom();
				}
			}
			
			toolsBB_changeHandler();
		}
		
		
		
		
		/**
		 * 点击背景容器
		 * @param event
		 */
		private function container_mouseDownHandler(event:MouseEvent):void
		{
			this.setFocus();
			if(toolsBB.selectedItem.value == "hand") _uic.startDrag();//手型，拖动
		}
		
		private function stage_mouseUpHandler(event:MouseEvent):void
		{
			_uic.stopDrag();
		}
		
		private function container_mouseOverHandler(event:MouseEvent):void
		{
			Mouse.cursor = (toolsBB.selectedItem.value == "hand") ? MouseCursor.HAND : MouseCursor.ARROW;
		}
		
		private function container_mouseOutHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.ARROW;
		}
		
		
		private function gridBG_mouseDownHandler(event:MouseEvent):void
		{
			this.setFocus();
		}
		
		
		
		
		/**
		 * 操作类型有改变
		 * @param event
		 */
		protected function toolsBB_changeHandler(event:IndexChangeEvent=null):void
		{
			
		}
		
		
		/**
		 * 点击聚焦按钮
		 * @param event
		 */
		protected function focusBtn_clickHandler(event:MouseEvent):void
		{
			focusSelectedLayer();
		}
		
		
		/**
		 * 点击刷新按钮
		 * @param event
		 */
		protected function refreshBtn_clickHandler(event:MouseEvent):void
		{
			AppCommon.controller.update();
		}
		
		/**
		 * 是否绘制纯色背景
		 * @param event
		 */
		protected function colorBG_eventHandler(event:Event):void
		{
			this.setFocus();
			colorCP.enabled = colorCB.selected;
			drawColorBG();
		}
		
		
		
		
		
		/**
		 * 修改舞台缩放
		 * @param event
		 */
		protected function zoomDDL_changeHandler(event:IndexChangeEvent):void
		{
			changeZoom();
		}
		
		
		/**
		 * 绘制纯色背景
		 */
		public function drawColorBG():void
		{
			var colorBG:UIComponent = AppCommon.canvas.colorBG;
			var gridBG:GridBackground = AppCommon.canvas.gridBG;
			colorBG.graphics.clear();
			if(colorCB.selected) {
				colorBG.graphics.beginFill(colorCP.selectedColor);
				colorBG.graphics.drawRect(gridBG.x + 1, gridBG.y + 1, gridBG.width - 1, gridBG.height - 1);
				colorBG.graphics.endFill();
			}
		}
		
		
		/**
		 * 修改舞台缩放
		 * @param value
		 */
		private function changeZoom(value:Number=0):void
		{
			if(value == 0) value = zoomDDL.selectedItem.value;
			AppCommon.canvas.uic.scaleX =  AppCommon.canvas.uic.scaleY = value;
		}
		
		
		/**
		 * 聚焦到当前所选图层
		 */
		public function focusSelectedLayer():void
		{
			_uic.x = _gridBG.x;
			_uic.y = _gridBG.y;
			
			if(selectedLayer != null) {
				//移除模态背景后，再计算容器大小
				var mbgLayer:ModalBackgroundLayer;
				var c:Sprite;
				if(LayerUtil.isContainer()) {
					c = selectedLayer.element as Sprite;
					if(c.numChildren > 0) mbgLayer = c.getChildAt(0) as ModalBackgroundLayer;
					if(mbgLayer) c.removeChild(mbgLayer);
				}
				
				var rect:Rectangle = selectedLayer.getBounds(selectedLayer.parent);
				if(selectedLayer.width == 0 || selectedLayer.height == 0) rect.x = rect.y = 0;
				if(mbgLayer) c.addChildAt(mbgLayer, 0);
				
				_uic.x -= rect.x;
				_uic.y -= rect.y;
				_uic.x += _gridBG.width - rect.width >> 1;
				_uic.y += _gridBG.height - rect.height >> 1;
			}
			else {
				_uic.x += _gridBG.width >> 1;
				_uic.y += _gridBG.height >> 1;
			}
			_uic.x = int(_uic.x);
			_uic.y = int(_uic.y);
		}
		
		
		
		
		
		/**
		 * 当前选中的图层
		 */
		private function get selectedLayer():Layer { return AppCommon.controller.selectedLayer; }
		
		
		
		
		/**
		 * 渐隐渐现
		 * @param event
		 */
		protected function mouseEventHandler(event:MouseEvent):void
		{
			TweenMax.killTweensOf(this);
			TweenMax.to(this, 0.3, { alpha:(event.type == MouseEvent.MOUSE_OVER ? 1 : 0.5) });
		}
		//
	}
}