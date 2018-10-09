package app.common
{
	import flash.display.DisplayObject;

	public class ImageAssets
	{
		[Bindable]
		[Embed(source="assets/rightArrow.png")]
		public static var RightArrow:Class;
		
		
		[Bindable]
		[Embed(source="assets/close.png")]
		public static var Close:Class;
		
		
		
		
		public static function getInstance(name:String):DisplayObject
		{
			return new ImageAssets[name]();
		}
		//
	}
}