package toolbox.utils
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import lolo.utils.MaxRectsBinPack;
	
	import mx.collections.ArrayList;
	
	import toolbox.Toolbox;

	/**
	 * 矩形算法
	 * @author LOLO
	 */
	public class MaxRects
	{
		public static const METHOD_LIST:ArrayList = new ArrayList([
			{ label:"Best Short Side Fit", value:0 },
			{ label:"Best Long Side Fit", value:1 },
			{ label:"Best Area Fit", value:2 },
			{ label:"Bottom Left Rule", value:3 },
			{ label:"Contact Point Rule", value:4 }
		]);
		public static const DEFAULT_METHOD:uint = 3;
		
		public static const ROTATION_LIST:ArrayList = new ArrayList([
			{ label:"true", value:true },
			{ label:"false", value:false }
		]);
		
		
		private var _rects:MaxRectsBinPack;
		private var _bigBitmapData:BitmapData;
		private var _method:uint;
		
		public var curRect:Rectangle;
		
		
		
		
		public function MaxRects(bigBitmapData:BitmapData, method:uint)
		{
			_bigBitmapData = bigBitmapData;
			_rects = new MaxRectsBinPack(_bigBitmapData.width, _bigBitmapData.height, false);
			_method = method;
			curRect = new Rectangle();
		}
		
		
		public function insert(bitmapData:BitmapData):Rectangle
		{
			var gap:uint = Toolbox.isASProject ? 0 : 1;
			var rect:Rectangle = _rects.insert(
				bitmapData.width + gap,
				bitmapData.height + gap,
				_method
			);
			rect.width = bitmapData.width;
			rect.height = bitmapData.height;
			
			/*
			//旋转
			if(info.rotated) {
				var bitmap:Bitmap = new Bitmap(bitmapData);
				var bmd:BitmapData = new BitmapData(bitmap.height, bitmap.width, true, 0);
				var matrix:Matrix = bitmap.transform.matrix;
				var centerX:Number = bitmap.width / 2;
				var centerY:Number = bitmap.height / 2;
				matrix.translate(-centerX, -centerY);//注册点在中心
				matrix.rotate(90 * (Math.PI / 180));
				matrix.translate(centerY, centerX);//注册点恢复到左上
				bmd.draw(bitmap, matrix);
				
				bitmapData = bmd;
			}
			*/
			
			_bigBitmapData.copyPixels(bitmapData, bitmapData.rect, new Point(rect.x, rect.y));
			
			curRect.setTo(0, 0,
				Math.max(curRect.width, rect.x + rect.width),
				Math.max(curRect.height, rect.y + rect.height)
			);
			
			return rect;
		}
		
		
		//
	}
}