package app.ldUpdate
{
	import app.common.AppCommon;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
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
	
	import lolo.core.Constants;
	
	import toolbox.Toolbox;
	import toolbox.utils.MaxRects;

	/**
	 * 更新ui数据包
	 * @author LOLO
	 */
	public class UpdateUI
	{
		/**当前文件*/
		private static var _file:File;
		/**是否为有损压缩的数据包*/
		private static var _compressed:Boolean;
		
		private static var _list:Vector.<BitmapSpriteInfoVO>;
		private static var _vo:BitmapSpriteInfoVO;
		private static var _loader:Loader;
		
		/**正在打包的数据包*/
		private static var _packageData:ByteArray;
		/**正在打包的bigBitmap*/
		private static var _bigBitmapData:BitmapData;
		/**正在打包的矩形算法*/
		private static var _maxRects:MaxRects;
		/**用于有损压缩bigBitmap.png*/
		private static var _bigBitmapNP:NativeProcess;
		/**用于加载已经压缩好的bigBitmap*/
		private static var _bigBitmapLoader:URLLoader;
		
		
		
		
		public static function update(file:File, maxRects:uint=2048):void
		{
			if(_list == null)
			{
				_list = new Vector.<BitmapSpriteInfoVO>();
				
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
				
				_bigBitmapNP = new NativeProcess();
				_bigBitmapNP.addEventListener(NativeProcessExitEvent.EXIT, bigBitmapNP_exitHandler);
				
				_bigBitmapLoader = new URLLoader();
				_bigBitmapLoader.dataFormat = URLLoaderDataFormat.BINARY;
				_bigBitmapLoader.addEventListener(Event.COMPLETE, bigBitmapLoader_completeHandler);
			}
			
			_list.length = 0;
			_file = file;
			
			var bytes:ByteArray = file.data;
			bytes.position = 0;
			var flag:uint = bytes.readUnsignedByte();
			_compressed = (flag == Constants.FLAG_IDP);
			
			bytes.position = 5;
			var num:uint = bytes.readUnsignedShort();//包内包含的图像的数量
			for(var i:int=0; i < num; i++)
			{
				var vo:BitmapSpriteInfoVO = new BitmapSpriteInfoVO();
				vo.name = bytes.readUTF();//图像的源名称
				
				//图像在 bigBitmapData 中的位置，宽高
				bytes.readUnsignedShort();
				bytes.readUnsignedShort();
				bytes.readUnsignedShort();
				bytes.readUnsignedShort();
				
				vo.offsetX = bytes.readShort();//图像的X偏移
				vo.offsetY = bytes.readShort();//图像的Y偏移
				
				//是九切片图像
				var rect9:Rectangle;
				if(bytes.readUnsignedByte() == 1) {
					vo.scale9Grid = new Rectangle(
						bytes.readUnsignedShort(), bytes.readUnsignedShort(),
						bytes.readUnsignedShort(), bytes.readUnsignedShort()
					);
				}
				_list.push(vo);
			}
			
			_packageData = new ByteArray();
			_packageData.writeByte(_compressed ? Constants.FLAG_IDP : Constants.FLAG_LIDP);//写入类型标记
			_packageData.writeUnsignedInt(0);//写入图像数据的起始position，这里只是占位
			_packageData.writeShort(_list.length);//写入图片的数量
			
			_bigBitmapData = new BitmapData(maxRects, maxRects, true, 0);
			_maxRects = new MaxRects(_bigBitmapData, MaxRects.DEFAULT_METHOD);
			
			loadNext();
		}
		
		
		
		
		/**
		 * 加载下一张图像
		 */
		private static function loadNext():void
		{
			if(_list.length == 0)
			{
				loadAllComplete();
				return;
			}
			
			_vo = _list.shift();
			if(!(new File(path).exists))
			{
				AppCommon.app.ldUpdate.stop("图像 " + path + " 不存在！");
				return;
			}
			
			_loader.load(new URLRequest(path));
		}
		
		
		/**
		 * 加载图像完成
		 * @param event
		 */
		private static function loader_completeHandler(event:Event):void
		{
			var bd:BitmapData = (_loader.content as Bitmap).bitmapData;
			if(_vo.isScale9)
			{
				if(_vo.scale9Grid.x + _vo.scale9Grid.width > bd.width) {
					AppCommon.app.ldUpdate.stop("图像 " + path + " 的宽小于九切片的设定！");
					return;
				}
				if(_vo.scale9Grid.y + _vo.scale9Grid.height > bd.height) {
					AppCommon.app.ldUpdate.stop("图像 " + path + " 的高小于九切片的设定！");
					return;
				}
			}
			
			//将位图内容插入到bigBitmapData中
			var rect:Rectangle = _maxRects.insert(bd);
			
			//写入源名称[ 包名.名称 ]
			_packageData.writeUTF(_vo.name);
			
			//写入位图数据在 bigBitmapData 中的位置
			_packageData.writeShort(rect.x);
			_packageData.writeShort(rect.y);
			
			//写入宽高
			_packageData.writeShort(bd.width);
			_packageData.writeShort(bd.height);
			
			//写入偏移坐标
			_packageData.writeShort(_vo.offsetX);
			_packageData.writeShort(_vo.offsetY);
			
			//写入九切片信息
			if(_vo.isScale9) {
				_packageData.writeByte(1);
				_packageData.writeShort(_vo.scale9Grid.x);
				_packageData.writeShort(_vo.scale9Grid.y);
				_packageData.writeShort(_vo.scale9Grid.width);
				_packageData.writeShort(_vo.scale9Grid.height);
			}
			else {
				_packageData.writeByte(0);//不是九切片图像就写入字节 0
			}
			
			loadNext();
		}
		
		
		
		
		/**
		 * 加载所有图像完成
		 */
		private static function loadAllComplete():void
		{
			//将 bigBitmap 裁切成最小矩形，保存成png文件
			var file:File = new File(Toolbox.docPath + "bigBitmap.png");
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(_bigBitmapData.encode(_maxRects.curRect, new PNGEncoderOptions(_compressed)));
			fs.close();
			
			//压缩 bigBitmap
			if(_compressed)
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
		private static function bigBitmapNP_exitHandler(event:NativeProcessExitEvent):void
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
		private static function loadBigBitmap():void
		{
			_bigBitmapLoader.load(new URLRequest(Toolbox.docPath + "bigBitmap.png"));
		}
		
		
		/**
		 * 加载已经压缩好的 bigBitmap 完成
		 * @param event
		 */
		private static function bigBitmapLoader_completeHandler(event:Event):void
		{
			//写入图像数据的起始position
			_packageData.position = 1;
			_packageData.writeUnsignedInt(_packageData.length);
			
			//写入 bigBitmap 的数据
			var bytes:ByteArray = _bigBitmapLoader.data;
			_packageData.position = _packageData.length;
			_packageData.writeUnsignedInt(bytes.length);//写入数据的长度
			_packageData.writeBytes(bytes);
			
			
			//检查 bigBitmap.png 尺寸
			if((_maxRects.curRect.width + 100) > _bigBitmapData.width && (_maxRects.curRect.height + 100) > _bigBitmapData.height)
			{
				if(_bigBitmapData.width != 3000) {
					AppCommon.app.logger.addLog("bigBitmap的尺寸接近最大值：2000x2000，设置成3000x3000再次尝试更新...");
					update(_file, 3000);
					return;
				}
				else {
					AppCommon.app.ldUpdate.stop("bigBitmap的尺寸接近最大值：3000x3000，组合成大图时可能出错了！");
					return;
				}
			}
			else
			{
				//覆盖数据包文件
				var fs:FileStream = new FileStream();
				fs.open(_file, FileMode.WRITE);
				fs.writeBytes(_packageData);
				fs.close();
				
				AppCommon.app.logger.addLog("已更新：" + _file.nativePath);//写日志
				AppCommon.app.ldUpdate.updateNext(1);//继续打包
			}
		}
		
		
		
		
		
		/**
		 * 获取 _vo.name 对应的图像文件路径
		 * @return 
		 */
		private static function get path():String
		{
			var path:String = _vo.name.replace(/\./g, "/");
			path = Toolbox.resRootDir + "ui/" + path;
			if((new File( path + ".png").exists))
				return path + ".png";
			else
				return path + ".jpg";
		}
		//
	}
}