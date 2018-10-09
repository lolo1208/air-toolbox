package app.exportGroup
{
	import app.common.AppCommon;
	
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.List;
	import spark.components.TextInput;
	
	import toolbox.Toolbox;
	import toolbox.utils.MaxRects;
	
	/**
	 * 导出数据
	 * @author LOLO
	 */
	public class ExportGroup extends Group
	{
		public const FINISH_TIPS:String = "导出完毕！\n\n如果有修改 sourceName，请去修改对应的图片文件路径和名称！！！\n";
		public var list:List;
		public var clearBtn:Button;
		public var mrwText:TextInput;
		public var mrhText:TextInput;
		public var mrmDDL:DropDownList;
		public var compressCB:CheckBox;
		public var exportBtn:Button;
		
		[Bindable]
		public var listData:ArrayList;
		
		private var _exportUI:ExportUI;
		private var _exportAni:ExportAni;
		
		
		public function ExportGroup()
		{
			super();
			
			listData = new ArrayList();
			_exportUI = new ExportUI();
			_exportAni = new ExportAni();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			mrmDDL.dataProvider = MaxRects.METHOD_LIST;
			mrmDDL.selectedIndex = MaxRects.DEFAULT_METHOD;
		}
		
		
		
		protected function list_dragEnterHandler(event:DragEvent):void
		{
			if(event.dragSource.hasFormat("treeItems")) {
				var item:Object = AppCommon.app.fileGroup.tree.selectedItem;
				if(item.children == null)
					DragManager.acceptDragDrop(IUIComponent(event.target));
			}
		}
		
		protected function list_dragDropHandler(event:DragEvent):void
		{
			var item:Object = AppCommon.app.fileGroup.tree.selectedItem;
			addItem(item);
		}
		
		
		
		/**
		 * 在 List 中添加一条 item
		 * @param item
		 */
		public function addItem(item:Object):void
		{
			for(var i:int = 0; i < listData.length; i++) {
				if(listData.getItemAt(i).name == item.name) {
					Alert.show("sourceName：\n   " + item.name + "\n已在导出列表中，不能重复添加！");
					return;
				}
			}
			
			listData.addItem({
				name : item.name,
				info : item.info,
				
				bd   : item.bd,
				s9bd : item.s9bd,
				
				frameList : item.frameList
			});
		}
		
		
		
		
		/**
		 * 导出
		 */
		public function export():void
		{
			this.setFocus();
			
			if(listData.length == 0) {
				Alert.show("请添加需要导出的资源！");
				return;
			}
			
			try { new File(Toolbox.docPath).deleteDirectory(true); }
			catch(error:Error) {}
			
			AppCommon.isUI ? _exportUI.pack() : _exportAni.pack();
		}
		
		
		
		
		
		
		protected function removeBtn_clickHandler(event:MouseEvent):void
		{
			listData.removeItem(list.selectedItem);
		}
		
		
		protected function clearBtn_clickHandler(event:MouseEvent):void
		{
			listData.removeAll();
		}
		
		
		protected function exportBtn_clickHandler(event:MouseEvent):void
		{
			export();
		}
		//
	}
}