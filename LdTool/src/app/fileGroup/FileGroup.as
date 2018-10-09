package app.fileGroup
{
	import app.common.AppCommon;
	import app.common.ImageAssets;
	
	import flash.desktop.NativeDragManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import lolo.core.Constants;
	import lolo.display.BitmapMovieClipData;
	import lolo.display.Scale9BitmapData;
	import lolo.utils.optimize.CachePool;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.Tree;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Image;
	import spark.components.Label;
	
	import toolbox.data.SharedData;
	
	
	/**
	 * 文件列表
	 * @author LOLO
	 */
	public class FileGroup extends Group
	{
		public var typeLb:Label;
		public var typeIcon:Image;
		public var treeGroup:Group;
		public var tree:Tree;
		public var addBtn:Button;
		public var clearBtn:Button;
		public var allBtn:Button;
		
		[Bindable]
		public var treeData:ArrayCollection;
		
		/**用于打开文件*/
		private var _openFile:File;
		private var _openedType:String;
		
		private var _loaderList:Dictionary;
		
		
		public function FileGroup()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			_loaderList = new Dictionary();
			
			_openFile = new File();
			_openFile.addEventListener(Event.SELECT, openFile_eventHandler);
			_openFile.addEventListener(Event.COMPLETE, openFile_eventHandler);
			
			treeData = new ArrayCollection();
			
			treeGroup.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, treeGroup_nativeDragDropHandler);
			treeGroup.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, treeGroup_nativeDragDropHandler);
		}
		
		
		
		
		protected function treeGroup_nativeDragDropHandler(event:NativeDragEvent):void
		{
			var file:File = event.clipboard.getData(event.clipboard.formats[0])[0];
			if(file == null) return;//不是文件
			
			var arr:Array = file.nativePath.split(".");
			if(arr[arr.length - 1] != Constants.EXTENSION_LD) return;//不是数据包
			
			if(event.type == NativeDragEvent.NATIVE_DRAG_ENTER) {
				NativeDragManager.acceptDragDrop(event.target as InteractiveObject);
			}
			else {
				_openFile.nativePath = file.nativePath;
				SharedData.data.lastLTLdFilePath = _openFile.nativePath;
				SharedData.save();
				_openFile.load();
			}
		}
		
		
		
		
		/**
		 * 打开文件
		 */
		public function openFile():void
		{
			try {
				_openFile.nativePath = SharedData.data.lastLTLdFilePath;
			}
			catch(error:Error) {}
			
			var description:String;
			if(_openedType == "ui") description = "UI数据包";
			else if(_openedType == "ani") description = "动画数据包";
			else description = "动画数据包 或 UI数据包";
			
			_openFile.browse([new FileFilter(description, "*.ld;*.ast")]);
		}
		
		private function openFile_eventHandler(event:Event):void
		{
			if(event.type == Event.SELECT)
			{
				SharedData.data.lastLTLdFilePath = _openFile.nativePath;
				SharedData.save();
				_openFile.load();
			}
			else
			{
				var bytes:ByteArray = _openFile.data;
				try { bytes.uncompress(); } catch(error:Error) {}
				var flag:uint = bytes.readUnsignedByte();
				var errStr:String;
				
				if(_openedType == "ui") {
					if(flag != Constants.FLAG_IDP && flag != Constants.FLAG_LIDP) errStr = "不是有效的图像数据包！";
				}
				else if(_openedType == "ani") {
					if(flag != Constants.FLAG_AD) errStr = "不是有效的动画数据包！";
				}
				else {
					if(flag != Constants.FLAG_IDP && flag != Constants.FLAG_LIDP && flag != Constants.FLAG_AD)
						errStr = "不是有效的动画数据包或图像数据包！";
					else
					{
						AppCommon.app.exportGroup.compressCB.selected = true;
						if(flag == Constants.FLAG_AD) {
							_openedType = "ani";
							AppCommon.isUI = false;
							AppCommon.app.exportGroup.compressCB.enabled = false;
							typeLb.text = "动画";
							typeIcon.source = ImageAssets.Animation;
						}
						else {
							_openedType = "ui";
							AppCommon.isUI = true;
							AppCommon.app.exportGroup.compressCB.enabled = true;
							typeLb.text = "UI图像";
							typeIcon.source = ImageAssets.UI;
						}
					}
				}
				
				if(errStr != null) {
					Alert.show(errStr, "提示");
					return;
				}
				
				//验证文件是否已经打开了
				for(var i:int = 0; i < treeData.length; i++) {
					if(treeData.getItemAt(i).path == _openFile.nativePath) {
						Alert.show("文件已打开！", "提示");
						return;
					}
				}
				
				(_openedType == "ui") ? parseUiData(bytes) : parseAniData(bytes);
			}
		}
		
		
		
		/**
		 * 解析UI数据包
		 * @param bytes
		 */
		private function parseUiData(bytes:ByteArray):void
		{
			//加载图像字节数据
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, uiLoader_completeHandler);
			_loaderList[loader] = { path:_openFile.nativePath, bytes:bytes };
			
			var pos:uint = bytes.readUnsignedInt();
			bytes.position = pos;
			
			var len:uint = bytes.readUnsignedInt();
			var bigBitmapBytes:ByteArray = new ByteArray();
			bytes.readBytes(bigBitmapBytes, 0, len);
			
			loader.loadBytes(bigBitmapBytes);
		}
		
		private function uiLoader_completeHandler(event:Event):void
		{
			var loader:Loader = (event.target as LoaderInfo).loader;
			var bigBitmapData:BitmapData = (loader.content as Bitmap).bitmapData;
			var bytes:ByteArray = _loaderList[loader].bytes;
			var fileInfo:Object = addFileInfo(_loaderList[loader].path);
			delete _loaderList[loader];
			loader.unload();
			
			bytes.position = 5;
			var num:uint = bytes.readUnsignedShort();//包内包含的图像的数量
			for(var i:int=0; i < num; i++)
			{
				var name:String = bytes.readUTF();//图像的源名称
				
				//图像在 bigBitmapData 中的位置，宽高
				var x:uint = bytes.readUnsignedShort();
				var y:uint = bytes.readUnsignedShort();
				var width:uint = bytes.readUnsignedShort();
				var height:uint = bytes.readUnsignedShort();
				
				var offsetX:int = bytes.readShort();//图像的X偏移
				var offsetY:int = bytes.readShort();//图像的Y偏移
				
				//设置图像数据
				var p:Point = CachePool.getPoint();
				var rect:Rectangle = CachePool.getRectangle(x, y, width, height);
				var bitmapData:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
				bitmapData.copyPixels(bigBitmapData, rect, p);
				CachePool.recover([ p, rect ]);
				
				//是九切片图像
				var scale9Grid:Rectangle = null;
				var s9bd:Scale9BitmapData = null;
				if(bytes.readUnsignedByte() == 1) {
					scale9Grid = new Rectangle(
						bytes.readUnsignedShort(), bytes.readUnsignedShort(),
						bytes.readUnsignedShort(), bytes.readUnsignedShort()
					);
					s9bd = new Scale9BitmapData(bitmapData, scale9Grid);
				}
				
				var info:Object = { width:width, height:height, offsetX:offsetX, offsetY:offsetY, scale9Grid:scale9Grid };
				var item:Object = { name:name, info:info, bd:bitmapData, s9bd:s9bd };
				fileInfo.children.push(item);
			}
			bytes.clear();
		}
		
		
		
		
		/**
		 * 解析动画数据包
		 * @param bytes
		 */
		private function parseAniData(bytes:ByteArray):void
		{
			//加载图像字节数据
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, aniLoader_completeHandler);
			_loaderList[loader] = { path:_openFile.nativePath, bytes:bytes };
			
			var pos:uint = bytes.readUnsignedInt();
			bytes.position = pos;
			
			var len:uint = bytes.readUnsignedInt();
			var bigBitmapBytes:ByteArray = new ByteArray();
			bytes.readBytes(bigBitmapBytes, 0, len);
			
			loader.loadBytes(bigBitmapBytes);
		}
		
		private function aniLoader_completeHandler(event:Event):void
		{
			var loader:Loader = event.target.loader;
			var bigBitmapData:BitmapData = (loader.content as Bitmap).bitmapData;
			var bytes:ByteArray = _loaderList[loader].bytes;
			var fileInfo:Object = addFileInfo(_loaderList[loader].path);
			delete _loaderList[loader];
			loader.unload();
			
			bytes.position = 5;
			var num:uint = bytes.readUnsignedByte();//动画数量
			for(var i:int=0; i < num; i++)
			{
				var name:String = bytes.readUTF();//动画名称
				var totalFrames:uint = bytes.readUnsignedShort();//动画总帧数
				var fps:uint = bytes.readUnsignedByte();//默认帧频
				var frameList:Vector.<BitmapMovieClipData> = new Vector.<BitmapMovieClipData>();
				for(var n:int=0; n < totalFrames; n++)
				{
					var x:int = bytes.readShort();//在 bigBitmapData 中的位置
					var y:int = bytes.readShort();
					var width:uint = bytes.readUnsignedShort();//帧宽高
					var height:uint = bytes.readUnsignedShort();
					var offsetX:int = bytes.readShort();//帧偏移
					var offsetY:int = bytes.readShort();
					
					var bmcData:BitmapMovieClipData = new BitmapMovieClipData(width, height, offsetX, offsetY);
					frameList.push(bmcData);
					
					var p:Point = CachePool.getPoint();
					var rect:Rectangle = CachePool.getRectangle(x, y, width, height);
					bmcData.copyPixels(bigBitmapData, rect, p);
					CachePool.recover([ p, rect ]);
				}
				
				var info:Object = { totalFrames:totalFrames, fps:fps };
				var item:Object = { name:name, info:info, frameList:frameList };
				fileInfo.children.push(item);
			}
			bytes.clear();
		}
		
		
		
		private function addFileInfo(path:String):Object
		{
			var nameLabel:String = path;
			if(nameLabel.length > 48) {
				nameLabel = "..." + nameLabel.substr(nameLabel.length - 48);
			}
			var info:Object = { path:path, name:nameLabel, children:[] };
			treeData.addItem(info);
			return info;
		}
		
		
		
		/**
		 * 重置打开类型
		 */
		public function resetType():void
		{
			_openedType = null;
			typeIcon.source = null;
			typeLb.text = "";
			treeData.removeAll();
			AppCommon.app.exportGroup.listData.removeAll();
		}
		
		
		
		
		protected function addBtn_clickHandler(event:MouseEvent):void
		{
			openFile();
		}
		
		protected function clearBtn_clickHandler(event:MouseEvent):void
		{
			treeData.removeAll();
		}
		
		
		protected function allBtn_clickHandler(event:MouseEvent):void
		{
			var listData:ArrayList = AppCommon.app.exportGroup.listData;
			for(var i:int=0; i < treeData.length; i++)
			{
				var fileInfo:Object = treeData.getItemAt(i);
				for(var n:int=0; n < fileInfo.children.length; n++)
				{
					var item:Object = fileInfo.children[n];
					var equals:Boolean = false;
					for(var j:int = 0; j < listData.length; j++)
					{
						if(listData.getItemAt(j).name == item.name) {
							equals = true;
							break;
						}
					}
					if(!equals) AppCommon.app.exportGroup.addItem(item);
				}
			}
		}
		
		
		//
	}
}