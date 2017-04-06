package screens
{
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.Panel;
	import feathers.controls.PanelScreen;
	import feathers.controls.TextInput;
	import feathers.core.PopUpManager;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;

	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;

	import utils.NavigatorData;
	import utils.ProfileManager;
	import utils.Responses;
	import utils.SliderItemRenderer;

	public class HomeScreen extends PanelScreen
	{

		public static const GO_ADDTASK:String = "goAddTask";
		public static const GO_DETAILS:String = "goDetails";

		private var alert:Alert;
		private var tasksList:List;

		protected var _data:NavigatorData;

		public function get data():NavigatorData
		{
			return this._data;
		}

		public function set data(value:NavigatorData):void
		{
			this._data = value;
		}

		override protected function initialize():void
		{
			super.initialize();

			this.title = "To Do's";
			this..layout = new AnchorLayout();

			var personIcon:ImageLoader = new ImageLoader();
			personIcon.source = "assets/icons/person.png";
			personIcon.width = personIcon.height = 25;

			var personButton:Button = new Button();
			personButton.defaultIcon = personIcon;
			personButton.styleNameList.add("header-button");
			personButton.addEventListener(starling.events.Event.TRIGGERED, showCallout);
			this.headerProperties.leftItems = new <DisplayObject>[personButton];

			var addIcon:ImageLoader = new ImageLoader();
			addIcon.source = "assets/icons/add.png";
			addIcon.width = addIcon.height = 25;

			var addButton:Button = new Button();
			addButton.defaultIcon = addIcon;
			addButton.styleNameList.add("header-button");
			addButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				dispatchEventWith(GO_ADDTASK);
			});
			this.headerProperties.rightItems = new <DisplayObject>[addButton];

			var layoutForList:VerticalLayout = new VerticalLayout();
			layoutForList.hasVariableItemDimensions = true;

			tasksList = new List();
			tasksList.hasElasticEdges = false;
			tasksList.layout = layoutForList;
			tasksList.typicalItem = {title: "Task Title"};
			tasksList.itemRendererType = SliderItemRenderer;
			tasksList.addEventListener("delete-task", deleteTask);
			tasksList.addEventListener("select-task", function ():void
			{
				_data.selectedTask = tasksList.selectedItem;
				dispatchEventWith(GO_DETAILS);
			});

			tasksList.layoutData = new AnchorLayoutData(0, 0, 0, 0, NaN, NaN);
			this.addChild(tasksList);

			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}

		private function transitionComplete(event:starling.events.Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);

			loadTasks();
		}

		private function loadTasks():void
		{
			var request:URLRequest = new URLRequest(Firebase.FIREBASE_SELECT_URL + Firebase.LOGGED_USER_DATA.user_id +
					'.json?auth=' + Firebase.FIREBASE_AUTH_TOKEN);
			var tasksLoader:URLLoader = new URLLoader();
			tasksLoader.addEventListener(flash.events.Event.COMPLETE, tasksLoaded);
			tasksLoader.load(request);
		}

		private function tasksLoaded(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, tasksLoaded);

			var rawData:Object = JSON.parse(String(event.currentTarget.data));
			var tasksArray:Array = new Array();

			for (var key:String in rawData) {
				tasksArray.push({
					id: key,
					title: rawData[key].title,
					description: rawData[key].description,
					due_date: rawData[key].due_date,
					start_date: rawData[key].start_date
				});
			}

			tasksList.dataProvider = new ListCollection(tasksArray);
		}

		private function deleteTask():void
		{
			var header:URLRequestHeader = new URLRequestHeader("X-HTTP-Method-Override", "DELETE");
			var request:URLRequest = new URLRequest(Firebase.FIREBASE_DELETE_URL + Firebase.LOGGED_USER_DATA.user_id +
					"/" + tasksList.selectedItem.id + ".json?auth=" + Firebase.FIREBASE_AUTH_TOKEN);
			request.method = URLRequestMethod.POST;
			request.requestHeaders.push(header);

			var deleteTaskLoader:URLLoader = new URLLoader();
			deleteTaskLoader.addEventListener(flash.events.Event.COMPLETE, function ():void
			{
				//Task Successfully deleted.
			});
			deleteTaskLoader.load(request);
		}

		private function showCallout(event:starling.events.Event):void
		{
			var button:Button = Button(event.currentTarget);
			var content:LayoutGroup = new LayoutGroup();
			content.layout = new VerticalLayout();

			var updateEmailButton:Button = new Button();
			updateEmailButton.styleNameList.add("callout-button");
			updateEmailButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				alert = Alert.show("Do you want to update your Email Address?", "Update Email", new ListCollection(
						[
							{label: "Cancel"},
							{label: "OK", triggered: updateEmail}
						]));
			});
			updateEmailButton.label = "Update Email";
			content.addChild(updateEmailButton);

			var updatePasswordButton:Button = new Button();
			updatePasswordButton.styleNameList.add("callout-button");
			updatePasswordButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				alert = Alert.show("Do you want to update your Password?", "Update Password", new ListCollection(
						[
							{label: "Cancel"},
							{label: "OK", triggered: updatePassword}
						]));
			});
			updatePasswordButton.label = "Update Password";
			content.addChild(updatePasswordButton);

			var deleteAccountButton:Button = new Button();
			deleteAccountButton.styleNameList.add("callout-button");
			deleteAccountButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				alert = Alert.show("Do you want to permanently delete your account?", "Delete Account", new ListCollection(
						[
							{label: "Cancel"},
							{label: "OK", triggered: deleteAccount}
						]));
			});
			deleteAccountButton.label = "Delete Account";
			content.addChild(deleteAccountButton);

			var signOutButton:Button = new Button();
			signOutButton.styleNameList.add("callout-button");
			signOutButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				alert = Alert.show("Do you want to sign out of your account?", "Sign Out", new ListCollection(
						[
							{label: "Cancel"},
							{label: "OK", triggered: signOut}
						]));
			});
			signOutButton.label = "Sign Out";
			content.addChild(signOutButton);

			var callout:Callout = Callout.show(content, button);
		}

		private function updateEmail():void
		{
			var layoutForEmailPopUp:VerticalLayout = new VerticalLayout();
			layoutForEmailPopUp.gap = 10;

			var emailPopUp:Panel = new Panel();
			emailPopUp.padding = 10;
			emailPopUp.backgroundSkin = new Quad(3, 3, 0xE0F2F1);
			emailPopUp.layout = layoutForEmailPopUp;
			emailPopUp.width = emailPopUp.maxWidth = 250;
			emailPopUp.title = "Updating Email Address";

			var emailInput:TextInput = new TextInput();
			emailInput.layoutData = new VerticalLayoutData(100, NaN);
			emailInput.prompt = "Type your new Email Address.";
			emailPopUp.addChild(emailInput);

			var updateButton:Button = new Button();
			updateButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				if (emailInput.text == "") {
					alert = Alert.show("New Email Address is required.", "Error", new ListCollection([{label: "OK"}]));
				} else {
					var myObject:Object = new Object();
					myObject.email = emailInput.text;
					myObject.idToken = Firebase.FIREBASE_AUTH_TOKEN;

					var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

					var request:URLRequest = new URLRequest(Firebase.UPDATE_EMAIL);
					request.method = URLRequestMethod.POST;
					request.data = JSON.stringify(myObject);
					request.requestHeaders.push(header);

					var updateEmailLoader:URLLoader = new URLLoader();
					updateEmailLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
					updateEmailLoader.addEventListener(flash.events.Event.COMPLETE, function ():void
					{
						PopUpManager.removePopUp(emailPopUp, true);
						alert = Alert.show("Email Address successfully updated.", "Success", new ListCollection([{label: "OK"}]));
					});
					updateEmailLoader.load(request);
				}

			});
			updateButton.layoutData = new VerticalLayoutData(100, NaN);
			updateButton.label = "Update Email Address";
			updateButton.styleNameList.add("alert-button");
			emailPopUp.addChild(updateButton);

			PopUpManager.addPopUp(emailPopUp, true, true, function ():DisplayObject
			{
				var quad:Quad = new Quad(3, 3, 0x000000);
				quad.alpha = 0.50;
				return quad;
			});
		}

		private function updatePassword():void
		{
			var layoutForPasswordPopUp:VerticalLayout = new VerticalLayout();
			layoutForPasswordPopUp.gap = 10;

			var passwordPopUp:Panel = new Panel();
			passwordPopUp.padding = 10;
			passwordPopUp.backgroundSkin = new Quad(3, 3, 0xE0F2F1);
			passwordPopUp.layout = layoutForPasswordPopUp;
			passwordPopUp.width = passwordPopUp.maxWidth = 250;
			passwordPopUp.title = "Updating Password";

			var passwordInput:TextInput = new TextInput();
			passwordInput.layoutData = new VerticalLayoutData(100, NaN);
			passwordInput.displayAsPassword = true;
			passwordInput.prompt = "Type your new Password.";
			passwordPopUp.addChild(passwordInput);

			var updateButton:Button = new Button();
			updateButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				if (passwordInput.text == "") {
					alert = Alert.show("New Password is required.", "Error", new ListCollection([{label: "OK"}]));
				} else {
					var myObject:Object = new Object();
					myObject.password = passwordInput.text;
					myObject.idToken = Firebase.FIREBASE_AUTH_TOKEN;

					var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

					var request:URLRequest = new URLRequest(Firebase.UPDATE_PASSWORD);
					request.method = URLRequestMethod.POST;
					request.data = JSON.stringify(myObject);
					request.requestHeaders.push(header);

					var updatePasswordLoader:URLLoader = new URLLoader();
					updatePasswordLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
					updatePasswordLoader.addEventListener(flash.events.Event.COMPLETE, function ():void
					{
						//We update the conf file with the new email address.
						Firebase.LOGGED_USER_DATA.password = passwordInput.text;

						var file:File = File.applicationStorageDirectory.resolvePath("prefs.conf");

						var fileStream:FileStream = new FileStream();
						fileStream.open(file, FileMode.WRITE);
						fileStream.writeObject(Firebase.LOGGED_USER_DATA);
						fileStream.close();

						PopUpManager.removePopUp(passwordPopUp, true);
						alert = Alert.show("Password successfully updated.", "Success", new ListCollection(
								[
									{label: "OK"}
								]));
					});
					updatePasswordLoader.load(request);
				}

			});
			updateButton.layoutData = new VerticalLayoutData(100, NaN);
			updateButton.label = "Update Password";
			updateButton.styleNameList.add("alert-button");
			passwordPopUp.addChild(updateButton);

			PopUpManager.addPopUp(passwordPopUp, true, true, function ():DisplayObject
			{
				var quad:Quad = new Quad(3, 3, 0x000000);
				quad.alpha = 0.50;
				return quad;
			});
		}

		private function deleteAccount():void
		{
			var myObject:Object = new Object();
			myObject.idToken = Firebase.FIREBASE_AUTH_TOKEN;

			var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");

			var request:URLRequest = new URLRequest(Firebase.DELETE_ACCOUNT);
			request.method = URLRequestMethod.POST;
			request.data = JSON.stringify(myObject);
			request.requestHeaders.push(header);

			var deleteAccountLoader:URLLoader = new URLLoader();
			deleteAccountLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			deleteAccountLoader.addEventListener(flash.events.Event.COMPLETE, function ():void
			{
				var rawData:Object = JSON.parse(String(deleteAccountLoader.data));

				if (rawData.kind == "identitytoolkit#DeleteAccountResponse") {
					//Account was successfully delete in the server
					signOut();
				}
			});
			deleteAccountLoader.load(request);
		}

		private function signOut():void
		{
			ProfileManager.signOut();
			this.owner.replaceScreen("loginScreen");
		}

		private function errorHandler(event:IOErrorEvent):void
		{
			var rawData:Object = JSON.parse(String(event.currentTarget.data));
			alert = Alert.show(Responses[rawData.error.message], "Error", new ListCollection([{label: "OK"}]));
		}

	}
}