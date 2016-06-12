package
{
		
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.ButtonState;
	import feathers.controls.Header;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.PanelScreen;
	import feathers.controls.ScrollText;
	import feathers.controls.SpinnerList;
	import feathers.controls.TextInput;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.controls.text.StageTextTextEditor;
	import feathers.controls.text.TextBlockTextRenderer;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.FeathersControl;
	import feathers.core.ITextEditor;
	import feathers.core.ITextRenderer;
	import feathers.layout.HorizontalAlign;
	import feathers.themes.StyleNameFunctionTheme;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	
	public class CustomTheme extends StyleNameFunctionTheme
	{
				
		public function CustomTheme()
		{
			super();			
			this.initialize();
		}
		
		private function initialize():void
		{
			Alert.overlayFactory = function():DisplayObject
			{
				var quad:Quad = new Quad(3, 3, 0x000000);
				quad.alpha = 0.50;
				return quad;
			};
			
			this.initializeGlobals();
			this.initializeStyleProviders();	
		}
		
		private function initializeGlobals():void
		{
			FeathersControl.defaultTextRendererFactory = function():ITextRenderer
			{
				return new TextBlockTextRenderer();
			}
			
			FeathersControl.defaultTextEditorFactory = function():ITextEditor
			{
				return new StageTextTextEditor();
			}
		}
		
		private function initializeStyleProviders():void
		{
			this.getStyleProviderForClass(Button).setFunctionForStyleName("alert-button", setAlertButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("back-button", setBackButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("callout-button", setCalloutButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("header-button", setHeaderButtonStyles);
			this.getStyleProviderForClass(Label).setFunctionForStyleName("custom-label", setCustomLabelStyles);
			
			this.getStyleProviderForClass(Alert).defaultStyleFunction = this.setAlertStyles;
			this.getStyleProviderForClass(Button).defaultStyleFunction = this.setButtonStyles;
			this.getStyleProviderForClass(DefaultListItemRenderer).defaultStyleFunction = this.setDefaultListItemRendererStyles;
			this.getStyleProviderForClass(Header).defaultStyleFunction = this.setHeaderStyles;
			this.getStyleProviderForClass(Label).defaultStyleFunction = this.setLabelStyles;
			this.getStyleProviderForClass(List).defaultStyleFunction = this.setListStyles;
			this.getStyleProviderForClass(PanelScreen).defaultStyleFunction = this.setPanelScreenStyles;
			this.getStyleProviderForClass(ScrollText).defaultStyleFunction = this.setScrollTextStyles;
			this.getStyleProviderForClass(SpinnerList).defaultStyleFunction = this.setSpinnerListStyles;
			this.getStyleProviderForClass(TextInput).defaultStyleFunction = this.setTextInputStyles;
		}
		
		//-------------------------
		// Alert
		//-------------------------
		
		private function setAlertStyles(alert:Alert):void
		{
			alert.backgroundSkin = new Quad(3, 3, 0xE0F2F1);
			alert.maxWidth = 250;
			alert.minHeight = 50;
			alert.padding = 10;
						
			var icon:ImageLoader = new ImageLoader();
			icon.source = "assets/icons/warning.png";
			icon.width = icon.height = 20;
			
			alert.headerProperties.paddingLeft = 10;
			alert.headerProperties.leftItems = new <DisplayObject>[icon];
			alert.headerProperties.gap = 10;
			alert.headerProperties.titleAlign = Header.TITLE_ALIGN_PREFER_LEFT;
			
			alert.messageFactory = function():ITextRenderer
			{
				var renderer:TextBlockTextRenderer = new TextBlockTextRenderer();
				renderer.elementFormat = new ElementFormat(new FontDescription("_sans"), 14, 0x00000);
				renderer.leading = 7;
				renderer.wordWrap = true;
				return renderer;
			};
			
			alert.buttonGroupFactory = function():ButtonGroup
			{
				var group:ButtonGroup = new ButtonGroup();
				group.customButtonStyleName = "alert-button";
				group.direction = ButtonGroup.DIRECTION_HORIZONTAL;
				group.gap = 10;
				group.padding = 10;
				return group;
			}
			
		}
		
		
		//-------------------------
		// Button
		//-------------------------
				
		private function setButtonStyles(button:Button):void
		{
			button.height = 50;
			button.defaultSkin = RoundedRect.createRoundedRect(0xE0F2F1);
			button.downSkin = RoundedRect.createRoundedRect(0xCCCCCC);
			
			button.labelFactory = function():ITextRenderer
			{
				var renderer:TextBlockTextRenderer = new TextBlockTextRenderer();
				renderer.elementFormat = new ElementFormat(new FontDescription("_sans"), 16, 0x000000);
				return renderer;
			};
		}
		
		private function setCalloutButtonStyles(button:Button):void
		{
			button.width = 120;
			button.height = 35;
			button.horizontalAlign = HorizontalAlign.LEFT;
			button.paddingLeft = 10;
			button.defaultSkin = new Quad(3, 3, 0x00796B);
			button.downSkin = new Quad(3, 3, 0x004D40);
			button.labelFactory = function():ITextRenderer
			{
				var renderer:TextBlockTextRenderer = new TextBlockTextRenderer();
				renderer.elementFormat = new ElementFormat(new FontDescription("_sans"), 12, 0xFFFFFF);
				renderer.textAlign = TextBlockTextRenderer.TEXT_ALIGN_LEFT;
				return renderer;
			}
		}
		
		private function setAlertButtonStyles(button:Button):void
		{
			button.height = 40;
			button.defaultSkin = new Quad(40, 40, 0x00796B);
			button.downSkin = new Quad(40, 40, 0x004D40);
			button.labelFactory = function():ITextRenderer
			{
				var renderer:TextBlockTextRenderer = new TextBlockTextRenderer();
				renderer.elementFormat = new ElementFormat(new FontDescription("_sans"), 14, 0xFFFFFF);
				return renderer;
			}
		}
		
		private function setBackButtonStyles(button:Button):void
		{
			var transparentQuad:Quad = new Quad(3, 3, 0xFFFFFF);
			transparentQuad.alpha = 0.20;
			
			var arrowIcon:ImageLoader = new ImageLoader();
			arrowIcon.width = arrowIcon.height = 25;
			arrowIcon.source = "assets/icons/back-arrow.png";
			
			button.width = button.height = 45;
			button.defaultIcon = arrowIcon;
			button.downSkin = transparentQuad;
		}
		
		private function setHeaderButtonStyles(button:Button):void
		{
			var transparentQuad:Quad = new Quad(3, 3, 0xFFFFFF);
			transparentQuad.alpha = 0.20;
			
			button.width = button.height = 45;
			button.downSkin = transparentQuad;
		}
				
		//-------------------------
		// Header
		//-------------------------
		
		private function setHeaderStyles(header:Header):void
		{
			var quad:Quad = new Quad(3, 50, 0x00796B);			

			header.backgroundSkin = quad;
			
			header.titleFactory = function():ITextRenderer
			{
				var renderer:TextBlockTextRenderer = new TextBlockTextRenderer();
				renderer.elementFormat = new ElementFormat(new FontDescription("_sans"), 16, 0xFFFFFF);
				return renderer;
			}		
		}
		
		//-------------------------
		// Label
		//-------------------------
		
		private function setLabelStyles(label:Label):void
		{
			label.textRendererFactory = function():ITextRenderer
			{				
				var renderer:TextBlockTextRenderer = new TextBlockTextRenderer();
				renderer.elementFormat = new ElementFormat(new FontDescription("_sans"), 16, 0xFFFFFF);
				return renderer;
			}		
		}
		
		//-------------------------
		// List
		//-------------------------
			
		private function setListStyles(list:List):void
		{
			list.backgroundSkin = new Quad(3, 3, 0xE0F2F1);
		}
		
		private function setDefaultListItemRendererStyles(renderer:DefaultListItemRenderer):void
		{
			renderer.defaultSkin = new Quad(3, 3, 0xFFFFFF);
			renderer.downSkin = new Quad(3, 3, 0x00796B);
			renderer.defaultSelectedSkin = new Quad(3, 3, 0x00796B);
			
			renderer.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
			renderer.paddingLeft = 10;
			renderer.paddingRight = 10;
			renderer.paddingTop = 10;
			renderer.paddingBottom = 10;
			renderer.minHeight = 50;
			renderer.gap = 10;
			
			renderer.labelFactory = function():ITextRenderer
			{
				var blackFormat:TextFormat = new TextFormat("_sans", 14, 0x000000);
				blackFormat.leading = 7;
				blackFormat.align = TextFormatAlign.LEFT;
				
				var whiteFormat:TextFormat = new TextFormat("_sans", 14, 0xFFFFFF);
				whiteFormat.leading = 7;
				whiteFormat.align = TextFormatAlign.LEFT;
				
				var renderer:TextFieldTextRenderer = new TextFieldTextRenderer();
				renderer.wordWrap = true;
				renderer.isHTML = true;
				
				renderer.setTextFormatForState(ButtonState.UP, blackFormat);
				renderer.setTextFormatForState(ButtonState.UP_AND_SELECTED, whiteFormat);
				renderer.setTextFormatForState(ButtonState.DOWN, whiteFormat);
				renderer.setTextFormatForState(ButtonState.DOWN_AND_SELECTED, whiteFormat);
				renderer.setTextFormatForState(ButtonState.HOVER, blackFormat);
				renderer.setTextFormatForState(ButtonState.HOVER_AND_SELECTED, whiteFormat);
				
				return renderer;								
			}
		}		
		
		//-------------------------
		// PanelScreen
		//-------------------------
		
		private function setPanelScreenStyles(screen:PanelScreen):void
		{
			screen.backgroundSkin = new Quad(3, 3, 0xE0F2F1);
		}
		
		private function setCustomLabelStyles(label:Label):void
		{
			label.textRendererFactory = function():ITextRenderer
			{
				var renderer:TextBlockTextRenderer = new TextBlockTextRenderer();
				
				var font:FontDescription = new FontDescription("EmojiFont");
				font.fontLookup = FontLookup.EMBEDDED_CFF;
				renderer.elementFormat = new ElementFormat(font, 16, 0xFFFFFF);
				return renderer;
			}
		}
		
		//-------------------------
		// ScrollText
		//-------------------------
				
		private function setScrollTextStyles(scrollText:ScrollText):void
		{
			var textFormat:TextFormat =  new TextFormat("_sans", 14, 0x000000);
			textFormat.leading = 7;
			
			scrollText.textFormat = textFormat;
			scrollText.isHTML = true;
		}
				
		//-------------------------
		// SpinnerList
		//-------------------------
		
		private function setSpinnerListStyles(spinnerList:SpinnerList):void
		{
			var overlay:Quad = new Quad(3, 3, 0xCCCCCC);
			overlay.alpha = 0.3;
			
			spinnerList.selectionOverlaySkin = overlay;			
			spinnerList.backgroundSkin = new Quad(3, 3, 0xFFFFFF);

		}
		
		//-------------------------
		// TextInput
		//-------------------------
		
		private function setTextInputStyles(textInput:TextInput):void
		{
			textInput.backgroundSkin = RoundedRect.createRoundedRect(0x004D40);
			textInput.padding = 10;
			
			textInput.textEditorFactory = function():ITextEditor
			{
				var editor:StageTextTextEditor = new StageTextTextEditor();
				editor.fontFamily = "_sans";
				editor.fontSize = 16;
				editor.color = 0xFFFFFF;
				return editor;
			}
			
			textInput.promptFactory	= function():ITextRenderer
			{
				var renderer:TextBlockTextRenderer = new TextBlockTextRenderer();
				renderer.elementFormat = new ElementFormat(new FontDescription("_sans"), 16, 0xCCCCCC);
				return renderer;
			}	
		}
		
	}		
}