package app.main
{
	import app.canvasGroup.Tile;
	import app.common.AppCommon;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import lolo.core.Common;
	import lolo.utils.StringUtil;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import toolbox.Toolbox;

	/**
	 * 导出区块辅助线
	 * @author LOLO
	 */
	public class ExportTile
	{
		private static var _tileC:Sprite;
		private static var _bd:BitmapData;
		
		
		
		/**
		 * 开始导出
		 */
		public static function start():void
		{
			if(AppCommon.app.canvasGroup.tileC.numChildren == 0) {
				Alert.show("请生成区块，然后再尝试导出区块辅助线！", "提示");
				return;
			}
			Toolbox.progressPanel.show(3, 1, "正在导出区块辅助线...");
			
			Common.stage.addEventListener(Event.ENTER_FRAME, create);
		}
		
		
		
		/**
		 * 生成区块
		 * @param event
		 */
		private static function create(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, create);
			
			if(_tileC == null) _tileC = new Sprite();
			for(var i:int=0; i < AppCommon.app.canvasGroup.tileC.numChildren; i++) {
				var t:Tile = AppCommon.app.canvasGroup.tileC.getChildAt(i) as Tile;
				var tile:Tile = new Tile(
					t.point.x, t.point.y,
					t.tileWidth, t.tileHeight,
					t.staggered, t.mapWidth, t.mapHeight
				);
				tile.canPass = true;
				_tileC.addChild(tile);
			}
			
			Common.stage.addEventListener(Event.ENTER_FRAME, draw);
		}
		
		
		/**
		 * 将区块绘制成 BitmapData
		 * @param event
		 */
		private static function draw(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, draw);
			Toolbox.progressPanel.addProgress();
			
			var rect:Rectangle = _tileC.getBounds(_tileC);
			_bd = new BitmapData(_tileC.width, _tileC.height, true, 0x0);
			_bd.draw(_tileC, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
			
			Common.stage.addEventListener(Event.ENTER_FRAME, save);
		}
		
		
		/**
		 * 保存区块 BitmapData
		 * @param event
		 */
		private static function save(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, save);
			Toolbox.progressPanel.addProgress();
			
			try {
				new File(Toolbox.docPath).deleteDirectory(true);
			}
			catch(error:Error) {}
			
			var bytes:ByteArray = _bd.encode(_bd.rect, new PNGEncoderOptions())
			var file:File = new File(Toolbox.docPath + "tile.png");
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(bytes);
			fs.close();
			
			Common.stage.addEventListener(Event.ENTER_FRAME, dispose);
		}
		
		
		/**
		 * 清理，释放
		 * @param event
		 */
		private static function dispose(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, dispose);
			
			_tileC.removeChildren();
			_bd.dispose();
			_bd = null;
			
			Toolbox.progressPanel.hide();
			Alert.show("导出区块辅助线完毕！", "提示", Alert.OK, null, closeHandler);
		}
		
		
		
		/**
		 * 保存完毕，查看目录
		 * @param event
		 */
		private static function closeHandler(event:CloseEvent):void
		{
			if(event.detail == Alert.OK) {
				var args:Vector.<String> = new Vector.<String>();
				args.push(StringUtil.slashToBackslash(Toolbox.docPath));
				
				var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				npsi.executable = new File(Toolbox.explorerPath);
				npsi.arguments = args;
				new NativeProcess().start(npsi);
			}
		}
		//
	}
}