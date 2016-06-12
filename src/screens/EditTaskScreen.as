package screens
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
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
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class EditTaskScreen extends PanelScreen
	{
		private var alert:Alert;
		private var nameInput:TextInput;
		private var descriptionInput:TextInput;
		private var dueDate:DateTimeSpinner;
		
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
			this.layout = new AnchorLayout();
			this.title = "Edit Task";
			this.backButtonHandler = goBack;

			var backButton:Button = new Button();
			backButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			backButton.styleNameList.add("back-button");
			
			this.headerProperties.leftItems = new <DisplayObject>[backButton];
			
			var saveIcon:ImageLoader = new ImageLoader();
			saveIcon.source = "assets/icons/save.png";
			saveIcon.width = saveIcon.height = 25;
			
			var saveButton:Button = new Button();
			saveButton.defaultIcon = saveIcon;
			saveButton.addEventListener(starling.events.Event.TRIGGERED, updateTask);
			saveButton.styleNameList.add("header-button");
			
			this.headerProperties.rightItems = new <DisplayObject>[saveButton];
			
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
			nameInput.text = _data.selectedTask.title;
			nameInput.prompt = "Task Name";
			mainGroup.addChild(nameInput);
			
			descriptionInput = new TextInput();
			descriptionInput.layoutData = new VerticalLayoutData(100, NaN);
			descriptionInput.height = 100;
			descriptionInput.text = _data.selectedTask.description;
			descriptionInput.prompt = "Task Description";
			descriptionInput.textEditorProperties.multiline = true;
			mainGroup.addChild(descriptionInput);
			
			var label1:Label = new Label();
			label1.text = "Due Date";
			mainGroup.addChild(label1);
			
			dueDate = new DateTimeSpinner();
			dueDate.value = new Date(_data.selectedTask.due_date);
			mainGroup.addChild(dueDate);
			
		}
		
		private function updateTask():void
		{
			if(nameInput.text == ""){
				alert = Alert.show("A name is required.", "Error", new ListCollection(
					[
						{ label: "OK"}
					]) );
			} else {
				var urlVars:Object = new Object();
				urlVars.title = nameInput.text;
				urlVars.description = descriptionInput.text;
				urlVars.due_date = dueDate.value.getTime();
				
				var header:URLRequestHeader = new URLRequestHeader("X-HTTP-Method-Override", "PATCH");			
				var request:URLRequest = new URLRequest(Firebase.FIREBASE_UPDATE_URL+Firebase.LOGGED_USER_DATA.localId+
					"/"+_data.selectedTask.id+".json?auth="+Firebase.LOGGED_USER_DATA.idToken);
				request.data = JSON.stringify(urlVars);
				request.method = URLRequestMethod.POST;
				request.requestHeaders.push(header);
				
				var taskLoader:URLLoader = new URLLoader();
				taskLoader.addEventListener(flash.events.Event.COMPLETE, taskUpdated);
				taskLoader.load(request);
			}			
		}
		
		private function taskUpdated(event:flash.events.Event):void
		{
			goBack();
		}
		
		private function goBack():void
		{
			if(alert){
				alert.removeFromParent(true);
			}
			
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}
	}
}