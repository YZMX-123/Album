export class Ratio {
  private w: number;
  private h: number;
  constructor(w: number, h: number) {
    this.w = w;
    this.h = h;
  }
  set(w: number, h: number): void {
    this.w = w;
    this.h = h;
  }
  getW(): number {
    return this.w;
  }
  getH(): number {
    return this.h;
  }
  getRate(): number {
    return (this.w / this.h);
  }
  isValid(): boolean {
    return (this.w > 0 && this.h > 0);
  }
}