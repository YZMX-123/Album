export class PixelMapWrapper {
  pixelMap?: PixelMap;
  width: number = 0;
  height: number = 0;

  constructor(pixelMap: PixelMap, width: number, height: number) {
    this.pixelMap = pixelMap;
    this.width = width;
    this.height = height;
  }

  release() {
    if (this.pixelMap != undefined) {
      this.pixelMap.release();
    }
    this.width = 0;
    this.height = 0;
  }
}