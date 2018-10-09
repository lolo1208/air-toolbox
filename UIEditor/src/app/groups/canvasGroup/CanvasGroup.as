package app.groups.canvasGroup
{
	import app.common.AppCommon;
	import app.common.Controller;
	import app.layers.Layer;
	import app.utils.LayerUtil;
	
	import flash.desktop.NativeDragManager;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import lolo.core.Common;
	import lolo.utils.DisplayUtil;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.NavigatorContent;
	import spark.components.TabBar;
	
	import toolbox.controls.GridBackground;
	
	
	/**
	 * 画布容器
	 * @author LOLO
	 */
	public class CanvasGroup extends NavigatorContent
	{
		public var containerTB:TabBar;
		public var addContainerBtn:Button;
		public var removeContainerBtn:Button;
		public var toolbar:ToolbarView;
		public var createContainerPanel:CreateContainerPanel;
		
		private var _gridBG:GridBackground;
		private var _colorBG:UIComponent;
		private var _uic:UIComponent;
		private var _uicMask:UIComponent;
		private var _bottomFrame:Shape;
		private var _containers:Sprite;
		private var _topFrame:Shape;
		
		
		/**共用功能控制器*/
		private var _controller:Controller;
		
		/**鼠标在图层上按下的时间，记录该时间是为了避免误拖*/
		private var _layerMouseDownTime:Number;
		/**上次更新拖动位置的坐标*/
		private var _lastUpdateDragPosition:Point;
		/**上次更新的位置（拖动图层）*/
		private var _lastDragLayerPosition:Point;
		/**拖动的起始点*/
		private var _pDragStart:Point;
		
		
		
		public function CanvasGroup()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			containerTB.dataProvider = new ArrayList();
			
			_gridBG = new GridBackground();
			_gridBG.y = 28;
			this.addElementAt(_gridBG, 0);
			
			_colorBG = new UIComponent();
			this.addElementAt(_colorBG, 1);
			
			_uic = new UIComponent();
			_uic.mouseEnabled = false;
			_uic.x = 80;
			_uic.y = 150;
			this.addElementAt(_uic, 2);
			
			_uicMask = new UIComponent();
			_uic.mask = _uicMask;
			this.addElement(_uicMask);
			
			_bottomFrame = new Shape();
			_uic.addChild(_bottomFrame);
			
			_containers = new Sprite();
			_uic.addChild(_containers);
			
			_topFrame = new Shape();
			_topFrame.alpha = 0.5;
			_uic.addChild(_topFrame);
			
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
		}
		
		
		protected function addedToStageHandler(event:Event):void
		{
			_controller = AppCommon.controller;
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragDropHandler);
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragDropHandler);
			
			_containers.addEventListener(MouseEvent.MOUSE_DOWN, containers_mouseDownHandler, true);
			
			resizeHandler();
		}
		
		
		protected function resizeHandler(event:ResizeEvent=null):void
		{
			if(_gridBG == null) return;
			
			_gridBG.width = width - 1;
			_gridBG.height = height - _gridBG.y - 1;
			toolbar.drawColorBG();
			
			_uicMask.width = _gridBG.width;
			_uicMask.height = _gridBG.height;
			_uicMask.graphics.clear();
			_uicMask.graphics.beginFill(0, 1);
			_uicMask.graphics.drawRect(_gridBG.x + 1, _gridBG.y + 1, _gridBG.width - 1, _gridBG.height - 1);
			_uicMask.graphics.endFill();
			
			removeContainerBtn.x = width - removeContainerBtn.width;
			addContainerBtn.x = removeContainerBtn.x - addContainerBtn.width - 5;
			containerTB.width = addContainerBtn.x - 5;
			
			toolbar.x = width - toolbar.width - 5;
		}
		
		
		/**
		 * 有UI、动画或组件拖入到画布中
		 * @param event
		 */
		private function nativeDragDropHandler(event:NativeDragEvent):void
		{
			if(mouseY < 29) return;
			var item:Object = event.clipboard.getData(event.clipboard.formats[0])[0];
			if(!AppCommon.controller.configOpened) return;//还没打开配置文件
			if(item is File) return;//是文件
			if(item.children != null) return;//不是一个显示对象
			if(item.isLayer) return;//是图层
			
			switch(event.type)
			{
				case NativeDragEvent.NATIVE_DRAG_ENTER:
					NativeDragManager.acceptDragDrop(event.target as InteractiveObject);
					break;
				
				case NativeDragEvent.NATIVE_DRAG_DROP:
					_controller.addLayer(item, { x:_uic.mouseX, y:_uic.mouseY });
					break;
			}
		}
		
		
		
		
		
		/**
		 * 鼠标在容器上按下
		 * @param event
		 */
		private function containers_mouseDownHandler(event:MouseEvent):void
		{
			this.setFocus();
			if(toolbar.toolsBB.selectedItem.value == "hand") return;
			
			//拿到鼠标下的所有显示对象
			var list:Array = stage.getObjectsUnderPoint(new Point(event.stageX, event.stageY));
			list.reverse();
			
			//取出图层列表
			var layers:Vector.<Layer> = new Vector.<Layer>();
			var i:int, disObj:DisplayObject, layer:Layer;
			for(i = 0; i < list.length; i++)
			{
				//从显示对象开始，往父级一直找，直到找到图层对象或舞台为止
				disObj = list[i] as DisplayObject;
				while(disObj != null)
				{
					layer = disObj as Layer;
					if(layer != null) {
						layers.push(layer);
						break;
					}
					disObj = disObj.parent;
				}
			}
			
			//找出不是点在透明区域的图层
			for(i = 0; i < layers.length; i++)
			{
				layer = layers[i];
				//因文字图层透明区域太多，所以不用检测是否全透明
				if(DisplayUtil.fullTransparent(layer, null)
					&& !LayerUtil.isBaseTextField(layer)
					&& !LayerUtil.isCheckBox(layer)
					&& !LayerUtil.isArtText(layer)
				) continue;
				
				_controller.selectLayer(layer);
				if(selectedLayer.canDrag(event))
				{
					_layerMouseDownTime = getTimer();
					_lastDragLayerPosition = new Point(mouseX, mouseY);
					_pDragStart = new Point(selectedLayer.x, selectedLayer.y);
					
					stage.addEventListener(MouseEvent.MOUSE_UP, dragSelectedLayer);
					_uic.addEventListener(MouseEvent.MOUSE_MOVE, dragSelectedLayer);
					_gridBG.addEventListener(MouseEvent.MOUSE_MOVE, dragSelectedLayer);
					_colorBG.addEventListener(MouseEvent.MOUSE_MOVE, dragSelectedLayer);
				}
				return;
			}
		}
		
		/**
		 * 拖动当前选中的图层
		 * @param event
		 */
		private function dragSelectedLayer(event:MouseEvent):void
		{
			//选中时误拖
			var x:int = mouseX - _lastDragLayerPosition.x;
			var y:int = mouseY - _lastDragLayerPosition.y;
			var isSelect:Boolean = getTimer() - _layerMouseDownTime < 300 && Math.abs(x) < 10 && Math.abs(y) < 10;
			
			if(event.type == MouseEvent.MOUSE_UP)
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, dragSelectedLayer);
				_uic.removeEventListener(MouseEvent.MOUSE_MOVE, dragSelectedLayer);
				_gridBG.removeEventListener(MouseEvent.MOUSE_MOVE, dragSelectedLayer);
				_colorBG.removeEventListener(MouseEvent.MOUSE_MOVE, dragSelectedLayer);
			}
			
			if(isSelect) return;
			
			x = int(x / _uic.scaleX);
			y = int(y / _uic.scaleY);
			if(x != 0) {
				selectedLayer.x += x;
				_lastDragLayerPosition.x = mouseX;
			}
			if(y != 0) {
				selectedLayer.y += y;
				_lastDragLayerPosition.y = mouseY;
			}
			AppCommon.prop.updateBounds();
		}
		
		
		
		
		
		
		/**
		 * 更新容器tabBar的itemRenderer样式
		 * @param event
		 */
		public function updateContainerTabBarStyle(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, updateContainerTabBarStyle);
			for(var i:int = 0; i < containerTB.dataGroup.numElements; i++)
			{
				var itemRenderer:UIComponent = containerTB.dataGroup.getElementAt(i) as UIComponent;
				itemRenderer.setStyle("fontSize", i == 0 ? 16 : 12);
				itemRenderer.setStyle("color",  i == 0 ? 0x0 : 0x333333);
			}
		}
		
		
		/**
		 * 所选容器有改变
		 * @param event
		 */
		protected function containerTB_changeHandler(event:Event):void
		{
			if(containerTB.selectedItem == null) return;
			
			_controller.showCurrentContainer();
			_controller.selectLayer(_controller.currentContainerLayer);
			if(event.type != MouseEvent.CLICK) toolbar.focusSelectedLayer();
		}
		
		
		/**
		 * 点击添加容器按钮
		 * @param event
		 */
		protected function addContainerBtn_clickHandler(event:MouseEvent):void
		{
			this.setFocus();
			if(AppCommon.controller.configOpened) {
				PopUpManager.addPopUp(createContainerPanel, this, true);
				stage.focus = createContainerPanel.idText;
			}
			else {
				Alert.show("请先打开想要编辑的xml配置文件", "提示");
			}
		}
		
		
		/**
		 * 点击移除当前容器按钮
		 * @param event
		 */
		protected function removeContainerBtn_clickHandler(event:MouseEvent):void
		{
			this.setFocus();
			if(!AppCommon.controller.configOpened) return;
			
			if(containerTB.selectedIndex == 0) {
				Alert.show("不能移除配置文件中的最底层容器！", "提示");
				return;
			}
			Alert.show("您确定要移除容器 " + AppCommon.controller.currentContainerLayer.id + " 吗？", "提示",
				Alert.YES | Alert.NO, this.parent as Sprite, removeContainer_alertCloseHandler);
		}
		
		private function removeContainer_alertCloseHandler(event:CloseEvent):void
		{
			if(event.detail != Alert.YES) return;
			
			AppCommon.controller.clearContainerLayer(containerTB.dataProvider.removeItemAt(containerTB.selectedIndex).container);
			Common.stage.addEventListener(Event.ENTER_FRAME, delayedShowCurrentContainerLayer);
		}
		
		private function delayedShowCurrentContainerLayer(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, delayedShowCurrentContainerLayer);
			AppCommon.controller.showCurrentContainer();
			AppCommon.controller.selectLayer(AppCommon.controller.currentContainerLayer);
		}
		
		
		
		
		
		
		/**
		 * 当前选中的图层
		 */
		private function get selectedLayer():Layer { return AppCommon.controller.selectedLayer; }
		
		
		public function get uic():UIComponent { return _uic; }
		public function get gridBG():GridBackground { return _gridBG; }
		public function get colorBG():UIComponent { return _colorBG; }
		public function get containers():Sprite { return _containers; }
		public function get topFrame():Shape { return _topFrame; }
		public function get bottomFrame():Shape { return _bottomFrame; }
		//
	}
}