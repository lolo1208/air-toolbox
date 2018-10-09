package app.groups.styleGroup
{
	import app.common.AppCommon;
	import app.layers.Layer;
	import app.utils.LayerUtil;
	
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.NavigatorContent;
	import spark.components.Scroller;
	import spark.components.VGroup;
	
	/**
	 * 样式列表容器
	 * @author LOLO
	 */
	public class StyleGroup extends NavigatorContent
	{
		public var scroller:Scroller;
		public var listVG:VGroup;
		
		public var headG:HeadGroup;
		
		public var textFieldG:TextFieldGroup;
		public var labelG:LabelGroup;
		public var numberTextG:NumberTextGroup;
		
		public var hitAreaPaddingTextG:HitAreaPaddingTextGroup;
		public var autoSizeG:AutoSizeGroup;
		public var paddingG:PaddingGroup;
		public var buttonLabelG:ButtonLabelGroup;
		public var imagePrefixG:ImagePrefixGroup;
		
		public var scrollBarG:ScrollBarGroup;
		
		
		
		
		
		public function StyleGroup()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			listVG.removeAllElements();
		}
		
		
		protected function addedToStageHandler(event:Event):void
		{
			
		}
		
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			scroller.width = this.width;
			scroller.height = this.height - 1;
		}
		
		
		/**
		 * 更新显示内容
		 */
		public function update():void
		{
			listVG.removeAllElements();
			if(selectedLayer == null) return;
			
			if(LayerUtil.isBaseTextField()
				|| LayerUtil.isBaseButton()
				|| LayerUtil.isScrollBar()
			) addToList(headG);
			
			if(LayerUtil.isBaseTextField()) addToList(textFieldG);
			if(LayerUtil.isLabel()) addToList(labelG);
			if(LayerUtil.isNumberText()) addToList(numberTextG);
			
			if(LayerUtil.isBaseButton()) addToList(hitAreaPaddingTextG);
			
			if(LayerUtil.isButton())
				addToList(autoSizeG, paddingG, buttonLabelG);
			
			if(LayerUtil.isImageButton())
				addToList(autoSizeG, paddingG, imagePrefixG);
			
			if(LayerUtil.isScrollBar()) addToList(scrollBarG);
			
		}
		
		
		
		
		/**
		 * 将 group 添加到 listVG
		 * @param args
		 */
		private function addToList(...args):void
		{
			while(args.length > 0) {
				var group:UIComponent = args.shift();
				if(group.parent != null) continue;
				listVG.addElement(group);
				group["update"]();
			}
		}
		
		
		
		
		
		/**
		 * 当前选中的图层
		 */
		private function get selectedLayer():Layer { return AppCommon.controller.selectedLayer; }
		//
	}
}