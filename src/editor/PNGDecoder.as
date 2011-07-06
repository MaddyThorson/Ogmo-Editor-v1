package editor {
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/*******************************
	PNGDecoder
	Author: Jerion
	
	A class that decodes png byte arrays and generates a bitmapdata.
	This is my first attempt at decoding images, so there are a lot of
	things that are not implemented.
	
	So far, it can only decode truecolour with alpha png images with
	no interlacing, no filter, and bit depth of 8.
	********************************/
	
	public class PNGDecoder {
		private const IHDR:uint = 0x49484452;
		private const PLTE:uint = 0x504c5445;
		private const IDAT:uint = 0x49444154;
		private const IEND:uint = 0x49454e44;
		
		private var imgWidth:uint = 0;
		private var imgHeight:uint = 0;
		
		//file info, but not used yet.
		private var bitDepth:uint = 0;
		private var colourType:uint = 0;
		private var compressionMethod:uint = 0;
		private var filterMethod:uint = 0;
		private var interlaceMethod:uint = 0;
		
		private var chunks:Array;
		private var input:ByteArray;
		private var output:ByteArray;
		
		//recieves the bytearray and returns a bitmapdata
		public function decode(ba:ByteArray):BitmapData {
			chunks = new Array();
			input = new ByteArray();
			output = new ByteArray();
			
			input = ba;
			
			input.position = 0;
			
			if (!readSignature()) throw new Error("wrong signature");
			
			getChunks();
			
			for (var i:int = 0; i < chunks.length; ++i) {
				switch(chunks[i].type) {
					case IHDR: processIHDR(i); break;
					//case PLTE: processPLTE(i); break;
					case IDAT: processIDAT(i); break;
					//case IEND: processIEND(i); break;
				}
			}
			
			
			//Since the image is inverted in x and y, I have to flip it using a Matrix object. There should be a better solution for this..
			var bd0:BitmapData = new BitmapData(imgWidth, imgHeight);
			var bd1:BitmapData = new BitmapData(imgWidth, imgHeight, true, 0xffffff);
			
			if (output.length > 0 && (imgWidth * imgHeight * 4) == output.length) {
				output.position = 0;
				bd0.setPixels(new Rectangle(0,0,imgWidth,imgHeight), output);
				
				var mat:Matrix = new Matrix();
				mat.scale(-1,-1);
				mat.translate(imgWidth, imgHeight);
				
				bd1.draw(bd0, mat);
			}
			
			return bd1;
		}
		
		//read the header of the image
		private function processIHDR(index:uint):void {
			input.position = chunks[index].position;
			
			imgWidth = input.readUnsignedInt();
			imgHeight = input.readUnsignedInt();
			
			//file info, but is not used yet
			bitDepth = input.readUnsignedByte();
			colourType = input.readUnsignedByte();
			compressionMethod = input.readUnsignedByte();
			filterMethod = input.readUnsignedByte();
			interlaceMethod = input.readUnsignedByte();
		}
		
		
		//This can't handle multiple IDATs yet, and it can only decode filter 0 scanlines.
		private function processIDAT(index:uint):void {
			var tmp:ByteArray = new ByteArray();
			
			var pixw:uint = imgWidth * 4;
			
			tmp.writeBytes(input, chunks[index].position, chunks[index].length);
			tmp.uncompress();
			
			for (var i:int = tmp.length - 1; i > 0; --i) {
				if (i % (pixw + 1) != 0) {
					var a:uint = tmp[i];
					var b:uint = tmp[i-1];
					var g:uint = tmp[i-2];
					var r:uint = tmp[i-3];
					
					output.writeByte(a);
					output.writeByte(r);
					output.writeByte(g);
					output.writeByte(b);
					
					i -= 3;
				}
			}
		}
		
		private function getChunks():void {
			var pos:uint = 0;
			var len:uint = 0;
			var type:uint = 0;
			
			var loopEnd:int = input.length;
			
			while (input.position < loopEnd) {
				len = input.readUnsignedInt();
				type = input.readUnsignedInt();
				pos = input.position;
				
				input.position += len;
				input.position += 4; //crc block. It is ignored right now, but if you want to retrieve it, replace this line with "input.readUnsignedInt()"
				
				chunks.push({position: pos, length: len, type: type});
			}
		}
		
		private function readSignature():Boolean {
			return (input.readUnsignedInt() == 0x89504e47 && input.readUnsignedInt() == 0x0D0A1A0A);
		}
		
		//transform the chunk type to a string representation
		private function fixType(num:uint):String {
			var ret:String = "";
			var str:String = num.toString(16);
			
			while (str.length < 8) str = "0" + str;
			
			ret += String.fromCharCode(parseInt(str.substr(0,2), 16));
			ret += String.fromCharCode(parseInt(str.substr(2,2), 16));
			ret += String.fromCharCode(parseInt(str.substr(4,2), 16));
			ret += String.fromCharCode(parseInt(str.substr(6,2), 16));
			
			return ret;
		}
		
	}
}