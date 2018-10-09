package app.skinListGroup
{
	import app.common.AppCommon;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;
	
	import toolbox.Toolbox;
	
	/**
	 * 皮肤列表容器
	 * @author LOLO
	 */
	public class SkinListGroup extends Group
	{
		public var skinList:List;
		public var addBtn:Button;
		public var removeBtn:Button;
		
		public var nameLabel:Label;
		public var nameText:TextInput;
		
		public var saveBtn:Button;
		
		/**Skin.xml*/
		private var _skinConfigFile:File;
		/**BitmapSpriteConfig.xml*/
		private var _bsConfigFile:File;
		
		/**BitmapSprite信息列表*/
		private var _bsInfoList:Dictionary;
		
		
		
		public function SkinListGroup()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			skinList.tabFocusEnabled = false;
			addBtn.tabFocusEnabled = false;
			removeBtn.tabFocusEnabled = false;
			nameText.tabFocusEnabled = false;
			saveBtn.tabFocusEnabled = false;
			
			_skinConfigFile = new File();
			_skinConfigFile.addEventListener(Event.COMPLETE, skinConfigFile_completeHandler);
			_bsConfigFile = new File();
			_bsConfigFile.addEventListener(Event.COMPLETE, bsConfigFile_completeHandler);
		}
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			if(skinList == null) return;
			skinList.height = height - 104;
			nameLabel.y = height - 58;
			nameText.y = height - 65;
			saveBtn.y = height - 30;
		}
		
		
		
		
		/**
		 * 开始解析配置文件
		 */
		public function parse():void
		{
			Toolbox.progressPanel.show(2, 1);
			
			//加载 Skin.xml 或 Skin.json
			var path:String = Toolbox.isASProject
				? "xml/core/Skin.xml"
				: "json/core/Skin.json";
			_skinConfigFile.nativePath = Toolbox.resRootDir + path;
			_skinConfigFile.load();
		}
		
		
		/**
		 * 加载 Skin.xml 或 Skin.json 完成
		 * @param event
		 */
		private function skinConfigFile_completeHandler(event:Event):void
		{
			Toolbox.progressPanel.addProgress();
			
			var content:String = _skinConfigFile.data.readUTFBytes(_skinConfigFile.data.bytesAvailable);
			var arr:Array = [];
			if(Toolbox.isASProject)
			{
				var children:XMLList = XML(content).children();
				for each(var xmlItem:XML in children)
				{
					arr.push({
						name	: String(xmlItem.name()),
						states	: [
							String(xmlItem.@up),
							String(xmlItem.@over),
							String(xmlItem.@down),
							String(xmlItem.@disabled),
							String(xmlItem.@selectedUp),
							String(xmlItem.@selectedOver),
							String(xmlItem.@selectedDown),
							String(xmlItem.@selectedDisabled)
						]
					});
				}
			}
			else
			{
				var obj:Object = JSON.parse(content);
				for(var name:String in obj)
				{
					var objItem:Object = obj[name];
					arr.push({
						name	: name,
						states	: [
							(objItem.up != null ? objItem.up : ""),
							(objItem.over != null ? objItem.over : ""),
							(objItem.down != null ? objItem.down : ""),
							(objItem.disabled != null ? objItem.disabled : ""),
							(objItem.selectedUp != null ? objItem.selectedUp : ""),
							(objItem.selectedOver != null ? objItem.selectedOver : ""),
							(objItem.selectedDown != null ? objItem.selectedDown : ""),
							(objItem.selectedDisabled != null ? objItem.selectedDisabled : "")
						]
					});
				}
			}
			
			arr.sortOn("name", Array.CASEINSENSITIVE);
			skinList.dataProvider = new ArrayList(arr);
			
			for(var i:int = 0; i < arr.length; i++)
				AppCommon.app.checkRepeatName(arr[i].name);
			
			
			//加载 BitmapSpriteConfig.xml 或 BitmapConfig.json
			var path:String = Toolbox.isASProject
				? "xml/core/BitmapSpriteConfig.xml"
				: "json/core/BitmapConfig.json";
			_bsConfigFile.nativePath = Toolbox.resRootDir + path;
			_bsConfigFile.load();
		}
		
		
		/**
		 * 加载 BitmapSpriteConfig.xml 或 BitmapConfig.json 完成
		 * @param event
		 */
		private function bsConfigFile_completeHandler(event:Event):void
		{
			_bsInfoList = new Dictionary();
			var content:String = _bsConfigFile.data.readUTFBytes(_bsConfigFile.data.bytesAvailable);
			if(Toolbox.isASProject)
			{
				var xml:XML = XML(content);
				for each(var xmlItem:XML in xml.item)
				{
					for each(var bs:XML in xmlItem.*)
					_bsInfoList[String(bs.name())] = new Point(bs.@x, bs.@y);
				}
			}
			else
			{
				var arr:Array = JSON.parse(content) as Array;
				for(var i:int = 0; i < arr.length; i++)
				{
					var list:Array = arr[i].list;
					for(var n:int = 0; n < list.length; n++) {
						var info:Object = list[n];
						_bsInfoList[info.sn] = new Point(
							(info.ox > 0) ? -info.ox : Math.abs(info.ox),
							(info.oy > 0) ? -info.oy : Math.abs(info.oy)
						);
					}
				}
			}
			
			Toolbox.progressPanel.hide();
		}
		
		
		
		public function addSkin(name:String, states:Array):void
		{
			skinList.dataProvider.addItem({ name:name, states:states });
			AppCommon.app.checkRepeatName(name);
			setSelectedIndex(skinList.dataProvider.length - 1);
		}
		
		
		
		
		
		/**
		 * 选中皮肤
		 * @param event
		 */
		protected function skinList_changeHandler(event:IndexChangeEvent=null):void
		{
			nameText.text =  skinList.selectedItem.name;
			AppCommon.app.canvasGroup.show(skinList.selectedItem.states);
		}
		
		
		
		/**
		 * 修改皮肤的名称
		 * @param event
		 */
		protected function nameText_changeHandler(event:TextOperationEvent):void
		{
			if(skinList.selectedItem == null) {
				nameText.text = "";
				return;
			}
			if(nameText.text.length == 0) return;
			
			var lastName:String = skinList.selectedItem.name;
			skinList.selectedItem.name = nameText.text;
			var item:SkinItemRenderer = skinList.dataGroup.getElementAt(skinList.selectedIndex) as SkinItemRenderer;
			if(item != null) item.update();
			
			AppCommon.app.checkRepeatName(lastName);
			AppCommon.app.checkRepeatName(skinList.selectedItem.name);
		}
		
		
		
		
		/**
		 * 点击保存按钮
		 * @param event
		 */
		protected function saveBtn_clickHandler(event:MouseEvent):void
		{
			AppCommon.app.saveConfig();
		}
		
		
		
		/**
		 * 点击添加按钮
		 * @param event
		 */
		protected function addBtn_clickHandler(event:MouseEvent):void
		{
			PopUpManager.addPopUp(AppCommon.app.createPanel, AppCommon.app, true);
		}
		
		
		
		/**
		 * 点击移除按钮
		 * @param event
		 */
		protected function removeBtn_clickHandler(event:MouseEvent):void
		{
			if(skinList.selectedItem == null) return;
			Alert.show("您确定要删除皮肤：" + skinList.selectedItem.name + " 吗？", "提示",
				Alert.YES | Alert.NO, null, removeAlertCloseHandler);
		}
		
		private function removeAlertCloseHandler(event:CloseEvent):void
		{
			if(event.detail == Alert.NO) return;
			reset();
			AppCommon.app.canvasGroup.reset();
			
			var name:String = skinList.selectedItem.name;
			var index:uint = skinList.selectedIndex;
			skinList.dataProvider.removeItemAt(skinList.selectedIndex);
			AppCommon.app.checkRepeatName(name);
			
			if(skinList.dataProvider.length == 0) return;
			if(index >= skinList.dataProvider.length) index = skinList.dataProvider.length-1;
			setSelectedIndex(index);
		}
		
		
		
		public function setSelectedIndex(index:uint):void
		{
			skinList.selectedIndex = index;
			skinList_changeHandler();
		}
		
		
		
		/**
		 * 获取 sourceName 对应的偏移坐标
		 * @param sn
		 * @return 
		 */
		public function getOffsetPoint(sn:String):Point
		{
			return _bsInfoList[sn];
		}
		
		
		
		
		public function reset():void
		{
			nameText.text = "";
		}
		//
	}
}