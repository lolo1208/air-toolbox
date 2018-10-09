package toolbox.utils
{
	import flash.utils.describeType;
	
	
	/**
	 * 在转换成JSON字符串时，保证 Object 的属性生成是有序的<br/>
	 * 改自 com.adobe.serialization.json.JSONEncoder
	 * @author LOLO
	 */
	public class SortJSONEncoder
	{
		
		/**
		 * 获取 obj 对应的JSON字符串
		 * @param obj
		 * @return 
		 */
		public static function stringify(obj:*):String
		{
			return convertToString(obj);
		}
		
		
		
		/**
		 * Converts a value to it's JSON string equivalent.
		 *
		 * @param value The value to convert.  Could be any 
		 *		type (object, number, array, etc)
		 */
		private static function convertToString( value:* ):String
		{
			// determine what value is and convert it based on it's type
			if ( value is String ) {
				
				// escape the string so it's formatted correctly
				return escapeString( value as String );
				
			} else if ( value is Number ) {
				
				// only encode numbers that finate
				return isFinite( value as Number) ? value.toString() : "null";

			} else if ( value is Boolean ) {
				
				// convert boolean to string easily
				return value ? "true" : "false";

			} else if ( value is Array ) {
			
				// call the helper method to convert an array
				return arrayToString( value as Array );
			
			} else if ( value is Object && value != null ) {
			
				// call the helper method to convert an object
				return objectToString( value );
			}
            return "null";
		}
		
		
		
		
		/**
		 * Escapes a string accoding to the JSON specification.
		 *
		 * @param str The string to be escaped
		 * @return The string with escaped special characters
		 * 		according to the JSON specification
		 */
		private static function escapeString( str:String ):String
		{
			// create a string to store the string's jsonstring value
			var s:String = "";
			// current character in the string we're processing
			var ch:String;
			// store the length in a local variable to reduce lookups
			var len:Number = str.length;
			
			// loop over all of the characters in the string
			for ( var i:int = 0; i < len; i++ ) {
			
				// examine the character to determine if we have to escape it
				ch = str.charAt( i );
				switch ( ch ) {
				
					case '"':	// quotation mark
						s += "\\\"";
						break;
						
					//case '/':	// solidus
					//	s += "\\/";
					//	break;
						
					case '\\':	// reverse solidus
						s += "\\\\";
						break;
						
					case '\b':	// bell
						s += "\\b";
						break;
						
					case '\f':	// form feed
						s += "\\f";
						break;
						
					case '\n':	// newline
						s += "\\n";
						break;
						
					case '\r':	// carriage return
						s += "\\r";
						break;
						
					case '\t':	// horizontal tab
						s += "\\t";
						break;
						
					default:	// everything else
						
						// check for a control character and escape as unicode
						if ( ch < ' ' ) {
							// get the hex digit(s) of the character (either 1 or 2 digits)
							var hexCode:String = ch.charCodeAt( 0 ).toString( 16 );
							
							// ensure that there are 4 digits by adjusting
							// the # of zeros accordingly.
							var zeroPad:String = hexCode.length == 2 ? "00" : "000";
							
							// create the unicode escape sequence with 4 hex digits
							s += "\\u" + zeroPad + hexCode;
						} else {
						
							// no need to do any special encoding, just pass-through
							s += ch;
							
						}
				}	// end switch
				
			}	// end for loop
						
			return "\"" + s + "\"";
		}
		
		
		
		/**
		 * Converts an array to it's JSON string equivalent
		 *
		 * @param a The array to convert
		 * @return The JSON string representation of <code>a</code>
		 */
		private static function arrayToString( a:Array ):String
		{
			// create a string to store the array's jsonstring value
			var s:String = "";
			
			// loop over the elements in the array and add their converted
			// values to the string
			for ( var i:int = 0; i < a.length; i++ ) {
				// when the length is 0 we're adding the first element so
				// no comma is necessary
				if ( s.length > 0 ) {
					// we've already added an element, so add the comma separator
					s += ","
				}
				
				// convert the value to a string
				s += convertToString( a[i] );	
			}
			
			// KNOWN ISSUE:  In ActionScript, Arrays can also be associative
			// objects and you can put anything in them, ie:
			//		myArray["foo"] = "bar";
			//
			// These properties aren't picked up in the for loop above because
			// the properties don't correspond to indexes.  However, we're
			// sort of out luck because the JSON specification doesn't allow
			// these types of array properties.
			//
			// So, if the array was also used as an associative object, there
			// may be some values in the array that don't get properly encoded.
			//
			// A possible solution is to instead encode the Array as an Object
			// but then it won't get decoded correctly (and won't be an
			// Array instance)
						
			// close the array and return it's string value
			return "[" + s + "]";
		}
		
		
		
		/**
		 * Converts an object to it's JSON string equivalent
		 *
		 * @param o The object to convert
		 * @return The JSON string representation of <code>o</code>
		 */
		private static function objectToString( o:Object ):String
		{
			// create a string to store the object's jsonstring value
			var s:String = "";
			
			// determine if o is a class instance or a plain object
			var classInfo:XML = describeType( o );
			if ( classInfo.@name.toString() == "Object" )
			{
				var keys:Array = [];
				for(var key:String in o) keys.push(key);
				keys.sort();
				
				var len:int = keys.length;
				for(var i:int = 0; i < len; i++)
				{
					key = keys[i];
					var value:* = o[key];
					if(value is Function) continue;
					
					if(i != 0) s += ",";
					
					s += escapeString(key) + ":" + convertToString(value);
				}
			}
			else // o is a class instance
			{
				// Loop over all of the variables and accessors in the class and 
				// serialize them along with their values.
				for each ( var v:XML in classInfo..*.( 
					name() == "variable"
					||
					( 
						name() == "accessor"
						// Issue #116 - Make sure accessors are readable
						&& attribute( "access" ).charAt( 0 ) == "r" ) 
					) )
				{
					// Issue #110 - If [Transient] metadata exists, then we should skip
					if ( v.metadata && v.metadata.( @name == "Transient" ).length() > 0 )
					{
						continue;
					}
					
					// When the length is 0 we're adding the first item so
					// no comma is necessary
					if ( s.length > 0 ) {
						// We've already added an item, so add the comma separator
						s += ","
					}
					
					s += escapeString( v.@name.toString() ) + ":" 
							+ convertToString( o[ v.@name ] );
				}
				
			}
			
			return "{" + s + "}";
		}
		
		//
	}
}
