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
	
	import lolo.utils.StringUtil;
	
	import toolbox.Toolbox;

	/**
	 * 导出动画
	 * @author LOLO
	 */
	public class ExportAni
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
			
			
			var i:int, n:int, j:int, dir:String;
			var num:int, avo:AnimationVO, fvo:FrameVO;
			var ix:int, iy:int, ox:int, oy:int, w:int, h:int, nw:int, nh:int, nx:int, ny:int;
			var aList:Array = [];//文件内动画信息列表
			var fList:Array = [];//文件内所有帧信息列表
			
			bytes.position = 5;
			num = bytes.readUnsignedByte();//动画数量
			j = 0;
			for(i = 0; i < num; i++)
			{
				avo = new AnimationVO();
				avo.sn = bytes.readUTF();//动画名称
				avo.tf = bytes.readUnsignedShort();//动画总帧数
				bytes.readUnsignedByte();//默认帧频
				aList.push(avo);
				
				for(n = 0; n < avo.tf; n++)
				{
					fvo = new FrameVO();
					fvo.i = j; j++;
					fvo.x = bytes.readShort();//在 bigBitmapData 中的位置
					fvo.y = bytes.readShort();
					fvo.w = bytes.readUnsignedShort();//帧宽高
					fvo.h = bytes.readUnsignedShort();
					fvo.ox = bytes.readShort();//帧偏移
					fvo.oy = bytes.readShort();
					fList.push(fvo);
				}
			}
			bytes.clear();
			
			
			//偏移范围（最大偏移值）。ox/oy
			fList.sortOn("ox", Array.NUMERIC);
			ix = fList[fList.length - 1].ox;
			ox = ix - fList[0].ox;
			fList.sortOn("oy", Array.NUMERIC);
			iy = fList[fList.length - 1].oy;
			oy = iy - fList[0].oy;
			
			//最大宽高。w/h
			fList.sortOn("w", Array.NUMERIC);
			w = fList[fList.length - 1].w;
			fList.sortOn("h", Array.NUMERIC);
			h = fList[fList.length - 1].h;
			
			//宽高加上偏移，再多加 50 - 150的空白。nw/nh
			nw = int(Math.round((w + ox) / 100) + 1) * 100;
			nh = int(Math.round((h + oy) / 100) + 1) * 100;
			
			//空白导致的整体偏移。nx/ny
			nx = nw - w >> 1;
			ny = nh - h >> 1;
			
			//确保居中，减去整体偏移
			nx += ox / 2 - ix;
			ny += oy / 2 - iy;
			
			
			//导出图像
			var p:Point = new Point();
			var rect:Rectangle = new Rectangle();
			var file:File = new File();
			var fs:FileStream = new FileStream();
			var bd:BitmapData;
			
			fList.sortOn("i", Array.NUMERIC);
			j = 0;
			for(i = 0; i < aList.length; i++)
			{
				avo = aList[i];
				dir = Toolbox.docPath + "ani/" + avo.sn + "/";
				try { new File(dir).deleteDirectory(true); }
				catch(error:Error) {}
				
				for(n = 0; n < avo.tf; n++)
				{
					fvo = fList[j]; j++;
					
					rect.setTo(fvo.x, fvo.y, fvo.w, fvo.h);
					p.setTo(nx + fvo.ox, ny + fvo.oy);
					bd = new BitmapData(nw, nh, true, 0);
					bd.copyPixels(bigBitmapData, rect, p);
					
					file.nativePath = dir + StringUtil.leadingZero(n + 1, 3) + ".png";
					fs.open(file, FileMode.WRITE);
					fs.writeBytes(bd.encode(bd.rect, new PNGEncoderOptions()));
					fs.close();
				}
			}
			
			//导出下个文件
			AppCommon.app.ldExport.exportNext(_file);
		}
		
		
		
		//
	}
}