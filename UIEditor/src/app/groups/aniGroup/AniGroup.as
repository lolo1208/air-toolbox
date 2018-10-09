package app.groups.aniGroup
{
	import app.common.AppCommon;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Tree;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.Button;
	import spark.components.NavigatorContent;
	
	import toolbox.config.AniConfig;
	
	/**
	 * 动画资源容器
	 * @author LOLO
	 */
	public class AniGroup extends NavigatorContent
	{
		public var aniTree:Tree;
		public var refreshBtn:Button;
		
		
		/**加载资源库完成后的回调*/
		private var _loadedCallback:Function;
		
		
		
		public function AniGroup()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			
		}
		
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			aniTree.width = this.width - 2;
			aniTree.height = this.height - 1;
		}
		
		
		/**
		 * 加载资源库
		 * @param callback 加载资源库完成后的回调
		 */
		public function loadRes(callback:Function=null):void
		{
			_loadedCallback = callback;
			AniConfig.refreshComplete = refreshComplete;
			AniConfig.refresh(true);
		}
		
		
		
		/**
		 * 刷新AnimationConfig.xml，加载缓存数据完成
		 */
		private function refreshComplete():void
		{
			aniTree.dataProvider = AniConfig.treeData;
			
			if(_loadedCallback != null) {
				_loadedCallback();
				_loadedCallback = null;
			}
		}
		
		
		
		/**
		 * 运行动画打包工具
		 * @param event
		 */
		protected function toolBtn_clickHandler(event:MouseEvent):void
		{
			this.setFocus();
			AppCommon.app.openTool(3);
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