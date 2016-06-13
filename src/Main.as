package
{
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import feathers.controls.StackScreenNavigator;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.motion.Cover;
	import feathers.motion.Reveal;
	import feathers.motion.Slide;
	
	import screens.AddTaskScreen;
	import screens.EditTaskScreen;
	import screens.HomeScreen;
	import screens.LoginScreen;
	import screens.RegisterScreen;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Main extends Sprite
	{
		public function Main()
		{
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private var myNavigator:StackScreenNavigator;
		
		private static const LOGIN_SCREEN:String = "loginScreen";
		private static const REGISTER_SCREEN:String = "registerScreen";
		private static const HOME_SCREEN:String = "homeScreen";
		private static const ADD_TASK_SCREEN:String = "addTaskScreen";
		private static const EDIT_TASK_SCREEN:String = "editTaskScreen";
		
		protected function addedToStageHandler(event:starling.events.Event):void
		{			
			this.removeEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStageHandler);
			
			new CustomTheme();
			
			var NAVIGATOR_DATA:NavigatorData = new NavigatorData();
			
			myNavigator = new StackScreenNavigator();
			myNavigator.pushTransition = Slide.createSlideLeftTransition();
			myNavigator.popTransition = Slide.createSlideRightTransition();
			addChild(myNavigator);
			
			var loginScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(LoginScreen);
			loginScreenItem.setScreenIDForPushEvent(LoginScreen.GO_HOME, HOME_SCREEN);
			loginScreenItem.setScreenIDForPushEvent(LoginScreen.GO_REGISTER, REGISTER_SCREEN);
			myNavigator.addScreen(LOGIN_SCREEN, loginScreenItem);
			
			var registerScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(RegisterScreen);
			registerScreenItem.pushTransition = Cover.createCoverUpTransition();
			registerScreenItem.popTransition = Reveal.createRevealDownTransition();
			registerScreenItem.addPopEvent(starling.events.Event.COMPLETE);
			registerScreenItem.setScreenIDForPushEvent(RegisterScreen.GO_HOME, HOME_SCREEN);
			myNavigator.addScreen(REGISTER_SCREEN, registerScreenItem);
			
			var homeScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(HomeScreen);
			homeScreenItem.properties.data = NAVIGATOR_DATA;
			homeScreenItem.setScreenIDForPushEvent(HomeScreen.GO_ADDTASK, ADD_TASK_SCREEN);
			homeScreenItem.setScreenIDForPushEvent(HomeScreen.GO_DETAILS, EDIT_TASK_SCREEN);
			myNavigator.addScreen(HOME_SCREEN, homeScreenItem);
			
			var addTaskScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(AddTaskScreen);
			addTaskScreenItem.addPopEvent(starling.events.Event.COMPLETE);
			myNavigator.addScreen(ADD_TASK_SCREEN, addTaskScreenItem);
			
			var editTaskScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(EditTaskScreen);
			editTaskScreenItem.properties.data = NAVIGATOR_DATA;
			editTaskScreenItem.addPopEvent(starling.events.Event.COMPLETE);
			myNavigator.addScreen(EDIT_TASK_SCREEN, editTaskScreenItem);
			
			//We load the user config and determinate if it's a new user
			
			var file:File = File.applicationStorageDirectory.resolvePath("prefs.conf");
			
			if(file.exists)
			{
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				
				if(fileStream.bytesAvailable == 0){
					//Empty file, we go directly to LoginScreen
					
					fileStream.close();				
					myNavigator.rootScreenID = LOGIN_SCREEN;
				} else {
					var myObject:Object = fileStream.readObject();					
					fileStream.close();				
					
					//We check if the Object has a token (from Firebase), if not we go tot he LoginScreen
					
					if(myObject.idToken){
						Firebase.LOGGED_USER_DATA = myObject;
						
						//We refresh the auth token
						
						var urlVars:Object = new Object();
						urlVars.email = Firebase.LOGGED_USER_DATA.email;
						urlVars.password = Firebase.LOGGED_USER_DATA.password;
						urlVars.returnSecureToken = true;
						
						var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");
						
						var request:URLRequest = new URLRequest(Firebase.EMAIL_PASSWORD_LOGIN);
						request.method = URLRequestMethod.POST;
						request.data = JSON.stringify(urlVars);
						request.requestHeaders.push(header);
						
						var authLoader:URLLoader = new URLLoader();	
						authLoader.addEventListener(IOErrorEvent.IO_ERROR, function():void
						{
							//Something wrong happened to the user account, we default to the login screen
							myNavigator.rootScreenID = LOGIN_SCREEN;
						});
						authLoader.addEventListener(flash.events.Event.COMPLETE, function():void
						{
							var rawData:Object = JSON.parse(String(authLoader.data));
							
							Firebase.LOGGED_USER_DATA.idToken = rawData.idToken;
							
							var file:File = File.applicationStorageDirectory.resolvePath("prefs.conf");
							
							var fileStream:FileStream = new FileStream();
							fileStream.open(file, FileMode.WRITE);
							fileStream.writeObject(Firebase.LOGGED_USER_DATA);
							fileStream.close();
							
							myNavigator.rootScreenID = HOME_SCREEN;					
							
						});
						authLoader.load(request);						
					} else {
						myNavigator.rootScreenID = LOGIN_SCREEN;
					}
				}								
			} else {
				//Fresh install or file was deleted
				myNavigator.rootScreenID = LOGIN_SCREEN;
			}			
		}
		
	}
}