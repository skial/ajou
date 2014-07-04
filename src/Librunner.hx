package ;

import neko.Lib;
import sys.io.File;
import uhx.sys.Ajou;

using Sys;
using sys.io.File;
using haxe.io.Path;
using sys.FileSystem;

/**
 * ...
 * @author Skial Bainn
 */

@:cmd
@:usage( 'haxelib run ajou [options]' )
class Librunner implements Klas {
	
	static function main() {
		var ajou = new Librunner( Sys.args() );
	}
	
	/**
	 * Allows you to run `ajou [options]` from now on.
	 */
	@alias('g') 
	public var global:Bool;
	
	/**
	 * Compress the output.
	 */
	@alias('c') 
	public var compress:Bool;
	
	/**
	 * The css file you want to process.
	 */
	@alias('i')
	public var input:String;
	
	/**
	 * The location you want the processed file to be saved to.
	 */
	@alias('o')
	public var output:String;
	
	/**
	 * A list of plugin names to use with Ajou.
	 */
	@alias('p')
	public var plugins:Array<String>;
	
	private var directory:String;
	
	public function new(args:Array<String>) {
		
		
		trace( args );
		trace( input );
		trace( output );
		trace( plugins );
		
		if (input == null || input == '') {
			'You are missing an input file.'.println();
			return;
		}
		
		if (output == null || output == '') {
			'You seem to have forgotten to specify an output location.'.println();
			return;
		}
		
		directory = args[args.length - 1].normalize();
		directory.setCwd();
		
		if (global) makeGlobal();
		
		var ajou = new Ajou( '$directory/$input'.normalize().getContent() );
		for (plugin in plugins) ajou.use( plugin );
		ajou.rework();
		File.saveContent( '$directory/$output'.normalize(), ajou.toString( compress ) );
	}
	
	private function makeGlobal() {
		if (!Sys.environment().exists( 'HAXEPATH' )) {
			'The enviroment HAXEPATH does not exist.'.println();
			return;
		}
		
		var path = Sys.environment().get( 'HAXEPATH' ).normalize();
		
		switch (Sys.systemName().toLowerCase()) {
			case _.indexOf( 'windows' ) > -1 => true if ('$path/ajou.bat'.normalize().exists()):
				'Ajou is already global.'.println();
				return;
				
			case _ if ('$path/ajou.sh'.normalize().exists()): 
				'Ajou is already global.'.println();
				return;
				
		}
		
		switch (Sys.systemName().toLowerCase()) {
			case _.indexOf( 'windows' ) > -1 => true:
				File.saveContent( '$path/ajou.bat'.normalize(), '@echo off\r\nhaxelib run ajou %*' );
				
			case _.indexOf( 'linux' ) > -1 => true:
				File.saveContent( '$path/ajou.sh'.normalize(), '# Bash\r\n#!/bin/sh\r\nhaxelib run ajou $@' );
				
			case _.indexOf( 'mac' ) > -1 => true:
				File.saveContent( '$path/ajou.sh'.normalize(), '# Bash\r\n#!/bin/sh\r\nhaxelib run ajou $@' );
				
			case _: 
				'Can not determine the OS type, apologies.'.println();
		}
	}
	
}