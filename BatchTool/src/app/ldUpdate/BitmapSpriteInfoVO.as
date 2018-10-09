package app.ldUpdate
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	public class BitmapSpriteInfoVO
	{
		/**图像的源名称*/
		public var name:String;
		
		/**图像的X偏移*/
		public var offsetX:int;
		/**图像的Y偏移*/
		public var offsetY:int;
		
		/**九切片信息*/
		public var scale9Grid:Rectangle;
		/**是否为九切片图像*/
		public function get isScale9():Boolean { return scale9Grid != null; }
		//
	}
}