package app.ldExport
{
	import app.common.AppCommon;
	
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import lolo.core.Constants;
	import lolo.utils.StringUtil;
	import lolo.utils.TimeUtil;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	import spark.components.TextInput;
	
	import toolbox.Toolbox;
	import toolbox.controls.GroupBox;
	
	
	/**
	 * 自定义数据导出工具
	 * @author LOLO
	 */
	public class LdExport extends GroupBox
	{
		public var dirText:TextInput;
		public var dirBtn:Button;
		public var updateBtn:Button;
		
		private var _dir:File;
		private var _list:Array = [];
		private var _file:File;
		
		private var _startTime:Number;
		
		
		
		
		public function LdExport()
		{
			super();
		}
		
		
		public function init():void
		{
			_dir = new File();
			_dir.addEventListener(Event.SELECT, dirSelectHandler);
			
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragDropHandler);
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragDropHandler);
		}
		
		
		protected function nativeDragDropHandler(event:NativeDragEvent):void
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
			try {
				_dir.nativePath = dirText.text;
			}
			catch(error:Error) {}
			_dir.browseForDirectory("请选择数据包所在的目录");
		}
		
		
		private function dirSelectHandler(event:Event):void
		{
			dirText.text = _dir.nativePath;
		}
		
		
		protected function exportBtn_clickHandler(event:MouseEvent):void
		{
			_dir.nativePath = dirText.text;
			
			if(!_dir.exists || !_dir.isDirectory)
			{
				Alert.show("文件夹：" + dirText.text + " 不存在！");
				return;
			}
			
			_list.length = 0;
			findFile(_dir);
			
			if(_list.length == 0) {
				Alert.show("文件夹：" + dirText.text + " 下没有资源包文件！");
				return;
			}
			
			_startTime = TimeUtil.getTime();
			AppCommon.app.logger.clear();
			Toolbox.progressPanel.show(_list.length + 1);
			
			//开始导出
			try { new File(Toolbox.docPath).deleteDirectory(true); }
			catch(error:Error) {}
			exportNext();
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
		 * 导出下一个资源包文件
		 */
		public function exportNext(lastFile:File=null, errMsg:String=null):void
		{
			if(lastFile != null)
			{
				if(errMsg == null) {
					AppCommon.app.logger.addLog("已导出：" + lastFile.nativePath);
				}
				else {
					AppCommon.app.logger.addErrorLog("导出：" + lastFile.nativePath + " 出错");
					AppCommon.app.logger.addErrorLog(errMsg);
				}
			}
			
			if(_list.length == 0)
			{
				Toolbox.progressPanel.hide();
				AppCommon.app.logger.addLog("耗时：" + TimeUtil.format(TimeUtil.getTime() - _startTime));
				AppCommon.app.logger.addSuccLog("<b>导出完毕！</b>");
				AppCommon.app.logger.show("导出日志");
				Alert.show("导出完毕！", "提示", 4, null, alert_closeHandler);
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
				ExportAni.export(_file);
			}
			else if(flag == Constants.FLAG_IDP || flag == Constants.FLAG_LIDP)
			{
				ExportUI.export(_file);
			}
			else {
				exportNext();
			}
		}
		
		
		
		/**
		 * 查看导出文件夹
		 * @param event
		 */
		private function alert_closeHandler(event:CloseEvent):void
		{
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var args:Vector.<String> = new Vector.<String>();
			args.push(StringUtil.slashToBackslash(
				Toolbox.docPath.substr(0, Toolbox.docPath.length - 1)
			));
			info.executable = new File(Toolbox.explorerPath);
			info.arguments = args;
			new NativeProcess().start(info);
		}
		//
	}
}