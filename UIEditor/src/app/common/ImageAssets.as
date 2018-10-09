package app.common
{
	import flash.display.DisplayObject;

	public class ImageAssets
	{
		
		[Bindable]
		[Embed(source="assets/icons/groups/animation.png")]
		public static var Animation:Class;
		
		[Bindable]
		[Embed(source="assets/icons/groups/ui.png")]
		public static var UI:Class;
		
		[Bindable]
		[Embed(source="assets/icons/groups/component.png")]
		public static var Component:Class;
		
		[Bindable]
		[Embed(source="assets/icons/groups/skin.png")]
		public static var Skin:Class;
		
		[Bindable]
		[Embed(source="assets/icons/groups/config.png")]
		public static var Config:Class;
		
		[Bindable]
		[Embed(source="assets/icons/groups/layer.png")]
		public static var Layer:Class;
		
		[Bindable]
		[Embed(source="assets/icons/groups/prop.png")]
		public static var Prop:Class;
		
		[Bindable]
		[Embed(source="assets/icons/groups/style.png")]
		public static var Style:Class;
		
		
		
		
		[Bindable]
		[Embed(source="assets/icons/buttons/add.png")]
		public static var Add:Class;
		
		[Bindable]
		[Embed(source="assets/icons/buttons/remove.png")]
		public static var Remove:Class;
		
		[Bindable]
		[Embed(source="assets/icons/buttons/min.png")]
		public static var Min:Class;
		
		[Bindable]
		[Embed(source="assets/icons/buttons/close.png")]
		public static var Close:Class;
		
		[Bindable]
		[Embed(source="assets/icons/buttons/refresh.png")]
		public static var Refresh:Class;
		
		[Bindable]
		[Embed(source="assets/icons/buttons/tool.png")]
		public static var Tool:Class;
		
		[Bindable]
		[Embed(source="assets/icons/buttons/focus.png")]
		public static var Focus:Class;
		
		[Bindable]
		[Embed(source="assets/icons/buttons/arrow.png")]
		public static var Arrow:Class;
		
		[Bindable]
		[Embed(source="assets/icons/buttons/hand.png")]
		public static var Hand:Class;
		
		[Bindable]
		[Embed(source="assets/icons/buttons/play.png")]
		public static var Play:Class;
		
		[Bindable]
		[Embed(source="assets/icons/buttons/stop.png")]
		public static var Stop:Class;
		
		
		
		
		[Bindable]
		[Embed(source="assets/icons/style/left.png")]
		public static var Style_Left:Class;
		
		[Bindable]
		[Embed(source="assets/icons/style/center.png")]
		public static var Style_Center:Class;
		
		[Bindable]
		[Embed(source="assets/icons/style/right.png")]
		public static var Style_Right:Class;
		
		[Bindable]
		[Embed(source="assets/icons/style/bold.png")]
		public static var Style_Bold:Class;
		
		[Bindable]
		[Embed(source="assets/icons/style/underline.png")]
		public static var Style_Underline:Class;
		
		
		
		
		[Bindable]
		[Embed(source="assets/icons/file/folder.png")]
		public static var Folder:Class;
		
		[Bindable]
		[Embed(source="assets/icons/file/doc.png")]
		public static var Doc:Class;
		
		
		
		
		[Bindable]
		[Embed(source="assets/icons/components/label.png")]
		public static var C_Label:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/baseButton.png")]
		public static var C_BaseButton:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/button.png")]
		public static var C_Button:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/imageButton.png")]
		public static var C_ImageButton:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/imageLoader.png")]
		public static var C_ImageLoader:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/artText.png")]
		public static var C_ArtText:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/modalBackground.png")]
		public static var C_ModalBackground:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/checkBox.png")]
		public static var C_CheckBox:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/radioButton.png")]
		public static var C_RadioButton:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/itemGroup.png")]
		public static var C_ItemGroup:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/sprite.png")]
		public static var C_Sprite:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/displayObject.png")]
		public static var C_DisplayObject:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/inputText.png")]
		public static var C_InputText:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/page.png")]
		public static var C_Page:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/scrollBar.png")]
		public static var C_ScrollBar:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/list.png")]
		public static var C_List:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/pageList.png")]
		public static var C_PageList:Class;
		
		[Bindable]
		[Embed(source="assets/icons/components/scrollList.png")]
		public static var C_ScrollList:Class;
		
		
		
		[Bindable]
		[Embed(source="assets/icons/layers/eye.png")]
		public static var Eye:Class;
		
		[Bindable]
		[Embed(source="assets/icons/layers/lock.png")]
		public static var Lock:Class;
		
		[Bindable]
		[Embed(source="assets/icons/layers/ignore.png")]
		public static var Ignore:Class;
		
		
		
		[Bindable]
		[Embed(source="assets/icons/saved.png")]
		public static var Saved:Class;
		
		
		
		
		
		
		public static function getInstance(name:String):DisplayObject
		{
			return new ImageAssets[name]();
		}
		//
		//
	}
}