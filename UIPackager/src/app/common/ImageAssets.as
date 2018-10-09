package app.common
{
	import flash.display.DisplayObject;

	public class ImageAssets
	{
		
		[Embed(source="assets/icons/file/folder.png")]
		public static var folder:Class;
		[Embed(source="assets/icons/file/png.png")]
		public static var png:Class;
		[Embed(source="assets/icons/file/jpg.png")]
		public static var jpg:Class;
		
		
		[Bindable]
		[Embed(source="assets/icons/buttons/cut.png")]
		public static var Cut:Class;
		[Bindable]
		[Embed(source="assets/icons/buttons/focus.png")]
		public static var Focus:Class;
		
		
		public static function getInstance(name:String):DisplayObject
		{
			return new ImageAssets[name]();
		}
		//
	}
}