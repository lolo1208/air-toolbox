package app.main
{
	import app.canvasGroup.CanvasGroupView;
	import app.common.AppCommon;
	import app.fileGroup.FileGroupView;
	import app.operationGroup.OperationGroupView;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.ui.Console;
	import lolo.utils.StringUtil;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.MenuBar;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.WindowedApplication;
	
	import toolbox.Toolbox;
	import toolbox.config.AniConfig;
	import toolbox.data.SharedData;
	import toolbox.utils.Helper;
	
	/**
	 * 动画打包
	 * @author LOLO
	 */
	public class Main extends WindowedApplication
	{
		public var menuBar:MenuBar;
		public var fileGroup:FileGroupView;
		public var operationGroup:OperationGroupView;
		public var canvasGroup:CanvasGroupView;
		
		[Bindable]
		public var menuData:ArrayCollection;
		
		/**当前打开的LD源文件*/
		public var ldFile:File;
		/**数据包中路径已经失效的动画列表*/
		private var _notExistImgList:Array = [];
		
		
		public function Main()
		{
			super();
		}
		
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			AppCommon.app = this;
			resizeHandler();
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			Toolbox.initialize(this, stage);
			Toolbox.setToolInfo("animationPackager", "动画打包");
			
			menuData = new ArrayCollection([
				{ label:"文件", children:[
					{label:"打开文件"},
					{label:"打包所选动画", enabled:false},
					{label:"覆盖打包，并更新配置", enabled:false}
				]},
				{ label:"项目", children:[
					{label:"刷新当前项目"},
					{label:"切换项目"},
					{type:"separator"},
					{label:"更新配置"},
					{type:"separator"},
					{label:"设置"}
				]},
				{ label:"帮助", children:[
					{label:"关于"},
					{label:"ver: " + Toolbox.version, enabled:false},
					{label:"检查更新"}
				]}
			]);
			
			ldFile = new File();
			ldFile.addEventListener(Event.SELECT, ldFile_eventHandler);
			ldFile.addEventListener(Event.COMPLETE, ldFile_eventHandler);
			
			Common.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			
			Toolbox.projectPanel.refresh(refreshProject);
		}
		
		protected function resizeHandler(event:ResizeEvent=null):void
		{
			if(menuBar == null) return;
			
			menuBar.width = width;
			
			var h:int = height - 40;
			var lw:int = Math.max((width - 20) * 0.35, 270);
			if(lw > 450) lw = 450;
			fileGroup.width = lw;
			fileGroup.height = height - 30 - operationGroup.height;
			
			operationGroup.x = lw - operationGroup.width;
			operationGroup.y = height - operationGroup.height;
			
			canvasGroup.x = lw - 10;
			canvasGroup.width = width - lw + 10;
			canvasGroup.height = height - 35;
		}
		
		private function stage_keyUpHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.A:
					if(event.ctrlKey) openFile();
					break;
				
				case Keyboard.S:
					if(event.ctrlKey) operationGroup.startPack(true, true);
					break;
				
				case Keyboard.D:
					if(event.ctrlKey) operationGroup.startPack(true);
					break;
			}
		}
		
		
		
		
		protected function menuBar_itemClickHandler(event:MenuEvent):void
		{
			switch(event.label)
			{
				case "打开文件": openFile(); break;
				case "打包所选动画": operationGroup.startPack(); break;
				case "覆盖打包，并更新配置": operationGroup.startPack(true, true); break;
				case "刷新当前项目": Toolbox.projectPanel.refresh(refreshProject); break;
				case "切换项目": Toolbox.projectPanel.choose(refreshProject); break;
				case "更新配置": AniConfig.refresh(false); break;
				case "设置": Toolbox.settingsPanel.show(); break;
				case "关于": Helper.about(); break;
				case "检查更新": Helper.checkUpdate(); break;
			}
		}
		
		
		
		
		/**
		 * 刷新项目
		 * @param isOpenFile 是否为打开ld文件方式刷新
		 */
		private function refreshProject(isOpenFile:Boolean=false):void
		{
			fileGroup.reset();
			canvasGroup.reset();
			operationGroup.reset();
			
			menuData.getItemAt(0).children[2].enabled = isOpenFile;
			if(!isOpenFile) {
				AppCommon.saveFileName = "aniPackage";
				fileGroup.parse();
			}
		}
		
		
		
		/**
		 * 打开文件
		 */
		private function openFile():void
		{
			var err:Boolean;
			try {
				ldFile.nativePath = SharedData.data.lastAniLdFilePath;
			}
			catch(error:Error) {
				err = true;
			}
			if(err || !ldFile.exists) ldFile.nativePath = Toolbox.resRootDir;
			
			ldFile.browse([new FileFilter("动画数据包", "*.ld;*.ast")]);
		}
		
		/**
		 * 选择原始包，.ld文件相关事件
		 * @param event
		 */
		private function ldFile_eventHandler(event:Event):void
		{
			if(event.type == Event.SELECT)
			{
				SharedData.data.lastAniLdFilePath = ldFile.nativePath;
				SharedData.save();
				ldFile.load();
			}
			else
			{
				var bytes:ByteArray = ldFile.data;
				try { bytes.uncompress(); } catch(error:Error) {}
				if(bytes.readUnsignedByte() != Constants.FLAG_AD) {
					Alert.show("不是有效的动画数据包！", "提示");
					return;
				}
				
				var infoList:Dictionary = new Dictionary();
				bytes.readUnsignedInt();//图像数据的起始position
				var num:uint = bytes.readUnsignedByte();//包内包含的动画的数量
				for(var i:int=0; i < num; i++)
				{
					var name:String = bytes.readUTF();//动画的源名称
					var totalFrames:uint = bytes.readUnsignedShort();//动画总帧数
					var fps:uint = bytes.readUnsignedByte();//默认帧频
					var path:String = StringUtil.slashToBackslash(Toolbox.resRootDir + "ani")
						+ "\\" + name.replace(/\./g, "\\");
					
					//动画是否还存在
					var info:Object = { fps:fps };
					(new File(path).exists) ? infoList[path] = info : _notExistImgList.push(path);
					
					for(var n:int = 0; n < totalFrames; n++)
					{
						bytes.readUnsignedShort();//图像在 bigBitmapData 中的位置
						bytes.readUnsignedShort();
						bytes.readUnsignedShort();//帧宽高
						bytes.readUnsignedShort();
						
						//帧的X、Y偏移
						var point:Point = new Point(bytes.readShort(), bytes.readShort());
						if(info.p == null) {
							info.p = point;
							info.needOffset = true;
						}
					}
				}
				bytes.clear();
				
				
				refreshProject(true);
				canvasGroup.infoList = infoList;
				fileGroup.parse();
				
				AppCommon.saveFileName = ldFile.name.substr(0, ldFile.name.length - 4);
				menuData.getItemAt(0).children[2].enabled = true;
				
				
				//提示数据包中路径已经失效的动画列表
				if(_notExistImgList.length > 0)
				{
					Console.clear();
					Console.trace("=====================[数据包中路径已经失效的动画列表]===================");
					for each(var imgPath:String in _notExistImgList) Console.trace(imgPath);
					Console.trace("========================================================================");
					_notExistImgList = [];
				}
			}
		}
		
		//
	}
}