package toolbox.config
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.display.BitmapSprite;
	import lolo.display.Scale9BitmapData;
	import lolo.utils.StringUtil;
	import lolo.utils.optimize.ConsumeBalancer;
	
	import mx.collections.ArrayCollection;
	
	import toolbox.Toolbox;

	/**
	 * 界面配置文件相关操作
	 * @author LOLO
	 */
	public class UIConfig
	{
		/**刷新BitmapSpriteConfig.xml，加载UI图像数据完成时的回调*/
		public static var refreshComplete:Function;
		/**UI图像数据树*/
		public static var treeData:ArrayCollection;
		
		
		/**正在解析的列表数据*/
		private static var _data:Array;
		/**引用item的parent的列表*/
		private static var _parentList:Dictionary;
		/**需要加载的图像包列表*/
		private static var _uiPackageList:Array;
		
		/**正在加载的动画的信息*/
		private static var _uiItem:Object;
		/**用于加载UI包*/
		private static var _uiLoader:URLLoader;
		/**loader为key，value为对应的、还未解析的图像信息*/
		private static var _uiInfoList:Dictionary = new Dictionary();
		
		/**是否需要加载UI图像数据*/
		private static var _needLoad:Boolean;
		/**界面配置xml*/
		private static var _configXml:XML;
		
		
		
		/**
		 * 刷新BitmapSpriteConfig.xml，加载UI图像数据
		 * @param needLoad 是否需要加载UI图像数据
		 */
		public static function refresh(needLoad:Boolean):void
		{
			if(!Toolbox.isASProject)
			{
				UIConfig_JSON.refresh(needLoad);
				return;
			}
			
			
			if(_uiLoader == null) {
				_uiLoader = new URLLoader();
				_uiLoader.dataFormat = URLLoaderDataFormat.BINARY;
				_uiLoader.addEventListener(Event.COMPLETE, completeHandler);
			}
			
			_needLoad = needLoad;
			if(_needLoad) BitmapSprite.cache.clear();
			
			_data = [];
			_uiPackageList = [];
			_parentList = new Dictionary();
			_configXml = <config/>;
			
			parseDir(new File(Toolbox.resRootDir + "ui"), _data, null);
			for each(var item:Object in _data) checkRemoveDir(item);
			
			Toolbox.progressPanel.show(_uiPackageList.length, 0, "刷新 BitmapSpriteConfig.xml");
			loadNextUiPackage();
		}
		
		
		
		/**
		 * 解析文件夹
		 * @param dir
		 * @return 这个文件夹里是否有LD文件
		 */
		private static function parseDir(dir:File, data:Array, parentItem:Object):Boolean
		{
			var files:Array = dir.getDirectoryListing();
			var haveLdFile:Boolean;
			
			for(var i:int = 0; i < files.length; i++)
			{
				var file:File = files[i];
				var children:Array = [];
				
				if(file.name == ".svn") continue;
				
				var item:Object = { name:file.name, path:file.nativePath, children:children };
				_parentList[item.path] = parentItem;
				
				if(file.isDirectory) {
					item.haveLdFile = parseDir(file, children, item);
					data.push(item);
				}
				else if(file.extension == Constants.EXTENSION_LD) {
					item.isLdFile = true;
					data.push(item);
					haveLdFile = true;
					_uiPackageList.push(item);
				}
			}
			
			return haveLdFile;
		}
		
		/**
		 * 移除不包含LD文件的文件夹
		 */
		private static function checkRemoveDir(item:Object):void
		{
			if(item.children.length == 0) {
				removeDir(item);
			}
			else {
				var arr:Array = [];
				var child:Object;
				for each(child in item.children) arr.push(child);
				for each(child in arr) checkRemoveDir(child);
			}
		}
		
		private static function removeDir(item:Object):void
		{
			var parentItem:Object = _parentList[item.path];
			if(parentItem == null) return;
			
			if(!item.haveLdFile && !item.isLdFile) {
				for(var i:int = 0; i < parentItem.children.length; i++) {
					if(parentItem.children[i].path == item.path) {
						parentItem.children.splice(i, 1);
						break;
					}
				}
				
				delete _parentList[item.path];
				removeDir(parentItem);
			}
		}
		
		
		
		/**
		 * 加载下一个UI包
		 */
		private static function loadNextUiPackage():void
		{
			if(_uiPackageList.length == 0)
			{
				treeData = new ArrayCollection(_data);
				Common.stage.addEventListener(Event.ENTER_FRAME, saveConfigXml);
				return;
			}
			
			Toolbox.progressPanel.addProgress();
			_uiItem = _uiPackageList.shift();
			_uiLoader.load(new URLRequest(_uiItem.path));
		}
		
		
		
		/**
		 * 加载UI包完成
		 * @param event
		 */
		private static function completeHandler(event:Event):void
		{
			var itemXml:XML = <item/>;
			var url:String = _uiItem.path.replace(StringUtil.slashToBackslash(Toolbox.resRootDir + "ui/"), "");
			itemXml.@url = StringUtil.backslashToSlash(url);
			
			var bytes:ByteArray = _uiLoader.data;
			try { bytes.uncompress(); } catch(error:Error) {}
			bytes.readUnsignedByte();//Constants.FLAG_AD
			
			//加载图像字节数据
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			_uiInfoList[loader] = { bytes:bytes, itemXml:itemXml, uiItem:_uiItem };
			
			var pos:uint = bytes.readUnsignedInt();
			bytes.position = pos;
			
			var len:uint = bytes.readUnsignedInt();
			var bigBitmapBytes:ByteArray = new ByteArray();
			bytes.readBytes(bigBitmapBytes, 0, len);
			
			loader.loadBytes(bigBitmapBytes);
		}
		
		/**
		 * 加载图像字节数据完成
		 * @param event
		 */
		private static function loader_completeHandler(event:Event):void
		{
			var loader:Loader = event.target.loader;
			var bigBitmapData:BitmapData = (loader.content as Bitmap).bitmapData;
			var bytes:ByteArray = _uiInfoList[loader].bytes;
			var itemXml:XML = _uiInfoList[loader].itemXml;
			var uiItem:Object = _uiInfoList[loader].uiItem;
			delete _uiInfoList[loader];
			
			bytes.position = 5;
			var num:uint = bytes.readUnsignedShort();//包内包含的图像的数量
			for(var i:int=0; i < num; i++)
			{
				var name:String = bytes.readUTF();//图像的源名称
				
				//图像在 bigBitmapData 中的位置
				var x:uint = bytes.readUnsignedShort();
				var y:uint = bytes.readUnsignedShort();
				
				var info:Object = {
					width	: bytes.readUnsignedShort(),
					height	: bytes.readUnsignedShort(),
					offsetX	: bytes.readShort(),
					offsetY	: bytes.readShort()
				};
				var uiXml:XML = new XML("<" + name + "/>");
				uiXml.@x = info.offsetX;
				uiXml.@y = info.offsetY;
				uiXml.@w = info.width;
				uiXml.@h = info.height;
				
				//是九切片图像
				if(bytes.readUnsignedByte() == 1) {
					var rect:Rectangle = new Rectangle(
						bytes.readUnsignedShort(),
						bytes.readUnsignedShort(),
						bytes.readUnsignedShort(),
						bytes.readUnsignedShort()
					);
					info.scale9Grid = rect;
					uiXml.@g = rect.x + "," + rect.y + "," + rect.width + "," + rect.height;
				}
				itemXml.appendChild(uiXml);
				uiItem.children.push({ name:name, isUI:true });
				
				if(_needLoad) {
					BitmapSprite.config[name] = info;
					ConsumeBalancer.addCallback(copyBitmapPixels, name, bigBitmapData, new Rectangle(x, y, info.width, info.height));
				}
			}
			_configXml.appendChild(itemXml);
			bytes.clear();
			loadNextUiPackage();
		}
		
		
		/**
		 * 在 bigBitmap 中拷贝图像的数据<br/>
		 * 在合适的时候，由 ConsumeBalancer 调用，均衡每帧CPU消耗。
		 * @param name 图像的源名称
		 * @param frameData 图像的数据
		 */
		private static function copyBitmapPixels(name:String, bigBitmapData:BitmapData, rect:Rectangle):void
		{
			//设置图像数据
			var bitmapData:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			bitmapData.copyPixels(bigBitmapData, rect, new Point());
			
			//是九切片图像
			var info:Object = BitmapSprite.config[name];
			if(info.scale9Grid != null) {
				BitmapSprite.cache.add(name, new Scale9BitmapData(bitmapData, info.scale9Grid), info.width * info.height * 4);
			}
			else {
				BitmapSprite.cache.add(name, bitmapData, info.width * info.height * 4);
			}
			
			//回调
			if(BitmapSprite.config[name].callbacks) {
				for each(var callback:Function in BitmapSprite.config[name].callbacks) callback(name);
			}
			BitmapSprite.config[name].callbacks = null;
		}
		
		
		/**
		 * 保存xml配置文件
		 */
		private static function saveConfigXml(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, saveConfigXml);
			
			var xmlStr:String = _configXml.toXMLString();
			xmlStr = xmlStr.replace(/  /g, "\t");
			xmlStr = xmlStr.replace(/\n/g, "\r\n");
			//去换行和缩进
			xmlStr = xmlStr.replace(/">\r\n\t/g, "\">");
			xmlStr = xmlStr.replace(/\/>\r\n\t\t/g, "/>");
			xmlStr = xmlStr.replace(/\/>\r\n/g, "/>");
			
			var file:File = new File(Toolbox.resRootDir + "/xml/core/BitmapSpriteConfig.xml");
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeUTFBytes('<?xml version="1.0" encoding="utf-8"?>');
			fs.writeUTFBytes("\r\n<!--");
			fs.writeUTFBytes("\r\n\t位图显示对象的配置文件");
			fs.writeUTFBytes("\r\n\t该文件由编辑器自动生成，手动修改该文件的内容，将会在下次打开编辑器时丢失");
			fs.writeUTFBytes("\r\n-->");
			fs.writeUTFBytes("\r\n" + xmlStr);
			fs.close();
			
			Toolbox.progressPanel.hide();
			if(refreshComplete != null) {
				refreshComplete();
				refreshComplete = null;
			}
		}
		//
	}
}