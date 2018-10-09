package app.canvasGroup
{
	import com.greensock.TweenMax;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.utils.DisplayUtil;
	
	import mx.controls.Alert;
	import mx.controls.ColorPicker;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
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
	
	/**
	 * 画布容器
	 * @author LOLO
	 */
	public class CanvasGroup extends Group
	{
		public var colorCB:CheckBox;
		public var colorCP:ColorPicker;
		public var pathText:Label;
		public var cutBtn:Button;
		public var focusBtn:Button;
		
		public var positionGroup:Group;
		public var scale9CB:CheckBox;
		public var xText:TextInput;
		public var yText:TextInput;
		
		private var _uic:UIComponent;
		private var _uicMask:UIComponent;
		private var _loader:Loader;
		private var _item:UIComponent;
		
		public var _dlC:UIComponent;
		public var _h1DL:DottedLine;
		public var _h2DL:DottedLine;
		public var _v1DL:DottedLine;
		public var _v2DL:DottedLine;
		
		private var _gridBG:GridBackground;
		private var _colorBG:UIComponent;
		
		/**有改动的元件的信息列表，path为key*/
		public var infoList:Dictionary = new Dictionary();
		
		/**当前选中的九切片辅助线*/
		private var _selectedDL:DottedLine;
		/**上次更新拖动位置的坐标*/
		private var _lastUpdateDragPosition:Point;
		/**用于有损压缩png*/
		private var _pngNP:NativeProcess;
		
		
		
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
			
			_loader = new Loader();
			_item.addChild(_loader);
			
			
			_dlC = new UIComponent();
			_dlC.visible = false;
			_uic.addChild(_dlC);
			
			_h1DL = new DottedLine();
			_h2DL = new DottedLine();
			_v1DL = new DottedLine();
			_v2DL = new DottedLine();
			_h1DL.x = _h2DL.x = _v1DL.y = _v2DL.y = -100;
			_v1DL.direction = _v2DL.direction = DottedLine.DIRECTION_VERTICAL;
			_dlC.addChild(_h1DL);
			_dlC.addChild(_h2DL);
			_dlC.addChild(_v1DL);
			_dlC.addChild(_v2DL);
			
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
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			
			_gridBG.addEventListener(MouseEvent.MOUSE_DOWN, bg_mouseEventHandler);
			_colorBG.addEventListener(MouseEvent.MOUSE_DOWN, bg_mouseEventHandler);
			
			_h1DL.addEventListener(MouseEvent.MOUSE_DOWN, dl_mouseDownHandler);
			_h2DL.addEventListener(MouseEvent.MOUSE_DOWN, dl_mouseDownHandler);
			_v1DL.addEventListener(MouseEvent.MOUSE_DOWN, dl_mouseDownHandler);
			_v2DL.addEventListener(MouseEvent.MOUSE_DOWN, dl_mouseDownHandler);
			
			_pngNP = new NativeProcess();
			_pngNP.addEventListener(NativeProcessExitEvent.EXIT, pngNP_exitHandler);
			
			focusBtn_clickHandler();
		}
		
		
		protected function addedToStageHandler(event:Event):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
		}
		
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			if(_gridBG == null) return;
			
			_gridBG.width = width - 20;
			_gridBG.height = height - 20;
			colorBG_eventHandler();
			
			colorCB.x = width - 128;
			colorCP.x = width - 110;
			cutBtn.x = width - 70;
			focusBtn.x = width - 40;
			
			positionGroup.x = width - 220;
			positionGroup.y = height - 40;
			
			_uicMask.graphics.clear();
			_uicMask.graphics.beginFill(0x660000, 1);
			_uicMask.graphics.drawRect(0, 0, _gridBG.width - 1, _gridBG.height - 1);
			_uicMask.graphics.endFill();
		}
		
		
		
		/**
		 * 舞台按下键盘
		 * @param event
		 */
		private function stage_keyDownHandler(event:KeyboardEvent):void
		{
			if(stage == null) return;
			
			if(_dlC.visible && _selectedDL != null)
			{
				switch(_selectedDL)
				{
					case _h1DL:
						if(event.keyCode == Keyboard.UP) {
							_h1DL.y--;
							if(_h1DL.y < h1Min) _h1DL.y = h1Min;
						}
						else if(event.keyCode == Keyboard.DOWN) {
							_h1DL.y++;
							if(_h1DL.y > h1Max) _h1DL.y = h1Max;
						}
						break;
					
					case _h2DL:
						if(event.keyCode == Keyboard.UP) {
							_h2DL.y--;
							if(_h2DL.y < h2Min) _h2DL.y = h2Min;
						}
						else if(event.keyCode == Keyboard.DOWN) {
							_h2DL.y++;
							if(_h2DL.y >  h2Max) _h2DL.y = h2Max;
						}
						break;
					
					case _v1DL:
						if(event.keyCode == Keyboard.LEFT) {
							_v1DL.x--;
							if(_v1DL.x < v1Min) _v1DL.x = v1Min;
						}
						else if(event.keyCode == Keyboard.RIGHT) {
							_v1DL.x++;
							if(_v1DL.x > v1Max) _v1DL.x = v1Max;
						}
						break;
					
					case _v2DL:
						if(event.keyCode == Keyboard.LEFT) {
							_v2DL.x--;
							if(_v2DL.x < v2Min) _v2DL.x = v2Min;
						}
						else if(event.keyCode == Keyboard.RIGHT) {
							_v2DL.x++;
							if(_v2DL.x > v2Max) _v2DL.x = v2Max;
						}
						break;
				}
				infoList[pathText.text].g = new Rectangle(_v1DL.x, _h1DL.y, _v2DL.x, _h2DL.y);
				return;
			}
			
			if(!infoList[pathText.text] || _dlC.visible) return;
			
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
				default:
					return;
			}
			itemPositionChanged();
			recordItemPosition();
		}
		
		
		/**
		 * 加载当前图像完成
		 * @param event
		 */
		private function loader_completeHandler(event:Event):void
		{
			_h1DL.width = _h2DL.width = _loader.width + 200;
			_v1DL.height = _v2DL.height = _loader.height + 200;
		}
		
		
		
		/**
		 * 显示图片
		 * @param data
		 */
		public function showImage(data:Object):void
		{
			pathText.text = data.path;
			_loader.load(new URLRequest(data.path));
			if(infoList[data.path] == null) infoList[data.path] = { p:new Point() };
			
			var p:Point = infoList[data.path].p;
			_item.x = p.x;
			_item.y = p.y;
			itemPositionChanged();
			showScale9DottedLine();
			_selectedDL = null;
		}
		
		
		
		/**
		 * 鼠标拖动元件
		 * @param event
		 */
		private function item_mouseEventHandler(event:MouseEvent):void
		{
			this.setFocus();
			if(scale9CB.selected) return;
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
		 * 鼠标在虚线上按下
		 * @param event
		 */
		protected function dl_mouseDownHandler(event:MouseEvent):void
		{
			_selectedDL = event.target as DottedLine;
			var bounds:Rectangle;
			switch(_selectedDL)
			{
				case _h1DL:
					bounds = new Rectangle(_h1DL.x, 2, 0, _h2DL.y - 6);
					break;
				case _h2DL:
					bounds = new Rectangle(_h2DL.x, _h1DL.y + 4, 0, _loader.height - _h1DL.y - 6);
					break;
				case _v1DL:
					bounds = new Rectangle(2, _v1DL.y, _v2DL.x - 6, 0);
					break;
				case _v2DL:
					bounds = new Rectangle(_v1DL.x + 4, _v2DL.y, _loader.width - _v1DL.x - 6, 0);
					break;
			}
			_selectedDL.startDrag(false, bounds);
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}
		
		private function stage_mouseUpHandler(event:MouseEvent):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			_h1DL.stopDrag();
			_h2DL.stopDrag();
			_v1DL.stopDrag();
			_v2DL.stopDrag();
			infoList[pathText.text].g = new Rectangle(_v1DL.x, _h1DL.y, _v2DL.x, _h2DL.y);
		}
		
		
		/**
		 * 启用或删除九切片
		 * @param event
		 */
		protected function scale9CB_clickHandler(event:MouseEvent=null):void
		{
			if(scale9CB.selected) {
				infoList[pathText.text].g = new Rectangle(
					int(_loader.width * 0.2),
					int(_loader.height * 0.2),
					int(_loader.width * 0.8),
					int(_loader.height * 0.8)
				);
				xText.text = yText.text = "0";
				positionText_changeHandler();
			}
			else {
				delete infoList[pathText.text].g;
			}
			showScale9DottedLine();
		}
		
		
		/**
		 * 聚焦元件
		 * @param event
		 */
		protected function focusBtn_clickHandler(event:MouseEvent=null):void
		{
			this.setFocus();
			_uic.x = 180;
			_uic.y = 200;
		}
		
		
		/**
		 * 裁剪图片透明区域
		 * @param event
		 */
		protected function cutBtn_clickHandler(event:MouseEvent):void
		{
			this.setFocus();
			if(!scale9CB.enabled) return;
			
			var arr:Array = pathText.text.split("\\");
			arr = arr[arr.length - 1].split(".");
			if(arr.length > 2) {
				Alert.show("文件的名称有误，不能使用 \".\" 字符！", "提示");
				return;
			}
			
			if(int(arr[0]) > 0) {
				Alert.show("文件的名称不能为纯数字！", "提示");
				return;
			}
			
			Alert.show("您确定要裁切掉图片的透明区域，并压缩图像、覆盖原图吗？", "提示",
				Alert.YES | Alert.NO, this, cutAlert_closeHandler);
		}
		
		private function cutAlert_closeHandler(event:CloseEvent):void
		{
			if(event.detail == Alert.NO) return;
			Toolbox.progressPanel.show();
			
			var bitmapData:BitmapData = (_loader.content as Bitmap).bitmapData;
			var file:File = new File(pathText.text);
			
			//得到图片的最小不透明区域
			if(file.extension == "png")
			{
				try {
					var rect:Rectangle = DisplayUtil.getOpaqueRect(bitmapData);
					var bytes:ByteArray = bitmapData.getPixels(rect);
					bytes.position = 0;
					bitmapData = new BitmapData(rect.width, rect.height);
					bitmapData.setPixels(new Rectangle(0, 0, rect.width, rect.height), bytes);
				}
				catch(error:Error) {
					Alert.show("裁剪图像报错了！！\n这张图片或许不能再被裁剪了吧？", "提示");
					Toolbox.progressPanel.hide();
					return;
				}
			}
			
			//创建新的图像（jpg就此压缩）
			var fs:FileStream = new FileStream();
			var compressor:Object = (file.extension == "png")
				? new PNGEncoderOptions()
				: new JPEGEncoderOptions();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(bitmapData.encode(bitmapData.rect, compressor));
			fs.close();
			
			//压缩png
			if(file.extension == "png")
			{
				var args:Vector.<String> = new Vector.<String>();
				args.push(pathText.text);
				args.push("--quality");
				args.push("0-100");
				args.push("--speed");
				args.push("1");
				args.push("--force");
				args.push("--verbose");
				
				var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				npsi.executable = new File(Toolbox.pngquantPath);
				npsi.arguments = args;
				_pngNP.start(npsi);
			}
			else {
				reloadImage();
			}
		}
		
		private function pngNP_exitHandler(event:NativeProcessExitEvent):void
		{
			var sFile:File = new File(pathText.text);
			var name:String = sFile.name.substr(0, sFile.name.length - 4);
			var cFile:File = new File(pathText.text.replace(name, name + "-fs8"));
			if(cFile.exists) {
				cFile.copyTo(sFile, true);
				cFile.deleteFile();
				reloadImage();
			}
			else {
				Alert.show(sFile.name + " 在进行有损压缩时报错了！！", "失败");
				Toolbox.progressPanel.hide();
			}
		}
		
		
		/**
		 * 删除九切片信息，加载新图像
		 */
		private function reloadImage():void
		{
			scale9CB.selected = false;
			scale9CB_clickHandler();
			_loader.load(new URLRequest(pathText.text));
			
			Toolbox.progressPanel.hide();
		}
		
		
		/**
		 * 显示或隐藏当前选中图像的九切片
		 */
		private function showScale9DottedLine():void
		{
			scale9CB.enabled = _dlC.visible = pathText.text != "";
			if(!scale9CB.enabled) return;
			
			var rect:Rectangle = infoList[pathText.text].g
			_dlC.visible = scale9CB.selected = rect != null;
			if(_dlC.visible) {
				_h1DL.y = rect.y;
				_h2DL.y = rect.height;
				_v1DL.x = rect.x;
				_v2DL.x = rect.width;
			}
			xText.editable = yText.editable = !scale9CB.selected;
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
		
		
		
		private function get h1Min():int { return 2; }
		private function get h1Max():int { return _h2DL.y - 4; }
		
		private function get h2Min():int { return _h1DL.y + 4; }
		private function get h2Max():int { return _loader.height - 2; }
		
		private function get v1Min():int { return 2; }
		private function get v1Max():int { return _v2DL.x - 4; }
		
		private function get v2Min():int { return _v1DL.x + 4; }
		private function get v2Max():int { return _loader.width - 2; }
		
		
		
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
			_colorBG.graphics.clear();
			colorCP.enabled = colorCB.selected;
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
		
		
		
		public function reset():void
		{
			infoList = new Dictionary();
			pathText.text = "";
			xText.text = yText.text = "0";
			
			try { _loader.close(); }
			catch(error:Error) {}
			try { _loader.unload(); }
			catch(error:Error) {}
			
			scale9CB.selected = false;
			showScale9DottedLine();
		}
		//
	}
}