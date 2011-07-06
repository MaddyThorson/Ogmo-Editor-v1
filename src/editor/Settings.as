package editor 
{
	import editor.ui.Window;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class Settings
	{
		static public var settings:XML;
		
		static public function loadSettings():void
		{
			//Get the settings file
			var file:File = File.applicationStorageDirectory.resolvePath( "settings.xml" );	
			
			//If it doesn't exist, load defaults
			if (!file.exists)
				return loadDefaultSettings();
			
			//Load the file into an XML object
			var stream:FileStream 	= new FileStream;
			stream.open( file, FileMode.READ );
			settings = new XML( stream.readUTFBytes( stream.bytesAvailable ) );
			stream.close();
		}
		
		static private function loadDefaultSettings():void
		{	
			settings = <settings>
				<version />
				<window>
					<x>20</x>
					<y>20</y>
					<width>-1</width>
					<height>-1</height>
					<maximized>false</maximized>
				</window>
				<projectHistory />
			</settings>;
		}
		
		static public function saveSettings():void
		{
			var file:File 			= File.applicationStorageDirectory.resolvePath( "settings.xml" );	
			var stream:FileStream 	= new FileStream;
			
			settings.version[0] = Ogmo.version;
			
			stream.open( file, FileMode.WRITE );
			stream.writeUTFBytes( settings.toXMLString() );
			stream.close();
		}
		
	}

}