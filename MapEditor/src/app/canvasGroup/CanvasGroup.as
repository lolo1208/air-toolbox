package app.canvasGroup
{
	import app.common.AppCommon;
	import app.main.ExportTile;
	
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import lolo.core.Common;
	import lolo.rpg.RpgUtil;
	import lolo.rpg.map.MapInfo;
	import lolo.utils.Validator;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.List;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;
	
	import toolbox.controls.GridBackground;
	
	/**
	 * 画布容器
	 * @author LOLO
	 */
	public class CanvasGroup extends Group
	{
		public var tileGroup:Group;
		public var twText:TextInput;
		public var thText:TextInput;
		public var staggeredCB:CheckBox;
		public var createTileBtn:Button;
		
		public var cbGroup:Group;
		public var tileCB:CheckBox;
		public var pointCB:CheckBox;
		public var indexCB:CheckBox;
		
		public var featureGroup:Group;
		public var featureText:TextInput;
		public var impassabilityCB:CheckBox;
		public var coverCB:CheckBox;
		
		public var arrowBB:ButtonBar;
		
		private var _gridBG:GridBackground;
		
		private var _uic:UIComponent;
		private var _container:Sprite;
		private var _containerMask:Shape;
		
		private var _tileC:Sprite;
		
		private var _drawTarget:Sprite;
		private var _coverC:Sprite;
		private var _bgC:Sprite;
		
		
		/**当前正在拖动的元件*/
		private var _currentElement:Sprite;
		/**是否因为按紧空格而显示了手型*/
		private var _isSpaceHand:Boolean;
		/**按空格前的操作类型*/
		private var _lastIndex1:int;
		/**复位容器位置前的操作类型*/
		private var _lastIndex2:int;
		
		/**当前区块的宽高*/
		private var _tileWidth:uint;
		private var _tileHeight:uint;
		
		
		
		
		
		public function CanvasGroup()
		{
			super();
		}
		
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			_gridBG = new GridBackground();
			_gridBG.y = 35;
			this.addElement(_gridBG);
			
			_uic = new UIComponent();
			_uic.y = _gridBG.y;
			this.addElement(_uic);
			
			_container = new Sprite();
			_uic.addChild(_container);
			_drawTarget = new Sprite();
			_container.addChild(_drawTarget);
			
			_bgC = new Sprite();
			_drawTarget.addChild(_bgC);
			_coverC = new Sprite();
			_drawTarget.addChild(_coverC);
			
			_tileC = new Sprite();
			_container.addChild(_tileC);
			
			_containerMask = new Shape();
			_uic.addChild(_containerMask);
			_container.mask = _containerMask;
			
			this.addElement(arrowBB);
		}
		
		
		protected function addedToStageHandler(event:Event):void
		{
			_container.addEventListener(MouseEvent.MOUSE_DOWN, container_mouseDownHandler);
			_container.addEventListener(MouseEvent.MOUSE_OVER, container_mouseOverHandler);
			_container.addEventListener(MouseEvent.MOUSE_OUT, container_mouseOutHandler);
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			
			_tileC.addEventListener(MouseEvent.MOUSE_DOWN, tileC_mouseHandler);
			_tileC.addEventListener(MouseEvent.MOUSE_MOVE, tileC_mouseHandler);
			
			_gridBG.addEventListener(MouseEvent.MOUSE_DOWN, gridBG_mouseDownHandler);
			
			Common.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			Common.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
		}
		
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			if(_gridBG == null) return;
			
			_gridBG.width = width;
			_gridBG.height = height - 35;
			
			_containerMask.graphics.clear();
			_containerMask.graphics.beginFill(0);
			_containerMask.graphics.drawRect(1, 1, _gridBG.width - 1, _gridBG.height - 1);
			_containerMask.graphics.endFill();
			
			arrowBB.x = width - 134;
		}
		
		
		/**
		 * 按下键盘
		 * @param event
		 */
		private function stage_keyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.SPACE) {
				if(arrowBB.selectedItem.value != "hand") {
					_isSpaceHand = true;
					_lastIndex1 = arrowBB.selectedIndex;
					arrowBB.selectedIndex = 1;
					Mouse.cursor = MouseCursor.HAND;
				}
			}
		}
		
		private function stage_keyUpHandler(event:KeyboardEvent):void
		{
			if(event.target.parent != null) {
				if(event.target.parent.parent == featureText) return;
				if(event.target.parent.parent == AppCommon.app.propertiesPanel.featureText) return;
			}
			
			switch(event.keyCode)
			{
				case Keyboard.SPACE:
					if(_isSpaceHand) {
						_isSpaceHand = false;
						Mouse.cursor = MouseCursor.ARROW;
						arrowBB.selectedIndex = _lastIndex1;
					}
					break;
				
				
				case Keyboard.Q:
					tileCB.selected = !tileCB.selected;
					tileCB_changeHandler();
					break;
				
				case Keyboard.W:
					pointCB.selected = !pointCB.selected;
					pointCB_changeHandler();
					break;
				
				case Keyboard.E:
					indexCB.selected = !indexCB.selected;
					indexCB_changeHandler();
					break;
				
				
				case Keyboard.A:
					impassabilityCB.selected = !impassabilityCB.selected;
					coverCB.selected = false;
					break;
				
				case Keyboard.S:
					coverCB.selected = !coverCB.selected;
					impassabilityCB.selected = false;
					break;
				
				
				case Keyboard.Z:
					arrowBB.selectedIndex = 0;
					break;
				case Keyboard.X:
					arrowBB.selectedIndex = 1;
					break;
				
				case Keyboard.C:
					arrowBB.selectedIndex = 2;
					break;
				
				case Keyboard.V:
					arrowBB.selectedIndex = 3;
					break;
				
				case Keyboard.B:
					recoverContainerPosition();
					break;
			}
			
			arrowBB_changeHandler();
		}
		
		
		
		
		
		
		/**
		 * 点击背景容器
		 * @param event
		 */
		private function container_mouseDownHandler(event:MouseEvent):void
		{
			this.stage.focus = null;
			
			//手型，拖动
			if(arrowBB.selectedItem.value == "hand") {
				_container.startDrag();
				_tileC.visible = false;
			}
		}
		
		private function stage_mouseUpHandler(event:MouseEvent):void
		{
			_container.stopDrag();
			_tileC.visible = tileCB.selected;
		}
		
		private function container_mouseOverHandler(event:MouseEvent):void
		{
			Mouse.cursor = (arrowBB.selectedItem.value == "hand") ? MouseCursor.HAND : MouseCursor.ARROW;
		}
		
		private function container_mouseOutHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.ARROW;
		}
		
		
		
		private function gridBG_mouseDownHandler(event:MouseEvent):void
		{
			this.stage.focus = null;
		}
		
		
		
		
		
		/**
		 * 鼠标点击区块
		 * @param event
		 */
		private function tileC_mouseHandler(event:MouseEvent):void
		{
			if(!event.buttonDown) return;
			
			var info:MapInfo = new MapInfo({ tileWidth:_tileWidth, tileHeight:_tileHeight, mapWidth:_bgC.width, mapHeight:_bgC.height, staggered:staggeredCB.selected });
			var p:Point = new Point(_tileC.mouseX, _tileC.mouseY);
			p = RpgUtil.getTile(p, info);
			
			var tile:Tile = getTile(p.x, p.y);
			if(tile == null) return;
			
			//箭头工具
			if(arrowBB.selectedItem.value == "arrow") {
				tile.feature = feature;
				tile.canPass = !impassabilityCB.selected;
				tile.cover = coverCB.selected;
			}
			
			//选择区块
			if(arrowBB.selectedItem.value == "tile" && event.type == MouseEvent.MOUSE_DOWN) {
				AppCommon.app.propertiesPanel.show(tile);
			}
		}
		
		
		
		
		
		/**
		 * 添加一个元件到层中
		 * @param element
		 * @param type [1:遮挡物, 2:背景]
		 */
		public function addLayer(element:Sprite, type:int):void
		{
			element.addEventListener(MouseEvent.MOUSE_DOWN, element_mouseEventHandler);
			getContainer(type).addChild(element);
		}
		
		/**
		 * 移除一个元件
		 * @param element
		 * @param type
		 */
		public function removeLayer(element:Sprite, type:int):void
		{
			getContainer(type).removeChild(element);
		}
		
		
		/**
		 * 根据类型获取容器
		 * @param type [1:遮挡物, 2:背景]
		 * @return 
		 */
		private function getContainer(type:int):Sprite
		{
			if(type == 1) return _coverC;
			if(type == 2) return _bgC;
			return null;
		}
		
		
		
		
		
		
		/**
		 * 图层元件（遮挡物、背景）的鼠标事件处理
		 * @param event
		 */
		private function element_mouseEventHandler(event:MouseEvent):void
		{
			switch(event.type)
			{
				case MouseEvent.MOUSE_DOWN:
					if(arrowBB.selectedItem.value != "layer") return;//图层位置调整模式
					_currentElement = event.currentTarget as Sprite;
					
					//复制一个element，并拖拽
					if(event.ctrlKey)
					{
						var element:Sprite = new Sprite();
						element.x = _currentElement.x + 10;
						element.y = _currentElement.y + 10;
						
						var bmp:Bitmap = _currentElement.getChildAt(0) as Bitmap;
						if(bmp == null) bmp = (_currentElement.getChildAt(0) as Loader).content as Bitmap;
						
						var bitmap:Bitmap = new Bitmap();
						bitmap.bitmapData = bmp.bitmapData;
						element.addChild(bitmap);
						
						var list:List, type:int;
						var name:String = _currentElement.name.split("_")[0];
						if(name == "cover") {
							AppCommon.coverIndex++;
							element.name = "cover_" + AppCommon.coverIndex;
							list = AppCommon.app.layerPanel.coverList;
							type = 1;
						}
						else {
							AppCommon.bgIndex++;
							element.name = "bg_" + AppCommon.bgIndex;
							list = AppCommon.app.layerPanel.bgList;
							type = 2;
						}
						addLayer(element, type);
						list.dataProvider.addItemAt({ name:element.name, layer:element }, 0);
						
						_currentElement = element;
					}
					
					_currentElement.startDrag();
					stage.addEventListener(MouseEvent.MOUSE_UP, element_mouseEventHandler);
					stage.addEventListener(MouseEvent.MOUSE_MOVE, element_mouseEventHandler);
					AppCommon.app.propertiesPanel.show(_currentElement);
				break;
				
				case MouseEvent.MOUSE_UP:
					stage.removeEventListener(MouseEvent.MOUSE_UP, element_mouseEventHandler);
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, element_mouseEventHandler);
					_currentElement.stopDrag();
					AppCommon.app.propertiesPanel.refrsh(_currentElement);
				break;
				
				case MouseEvent.MOUSE_MOVE:
					AppCommon.app.propertiesPanel.refrsh(_currentElement);
				break;
			}
		}
		
		
		
		
		/**
		 * 显示或隐藏区块
		 * @param event
		 */
		protected function tileCB_changeHandler(event:Event=null):void
		{
			_tileC.visible = tileCB.selected;
			pointCB.enabled = indexCB.enabled = tileCB.selected;
		}
		
		
		/**
		 * 显示或隐藏坐标
		 * @param event
		 */
		protected function pointCB_changeHandler(event:Event=null):void
		{
			indexCB.selected = false;
			var type:int = showType;
			for(var i:int=0; i < _tileC.numChildren; i++) {
				(_tileC.getChildAt(i) as Tile).showType = type;
			}
		}
		
		
		/**
		 * 显示或隐藏特性索引
		 */
		protected function indexCB_changeHandler(event:Event=null):void
		{
			pointCB.selected = false;
			var type:int = showType;
			for(var i:int=0; i < _tileC.numChildren; i++) {
				(_tileC.getChildAt(i) as Tile).showType = type;
			}
		}
		
		
		
		
		/**
		 * 点击生成区块按钮
		 * @param event
		 */
		protected function createTileBtn_clickHandler(event:MouseEvent):void
		{
			if(_tileC.numChildren > 0) {
				Alert.show("您确定要删除现有区块，重新创建区块吗？", "警告",
					Alert.YES|Alert.NO, null, createTileAlert_closeHandler
				);
			}
			else {
				createTileAlert_closeHandler();
			}
		}
		
		private function createTileAlert_closeHandler(event:CloseEvent=null):void
		{
			if(event != null && event.detail == Alert.NO) return;
			
			while(_tileC.numChildren > 0) _tileC.removeChildAt(0);
			
			_tileWidth = int(twText.text);
			_tileHeight = int(thText.text);
			var v:int = vTileCount;
			var h:int = hTileCount;
			var showType:int = this.showType;
			for(var y:int = 0; y < v; y++) {
				for(var x:int = 0; x < h; x++) {
					var tile:Tile = new Tile(x, y, _tileWidth, _tileHeight, staggeredCB.selected, _bgC.width, _bgC.height);
					tile.showType = showType;
					tile.name = "t" + x + "_" + y;
					_tileC.addChild(tile);
				}
			}
		}
		
		
		
		
		
		/**
		 * 输入的特性
		 */
		private function get feature():String
		{
			var value:String = featureText.text;
			if(value == "特性" || value == "") return null;
			if(!Validator.notExactlySpace(value)) return null;
			return value;
		}
		
		protected function featureText_changeHandler(event:TextOperationEvent):void
		{
			featureText.setStyle("color", feature ? "#000000" : "#999999");
		}
		
		protected function featureText_focusInOrOutHandler(event:FocusEvent):void
		{
			if(event.type == FocusEvent.FOCUS_IN) {
				if(featureText.text == "特性") featureText.text = "";
			}
			else {
				if(featureText.text == "") featureText.text = "特性";
			}
		}
		
		
		
		/**
		 * 区块类型选中
		 */
		protected function tileTypeCB_changeHandler(event:Event):void
		{
			if(event.target == impassabilityCB) coverCB.selected = false;
			else impassabilityCB.selected = false;
		}
		
		
		
		/**
		 * 操作类型有改变
		 * @param event
		 */
		protected function arrowBB_changeHandler(event:IndexChangeEvent=null):void
		{
			_tileC.mouseEnabled = _tileC.mouseChildren = (arrowBB.selectedItem.value != "layer");
			
			//容器位置复位
			if(arrowBB.selectedItem.value == "focus") {
				recoverContainerPosition();
				Common.stage.addEventListener(Event.ENTER_FRAME, recoverViewBBArrow);
			}
			else {
				_lastIndex2 = arrowBB.selectedIndex;
				if(arrowBB.selectedItem.value != "layer" && arrowBB.selectedItem.value != "tile")
					AppCommon.app.propertiesPanel.show(null);
			}
		}
		
		/**
		 * 恢复到之前的操作类型
		 */
		private function recoverViewBBArrow(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, recoverViewBBArrow);
			arrowBB.selectedIndex = _lastIndex2;
		}
		
		/**
		 * 容器位置复位
		 */
		private function recoverContainerPosition():void
		{
			_container.x = _container.y = 0;
		}
		
		
		
		
		/**
		 * 操作方式按钮条的相关事件
		 * @param event
		 */
		protected function arrowBB_mouseEventHandler(event:MouseEvent):void
		{
			TweenMax.killTweensOf(arrowBB);
			TweenMax.to(arrowBB, 0.3, { alpha:(event.type == MouseEvent.MOUSE_OVER ? 1 : 0.4) });
		}
		
		
		
		
		/**
		 * 导出区块辅助线
		 * @param event
		 */
		protected function tileLabel_doubleClickHandler(event:MouseEvent):void
		{
			ExportTile.start();
		}
		
		
		
		/**
		 * 根据x和y，获取一个区块
		 * @param x
		 * @param y
		 * @return 
		 */
		public function getTile(x:int, y:int):Tile
		{
			return _tileC.getChildByName("t" + x + "_" + y) as Tile;
		}
		
		public function get hTileCount():int
		{
			return staggeredCB.selected
				? _bgC.width / _tileWidth
				: vTileCount;
		}
		
		public function get vTileCount():int
		{
			return staggeredCB.selected
				? int(_bgC.height / _tileHeight) * 2 - 1
				: Math.ceil(_bgC.width / _tileWidth + _bgC.height / _tileHeight);
		}
		
		
		
		public function get bgC():Sprite { return _bgC; }
		public function get coverC():Sprite { return _coverC; }
		public function get tileC():Sprite { return _tileC; }
		public function get drawTarget():Sprite { return _drawTarget; }
		
		public function set tileWidth(value:uint):void { _tileWidth = value; }
		public function set tileHeight(value:uint):void { _tileHeight = value; }
		
		
		public function get showType():int
		{
			if(pointCB.selected) return 1;
			if(indexCB.selected) return 3;
			return 2;
		}
		//
	}
}