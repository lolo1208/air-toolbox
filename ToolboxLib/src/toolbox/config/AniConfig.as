package toolbox.config
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
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
	import lolo.display.Animation;
	import lolo.display.BitmapMovieClipData;
	import lolo.utils.StringUtil;
	import lolo.utils.optimize.ConsumeBalancer;
	
	import mx.collections.ArrayCollection;
	
	import toolbox.Toolbox;

	/**
	 * 动画配置文件相关操作
	 * @author LOLO
	 */
	public class AniConfig
	{
		/**刷新AnimationConfig.xml，加载缓存数据完成时的回调*/
		public static var refreshComplete:Function;
		/**数据树*/
		public static var treeData:ArrayCollection;
		
		/**正在解析的列表数据*/
		private static var _data:Array;
		/**引用item的parent的列表*/
		private static var _parentList:Dictionary;
		/**需要加载的LD包列表*/
		private static var _ldPackageList:Array;
		
		/**正在加载的item信息*/
		private static var _item:Object;
		/**用于加载LD数据包*/
		private static var _ldLoader:URLLoader;
		/**loader为key，value为对应的、还未解析的描述信息*/
		private static var _infoList:Dictionary = new Dictionary();
		
		/**是否需要加载缓存数据*/
		private static var _needLoad:Boolean;
		/**界面配置xml*/
		private static var _configXml:XML;
		
		
		
		/**
		 * 刷新AnimationConfig.xml，加载缓存数据
		 * @param needLoad 是否需要加载缓存数据
		 */
		public static function refresh(needLoad:Boolean):void
		{
			if(!Toolbox.isASProject)
			{
				AniConfig_JSON.refresh(needLoad);
				return;
			}
			
			if(_ldLoader == null) {
				_ldLoader = new URLLoader();
				_ldLoader.dataFormat = URLLoaderDataFormat.BINARY;
				_ldLoader.addEventListener(Event.COMPLETE, completeHandler);
			}
			
			_needLoad = needLoad;
			if(_needLoad) Animation.cache.clear();
			
			_data = [];
			_ldPackageList = [];
			_parentList = new Dictionary();
			_configXml = <config/>;
			
			parseDir(new File(Toolbox.resRootDir + "ani"), _data, null);
			for each(var item:Object in _data) checkRemoveDir(item);
			
			Toolbox.progressPanel.show(_ldPackageList.length, 0, "刷新 AnimationConfig.xml");
			loadNextLdPackage();
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
					_ldPackageList.push(item);
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
		 * 加载下一个LD数据包
		 */
		private static function loadNextLdPackage():void
		{
			if(_ldPackageList.length == 0)
			{
				treeData = new ArrayCollection(_data);
				Common.stage.addEventListener(Event.ENTER_FRAME, saveConfigXml);
				return;
			}
			
			Toolbox.progressPanel.addProgress();
			_item = _ldPackageList.shift();
			_ldLoader.load(new URLRequest(_item.path));
		}
		
		
		
		/**
		 * 加载动画数据包完成
		 * @param event
		 */
		private static function completeHandler(event:Event):void
		{
			var itemXml:XML = <item/>;
			var url:String = _item.path.replace(StringUtil.slashToBackslash(Toolbox.resRootDir + "ani/"), "");
			itemXml.@url = StringUtil.backslashToSlash(url);
			
			var bytes:ByteArray = _ldLoader.data;
			try { bytes.uncompress(); } catch(error:Error) {}
			bytes.readUnsignedByte();//Constants.FLAG_*
			
			//加载图像字节数据
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			_infoList[loader] = { bytes:bytes, itemXml:itemXml, item:_item };
			
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
			var bytes:ByteArray = _infoList[loader].bytes;
			var itemXml:XML = _infoList[loader].itemXml;
			var item:Object = _infoList[loader].item;
			delete _infoList[loader];
			
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
					
					if(_needLoad) {
						var bmcData:BitmapMovieClipData = new BitmapMovieClipData(width, height, offsetX, offsetY);
						frameList.push(bmcData);
						ConsumeBalancer.addCallback(copyFramePixels, name, n, bigBitmapData, new Rectangle(x, y, width, height));
					}
				}
				
				if(_needLoad) {
					Animation.cache.add(name, frameList);
					Animation.config[name] = { totalFrames:frameList.length, fps:fps };
				}
				
				var aniXml:XML = new XML("<" + name + "/>");
				aniXml.@tf = totalFrames;
				aniXml.@fps = fps;
				itemXml.appendChild(aniXml);
				
				item.children.push({ name:name, isAnimation:true });
			}
			
			_configXml.appendChild(itemXml);
			bytes.clear();
			loadNextLdPackage();
		}
		
		
		
		/**
		 * 拷贝帧的数据<br/>
		 * 在合适的时候，由 ConsumeBalancer 调用，均衡每帧CPU消耗。
		 * @param name 动画的名称
		 * @param index 帧的索引
		 * @param frameData 帧数据
		 */
		private static function copyFramePixels(name:String, index:uint, bigBitmapData:BitmapData, rect:Rectangle):void
		{
			var frameList:Vector.<BitmapMovieClipData> = Animation.cache.getValue(name);
			frameList[index].copyPixels(bigBitmapData, rect, new Point());
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
			
			var file:File = new File(Toolbox.resRootDir + "/xml/core/AnimationConfig.xml");
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes('<?xml version="1.0" encoding="utf-8"?>');
			stream.writeUTFBytes("\r\n<!--");
			stream.writeUTFBytes("\r\n\t自定义动画的配置文件");
			stream.writeUTFBytes("\r\n\t该文件由编辑器自动生成，手动修改该文件的内容，将会在下次打开编辑器时丢失");
			stream.writeUTFBytes("\r\n-->");
			stream.writeUTFBytes("\r\n" + xmlStr);
			stream.close();
			
			Toolbox.progressPanel.hide();
			if(refreshComplete != null) {
				refreshComplete();
				refreshComplete = null;
			}
		}
		//
	}
}