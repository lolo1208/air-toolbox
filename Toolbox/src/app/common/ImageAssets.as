package app.common
{
	import flash.display.DisplayObject;

	public class ImageAssets
	{
		/*
		[Embed(source="assets/icons/refresh.png")]
		public static var icon_refresh:Class;
		*/
		
		public static function getInstance(name:String):DisplayObject
		{
			return new ImageAssets[name]();
		}
		//
	}
}