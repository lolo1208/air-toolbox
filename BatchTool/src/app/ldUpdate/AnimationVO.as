package app.ldUpdate
{
	import flash.geom.Point;

	public class AnimationVO
	{
		/**动画名称*/
		public var name:String;
		/**默认帧频*/
		public var fps:uint;
		/**帧偏移信息列表[{x, y}]*/
		public var offsetList:Vector.<Point> = new Vector.<Point>();
		
		/**动画总帧数*/
		public function get totalFrames():uint { return offsetList.length; }
	}
	
}