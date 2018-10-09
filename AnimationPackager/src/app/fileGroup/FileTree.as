package app.fileGroup
{
	import app.common.AppCommon;
	
	import flash.events.KeyboardEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Tree;
	
	/**
	 * 文件树组件
	 * @author LOLO
	 */
	public class FileTree extends Tree
	{
		
		public function FileTree()
		{
			super();
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			
		}
		
		
		
		/**
		 * 根据图片路径，取消renderer的选中
		 * @param path
		 */
		public function uncheckItem(path:String):void
		{
			for(var i:int=0; i < listItems.length; i++) {
				var renderer:FileTreeItemRenderer = listItems[i][0];
				if(renderer.data.path == path) {
					renderer.setSelected(false);
					return;
				}
			}
		}
		
		
		/**
		 * 滚动到指定item
		 * @param data
		 */
		public function scrollToItem(data:Object):void
		{
			var index:int = 0;
			while(true)
			{
				for(var i:int=0; i < listItems.length; i++) {
					if(listItems[i].length > 0 && listItems[i][0].data == data) return;
				}
				scrollToIndex(++index);
			}
		}
		
		
		/**
		 * 全选或取消全选
		 * @param selected
		 */
		public function selectAll(selected:Boolean):void
		{
			setChildrenSelected({ children:dataProvider.source }, selected);
		}
		
		
		
		
		/**
		 * 设置所有子项的选中状态
		 * @param data
		 */
		public function setChildrenSelected(data:Object, selected:Boolean):void
		{
			var children:Array = data.children;
			for(var i:int = 0; i < children.length; i++)
			{
				var childData:Object = children[i];
				childData.selected = selected;
				if(childData.children != null) setChildrenSelected(childData, selected);
				
				var item:FileTreeItemRenderer = itemToItemRenderer(childData) as FileTreeItemRenderer;
				if(item != null) item.data = childData;
			}
		}
		
		
		
		
		/**
		 * 文件树列表的item选中状态有改变
		 */
		public function itemSelectChanged():void
		{
			var arr:ArrayCollection = dataProvider as ArrayCollection;
			for(var i:int = 0; i < arr.length; i++)
				checkChildrenSelected(arr.getItemAt(i));
			
			AppCommon.app.fileGroup.selectedFileList.dataProvider = new ArrayList();
			for(i = 0; i < arr.length; i++)
				checkFileSelected(arr.getItemAt(i));
			
			AppCommon.app.menuData.getItemAt(0).children[1].enabled
				= AppCommon.app.fileGroup.selectedFileList.dataProvider.length > 0;
			
			this.invalidateList();
		}
		
		
		/**
		 * 检查是不是选中的文件
		 * @param data
		 */
		private function checkFileSelected(data:Object):void
		{
			var children:Array = data.children;
			if(children != null) {
				for(var i:int = 0; i < children.length; i++)
					checkFileSelected(children[i]);
			}
			else {
				if(!data.selected) return;
				AppCommon.app.fileGroup.selectedFileList.dataProvider.addItem({
					name		: data.prefixion + data.name,
					path		: data.path,
					treeItemData: data
				});
			}
		}
		
		
		
		
		/**
		 * 向下检查，子项是否全部选中
		 * @param data
		 */
		private function checkChildrenSelected(data:Object):void
		{
			var children:Array = data.children;
			if(children == null) return;
			
			var selected:Boolean = true;
			for(var i:int = 0; i < children.length; i++)
			{
				var childData:Object = children[i];
				checkChildrenSelected(childData);
				if(!childData.selected) selected = false;
			}
			if(selected != data.selected)
			{
				data.selected = selected;
				var item:FileTreeItemRenderer = itemToItemRenderer(data) as FileTreeItemRenderer;
				if(item != null) item.data = data;
				checkParentSelected(data.parent);
			}
		}
		
		
		/**
		 * 向上检查，父项中的子项，是否全部选中
		 * @param data
		 */
		private function checkParentSelected(data:Object):void
		{
			if(data == null) return;
			var children:Array = data.children;
			
			var selected:Boolean = true;
			for(var i:int = 0; i < children.length; i++)
			{
				var childData:Object = children[i];
				if(!childData.selected) {
					selected = false;
					break;
				}
			}
			if(selected != data.selected)
			{
				data.selected = selected;
				var item:FileTreeItemRenderer = itemToItemRenderer(data) as FileTreeItemRenderer;
				if(item != null) item.data = data;
				checkParentSelected(data.parent);
			}
		}
		//
	}
}