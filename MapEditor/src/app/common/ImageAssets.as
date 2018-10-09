package app.common
{
	import flash.display.DisplayObject;

	public class ImageAssets
	{
		
		[Bindable]
		[Embed(source="assets/arrow.png")]
		public static var Arrow:Class;
		
		[Bindable]
		[Embed(source="assets/hand.png")]
		public static var Hand:Class;
		
		[Bindable]
		[Embed(source="assets/imageFocus.png")]
		public static var ImageFocus:Class;
		
		[Bindable]
		[Embed(source="assets/layer.png")]
		public static var Layer:Class;
		
		[Bindable]
		[Embed(source="assets/tile.png")]
		public static var Tile:Class;
		
		[Bindable]
		[Embed(source="assets/properties.png")]
		public static var Properties:Class;
		
		
		[Bindable]
		[Embed(source="assets/add.png")]
		public static var Add:Class;
		
		[Bindable]
		[Embed(source="assets/remove.png")]
		public static var Remove:Class;
		
		
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