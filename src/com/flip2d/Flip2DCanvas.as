package com.flip2d {
	import flashx.textLayout.elements.SpecialCharacterElement;
	import flash.geom.Matrix3D;
	import flash.display3D.Program3D;
	import flash.display3D.Context3DProgramType;
	import com.adobe.utils.AGALMiniAssembler;
	import com.flip2d.utils.ColorUtil;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3D;
	import flash.display.Stage3D;
	import flash.system.Capabilities;
	import flash.events.ErrorEvent;
	import flash.system.ApplicationDomain;
	import com.flip2d.utils.TextLabel;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.display.Sprite;
	import com.flip2d.renderables.BaseRender;
	/**
	 * @author emil
	 */
	public class Flip2DCanvas extends Sprite {
		private var renderInfoField : TextLabel;
		private var context3D : Context3D;

		private var vertexBuffer : VertexBuffer3D;
		private var vertexBufferData : Vector.<Number>;
		private var indexData : Vector.<uint>;
		private var indexBuffer : IndexBuffer3D;
		private var vertexAssembler : AGALMiniAssembler;
		private var fragmentAssembler : AGALMiniAssembler;
		private var vertexShader : Array;
		private var fragmentShader : Array;
		private var program : Program3D;
		private var projection : Matrix3D;
		private var vertexData : Vector.<Number> = new Vector.<Number>();
		private var displayList:Vector.<BaseRender> = new Vector.<BaseRender>();
		private var stage3DAvailable : Boolean;
		
		private var _canvasWidth : Number;
		private var _canvasHeight : Number;
		private var _antiAlias : int = 2;
		
		public var backgroundColor:Number = 0xbeeeef;
		public var renderAlpha : Number = 1;
		private var hueRender : Program3D;
		private var sepiaRender : Program3D;
		private var fragmentShaderHue : Array;
		private var fragmentAssemblerHue : AGALMiniAssembler;
		private var fragmentShaderSepia : Array;
		private var fragmentAssemblerSepia : AGALMiniAssembler;
		
		
		public function Flip2DCanvas(canvasWidth:Number = 800, canvasHeight:Number = 600):void {
			_canvasWidth = canvasWidth;
			_canvasHeight = canvasHeight;
			
			if(stage != null){
				initializeStage3D(null);
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, initializeStage3D);
			}
		}
		
		public function get canvasWidth():Number {return _canvasWidth;}
		public function set canvasWidth(value:Number):void {
			_canvasWidth = value;
			if(stage3DAvailable) updateBackBuffer();
		}
		public function get canvasHeight():Number {return _canvasHeight;}
		public function set canvasHeight(value:Number):void {
			_canvasHeight = value;
			if(stage3DAvailable) updateBackBuffer();
		}
		
		public function add(child : BaseRender) : void {
			displayList.push(child);
		}
		
		public function set antiAlias(value:Number):void {
			if( value == _antiAlias) return;
			_antiAlias = value;
			updateBackBuffer();
		}
		
		private function updateBackBuffer() : void {
			context3D.configureBackBuffer(canvasWidth, canvasHeight, _antiAlias, true);
		}

		private function initializeStage3D(e:Event) : void {
			trace('initializeStage3D: ' + (initializeStage3D));
			if (hasEventListener(Event.ADDED_TO_STAGE)) {
				removeEventListener(Event.ADDED_TO_STAGE, initializeStage3D);
			}
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			initGUI();
						
			stage3DAvailable = ApplicationDomain.currentDomain.hasDefinition("flash.display.Stage3D");
			
			if (stage3DAvailable) {
				trace('stage3D is available');
			    stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
			    // detect when the swf is not using wmode=direct
			    stage.stage3Ds[0].addEventListener(ErrorEvent.ERROR, onStage3DError);
			    // request hardware 3d mode now
			    stage.stage3Ds[0].requestContext3D();
			}
			else {
			    trace("stage3DAvailable is false!");
			    renderInfoField.txt.text =
			    'Flash 11 Required.\nYour version: '
			    + Capabilities.version
			    +'\nThis game uses Stage3D.'
			    +'\nPlease upgrade to Flash 11'
			    +'\nso you can play 3d games!';
			}
		}

		private function onStage3DError(event : ErrorEvent) : void {
			trace("stage3DAvailable is false!");
		    renderInfoField.txt.text =
		    'Flash 11 Required.\nYour version: '
		    + Capabilities.version
		    +'\nThis game uses Stage3D.'
		    +'\nPlease upgrade to Flash 11'
		    +'\nso you can play 3d games!';
		}

		private function onContext3DCreate(event : Event) : void {
			trace('onContext3DCreate: ' + (onContext3DCreate));
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME,enterFrame);
			}
			var t:Stage3D = event.target as Stage3D;
    		context3D = t.context3D;
			
			if (context3D == null){
		        // Currently no 3d context is available (error!)
		       	trace('ERROR: no context3D - video driver problem?');
		        return;
		    }
		 
		    // detect software mode (html might not have wmode=direct)
		    if ((context3D.driverInfo == Context3DRenderMode.SOFTWARE) || (context3D.driverInfo.indexOf('oftware')>-1))
		    {
		        //Context3DRenderMode.AUTO
		        trace("Software mode detected!");
		        renderInfoField.txt.text = 'Software Rendering Detected!'
		        +'\nYour Flash 11 settings'
		        +'\nhave hardware 3D turned OFF.'
		        +'\nIs wmode=direct in the html?'
		        +'\nExpect poor performance.';
		    }
		    // if this is too big, it changes the stage size!
		    renderInfoField.txt.text = 'Flash 11 Stage3D '
		    +'(Molehill) is working perfectly!'
		    +'\nFlash Version: '
		    + Capabilities.version
		    + '\n3D mode: ' + context3D.driverInfo;
		 
		    // Disabling error checking will drastically improve performance.
		    // If set to true, Flash sends helpful error messages regarding
		    // AGAL compilation errors, uninitialized program constants, etc.
		    context3D.enableErrorChecking = false;
		    CONFIG::debug
		    {
		        context3D.enableErrorChecking = true; // v2
		    }
		 
		    // The 3d back buffer size is in pixels
		    context3D.configureBackBuffer(_canvasWidth, _canvasHeight, _antiAlias, true);
		 
		    // assemble all the shaders we need
		    initShaders();
		 
		    // start animating
		    addEventListener(Event.ENTER_FRAME,enterFrame);
		}

		private function createVertexData() : void {
			vertexBufferData = new Vector.<Number>();
			indexData = new Vector.<uint>();
			var indexCount:uint = 0;
			for(var i:uint = 0; i < displayList.length;i++){
				var d:BaseRender = displayList[i];
				var xval:Number;
				var yval:Number;
				var cols:Array;
				for(var t:uint = 0; t < 3; t++){
					xval =  d.x + (t == 1 ? d.width : 0);
					xval = (xval / canvasWidth) * 2 - 1;
					yval = d.y + (t == 2 ? d.height : 0);
					yval = ((yval / canvasWidth) * 2 - 1) * -1;
					vertexBufferData.push(xval); //x
					vertexBufferData.push(yval); //y
					vertexBufferData.push(0); //z
					cols = ColorUtil.vec3cColorToHex(displayList[i].color);
					vertexBufferData.push(cols[0],cols[1],cols[2]);
					indexData.push(indexCount);
					indexCount++;
				}
				for(var k:uint = 0; k < 3;k++){
					xval =  d.x + (k == 1 ? 0 : d.width);
					xval = (xval / canvasWidth) * 2 - 1;
					yval = d.y + (k == 0 ? 0 : d.height);
					yval = ((yval / canvasWidth) * 2 - 1) * -1;
					vertexBufferData.push(xval); //x
					vertexBufferData.push(yval); //y
					vertexBufferData.push(0); //z
					cols = ColorUtil.vec3cColorToHex(displayList[i].color);
					vertexBufferData.push(cols[0],cols[1],cols[2]);
					indexData.push(indexCount);
					indexCount++;
				}
			}
			vertexBuffer = context3D.createVertexBuffer(displayList.length*6, 6);
			vertexBuffer.uploadFromVector( vertexBufferData,0,displayList.length*6);
			indexBuffer = context3D.createIndexBuffer( displayList.length*6);
			indexBuffer.uploadFromVector(indexData, 0, displayList.length*6);
			context3D.setVertexBufferAt( 0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 );
			context3D.setVertexBufferAt( 1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3 );
		}
		
		private function initShaders() : void {
			vertexShader = [
				"m44 vt0, va0, vc0",
				"mov v0, va1",
      			"mov op, vt0"
			];
			vertexAssembler = new AGALMiniAssembler();
			vertexAssembler.assemble(Context3DProgramType.VERTEX, vertexShader.join("\n"));
			
			fragmentShaderHue = [
				"mul ft0, v0, fc0",
				"mov oc, ft0"
			];
			fragmentAssemblerHue = new AGALMiniAssembler();
			fragmentAssemblerHue.assemble(Context3DProgramType.FRAGMENT, fragmentShaderHue.join("\n"));
			
			hueRender = context3D.createProgram();
			hueRender.upload(vertexAssembler.agalcode, fragmentAssemblerHue.agalcode);
			context3D.setProgram(hueRender);
			
			fragmentShaderSepia = [
				"mul ft0, v0, fc1",
				"mov oc, ft0"
			];
			fragmentAssemblerSepia = new AGALMiniAssembler();
			fragmentAssemblerSepia.assemble(Context3DProgramType.FRAGMENT, fragmentShaderSepia.join("\n"));
			
			sepiaRender = context3D.createProgram();
			sepiaRender.upload(vertexAssembler.agalcode, fragmentAssemblerSepia.agalcode);
			context3D.setProgram(sepiaRender);
			
			projection = new Matrix3D();
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, projection, true);
      		context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([1, 1, 1, 1]));
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, Vector.<Number>([0.5, 0.4, 1, 1]));
		}

		private function enterFrame(event : Event) : void {
			if (displayList.length == 0) return;
			createVertexData();
			var cols:Array = ColorUtil.vec3cColorToHex(backgroundColor);
			context3D.clear(cols[0],cols[1],cols[2],renderAlpha);
			//context3D.setProgram(getRenderFromString(displayList[i].renderMode));
			context3D.drawTriangles(indexBuffer,4,4);
			context3D.present();
		}

		private function getRenderFromString(renderMode : String) : Program3D {
			var renderShader:Program3D;
			switch(renderMode){
				case RenderConstants.HUE_RENDER:
					renderShader = hueRender;
					break;
				case RenderConstants.SEPIA_RENDER:
					renderShader = sepiaRender;
					break;
				default:
					renderShader = hueRender;
					break;
			}
			return renderShader;
		}

		private function initGUI() : void {
			renderInfoField = new TextLabel("stage3d is not ready");
			addChild(renderInfoField);
		}
	}
}
