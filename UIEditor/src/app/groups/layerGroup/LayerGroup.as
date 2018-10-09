package app.groups.layerGroup
{
	import app.common.AppCommon;
	import app.layers.Layer;
	import app.layers.ModalBackgroundLayer;
	import app.utils.LayerUtil;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayList;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.List;
	import spark.components.NavigatorContent;
	import spark.events.IndexChangeEvent;
	
	/**
	 * 图层列表容器
	 * @author LOLO
	 */
	public class LayerGroup extends NavigatorContent
	{
		public var layerList:List;
		
		/**自动增长的编号*/
		private var _no:uint;
		/**图层实例列表，key=layerItemRenderer.data.no*/
		private var _layers:Dictionary;
		
		/**已添加的模态背景层*/
		private var _modalBGLayer:ModalBackgroundLayer;
		/**当前是否正在拖动模态背景*/
		private var _dragModalBG:Boolean;
		
		
		
		public function LayerGroup()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			
		}
		
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			layerList.width = this.width - 2;
			layerList.height = this.height - 1;
		}
		
		
		
		/**
		 * 列表有选中事件
		 * @param event
		 */
		protected function layerList_changeHandler(event:IndexChangeEvent):void
		{
			var layer:Layer = getLayerByNO(layerList.selectedItem.no);
			AppCommon.controller.selectLayer(layer);
		}
		
		
		
		/**
		 * 添加一个图层
		 * @param layer 图层的显示实例
		 */
		public function addLayer(layer:Layer):void
		{
			var item:Object = { no:String(++_no), isLayer:true };
			_layers[item.no] = layer;
			
			if(LayerUtil.isModalBackground(layer)){
				_modalBGLayer = layer as ModalBackgroundLayer;
				_modalBGLayer.parent.addChildAt(_modalBGLayer, 0);
				layerList.dataProvider.addItem(item);
			}
			else {
				layerList.dataProvider.addItemAt(item, 0);
			}
		}
		
		
		/**
		 * 移除一个图层
		 * @param layer
		 */
		public function removeLayer(layer:Layer):void
		{
			if(layer == _modalBGLayer) _modalBGLayer = null;
			
			for(var i:int=0; i < layerList.dataProvider.length; i++) {
				var item:Object = layerList.dataProvider.getItemAt(i);
				if(_layers[item.no] == layer) {
					layerList.dataProvider.removeItemAt(i);
					delete _layers[item.no];
					return;
				}
			}
		}
		
		
		
		/**
		 * 更新显示内容，选中当前的 selectedLayer
		 */
		public function update():void
		{
			for(var i:int=0; i < layerList.dataProvider.length; i++) {
				if(getLayerByIndex(i) == selectedLayer) {
					layerList.selectedIndex = i;
					return;
				}
			}
			layerList.selectedItem = null;
		}
		
		
		
		/**
		 * 将layer与旁边的图层（上或下）交换深度
		 * @param layer
		 * @param isUP
		 */
		public function swapLayerDepth(layer:Layer, isUP:Boolean):void
		{
			if(LayerUtil.isModalBackground(layer)) return;
			
			for(var i:int=0; i < layerList.dataProvider.length; i++)
			{
				if(getLayerByIndex(i) != layer)  continue;
				if(isUP && i == 0) return;
				if(!isUP && i == layerList.dataProvider.length - 1) return;
				
				var item:Object = layerList.dataProvider.removeItemAt(i);
				layerList.dataProvider.addItemAt(item, isUP ? i-1 : i+1);
				layerList.selectedItem = item;
				
				updateLayerDepth();
				return;
			}
		}
		
		
		/**
		 * 选择layer旁边的图层（上或下）
		 * @param layer
		 * @param isUP
		 */
		public function selectSideLayer(layer:Layer, isUP:Boolean):void
		{
			for(var i:int=0; i < layerList.dataProvider.length; i++)
			{
				if(getLayerByIndex(i) != layer)  continue;
				if(isUP && i == 0) return;
				if(!isUP && i == layerList.dataProvider.length - 1) return;
				
				layer = getLayerByIndex(isUP ? i-1 : i+1);
				AppCommon.controller.selectLayer(layer);
				return;
			}
		}
		
		
		/**
		 * 开始拖动item
		 * @param event
		 */
		protected function layerList_dragStartHandler(event:DragEvent):void
		{
			_dragModalBG = (_modalBGLayer && layerList.selectedIndex == layerList.dataProvider.length - 1);
		}
		
		/**
		 * 有item拖动进来
		 * @param event
		 */
		protected function layerList_dragEnterHandler(event:DragEvent):void
		{
			var item:Object = event.dragSource.dataForFormat(event.dragSource.formats[0])[0];
			layerList.dropEnabled = item.isLayer && !_dragModalBG;
		}
		
		/**
		 * 列表拖动结束
		 * @param event
		 */
		protected function layerList_dragCompleteHandler(event:DragEvent):void
		{
			updateLayerDepth();
			if(_dragModalBG) update();
		}
		
		
		
		/**
		 * 更新舞台上的图层深度
		 */
		private function updateLayerDepth():void
		{
			var modalBGItem:Object, i:int, layer:Layer;
			for(i = 0; i < layerList.dataProvider.length; i++)
			{
				layer = getLayerByIndex(i);
				
				if(LayerUtil.isModalBackground(layer)) {
					modalBGItem = layerList.dataProvider.removeItemAt(i);
					i--;
				}
				else {
					layer.parent.addChildAt(layer, layerList.dataProvider.length - 1 - i);
				}
			}
			
			//模态背景放到最底层
			if(modalBGItem) {
				layerList.dataProvider.addItem(modalBGItem);
				_modalBGLayer.parent.addChildAt(_modalBGLayer, 0);
			}
			
			AppCommon.controller.update();
		}
		
		
		
		/**
		 * 获取图层的索引（图层深度）
		 * @param layer
		 * @return 如果 layer 不是 layerList 的子集将返回 -1
		 */
		public function getLayerIndex(layer:Layer):int
		{
			for(var i:int=0; i < layerList.dataProvider.length; i++) {
				if(_layers[layerList.dataProvider.getItemAt(i).no] == layer) return i;
			}
			return -1;
		}
		
		
		/**
		 * 根据编号获取图层实例
		 */
		public function getLayerByNO(no:String):Layer { return _layers[no]; }
		
		/**
		 * 根据索引获取图层实例
		 */
		public function getLayerByIndex(index:uint):Layer { return _layers[layerList.dataProvider.getItemAt(index).no]; }
		
		
		/**
		 * 是否已经有模态背景层存在了
		 */
		public function get hasModalBGLayer():Boolean { return _modalBGLayer != null; }
		
		public function get modalBGLayer():ModalBackgroundLayer { return _modalBGLayer; }
		
		
		
		/**
		 * 当前选中的图层
		 */
		public function get selectedLayer():Layer { return AppCommon.controller.selectedLayer; }
		
		
		
		/**
		 * 清空图层内容
		 */
		public function clear():void
		{
			_modalBGLayer = null;
			_no = 0;
			_layers = new Dictionary();
			layerList.dataProvider = new ArrayList();
		}
		//
	}
}