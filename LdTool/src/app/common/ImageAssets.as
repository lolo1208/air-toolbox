package app.common
{
	import flash.display.DisplayObject;

	public class ImageAssets
	{
		
		[Bindable]
		[Embed(source="assets/add.png")]
		public static var Add:Class;
		[Bindable]
		[Embed(source="assets/remove.png")]
		public static var Remove:Class;
		[Bindable]
		[Embed(source="assets/all.png")]
		public static var All:Class;
		[Bindable]
		[Embed(source="assets/clear.png")]
		public static var Clear:Class;
		[Bindable]
		[Embed(source="assets/close.png")]
		public static var Close:Class;
		
		
		[Bindable]
		[Embed(source="assets/ui.png")]
		public static var UI:Class;
		[Bindable]
		[Embed(source="assets/animation.png")]
		public static var Animation:Class;
		
		
		public static function getInstance(name:String):DisplayObject
		{
			return new ImageAssets[name]();
		}
		//
	}
}