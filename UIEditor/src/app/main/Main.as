package app.main
{
	import app.common.AppCommon;
	import app.common.Controller;
	import app.common.ImageAssets;
	import app.controls.Reload;
	import app.controls.Save;
	import app.effects.AppEffect;
	import app.groups.canvasGroup.CanvasGroupView;
	import app.layers.Layer;
	import app.utils.LayerUtil;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.filesystem.File;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import lolo.components.AlertText;
	import lolo.components.ImageLoader;
	import lolo.core.Common;
	import lolo.core.ConfigManager;
	import lolo.core.LanguageManager;
	import lolo.core.LoadManager;
	import lolo.core.UIManager;
	import lolo.data.LRUCache;
	import lolo.display.Animation;
	import lolo.display.BitmapSprite;
	import lolo.events.ConsoleEvent;
	import lolo.ui.Console;
	import lolo.utils.ObjectUtil;
	import lolo.utils.logging.LogEvent;
	import lolo.utils.logging.Logger;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.MenuBar;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.WindowedApplication;
	
	import toolbox.Toolbox;
	import toolbox.config.EmbedFontConfig;
	import toolbox.config.LanguageConfig;
	import toolbox.config.StyleConfig;
	import toolbox.controls.IconTips;
	import toolbox.data.SharedData;
	import toolbox.utils.Helper;
	
	public class Main extends WindowedApplication
	{
		public var menuBar:MenuBar;
		public var lt:LeftTopView;
		public var lb:LeftBottomView;
		public var rt:RightTopView;
		public var rb:RightBottomView;
		public var canvas:CanvasGroupView;
		
		public var savedTips:IconTips;
		
		
		[Bindable]
		public var menuData:ArrayCollection;
		
		/**在项目刷新后，是否需要重载当前配置文件*/
		private var _needRelad:Boolean;
		
		
		
		public function Main()
		{
			super();
		}
		
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			AppCommon.app = this;
			AppCommon.canvas = canvas;
			AppCommon.toolbar = canvas.toolbar;
			AppCommon.ui = lt.uiGroup;
			AppCommon.ani = lt.aniGroup;
			AppCommon.config = rt.configGroup;
			AppCommon.layer = rt.layerGroup;
			AppCommon.component = lb.componentGroup;
			AppCommon.skin = lb.skinGroup;
			AppCommon.prop = rb.propGroup
			AppCommon.style = rb.styleGroup;
			AppCommon.controller = new Controller();
			
			savedTips = new IconTips(ImageAssets.getInstance("Saved"));
			this.addElement(savedTips);
			
			resizeHandler();
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			Toolbox.initialize(this, stage);
			Toolbox.setToolInfo("uiEditor", "界面编辑器");
			
			menuData = new ArrayCollection([
				{ label:"文件", children:[
					{label:"打开"},
					{label:"重载", enabled:false},
					{label:"关闭", enabled:false},
					{type:"separator"},
					{label:"保存", enabled:false}
				]},
				{ label:"项目", children:[
					{label:"刷新当前项目"},
					{label:"切换项目"},
					{type:"separator"},
					{label:"设置"}
				]},
				{ label:"工具", children:[
					{label:"界面打包"},
					{label:"动画打包"},
					{label:"皮肤编辑器"},
					{type:"separator"},
					{label:"工具箱"}
				]},
				{ label:"帮助", children:[
					{label:"关于"},
					{label:"ver: " + Toolbox.version, enabled:false},
					{label:"检查更新"}
				]}
			]);
			
			
			//初始化框架相关环境
			Common.ui = new UIManager();
			Common.loader = LoadManager.getInstance();
			Common.config = ConfigManager.getInstance();
			Common.language = LanguageManager.getInstance();
			Common.getResUrl = AppCommon.getResUrl;
			
			BitmapSprite.cache = new LRUCache();
			BitmapSprite.cache.deadline = 24 * 60 * 60 * 1000;
			BitmapSprite.cache.maxMemorySize = 500 * 1024 * 1024;
			BitmapSprite.config = new Dictionary();
			
			Animation.cache = new LRUCache();
			Animation.cache.deadline = 24 * 60 * 60 * 1000;
			Animation.cache.maxMemorySize = 500 * 1024 * 1024;
			Animation.config = new Dictionary();
			
			Common.ui.initialize();
			ImageLoader.initialize();
			Common.stage.addChild(Common.ui as DisplayObject);
			Console.getInstance().addEventListener(ConsoleEvent.INPUT, console_inputHandler);
			
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, Logger.uncaughtErrorHandler);
			Logger.addEventListener(LogEvent.ERROR_LOG, errorLogHandler);
			//
			
			Common.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler, true);
			Common.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			
			Toolbox.projectPanel.refresh(refreshProject);
		}
		
		protected function resizeHandler(event:ResizeEvent=null):void
		{
			if(menuBar == null) return;
			
			menuBar.width = width;
			
			var gap1:int = 10;
			var gap2:int = 5;
			var w:int = width;
			var h:int = height - 35;
			
			lt.height = Math.round(h * 0.65);
			lb.height = h - lt.height - gap1 - gap2;
			lb.y = lt.y + lt.height + gap1;
			
			rt.height = Math.round(h * 0.35);
			rt.x = w - rt.width - gap2;
			rb.height = h - rt.height - gap1 - gap2;
			rb.y = rt.y + rt.height + gap1;
			rb.x = rt.x;
			
			canvas.width = w - lt.width - rt.width - gap1 * 2 - gap2 * 2;
			canvas.height = h - gap2;
		}
		
		
		
		/**
		 * 快捷键
		 * @param event
		 */
		private function stage_keyDownHandler(event:KeyboardEvent):void
		{
			if(AppCommon.keyboardUsing) return;
			
			switch(event.keyCode)
			{
				case Keyboard.UP:
					if(selectedLayer == null) break;
					
					if(event.ctrlKey) {
						AppCommon.layer.selectSideLayer(selectedLayer, true);
					}
					else if(event.shiftKey) {
						AppCommon.layer.swapLayerDepth(selectedLayer, true);
					}
					else {
						if(selectedLayer.canDrag()) selectedLayer.y--;
					}
					
					event.stopImmediatePropagation();
					break;
				
				case Keyboard.DOWN:
					if(selectedLayer == null) break;
					
					if(event.ctrlKey) {
						AppCommon.layer.selectSideLayer(selectedLayer, false);
					}
					else if(event.shiftKey) {
						AppCommon.layer.swapLayerDepth(selectedLayer, false);
					}
					else {
						if(selectedLayer.canDrag()) selectedLayer.y++;
					}
					
					event.stopImmediatePropagation();
					break;
				
				case Keyboard.LEFT:
					if(selectedLayer == null) break;
					if(selectedLayer.canDrag()) selectedLayer.x--;
					event.stopImmediatePropagation();
					break;
				
				case Keyboard.RIGHT:
					if(selectedLayer == null) break;
					if(selectedLayer.canDrag()) selectedLayer.x++;
					event.stopImmediatePropagation();
					break;
				
				case Keyboard.DELETE:
					if(selectedLayer == null) break;
					if(LayerUtil.isContainer()) return;
					AppCommon.controller.removeLayer(selectedLayer);
					AppCommon.controller.selectLayer(AppCommon.controller.currentContainerLayer);
					event.stopImmediatePropagation();
					break;
				
				case Keyboard.Z:
					//if(event.ctrlKey) AppCommon.undoManager.undo();
					break;
				
				case Keyboard.Y:
					//if(event.ctrlKey) AppCommon.undoManager.redo();
					break;
			}
			
			AppCommon.prop.updateBounds();
		}
		
		
		private function stage_keyUpHandler(event:KeyboardEvent):void
		{
			if(AppCommon.keyboardUsing) return;
			
			switch(event.keyCode)
			{
				case Keyboard.S:
					if(event.ctrlKey) Save.save();
					break;
				
				case Keyboard.F5:
					AppCommon.controller.update();
					break;
			}
		}
		
		
		
		
		/**
		 * 菜单栏
		 * @param event
		 */
		protected function menuBar_itemClickHandler(event:MenuEvent):void
		{
			switch(event.label)
			{
				case "打开": openConfigXml(); break;
				case "重载": reloadConfigXml(); break;
				case "关闭": closeConfigXml(); break;
				case "保存": Save.save(); break;
				
				case "刷新当前项目": refreshProject(); break;
				case "切换项目": chooseProject(); break;
				case "设置": Toolbox.settingsPanel.show(); break;
				
				case "关于": Helper.about(); break;
				case "检查更新": Helper.checkUpdate(); break;
				
				case "界面打包": openTool(2); break;
				case "动画打包": openTool(3); break;
				case "皮肤编辑器": openTool(4); break;
				case "工具箱": openTool(1); break;
			}
		}
		
		
		
		
		
		/**
		 * 刷新项目
		 */
		private function refreshProject():void
		{
			Reload.alert("刷新当前项目", refreshProject_reloadAlertCallback);
		}
		
		private function refreshProject_reloadAlertCallback(confirmed:Boolean):void
		{
			if(!confirmed) return;
			_needRelad = true;
			Toolbox.projectPanel.refresh(doRefreshProject);
		}
		
		
		/**
		 * 切换项目
		 */
		private function chooseProject():void
		{
			Reload.alert("切换项目", chooseProject_reloadAlertCallback, false);
		}
		
		private function chooseProject_reloadAlertCallback(confirmed:Boolean):void
		{
			if(!confirmed) return;
			AppCommon.controller.clear();
			Toolbox.projectPanel.choose(doRefreshProject);
		}
		
		
		/**
		 * 执行项目刷新
		 */
		private function doRefreshProject():void
		{
			function step1():void { lt.uiGroup.loadRes(step2); }
			function step2():void { lt.aniGroup.loadRes(step3); }
			function step3():void { rt.configGroup.loadRes(step4); }
			function step4():void { lb.skinGroup.loadRes(step5); }
			function step5():void { EmbedFontConfig.load(step6); }
			function step6():void { LanguageConfig.load(step7); }
			function step7():void { StyleConfig.load(step8); }
			
			step1();
			function step8():void
			{
				var at:AlertText = AlertText.getInstance("failed");
				at.colorIndex = 0;
				at.alertLayerShow = true;
				
				at = AlertText.getInstance("succeeded");
				at.colorIndex = 1;
				at.alertLayerShow = true;
				
				if(_needRelad) {
					_needRelad = false;
					Reload.reload();
				}
				
				lb.componentGroup.refresh();
				
				//根据项目类型来禁用某些属性和样式
				rb.propGroup.textFieldG.embedFontsDDL.enabled
					= rb.propGroup.textFieldG.autoSizeDDL.enabled
					= rb.styleGroup.labelG.moreTextText.enabled
					
					= Toolbox.isASProject;
			}
		}
		
		
		
		
		
		/**
		 * 打开界面配置文件
		 */
		private function openConfigXml():void
		{
			var alertText:AlertText = AlertText.getInstance("succeeded");
			alertText.moveToStageMousePosition();
			alertText.show("请在配置面板打开要编辑的界面配置文件！");
			
			rt.contentVS.selectedIndex = 0;
			AppEffect.glowFilterAni(rt, 0x00FF00);
		}
		
		
		/**
		 * 重载界面配置文件
		 */
		private function reloadConfigXml():void
		{
			Alert.show("您确定要重载当前配置文件吗？", "提示", Alert.YES|Alert.NO, null, reloadAlert_closeHandler);
		}
		
		private function reloadAlert_closeHandler(event:CloseEvent):void
		{
			if(event.detail != Alert.YES) return;
			Reload.reload();
		}
		
		
		/**
		 * 关闭界面配置文件
		 */
		private function closeConfigXml():void
		{
			Alert.show("您确定要关闭当前配置文件吗？", "提示", Alert.YES|Alert.NO, null, closeAlert_closeHandler);
		}
		
		private function closeAlert_closeHandler(event:CloseEvent):void
		{
			if(event.detail != Alert.YES) return;
			rt.contentVS.selectedIndex = 0;
			AppCommon.controller.clear();
			//禁用重载、关闭和保存菜单项
			AppCommon.app.menuData.getItemAt(0).children[1].enabled = false;
			AppCommon.app.menuData.getItemAt(0).children[2].enabled = false;
			AppCommon.app.menuData.getItemAt(0).children[4].enabled = false;
		}
		
		
		
		
		/**
		 * 打开某个工具
		 * @param type 工具类型
		 */
		public function openTool(type:int):void
		{
			var tool:String, name:String;
			switch(type)
			{
				case 1:
					tool = "toolbox";
					name = "工具箱";
					break;
				
				case 2:
					tool = "uiPackager";
					name = "界面打包工具";
					break;
				
				case 3:
					tool = "animationPackager";
					name = "动画打包工具";
					break;
				
				case 4:
					tool = "skinEditor";
					name = "皮肤编辑器";
					break;
			}
			
			var toolInfo:Object = SharedData.data[tool];
			if(toolInfo == null) {
				Alert.show("[" + name + "]不存在，请通过[工具箱]进行安装！", "提示", 4, null, openToolErrorAlert_closeHandler);
				return;
			}
			
			var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npsi.executable = new File(toolInfo.path);
			new NativeProcess().start(npsi);
		}
		
		private function openToolErrorAlert_closeHandler(event:CloseEvent):void
		{
			openTool(1);
		}
		
		
		
		
		/**
		 * 当前选中的图层
		 */
		private function get selectedLayer():Layer { return AppCommon.controller.selectedLayer; }
		
		
		
		
		/**
		 * 有新的错误产生
		 * @param event
		 */
		private function errorLogHandler(event:LogEvent):void
		{
			Alert.show(
				"出错了！！！\n\n" +
				"-= 请不要继续编辑或保存XML =-\n\n" +
				"点击 [Yes] 可查看错误详情",
				"提示", Alert.YES | Alert.NO, null, closeHandler);
		}
		
		private function closeHandler(event:CloseEvent):void
		{
			if(event.detail == Alert.YES) {
				Console.getInstance().showLog(Logger.LOG_TYPE_ERROR, 1);
				Console.getInstance().inputText.text = "log error 1";
				stage.focus = Console.getInstance().inputText;
			}
		}
		
		
		
		/**
		 * 控制台有数据推送过来
		 * @param event
		 */
		private function console_inputHandler(event:ConsoleEvent):void
		{
			var content:String = event.data;
			
			var arr:Array = content.split(" ");
			var args:Array = [];
			var len:int = arr.length;
			for(var i:int = 0; i < len; i++) if(arr[i] != "") args.push(arr[i]);
			if(!args[0]) return;
			
			switch(args[0].toLocaleLowerCase())
			{
				case "aaa":
					break;
				
				case "bbb":
					break;
			}
		}
		//
	}
}