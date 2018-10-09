package app.canvasGroup
{
	import app.common.AppCommon;
	
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.display.BitmapMovieClip;
	import lolo.display.BitmapMovieClipData;
	import lolo.events.AnimationEvent;
	import lolo.utils.DisplayUtil;
	
	import mx.controls.ColorPicker;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;
	
	import toolbox.Toolbox;
	import toolbox.controls.DottedLine;
	import toolbox.controls.GridBackground;
	import toolbox.controls.Timeline;
	
	/**
	 * 画布容器
	 * @author LOLO
	 */
	public class CanvasGroup extends Group
	{
		/**动画已经加载完毕*/
		public static const ANI_LOAD_COMPLETE:String = "aniLoadComplete";
		
		public var colorCB:CheckBox;
		public var colorCP:ColorPicker;
		public var pathText:Label;
		public var focusBtn:Button;
		
		public var positionGroup:Group;
		public var timeline:Timeline;
		public var fpsText:TextInput;
		public var xText:TextInput;
		public var yText:TextInput;
		
		private var _uic:UIComponent;
		private var _uicMask:UIComponent;
		private var _bmc:BitmapMovieClip;
		private var _item:UIComponent;
		
		private var _gridBG:GridBackground;
		private var _colorBG:UIComponent;
		
		/**是否正在加载动画*/
		private var _loadAni:Boolean;
		
		/**当前选中的TreeItem的data*/
		private var _itemData:Object;
		/**用于加载动画帧图像*/
		private var _loader:Loader;
		/**当前需要加载的动画帧图像url列表*/
		private var _frameUrlList:Array;
		
		/**有改动的元件的信息列表，path为key*/
		public var infoList:Dictionary = new Dictionary();
		
		/**当前选中的九切片辅助线*/
		private var _selectedDL:DottedLine;
		/**上次更新拖动位置的坐标*/
		private var _lastUpdateDragPosition:Point;
		
		/**默认注册点位置*/
		private var _defaultCP:Point = new Point();
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			_gridBG = new GridBackground();
			_gridBG.x = _gridBG.y = 10;
			this.addElementAt(_gridBG, 0);
			
			_colorBG = new UIComponent();
			this.addElementAt(_colorBG, 1);
			
			_uic = new UIComponent();
			_uic.x = _uic.y = 10;
			this.addElementAt(_uic, 2);
			
			_uicMask = new UIComponent();
			_uicMask.x = _uicMask.y = 11;
			_uic.mask = _uicMask;
			this.addElement(_uicMask);
			
			_item = new UIComponent();
			_uic.addChild(_item);
			
			_bmc = new BitmapMovieClip();
			_item.addChild(_bmc);
			
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
			
			
			_item.addEventListener(MouseEvent.MOUSE_DOWN, item_mouseEventHandler);
			_gridBG.addEventListener(MouseEvent.MOUSE_DOWN, bg_mouseEventHandler);
			_colorBG.addEventListener(MouseEvent.MOUSE_DOWN, bg_mouseEventHandler);
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			
			_bmc.dispatchEnterFrame = true;
			_bmc.addEventListener(AnimationEvent.ENTER_FRAME, bmc_enterFrameHandler);
			timeline.addEventListener(DataEvent.DATA, timelineEventHandler);
			
			focusBtn_clickHandler();
		}
		
		
		protected function addedToStageHandler(event:Event):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
		}
		
		
		/**
		 * 舞台按下键盘
		 * @param event
		 */
		private function stage_keyDownHandler(event:KeyboardEvent):void
		{
			if(stage == null || !infoList[pathText.text]) return;
			
			var item:Object = AppCommon.app.fileGroup.fileTree.selectedItem;
			var list:Array = item.parent.children;
			var path:String = item.path;
			path = path.substr(0, path.length - item.name.length);
			
			switch(event.keyCode)
			{
				case Keyboard.UP:
					_item.y--;
					break;
				case Keyboard.DOWN:
					_item.y++;
					break;
				case Keyboard.LEFT:
					_item.x--;
					break;
				case Keyboard.RIGHT:
					_item.x++;
					break;
				
				case Keyboard.LEFTBRACKET:
					AppCommon.saveFileName = "1";
					AppCommon.app.ldFile.nativePath = path + AppCommon.saveFileName + "." + Constants.EXTENSION_LD;
					selectAvatar(list, "run", "stand");
					break;
				case Keyboard.RIGHTBRACKET:
					AppCommon.saveFileName = "2";
					AppCommon.app.ldFile.nativePath = path + AppCommon.saveFileName + "." + Constants.EXTENSION_LD;
					selectAvatar(list, "attack", "hitted", "dead", "conjure", "appear", "leisure", "att2_", "dash");
					break;
				
				default:
					return;
			}
			itemPositionChanged();
			recordItemPosition();
		}
		
		
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			if(_gridBG == null) return;
			
			_gridBG.width = width - 20;
			_gridBG.height = height - 55;
			
			colorCB.x = width - 98;
			colorCP.x = width - 80;
			focusBtn.x = width - 40;
			colorBG_eventHandler();
			
			positionGroup.y = height - 35;
			timeline.width = width - 300;
			
			_uicMask.graphics.clear();
			_uicMask.graphics.beginFill(0x660000, 1);
			_uicMask.graphics.drawRect(0, 0, _gridBG.width - 1, _gridBG.height - 1);
			_uicMask.graphics.endFill();
		}
		
		
		/**
		 * 显示动画
		 * @param data
		 */
		public function showAni(data:Object):void
		{
			//动画正在加载中（使用箭头按钮选中的TreeItem）
			if(_loadAni) {
				AppCommon.app.fileGroup.fileTree.selectedItem = _itemData;
				return;
			}
			
			_itemData = data;
			pathText.text = data.path;
			
			if(infoList[data.path] == null) infoList[data.path] = { p:_defaultCP.clone(), fps:12 };
			
			var info:Object = infoList[data.path];
			_item.x = info.p.x;
			_item.y = info.p.y;
			_bmc.fps = info.fps;
			fpsText.text = _bmc.fps.toString();
			itemPositionChanged();
			
			//还没加载过这个动画
			if(_itemData.frameList == null)
			{
				_itemData.frameList = new Vector.<BitmapMovieClipData>();
				_frameUrlList = _itemData.imgUrlList;
				if(!AppCommon.packing) Toolbox.progressPanel.show(_frameUrlList.length);
				_loadAni = true;
				loadNextFrame();
			}
			else {
				showCurrentAni();
			}
		}
		
		
		/**
		 * 加载下一帧
		 */
		private function loadNextFrame():void
		{
			if(_frameUrlList.length == 0) {
				if(!AppCommon.packing) Toolbox.progressPanel.hide();
				_loadAni = false;
				showCurrentAni();
				return;
			}
			
			if(!AppCommon.packing) Toolbox.progressPanel.addProgress();
			_loader.load(new URLRequest(_frameUrlList.shift()));
		}
		
		
		/**
		 * 加载图片数据完成
		 * @param event
		 */
		private function loader_completeHandler(event:Event):void
		{
			var bitmapData:BitmapData = (_loader.content as Bitmap).bitmapData;
			
			//得到图片的最小不透明区域
			var rect:Rectangle = DisplayUtil.getOpaqueRect(bitmapData);
			var bytes:ByteArray = bitmapData.getPixels(rect);
			bytes.position = 0;
			var bmcData:BitmapMovieClipData = new BitmapMovieClipData(
				rect.width, rect.height, rect.x, rect.y
			);
			bmcData.setPixels(new Rectangle(0, 0, rect.width, rect.height), bytes);
			_itemData.frameList.push(bmcData);
			
			//需要修正偏移值（载入ld，并且还没加载过帧数据）
			var info:Object = infoList[_itemData.path];
			if(info.needOffset) {
				delete info.needOffset;
				info.p.x -= rect.x;
				info.p.y -= rect.y;
				_item.x = info.p.x;
				_item.y = info.p.y;
				itemPositionChanged();
			}
			
			loadNextFrame();
		}
		
		
		private function showCurrentAni():void
		{
			_bmc.frameList = _itemData.frameList;
			_bmc.play();
			timeline.contentFrameNum = _bmc.totalFrames;
			this.dispatchEvent(new Event(ANI_LOAD_COMPLETE));
		}
		
		private function bmc_enterFrameHandler(event:AnimationEvent):void
		{
			timeline.currentFrame = _bmc.currentFrame;
		}
		
		private function timelineEventHandler(event:DataEvent):void
		{
			_bmc.gotoAndStop(uint(event.data));
			
			TweenMax.killDelayedCallsTo(_bmc.play);
			TweenMax.delayedCall(5, _bmc.play);
		}
		
		
		
		
		
		
		/**
		 * 鼠标拖动元件
		 * @param event
		 */
		private function item_mouseEventHandler(event:MouseEvent):void
		{
			this.setFocus();
			switch(event.type)
			{
				case MouseEvent.MOUSE_DOWN:
					Common.stage.addEventListener(MouseEvent.MOUSE_UP, item_mouseEventHandler);
					Common.stage.addEventListener(MouseEvent.MOUSE_MOVE, item_mouseEventHandler);
					_item.startDrag();
					break;
				
				case MouseEvent.MOUSE_MOVE:
					break;
				
				case MouseEvent.MOUSE_UP:
					Common.stage.removeEventListener(MouseEvent.MOUSE_UP, item_mouseEventHandler);
					Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, item_mouseEventHandler);
					_item.stopDrag();
					break;
			}
			itemPositionChanged();
			recordItemPosition();
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
		
		
		/**
		 * 聚焦元件
		 * @param event
		 */
		protected function focusBtn_clickHandler(event:MouseEvent=null):void
		{
			this.setFocus();
			_uic.x = width - _bmc.width >> 1;
			_uic.y = height - 30 - _bmc.height >> 1;
		}
		
		
		
		/**
		 * 舞台上的元件坐标有改变
		 */
		private function itemPositionChanged():void
		{
			xText.text = _item.x.toString();
			yText.text = _item.y.toString();
		}
		
		/**
		 * 记录当前元件的坐标
		 */
		private function recordItemPosition():void
		{
			infoList[pathText.text].p = new Point(_item.x, _item.y);
		}
		
		
		
		
		
		/**
		 * 将注册点位置应用到所有动画
		 * @param event
		 */
		protected function allBtn_clickHandler(event:MouseEvent):void
		{
			_defaultCP.x = _item.x;
			_defaultCP.y = _item.y;
			for each(var info:Object in infoList) {
				info.p = _defaultCP.clone();
				delete info.needOffset;
			}
		}
		
		
		/**
		 * 帧频文本内容有改变
		 * @param event
		 */
		protected function fpsText_changeHandler(event:TextOperationEvent=null):void
		{
			if(_bmc.frameList == null) return;
			var fps:int = int(fpsText.text);
			if(fps != 0) {
				_bmc.fps = fps;
				infoList[pathText.text].fps = _bmc.fps;
			}
		}
		
		/**
		 * 坐标文本内容有改变
		 * @param event
		 */
		protected function positionText_changeHandler(event:TextOperationEvent=null):void
		{
			if(!infoList[pathText.text]) return;
			_item.x = int(xText.text);
			_item.y = int(yText.text);
			recordItemPosition();
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
		
		
		
		/**
		 * 选中avatar相关的动作动画
		 * @param list
		 * @param actions
		 */
		private function selectAvatar(list:Array, ...actions:Array):void
		{
			AppCommon.app.fileGroup.fileTree.selectAll(false);
			
			for(var a:int = 0; a < actions.length; a++) {
				var action:String = actions[a];
				for(var d:int = 1; d < 9; d++) {
					for(var i:int = 0; i < list.length; i++) {
						var item:Object = list[i];
						if(item.name == action + d) {
							item.selected = true;
						}
					}
				}
			}
			
			AppCommon.app.fileGroup.fileTree.itemSelectChanged();
		}
		
		
		
		public function get itemX():int { return _item.x; }
		public function get itemY():int { return _item.y; }
		
		
		
		
		public function reset():void
		{
			infoList = new Dictionary();
			pathText.text = "";
			xText.text = yText.text = fpsText.text = "0";
			
			_bmc.stop();
			_bmc.frameList = null;
			(_bmc.getChildAt(0) as Bitmap).bitmapData = null;
			timeline.contentFrameNum = 0;
			
			try { _loader.close(); }
			catch(error:Error) {}
			try { _loader.unload(); }
			catch(error:Error) {}
		}
		//
	}
}