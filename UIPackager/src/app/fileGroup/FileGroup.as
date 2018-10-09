package app.fileGroup
{
	import app.common.AppCommon;
	
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	import mx.events.ListEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	import toolbox.Toolbox;
	
	/**
	 * 文件列表容器
	 * @author LOLO
	 */
	public class FileGroup extends Group
	{
		public var fileTree:FileTree;
		public var selectedFileListTileText:Label;
		public var selectedFileList:List;
		
		
		
		public function FileGroup()
		{
			super();
		}
		
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			selectedFileList.width = fileTree.width = width - 20;
			selectedFileList.height = Math.max(50, int(height * 0.25));
			selectedFileList.y = height - selectedFileList.height - 10;
			
			selectedFileListTileText.y = selectedFileList.y - 20;
			
			fileTree.height = selectedFileListTileText.y - 50;
		}
		
		
		
		public function parse():void
		{
			var rootDir:File = new File(Toolbox.resRootDir + "ui");
			fileTree.dataProvider = new ArrayCollection(parseDir(rootDir, "", null));
			fileTree.itemSelectChanged();
		}
		
		
		/**
		 * 解析文件夹
		 * @param dir
		 * @param prefixion
		 * @param parent
		 */
		private function parseDir(dir:File, prefixion:String, parent:Object):Array
		{
			prefixion += dir.name + ".";
			
			var data:Array = [];
			var files:Array = dir.getDirectoryListing();
			
			for(var i:int=0; i < files.length; i++)
			{
				var file:File = files[i];
				if(file.name == ".svn") continue;
				
				var item:Object = { name:file.name, path:file.nativePath, parent:parent };
				
				if(file.isDirectory) {
					item.children = parseDir(file, prefixion, item);
					item.selected = false;
					data.push(item);
				}
				else {
					if(file.extension == "png" || file.extension == "jpg") {
						item.prefixion = prefixion.substr(3);
						item.selected = (AppCommon.app.canvasGroup.infoList[item.path] != null);
						data.push(item);
					}
				}
			}
			
			return data;
		}
		
		
		
		
		
		/**
		 * Tree有选中
		 * @param event
		 */
		protected function fileTree_changeHandler(event:ListEvent=null):void
		{
			if(fileTree.selectedItem.children != null) return;
			AppCommon.app.canvasGroup.showImage(fileTree.selectedItem);
		}
		
		
		
		/**
		 * 要打包的文件列表有选中
		 * @param event
		 */
		public function selectedFileList_changeHandler(event:IndexChangeEvent=null):void
		{
			var treeItemData:Object = selectedFileList.selectedItem.treeItemData;
			var parentItem:Object = treeItemData.parent;
			while(parentItem != null) {
				fileTree.expandItem(parentItem, true);
				parentItem = parentItem.parent;
			}
			
			fileTree.selectedItem = treeItemData;
			fileTree_changeHandler();
			fileTree.scrollToItem(treeItemData);
		}
		
		
		public function reset():void
		{
			fileTree.dataProvider = null;
			selectedFileList.dataProvider = null;
		}
		//
	}
}