package app.groups.skinGroup
{
	import app.common.AppCommon;
	import app.controls.Reload;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import lolo.core.Common;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.List;
	import spark.components.NavigatorContent;
	
	import toolbox.config.SkinConfig;
	
	/**
	 * 皮肤列表容器
	 * @author LOLO
	 */
	public class SkinGroup extends NavigatorContent
	{
		public var skinList:List;
		public var preview:SkinPreviewPanel;
		
		
		/**加载样式完成后的回调*/
		private var _completeCallback:Function;
		
		
		
		public function SkinGroup()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			
		}
		
		
		protected function addedToStageHandler(event:Event):void
		{
			Common.stage.addChild(preview);
		}
		
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			skinList.width = this.width - 2;
			skinList.height = this.height - 1;
		}
		
		
		
		
		/**
		 * 加载资源库
		 * @param rootDir
		 */
		public function loadRes(callback:Function=null):void
		{
			_completeCallback = callback;
			SkinConfig.load(congfigLoadComplete);
		}
		
		private function congfigLoadComplete():void
		{
			skinList.dataProvider = new ArrayList(SkinConfig.skinList);
			
			//更新各样式选项的 DropDownList
			AppCommon.style.headG.refreshSkinList();
			AppCommon.style.scrollBarG.refreshSkinList();
			
			if(_completeCallback != null) {
				_completeCallback();
				_completeCallback = null;
			}
		}
		
		
		
		/**
		 * 刷新皮肤列表
		 */
		public function refresh():void
		{
			Reload.alert("刷新皮肤列表", refreshCallback);
		}
		
		protected function refreshBtn_clickHandler(event:MouseEvent):void
		{
			this.setFocus();
			refresh();
		}
		
		private function  refreshCallback(confirmed:Boolean):void
		{
			if(confirmed) loadRes(Reload.reload);
		}
		
		
		
		
		/**
		 * 运行皮肤编辑器
		 * @param event
		 */
		protected function toolBtn_clickHandler(event:MouseEvent):void
		{
			this.setFocus();
			AppCommon.app.openTool(4);
		}
		//
	}
}