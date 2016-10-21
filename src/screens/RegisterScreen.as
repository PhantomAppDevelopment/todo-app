package screens
{
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.PanelScreen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
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

	import starling.display.DisplayObject;
	import starling.events.Event;

	import utils.ProfileManager;
	import utils.Responses;
	import utils.RoundedRect;

	public class RegisterScreen extends PanelScreen
	{

		private var alert:Alert;
		private var emailInput:TextInput;
		private var passwordInput:TextInput;

		public static const GO_HOME:String = "goHomeScreen";

		override protected function initialize():void
		{
			super.initialize();

			this.layout = new AnchorLayout();
			this.title = "Register";
			this.backButtonHandler = goBack;

			var cancelIcon:ImageLoader = new ImageLoader();
			cancelIcon.source = "assets/icons/cancel.png";
			cancelIcon.width = cancelIcon.height = 25;

			var cancelBtn:Button = new Button();
			cancelBtn.defaultIcon = cancelIcon;
			cancelBtn.styleNameList.add("header-button");
			cancelBtn.addEventListener(starling.events.Event.TRIGGERED, goBack);
			this.headerProperties.rightItems = new <DisplayObject>[cancelBtn];

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

			var registerBtn:Button = new Button();
			registerBtn.addEventListener(starling.events.Event.TRIGGERED, register);
			registerBtn.layoutData = new VerticalLayoutData(100, NaN);
			registerBtn.styleNameList.add("white-button");
			registerBtn.label = "Sign Up";
			mainGroup.addChild(registerBtn);
		}

		private function register():void
		{
			if (emailInput.text == "" || passwordInput.text == "") {
				alert = Alert.show("Email and Password are required fields.", "Error", new ListCollection([{label: "OK"}]));
			} else {
				var myObject:Object = new Object();
				myObject.email = emailInput.text;
				myObject.password = passwordInput.text;

				var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

				var request:URLRequest = new URLRequest(Firebase.EMAIL_PASSWORD_SIGNUP);
				request.method = URLRequestMethod.POST;
				request.data = JSON.stringify(myObject);
				request.requestHeaders.push(header);

				var registerLoader:URLLoader = new URLLoader();
				registerLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				registerLoader.addEventListener(flash.events.Event.COMPLETE, registerComplete);
				registerLoader.load(request);
			}
		}

		private function registerComplete(event:flash.events.Event):void
		{
			//The user has been registered to our Firebase project, now we are going to log in to get an access_token.
			var rawData:Object = JSON.parse(event.currentTarget.data);
			var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

			var myObject:Object = new Object();
			myObject.grant_type = "refresh_token";
			myObject.refresh_token = rawData.refreshToken;

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
			Firebase.FIREBASE_AUTH_TOKEN = rawData.id_token;
			ProfileManager.saveProfile(rawData);

			this.dispatchEventWith(GO_HOME);
		}

		private function errorHandler(event:IOErrorEvent):void
		{
			var rawData:Object = JSON.parse(String(event.currentTarget.data));
			alert = Alert.show(Responses[rawData.error.message], "Error", new ListCollection([{label: "OK"}]));
		}

		private function goBack():void
		{
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}

	}
}