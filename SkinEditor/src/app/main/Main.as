package app.main
{
	import app.canvasGroup.CanvasGroupView;
	import app.common.AppCommon;
	import app.common.ImageAssets;
	import app.createPanel.CreatePanelView;
	import app.skinListGroup.SkinItemRenderer;
	import app.skinListGroup.SkinListGroupView;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.ui.Keyboard;
	
	import lolo.core.Common;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.MenuBar;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.WindowedApplication;
	
	import toolbox.Toolbox;
	import toolbox.controls.IconTips;
	import toolbox.utils.Helper;
	import toolbox.utils.SortJSONEncoder;
	
	
	
	/**
	 * 主界面，入口
	 * @author LOLO
	 */
	public class Main extends WindowedApplication
	{
		public var menuBar:MenuBar;
		public var skinListGroup:SkinListGroupView;
		public var canvasGroup:CanvasGroupView;
		public var createPanel:CreatePanelView;
		
		private var _savedTips:IconTips;
		
		[Bindable]
		public var menuData:ArrayCollection;
		
		
		
		public function Main()
		{
			super();
		}
		
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			menuBar.tabFocusEnabled = false;
			
			this.removeElement(createPanel);
			
			_savedTips = new IconTips(ImageAssets.getInstance("Saved"));
			this.addElement(_savedTips);
			
			AppCommon.app = this;
			resizeHandler();
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			Toolbox.initialize(this, stage);
			Toolbox.setToolInfo("skinEditor", "皮肤编辑器");
			
			menuData = new ArrayCollection([
				{ label:"项目", children:[
					{label:"刷新当前项目"},
					{label:"切换项目"},
					{type:"separator"},
					{label:"保存更改，更新配置 [Ctrl+S]"},
					{type:"separator"},
					{label:"设置"}
				]},
				{ label:"帮助", children:[
					{label:"关于"},
					{label:"ver: " + Toolbox.version, enabled:false},
					{label:"检查更新"}
				]}
			]);
			
			Toolbox.projectPanel.refresh(refreshProject);
			
			Common.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
		}
		
		protected function resizeHandler(event:ResizeEvent=null):void
		{
			if(menuBar == null) return;
			menuBar.width = width;
			skinListGroup.height = height - 40;
			canvasGroup.width = width - 320;
			canvasGroup.height = height - 40;
			createPanel.x = width - createPanel.width >> 1;
			createPanel.y = height * 0.94 - createPanel.height >> 1;
		}
		
		
		private function stage_keyUpHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.TAB)
			{
				var index:uint = canvasGroup.stateTimeLine.currentStateIndex;
				index++;
				if(index >= 8) index = 0;
				canvasGroup.stateTimeLine.currentStateIndex = index;
			}
			
			if(event.ctrlKey && event.keyCode == Keyboard.S) saveConfig();
		}
		
		
		
		/**
		 * 刷新项目
		 */
		private function refreshProject():void
		{
			skinListGroup.reset();
			canvasGroup.reset();
			
			skinListGroup.parse();
		}
		
		
		
		
		/**
		 * 检查皮肤是否重名
		 * @param name
		 * @return 
		 */
		public function checkRepeatName(name:String):void
		{
			var arr1:IList = skinListGroup.skinList.dataProvider;
			var arr2:Array = [];
			var i:int;
			for(i = 0; i < arr1.length; i++)
			{
				var itemData:Object = arr1.getItemAt(i);
				if(itemData.name == name) {
					arr2.push({index:i, data:itemData});
					itemData.repeat = false;
					showError(i);
				}
			}
			if(arr2.length == 1) return;
			
			for(i = 0; i < arr2.length; i++)
			{
				arr2[i].data.repeat = true;
				showError(arr2[i].index);
			}
		}
		
		
		
		
		public function showError(index:uint):void
		{
			var item:SkinItemRenderer = skinListGroup.skinList.dataGroup.getElementAt(index) as SkinItemRenderer;
			if(item != null) item.showError();
		}
		
		
		
		
		
		protected function menuBar_itemClickHandler(event:MenuEvent):void
		{
			switch(event.label)
			{
				case "刷新当前项目": Toolbox.projectPanel.refresh(refreshProject); break;
				case "切换项目": Toolbox.projectPanel.choose(refreshProject); break;
				case "保存更改，更新配置 [Ctrl+S]": saveConfig(); break;
				case "设置": Toolbox.settingsPanel.show(); break;
				case "关于": Helper.about(); break;
				case "检查更新": Helper.checkUpdate(); break;
			}
		}
		
		
		
		
		/**
		 * 保存 Skin.xml 配置文件
		 */
		public function saveConfig():void
		{
			if(skinListGroup.skinList.dataProvider == null) return;
			
			var lastName:String;
			if(skinListGroup.skinList.selectedItem != null) lastName = skinListGroup.skinList.selectedItem.name;
			
			var arrList:ArrayList = skinListGroup.skinList.dataProvider as ArrayList;
			var arr:Array = arrList.source;
			arr.sortOn("name", Array.CASEINSENSITIVE);
			
			var lastIndex:uint = Toolbox.isASProject
				? saveSkinXML(arr, lastName)
				: saveSkinJSON(arr, lastName);
			
			arrList.source = arr;
			skinListGroup.setSelectedIndex(lastIndex);
			_savedTips.show();
		}
		
		
		/**
		 * 保存Skin.xml
		 * @param arr
		 * @param lastName
		 * @return 
		 */
		private function saveSkinXML(arr:Array, lastName:String):uint
		{
			var lastIndex:uint = 0;
			
			var configXml:XML = <config/>
			for(var i:int = 0; i < arr.length; i++)
			{
				var name:String = arr[i].name;
				var states:Array = arr[i].states;
				var itemXml:XML = XML("<" + name + "/>");
				for(var n:int = 0; n < states.length; n++)
				{
					if(states[n] != "" && states[n] != null) {
						var stateName:String = canvasGroup.stateTimeLine.getStateName(n);
						itemXml.@[stateName] = states[n];
					}
				}
				if(name == lastName) lastIndex = i;
				configXml.appendChild(itemXml);
			}
			
			var xmlStr:String = configXml.toXMLString();
			xmlStr = xmlStr.replace(/  /g, "\t");
			var file:File = new File(Toolbox.resRootDir + "/xml/core/Skin.xml");
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeUTFBytes('<?xml version="1.0" encoding="utf-8"?>');
			fs.writeUTFBytes("\r\n<!--");
			fs.writeUTFBytes("\r\n\t皮肤配置文件");
			fs.writeUTFBytes("\r\n\t该文件由编辑器自动生成");
			fs.writeUTFBytes("\r\n-->");
			fs.writeUTFBytes("\r\n" + xmlStr);
			fs.close();
			
			return lastIndex;
		}
		
		
		/**
		 * 保存Skin.json
		 * @param arr
		 * @param lastName
		 * @return 
		 */
		private function saveSkinJSON(arr:Array, lastName:String):uint
		{
			var lastIndex:uint = 0;
			
			var config:Object = {};
			for(var i:int = 0; i < arr.length; i++)
			{
				var name:String = arr[i].name;
				var states:Array = arr[i].states;
				var item:Object = {};
				for(var n:int = 0; n < states.length; n++)
				{
					if(states[n] != "" && states[n] != null) {
						var stateName:String = canvasGroup.stateTimeLine.getStateName(n);
						item[stateName] = states[n];
					}
				}
				if(name == lastName) lastIndex = i;
				config[name] = item;
			}
			
			var file:File = new File(Toolbox.resRootDir + "/json/core/Skin.json");
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeUTFBytes(SortJSONEncoder.stringify(config));
			fs.close();
			
			return lastIndex;
		}
		
		
		//
	}
}