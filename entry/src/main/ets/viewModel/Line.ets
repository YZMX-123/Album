import { Point } from './Point';

export class LineSegment {
  start: Point;
  end: Point;
  constructor(start: Point, end: Point) {
    this.start = start;
    this.end = end;
  }
}