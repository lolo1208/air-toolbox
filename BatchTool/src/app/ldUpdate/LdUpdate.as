package app.ldUpdate
{
	import app.common.AppCommon;
	
	import flash.desktop.NativeDragManager;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import lolo.core.Constants;
	import lolo.utils.TimeUtil;
	
	import spark.components.Button;
	import spark.components.TextInput;
	
	import toolbox.Toolbox;
	import toolbox.config.AniConfig;
	import toolbox.config.UIConfig;
	import toolbox.controls.GroupBox;
	import toolbox.data.SharedData;
	
	/**
	 * 数据包批量更新工具
	 * @author LOLO
	 */
	public class LdUpdate extends GroupBox
	{
		public var dirText:TextInput;
		public var dirBtn:Button;
		public var updateBtn:Button;
		
		private var _dir:File;
		private var _list:Array = [];
		private var _file:File;
		
		private var _uiNum:uint;
		private var _aniNum:uint;
		private var _numCount:Object;
		private var _startTime:Number;
		
		
		
		public function LdUpdate()
		{
			super();
		}
		
		
		
		public function init():void
		{
			_dir = new File();
			try {
				_dir.nativePath = SharedData.data.lastUpdateLdDir;
				dirText.text = _dir.nativePath;
			}
			catch(error:Error) {}
			
			_dir.addEventListener(Event.SELECT, dirSelectHandler);
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, treeGroup_nativeDragDropHandler);
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, treeGroup_nativeDragDropHandler);
		}
		
		
		protected function treeGroup_nativeDragDropHandler(event:NativeDragEvent):void
		{
			var file:File = event.clipboard.getData(event.clipboard.formats[0])[0];
			if(file == null) return;//不是文件
			
			if(event.type == NativeDragEvent.NATIVE_DRAG_ENTER) {
				NativeDragManager.acceptDragDrop(event.target as InteractiveObject);
			}
			else {
				dirText.text = file.isDirectory ? file.nativePath : file.parent.nativePath;
			}
		}
		
		
		protected function dirBtn_clickHandler(event:MouseEvent):void
		{
			if(dirText.text == "") dirText.text = Toolbox.resRootDir;
			
			_dir.nativePath = dirText.text;
			SharedData.data.lastUpdateLdDir = _dir.nativePath;
			SharedData.save();
			
			_dir.browseForDirectory("请选择需要更新的目录（目录路径越深，更新速度越快）");
		}
		
		
		private function dirSelectHandler(event:Event):void
		{
			dirText.text = _dir.nativePath;
			SharedData.data.lastUpdateLdDir = _dir.nativePath;
			SharedData.save();
		}
		
		
		protected function updateBtn_clickHandler(event:MouseEvent):void
		{
			_dir.nativePath = dirText.text;
			SharedData.data.lastUpdateLdDir = dirText.text;
			SharedData.save();
			
			var dir:String = dirText.text.replace(/\\/g, "/");
			if(dir.indexOf(Toolbox.resRootDir.substr(0, Toolbox.resRootDir.length - 1)) != 0)
			{
				alert("请选择当前项目：<b>" + Toolbox.resRootDir + "</b> 目录下的文件夹！");
				return;
			}
			
			if(!_dir.exists || !_dir.isDirectory)
			{
				alert("文件夹：<b>" + dir + "</b> 不存在！");
				return;
			}
			
			
			_list.length = 0;
			_uiNum = _aniNum = 0;
			_numCount = { ui:0, ani:0 };
			findFile(_dir);
			if(_list.length == 0) {
				alert("文件夹：<b>" + dir + "</b> 下没有资源包文件！");
				return;
			}
			
			_startTime = TimeUtil.getTime();
			AppCommon.app.logger.clear();
			Toolbox.progressPanel.show(_list.length + 1);
			updateNext();//开始更新
		}
		
		
		
		/**
		 * 查找文件夹下的资源包文件
		 * @param dir
		 */
		private function findFile(dir:File):void
		{
			var files:Array = dir.getDirectoryListing();
			for(var i:int = 0; i < files.length; i++)
			{
				var file:File = files[i];
				if(file.isDirectory) {
					findFile(file);
				}
				else {
					if(file.extension.toLocaleLowerCase() == Constants.EXTENSION_LD) _list.push(file);
				}
			}
		}
		
		
		
		/**
		 * 更新下一个资源包文件
		 * @param type [ 0:不增加，1:ui包数量+1，动画包数量+1 ]
		 */
		public function updateNext(type:int=0):void
		{
			if(type == 1) _uiNum++;
			else if(type == 2) _aniNum++;
			
			if(_list.length == 0)
			{
				Toolbox.progressPanel.hide();
				updateConfig();
				AppCommon.app.logger.addSuccLog("<b>更新完毕！</b>");
				return;
			}
			
			Toolbox.progressPanel.addProgress();
			
			_file = _list.pop();
			_file.addEventListener(Event.COMPLETE, fileCompleteHandler);
			_file.load();
		}
		
		
		
		/**
		 * 加载资源包文件完毕
		 * @param event
		 */
		private function fileCompleteHandler(event:Event):void
		{
			_file.removeEventListener(Event.COMPLETE, fileCompleteHandler);
			
			var bytes:ByteArray = _file.data;
			try { bytes.uncompress(); } catch(error:Error) {}
			var flag:uint = bytes.readUnsignedByte();
			bytes.position = 0;
			
			if(flag == Constants.FLAG_AD)
			{
				UpdateAni.update(_file);
			}
			else if(flag == Constants.FLAG_IDP || flag == Constants.FLAG_LIDP)
			{
				UpdateUI.update(_file);
			}
			else {
				updateNext(0);
			}
		}
		
		
		
		
		/**
		 * 出错了，停止更新
		 * @param msg
		 */
		public function stop(msg:String):void
		{
			Toolbox.progressPanel.hide();
			updateConfig();
			AppCommon.app.logger.addErrorLog("<b>错误信息：</b>" + msg);
			AppCommon.app.logger.addErrorLog("出错的数据包：" + _file.nativePath);
		}
		
		
		
		/**
		 * 刷新对应的Config
		 */
		private function updateConfig():void
		{
			if(_uiNum > 0) {
				_numCount.ui = _uiNum;
				_uiNum = 0;
				UIConfig.refreshComplete = updateConfig;
				UIConfig.refresh(false);
				AppCommon.app.logger.addLog("已更新：" + (Toolbox.isASProject ? "BitmapSpriteConfig.xml" : "BitmapConfig.json"));
			}
			else if(_aniNum > 0) {
				_numCount.ani = _aniNum;
				_aniNum = 0;
				AniConfig.refreshComplete = updateConfig;
				AniConfig.refresh(false);
				AppCommon.app.logger.addLog("已更新：" + (Toolbox.isASProject ? "AnimationConfig.xml" : "AnimationConfig.json"));
			}
			else {
				updateComplete();
			}
		}
		
		
		private function updateComplete():void
		{
			AppCommon.app.logger.addLog("本次已更新：" +
				"UI<b> " + _numCount.ui + " </b>个，" +
				"动画<b> " + _numCount.ani + " </b>个，" +
				"共<b> " + (_numCount.ui + _numCount.ani) + " </b>个文件。"
			);
			AppCommon.app.logger.addLog("耗时：" + TimeUtil.format(TimeUtil.getTime() - _startTime));
			AppCommon.app.logger.show("更新日志");
		}
		
		
		
		private function alert(msg:String):void
		{
			AppCommon.app.logger.clear();
			AppCommon.app.logger.addErrorLog(msg);
			AppCommon.app.logger.show("更新失败");
		}
		
		//
	}
}