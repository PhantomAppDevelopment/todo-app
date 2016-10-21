package
{

	import feathers.controls.StackScreenNavigator;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.motion.Cover;
	import feathers.motion.Reveal;
	import feathers.motion.Slide;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;

	import screens.AddTaskScreen;
	import screens.EditTaskScreen;
	import screens.HomeScreen;
	import screens.LoginScreen;
	import screens.RegisterScreen;

	import starling.display.Sprite;
	import starling.events.Event;

	import utils.NavigatorData;
	import utils.ProfileManager;

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

			if (ProfileManager.isLoggedIn()) {

				Firebase.LOGGED_USER_DATA = ProfileManager.loadProfile();

				var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

				var myObject:Object = new Object();
				myObject.grant_type = "refresh_token";
				myObject.refresh_token = Firebase.LOGGED_USER_DATA.refresh_token;

				var request:URLRequest = new URLRequest(Firebase.FIREBASE_AUTH_TOKEN_URL);
				request.method = URLRequestMethod.POST;
				request.data = JSON.stringify(myObject);
				request.requestHeaders.push(header);

				var loader:URLLoader = new URLLoader();
				loader.addEventListener(flash.events.Event.COMPLETE, function ():void
				{
					var rawData:Object = JSON.parse(loader.data);
					Firebase.FIREBASE_AUTH_TOKEN = rawData.access_token;
					myNavigator.rootScreenID = HOME_SCREEN;
				});
				loader.addEventListener(IOErrorEvent.IO_ERROR, function ():void
				{
					trace(loader.data);
				});
				loader.load(request);

			} else {
				myNavigator.rootScreenID = LOGIN_SCREEN;
			}

		}

	}
}