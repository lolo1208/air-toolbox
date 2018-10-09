package app.groups.configGroup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import lolo.core.Common;
	import lolo.utils.Validator;
	
	import mx.controls.Alert;
	import mx.core.IVisualElementContainer;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.Panel;
	import spark.components.TextInput;
	
	import toolbox.Toolbox;
	
	/**
	 * 创建配置文件面板
	 * @author LOLO
	 */
	public class CreateConfigPanel extends Panel
	{
		public var closeBtn:Button;
		public var nameText:TextInput;
		public var submitBtn:Button;
		public var cancelBtn:Button;
		
		
		
		public function CreateConfigPanel()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			(this.parent as IVisualElementContainer).removeElement(this);
		}
		
		
		protected function addedToStageHandler(event:Event):void
		{
			stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler();
		}
		
		public function stage_resizeHandler(event:Event=null):void
		{
			this.x = int(Common.stage.stageWidth - width >> 1);
			this.y = int(Common.stage.stageHeight - height >> 1);
		}
		
		
		public function show():void
		{
//			if(!AppCommon.viewEditor.projectOpened) {
//				Alert.show("请先打开资源库！", "提示");
//				return;
//			}
			
			PopUpManager.addPopUp(this, this, true);
			stage.focus = nameText;
		}
		
		
		
		
		/**
		 * 点击确定按钮
		 * @param event
		 */
		protected function submitBtn_clickHandler(event:MouseEvent):void
		{
			this.setFocus();
			var name:String = nameText.text;
			if(!Validator.noSpace(name)) return;
			
			name = name.charAt(0).toLocaleUpperCase() + name.substr(1) + ".xml";
			var file:File = new File(Toolbox.resRootDir + "xml/uiConfig/" + name);
			if(file.exists) {
				Alert.show("文件 " + name + " 已存在！", "提示");
				return;
			}
			
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeUTFBytes('<?xml version="1.0" encoding="utf-8"?>\r\n<config/>');
			fs.close();
			
			Alert.show("创建配置文件 [" + name + "] 成功！是否需要打开？", "提示", Alert.YES | Alert.NO, null, openAlert_closeHandler);
			
			closeBtn_clickHandler();
//			AppCommon.viewEditor.configPanel.loadRes();
		}
		
		private function openAlert_closeHandler(event:CloseEvent):void
		{
			if(event.detail == Alert.YES) {
//				Reload.alert("打开所选配置文件", openCallback, false);
			}
		}
		
		private function  openCallback(confirmed:Boolean):void
		{
			if(confirmed) {
//				AppCommon.viewEditor.openConfig(nameText.text + ".xml", new XML());
			}
		}
		
		
		
		
		
		/**
		 * 点击关闭按钮
		 * @param event
		 */
		protected function closeBtn_clickHandler(event:MouseEvent=null):void
		{
			this.setFocus();
			PopUpManager.removePopUp(this);
		}
		//
	}
}