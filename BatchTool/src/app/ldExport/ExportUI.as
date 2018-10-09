package app.ldExport
{
	import app.common.AppCommon;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import toolbox.Toolbox;

	/**
	 * 导出UI图像
	 * @author LOLO
	 */
	public class ExportUI
	{
		/**当前文件*/
		private static var _file:File;
		/**加载图像*/
		private static var _loader:Loader;
		
		
		
		public static function export(file:File):void
		{
			_file = file;
			
			//加载图像字节数据
			var bytes:ByteArray = _file.data;
			bytes.readUnsignedByte();//flag
			var pos:uint = bytes.readUnsignedInt();
			bytes.position = pos;
			var len:uint = bytes.readUnsignedInt();
			var bigBitmapBytes:ByteArray = new ByteArray();
			bytes.readBytes(bigBitmapBytes, 0, len);
			
			if(_loader == null) {
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			}
			_loader.loadBytes(bigBitmapBytes);
		}
		
		
		private static function loader_completeHandler(event:Event):void
		{
			var bigBitmapData:BitmapData = (_loader.content as Bitmap).bitmapData;
			var bytes:ByteArray = _file.data;
			_loader.unload();
			
			
			var i:int, num:int;
			var sn:String, x:int, y:int, w:int, h:int;
			var p:Point = new Point();
			var rect:Rectangle = new Rectangle();
			var bd:BitmapData;
			var file:File = new File();
			var fs:FileStream = new FileStream();
			
			bytes.position = 5;
			num = bytes.readUnsignedShort();//包内包含的图像的数量
			for(i = 0; i < num; i++)
			{
				sn = bytes.readUTF();//图像的源名称
				
				//图像在 bigBitmapData 中的位置，宽高
				x = bytes.readUnsignedShort();
				y = bytes.readUnsignedShort();
				w = bytes.readUnsignedShort();
				h = bytes.readUnsignedShort();
				
				bytes.readShort();//图像的X偏移
				bytes.readShort();//图像的Y偏移
				
				//是九切片图像
				if(bytes.readUnsignedByte() == 1) {
					bytes.readUnsignedShort();//x
					bytes.readUnsignedShort();//y
					bytes.readUnsignedShort();//width
					bytes.readUnsignedShort();//height
				}
				
				//得到图像
				rect.setTo(x, y, w, h);
				bd = new BitmapData(rect.width, rect.height, true, 0);
				bd.copyPixels(bigBitmapData, rect, p);
				
				//保存成文件
				file.nativePath = Toolbox.docPath + "ui/" + sn + ".png";
				fs.open(file, FileMode.WRITE);
				fs.writeBytes(bd.encode(bd.rect, new PNGEncoderOptions()));
				fs.close();
			}
			bytes.clear();
			
			//导出下个文件
			AppCommon.app.ldExport.exportNext(_file);
		}
		//
	}
}