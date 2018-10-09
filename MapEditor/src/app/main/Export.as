package app.main
{
	import app.canvasGroup.Tile;
	import app.common.AppCommon;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.utils.StringUtil;
	import lolo.utils.zip.ZipWriter;
	
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import toolbox.Toolbox;
	import toolbox.utils.SortJSONEncoder;

	/**
	 * 导出
	 * @author LOLO
	 */
	public class Export
	{
		/**项目类型*/
		public static var appType:int;
		/**图块宽*/
		public static var chunkWidth:uint;
		/**图块高*/
		public static var chunkHeight:uint;
		/**缩略图最大宽*/
		public static var thumbnailWidth:uint;
		/**缩略图最大高*/
		public static var thumbnailHeight:uint;
		
		
		
		private static var _bgC:Sprite;
		private static var _drawTarget:Sprite;
		
		/**保存文件的根目录*/
		private static var _rootDir:String;
		/**需要被导出的图块列表*/
		private static var _chunkList:Array;
		/**正在保存的地图信息*/
		private static var _mapInfo:Object;
		/**正在保存的源文件*/
		private static var _sourceData:ZipWriter;
		
		private static var _tileWidth:uint;
		private static var _tileHeight:uint;
		
		
		
		
		/**
		 * 开始导出
		 */
		public static function start():void
		{
			_bgC = AppCommon.app.canvasGroup.bgC;
			_drawTarget = AppCommon.app.canvasGroup.drawTarget;
			
			try {
				_rootDir = Toolbox.docPath;
				new File(_rootDir).deleteDirectory(true);
			}
			catch(error:Error) {}
			
			_chunkList = [];
			var v:int = Math.ceil(_bgC.height / chunkHeight);
			var h:int = Math.ceil(_bgC.width / chunkWidth);
			var x:int, y:int;
			for(y = 0; y < v; y++) {
				for(x = 0; x < h; x++) _chunkList.push({ x:x, y:y });
			}
			
			try {
				var tile:Tile = AppCommon.app.canvasGroup.getTile(0, 0);
				_tileWidth = tile.tileWidth;
				_tileHeight = tile.tileHeight;
			}
			catch(error:Error) {
				Alert.show("您还未生成区块，无法保存数据！", "错误");
				return;
			}
			_sourceData = new ZipWriter();
			
			Toolbox.progressPanel.show(_chunkList.length + 3);
			Common.stage.addEventListener(Event.ENTER_FRAME, saveNextChunk);
		}
		
		
		
		/**
		 * 保存下一张图块
		 */
		private static function saveNextChunk(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, saveNextChunk);
			
			var chunkInfo:Object = _chunkList.shift();
			
			var w:int = _bgC.width - chunkWidth * chunkInfo.x;
			if(w > chunkWidth) w = chunkWidth;
			var h:int = _bgC.height - chunkHeight * chunkInfo.y;
			if(h > chunkHeight) h = chunkHeight;
			
			//提取图片像素数据
			var bitmapData:BitmapData = new BitmapData(w, h);
			bitmapData.draw(_drawTarget, new Matrix(1, 0, 0, 1, -chunkWidth * chunkInfo.x, -chunkHeight * chunkInfo.y));
			
			//封装成自定义数据
			var bytes:ByteArray = new ByteArray();
			if(isASProject) bytes.writeByte(Constants.FLAG_CD);//AS项目，写入标记
			bytes.writeBytes(bitmapData.encode(bitmapData.rect, new JPEGEncoderOptions()));
			
			//写入文件
			var extension:String = isASProject ? Constants.EXTENSION_LD : "chunk";
			var file:File = new File(_rootDir + "\\chunks\\" + chunkInfo.x + "_" + chunkInfo.y + "." + extension);
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(bytes);
			stream.close();
			
			
			Toolbox.progressPanel.addProgress();
			if(_chunkList.length > 0) {
				Common.stage.addEventListener(Event.ENTER_FRAME, saveNextChunk);
			}
			else {
				Common.stage.addEventListener(Event.ENTER_FRAME, saveInfoFile);
			}
		}
		
		
		/**
		 * 保存区块和配置信息
		 */
		private static function saveInfoFile(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, saveInfoFile);
			
			//区块和配置信息
			var v:int = AppCommon.app.canvasGroup.vTileCount;
			var h:int = AppCommon.app.canvasGroup.hTileCount;
			var arr:Array = [];
			var x:int, y:int, tile:Tile;
			for(y = 0; y < v; y++) {
				arr[y] = [];
				for(x = 0; x < h; x++) {
					tile = AppCommon.app.canvasGroup.getTile(x, y);
					if(tile == null) {
						Alert.show("区块未包含到整个背景，请重新生成区块！", "错误");
						Toolbox.progressPanel.hide();
						return;
					}
					else {
						arr[y][x] = { canPass:tile.canPass, cover:tile.cover, feature:tile.feature, fIndex:tile.index };
					}
				}
			}
			
			var vChunkCount:int = Math.ceil(_bgC.height / chunkHeight);
			var hChunkCount:int = Math.ceil(_bgC.width / chunkWidth);
			_mapInfo = {
				mapWidth:_bgC.width, mapHeight:_bgC.height,
				tileWidth:_tileWidth, tileHeight:_tileHeight,
				chunkWidth:chunkWidth, chunkHeight:chunkHeight,
				hTileCount:h, vTileCount:v,
				hChunkCount:hChunkCount, vChunkCount:vChunkCount,
				staggered:AppCommon.app.canvasGroup.staggeredCB.selected,
				data:arr
			};
			
			
			//保存缩略图
			var scale:Number = Math.min(thumbnailWidth / _bgC.width, thumbnailHeight / _bgC.height);
			var bitmapData:BitmapData = new BitmapData(_bgC.width * scale, _bgC.height * scale);
			var matrix:Matrix = new Matrix();
			matrix.scale(scale, scale);
			bitmapData.draw(_drawTarget, matrix);
			bitmapData.applyFilter(bitmapData, new Rectangle(0,0,bitmapData.width,bitmapData.height), new Point(), new BlurFilter(1.1, 1.1));
			
			var file:File = new File(_rootDir + "\\thumbnail.jpg");
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(bitmapData.encode(bitmapData.rect, new JPEGEncoderOptions(80)));
			stream.close();
			
			_mapInfo.thumbnailScale = scale;
			
			
			//保存遮挡物
			_mapInfo.covers = [];
			var coverList:IList = AppCommon.app.layerPanel.coverList.dataProvider;
			var i:int = coverList.length - 1;
			var layer:Sprite;
			var pngData:ByteArray;
			for(;i >= 0; i--) {
				layer = coverList.getItemAt(i).layer;
				bitmapData = new BitmapData(layer.width, layer.height, true, 0);
				bitmapData.draw(layer);
				pngData = bitmapData.encode(bitmapData.rect, new PNGEncoderOptions());
				
				file = new File(_rootDir + "\\covers\\" + i +".png");
				stream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeBytes(pngData);
				stream.close();
				
				_sourceData.addFile("cover" + i +".png", pngData);//保存到源文件里
				
				_mapInfo.covers.push({id:i, point:new Point(layer.x, layer.y)});
			}
			
			//保存区块和配置信息
			var mapData:ByteArray = new ByteArray();
			if(isASProject) {
				mapData.writeByte(Constants.FLAG_MI);//写入类型标记
				mapData.writeObject(_mapInfo);
				mapData.compress();
			}
			else {
				var info:Object = {
					mapWidth : _mapInfo.mapWidth,
					mapHeight : _mapInfo.mapHeight,
					thumbnailScale : _mapInfo.thumbnailScale,
					staggered : _mapInfo.staggered,
					tileWidth : _mapInfo.tileWidth,
					tileHeight : _mapInfo.tileHeight,
					hTileCount : _mapInfo.hTileCount,
					vTileCount : _mapInfo.vTileCount,
					chunkWidth : _mapInfo.chunkWidth,
					chunkHeight : _mapInfo.chunkHeight,
					hChunkCount : _mapInfo.hChunkCount,
					vChunkCount : _mapInfo.vChunkCount
				};
				
				info.data = [];
				info.features = {};
				for(y = 0; y < v; y++) {
					info.data[y] = [];
					for(x = 0; x < h; x++) {
						tile = AppCommon.app.canvasGroup.getTile(x, y);
						info.data[y][x] = {};
						if(tile.canPass) info.data[y][x].p = true;// p
						if(tile.cover) info.data[y][x].c = true;// c
						if(tile.feature != null) {
							info.data[y][x].f = tile.feature;// f
							
							if(info.features[tile.feature] == null) info.features[tile.feature] = [];
							info.features[tile.feature].push({ x:x, y:y });
						}
					}
				}
				mapData.writeUTFBytes(SortJSONEncoder.stringify(info));
			}
			
			var extension:String = isASProject ? Constants.EXTENSION_LD : "json";
			file = new File(_rootDir + "\\info." + extension);
			stream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(mapData);
			stream.close();
			
			
			Toolbox.progressPanel.addProgress();
			Common.stage.addEventListener(Event.ENTER_FRAME, saveSourceFile);
		}
		
		
		/**
		 * 保存源文件
		 */
		private static function saveSourceFile(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, saveSourceFile);
			
			var bgList:IList = AppCommon.app.layerPanel.bgList.dataProvider;
			var i:int = bgList.length - 1;
			var layer:Sprite;
			var bitmapData:BitmapData;
			_mapInfo.bgs = [];//源文件里才有背景列表
			for(;i >= 0; i--) {
				//背景
				layer = bgList.getItemAt(i).layer;
				bitmapData = new BitmapData(layer.width, layer.height, true, 0);
				bitmapData.draw(layer);
				_sourceData.addFile(
					"bg" + i +".png",
					bitmapData.encode(bitmapData.rect, new PNGEncoderOptions())
				);
				
				_mapInfo.bgs.push({id:i, point:new Point(layer.x, layer.y)});
			}
			
			var mapData:ByteArray = new ByteArray();
			mapData.writeObject(_mapInfo);
			_sourceData.addFile("mapData", mapData);
			_sourceData.finish();
			
			var file:File = new File(_rootDir + "\\sourceData.zip");
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(_sourceData.byteArray);
			fs.close();
			
			
			Toolbox.progressPanel.addProgress();
			Common.stage.addEventListener(Event.ENTER_FRAME, saveServerMapInfo);
		}
		
		
		/**
		 * 保存后端需要的配置信息
		 */
		private static function saveServerMapInfo(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, saveServerMapInfo);
			
			var file:File = new File(_rootDir + "\\serverMapInfo.txt");
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			var featureList:Dictionary = new Dictionary();
			for(var y:int = 0; y < _mapInfo.vTileCount; y++)
			{
				for(var x:int = 0; x < _mapInfo.hTileCount; x++) {
					var tile:Tile = AppCommon.app.canvasGroup.getTile(x, y);
					fs.writeUTFBytes(tile.canPass ? "1" : "0");
					
					if(tile.feature != null) {
						if(featureList[tile.feature] == null) featureList[tile.feature] = [];
						featureList[tile.feature].push({ index:tile.index, x:x, y:y });
					}
					
				}
				fs.writeUTFBytes("\n");
			}
			
			//写入特性
			fs.writeUTFBytes("---");
			for(var key:String in featureList) {
				fs.writeUTFBytes("\n" + key + ":");
				var list:Array = featureList[key];
				list.sortOn("index", Array.NUMERIC);
				for(var i:int = 0; i < list.length; i++) {
					fs.writeUTFBytes(list[i].x + "," + list[i].y + ";");
				}
			}
			fs.close();
			
			Toolbox.progressPanel.hide();
			Alert.show("导出完毕！", "提示", Alert.OK, null, closeHandler);
		}
		
		
		
		
		/**
		 * 保存完毕，查看目录
		 * @param event
		 */
		private static function closeHandler(event:CloseEvent):void
		{
			if(event.detail == Alert.OK) {
				var args:Vector.<String> = new Vector.<String>();
				args.push(StringUtil.slashToBackslash(_rootDir));
				
				var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				npsi.executable = new File(Toolbox.explorerPath);
				npsi.arguments = args;
				new NativeProcess().start(npsi);
			}
		}
		
		
		
		/**是否为ActionScript项目*/
		public static function get isASProject():Boolean { return appType == 1; }
		
		//
	}
}