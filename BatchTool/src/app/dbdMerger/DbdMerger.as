package app.dbdMerger
{
	import com.greensock.TweenMax;
	
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	
	import lolo.core.Common;
	import lolo.utils.DisplayUtil;
	import lolo.utils.StringUtil;
	import lolo.utils.zip.ZipReader;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.TextInput;
	
	import toolbox.Toolbox;
	import toolbox.controls.GroupBox;
	
	/**
	 * DragonBonesData合并工具
	 * @author LOLO
	 */
	public class DbdMerger extends GroupBox
	{
		public var zipText:TextInput;
		public var zipBtn:Button;
		public var pngText:TextInput;
		public var pngBtn:Button;
		public var dirText:TextInput;
		public var dirBtn:Button;
		public var minSizeCB:CheckBox;
		public var compressCB:CheckBox;
		public var exportBtn:Button;
		
		private var _zip:File;
		private var _png:File;
		private var _dir:File;
		private var _fileName:String;
		private var _skeData:Object;
		private var _texData:Object;
		private var _texture:BitmapData;
		private var _minTexture:BitmapData;
		private var _textureBytes:ByteArray;
		private var _fileList:Vector.<File>;
		private var _exportType:int;
		
		/**用于加载原始纹理图像*/
		private var _loader:Loader;
		/**用于有损压缩bigBitmap.png*/
		private static var _bigBitmapNP:NativeProcess;
		/**用于加载已经压缩好的bigBitmap*/
		private static var _bigBitmapLoader:URLLoader;
		
		
		
		public function DbdMerger()
		{
			super();
		}
		
		
		
		public function init():void
		{
			_fileList = new Vector.<File>();
			
			_zip = new File();
			_zip.addEventListener(Event.SELECT, zipHandler);
			_zip.addEventListener(Event.COMPLETE, zipHandler);
			
			_png = new File();
			_png.addEventListener(Event.SELECT, pngHandler);
			_png.addEventListener(Event.COMPLETE, pngHandler);
			
			_dir = new File();
			_dir.addEventListener(Event.SELECT, dirHandler);
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			
			_bigBitmapNP = new NativeProcess();
			_bigBitmapNP.addEventListener(NativeProcessExitEvent.EXIT, bigBitmapNP_exitHandler);
			
			_bigBitmapLoader = new URLLoader();
			_bigBitmapLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_bigBitmapLoader.addEventListener(Event.COMPLETE, bigBitmapLoader_completeHandler);
			
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, treeGroup_nativeDragDropHandler);
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, treeGroup_nativeDragDropHandler);
		}
		
		
		
		/**
		 * 拖入文件
		 * @param event
		 */
		protected function treeGroup_nativeDragDropHandler(event:NativeDragEvent):void
		{
			var file:File = event.clipboard.getData(event.clipboard.formats[0])[0];
			if(file == null) return;//不是文件
			var extension:String;
			if(!file.isDirectory) {
				extension = file.extension.toLocaleLowerCase();
				if(extension != "zip" && extension != "png") return;
			}
			
			if(event.type == NativeDragEvent.NATIVE_DRAG_ENTER) {
				NativeDragManager.acceptDragDrop(event.target as InteractiveObject);
			}
			else
			{
				if(file.isDirectory) {
					dirText.text = file.nativePath;
					parseDir();
				}
				else {
					if(extension == "zip") {
						zipText.text = file.nativePath;
						loadZIP()
					}
					else {
						pngText.text = file.nativePath;
						loadPNG();
					}
				}
			}
		}
		
		
		
		
		/**
		 * ZIP文件选择和加载相关
		 * @param event
		 */
		protected function zipText_keyUpHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER) loadZIP();
		}
		
		protected function zipBtn_clickHandler(event:MouseEvent):void
		{
			try {
				_zip.nativePath = zipText.text;
			}
			catch(error:Error) {}
			_zip.browse([new FileFilter("请选择包含 skeleton.json、texture.json、texture.png 的ZIP文件", "*.zip")]);
		}
		
		private function loadZIP():void
		{
			try {
				startExport(1);
				_zip.nativePath = zipText.text;
				_zip.load();
			}
			catch(error:Error) {
				Alert.show("错误的ZIP路径！");
			}
		}
		
		private function zipHandler(event:Event):void
		{
			if(event.type == Event.SELECT)
			{
				zipText.text = _zip.nativePath;
				loadZIP();
			}
			else
				parseZip();
		}
		
		private function parseZip(alert:Boolean=true, file:File=null):Boolean
		{
			if(file == null) file = _zip;
			
			var zip:ZipReader = new ZipReader(file.data);
			if(zip.entries.length != 3) {
				if(alert) Alert.show("错误的ZIP文件！");
				return false;
			}
			
			try
			{
				var textureBytes:ByteArray;
				for(var i:int = 0; i < zip.entries.length; i++)
				{
					var name:String = zip.entries[i].name.toLocaleLowerCase();
					var arr:Array = name.split(".");
					var extension:String = arr[arr.length - 1];
					var bytes:ByteArray = zip.getInput(zip.entries[i]);
					
					//纹理图像
					if(extension == "png")
					{
						textureBytes = bytes;
					}
					else if(extension == "json")
					{
						var obj:Object = JSON.parse(bytes.toString());
						//骨骼信息
						if(obj.name != null && obj.armature != null) {
							_skeData = obj;
						}
							//纹理信息
						else if(obj.name != null && obj.SubTexture != null) {
							_texData = obj;
						}
						else {
							if(alert) Alert.show("错误的ZIP文件！");
							return false;
						}
					}
					else {
						if(alert) Alert.show("错误的ZIP文件！");
						return false;
					}
				}
				
				_fileName = file.name.substring(0, file.name.length - 4);
				_loader.loadBytes(textureBytes);
			}
			catch(error:Error)
			{
				if(alert) Alert.show("错误的ZIP文件！");
				return false;
			}
			
			return true;
		}
		
		
		
		
		
		/**
		 * PNG文件选择和加载相关
		 * @param event
		 */
		protected function pngText_keyUpHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER) loadPNG();
		}
		
		protected function pngBtn_clickHandler(event:MouseEvent):void
		{
			try {
				_png.nativePath = pngText.text;
			}
			catch(error:Error) {}
			_png.browse([new FileFilter("请选择包含：骨骼信息、纹理信息、纹理图像的PNG文件", "*.png")]);
		}
		
		private function loadPNG():void
		{
			try {
				startExport(2);
				_png.nativePath = pngText.text;
				_png.load();
			}
			catch(error:Error) {
				Alert.show("错误的PNG路径！");
			}
		}
		
		private function pngHandler(event:Event):void
		{
			if(event.type == Event.SELECT)
			{
				pngText.text = _png.nativePath;
				loadPNG();
			}
			else
				parsePng();
		}
		
		private function parsePng(alert:Boolean=true, file:File=null):Boolean
		{
			if(file == null) file = _png;
			
			try {
				var intSize:int = 4;
				var decodedBytes:ByteArray = new ByteArray();
				var helpBytes:ByteArray = new ByteArray();
				decodedBytes.writeBytes(file.data);
				decodedBytes.position = decodedBytes.length - intSize;
				var dataSize:int = decodedBytes.readInt();
				var position:uint = decodedBytes.length - intSize - dataSize;
				helpBytes.writeBytes(decodedBytes, position, dataSize);
				
				//Read DragonBones Data
				helpBytes.uncompress();
				helpBytes.position = 0;
				_skeData = helpBytes.readObject();
				
				//Get TextureAtlas Data size and position
				decodedBytes.length = position;
				decodedBytes.position = decodedBytes.length - intSize;
				dataSize = decodedBytes.readInt();
				position = decodedBytes.length - intSize - dataSize;
				
				//Read TextureAtlas Data
				helpBytes.length = 0;
				helpBytes.writeBytes(decodedBytes, position, dataSize);
				helpBytes.uncompress();
				helpBytes.position = 0;
				_texData = helpBytes.readObject();
				helpBytes.clear();
				
				//TextureAtlas
				decodedBytes.length = position;
				
				_fileName = file.name.substring(0, file.name.length - 4);
				_loader.loadBytes(decodedBytes);
			}
			catch(error:Error)
			{
				if(alert) Alert.show("错误的PNG文件！");
				return false;
			}
			
			return true;
		}
		
		
		
		
		
		/**
		 * 文件夹选择和解析相关
		 * @param event
		 */
		protected function dirText_keyUpHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER) parseDir();
		}
		
		protected function dirBtn_clickHandler(event:MouseEvent):void
		{
			try {
				_dir.nativePath = dirText.text;
			}
			catch(error:Error) {}
			_dir.browseForDirectory("请选择包含DragonBones数据的文件夹（不支持嵌套）");
		}
		
		private function parseDir(export:Boolean=false):void
		{
			try {
				startExport(3);
				_dir.nativePath = dirText.text;
				
				_fileList.length = 0;
				var list:Array = _dir.getDirectoryListing();
				for(var i:int = 0; i < list.length; i++)
				{
					var file:File = list[i];
					if(file.isDirectory) continue;
					var extension:String = file.extension.toLocaleLowerCase();
					if(extension == "zip" || extension == "png") {
						file.load();
						_fileList.push(file);
					}
				}
				
				if(_fileList.length == 0) {
					Alert.show("文件夹下不包含任何DragonBones数据文件！");
				}
				else {
					if(export) {
						exportBtn.enabled = true;
						TweenMax.killDelayedCallsTo(do_exportBtn_clickHandler);
						TweenMax.delayedCall(2, do_exportBtn_clickHandler);
					}
					else {
						showExportBtn();
					}
				}
			}
			catch(error:Error) {
				Alert.show("错误的文件夹路径！");
			}
		}
		
		private function dirHandler(event:Event):void
		{
			if(event.type == Event.SELECT)
			{
				dirText.text = _dir.nativePath;
				parseDir();
			}
		}
		
		
		
		
		/**
		 * 加载纹理图像完成
		 * @param event
		 */
		private function loaderCompleteHandler(event:Event):void
		{
			try {
				_texture = (_loader.content as Bitmap).bitmapData;
			}
			catch(error:Error)
			{
				if(isBatch) {
					exportNext();
				}
				else {
					Alert.show("纹理图像有误！");
				}
				return;
			}
			
			if(isBatch) {
				Common.stage.addEventListener(Event.ENTER_FRAME, doExport);
			}
			else {
				showExportBtn();
			}
		}
		
		
		
		
		/**
		 * 点击导出按钮
		 * @param event
		 */
		protected function exportBtn_clickHandler(event:MouseEvent):void
		{
			Toolbox.progressPanel.show(_fileList.length);
			TweenMax.killDelayedCallsTo(do_exportBtn_clickHandler);
			TweenMax.delayedCall(1, do_exportBtn_clickHandler);
			
			try { new File(Toolbox.docPath).deleteDirectory(true); }
			catch(error:Error) {}
		}
		
		private function do_exportBtn_clickHandler():void
		{
			TweenMax.killDelayedCallsTo(do_exportBtn_clickHandler);
			
			if(isBatch) {
				if(_fileList.length == 0) {
					parseDir(true);
				}
				else {
					Common.stage.addEventListener(Event.ENTER_FRAME, exportNext);
				}
			}
			else {
				Common.stage.addEventListener(Event.ENTER_FRAME, doExport);
			}
		}
		
		
		private function exportNext(event:Event=null):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, exportNext);
			Toolbox.progressPanel.addProgress();
			
			if(_fileList.length == 0)
			{
				Toolbox.progressPanel.hide();
				Alert.show("导出完毕！", "提示", 4, null, alert_closeHandler);
			}
			else
			{
				var file:File = _fileList.shift();
				var succ:Boolean;
				if(file.extension.toLocaleLowerCase() == "zip")
					succ = parseZip(false, file);
				else
					succ = parsePng(false, file);
				
				if(!succ) exportNext();
			}
		}
		
		
		
		private function doExport(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, doExport);
			
			//切到最小尺寸
			if(minSizeCB.selected)
			{
				var rect:Rectangle = DisplayUtil.getOpaqueRect(_texture);
				//保留左和上的空像素
				rect.width += rect.x;
				rect.height += rect.y;
				rect.x = rect.y = 0;
				
				_minTexture = new BitmapData(rect.width, rect.height, true, 0);
				_minTexture.copyPixels(_texture, rect, new Point());
			}
			
			//有损压缩
			if(compressCB.selected)
			{
				//将 bigBitmap 裁切成最小矩形，保存成png文件
				var file:File = new File(Toolbox.docPath + "bigBitmap.png");
				var fs:FileStream = new FileStream();
				fs.open(file, FileMode.WRITE);
				fs.writeBytes(textureData.encode(textureData.rect, new PNGEncoderOptions(true)));
				fs.close();
				
				var args:Vector.<String> = new Vector.<String>();
				args.push(file.nativePath);
				args.push("--quality");
				args.push("0-100");
				args.push("--speed");
				args.push("1");
				args.push("--force");
				args.push("--verbose");
				
				var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				npsi.executable = new File(Toolbox.pngquantPath);
				npsi.arguments = args;
				_bigBitmapNP.start(npsi);
			}
			else {
				bigBitmapLoader_completeHandler();
			}
		}
		
		
		
		/**
		 * 压缩 bigBitmap 完成
		 * @param event
		 */
		private function bigBitmapNP_exitHandler(event:NativeProcessExitEvent):void
		{
			var pngPath:String = Toolbox.docPath + "bigBitmap";
			var cFile:File = new File(pngPath + "-fs8.png");
			if(cFile.exists) {
				cFile.copyTo(new File(pngPath + ".png"), true);
				cFile.deleteFile();
			}
			_bigBitmapLoader.load(new URLRequest(Toolbox.docPath + "bigBitmap.png"));
		}
		
		
		/**
		 * 加载已经压缩好的 bigBitmap 完成
		 * @param event
		 */
		private function bigBitmapLoader_completeHandler(event:Event=null):void
		{
			if(event == null) {
				_textureBytes = textureData.encode(textureData.rect, new PNGEncoderOptions());
			}
			else {
				_textureBytes = _bigBitmapLoader.data;
				_bigBitmapLoader.close();
			}
			
			Common.stage.addEventListener(Event.ENTER_FRAME, doWriteFile);
		}
		
		
		private function doWriteFile(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, doWriteFile);
			
			//纹理信息
			var texBytes:ByteArray = new ByteArray();
			texBytes.writeObject(_texData);
			texBytes.compress();
			
			//龙骨信息
			var steBytes:ByteArray = new ByteArray();
			steBytes.writeObject(_skeData);
			steBytes.compress();
			
			//按顺序，写入最终数据
			var bytes:ByteArray = new ByteArray();
			bytes.writeBytes(_textureBytes);
			bytes.writeBytes(texBytes);
			bytes.writeInt(texBytes.length);
			bytes.writeBytes(steBytes);
			bytes.writeInt(steBytes.length);
			
			//保存文件
			var file:File = new File(Toolbox.docPath + _fileName + ".png");
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(bytes);
			fs.close();
			
			//提示
			if(isBatch) {
				exportNext();
			}
			else {
				Toolbox.progressPanel.hide();
				Alert.show("导出成功！", "提示", 4, null, alert_closeHandler);
			}
		}
		
		
		
		/**
		 * 查看导出的texture.png
		 * @param event
		 */
		private function alert_closeHandler(event:CloseEvent):void
		{
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var args:Vector.<String> = new Vector.<String>();
			args.push(StringUtil.slashToBackslash(
				Toolbox.docPath.substr(0, Toolbox.docPath.length - 1)
			));
			info.executable = new File(Toolbox.explorerPath);
			info.arguments = args;
			new NativeProcess().start(info);
			
			try {
				new File(Toolbox.docPath + "bigBitmap.png").deleteFile();
			}
			catch(error:Error){}
		}
		
		
		
		
		
		private function startExport(type:int):void
		{
			_exportType = type;
			exportBtn.enabled = false;
			Common.stage.focus = null;
			
			var c1:uint = 0x000000, c2:uint = 0x999999;
			zipText.setStyle("color", (type == 1) ? c1 : c2);
			pngText.setStyle("color", (type == 2) ? c1 : c2);
			dirText.setStyle("color", (type == 3) ? c1 : c2);
		}
		
		
		private function showExportBtn():void
		{
			exportBtn.enabled = true;
			var color:uint = 0x00FF00;
			TweenMax.killTweensOf(exportBtn);
			TweenMax.to(exportBtn, 0.8, { glowFilter:{color:color, alpha:1, blurX:20, blurY:20 }});
			TweenMax.to(exportBtn, 0.4, { glowFilter:{color:color, alpha:0.1, blurX:0, blurY:0 }, delay:0.8});
			TweenMax.to(exportBtn, 0.4, { glowFilter:{color:color, alpha:1, blurX:20, blurY:20 }, delay:1.2});
			TweenMax.to(exportBtn, 0.2, { glowFilter:{color:color, alpha:0.1, blurX:0, blurY:0 }, delay:1.6});
			TweenMax.to(exportBtn, 0.4, { glowFilter:{color:color, alpha:1, blurX:20, blurY:20 }, delay:1.8});
			TweenMax.to(exportBtn, 0.2, { glowFilter:{color:color, alpha:0.1, blurX:0, blurY:0 }, delay:2.2});
		}
		
		
		private function get textureData():BitmapData
		{
			return minSizeCB.selected ? _minTexture : _texture;
		}
		
		
		/**
		 * 是否为批量导出
		 */
		private function get isBatch():Boolean
		{
			return _exportType == 3;
		}
		
		//
	}
}