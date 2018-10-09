package app.layers
{
	import app.common.AppCommon;
	import app.common.LayerConstants;
	
	import lolo.components.IItemRenderer;
	import lolo.components.ItemGroup;
	import lolo.core.Constants;
	import lolo.events.components.ListEvent;
	import lolo.utils.optimize.PrerenderScheduler;

	/**
	 * ItemGroup 图层
	 * @author LOLO
	 */
	public class ItemGroupLayer extends SpriteLayer
	{
		/**布局方式*/
		private var _layout:String = "absolute";
		/**水平方向子项间的像素间隔*/
		private var _horizontalGap:int = 0;
		/**垂直方向子项间的像素间隔*/
		private var _verticalGap:int = 0;
		
		/**子集列表（group=this）*/
		private var _groupChildren:Vector.<Layer> = new Vector.<Layer>();
		
		
		
		public function ItemGroupLayer()
		{
			super();
			this.type = LayerConstants.ITEM_GROUP;
		}
		
		
		override protected function createElement():void
		{
			this.element = new ItemGroup();
			this.element.addEventListener(ListEvent.ITEM_SELECTED, itemSelectedHandler);
		}
		
		
		override public function initProps(jsonStr:String):Object
		{
			if(jsonStr.length == 0) return null;
			
			var propObj:Object = super.initProps(jsonStr);
			if(propObj.layout != null) _layout = propObj.layout;
			if(propObj.horizontalGap != null) _horizontalGap = propObj.horizontalGap;
			if(propObj.verticalGap != null) _verticalGap = propObj.verticalGap;
			
			return propObj;
		}
		
		
		
		private function itemSelectedHandler(event:ListEvent):void
		{
			AppCommon.prop.common2G.updateSelected();
		}
		
		
		
		/**
		 * 添加一个层到 groupChildren
		 * @param layer
		 */
		public function addToGroup(layer:Layer):void
		{
			removeFromGroup(layer);
			_groupChildren.push(layer);
			update();
		}
		
		/**
		 * 从 groupChildren 删除层
		 * @param layer
		 */
		public function removeFromGroup(layer:Layer):void
		{
			for(var i:int = 0; i < _groupChildren.length; i++) {
				if(_groupChildren[i] == layer) {
					_groupChildren.splice(i, 1);
					return;
				}
			}
			update();
		}
		
		
		
		/**
		 * 布局方式
		 */
		public function set layout(value:String):void
		{
			_layout = value;
			update();
		}
		public function get layout():String { return _layout; }
		
		
		/**
		 * 水平方向子项间的像素间隔
		 */
		public function set horizontalGap(value:int):void
		{
			_horizontalGap = value;
			update();
		}
		public function get horizontalGap():int { return _horizontalGap; }
		
		
		/**
		 * 垂直方向子项间的像素间隔
		 */
		public function set verticalGap(value:int):void
		{
			_verticalGap = value;
			update();
		}
		public function get verticalGap():int { return _verticalGap; }
		
		
		
		
		override public function update():void
		{
			PrerenderScheduler.addCallback(prerender);
		}
		
		
		/**
		 * 即将进入渲染时的回调
		 */
		protected function prerender():void
		{
			PrerenderScheduler.removeCallback(prerender);
			if(_layout == Constants.ABSOLUTE || _groupChildren.length == 0) return;
			
			//按图层深度排序
			var i:int, layer:Layer;
			var children:Array = [];
			for(i = 0; i < _groupChildren.length; i++) {
				layer = _groupChildren[i];
				children.push({ layer:layer, index:AppCommon.layer.getLayerIndex(layer) });
			}
			children.sortOn("index", Array.NUMERIC | Array.DESCENDING);
			
			
			var position:int = 0;
			for(i = 0; i < children.length; i++)
			{
				layer = children[i].layer;
				var item:IItemRenderer = layer.element as IItemRenderer;
				
				if(layer.parentLayer == this && item.visible)
				{
					switch(_layout)
					{
						case Constants.HORIZONTAL:
							layer.x = position;
							layer.y = 0;
							position += item.itemWidth + _horizontalGap;
							break;
						
						case Constants.VERTICAL:
							layer.x = 0;
							layer.y = position;
							position += item.itemHeight + _verticalGap;
							break;
					}
				}
			}
			AppCommon.controller.updateFrame();
		}
		
		
		
		public function set enabled(value:Boolean):void
		{
			_element["enabled"] = value;
			for(var i:int = 0; i < _groupChildren.length; i++) {
				_groupChildren[i].element["enabled"] = value;
			}
		}
		public function get enabled():Boolean { return _element["enabled"]; }
		
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			if(_layout != Constants.ABSOLUTE) props.layout = _layout;
			if(_horizontalGap != 0) props.horizontalGap = _horizontalGap;
			if(_verticalGap != 0) props.verticalGap = _verticalGap;
			if(!_element["enabled"]) props.enabled = false;
			
			return props;
		}
		//
	}
}