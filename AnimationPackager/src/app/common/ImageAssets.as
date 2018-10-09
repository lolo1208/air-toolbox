package app.common
{
	import flash.display.DisplayObject;

	public class ImageAssets
	{
		
		[Embed(source="assets/icons/file/folder.png")]
		public static var Folder:Class;
		[Embed(source="assets/icons/file/animation.png")]
		public static var Animation:Class;
		
		[Bindable]
		[Embed(source="assets/icons/buttons/focus.png")]
		public static var Focus:Class;
		
		[Bindable]
		[Embed(source="assets/icons/buttons/all.png")]
		public static var All:Class;
		
		
		
		public static function getInstance(name:String):DisplayObject
		{
			return new ImageAssets[name]();
		}
		//
	}
}