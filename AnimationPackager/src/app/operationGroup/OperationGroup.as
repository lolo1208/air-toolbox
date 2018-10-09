package app.operationGroup
{
	import app.canvasGroup.CanvasGroup;
	import app.common.AppCommon;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import lolo.core.Constants;
	import lolo.display.BitmapMovieClipData;
	import lolo.utils.StringUtil;
	
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.TextInput;
	
	import toolbox.Toolbox;
	import toolbox.config.AniConfig;
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
		public var packBtn:Button;
		
		/**要打包的动画列表*/
		private var _aniList:IList;
		/**正在打包的数据包*/
		private var _packageData:ByteArray;
		/**正在打包的bigBitmap*/
		private var _bigBitmapData:BitmapData;
		/**正在打包的矩形算法*/
		private var _maxRects:MaxRects;
		/**正在打包的图片的Index*/
		private var _index:int;
		/**用于有损压缩bigBitmap.png*/
		private var _bigBitmapNP:NativeProcess;
		/**用于加载已经压缩好的bigBitmap*/
		private var _bigBitmapLoader:URLLoader;
		
		/**是否覆盖源文件*/
		private var _overwrite:Boolean;
		/**是否需要刷新AnimationConfig*/
		private var _refreshConfig:Boolean;
		
		
		
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
		public function startPack(overwrite:Boolean=false, refreshConfig:Boolean=false):void
		{
			_aniList = AppCommon.app.fileGroup.selectedFileList.dataProvider;
			if(_aniList == null || _aniList.length == 0) {
				Alert.show("没有需要打包的动画！", "提示");
				return;
			}
			
			try { new File(Toolbox.docPath).deleteDirectory(true); }
			catch(error:Error) {}
			
			_overwrite = overwrite;
			_refreshConfig = refreshConfig;
			
			_packageData = new ByteArray();
			_packageData.writeByte(Constants.FLAG_AD);//写入类型标记
			_packageData.writeUnsignedInt(0);//写入图像数据的起始position，这里只是占位
			_packageData.writeByte(_aniList.length);//写入动画的数量
			
			var maxW:int = int(mrwText.text);
			var maxH:int = int(mrhText.text);
			_bigBitmapData = new BitmapData(maxW, maxH, true, 0);
			_maxRects = new MaxRects(_bigBitmapData, mrmDDL.selectedItem.value);
			
			AppCommon.packing = true;
			AppCommon.app.canvasGroup.addEventListener(CanvasGroup.ANI_LOAD_COMPLETE, aniLoadCompleteHandler);
			Toolbox.progressPanel.show(_aniList.length + 3);
			_index = -1;
			packNextAni();
		}
		
		
		/**
		 * 打包下一个动画
		 */
		private function packNextAni():void
		{
			_index++;
			
			//打包完毕
			if(_index == _aniList.length) {
				packFinish();
				return;
			}
			
			Toolbox.progressPanel.addProgress();
			AppCommon.app.fileGroup.selectedFileList.selectedIndex = _index;
			AppCommon.app.fileGroup.selectedFileList_changeHandler();
		}
		
		private function aniLoadCompleteHandler(event:Event):void
		{
			var item:Object = _aniList.getItemAt(_index);
			var treeItem:Object = item.treeItemData;
			var frameList:Vector.<BitmapMovieClipData> = treeItem.frameList;
			
			_packageData.writeUTF(item.name);//写入动画的名称[ 包名.名称 ]
			_packageData.writeShort(frameList.length);//写入动画帧数
			_packageData.writeByte(AppCommon.app.canvasGroup.infoList[item.path].fps);//写入默认帧频
			
			for(var i:int = 0; i < frameList.length; i++)
			{
				//将位图内容插入到bigBitmapData中
				var bmcData:BitmapMovieClipData = frameList[i];
				var rect:Rectangle = _maxRects.insert(bmcData);
				
				//写入帧位图数据在 bigBitmapData 中的位置
				_packageData.writeShort(rect.x);
				_packageData.writeShort(rect.y);
				
				//写入帧的宽高
				_packageData.writeShort(bmcData.width);
				_packageData.writeShort(bmcData.height);
				
				//写入帧的偏移坐标
				_packageData.writeShort(bmcData.offsetX + AppCommon.app.canvasGroup.itemX);
				_packageData.writeShort(bmcData.offsetY + AppCommon.app.canvasGroup.itemY);
			}
			
			packNextAni();
		}
		
		
		
		/**
		 * 打包完成
		 */
		private function packFinish():void
		{
			AppCommon.packing = false;
			AppCommon.app.canvasGroup.removeEventListener(CanvasGroup.ANI_LOAD_COMPLETE, aniLoadCompleteHandler);
			Toolbox.progressPanel.addProgress();
			
			//将 bigBitmap 裁切成最小矩形，保存成png文件
			var file:File = new File(Toolbox.docPath + "bigBitmap.png");
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(_bigBitmapData.encode(_maxRects.curRect, new PNGEncoderOptions()));
			fs.close();
			
			//压缩 bigBitmap
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
		
		
		/**
		 * 压缩 bigBitmap 完成
		 * @param event
		 */
		private function bigBitmapNP_exitHandler(event:NativeProcessExitEvent):void
		{
			Toolbox.progressPanel.addProgress();
			var pngPath:String = Toolbox.docPath + "bigBitmap";
			var cFile:File = new File(pngPath + "-fs8.png");
			if(cFile.exists) {
				cFile.copyTo(new File(pngPath + ".png"), true);
				cFile.deleteFile();
			}
			
			_bigBitmapLoader.load(new URLRequest(pngPath + ".png"));
		}
		
		
		/**
		 * 加载已经压缩好的 bigBitmap 完成
		 * @param event
		 */
		private function bigBitmapLoader_completeHandler(event:Event):void
		{
			Toolbox.progressPanel.addProgress();
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
			}
			
			if(_refreshConfig) {
				AniConfig.refreshComplete = refreshUIConfigComplete;
				AniConfig.refresh(false);
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
		 * 查看ld文件
		 * @param event
		 */
		private function lookLD_closeHandler(event:CloseEvent):void
		{
			if(event.detail == Alert.OK) {
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
			if(_packageData) {
				_packageData.clear();
				_packageData = null;
			}
		}
		//
	}
}