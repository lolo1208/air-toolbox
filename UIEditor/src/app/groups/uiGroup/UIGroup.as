package app.groups.uiGroup
{
	import app.common.AppCommon;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Tree;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.Button;
	import spark.components.NavigatorContent;
	
	import toolbox.config.UIConfig;
	
	/**
	 * 界面资源容器
	 * @author LOLO
	 */
	public class UIGroup extends NavigatorContent
	{
		public var uiTree:Tree;
		public var refreshBtn:Button;
		
		
		/**加载资源库完成后的回调*/
		private var _loadedCallback:Function;
		
		
		
		public function UIGroup()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			
		}
		
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			uiTree.width = this.width - 2;
			uiTree.height = this.height - 1;
		}
		
		
		
		/**
		 * 加载资源库
		 * @param callback 加载资源库完成后的回调
		 */
		public function loadRes(callback:Function=null):void
		{
			_loadedCallback = callback;
			UIConfig.refreshComplete = refreshComplete;
			UIConfig.refresh(true);
		}
		
		
		
		/**
		 * 刷新BitmapSpriteConfig.xml，加载UI图像数据完成
		 */
		private function refreshComplete():void
		{
			uiTree.dataProvider = UIConfig.treeData;
			
			if(_loadedCallback != null) {
				_loadedCallback();
				_loadedCallback = null;
			}
		}
		
		
		
		/**
		 * 运行界面打包工具
		 * @param event
		 */
		protected function toolBtn_clickHandler(event:MouseEvent):void
		{
			this.setFocus();
			AppCommon.app.openTool(2);
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
		//
	}
}