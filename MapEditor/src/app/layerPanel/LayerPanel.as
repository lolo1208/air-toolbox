package app.layerPanel
{
	import app.common.AppCommon;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayList;
	import mx.containers.Accordion;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	
	import spark.components.List;
	import spark.components.Panel;
	
	/**
	 * 图层面板
	 * @author LOLO
	 */
	public class LayerPanel extends Panel
	{
		public var contentA:Accordion;
		public var coverList:List;
		public var bgList:List;
		
		private var _file:File;
		private var _loader:Loader;
		
		
		
		public function LayerPanel()
		{
			super();
			this.setStyle("dropShadowVisible", false);
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			_file = new File();
			_file.addEventListener(Event.SELECT, file_selectHandler);
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			
			coverList.dataProvider = new ArrayList();
			bgList.dataProvider = new ArrayList();
		}
		
		
		
		
		/**
		 * 初始化
		 */
		public function init():void
		{
			_file = new File();
			_file.addEventListener(Event.SELECT, file_selectHandler);
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			
			coverList.dataProvider = new ArrayList();
			bgList.dataProvider = new ArrayList();
		}
		
		
		
		
		
		/**
		 * 拖动结束
		 * @param event
		 */
		protected function dragCompleteHandler(event:DragEvent):void
		{
			for(var i:int = list.dataProvider.length-1; i >= 0; i--) {
				AppCommon.app.canvasGroup.addLayer(
					list.dataProvider.getItemAt(i).layer,
					contentA.selectedIndex+1
				);
			}
		}
		
		
		
		/**
		 * 点击添加按钮
		 * @param event
		 */
		protected function addBtn_clickHandler(event:MouseEvent):void
		{
			_file.browse([new FileFilter("图像文件", "*.jpg;*.gif;*.png")]);
		}
		
		/**
		 * 选中图片
		 * @param event
		 */
		private function file_selectHandler(event:Event):void
		{
			_loader.load(new URLRequest(_file.nativePath));
		}
		
		/**
		 * 加载图片完成
		 * @param event
		 */
		private function loader_completeHandler(event:Event):void
		{
			var bitmap:Bitmap = new Bitmap((_loader.content as Bitmap).bitmapData.clone());
			var element:Sprite = new Sprite();
			element.addChild(bitmap);
			if(contentA.selectedIndex == 0) {
				AppCommon.coverIndex++;
				element.name = "cover_" + AppCommon.coverIndex;
			}
			else {
				AppCommon.bgIndex++;
				element.name = "bg_" + AppCommon.bgIndex;
			}
			_loader.unload();
			
			AppCommon.app.canvasGroup.addLayer(element, contentA.selectedIndex + 1);
			list.dataProvider.addItemAt({ name:element.name, layer:element }, 0);
		}
		
		
		
		
		/**
		 * 点击移除按钮
		 * @param event
		 */
		protected function removeBtn_clickHandler(event:MouseEvent):void
		{
			if(list.dataProvider.length == 0) return;
			var item:Object = list.dataProvider.removeItemAt(list.selectedIndex);
			AppCommon.app.canvasGroup.removeLayer(item.layer, contentA.selectedIndex+1);
		}
		
		
		private function get list():List
		{
			var list:List;
			if(contentA.selectedIndex == 0) list = coverList;
			else if(contentA.selectedIndex == 1) list = bgList;
			return list;
		}
		//
	}
}