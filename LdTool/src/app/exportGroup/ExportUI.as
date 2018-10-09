package app.exportGroup
{
	import app.common.AppCommon;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.utils.StringUtil;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import spark.components.CheckBox;
	import spark.components.DropDownList;
	import spark.components.TextInput;
	
	import toolbox.Toolbox;
	import toolbox.utils.MaxRects;

	
	/**
	 * 导出UI图像数据包
	 * @author LOLO
	 */
	public class ExportUI
	{
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
		
		
		
		
		public function ExportUI()
		{
			_bigBitmapNP = new NativeProcess();
			_bigBitmapNP.addEventListener(NativeProcessExitEvent.EXIT, bigBitmapNP_exitHandler);
			
			_bigBitmapLoader = new URLLoader();
			_bigBitmapLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_bigBitmapLoader.addEventListener(Event.COMPLETE, bigBitmapLoader_completeHandler);
		}
		
		
		
		
		/**
		 * 打包
		 */
		public function pack():void
		{
			_packageData = new ByteArray();
			_packageData.writeByte(compressCB.selected ? Constants.FLAG_IDP : Constants.FLAG_LIDP);//写入类型标记
			_packageData.writeUnsignedInt(0);//写入图像数据的起始position，这里只是占位
			_packageData.writeShort(listData.length);//写入图片的数量
			
			var maxW:int = int(mrwText.text);
			var maxH:int = int(mrhText.text);
			_bigBitmapData = new BitmapData(maxW, maxH, true, 0);
			_maxRects = new MaxRects(_bigBitmapData, mrmDDL.selectedItem.value);
			
			Toolbox.progressPanel.show(listData.length + 2);
			_index = -1;
			packNextImage();
		}
		
		
		
		
		
		/**
		 * 打包下一张图片
		 */
		private function packNextImage():void
		{
			Common.stage.addEventListener(Event.ENTER_FRAME, doPackNextImage);
		}
		
		private function doPackNextImage(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, doPackNextImage);
			Toolbox.progressPanel.addProgress();
			_index++;
			
			//打包完毕
			if(_index == listData.length) {
				packFinish();
				return;
			}
			
			var item:Object = listData.getItemAt(_index);
			var info:Object = item.info;
			
			//将位图内容插入到bigBitmapData中
			var bitmapData:BitmapData = item.bd;
			var rect:Rectangle = _maxRects.insert(bitmapData);
			
			//写入源名称[ 包名.名称 ]
			_packageData.writeUTF(item.name);
			
			//写入位图数据在 bigBitmapData 中的位置
			_packageData.writeShort(rect.x);
			_packageData.writeShort(rect.y);
			
			//写入宽高
			_packageData.writeShort(bitmapData.width);
			_packageData.writeShort(bitmapData.height);
			
			//写入偏移坐标
			_packageData.writeShort(info.offsetX);
			_packageData.writeShort(info.offsetY);
			
			//写入九切片信息
			var s9Rect:Rectangle = info.scale9Grid;
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
			Toolbox.progressPanel.addProgress();
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
			Toolbox.progressPanel.addProgress();
			
			//写入图像数据的起始position
			_packageData.position = 1;
			_packageData.writeUnsignedInt(_packageData.length);
			
			//写入 bigBitmap 的数据
			var bytes:ByteArray = _bigBitmapLoader.data;
			_packageData.position = _packageData.length;
			_packageData.writeUnsignedInt(bytes.length);//写入数据的长度
			_packageData.writeBytes(bytes);
			
			//保存文件
			var file:File = new File(Toolbox.docPath + "ui." + Constants.EXTENSION_LD);
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(_packageData);
			fs.close();
			
			checkMaxRects();
		}
		
		private function checkMaxRects():void
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
			Alert.show(AppCommon.app.exportGroup.FINISH_TIPS, "提示", 4, null, lookLD_closeHandler);
		}
		
		
		/**
		 * 打包完毕，查看目录
		 * @param event
		 */
		private function lookLD_closeHandler(event:CloseEvent):void
		{
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var args:Vector.<String> = new Vector.<String>();
			args.push(StringUtil.slashToBackslash(Toolbox.docPath.substr(0, Toolbox.docPath.length - 1)));
			
			info.executable = new File(Toolbox.explorerPath);
			info.arguments = args;
			new NativeProcess().start(info);
		}
		
		
		
		
		
		public function get listData():ArrayList { return AppCommon.app.exportGroup.listData; }
		
		public function get compressCB():CheckBox { return AppCommon.app.exportGroup.compressCB };
		
		public function get mrwText():TextInput { return AppCommon.app.exportGroup.mrwText; }
		
		public function get mrhText():TextInput { return AppCommon.app.exportGroup.mrhText; }
		
		public function get mrmDDL():DropDownList { return AppCommon.app.exportGroup.mrmDDL; }
		
		
		//
	}
}