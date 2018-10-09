package app.utils
{
	import app.common.AppCommon;
	import app.common.LayerConstants;
	import app.layers.AnimationLayer;
	import app.layers.ArtTextLayer;
	import app.layers.BaseButtonLayer;
	import app.layers.BaseTextFieldLayer;
	import app.layers.BitmapSpriteLayer;
	import app.layers.ButtonLayer;
	import app.layers.CheckBoxLayer;
	import app.layers.ContainerLayer;
	import app.layers.DisplayObjectLayer;
	import app.layers.ImageButtonLayer;
	import app.layers.ImageLoaderLayer;
	import app.layers.InputTextLayer;
	import app.layers.ItemGroupLayer;
	import app.layers.LabelLayer;
	import app.layers.Layer;
	import app.layers.ListLayer;
	import app.layers.ModalBackgroundLayer;
	import app.layers.NumberTextLayer;
	import app.layers.PageLayer;
	import app.layers.PageListLayer;
	import app.layers.RadioButtonLayer;
	import app.layers.ScrollBarLayer;
	import app.layers.ScrollListLayer;
	import app.layers.SpriteLayer;
	import app.layers.TouchScrollBarLayer;
	
	import lolo.components.BaseButton;
	import lolo.components.Button;
	import lolo.components.ImageButton;
	import lolo.components.ImageLoader;
	import lolo.components.ItemGroup;
	import lolo.components.Page;
	import lolo.components.ScrollBar;
	import lolo.display.Animation;
	import lolo.display.BaseTextField;
	import lolo.utils.AutoUtil;

	
	/**
	 * 图层相关工具类
	 * @author LOLO
	 */
	public class LayerUtil
	{
		
		/**
		 * 解析props JSON字符串，转为layer的属性
		 * @param layer
		 * @param propsStr
		 * @return propsStr 对应的 Object
		 */
		public static function parseProps(layer:Layer, propsStr:String):Object
		{
			if(layer == null || propsStr == "" || propsStr == null) return null;
			var props:Object = JSON.parse(propsStr);
			AutoUtil.initObject(layer.element, props);
			
			if(props.x != null) layer.x = props.x;
			if(props.y != null) layer.y = props.y;
			if(props.width != null) layer.width = props.width;
			if(props.height != null) layer.height = props.height;
			
			if(props.alpha != null) layer.alpha = props.alpha;
			if(props.visible != null) layer.visible = props.visible;
			
			if(props.styleName != null) layer.styleName = props.styleName;
			
			return props;
		}
		
		
		
		/**
		 * 解析stageLayout JSON字符串，转为layer.stageLayout属性
		 * @param layer
		 * @param slStr
		 */
		public static function parseStageLayout(layer:Layer, slStr:String):void
		{
			if(layer == null || slStr == "" || slStr == null) return;
			
			var args:Object = layer.stageLayout;
			args.enabled = true;
			var obj:Object = JSON.parse(slStr);
			
			if(obj.width != null) args.width = obj.width;
			if(obj.x != null) {
				args.hKey = "x";
				args.hValue = String(obj.x * 100) + "%";
			}
			else if(obj.paddingRight != null) {
				args.hKey = "paddingRight";
				args.hValue = obj.paddingRight;
			}
			else if(obj.offsetX != null) {
				args.hKey = "offsetX";
				args.hValue = obj.offsetX;
			}
			else if(obj.cancelH != null) {
				args.hEnabled = false;
			}
			
			
			if(obj.height != null) args.height = obj.height;
			if(obj.y != null) {
				args.vKey = "y";
				args.vValue = String(obj.y * 100) + "%";
			}
			else if(obj.paddingBottom != null) {
				args.vKey = "paddingBottom";
				args.vValue = obj.paddingBottom;
			}
			else if(obj.offsetY != null) {
				args.vKey = "offsetY";
				args.vValue = obj.offsetY;
			}
			else if(obj.cancelV != null) {
				args.vEnabled = false;
			}
		}
		
		
		
		
		/**
		 * 根据类型，获取一个（新创建的）组件图层
		 * @param type
		 * @return 
		 */
		public static function getComponentLayer(type:String):Layer
		{
			var layer:Layer;
			switch(type)
			{
				case LayerConstants.MODAL_BACKGROUND:
					layer = new ModalBackgroundLayer();
					break;
				
				case LayerConstants.IMAGE_LOADER:
					layer = new ImageLoaderLayer();
					break;
				
				case LayerConstants.ART_TEXT:
					layer = new ArtTextLayer();
					break;
				
				case LayerConstants.DISPLAY_OBJECT:
					layer = new DisplayObjectLayer();
					break;
				
				case LayerConstants.LABEL:
					layer = new LabelLayer();
					break;
				
				case LayerConstants.NUMBER_TEXT:
					layer = new NumberTextLayer();
					break;
				
				case LayerConstants.INPUT_TEXT:
					layer = new InputTextLayer();
					break;
				
				case LayerConstants.BASE_BUTTON:
					layer = new BaseButtonLayer();
					break;
				
				case LayerConstants.IMAGE_BUTTON:
					layer = new ImageButtonLayer();
					break;
				
				case LayerConstants.BUTTON:
					layer = new ButtonLayer();
					break;
				
				case LayerConstants.CHECK_BOX:
					layer = new CheckBoxLayer();
					break;
				
				case LayerConstants.RADIO_BUTTON:
					layer = new RadioButtonLayer();
					break;
				
				case LayerConstants.SPRITE:
					layer = new SpriteLayer();
					break;
				
				case LayerConstants.ITEM_GROUP:
					layer = new ItemGroupLayer();
					break;
				
				case LayerConstants.PAGE:
					layer = new PageLayer();
					break;
				
				case LayerConstants.SCROLL_BAR:
					layer = new ScrollBarLayer();
					break;
				case LayerConstants.TOUCH_SCROLL_BAR:
					layer = new TouchScrollBarLayer();
					break;
				
				case LayerConstants.LIST:
					layer = new ListLayer();
					break;
				
				case LayerConstants.PAGE_LIST:
					layer = new PageListLayer();
					break;
				
				case LayerConstants.SCROLL_LIST:
					layer = new ScrollListLayer();
					break;
				
			}
			if(layer != null) layer.init();
			return layer;
		}
		
		
		
		
		
		
		
		public static function isContainer(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is ContainerLayer;
		}
		
		public static function isAnimation(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is AnimationLayer;
		}
		
		public static function isBtimapSprite(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is BitmapSpriteLayer;
		}
		
		
		
		public static function isComponent(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return !isContainer(layer)
				&& !isAnimation(layer)
				&& !isBtimapSprite(layer);
		}
		
		
		
		public static function isModalBackground(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is ModalBackgroundLayer;
		}
		
		public static function isBaseTextField(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is BaseTextFieldLayer;
		}
		
		public static function isLabel(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is LabelLayer;
		}
		
		public static function isNumberText(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is NumberTextLayer;
		}
		
		public static function isInputText(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is InputTextLayer;
		}
		
		
		public static function isBaseButton(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is BaseButtonLayer;
		}
		
		public static function isButton(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is ButtonLayer;
		}
		
		public static function isImageButton(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is ImageButtonLayer;
		}
		
		public static function isCheckBox(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is CheckBoxLayer;
		}
		
		public static function isRadioButton(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is RadioButtonLayer;
		}
		
		
		public static function isSprite(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is SpriteLayer;
		}
		
		public static function isItemGroup(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is ItemGroupLayer;
		}
		
		public static function isImageLoader(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is ImageLoaderLayer;
		}
		
		public static function isArtText(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is ArtTextLayer;
		}
		
		public static function isDisplayObject(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is DisplayObjectLayer;
		}
		
		
		public static function isPage(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is PageLayer;
		}
		
		public static function isScrollBar(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is ScrollBarLayer || layer is TouchScrollBarLayer;
		}
		
		public static function isTouchScrollBar(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is TouchScrollBarLayer;
		}
		
		
		public static function isList(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is ListLayer;
		}
		
		public static function isPageList(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is PageListLayer;
		}
		
		public static function isScrollList(layer:Layer=null):Boolean
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer is ScrollListLayer;
		}
		
		
		
		
		
		public static function getAni(layer:Layer=null):Animation
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer.element as Animation;
		}
		
		public static function getTextField(layer:Layer=null):BaseTextField
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer.element as BaseTextField;
		}
		
		public static function getBaseButton(layer:Layer=null):BaseButton
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer.element as BaseButton;
		}
		
		public static function getButton(layer:Layer=null):Button
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer.element as Button;
		}
		
		public static function getImageButton(layer:Layer=null):ImageButton
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer.element as ImageButton;
		}
		
		public static function getImageLoader(layer:Layer=null):ImageLoader
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer.element as ImageLoader;
		}
		
		public static function getPage(layer:Layer=null):Page
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer.element as Page;
		}
		
		public static function getScrollBar(layer:Layer=null):ScrollBar
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer.element as ScrollBar;
		}
		
		public static function getItemGroup(layer:Layer=null):ItemGroup
		{
			if(layer == null) layer = AppCommon.controller.selectedLayer;
			return layer.element as ItemGroup;
		}
		//
	}
}