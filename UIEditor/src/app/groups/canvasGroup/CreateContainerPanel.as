package app.groups.canvasGroup
{
	import app.common.AppCommon;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import lolo.core.Common;
	import lolo.utils.Validator;
	
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Panel;
	import spark.components.TextInput;
	
	/**
	 * 创建容器面板
	 * @author LOLO
	 */
	public class CreateContainerPanel extends Panel
	{
		public var closeBtn:Button;
		public var extContainerCB:CheckBox;
		public var idText:TextInput;
		public var createBtn:Button;
		public var cancelBtn:Button;
		
		
		
		public function CreateContainerPanel()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			(this.parent as IVisualElementContainer).removeElement(this);
		}
		
		
		protected function addedToStageHandler(event:Event):void
		{
			Common.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler();
		}
		
		
		private function stage_resizeHandler(event:Event=null):void
		{
			this.x = int(Common.stage.stage.stageWidth - width >> 1);
			this.y = int(Common.stage.stage.stageHeight - height >> 1);
		}
		
		
		
		
		protected function createBtn_clickHandler(event:MouseEvent):void
		{
			this.setFocus();
			var name:String = idText.text;
			if(!Validator.noSpace(name)) return;
			
			//验证是否已经有这个名称的容器了
			var list:IList = AppCommon.canvas.containerTB.dataProvider;
			for(var i:int = 0; i < list.length; i++) {
				if(list.getItemAt(i).name == name) {
					Alert.show("容器名称 " + name + " 已经存在了！", "提示");
					return;
				}
			}
			
			idText.text = "";
			closeBtn_clickHandler();
			
			AppCommon.controller.addContainer(name, extContainerCB.selected);
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