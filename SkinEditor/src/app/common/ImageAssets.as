package app.common
{
	import flash.display.DisplayObject;

	public class ImageAssets
	{
		
		[Bindable]
		[Embed(source="assets/focus.png")]
		public static var Focus:Class;
		
		
		[Bindable]
		[Embed(source="assets/add.png")]
		public static var Add:Class;
		
		[Bindable]
		[Embed(source="assets/remove.png")]
		public static var Remove:Class;
		
		[Bindable]
		[Embed(source="assets/close.png")]
		public static var Close:Class;
		
		
		[Bindable]
		[Embed(source="assets/saved.png")]
		public static var Saved:Class;
		
		
		[Bindable]
		[Embed(source="assets/error.png")]
		public static var Error:Class;
		
		
		public static function getInstance(name:String):DisplayObject
		{
			return new ImageAssets[name]();
		}
		//
	}
}