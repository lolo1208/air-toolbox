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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import lolo.core.Constants;
	import lolo.utils.DisplayUtil;
	
	import toolbox.Toolbox;
	import toolbox.utils.MaxRects;

	/**
	 * 更新动画数据包
	 * @author LOLO
	 */
	public class UpdateAni
	{
		/**当前文件*/
		private static var _file:File;
		
		private static var _list:Vector.<AnimationVO>;
		private static var _vo:AnimationVO;
		private static var _frameFiles:Array;
		private static var _frameIndex:int;
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
				_list = new Vector.<AnimationVO>();
				_frameFiles = [];
				
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
			bytes.position = 5;
			var num:uint = bytes.readUnsignedByte();//动画数量
			for(var i:int=0; i < num; i++)
			{
				var vo:AnimationVO = new AnimationVO
				vo.name = bytes.readUTF();//动画名称
				var totalFrames:uint = bytes.readUnsignedShort();//动画总帧数
				vo.fps = bytes.readUnsignedByte();//默认帧频
				for(var n:int=0; n < totalFrames; n++)
				{
					bytes.readShort();//在 bigBitmapData 中的位置
					bytes.readShort();
					bytes.readUnsignedShort();//帧宽高
					bytes.readUnsignedShort();
					var offsets:Point = new Point();
					offsets.x = bytes.readShort();//帧偏移
					offsets.y = bytes.readShort();
					
					vo.offsetList.push(offsets);
				}
				
				_list.push(vo);
			}
			
			
			_packageData = new ByteArray();
			_packageData.writeByte(Constants.FLAG_AD);//写入类型标记
			_packageData.writeUnsignedInt(0);//写入图像数据的起始position，这里只是占位
			_packageData.writeByte(_list.length);//写入动画的数量
			
			_bigBitmapData = new BitmapData(maxRects, maxRects, true, 0);
			_maxRects = new MaxRects(_bigBitmapData, MaxRects.DEFAULT_METHOD);
			
			loadNextAni();
		}
		
		
		
		/**
		 * 加载下一个动画
		 */
		private static function loadNextAni():void
		{
			if(_list.length == 0)
			{
				loadAllComplete();
				return;
			}
			
			_vo = _list.shift();
			var dir:File = new File(path);
			if(!dir.exists)
			{
				AppCommon.app.ldUpdate.stop("动画 " + _vo.name + " 不存在！");
				return;
			}
			
			var files:Array = dir.getDirectoryListing();
			_frameFiles.length = 0;
			for(var i:int = 0; i < files.length; i++) {
				if((files[i] as File).extension == "png") _frameFiles.push(files[i]);
			}
			
			if(_frameFiles.length != _vo.totalFrames)
			{
				AppCommon.app.ldUpdate.stop("动画 " + _vo.name + " 的帧数与数据包中的帧数不一致！");
				return;
			}
			
			_packageData.writeUTF(_vo.name);//写入动画的名称[ 包名.名称 ]
			_packageData.writeShort(_vo.totalFrames);//写入动画帧数
			_packageData.writeByte(_vo.fps);//写入默认帧频
			
			_frameIndex = -1;
			loadNextFrame();//开始加载帧图像数据
		}
		
		
		
		/**
		 * 加载下一帧图像
		 */
		private static function loadNextFrame():void
		{
			if(_frameFiles.length == 0)
			{
				loadNextAni();
				return;
			}
			
			_frameIndex++;
			var file:File = _frameFiles.shift();
			_loader.load(new URLRequest(file.nativePath));
		}
		
		private static function loader_completeHandler(event:Event):void
		{
			var bitmapData:BitmapData = (_loader.content as Bitmap).bitmapData;
			
			//得到图片的最小不透明区域
			var rect:Rectangle = DisplayUtil.getOpaqueRect(bitmapData);
			var bytes:ByteArray = bitmapData.getPixels(rect);
			bytes.position = 0;
			var bd:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			bd.setPixels(new Rectangle(0, 0, rect.width, rect.height), bytes);
			
			//将位图内容插入到bigBitmapData中
			rect = _maxRects.insert(bd);
			
			//写入帧位图数据在 bigBitmapData 中的位置
			_packageData.writeShort(rect.x);
			_packageData.writeShort(rect.y);
			
			//写入帧的宽高
			_packageData.writeShort(bd.width);
			_packageData.writeShort(bd.height);
			
			//写入帧的偏移坐标
			var offsets:Point = _vo.offsetList[_frameIndex];
			_packageData.writeShort(offsets.x);
			_packageData.writeShort(offsets.y);
			
			loadNextFrame();
		}
		
		
		
		
		/**
		 * 加载所有动画完成
		 */
		private static function loadAllComplete():void
		{
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
		private static function bigBitmapNP_exitHandler(event:NativeProcessExitEvent):void
		{
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
				AppCommon.app.ldUpdate.updateNext(2);//继续打包
			}
		}
		
		
		
		
		/**
		 * 获取 _vo.name 对应的图像文件路径
		 * @return 
		 */
		private static function get path():String
		{
			var path:String = _vo.name.replace(/\./g, "/");
			return Toolbox.resRootDir + "ani/" + path;
		}
		
		//
	}
}