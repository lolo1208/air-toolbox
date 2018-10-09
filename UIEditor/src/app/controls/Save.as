package app.controls
{
	import app.common.AppCommon;
	import app.layers.BaseButtonLayer;
	import app.layers.ContainerLayer;
	import app.layers.DisplayObjectLayer;
	import app.layers.Layer;
	import app.layers.PageListLayer;
	import app.utils.LayerUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;
	
	import lolo.utils.MathUtil;
	import lolo.utils.StringUtil;
	
	import mx.collections.IList;
	import mx.controls.Alert;
	
	import toolbox.Toolbox;
	
	/**
	 * 保存配置文件控制器
	 * @author LOLO
	 */
	public class Save
	{
		/**生成xml时，属性的排列优先级索引列表*/
		private static var _propertiesIndexDic:Dictionary;
		/**在生成xml节点属性时，是否遇到了错误*/
		private static var _hasError:Boolean;
		
		
		
		/**
		 * 保存当前界面编辑器的内容
		 */
		public static function save():void
		{
			if(_propertiesIndexDic == null)
			{
				var propertiesList:Array = [
					"x", "y", "width", "height", "scaleX", "scaleY", "alpha", "rotation",
					"sourceName", "enabled", "selected",
					"fps", "playing", "currentFrame",
					"color",
					"autoSize", "multiline", "textID", "text",
					"label", "labelID",
					"firstBtnProp", "lastBtnProp", "prevBtnProp", "nextBtnProp", "pageTextProp",
					"direction", "viewableArea",
					"bounces", "scrollPolicy",
					"horizontalGap", "verticalGap",
					"columnCount", "rowCount",
					"prefix", "align", "valign", "spacing"
				];
				
				_propertiesIndexDic = new Dictionary();
				for(var ii:int = 0; ii < propertiesList.length; ii++) {
					_propertiesIndexDic[propertiesList[ii]] = ii;
				}
			}
			
			
			var dataProvider:IList = AppCommon.canvas.containerTB.dataProvider;
			if(dataProvider.length == 0) return;
			
			_hasError = false;
			var xml:XML = <config/>;
			var i:int, cData:Object, cLayer:ContainerLayer, container:XML;
			var n:int, layer:Layer, item:XML;
			var parentXMLs:Array = [];
			for(i = 0; i < dataProvider.length; i++)
			{
				cData = dataProvider.getItemAt(i);
				cLayer = cData.container;
				
				//最底层容器
				if(i == 0) {
					container = xml;
				}
				else {
					if(cLayer.extContainer) {
						container = <container/>;
						if(cData.name != "") container.@id = cData.name;
						if(cLayer.cType != "normal") container.@type = cLayer.cType;
					}
					else {
						if(cData.name == "") {
							Alert.show("未继承Container的容器，ID不能为空！", "提示");
							return;
						}
						container = new XML("<" + cData.name + "/>");
					}
					
					if(cLayer.parentXML == "") {
						insertChild(xml, container, cLayer.depth);
					}
					else {
						parentXMLs.push({
							container	: container,
							depth		: cLayer.depth,
							parentXML	: cLayer.parentXML,
							pathLength	: cLayer.parentXML.length
						});
					}
				}
				createXMLNodeAttributes(container, cLayer);
				
				
				//生成容器中的元件
				for(n = 0; n < (cLayer.element as DisplayObjectContainer).numChildren; n++)
				{
					layer = (cLayer.element as DisplayObjectContainer).getChildAt(n) as Layer;
					item = new XML("<" + layer.type + "/>");
					createXMLNodeAttributes(item, layer);
					container.appendChild(item);
				}
			}
			
			//按照父级路径的字符串长短来排序
			parentXMLs.sortOn("pathLength", Array.NUMERIC);
			
			//放到所指的容器中
			for(i = 0; i < parentXMLs.length; i++)
			{
				var nameArr:Array = parentXMLs[i].parentXML.split(".");
				var pXML:XML = xml;
				for(n = 0; n < nameArr.length; n++)
				{
					var cName:String = nameArr[n];
					container = null;
					
					//先获取直接命名的子容器
					if(pXML[cName].length() > 0) {
						if(pXML[cName].length() > 1) {
							Alert.show("parentXML不明确，同一个ID(" + cName + ")出现多次：\n" + parentXMLs[i].parentXML, "提示");
							return;
						}
						else {
							container = pXML[cName][0];
						}
					}
					
					//再尝试获取继承至 Container 的容器
					if(container == null) {
						for(var j:int = 0; j < pXML.container.length(); j++) {
							if(pXML.container[j].@id == cName) {
								container = pXML.container[j];
								break;
							}
						}
					}
					
					//获取到容器了
					if(container != null) {
						pXML = container;
					}
					else {
						Alert.show("未能找到指定的parentXML：\n" + parentXMLs[i].parentXML + "\nposition : " + n, "提示");
						return;
					}
				}
				
				//顺利的取到了父容器XML，将内容添加到指定的图层深度
				insertChild(pXML, parentXMLs[i].container, parentXMLs[i].depth);
			}
			
			
			if(_hasError) return;
			
			//将组成的xml格式化
			var xmlStr:String = xml.toXMLString();
			xmlStr = xmlStr.replace(/&#xA;/g, "\\n");
			xmlStr = xmlStr.replace(/'/g, "\"");
			xmlStr = xmlStr.replace(/\"{/g, "'{");
			xmlStr = xmlStr.replace(/}\"/g, "}'");
//			xmlStr = xmlStr.replace(/  /g, "\t");//文本内容可能会连续输入两个空格
			
			/*
			Console.clear();
			Console.trace(dataProvider.getItemAt(0).name, "\n");
			Console.trace(xmlStr);
			*/
			
			//保存到配置文件中
			var file:File = new File(AppCommon.controller.configPath);
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			//fs.writeByte(0xEF);//BOM(Byte Order Mark)
			//fs.writeByte(0xBB);
			//fs.writeByte(0xBF);
			fs.writeUTFBytes('<?xml version="1.0" encoding="utf-8"?>\r\n');
			fs.writeUTFBytes(xmlStr);
			fs.close();
			
			//保存HTML5项目对应的JSON文件
			if(!Toolbox.isASProject) SaveJSON.save(new XML(xmlStr));
			
			//文字提示
			//var alertText:AlertText = AlertText.getInstance("succeeded");
			//alertText.x = Common.stage.stageWidth - alertText.textWidth >> 1;
			//alertText.y = Common.stage.stageHeight - alertText.textHeight >> 1;
			//alertText.show("保存配置文件成功！");
			AppCommon.app.savedTips.show();
		}
		
		
		
		/**
		 * 创建xml节点的属性
		 * @param node
		 * @param layer
		 */
		private static function createXMLNodeAttributes(node:XML, layer:Layer):void
		{
			if(!LayerUtil.isContainer(layer) && layer.id != "") node.@id = layer.id;
			
			if(layer.veIgnore) node.@ignore = "true";
			
			if(layer.parentID != null) node.@parent = layer.parentID;
			if(layer.targetID != null) node.@target = layer.targetID;
			
			if(LayerUtil.isBaseButton(layer) && (layer as BaseButtonLayer).groupID != null)
				node.@group = (layer as BaseButtonLayer).groupID;
			
			if(LayerUtil.isPageList(layer) && (layer as PageListLayer).pageID != null)
				node.@target = (layer as PageListLayer).pageID;
			
			if(LayerUtil.isDisplayObject(layer)) node.@definition = (layer as DisplayObjectLayer).definition;
			
			
			createProperties(node, layer.properties);
			createProps(node, layer.otherProps);
			createStyle(node, layer.changedStyle);
			createVars(node, layer.vars);
			createStageLayout(node, layer.stageLayout);
			createEditorProps(node, layer.editorProps);
		}
		
		
		/**
		 * 创建属性
		 * @param item 对item的引用
		 * @param properties
		 */
		private static function createProperties(item:XML, properties:Object):void
		{
			//获取属性的排序index，并存入数组
			var list:Array = [];
			for(var key:String in properties) {
				list.push({ name:key, value:properties[key], index:_propertiesIndexDic[key] });
			}
			if(list.length == 0) return;
			
			//属性按index升序
			list.sortOn("index", Array.NUMERIC);
			
			//组成json字符串
			var jsonStr:String = "{";
			var i:int, prop:Object, isString:Boolean;
			for(i = 0; i < list.length; i++) {
				prop = list[i];
				jsonStr = addJsonProp(jsonStr, prop.name, prop.value);
			}
			jsonStr += "}";
			item.@properties = jsonStr;
		}
		
		
		/**
		 * 创建样式
		 * @param item
		 * @param style
		 */
		private static function createStyle(item:XML, style:Object):void
		{
			if(style == null) return;
			
			var changed:Boolean;
			for(var key:String in style) {
				changed = true;
				break;
			}
			
			if(!changed) return;
			
			item.@style = jsonStringToXMLString(JSON.stringify(style), false);
		}
		
		
		/**
		 * 创建自定义变量
		 * @param item
		 * @param vars
		 */
		private static function createVars(item:XML, vars:String):void
		{
			//空字符串
			var str:String = StringUtil.trim(vars);
			if(str.length == 0) return;
			
			//错误的JSON数据
			try {
				JSON.parse(str);
			}
			catch (error:Error) {
				_hasError = true;
				Alert.show("错误的JSON数据：\n" + str, "自定义变量");
				return;
			}
			
			item.@vars = jsonStringToXMLString(str);
		}
		
		
		/**
		 * 创建编辑器中未提供操作的其他属性
		 * @param item
		 * @param vars
		 */
		private static function createProps(item:XML, props:String):void
		{
			var str:String = StringUtil.trim(props);
			if(str.length == 0) return;
			
			try {
				JSON.parse(str);
			}
			catch (error:Error) {
				_hasError = true;
				Alert.show("错误的JSON数据：\n" + str, "其他属性");
				return;
			}
			
			item.@props = jsonStringToXMLString(str);
		}
		
		
		/**
		 * 创建舞台布局属性
		 * @param item
		 * @param stageLayout
		 */
		private static function createStageLayout(item:XML, stageLayout:Object):void
		{
			//未启用舞台布局属性
			if(!stageLayout.enabled || (!stageLayout.hEnabled && !stageLayout.vEnabled)) return;
			
			var value:Number;
			var jsonStr:String = "{";
			
			if(stageLayout.hEnabled) {
				if(stageLayout.width != "") jsonStr = addJsonProp(jsonStr, "width", int(stageLayout.width));
				if(stageLayout.hKey != "") {
					value = (stageLayout.hKey == "x") ? MathUtil.percentageToDecimal(stageLayout.hValue) : stageLayout.hValue;
					if(isNaN(value)) {
						_hasError = true;
						Alert.show("错误的 stageLayout.x：" + stageLayout.hValue, "提示");
					}
					else {
						jsonStr = addJsonProp(jsonStr, stageLayout.hKey, value);
					}
				}
			}
			else {
				jsonStr = addJsonProp(jsonStr, "cancelH", true);
			}
			
			if(stageLayout.vEnabled) {
				if(stageLayout.height != "") jsonStr = addJsonProp(jsonStr, "height", int(stageLayout.height));
				if(stageLayout.vKey != "") {
					value = (stageLayout.vKey == "y") ? MathUtil.percentageToDecimal(stageLayout.vValue) : stageLayout.vValue;
					if(isNaN(value)) {
						_hasError = true;
						Alert.show("错误的 stageLayout.y：" + stageLayout.vValue, "提示");
					}
					else {
						jsonStr = addJsonProp(jsonStr, stageLayout.vKey, value);
					}
				}
			}
			else {
				jsonStr = addJsonProp(jsonStr, "cancelV", true);
			}
			
			jsonStr += "}";
			item.@stageLayout = jsonStr;
		}
		
		
		/**
		 * 创建在编辑器中使用的辅助属性
		 * @param item
		 * @param editorProps
		 */
		private static function createEditorProps(item:XML, editorProps:Object):void
		{
			if(editorProps == null) return;
			
			item.@editorProps = jsonStringToXMLString(JSON.stringify(editorProps), false);
		}
		
		
		
		
		/**
		 * 将JSON字符串中的特殊字符，替换成组成XML需要的字符
		 * @param jsonStr
		 * @param replaceSpace
		 * @return 
		 */
		private static function jsonStringToXMLString(jsonStr:String, replaceSpace:Boolean=true):String
		{
			jsonStr = jsonStr.replace(/\"/g, "'");
			if(replaceSpace) jsonStr = jsonStr.replace(/ /g, "");
			jsonStr = jsonStr.replace(/\n/g, "");
			jsonStr = jsonStr.replace(/,/g, ", ");
			return jsonStr;
		}
		
		
		/**
		 * 在传入的jsonStr后面加上一个json属性和对应的值，并返回传入的jsonStr
		 * @param jsonStr
		 * @param propName
		 * @param propValue
		 * @return 
		 */
		private static function addJsonProp(jsonStr:String, propName:String, propValue:*):String
		{
			var isString:Boolean = propValue is String;
			if(typeof(propValue) == "object") {
				propValue = JSON.stringify(propValue);
				propValue = propValue.replace(/\"/g, "'");
			}
			
			if(jsonStr != "{") jsonStr += ", ";
			jsonStr += "'" + propName + "':";
			jsonStr += isString ? "'" : "";
			jsonStr += propValue.toString();
			jsonStr += isString ? "'" : "";
			return jsonStr;
		}
		
		
		/**
		 * 将 child 插入到 parent 中，按照 depth 所指的图层深度。
		 * @param parent
		 * @param child
		 * @param depth 索引从0开始。值为 "" 表示插入到最后
		 */
		private static function insertChild(parent:XML, child:XML, depth:String=""):void
		{
			var d:uint = uint(depth);
			if(depth != "" && d < parent.*.length()) {
				parent.insertChildBefore(parent.*[d], child);
			}
			else {
				parent.appendChild(child);
			}
		}
		//
	}
}