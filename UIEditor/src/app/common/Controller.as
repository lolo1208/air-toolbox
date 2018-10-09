package app.common
{
	import app.controls.Open;
	import app.groups.canvasGroup.CanvasGroup;
	import app.groups.layerGroup.LayerGroup;
	import app.groups.propGroup.PropGroup;
	import app.groups.styleGroup.StyleGroup;
	import app.layers.AnimationLayer;
	import app.layers.BitmapSpriteLayer;
	import app.layers.ContainerLayer;
	import app.layers.Layer;
	import app.utils.LayerUtil;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import lolo.core.Common;
	import lolo.utils.AutoUtil;

	/**
	 * 公用方法控制器
	 * @author LOLO
	 */
	public class Controller
	{
		private var _canvas:CanvasGroup;
		private var _prop:PropGroup;
		private var _style:StyleGroup;
		private var _layer:LayerGroup;
		
		/**当前选中的图层*/
		private var _selectedLayer:Layer;
		
		/**当前打开的配置文件路径*/
		public var configPath:String;
		
		
		
		public function Controller()
		{
			_canvas = AppCommon.canvas;
			_prop = AppCommon.prop;
			_style = AppCommon.style;
			_layer = AppCommon.layer;
		}
		
		
		
		
		
		/**
		 * 添加一个容器
		 * @param name 容器的名称
		 */
		public function addContainer(name:String, extContainer:Boolean=true):ContainerLayer
		{
			var layer:ContainerLayer = new ContainerLayer(name, extContainer);
			
			_canvas.containerTB.dataProvider.addItem({ name:name, container:layer });
			Common.stage.addEventListener(Event.ENTER_FRAME, _canvas.updateContainerTabBarStyle);
			_canvas.containerTB.selectedIndex = _canvas.containerTB.dataProvider.length - 1;
			showCurrentContainer();
			
			selectLayer(layer);
			_canvas.toolbar.focusSelectedLayer();
			return layer;
		}
		
		
		
		/**
		 * 显示当前容器内容
		 */
		public function showCurrentContainer():void
		{
			_canvas.containers.removeChildren();
			_canvas.containers.addChild(currentContainerLayer);
			
			_layer.clear();
			for(var i:int=0; i < currentContainer.numChildren; i++) {
				_layer.addLayer(currentContainer.getChildAt(i) as Layer);
			}
		}
		
		
		
		/**
		 * 当前容器
		 */
		public function get currentContainer():Sprite { return _canvas.containerTB.selectedItem.container.element; }
		
		
		/**
		 * 当前容器图层对象
		 */
		public function get currentContainerLayer():ContainerLayer { return _canvas.containerTB.selectedItem.container; }
		
		
		/**
		 * 获取指定ID的容器图层
		 * @param id
		 * @return 
		 */
		public function getContainerLayer(id:String):ContainerLayer
		{
			for(var i:int = 0; i < _canvas.containerTB.dataProvider.length; i++) {
				var layer:ContainerLayer = _canvas.containerTB.dataProvider.getItemAt(i).container;
				if(layer.id == id) return layer;
			}
			return null;
		}
		
		
		
		
		/**
		 * 添加一个图层（元件）
		 * @param item 这个图层在列表中的数据
		 * @param props 附加属性
		 */
		public function addLayer(item:Object, props:Object):void
		{
			var layer:Layer;
			if(item.isUI) {
				layer = new BitmapSpriteLayer(item.name);
			}
			else if(item.isAnimation) {
				layer = new AnimationLayer(item.name);
			}
			else if(item.isComponent) {
				if(item.name == LayerConstants.MODAL_BACKGROUND && _layer.hasModalBGLayer) {
					selectLayer(_layer.modalBGLayer);
					return;
				}
				layer = LayerUtil.getComponentLayer(item.name);
			}
			
			AutoUtil.initObject(layer, props);
			//简单容器默认放到 0,0 位置
			if(LayerUtil.isSprite(layer) || LayerUtil.isItemGroup(layer)) layer.x = layer.y = 0;
			
			currentContainer.addChild(layer);
			_layer.addLayer(layer);
			selectLayer(layer);
			
			AppCommon.app.rt.contentVS.selectedIndex = 1;
		}
		
		
		/**
		 * 移除一个图层
		 * @param layer
		 */
		public function removeLayer(layer:Layer):void
		{
			if(layer.parent) layer.parent.removeChild(layer);
			if(LayerUtil.isAnimation(layer)) LayerUtil.getAni(layer).stop();
			_layer.removeLayer(layer);
			update();
		}
		
		
		/**
		 * 选中一个图层
		 * @param layer 值为null，表示不选中任何图层
		 */
		public function selectLayer(layer:Layer):void
		{
			if(layer == _selectedLayer) return;
			
			if(_selectedLayer != null) _selectedLayer.veSelected = false;
			_selectedLayer = layer;
			if(_selectedLayer != null) _selectedLayer.veSelected = true;
			
			_layer.update();
			_prop.update();
			_style.update();
			
			updateFrame();
			update();
		}
		
		
		
		/**
		 * 当前选中的图层
		 */
		public function get selectedLayer():Layer { return _selectedLayer; }
		
		
		/**
		 * 是否已经打开了界面配置文件（XML）
		 */
		public function get configOpened():Boolean { return _canvas.containerTB.dataProvider.length > 0; }
		
		
		
		
		
		/**
		 * 更新显示当前选中图层的边框
		 */
		public function updateFrame():void
		{
			var tf:Shape = _canvas.topFrame;
			var bf:Shape = _canvas.bottomFrame;
			tf.graphics.clear();
			bf.graphics.clear();
			
			if(_selectedLayer == null) return;
			if(LayerUtil.isContainer()) return;
			
			var bounds:Rectangle = _selectedLayer.bounds;
			bounds.x += currentContainer.x;
			bounds.y += currentContainer.y;
			bounds.left-=2;	bounds.right++;
			bounds.top-=2;	bounds.bottom++;
			
			tf.graphics.lineStyle(1, 0x0066FF);
			tf.graphics.moveTo(bounds.left, bounds.top);
			tf.graphics.lineTo(bounds.right, bounds.top);
			tf.graphics.lineTo(bounds.right, bounds.bottom);
			tf.graphics.lineTo(bounds.left, bounds.bottom);
			tf.graphics.lineTo(bounds.left, bounds.top);
			
			bf.graphics.lineStyle(1, 0x0066FF);
			bf.graphics.moveTo(bounds.left, bounds.top);
			bf.graphics.lineTo(bounds.right, bounds.top);
			bf.graphics.lineTo(bounds.right, bounds.bottom);
			bf.graphics.lineTo(bounds.left, bounds.bottom);
			bf.graphics.lineTo(bounds.left, bounds.top);
		}
		
		
		/**
		 * 刷新当前正在编辑的容器界面内容
		 */
		public function update():void
		{
			if(!configOpened) return;
			for(var i:int = 0; i < _layer.layerList.dataProvider.length; i++) {
				_layer.getLayerByIndex(i).update();
			}
		}
		
		
		
		
		
		/**
		 * 打开指定的配置文件
		 * @param path
		 * @param config
		 */
		public function openConfig(path:String, config:XML):void
		{
			configPath = path;
			var arr:Array = path.split("\\");
			Open.open(arr[arr.length - 1], config);
			_canvas.toolbar.focusSelectedLayer();
			
			//启用重载、关闭和保存菜单项
			AppCommon.app.menuData.getItemAt(0).children[1].enabled = true;
			AppCommon.app.menuData.getItemAt(0).children[2].enabled = true;
			AppCommon.app.menuData.getItemAt(0).children[4].enabled = true;
		}
		
		
		
		
		/**
		 * 清除一个容器层，以及容器内的子对象（层）
		 * @param layer
		 */
		public function clearContainerLayer(layer:ContainerLayer):void
		{
			
		}
		
		
		/**
		 * 清空正在编辑的界面（XML）
		 */
		public function clear():void
		{
			while(configOpened) {
				clearContainerLayer(_canvas.containerTB.dataProvider.removeItemAt(0).container);
			}
			_layer.clear();
			_canvas.containers.removeChildren();
			_canvas.bottomFrame.graphics.clear();
			_canvas.topFrame.graphics.clear();
		}
		//
	}
}