package screens
{

	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.PanelScreen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.text.TextFormat;

	import starling.events.Event;

	import utils.ProfileManager;
	import utils.Responses;
	import utils.RoundedRect;

	public class LoginScreen extends PanelScreen
	{
		public static const GO_HOME:String = "goHomeScreen";
		public static const GO_REGISTER:String = "goRegister";

		private var alert:Alert;
		private var emailInput:TextInput;
		private var passwordInput:TextInput;

		override protected function initialize():void
		{
			super.initialize();

			this.layout = new AnchorLayout();
			this.title = "Welcome";

			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.horizontalAlign = HorizontalAlign.CENTER;
			myLayout.gap = 12;

			var mainGroup:ScrollContainer = new ScrollContainer();
			mainGroup.layoutData = new AnchorLayoutData(10, 10, 10, 10, NaN, NaN);
			mainGroup.layout = myLayout;
			mainGroup.padding = 12;
			mainGroup.backgroundSkin = RoundedRect.createRoundedRect(0x00695C);
			this.addChild(mainGroup);

			var icon:ImageLoader = new ImageLoader();
			icon.source = "assets/icons/account.png";
			icon.width = icon.height = 110;
			mainGroup.addChild(icon);

			var label1:Label = new Label();
			label1.layoutData = new VerticalLayoutData(100, NaN);
			label1.text = "Email";
			mainGroup.addChild(label1);

			emailInput = new TextInput();
			emailInput.layoutData = new VerticalLayoutData(100, NaN);
			emailInput.prompt = "Type your Email Address";
			mainGroup.addChild(emailInput);

			var label2:Label = new Label();
			label2.layoutData = new VerticalLayoutData(100, NaN);
			label2.text = "Password";
			mainGroup.addChild(label2);

			passwordInput = new TextInput();
			passwordInput.layoutData = new VerticalLayoutData(100, NaN);
			passwordInput.prompt = "Type your Password";
			passwordInput.displayAsPassword = true;
			mainGroup.addChild(passwordInput);

			var loginBtn:Button = new Button();
			loginBtn.addEventListener(starling.events.Event.TRIGGERED, login);
			loginBtn.layoutData = new VerticalLayoutData(100, NaN);
			loginBtn.styleNameList.add("white-button");
			loginBtn.label = "Sign In";
			mainGroup.addChild(loginBtn);

			var registerBtn:Button = new Button();
			registerBtn.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				dispatchEventWith(GO_REGISTER);
			});
			registerBtn.label = "New User? <u>Register here</u>";
			registerBtn.height = 40;
			registerBtn.styleProvider = null;
			registerBtn.labelFactory = function ():ITextRenderer
			{
				var renderer:TextFieldTextRenderer = new TextFieldTextRenderer();
				renderer.isHTML = true;
				renderer.textFormat = new TextFormat("_sans", 16, 0xFFFFFF);
				return renderer;
			};
			mainGroup.addChild(registerBtn);
		}

		private function login():void
		{
			if (emailInput.text == "" || passwordInput.text == "") {
				alert = Alert.show("Email and Password are required fields.", "Error", new ListCollection([{label: "OK"}]));
			} else {
				var myObject:Object = new Object();
				myObject.email = emailInput.text;
				myObject.password = passwordInput.text;
				myObject.returnSecureToken = true; //We ask for a refreshToken in our response

				var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

				var request:URLRequest = new URLRequest(Firebase.EMAIL_PASSWORD_LOGIN);
				request.method = URLRequestMethod.POST;
				request.data = JSON.stringify(myObject);
				request.requestHeaders.push(header);

				var loginLoader:URLLoader = new URLLoader();
				loginLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loginLoader.addEventListener(flash.events.Event.COMPLETE, loginComplete);
				loginLoader.load(request);
			}
		}

		private function loginComplete(event:flash.events.Event):void
		{
			//The user has successfully logged in to our Firebase project, now we are going to get an access_token.
			var rawData:Object = JSON.parse(event.currentTarget.data);
			var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

			var myObject:Object = new Object();
			myObject.grant_type = "refresh_token";
			myObject.refresh_token = rawData.refreshToken; //Here we use the refreshToken previously mentioned

			var request:URLRequest = new URLRequest(Firebase.FIREBASE_AUTH_TOKEN_URL);
			request.method = URLRequestMethod.POST;
			request.data = JSON.stringify(myObject);
			request.requestHeaders.push(header);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, authComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);
		}

		private function authComplete(event:flash.events.Event):void
		{
			var rawData:Object = JSON.parse(event.currentTarget.data);

			Firebase.LOGGED_USER_DATA = rawData;
			Firebase.FIREBASE_AUTH_TOKEN = rawData.access_token;
			ProfileManager.saveProfile(rawData);

			this.dispatchEventWith(GO_HOME);
		}

		private function resetPassword():void
		{
			var myObject:Object = new Object();
			myObject.email = emailInput.text;
			myObject.requestType = "PASSWORD_RESET";

			var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

			var request:URLRequest = new URLRequest(Firebase.RESET_PASSWORD);
			request.method = URLRequestMethod.POST;
			request.data = JSON.stringify(myObject);
			request.requestHeaders.push(header);

			var resetLoader:URLLoader = new URLLoader();
			resetLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			resetLoader.addEventListener(flash.events.Event.COMPLETE, function ():void
			{
				//Recover password email has been sent
				alert = Alert.show("A recovery message has been sent to your email address.", "Password Reset", new ListCollection([{label: "OK"}]));
			});
			resetLoader.load(request);
		}

		private function errorHandler(event:IOErrorEvent):void
		{
			var rawData:Object = JSON.parse(event.currentTarget.data);
			trace(event.currentTarget.data);
			if (rawData.error.message == "INVALID_PASSWORD") {
				//If the user has an account we offer him to recover his password
				alert = Alert.show(rawData.error.message, "Error", new ListCollection(
						[
							{label: "Reset Pass", triggered: resetPassword},
							{label: "OK"}
						]));
			} else {
				alert = Alert.show(Responses[rawData.error.message], "Error", new ListCollection([{label: "OK"}]));
			}
		}


	}
}