package uhx.sys;

import uhx.mo.Token;
import byte.ByteData;
import uhx.lexer.CssLexer;
import uhx.lexer.CssParser;

typedef AjouPlugin = {
	@:optional public function onMedia(token:CssMedia, ajou:Ajou):CssMedia;
	@:optional public function onSelector(token:CssSelectors, ajou:Ajou):CssSelectors;
	@:optional public function onDeclaration(token:CssKeywords, ajou:Ajou):CssKeywords;
}

/**
 * ...
 * @author Skial Bainn
 * Haitian Creole for upgrade
 */
class Ajou {
	
	private var parser:CssParser;
	private var tokens:Array<Token<CssKeywords>>;
	
	public var media:Array<CssMedia->Ajou->CssMedia>;
	public var blocks:Array<CssKeywords->Ajou->CssKeywords>;
	public var selectors:Array<CssSelectors->Ajou->CssSelectors>;
	
	public function new(css:String) {
		media = [];
		blocks = [];
		selectors = [];
		
		parser = new CssParser();
		tokens = parser.toTokens( ByteData.ofString( css ), 'ajou' );
		
		Tappi.haxelib = true;
	}
	
	public function use(plugin:String):Void {
		Tappi.libraries.push( plugin );
	}
	
	public function rework():Void {
		Tappi.load();
		
		for (id in Tappi.classes.keys()) {
			var cls:AjouPlugin = std.Type.createInstance( Tappi.classes.get( id ), [] );
			if (cls.onMedia != null) media.push( cls.onMedia );
			if (cls.onSelector != null) selectors.push( cls.onSelector );
			if (cls.onDeclaration != null) blocks.push( cls.onDeclaration );
		}
		
		tokens = tokens.map( function(t) return switch (t.token) {
			case Keyword(x): 
				switch (x) {
					case RuleSet(_, _):
						for (cb in selectors) x = cb(x, this);
						
					case AtRule(_, _, _):
						for (cb in media) x = cb(x, this);
						
					case Declaration(_, _):
						for (cb in blocks) x = cb(x, this);
						
					case _:
				}
				x;
				
			case _:
				x;
				
		} );
	}
	
	public function toString(compress:Bool = false, sourceMap:Bool = false):String {
		return [for (token in tokens) parser.printString( token, compress )].join( compress ? '' : '\n' );
	}
	
}