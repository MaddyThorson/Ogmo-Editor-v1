package
{
	import editor.*;
	import editor.ui.*;
	import flash.display.NativeWindowDisplayState;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.InvokeEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.system.Capabilities;
	import flash.system.System;

	public class Ogmo extends Sprite
	{
		//Assets
		[Embed(source = '../assets/folder.png')]
		static public const ImgFolder:Class;
		[Embed(source = '../assets/arrow.png')]
		static public const ImgArrow:Class;
		
		//Consts
		static private const PROJECT_EXT:String			= "oep";
		static private const LEVEL_EXT:String			= "oel";
		static private const NEW_LEVEL_NAME:String 		= "NewLevel." + LEVEL_EXT;
		static private const PROJECT_FILTER:Array 		= [ new FileFilter("Ogmo Editor Project Files", "*." + PROJECT_EXT) ]
		static private const LEVEL_FILTER:Array			= [ new FileFilter("Ogmo Editor Level Files", "*." + LEVEL_EXT) ]
		static private const PROJECT_HISTORY_LIMIT:uint	= 3;
		static public const STAGE_DEFAULT_WIDTH:int		= 800;
		static public const STAGE_DEFAULT_HEIGHT:int	= 600;
		
		/**
		 * The singleton instance of the master sprite. Contains the level and project and all the UI
		 */
		static public var ogmo:Ogmo;
		
		/**
		 * The currently loaded level
		 */
		static public var level:Level;
		
		/**
		 * The currently loaded project
		 */
		static public var project:Project;
		
		/**
		 * The container of all the UI windows
		 */
		static public var windows:Windows;
		
		/**
		 * The container of the top window menu (File, Edit, etc)
		 */
		static public var windowMenu:WindowMenu;
		
		/**
		 * Whether editor UI objects should ignore keystrokes (ex: if a textfield is capturing input)
		 */
		static public var missKeys:Boolean;
		
		/**
		 * Whether the editing grid is currently visible
		 */
		static public var gridOn:Boolean;
		
		/**
		 * The keycode of the CTRL key (the apple key on macs)
		 */
		static public var keycode_ctrl:int;
		
		/**
		 * Whether the user is on a mac
		 */
		static public var mac:Boolean;
		
		/**
		 * A temporary file object for use when loading project or level files
		 */
		static public var tempFile:File;
		
		/**
		 * Currently displayed message (in a message box in the middle of the window)
		 */
		static public var message:Message;
		
		/**
		 * Ogmo Editor version number
		 */
		static public var version:String;
		
		/**
		 * Previously-opened projects (so the user can quickly re-open them)
		 */
		static public var projectHistory:Array;
		
		/**
		 * A temporary rectangle for use anywhere, to avoid instantiating new rectangles
		 */
		static public var rect:Rectangle = new Rectangle;
		
		/**
		 * Another temp rectangle for generic use
		 */
		static public var rect2:Rectangle = new Rectangle;
		
		/**
		 * A temporary point for use anywhere, to avoid instantiating new points
		 */
		static public var point:Point = new Point;
		
		public function Ogmo()
		{
			ogmo = this;
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			//Get the version number
			var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = descriptor.namespaceDeclarations()[0];
			version = descriptor.ns::version;
			
			//Init keystates
			missKeys	= false;
		
			//If running on a Mac, use Apple key instead of CTRL as modifier key
			if (Capabilities.os.indexOf("Mac") != -1)
			{
				mac 			= true;
				keycode_ctrl 	= 15;
			}
			else
			{
				mac 			= false;
				keycode_ctrl 	= 17;
			}
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//Init some window properties
			stage.frameRate				= 60;
			stage.scaleMode 			= StageScaleMode.NO_SCALE;
			stage.nativeWindow.width	= 816;
			stage.nativeWindow.height	= 658;
			stage.nativeWindow.minSize 	= new Point(816, 658);
			
			//Init the menu
			windowMenu = new WindowMenu(stage);
			
			//Load settings
			loadSettings();
			
			//Init grid stuff
			gridOn = true;
			
			//Add the splash
			var bg:BG = new BG;
			addChild(bg);
			
			//init listeners
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.nativeWindow.addEventListener(Event.CLOSING, onExit);
			
			//Init window title
			setWindowTitle();
			
			//add the main menu
			initMainMenu();
			
			//If a file was opened
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvokeEvent);
		}
		
		private function onInvokeEvent(e:InvokeEvent):void
		{
			//Open the selected file (if applicable)
			if (e.currentDirectory != null && e.arguments.length > 0)
			{
				var file:File = e.currentDirectory.resolvePath(e.arguments[ 0 ]);
				
				if (file.extension == PROJECT_EXT)
				{		
					//First close the current project if one is open
					if (level)
						closeProject();
		
					//Open the specified project
					loadProject(file);
					
					stage.nativeWindow.notifyUser("Project Opened");
				}
				else if (file.extension == LEVEL_EXT)
				{
					if (level)
					{
						//First close the current level
						closeLevel();
						
						//Open the specified level
						loadLevel(file);
						
						stage.nativeWindow.notifyUser("Level Opened");
					}
					else
						showMessage("Cannot open a level when\nno project is open!", 5000);
				}
				else
				{
					//Not sure what it is?
					showMessage("Unrecognized filetype:\n\"" + file.extension + "\"", 5000);
				}
			}
		}
		
		static public function quit():void
		{
			ogmo.onExit();
			NativeApplication.nativeApplication.exit();
		}
		
		public function initMainMenu():void
		{
			addChild(new MainMenu);
			addChild(new InfoWindow);
			addChild(new VersionWindow);
		}
		
		public function destroyMainMenu():void
		{
			for (var i:int = 0; i < numChildren; i++)
			{
				if (getChildAt(i) is MainMenu || getChildAt(i) is InfoWindow || getChildAt(i) is VersionWindow)
				{
					removeChildAt(i);
					i--;
				}
			}
		}
		
		private function initWindows():void
		{
			addChild(windows = new Windows);
		}
		
		static public function setWindowTitle():void
		{
			if (project)
				ogmo.stage.nativeWindow.title = project.name + " - " + level.levelName;
			else
				ogmo.stage.nativeWindow.title = "Ogmo Editor " + version;
		}
		
		static public function toggleDebugWindow():void
		{
			var d:DebugWindow = getDebugWindow();
			if (d == null)
				ogmo.addChild(new DebugWindow);
			else
				ogmo.removeChild(d);
			windowMenu.refreshState();
		}
		
		static public function getDebugWindow():DebugWindow
		{
			for (var i:int = 0; i < ogmo.numChildren; i++)
			{
				if (ogmo.getChildAt(i) is DebugWindow)
					return ogmo.getChildAt(i) as DebugWindow;
			}
			return null;
		}
		
		static public function openProjectDirectory():void
		{
			try
			{
				project.workingDirectory.openWithDefaultApplication();
			}
			catch (e:Error)
			{
				trace(project.workingDirectory.url);
				navigateToURL(new URLRequest(project.workingDirectory.url));
			}
		}
		
		static public function openWebsite():void
		{
			navigateToURL(new URLRequest("http://ogmoeditor.com/"));
		}
		
		/* =================== MESSAGE SYSTEM =================== */
		
		static public function showMessage(text:String, time:int = 2000, large:Boolean = false):void
		{
			clearMessage();
				
			message = new Message(text, time, large);
			ogmo.addChild(message);
		}
		
		static public function clearMessage():void
		{
			if (message)
			{
				ogmo.removeChild(message);
				message = null;
			}
		}
		
		/* =================== PROJECT STUFF =================== */
		
		public function closeProject():void
		{
			project = null;
			closeLevel();
			
			ogmo.removeChild(windows);
			windows 	= null;
			
			System.gc();
			
			//reset the window title
			setWindowTitle();
			
			//refresh the window menu
			windowMenu.refreshState();
			
			//re-add the main menu
			ogmo.initMainMenu();
		}
		
		public function reloadProject():void
		{
			tempFile = project.file;		
			closeProject();
			onLoadProjectSelect();
		}
		
		public function lookForProject():void
		{
			tempFile = new File;
			tempFile.addEventListener(Event.SELECT, onLoadProjectSelect, false, 0, true);
			tempFile.browseForOpen("Open Project File", PROJECT_FILTER);
		}
		
		public function loadProject(file:File):void
		{
			tempFile = file;
			onLoadProjectSelect();
		}
		
		private function onLoadProjectSelect(e:Event = null):void
		{
			//Clear error message if there is one
			clearMessage();
			
			//Create the project
			project = new Project();
			
			//Populate it
			if (Capabilities.isDebugger)
			{
				//Don't catch errors if debug build (so you get a stack trace)
				project.constructProject(tempFile);
			}
			else
			{
				//Catch errors if release build
				try
				{
					project.constructProject(tempFile);
				}
				catch (e:Error)
				{
					trace(e.getStackTrace);
					showMessage("Error loading project file:\n" + e.message, -1, true);
					return;
				}
			}
			
			//remove the main menu
			destroyMainMenu();
			
			//Init Windows
			initWindows();
			
			//Add a new level
			newLevel(false);
			
			//Add to history
			addToProjectHistory(project.file, project.name);
			
			//Show the message
			showMessage(project.name + "\nloaded!");
			
			//refresh the window menu
			windowMenu.refreshState();
			
			//Clean up
			System.gc();
		}
		
		/* =================== SAVING / LOADING LEVELS =================== */
		
		public function closeLevel():void
		{
			if (level)
				ogmo.removeChild(level);
			level = null;
		}
		
		public function newLevel(message:Boolean = true):void
		{
			closeLevel();
			
			ogmo.addChildAt(level = new Level(NEW_LEVEL_NAME), 1); 
			if (message)
				showMessage("New Level");
			System.gc();
			
			//set the window title
			setWindowTitle();
			
			//Init the level info window
			windows.windowLevelInfo.populate();
		}
		
		public function saveLevel():void
		{
			tempFile = new File(Ogmo.project.savingDirectory);
			tempFile.addEventListener(Event.SELECT, onSaveLevelSelect, false, 0, true);
			tempFile.save(level.xml, level.levelName);
		}
		
		private function onSaveLevelSelect(e:Event):void
		{ 	
			level.levelName = tempFile.name;
			level.saved 	= true;
			showMessage("Saved Level As:\n" + tempFile.name);
			tempFile = null;
			
			//set the window title
			setWindowTitle();
		}
		
		public function lookForLevel():void
		{
			tempFile = new File;
			tempFile.addEventListener(Event.SELECT, onLoadLevelSelect, false, 0, true);
			tempFile.addEventListener(Event.CANCEL, onLoadLevelCancel, false, 0, true );
			tempFile.browseForOpen("Open Level File", LEVEL_FILTER);
		}
		
		public function loadLevel(file:File):void
		{
			tempFile = file;
			onLoadLevelSelect();
		}
		
		private function onLoadLevelCancel(e:Event = null):void
		{
			tempFile = null;
		}
		
		private function onLoadLevelSelect(e:Event = null):void
		{	
			//Open the stream
			var stream:FileStream = new FileStream;
			stream.open(tempFile, FileMode.READ);
			
			//Read the level
			var lvl:XML = new XML(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
			
			//Error and abort if not a valid level file
			if (lvl.name().localName != "level")
			{
				showMessage("Could not load level file:\nRoot element is not a <level> tag.", -1, true);
				onLoadLevelCancel();
				return;
			}
			
			//store the old level; close it
			var tempLevel:Level = level;
			closeLevel();
			
			//Make the new level and add it
			level = new Level(tempFile.name);
			ogmo.addChildAt(level, 1);
			
			//Populate it
			if (Capabilities.isDebugger)
			{
				//Don't catch errors if debug build
				level.xml = lvl;
			}
			else
			{
				//Catch errors if release build
				try 
				{
					level.xml = lvl;
				}
				catch (e:Error)
				{
					showMessage("Could not load level file:\n" + e.message, -1, true);
					onLoadLevelCancel();
					
					//Go back to the old level
					closeLevel();
					level = tempLevel;
					ogmo.addChildAt(level, 1);
					level.initListeners();
					level.setLayer(level.currentLayerNum);
					return;
				}
			}
			
			//Show the message
			showMessage("Opened Level:\n" + tempFile.name);
			
			//set the window title
			setWindowTitle();
			
			//Init level info window
			windows.windowLevelInfo.populate();
			
			//Clean up
			tempFile = null;
			System.gc();
		}
		
		/* =================== SETTINGS =================== */
		
		private function saveSettings():void
		{
			//Window bounds
			if (stage.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
				Settings.settings.window[0].maximized[0]	= true;
			else if (stage.nativeWindow.displayState == NativeWindowDisplayState.NORMAL)
			{
				Settings.settings.window[0].x[0]			= stage.nativeWindow.x;
				Settings.settings.window[0].y[0] 			= stage.nativeWindow.y;
				Settings.settings.window[0].width[0]		= stage.nativeWindow.width;
				Settings.settings.window[0].height[0]		= stage.nativeWindow.height;
				Settings.settings.window[0].maximized[0]	= false;
			}
				
			//Project history
			Settings.settings.projectHistory[0] = <projectHistory />;
			for each (var ob:Object in projectHistory)
			{
				var o:XML = <project />;
				o.@file = ob.file;
				o.@name = ob.name;
				Settings.settings.projectHistory[0].appendChild(o);
			}
				
			Settings.saveSettings();
		}
		
		private function loadSettings():void
		{
			Settings.loadSettings();
			
			//Window bounds
			stage.nativeWindow.x 		= Settings.settings.window[0].x[0];
			stage.nativeWindow.y 		= Settings.settings.window[0].y[0];
			if (Settings.settings.window[0].width[0] == "-1")
				stage.nativeWindow.width = STAGE_DEFAULT_WIDTH;
			else
				stage.nativeWindow.width 	= Settings.settings.window[0].width[0];	
			if (Settings.settings.window[0].height[0] == "-1")
				stage.nativeWindow.width = STAGE_DEFAULT_HEIGHT;
			else
				stage.nativeWindow.height 	= Settings.settings.window[0].height[0];
			if (Settings.settings.window[0].maximized[0] == "true")
				stage.nativeWindow.maximize();
				
			//Project history
			projectHistory = new Array;
			if (Settings.settings.projectHistory[0].project.length())
			{
				for each (var o:XML in Settings.settings.projectHistory[0].project)
				{
					var f:File = new File(o.@file);
					if (!f.exists)
						continue;
					
					var ob:Object = new Object;
					ob.file = o.@file;
					ob.name = o.@name;
					projectHistory.push(ob);
				}
			}
		}
		
		static public function addToProjectHistory(file:File, name:String):void
		{
			var i:int;
			
			for (i = 0; i < projectHistory.length; i++)
			{
				if (projectHistory[ i ].file == file.url)
				{
					projectHistory.splice(i, 1);
					break;
				}
			}
			
			var a:Array = new Array;
			a[ 0 ] = new Object;
			a[ 0 ].file = file.url;
			a[ 0 ].name = name;
			for (i = 0; i < projectHistory.length && i < PROJECT_HISTORY_LIMIT - 1; i++)
				a[ i + 1 ] = projectHistory[ i ];
			projectHistory = a;
		}
		
		/* =================== EVENTS =================== */
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				//ESC
				case (27):
					if (level)
						closeProject();
					else
						quit();
					break;
			}
		}
		
		public function onExit(e:Event = null):void
		{
			saveSettings();
		}
		
	}

}