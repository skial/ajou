package ;

import neko.Lib;
import uhx.sys.Ajou;

/**
 * ...
 * @author Skial Bainn
 */

@:cmd
@:usage( 'haxelib run ajou [options]' )
class Librunner implements Klas {
	
	static function main() {
		new Librunner( Sys.args() );
	}
	
	public function new(args:Array<String>) {
		new Ajou('');
	}
	
}