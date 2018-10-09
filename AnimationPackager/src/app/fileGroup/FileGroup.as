package app.fileGroup
{
	import app.common.AppCommon;
	
	import flash.events.Event;
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
			Toolbox.progressPanel.show(2, 2, "正在解析动画文件夹");
			AppCommon.app.stage.addEventListener(Event.ENTER_FRAME, doParse);
		}
		
		private function doParse(event:Event):void
		{
			AppCommon.app.stage.removeEventListener(Event.ENTER_FRAME, doParse);
			
			var rootDir:File = new File(Toolbox.resRootDir + "ani");
			fileTree.dataProvider = new ArrayCollection(parseDir(rootDir, "", null));
			fileTree.itemSelectChanged();
			Toolbox.progressPanel.hide();
		}
		
		
		/**
		 * 解析文件夹
		 * @param dir
		 * @param prefixion
		 * @param parent
		 */
		private function parseDir(dir:File, prefixion:String, parent:Object):Array
		{
			if(prefixion != "" || dir.name != "ani") prefixion += dir.name + ".";
			
			var data:Array = [];
			var files:Array = dir.getDirectoryListing();
			
			for(var i:int=0; i < files.length; i++)
			{
				var file:File = files[i];
				if(file.name == ".svn") continue;
				
				var item:Object = { name:file.name, path:file.nativePath, parent:parent };
				if(file.isDirectory)
				{
					//文件夹内还有文件夹，说名这个文件夹只是中间文件夹，继续解析，否则保存好文件夹内的图片url列表
					var isMiddleDir:Boolean = false;
					var imgUrlList:Array = [];
					var childFiles:Array = file.getDirectoryListing();
					
					for(var n:int=0; n < childFiles.length; n++) {
						var cFile:File = childFiles[n];
						if(cFile.name == ".svn") continue;
						if(cFile.isDirectory) {
							isMiddleDir = true;
							break;
						}
						else if(cFile.extension == "png") {
							imgUrlList.push(cFile.nativePath);
						}
					}
					
					if(isMiddleDir) {
						item.children = parseDir(file, prefixion, item);
					}
					else {
						item.prefixion = prefixion;
						item.imgUrlList = imgUrlList;
					}
					data.push(item);
					item.selected = (AppCommon.app.canvasGroup.infoList[item.path] != null);
				}
				else
				{
					if(file.extension == "png") data.push(item);
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
			AppCommon.app.canvasGroup.showAni(fileTree.selectedItem);
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