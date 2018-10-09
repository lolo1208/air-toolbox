package toolbox.views
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.Panel;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	
	import toolbox.Toolbox;
	import toolbox.data.SharedData;
	
	
	/**
	 * 项目面板
	 * @author LOLO
	 */
	public class ProjectPanel extends Panel
	{
		private const TIPS:String = "请选择资源库的根目录，例如：res/zh_CN";
		private const ERROR_TIPS:String = "错误的资源库根目录！";
		
		public var projectList:List;
		public var projectText:TextInput;
		public var browseBtn:Button;
		public var openBtn:Button;
		public var cancelBtn:Button;
		
		/**切换或刷新项目成功后的回调*/
		private static var _callback:Function;
		/**资源库根目录文件夹*/
		private static var _resRootDir:File;
		
		
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			_resRootDir = new File();
			_resRootDir.addEventListener(Event.SELECT, resRootDir_selectHandler);
		}
		
		
		
		
		protected function projectList_changeHandler(event:IndexChangeEvent):void
		{
			projectText.text = projectList.selectedItem;
		}
		
		
		protected function browseBtn_clickHandler(event:MouseEvent):void
		{
			try { _resRootDir.nativePath = projectText.text; }
			catch(error:Error) {}
			
			_resRootDir.browseForDirectory(TIPS);
		}
		
		protected function openBtn_clickHandler(event:MouseEvent):void
		{
			var path:String = projectText.text;
			
			try { _resRootDir.nativePath = path; }
			catch(error:Error)
			{
				Alert.show(ERROR_TIPS, "提示", 4, null, resRootDirErrorHandler);
				return;
			}
			
			if(!checkPath()) return;
			
			Toolbox.resRootDir = path;
			refresh(_callback);
		}
		
		protected function cancelBtn_clickHandler(event:MouseEvent):void
		{
			hide();
		}
		
		
		
		private function resRootDir_selectHandler(event:Event):void
		{
			Toolbox.resRootDir = _resRootDir.nativePath;
			
			if(checkPath()) refresh(_callback);
		}
		
		
		
		/**
		 * 选择项目（切换项目）
		 */
		public function choose(callback:Function=null):void
		{
			_callback = callback;
			show();
		}
		
		
		
		
		/**
		 * 刷新项目
		 */
		public function refresh(callback:Function=null):void
		{
			_callback = callback;
			
			if(Toolbox.resRootDir == null
				|| !(new File(Toolbox.resRootDir).exists)
			) {
				Alert.show(TIPS, "提示", 4, null, resRootDirErrorHandler);
				return;
			}
			
			//自动判定是 AS项目 还是 H5项目
			SharedData.data.settings.appType = new File(Toolbox.resRootDir + "json/core").exists ? 2 : 1;
			SharedData.save();
			
			if(_callback != null) {
				_callback();
				_callback = null;
			}
			
			hide();
		}
		
		private function resRootDirErrorHandler(event:CloseEvent):void
		{
			choose(_callback);
		}
		
		
		
		private function checkPath():Boolean
		{
			if(		new File(Toolbox.resRootDir + "ani").exists
				&&	new File(Toolbox.resRootDir + "ui").exists
			) {
				return true;
			}
			else {
				Alert.show(ERROR_TIPS, "提示", 4, null, resRootDirErrorHandler);
				return false;
			}
		}
		
		
		
		
		private function stage_resizeHandler(event:Event=null):void
		{
			this.x = Toolbox.app.stage.stageWidth - width >> 1;
			this.y = Toolbox.app.stage.stageHeight - height >> 1;
		}
		
		
		/**
		 * 显示面板
		 */
		public function show():void
		{
			if(!this.parent) {
				PopUpManager.addPopUp(this, Toolbox.app, true);
				Toolbox.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
				stage_resizeHandler();
			}
			
			var list:Array = SharedData.data.resRootDirHistorys;
			projectList.dataProvider = new ArrayList(list);
			
			var path:String = Toolbox.resRootDir;
			if(path != null) {
				projectText.text = path;
				
				projectList.selectedIndex = list.indexOf(path);
			}
		}
		
		
		/**
		 * 隐藏面板
		 */
		public function hide():void
		{
			if(this.parent) {
				PopUpManager.removePopUp(this);
				Toolbox.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
			}
		}
		//
	}
}