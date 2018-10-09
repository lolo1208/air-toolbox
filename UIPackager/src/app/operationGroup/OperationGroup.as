package app.operationGroup
{
	import app.common.AppCommon;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import lolo.core.Constants;
	import lolo.utils.StringUtil;
	
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.TextInput;
	
	import toolbox.Toolbox;
	import toolbox.config.UIConfig;
	import toolbox.utils.MaxRects;
	
	/**
	 * 操作选项容器
	 * @author LOLO
	 */
	public class OperationGroup extends Group
	{
		public var mrwText:TextInput;
		public var mrhText:TextInput;
		public var mrmDDL:DropDownList;
		public var compressCB:CheckBox;
		public var packBtn:Button;
		
		/**要打包的图标列表*/
		private var _imageList:IList;
		/**正在打包的数据包*/
		private var _packageData:ByteArray;
		/**正在打包的bigBitmap*/
		private var _bigBitmapData:BitmapData;
		/**正在打包的矩形算法*/
		private var _maxRects:MaxRects;
		/**正在打包的图片的Index*/
		private var _index:int;
		/**用于加载需要打包的图片*/
		private var _packLoader:Loader;
		/**用于有损压缩bigBitmap.png*/
		private var _bigBitmapNP:NativeProcess;
		/**用于加载已经压缩好的bigBitmap*/
		private var _bigBitmapLoader:URLLoader;
		/**是否覆盖源文件*/
		private var _overwrite:Boolean;
		
		
		
		public function OperationGroup()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			mrmDDL.dataProvider = MaxRects.METHOD_LIST;
			mrmDDL.selectedIndex = MaxRects.DEFAULT_METHOD;
			
			_bigBitmapNP = new NativeProcess();
			_bigBitmapNP.addEventListener(NativeProcessExitEvent.EXIT, bigBitmapNP_exitHandler);
			
			_bigBitmapLoader = new URLLoader();
			_bigBitmapLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_bigBitmapLoader.addEventListener(Event.COMPLETE, bigBitmapLoader_completeHandler);
			
			_packLoader = new Loader();
			_packLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, packLoader_completeHandler);
		}
		
		
		
		/**
		 * 点击打包按钮
		 * @param event
		 */
		protected function packBtn_clickHandler(event:MouseEvent):void
		{
			this.setFocus();
			startPack();
		}
		
		
		/**
		 * 开始打包
		 * @param overwrite 是否覆盖源文件
		 */
		public function startPack(overwrite:Boolean=false):void
		{
			_imageList = AppCommon.app.fileGroup.selectedFileList.dataProvider;
			if(_imageList == null || _imageList.length == 0) {
				Alert.show("没有需要打包的图片！", "提示");
				return;
			}
			
			try { new File(Toolbox.docPath).deleteDirectory(true); }
			catch(error:Error) {}
			
			_overwrite = overwrite;
			
			_packageData = new ByteArray();
			_packageData.writeByte(compressCB.selected ? Constants.FLAG_IDP : Constants.FLAG_LIDP);//写入类型标记
			_packageData.writeUnsignedInt(0);//写入图像数据的起始position，这里只是占位
			_packageData.writeShort(_imageList.length);//写入图片的数量
			
			var maxW:int = int(mrwText.text);
			var maxH:int = int(mrhText.text);
			_bigBitmapData = new BitmapData(maxW, maxH, true, 0);
			_maxRects = new MaxRects(_bigBitmapData, mrmDDL.selectedItem.value);
			
			Toolbox.progressPanel.show(_imageList.length);
			_index = -1;
			packNextImage();
		}
		
		
		/**
		 * 打包下一张图片
		 */
		private function packNextImage():void
		{
			_index++;
			
			//打包完毕
			if(_index == _imageList.length) {
				packFinish();
				return;
			}
			
			AppCommon.app.fileGroup.selectedFileList.selectedIndex = _index;
			AppCommon.app.fileGroup.selectedFileList_changeHandler();
			
			Toolbox.progressPanel.addProgress();
			_packLoader.load(new URLRequest(_imageList.getItemAt(_index).path));
		}
		
		private function packLoader_completeHandler(event:Event):void
		{
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(event:Event):void
		{
			var info:Object = AppCommon.app.canvasGroup.infoList[_imageList.getItemAt(_index).path];
			if(info == null) return;
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			//将位图内容插入到bigBitmapData中
			var bitmapData:BitmapData = (_packLoader.content as Bitmap).bitmapData;
			var rect:Rectangle = _maxRects.insert(bitmapData);
			
			//写入源名称[ 包名.名称 ]
			_packageData.writeUTF(_imageList.getItemAt(_index).name);
			
			//写入位图数据在 bigBitmapData 中的位置
			_packageData.writeShort(rect.x);
			_packageData.writeShort(rect.y);
			
			//写入宽高
			_packageData.writeShort(bitmapData.width);
			_packageData.writeShort(bitmapData.height);
			
			//写入偏移坐标
			var p:Point = info.p;
			_packageData.writeShort(p.x);
			_packageData.writeShort(p.y);
			
			//写入九切片信息
			var s9Rect:Rectangle = info.g;
			if(s9Rect != null) {
				_packageData.writeByte(1);
				_packageData.writeShort(s9Rect.x);
				_packageData.writeShort(s9Rect.y);
				_packageData.writeShort(s9Rect.width - s9Rect.x);
				_packageData.writeShort(s9Rect.height - s9Rect.y);
			}
			else {
				_packageData.writeByte(0);//不是九切片图像就写入字节 0
			}
			
			packNextImage();
		}
		
		
		
		/**
		 * 打包完成
		 */
		private function packFinish():void
		{
			//将 bigBitmap 裁切成最小矩形，保存成png文件
			var file:File = new File(Toolbox.docPath + "bigBitmap.png");
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			
			fs.writeBytes(_bigBitmapData.encode(_maxRects.curRect, new PNGEncoderOptions(compressCB.selected)));
			fs.close();
			
			//压缩 bigBitmap
			if(compressCB.selected)
			{
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
				loadBigBitmap();
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
			loadBigBitmap();
		}
		
		
		/**
		 * 加载 bigBitmap
		 */
		private function loadBigBitmap():void
		{
			_bigBitmapLoader.load(new URLRequest(Toolbox.docPath + "bigBitmap.png"));
		}
		
		
		/**
		 * 加载已经压缩好的 bigBitmap 完成
		 * @param event
		 */
		private function bigBitmapLoader_completeHandler(event:Event):void
		{
			//写入图像数据的起始position
			_packageData.position = 1;
			_packageData.writeUnsignedInt(_packageData.length);
			
			//写入 bigBitmap 的数据
			var bytes:ByteArray = _bigBitmapLoader.data;
			_packageData.position = _packageData.length;
			_packageData.writeUnsignedInt(bytes.length);//写入数据的长度
			_packageData.writeBytes(bytes);
			//_packageData.compress();
			
			//保存文件
			var file:File = new File(Toolbox.docPath + AppCommon.saveFileName + "." + Constants.EXTENSION_LD);
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(_packageData);
			fs.close();
			
			if(_overwrite) {
				file.moveTo(AppCommon.app.ldFile, true);
				UIConfig.refreshComplete = refreshUIConfigComplete;
				UIConfig.refresh(false);
			}
			else {
				refreshUIConfigComplete();
			}
		}
		
		private function refreshUIConfigComplete():void
		{
			Toolbox.progressPanel.hide();
			if((_maxRects.curRect.width + 100) > _bigBitmapData.width && (_maxRects.curRect.height + 100) > _bigBitmapData.height) {
				Alert.show("bigBitmap.png的尺寸接近MaxRects设置的值，组合成大图时可能出错了！\n点击[OK]可查看bigBitmap.png",
					"提示", Alert.OK | Alert.CANCEL, null, lookBigBitmap_closeHandler);
			}
			else {
				lookBigBitmap_closeHandler();
			}
		}
		
		
		/**
		 * 查看bigBitmap.png
		 * @param event
		 */
		private function lookBigBitmap_closeHandler(event:CloseEvent=null):void
		{
			if(event && event.detail == Alert.OK)
			{
				var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				var args:Vector.<String> = new Vector.<String>();
				args.push(StringUtil.slashToBackslash(Toolbox.docPath.substr(0, Toolbox.docPath.length - 1)));
				
				info.executable = new File(Toolbox.explorerPath);
				info.arguments = args;
				new NativeProcess().start(info);
			}
			Alert.show("打包完毕！\n点击[OK]可查看导出目录。", "提示", Alert.OK | Alert.CANCEL, null, lookLD_closeHandler);
		}
		
		
		/**
		 * 打包完毕，查看目录
		 * @param event
		 */
		private function lookLD_closeHandler(event:CloseEvent):void
		{
			if(event.detail == Alert.OK)
			{
				var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				var args:Vector.<String> = new Vector.<String>();
				args.push(StringUtil.slashToBackslash(_overwrite
					? AppCommon.app.ldFile.parent.nativePath
					: Toolbox.docPath.substr(0, Toolbox.docPath.length - 1)
				));
				
				info.executable = new File(Toolbox.explorerPath);
				info.arguments = args;
				new NativeProcess().start(info);
			}
		}
		
		
		
		public function reset():void
		{
			try { _packLoader.unload(); }
			catch(error:Error) {}
			
			if(_packageData) {
				_packageData.clear();
				_packageData = null;
			}
		}
		//
	}
}