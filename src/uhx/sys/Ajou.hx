package uhx.sys;

import uhx.mo.Token;
import byte.ByteData;
import uhx.lexer.CssLexer;
import uhx.lexer.CssParser;
import uhx.Tappi;

typedef AjouPlugin = {
	public function handler(tokens:Array<Token<CssKeywords>>, ajou:Ajou):Array<Token<CssKeywords>>;
}

/**
 * ...
 * @author Skial Bainn
 * Haitian Creole for upgrade
 */
class Ajou {
	
	private var parser:CssParser;
	private var tokens:Array<Token<CssKeywords>>;
	
	private var callbacks:Array<Array<Token<CssKeywords>>->Ajou->Array<Token<CssKeywords>>>;
	
	#if tappi
	public var tappi:Tappi;
	#end
	
	public function new(css:String) {
		callbacks = [];
		
		parser = new CssParser();
		tokens = parser.toTokens( ByteData.ofString( css ), 'ajou' );
		
		#if tappi
		tappi = new Tappi([], true);
		#end
	}
	
	public function use(plugin:String):Void {
		#if tappi
		tappi.libraries.push( plugin );
		#end
	}
	
	public function rework():Void {
		#if tappi
		tappi.find();
		tappi.load();
		
		for (id in tappi.classes.keys()) {
			var cls:AjouPlugin = std.Type.createInstance( tappi.classes.get( id ), [] );
			callbacks.push( cls.handler );
		}
		#end
		
		for (cb in callbacks) tokens = cb(tokens, this);
		
	}
	
	public function toString(compress:Bool = false, sourceMap:Bool = false):String {
		return [for (token in tokens) parser.printString( token, compress )].join( compress ? '' : '\r\n' );
	}
	
}