package screens
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
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class RegisterScreen extends PanelScreen
	{

		private var alert:Alert;		
		private var emailInput:TextInput;
		private var passwordInput:TextInput;

		public static const GO_HOME:String = "goHomeScreen";
		
		override protected function initialize():void
		{
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
			if(emailInput.text == "" || passwordInput.text == ""){
				alert = Alert.show("Email and Password are required fields.", "Error", new ListCollection(
					[
						{ label: "OK"}
					]) );
			} else {			
				
				var myObject:Object = new Object();
				myObject.email = emailInput.text;
				myObject.password = passwordInput.text;
				myObject.returnSecureToken = true;
				
				var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");
				
				var request:URLRequest = new URLRequest(Firebase.EMAIL_PASSWORD_SIGNUP);
				request.method = URLRequestMethod.POST;
				request.data = JSON.stringify(myObject);
				request.requestHeaders.push(header);
				
				var registerLoader:URLLoader = new URLLoader();	
				registerLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
				registerLoader.addEventListener(flash.events.Event.COMPLETE, registerResponse);
				registerLoader.load(request);
			}		
		}
		
		private function onError(event:IOErrorEvent):void
		{
			var rawData:Object = JSON.parse(String(event.currentTarget.data));
			trace(event.currentTarget.data);
			alert = Alert.show(rawData.error.message, "Error", new ListCollection(
				[
					{ label: "OK"}
				]) );
		}
		
		private function registerResponse(event:flash.events.Event):void
		{			
			var rawData:Object = JSON.parse(String(event.currentTarget.data));
			trace(event.currentTarget.data);
						
			if(rawData.localId)
			{				
				var myObject:Object = new Object();
				myObject.email = emailInput.text;
				myObject.password = passwordInput.text;
				myObject.returnSecureToken = true;
				
				var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");
				
				var request:URLRequest = new URLRequest(Firebase.EMAIL_PASSWORD_LOGIN);
				request.method = URLRequestMethod.POST;
				request.data = JSON.stringify(myObject);
				request.requestHeaders.push(header);
				
				var authLoader:URLLoader = new URLLoader();
				authLoader.addEventListener(flash.events.Event.COMPLETE, authComplete);
				authLoader.load(request);
			}
		}
		
		private function authComplete(event:flash.events.Event):void
		{
			var rawData:Object = JSON.parse(String(event.currentTarget.data));

			var myObject:Object =new Object();
			myObject.email = emailInput.text;
			myObject.password = passwordInput.text;
			myObject.refreshToken = rawData.refreshToken;
			myObject.idToken = rawData.idToken;
			myObject.localId = rawData.localId;
			
			Firebase.LOGGED_USER_DATA = myObject;
			
			var file:File = File.applicationStorageDirectory.resolvePath("prefs.conf");
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeObject(myObject);
			fileStream.close();
			
			this.dispatchEventWith(GO_HOME);
		}
		
		private function goBack():void
		{
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}

	}
}