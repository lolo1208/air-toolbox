package app.groups.configGroup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import lolo.core.Common;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Tree;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.NavigatorContent;
	
	import toolbox.Toolbox;
	
	
	
	/**
	 * 界面配置列表容器
	 * @author LOLO
	 */
	public class ConfigGroup extends NavigatorContent
	{
		public var createConfigPanel:CreateConfigPanel;
		public var configTree:Tree;
		
		
		private var _data:Array;
		/**加载资源库完成后的回调*/
		private var _loadedCallback:Function;
		
		
		
		public function ConfigGroup()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			
		}
		
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			configTree.width = this.width - 2;
			configTree.height = this.height - 1;
		}
		
		
		
		
		/**
		 * 加载资源库
		 * @param callback 加载资源库完成后的回调
		 */
		public function loadRes(callback:Function=null):void
		{
			_loadedCallback = callback;
			Toolbox.progressPanel.show(0, 0, "刷新界面配置列表");
			Common.stage.addEventListener(Event.ENTER_FRAME, doLoadRes);
		}
		
		private function doLoadRes(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, doLoadRes);
			
			_data = [];
			parseDir(new File(Toolbox.resRootDir + "xml/uiConfig"), _data);
			
			Common.stage.addEventListener(Event.ENTER_FRAME, parseDirComplete);
		}
		
		
		/**
		 * 解析文件夹
		 * @param dir
		 * @param data
		 */
		private function parseDir(dir:File, data:Array):void
		{
			var files:Array = dir.getDirectoryListing();
			for(var i:int = 0; i < files.length; i++)
			{
				var file:File = files[i];
				if(file.name == ".svn") continue;
				
				var item:Object = { name:file.name, path:file.nativePath };
				if(file.isDirectory) {
					item.children = [];
					parseDir(file, item.children);
				}
				else {
					if(file.extension != "xml") continue;
				}
				data.push(item);
			}
			
			data.sort(fileSort);
		}
		
		private function fileSort(a:Object, b:Object):int
		{
			if(a.children != null) return -1;
			if(b.children != null) return 1;
			var an:int = a.name.charAt().toLocaleLowerCase().charCodeAt();
			var bn:int = b.name.charAt().toLocaleLowerCase().charCodeAt();
			if(an > bn) return 1;
			if(an < bn) return -1;
			return 0;
		}
		
		
		
		
		/**
		 * 解析界面配置文件夹完成
		 */
		private function parseDirComplete(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, parseDirComplete);
			Toolbox.progressPanel.hide();
			
			configTree.dataProvider = new ArrayCollection(_data);
			
			if(_loadedCallback != null) {
				_loadedCallback();
				_loadedCallback = null;
			}
		}
		
		
		
		
		
		/**
		 * 刷新资源库
		 * @param event
		 */
		protected function refreshBtn_clickHandler(event:MouseEvent):void
		{
			this.setFocus();
			loadRes();
		}
		
		
		
		/**
		 * 创建一个配置文件
		 * @param event
		 */
		protected function createBtn_clickHandler(event:MouseEvent):void
		{
			this.setFocus();
			createConfigPanel.show();
		}
		//
	}
}