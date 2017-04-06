package screens
{
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.DateTimeSpinner;
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
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	import starling.display.DisplayObject;
	import starling.events.Event;

	import utils.RoundedRect;

	public class AddTaskScreen extends PanelScreen
	{
		private var alert:Alert;
		private var nameInput:TextInput;
		private var descriptionInput:TextInput;
		private var dueDate:DateTimeSpinner;

		override protected function initialize():void
		{
			super.initialize();

			this.layout = new AnchorLayout();
			this.title = "Add Task";
			this.backButtonHandler = goBack;

			var backButton:Button = new Button();
			backButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			backButton.styleNameList.add("back-button");

			this.headerProperties.leftItems = new <DisplayObject>[backButton];

			var doneIcon:ImageLoader = new ImageLoader();
			doneIcon.source = "assets/icons/check.png";
			doneIcon.width = doneIcon.height = 25;

			var doneButton:Button = new Button();
			doneButton.defaultIcon = doneIcon;
			doneButton.addEventListener(starling.events.Event.TRIGGERED, saveTask);
			doneButton.styleNameList.add("header-button");

			this.headerProperties.rightItems = new <DisplayObject>[doneButton];

			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.horizontalAlign = HorizontalAlign.CENTER;
			myLayout.gap = 12;

			var mainGroup:ScrollContainer = new ScrollContainer();
			mainGroup.layoutData = new AnchorLayoutData(10, 10, 10, 10, NaN, NaN);
			mainGroup.layout = myLayout;
			mainGroup.padding = 12;
			mainGroup.backgroundSkin = RoundedRect.createRoundedRect(0x00695C);
			this.addChild(mainGroup);

			nameInput = new TextInput();
			nameInput.layoutData = new VerticalLayoutData(100, NaN);
			nameInput.height = 50;
			nameInput.prompt = "Task Name";
			mainGroup.addChild(nameInput);

			descriptionInput = new TextInput();
			descriptionInput.layoutData = new VerticalLayoutData(100, NaN);
			descriptionInput.height = 100;
			descriptionInput.prompt = "Task Description";
			descriptionInput.textEditorProperties.multiline = true;
			mainGroup.addChild(descriptionInput);

			var label1:Label = new Label();
			label1.text = "Due Date";
			mainGroup.addChild(label1);

			dueDate = new DateTimeSpinner();
			mainGroup.addChild(dueDate);

		}

		private function saveTask():void
		{
			if (nameInput.text == "") {
				alert = Alert.show("A name is required.", "Error", new ListCollection(
						[
							{label: "OK"}
						]));
			} else {
				var myObject:Object = new Object();
				myObject.title = nameInput.text;
				myObject.description = descriptionInput.text;
				myObject.due_date = dueDate.value.getTime();
				myObject.start_date = new Date().getTime();

				var request:URLRequest = new URLRequest(Firebase.FIREBASE_INSERT_URL + Firebase.LOGGED_USER_DATA.user_id +
						".json" + "?auth=" + Firebase.FIREBASE_AUTH_TOKEN);
				request.data = JSON.stringify(myObject);
				request.method = URLRequestMethod.POST;

				var taskLoader:URLLoader = new URLLoader();
				taskLoader.addEventListener(flash.events.Event.COMPLETE, taskSent);
				taskLoader.load(request);
			}
		}

		private function taskSent(event:flash.events.Event):void
		{
			goBack();
		}

		private function goBack():void
		{
			if (alert) {
				alert.removeFromParent(true);
			}

			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}

	}
}