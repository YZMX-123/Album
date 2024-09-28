// 线程间传递的消息
export class MessageItem {
  constructor(buf: ArrayBuffer, last: number, cur: number) {
    this.buf = buf;
    this.last = last;
    this.cur = cur;
  }
  buf: ArrayBuffer;
  last: number;
  cur: number;
}