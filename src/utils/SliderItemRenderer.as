package utils
{
	import feathers.controls.BasicButton;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollBarDisplayMode;
	import feathers.controls.ScrollContainer;
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.RelativePosition;

	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.text.TextFormat;

	public class SliderItemRenderer extends LayoutGroupListItemRenderer
	{
		protected static const FIXED_HEIGHT:Number = 70;

		protected var _leftThreshold:int = 50;
		protected var _rightThreshold:int = 50;
		protected var _additionalThreshold:int = 5;

		protected var _scrollerContainer:ScrollContainer;
		protected var _leftContent:LayoutGroup;
		protected var _middleContent:LayoutGroup;
		protected var _rightContent:LayoutGroup;

		protected var _label1:Label;
		protected var _label2:Label;

		protected var _transparentButton:BasicButton;
		protected var _button1:Button;
		protected var _button2:Button;


		public function SliderItemRenderer()
		{
			super();
			this.minHeight = FIXED_HEIGHT;
		}

		override protected function initialize():void
		{
			this._scrollerContainer = new ScrollContainer();
			this._scrollerContainer.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			this._scrollerContainer.layout = new HorizontalLayout();
			this._scrollerContainer.hasElasticEdges = false;
			this._scrollerContainer.decelerationRate = 0.3;
			this.addChild(_scrollerContainer);

			this._leftContent = new LayoutGroup();
			this._leftContent.height = FIXED_HEIGHT;
			this._leftContent.layout = new AnchorLayout();
			this._leftContent.backgroundSkin = new Quad(3, 3, 0x0066FF);
			this._scrollerContainer.addChild(this._leftContent);

			this._middleContent = new LayoutGroup();
			this._middleContent.height = FIXED_HEIGHT;
			this._middleContent.layout = new AnchorLayout();
			this._middleContent.backgroundSkin = new Quad(3, 3, 0xFFFFFF);
			this._scrollerContainer.addChild(this._middleContent);

			this._rightContent = new LayoutGroup();
			this._rightContent.height = FIXED_HEIGHT;
			this._rightContent.layout = new AnchorLayout();
			this._rightContent.backgroundSkin = new Quad(3, 3, 0xCC0000);
			this._scrollerContainer.addChild(this._rightContent);

			this._label1 = new Label();
			this._label1.styleProvider = null;
			this._label1.layoutData = new AnchorLayoutData(12, 10, NaN, 10, NaN, NaN);
			this._label1.fontStyles = new TextFormat("_sans", 16, 0x000000, "left");
			this._middleContent.addChild(this._label1);

			this._label2 = new Label();
			this._label2.styleProvider = null;
			this._label2.layoutData = new AnchorLayoutData(NaN, 10, 12, 10, NaN, NaN);
			this._label2.fontStyles = new TextFormat("_sans", 16, 0x000000, "left");
			this._middleContent.addChild(this._label2);

			this._transparentButton = new BasicButton();
			this._transparentButton.styleProvider = null;
			this._transparentButton.addEventListener(Event.TRIGGERED, function ():void
			{
				owner.selectedIndex = owner.dataProvider.getItemIndex(data);

				_scrollerContainer.scrollToPageIndex(1, 0, 0.2);
				_scrollerContainer.snapToPages = true;

				if (!isSelected) {
					_scrollerContainer.scrollToPageIndex(1, 0, 0.3);
					_scrollerContainer.snapToPages = true;
				}

				_middleContent.backgroundSkin = new Quad(3, 3, 0x00796B);

				var bubblingEvent:Event = new Event("select-task", true);
				dispatchEvent(bubblingEvent);

			});
			this._transparentButton.layoutData = new AnchorLayoutData(0, 0, 0, 0, NaN, NaN);
			this._middleContent.addChild(this._transparentButton);

			var icon1:ImageLoader = new ImageLoader();
			icon1.width = icon1.height = 30;
			icon1.source = "assets/icons/done.png";

			this._button1 = new Button();
			this._button1.styleProvider = null;
			this._button1.addEventListener(Event.TRIGGERED, disposeRenderer);
			this._button1.gap = 5;
			this._button1.visible = false;
			this._button1.width = 50;
			this._button1.layoutData = new AnchorLayoutData(0, 0, 0, NaN, NaN, 0);
			this._button1.defaultIcon = icon1;
			this._button1.label = "Done";
			this._button1.iconPosition = RelativePosition.TOP;
			this._button1.defaultSkin = new Quad(3, 3, 0x0066FF);
			this._button1.fontStyles = new TextFormat("_sans", 12, 0xFFFFFF)
			this._leftContent.addChild(this._button1);

			var icon2:ImageLoader = new ImageLoader();
			icon2.width = icon2.height = 30;
			icon2.source = "assets/icons/delete.png";

			this._button2 = new Button();
			this._button2.styleProvider = null;
			this._button2.addEventListener(Event.TRIGGERED, disposeRenderer);
			this._button2.gap = 5;
			this._button2.visible = false;
			this._button2.width = 50;
			this._button2.layoutData = new AnchorLayoutData(0, NaN, 0, 0, NaN, 0);
			this._button2.defaultIcon = icon2;
			this._button2.label = "Delete";
			this._button2.iconPosition = RelativePosition.TOP;
			this._button2.defaultSkin = new Quad(3, 3, 0xCC0000);
			this._button2.fontStyles = new TextFormat("_sans", 12, 0xFFFFFF)
			this._rightContent.addChild(this._button2);

			this.addEventListener(EnterFrameEvent.ENTER_FRAME, checkSelectedIndex);
			this._scrollerContainer.addEventListener(FeathersEventType.BEGIN_INTERACTION, startDrag);
			this._scrollerContainer.addEventListener(FeathersEventType.END_INTERACTION, stopDrag);

			stage.addEventListener(ResizeEvent.RESIZE, reSize);
		}

		override protected function commitData():void
		{
			if (this._data && this._owner) {
				this._label1.text = "<b>" + this._data.title + "</b>";
				this._label2.text = new Date(this._data.due_date).toLocaleString();

				this._button1.visible = false;
				this._button2.visible = false
			} else {
				this._label1.text = "";
				this._label2.text = "";
			}
		}

		override protected function postLayout():void
		{
			this._scrollerContainer.width = this.owner.width;
			this._scrollerContainer.pageWidth = this.owner.width;

			this._leftContent.width = this.owner.width;
			this._middleContent.width = this.owner.width;
			this._rightContent.width = this.owner.width;

			this._scrollerContainer.scrollToPageIndex(1, 0, 0);
			this._scrollerContainer.snapToPages = true;
		}

		protected function reSize(event:ResizeEvent):void
		{
			this._scrollerContainer.removeEventListener(Event.SCROLL, scrollingHandler);

			this.width = event.width;
			this._scrollerContainer.width = event.width;
			this._scrollerContainer.pageWidth = event.width;

			this._leftContent.width = event.width;
			this._middleContent.width = event.width;
			this._rightContent.width = event.width;

			this._scrollerContainer.scrollToPosition(0, event.width, 0);
			this._scrollerContainer.snapToPages = true;
		}

		protected function startDrag(event:Event):void
		{
			this._scrollerContainer.addEventListener(Event.SCROLL, scrollingHandler);
			this.owner.selectedIndex = owner.dataProvider.getItemIndex(data);

			//If the scrolling is touched by the user we show the buttons, this is to avoid unnecessary draw calls
			this._button1.visible = true;
			this._button2.visible = true;
		}

		protected function scrollingHandler(event:Event):void
		{
			//If slider has been dragged to the farright it will return to the middle of the right

			if (this._scrollerContainer.horizontalScrollPosition <= 40) {
				this._scrollerContainer.removeEventListener(Event.SCROLL, scrollingHandler);
				disposeRenderer();
			}

			if (this._scrollerContainer.horizontalScrollPosition >= this._scrollerContainer.maxHorizontalScrollPosition - 40) {
				this._scrollerContainer.removeEventListener(Event.SCROLL, scrollingHandler);
				disposeRenderer();
			}

		}

		protected function stopDrag(event:Event):void
		{
			if (this._scrollerContainer.isScrolling) {
				checkScrollPosition();
			} else {
				checkSelectedIndex();
			}
		}

		protected function checkScrollPosition():void
		{
			var currentPosition:int = this._scrollerContainer.horizontalScrollPosition;
			var tween:Tween;

			if (currentPosition <= Math.round(this._scrollerContainer.maxHorizontalScrollPosition / 2) - this._additionalThreshold &&
					currentPosition >= 0) {
				this._scrollerContainer.snapToPages = false;

				tween = new Tween(this._scrollerContainer, 0.2);
				tween.animate("horizontalScrollPosition", (Math.round(this._scrollerContainer.maxHorizontalScrollPosition / 2)) - this._leftThreshold);
				Starling.juggler.add(tween);
			}

			else if (currentPosition >= Math.round(this._scrollerContainer.maxHorizontalScrollPosition / 2) + this._additionalThreshold &&
					currentPosition <= this._scrollerContainer.maxHorizontalScrollPosition - this._additionalThreshold) {
				this._scrollerContainer.snapToPages = false;

				tween = new Tween(this._scrollerContainer, 0.2);
				tween.animate("horizontalScrollPosition", (Math.round(this._scrollerContainer.maxHorizontalScrollPosition / 2)) + this._rightThreshold);
				Starling.juggler.add(tween);
			}


			else {
				this._scrollerContainer.snapToPages = true;
			}
		}

		protected function disposeRenderer():void
		{
			var tween:Tween = new Tween(this, 0.2);
			tween.animate("height", 0);
			tween.onComplete = function ():void
			{
				var bubblingEvent:Event = new Event("delete-task", true);
				dispatchEvent(bubblingEvent);

				Starling.juggler.remove(tween);
				_owner.dataProvider.removeItemAt(_owner.selectedIndex);
			};
			Starling.juggler.add(tween);
		}

		protected function checkSelectedIndex():void
		{
			if (!this.isSelected) {
				this._scrollerContainer.scrollToPageIndex(1, 0, 0.3);
				this._scrollerContainer.snapToPages = true;
			}
		}

	}
}