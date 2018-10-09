package app.layers
{
	import app.common.AppCommon;
	import app.utils.LayerUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import lolo.core.Common;
	import lolo.utils.AutoUtil;
	import lolo.utils.ObjectUtil;
	
	import mx.core.IVisualElement;
	
	import spark.components.TabBar;
	
	/**
	 * 图层
	 * @author LOLO
	 */
	public class Layer extends Sprite
	{
		/**图层类型*/
		public var type:String;
		
		/**根据舞台尺寸调整位置的参数*/
		public var stageLayout:Object;
		/**自定义变量内容*/
		public var vars:String = "";
		/**设置的样式（StyleGroup面板获取值，改变需通过setStyle函数）*/
		public var style:Object;
		
		/**当前样式名称*/
		protected var _styleName:String;
		/**导出的样式*/
		protected var _exportStyle:Object;
		
		/**编辑器中未提供操作的其他属性*/
		protected var _otherProps:String = "";
		
		/**设置的图层的ID*/
		protected var _id:String = "";
		/**设置的宽*/
		protected var _width:uint = 0;
		/**设置的高*/
		protected var _height:uint = 0;
		/**设置的透明度（保存时，直接获取element.alpha会不精确）*/
		protected var _alpha:Number = -1;
		/**是否可见*/
		protected var _visible:Boolean = true;
		
		
		/**父容器的图层对象*/
		protected var _parentLayer:SpriteLayer;
		/**目标图层对象*/
		protected var _targetLayer:Layer;
		
		/**对应的显示元件*/
		protected var _element:DisplayObject;
		
		/**是否在编辑器中被选中*/
		protected var _veSelected:Boolean;
		/**图层是否可见*/
		protected var _veEye:Boolean = true;
		/**图层是否锁定*/
		protected var _veLock:Boolean;
		/**图层是否为引导层*/
		protected var _veIgnore:Boolean;
		
		
		
		
		public function Layer()
		{
			super();
			createElement();
			stageLayout = {
				enabled:false, hEnabled:true, vEnabled:true,
				width:"", height:"",
				hKey:"", hValue:"", vKey:"", vValue:""
			};
			initStyle(false);
		}
		
		
		/**
		 * 创建对应的显示元件，在构造函数调用，子类应覆盖该方法
		 */
		protected function createElement():void
		{
		}
		
		
		/**
		 * 初始化（组件在编辑器中拖放创建时被调用）
		 */
		public function init():void
		{
		}
		
		
		/**
		 * 初始化图层的舞台布局属性（打开文件时被调用）
		 */
		public function initStageLayout(jsonStr:String):void
		{
			LayerUtil.parseStageLayout(this, jsonStr);
		}
		
		
		/**
		 * 初始化图层的属性（打开文件时被调用）
		 */
		public function initProps(jsonStr:String):Object
		{
			return LayerUtil.parseProps(this, jsonStr);
		}
		
		
		
		
		/**
		 * 初始化样式
		 * @param setter 是否将样式应用到element
		 */
		public function initStyle(setter:Boolean=true):void
		{
			style = {};
		}
		
		/**
		 * 设置样式
		 * @param name 样式属性的名称
		 * @param value 样式属性的值
		 * @param setter 是否将样式应用到element
		 */
		public function setStyle(name:String, value:*, setter:Boolean=true):void
		{
			if(name == "leading") value = int(value);
			style[name] = value;
			if(!setter) return;
			
			var obj:Object = {};
			obj[name] = value;
			_element["style"] = obj;
			if(_width != 0 && _width != _element.width) _element.width = _width;
			if(_height != 0 && _height != _element.height) _element.height = _height;
			AppCommon.controller.updateFrame();
		}
		
		/**
		 * 根据样式名称设置样式
		 * @param styleName
		 * @param setter
		 */
		public function setStyleBySN(styleName:String, setter:Boolean=true):void
		{
			var obj:Object = ObjectUtil.baseClone(Common.config.getStyle(styleName));
			if(obj.thumbSourceName != null) {
				setStyle("thumbSourceName", obj.thumbSourceName, setter);
				delete obj.thumbSourceName;
			}
			for(var key:String in obj) setStyle(key, obj[key], setter);
		}
		
		/**
		 * 样式名称
		 */
		public function set styleName(value:String):void
		{
			_styleName = value;
			initStyle();
			setStyleBySN(value);
		}
		public function get styleName():String { return _styleName; }
		
		
		
		
		/**
		 * 在刷新界面（按F5）时，会调用的方法
		 */
		public function update():void
		{
		}
		
		
		
		/**
		 * 对应的显示元素
		 */
		public function set element(value:DisplayObject):void
		{
			if(_element && _element.parent == this) this.removeChild(_element);
			_element = value;
			this.addChild(_element);
		}
		public function get element():DisplayObject { return _element; }
		
		
		
		
		/**
		 * 在选中图层，绘制边框时，会获取矩形区域
		 */
		public function get bounds():Rectangle { return _element.getBounds(this); }
		
		
		/**
		 * 鼠标点击选中该图层时，会调用该方法，确认是否可以拖动
		 * @param event
		 * @return 
		 */
		public function canDrag(event:MouseEvent=null):Boolean { return !_veLock; }
		
		
		/**
		 * 是否在编辑器中被选中
		 */
		public function set veSelected(value:Boolean):void { _veSelected = value; }
		public function get veSelected():Boolean { return _veSelected; }
		
		
		
		
		
		/**
		 * 图层是否可见
		 */
		public function set veEye(value:Boolean):void
		{
			_veEye = value;
			_element.visible = _veEye && _visible;
		}
		public function get veEye():Boolean { return _veEye; }
		
		
		/**
		 * 图层是否锁定
		 */
		public function set veLock(value:Boolean):void { _veLock = value; }
		public function get veLock():Boolean { return _veLock; }
		
		
		/**
		 * 图层是否为引导层
		 */
		public function set veIgnore(value:Boolean):void { _veIgnore = value; }
		public function get veIgnore():Boolean { return _veIgnore; }
		
		
		
		
		
		/**
		 * 对应的容器图层对象
		 */
		public function get containerLayer():ContainerLayer { return this.parent.parent as ContainerLayer; }
		
		
		/**
		 * 父容器的图层对象
		 */
		public function set parentLayer(value:SpriteLayer):void
		{
			if(_parentLayer != null) {
				_element.x = _element.x - _parentLayer.x;
				_element.y = _element.y - _parentLayer.y;
				_parentLayer.removeChildLayer(this);
			}
			
			_parentLayer = value;
			if(_parentLayer != null) {
				_element.x = _element.x + _parentLayer.x;
				_element.y = _element.y + _parentLayer.y;
				_parentLayer.addChildLayer(this);
			}
			AppCommon.controller.updateFrame();
		}
		public function get parentLayer():SpriteLayer { return _parentLayer; }
		public function get parentID():String
		{
			if(_parentLayer == null) return null;
			if(_parentLayer.id == "") return null;
			return _parentLayer.id;
		}
		
		
		
		
		/**
		 * 目标图层对象
		 */
		public function set targetLayer(value:Layer):void { _targetLayer = value; }
		public function get targetLayer():Layer { return _targetLayer; }
		public function get targetID():String
		{
			if(_targetLayer == null) return null;
			if(_targetLayer.id == "") return null;
			return _targetLayer.id;
		}
		
		
		
		/**
		 * 图层的ID，用作代码引用
		 */
		public function set id(value:String):void
		{
			_id = value;
			if(LayerUtil.isContainer(this)) {
				var tb:TabBar = AppCommon.canvas.containerTB;
				if(tb.selectedItem != null && tb.selectedItem.container == this) {
					tb.selectedItem.name = _id;
					var renderer:IVisualElement = tb.dataGroup.getElementAt(tb.selectedIndex) as IVisualElement;
					tb.updateRenderer(renderer, tb.selectedIndex, tb.selectedItem);
				}
			}
		}
		public function get id():String { return _id; }
		
		
		override public function set x(value:Number):void
		{
			_element.x = int(value);
			if(_parentLayer != null) _element.x += _parentLayer.x;
		}
		override public function get x():Number
		{
			if(_parentLayer == null) return _element.x;
			return _element.x - _parentLayer.x;
		}
		
		
		override public function set y(value:Number):void
		{
			_element.y = int(value);
			if(_parentLayer != null) _element.y += _parentLayer.y;
		}
		override public function get y():Number
		{
			if(_parentLayer == null) return _element.y;
			return _element.y - _parentLayer.y;
		}
		
		
		override public function set width(value:Number):void
		{
			_width = uint(value);
			_element.width = _width;
		}
		override public function get width():Number
		{
			return (_width != 0) ? _width : _element.width;
		}
		
		
		override public function set height(value:Number):void
		{
			_height = uint(value);
			_element.height = _height;
		}
		override public function get height():Number
		{
			return (_height != 0) ? _height : _element.height;
		}
		
		
		override public function set visible(value:Boolean):void
		{
			_visible = value;
			_element.visible = _veEye && _visible;
		}
		override public function get visible():Boolean { return _visible; }
		
		
		
		override public function set scaleX(value:Number):void { _element.scaleX = value; }
		override public function get scaleX():Number { return _element.scaleX; }
		
		
		override public function set scaleY(value:Number):void { _element.scaleY = value; }
		override public function get scaleY():Number { return _element.scaleY; }
		
		
		override public function set mouseEnabled(value:Boolean):void { _element["mouseEnabled"] = value; }
		override public function get mouseEnabled():Boolean { return _element["mouseEnabled"]; }
		
		override public function set mouseChildren(value:Boolean):void { _element["mouseChildren"] = value; }
		override public function get mouseChildren():Boolean { return _element["mouseChildren"]; }
		
		
		override public function set alpha(value:Number):void
		{ 
			_alpha = value;
			_element.alpha = value;
		}
		override public function get alpha():Number
		{
			if(_alpha != -1) return _alpha;
			return _element.alpha;
		}
		
		
		
		
		/**
		 * 阻止事件流中当前节点，以及后续所有节点中的事件侦听器进行处理
		 * @param event
		 */
		protected function stopImmediatePropagation(event:Event):void
		{
			event.stopImmediatePropagation();
		}
		
		
		
		
		
		/**
		 * 获取在编辑器中使用的属性
		 */
		public function get editorProps():Object
		{
			var props:Object = {};
			
			if(!_veEye) props.eye = _veEye;
			if(_veLock) props.lock = _veLock;
			if(_veIgnore) props.ignore = _veIgnore;
			
			for(var p:String in props) return props;
			return null;
		}
		
		
		
		/**
		 * 编辑器中未提供操作的其他属性
		 */
		public function set otherProps(value:String):void
		{
			_otherProps = value;
			try {
				var obj:Object = JSON.parse(_otherProps);
				AutoUtil.initObject(_element, obj);
			}
			catch(error:Error){}
		}
		public function get otherProps():String { return _otherProps; }
		
		
		
		/**
		 * 获取有改动的属性
		 */
		public function get properties():Object
		{
			var props:Object = {};
			if(x != 0) props.x = x;
			if(y != 0) props.y = y;
			if(alpha != 1) props.alpha = alpha;
			if(!_visible) props.visible = _visible;
			if(rotation != 0) props.rotation = rotation;
			
			if(_width != 0) props.width = _width;
			else if(scaleX != 1) props.scaleX = scaleX;
			
			if(_height != 0) props.height = _height;
			else if(scaleY != 1) props.scaleY = scaleY;
			
			
			var b:Boolean = !LayerUtil.isImageLoader(this)
				&& !LayerUtil.isArtText(this)
				&& !LayerUtil.isBtimapSprite(this)
				&& !LayerUtil.isAnimation(this);
			
			if(mouseEnabled != b) props.mouseEnabled = mouseEnabled;
			
			
			if(!LayerUtil.isBaseTextField(this) && !LayerUtil.isDisplayObject(this))
			{
				b = LayerUtil.isContainer(this)
					|| LayerUtil.isSprite(this)
					|| LayerUtil.isItemGroup(this)
					|| LayerUtil.isList(this)
					|| LayerUtil.isScrollBar(this)
					|| LayerUtil.isPage(this)
					|| LayerUtil.isModalBackground(this);
				if(mouseChildren != b) props.mouseChildren = mouseChildren;
			}
			
			//这里设置样式名，子类再根据自己的样式名进行剔除
			if(_styleName != null) props.styleName = _styleName;
			
			return props;
		}
		
		
		
		/**
		 * 获取有改变的样式
		 */
		public function get changedStyle():Object
		{
			if(_styleName == null) return {};
			
			//取到默认样式，子类再从默认样式中剔除没变动的样式
			var tempStyle:Object = style;
			initStyle(false);
			setStyleBySN(_styleName, false);//用户选择的样式
			_exportStyle = style;
			style = tempStyle;//置回当前样式的引用
			
			return _exportStyle;
		}
		
		
		/**
		 * 更新_exportStyle中有改变的样式，或排除没有变动的样式
		 * @param styleName
		 */
		protected function checkStyle(styleName:String):void
		{
			if(style[styleName] == _exportStyle[styleName])
				delete _exportStyle[styleName];
			else
				_exportStyle[styleName] = style[styleName];
		}
		//
	}
}