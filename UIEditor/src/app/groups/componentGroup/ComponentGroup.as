package app.groups.componentGroup
{
	import app.common.ImageAssets;
	import app.common.LayerConstants;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.List;
	import spark.components.NavigatorContent;
	
	import toolbox.Toolbox;
	
	/**
	 * 组件列表容器
	 * @author LOLO
	 */
	public class ComponentGroup extends NavigatorContent
	{
		public var componentList:List;
		
		
		public function ComponentGroup()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
		}
		
		
		public function refresh():void
		{
			componentList.dataProvider = new ArrayList();
			addItem(LayerConstants.LABEL, ImageAssets.C_Label);
			addItem(LayerConstants.BUTTON, ImageAssets.C_Button);
			addItem(LayerConstants.IMAGE_BUTTON, ImageAssets.C_ImageButton);
			addItem(LayerConstants.BASE_BUTTON, ImageAssets.C_BaseButton);
			addItem(LayerConstants.IMAGE_LOADER, ImageAssets.C_ImageLoader);
			addItem(LayerConstants.ART_TEXT, ImageAssets.C_ArtText);
			addItem(LayerConstants.DISPLAY_OBJECT, ImageAssets.C_DisplayObject);
			addItem(LayerConstants.CHECK_BOX, ImageAssets.C_CheckBox);
			addItem(LayerConstants.RADIO_BUTTON, ImageAssets.C_RadioButton);
			addItem(LayerConstants.INPUT_TEXT, ImageAssets.C_InputText);
			addItem(LayerConstants.NUMBER_TEXT, ImageAssets.C_Label);
			addItem(LayerConstants.SPRITE, ImageAssets.C_Sprite);
			addItem(LayerConstants.ITEM_GROUP, ImageAssets.C_ItemGroup);
			addItem(LayerConstants.LIST, ImageAssets.C_List);
			addItem(LayerConstants.PAGE_LIST, ImageAssets.C_PageList);
			addItem(LayerConstants.SCROLL_LIST, ImageAssets.C_ScrollList);
			
			addItem(Toolbox.isASProject
				? LayerConstants.SCROLL_BAR
				: LayerConstants.TOUCH_SCROLL_BAR,
				ImageAssets.C_ScrollBar);
			
			addItem(LayerConstants.PAGE, ImageAssets.C_Page);
			addItem(LayerConstants.MODAL_BACKGROUND, ImageAssets.C_ModalBackground);
		}
		
		
		
		private function addItem(name:String, icon:Class):void
		{
			componentList.dataProvider.addItem({ isComponent:true, name:name, icon:icon });
		}
		
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			componentList.width = this.width - 2;
			componentList.height = this.height - 1;
		}
		
		
		//
	}
}