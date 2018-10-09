package app.controls
{
	import app.common.AppCommon;
	import app.common.LayerConstants;
	import app.layers.*;
	import app.utils.LayerUtil;
	
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import lolo.core.Common;
	
	import mx.controls.Alert;

	/**
	 * 打开配置文件控制器
	 * @author LOLO
	 */
	public class Open
	{
		
		/**
		 * 打开配置文件，解析并在编辑器中显示相应内容
		 * @param name
		 * @param config
		 */
		public static function open(name:String, config:XML):void
		{
			AppCommon.controller.clear();
			
			//创建最底层容器
			var container:ContainerLayer = AppCommon.controller.addContainer(name);
			container.otherProps = config.@props;
			container.vars = config.@vars;
			container.initStageLayout(config.@stageLayout);
			container.initProps(config.@properties);
			
			createElement(config, container);
			
			AppCommon.app.rt.contentVS.selectedIndex = 1;
			Common.stage.addEventListener(Event.ENTER_FRAME, refreshCurrentContainer);
		}
		
		private static function refreshCurrentContainer(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, refreshCurrentContainer);
			AppCommon.controller.showCurrentContainer();
			AppCommon.prop.update();
		}
		
		
		/**
		 * 创建config内的元件，放入到指定的容器中
		 * @param config
		 */
		private static function createElement(config:XML, container:ContainerLayer):void
		{
			for each(var item:XML in config.*)
			{
				//创建对应的元件
				var layer:Layer = null;
				var name:String = item.name();
				switch(name)
				{
					case LayerConstants.ANIMATION		: layer = new AnimationLayer();			break;
					case LayerConstants.BITMAP_SPRITE	: layer = new BitmapSpriteLayer();		break;
					case LayerConstants.MODAL_BACKGROUND: layer = new ModalBackgroundLayer();	break;
					case "modalBG"						: layer = new ModalBackgroundLayer();	break;
					case LayerConstants.LABEL			: layer = new LabelLayer();				break;
					case LayerConstants.INPUT_TEXT		: layer = new InputTextLayer();			break;
					case LayerConstants.NUMBER_TEXT		: layer = new NumberTextLayer();		break;
					case LayerConstants.BASE_BUTTON		: layer = new BaseButtonLayer();		break;
					case LayerConstants.BUTTON			: layer = new ButtonLayer();			break;
					case LayerConstants.IMAGE_BUTTON	: layer = new ImageButtonLayer();		break;
					case LayerConstants.CHECK_BOX		: layer = new CheckBoxLayer();			break;
					case LayerConstants.RADIO_BUTTON	: layer = new RadioButtonLayer();		break;
					case LayerConstants.ITEM_GROUP		: layer = new ItemGroupLayer();			break;
					case LayerConstants.SPRITE			: layer = new SpriteLayer();			break;
					case LayerConstants.IMAGE_LOADER	: layer = new ImageLoaderLayer();		break;
					case LayerConstants.ART_TEXT		: layer = new ArtTextLayer();			break;
					case LayerConstants.DISPLAY_OBJECT	: layer = new DisplayObjectLayer();		break;
					case LayerConstants.PAGE			: layer = new PageLayer();				break;
					case LayerConstants.SCROLL_BAR		: layer = new ScrollBarLayer();			break;
					case LayerConstants.TOUCH_SCROLL_BAR: layer = new TouchScrollBarLayer();	break;
					case LayerConstants.LIST			: layer = new ListLayer();				break;
					case LayerConstants.PAGE_LIST		: layer = new PageListLayer();			break;
					case LayerConstants.SCROLL_LIST		: layer = new ScrollListLayer();		break;
					
					//默认是容器
					default:
						var extContainer:Boolean = (name == "container");
						if(extContainer) name = item.@id;
						layer = AppCommon.controller.addContainer(name, extContainer);
						if(extContainer && String(item.@type) != "") (layer as ContainerLayer).cType = item.@type;
						createElement(item, layer as ContainerLayer);
				}
				
				if(!LayerUtil.isContainer(layer)) layer.id = item.@id;
				if(LayerUtil.isBaseTextField(layer)) (layer as BaseTextFieldLayer).tipsText = "";//打开的时候不要设置
				if(LayerUtil.isDisplayObject(layer)) (layer as DisplayObjectLayer).definition = item.@definition;
				
				// group
				var groupStr:String = String(item.@group);
				if(groupStr != "") {
					var group:ItemGroupLayer = container.getLayerByID(groupStr) as ItemGroupLayer;
					if(group != null) {
						(layer as BaseButtonLayer).groupLayer = group;
					}
					else {
						Alert.show("打开配置文件时，发现指定的 group:" + groupStr + " 不存在！！", "提示！");
					}
				}
				
				// parent
				var parentStr:String = String(item.@parent);
				if(parentStr != "") {
					var parent:SpriteLayer = container.getLayerByID(parentStr) as SpriteLayer;
					if(parent != null) {
						layer.parentLayer = parent;
					}
					else {
						Alert.show("打开配置文件时，发现指定的 parent:" + parentStr + " 不存在！！", "提示！");
					}
				}
				
				// target
				var targetStr:String = String(item.@target);
				if(targetStr != "") {
					var target:Layer = container.getLayerByID(targetStr);
					if(target != null) {
						if(LayerUtil.isPageList(layer)) (layer as PageListLayer).pageLayer = target as PageLayer;
						else layer.targetLayer = target;
					}
					else {
						Alert.show("打开配置文件时，发现指定的 target:" + targetStr + " 不存在！！", "提示！");
					}
				}
				
				
				layer.otherProps = item.@props;
				layer.vars = item.@vars;
				layer.initStageLayout(item.@stageLayout);
				layer.initProps(item.@properties);
				
				parseStyle(layer, item.@style);
				parseEditorProps(layer, item.@editorProps);
				
				if(!LayerUtil.isContainer(layer)) {
					(container.element as DisplayObjectContainer).addChild(layer);
					AppCommon.layer.addLayer(layer);
				}
			}
		}
		
		
		/**
		 * 解析图层的相关样式
		 * @param layer
		 * @param epStr
		 */
		private static function parseStyle(layer:Layer, styleStr:String):void
		{
			if(styleStr.length == 0) return;
			
			var style:Object = JSON.parse(styleStr);
			for(var name:String in style) {
				layer.setStyle(name, style[name]);
			}
		}
		
		
		/**
		 * 解析图层的编辑器属性
		 * @param layer
		 * @param epStr
		 */
		private static function parseEditorProps(layer:Layer, epStr:String):void
		{
			if(epStr.length == 0) return;
			epStr.replace(/\\t/g, "  ");
			var props:Object = JSON.parse(epStr);
			
			if(props.eye != null) layer.veEye = props.eye;
			if(props.lock != null) layer.veLock = props.lock;
			if(props.ignore != null) layer.veIgnore = props.ignore;
			
			if(props.tipsText != null) {
				(layer as BaseTextFieldLayer).tipsText = props.tipsText;
			}
			
			if(props.fileName != null) {
				(layer as ImageLoaderLayer).isDisplay = false;
				LayerUtil.getImageLoader(layer).fileName = props.fileName;
			}
			
			if(props.parentXML != null) {
				(layer as ContainerLayer).parentXML = props.parentXML;
			}
			if(props.depth != null) {
				(layer as ContainerLayer).depth = props.depth;
			}
			
			if(props.viewableAreaVisible != null) {
				layer["viewableAreaVisible"] = props.viewableAreaVisible;
			}
			
			if(props.swf != null) {
				(layer as DisplayObjectLayer).swf = props.swf;
			}
			
			if(props.item != null || props.scrollBar != null) {
				delayUpdate(layer, props);
			}
		}
		
		
		
		
		/**
		 * 延迟更新某些属性
		 */
		private static function delayUpdate(layer:Layer, props:Object):void
		{
			TweenMax.delayedCall(1, delayedUpdate, [layer, props]);
		}
		
		private static function delayedUpdate(layer:Layer, props:Object):void
		{
			var itemLayer:ContainerLayer, scrollBarLayer:*;
			
			if(props.item != null)
			{
				itemLayer = AppCommon.controller.getContainerLayer(props.item);
				if(itemLayer != null) {
					(layer as ListLayer).itemLayer = itemLayer;
					AppCommon.toolbar.focusSelectedLayer();
				}
				else {
					Alert.show("List 指定的 itemXML:" + props.item + " 不存在！！", "提示！");
				}
			}
			
			if(props.scrollBar != null)
			{
				scrollBarLayer = layer.containerLayer.getLayerByID(props.scrollBar);
				if(scrollBarLayer != null) {
					(layer as ScrollListLayer).scrollBarLayer = scrollBarLayer;
				}
				else {
					Alert.show("ScrollList 指定的 scrollBar:" + props.scrollBar + " 不存在！！", "提示！");
				}
			}
		}
		//
	}
}