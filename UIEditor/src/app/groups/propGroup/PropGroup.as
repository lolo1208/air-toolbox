package app.groups.propGroup
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
	 * 属性列表容器
	 * @author LOLO
	 */
	public class PropGroup extends NavigatorContent
	{
		public var propsScroller:Scroller;
		public var listVG:VGroup;
		
		public var common1G:Common1Group;
		public var common2G:Common2Group;
		public var common3G:Common3Group;
		
		public var containerG:ContainerGroup;
		public var textFieldG:TextFieldGroup;
		public var animationG:AnimationGroup;
		public var imageLoaderG:ImageLoaderGroup;
		public var listG:ListGroup;
		public var scrollBarG:ScrollBarGroup;
		public var touchScrollBarG:TouchScrollBarGroup;
		public var pageG:PageGroup;
		
		public var otherPropG:OtherPropGroup;
		public var varsG:VarsGroup;
		public var textG:TextGroup;
		public var buttonLabelG:ButtonLabelGroup;
		public var artTextG:ArtTextGroup;
		public var definitionG:DefinitionGroup;
		public var stageLayoutG:StageLayoutGroup;
		
		
		
		public function PropGroup()
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
			propsScroller.width = this.width;
			propsScroller.height = this.height - 1;
		}
		
		
		
		
		/**
		 * 更新显示内容
		 */
		public function update():void
		{
			listVG.removeAllElements();
			if(selectedLayer == null) return;
			
			if(LayerUtil.isContainer()) addToList(containerG);
			
			addToList(common1G);
			
			
			if(LayerUtil.isAnimation()
				|| LayerUtil.isBtimapSprite()
				|| LayerUtil.isModalBackground()
				|| LayerUtil.isBaseButton()
				|| LayerUtil.isItemGroup()
				|| LayerUtil.isList()
				|| LayerUtil.isPage()
				|| LayerUtil.isScrollBar()
			) addToList(common2G);
			
			
			if(LayerUtil.isAnimation()) {
				update_SX_SY_W_H(true, false);
				addToList(animationG);
			}
			else
				LayerUtil.isContainer()
					? update_SX_SY_W_H(true, false)
					: update_SX_SY_W_H(false, !LayerUtil.isModalBackground());
			
			
			//不是第一个容器（*.xml）
			if(!(AppCommon.canvas.containerTB.selectedIndex == 0
				&& selectedLayer == AppCommon.controller.currentContainerLayer))
				addToList(common3G);
			
			
			if(LayerUtil.isBaseTextField()) addToList(textFieldG, textG);
			
			if(LayerUtil.isButton()) addToList(buttonLabelG);
			
			if(LayerUtil.isImageLoader()) addToList(imageLoaderG);
			
			if(LayerUtil.isArtText()) addToList(artTextG);
			
			if(LayerUtil.isDisplayObject()) addToList(definitionG);
			
			if(LayerUtil.isList()) {
				update_SX_SY_W_H(false, false);
				addToList(listG);
			}
			
			if(LayerUtil.isPage()) {
				update_SX_SY_W_H(false, false);
				addToList(pageG);
			}
			
			if(LayerUtil.isScrollBar()) {
				update_SX_SY_W_H(false, false);
				addToList(scrollBarG);
			}
			if(LayerUtil.isTouchScrollBar()) {
				addToList(touchScrollBarG);
			}
			
			addToList(otherPropG, varsG, stageLayoutG);
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
		 * 是否显示 scaleX/scaleY，是否启用 width/height
		 * @param xy
		 * @param wh
		 */
		private function update_SX_SY_W_H(xy:Boolean, wh:Boolean):void
		{
			common1G.widthText.editable = common1G.heightText.editable = wh;
			
			if(xy)
				common2G.addElementAt(common2G.scaleG, 0);
			else if(common2G.scaleG.parent != null)
				common2G.removeElement(common2G.scaleG);
			
			common2G.updateHeight();
		}
		
		
		
		
		/**
		 * 更新x、y、width、height
		 */
		public function updateBounds():void
		{
			if(selectedLayer == null) return;
			
			common1G.xText.text = selectedLayer.x.toString();
			common1G.yText.text = selectedLayer.y.toString();
			common1G.widthText.text = selectedLayer.width.toString();
			common1G.heightText.text = selectedLayer.height.toString();
			
			AppCommon.controller.updateFrame();
		}
		
		
		
		/**
		 * 当前选中的图层
		 */
		private function get selectedLayer():Layer { return AppCommon.controller.selectedLayer; }
		//
	}
}