package app.main
{
	import app.canvasGroup.Tile;
	import app.common.AppCommon;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.utils.zip.ZipReader;
	
	import mx.collections.ArrayList;
	
	import toolbox.Toolbox;
	import toolbox.data.SharedData;

	/**
	 * 打开源文件
	 * @author LOLO
	 */
	public class Open
	{
		/**用于载入源文件*/
		private static var _sourceFile:File;
		
		private static var _zip:ZipReader;
		private static var _info:Object;
		
		
		
		public static function start():void
		{
			if(_sourceFile == null) {
				_sourceFile = new File();
				_sourceFile.addEventListener(Event.SELECT, sourceFile_eventHandler);
				_sourceFile.addEventListener(Event.COMPLETE, sourceFile_eventHandler);
			}
			try {
				_sourceFile.nativePath = SharedData.data.lastMapSDFilePath;
			}
			catch(error:Error) {}
			_sourceFile.browseForOpen("请选择地图源文件", [new FileFilter("ZIP压缩包", "*.zip")]);
		}
		
		
		
		
		/**
		 * 源文件相关事件
		 * @param event
		 */
		private static function sourceFile_eventHandler(event:Event):void
		{
			if(event.type == Event.SELECT) {
				SharedData.data.lastMapSDFilePath = _sourceFile.nativePath;
				SharedData.save();
				Toolbox.progressPanel.show(3);
				Common.stage.addEventListener(Event.ENTER_FRAME, loadSourceFile);
			}
			else {
				_zip = new ZipReader(_sourceFile.data);
				_info = _zip.getFile("mapData").readObject();
				
				AppCommon.bgIndex = AppCommon.coverIndex = 0;
				Toolbox.progressPanel.addProgress();
				Common.stage.addEventListener(Event.ENTER_FRAME, createBG);
			}
		}
		
		private static function loadSourceFile(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, loadSourceFile);
			_sourceFile.load();
		}
		
		
		
		
		/**
		 * 生成背景图
		 */
		private static function createBG(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, createBG);
			
			AppCommon.app.layerPanel.bgList.dataProvider = new ArrayList();
			AppCommon.app.canvasGroup.bgC.removeChildren();
			
			for(var i:int = 0; i < _info.bgs.length; i++)
			{
				AppCommon.bgIndex++;
				var item:Object = _info.bgs[i];
				var loader:Loader = new Loader();
				try {
					loader.loadBytes(_zip.getFile("bg" + item.id + ".jpg"));//以前版本是jpg后缀
				}
				catch(error:Error) {
					loader.loadBytes(_zip.getFile("bg" + item.id + ".png"));
				}
				var element:Sprite = new Sprite();
				element.x = item.point.x;
				element.y = item.point.y;
				element.name = "bg_" + AppCommon.bgIndex;
				element.addChild(loader);
				
				AppCommon.app.canvasGroup.addLayer(element, 2);
				AppCommon.app.layerPanel.bgList.dataProvider.addItemAt({
					name	: element.name,
					layer	: element
				}, 0);
			}
			
			Toolbox.progressPanel.addProgress();
			Common.stage.addEventListener(Event.ENTER_FRAME, createCover);
		}
		
		
		/**
		 * 生成遮挡物
		 */
		private static function createCover(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, createCover);
			
			AppCommon.app.layerPanel.coverList.dataProvider = new ArrayList();
			AppCommon.app.canvasGroup.coverC.removeChildren();
			
			for(var i:int = 0; i < _info.covers.length; i++)
			{
				AppCommon.coverIndex++;
				var item:Object = _info.covers[i];
				var loader:Loader = new Loader();
				loader.loadBytes(_zip.getFile("cover" + item.id + ".png"));
				
				var element:Sprite = new Sprite();
				element.x = item.point.x;
				element.y = item.point.y;
				element.name = "cover_" + AppCommon.coverIndex;
				element.addChild(loader);
				
				AppCommon.app.canvasGroup.addLayer(element, 1);
				AppCommon.app.layerPanel.coverList.dataProvider.addItemAt({
					name	: element.name,
					layer	: element
				}, 0);
			}
			
			Toolbox.progressPanel.addProgress();
			Common.stage.addEventListener(Event.ENTER_FRAME, createTile);
		}
		
		
		/**
		 * 生成区块
		 */
		private static function createTile(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, createTile);
			
			AppCommon.app.canvasGroup.staggeredCB.selected = _info.staggered;
			AppCommon.app.canvasGroup.tileC.removeChildren();
			Tile.clearFeatureInfo();
			
			var showType:int = 2;
			if(AppCommon.app.canvasGroup.pointCB.selected) showType = 1;
			if(AppCommon.app.canvasGroup.indexCB.selected) showType = 3;
			
			var x:int, y:int, tile:Tile, list:Array, i:int;
			var featureInfo:Dictionary = new Dictionary();
			for(y = 0; y < _info.vTileCount; y++) {
				for(x = 0; x < _info.hTileCount; x++)
				{
					tile = new Tile(x, y, _info.tileWidth, _info.tileHeight, _info.staggered, _info.mapWidth, _info.mapHeight);
					tile.showType = showType;
					tile.name = "t" + x + "_" + y;
					tile.canPass = _info.data[y][x].canPass;
					tile.cover = _info.data[y][x].cover;
					tile.feature = _info.data[y][x].feature;
					AppCommon.app.canvasGroup.tileC.addChild(tile);
					
					if(tile.feature != null) {
						if(featureInfo[tile.feature] == null) featureInfo[tile.feature] = [];
						featureInfo[tile.feature].push({ tile:tile, index:_info.data[y][x].fIndex });
					}
				}
			}
			
			for each(list in featureInfo)
			{
				list.sortOn("index", Array.NUMERIC);
				for(i = 0; i < list.length; i++)
					list[i].tile.setIndex(list[i].index);
			}
			
			AppCommon.app.canvasGroup.tileWidth = _info.tileWidth;
			AppCommon.app.canvasGroup.tileHeight = _info.tileHeight;
			AppCommon.app.canvasGroup.twText.text = _info.tileWidth;
			AppCommon.app.canvasGroup.thText.text = _info.tileHeight;
			
			Toolbox.progressPanel.hide();
		}
		//
	}
}