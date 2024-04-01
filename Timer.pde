@FunctionalInterface
interface TimerFunction {
    void timeout();
}

class Timer {
  int interval = 1 * 1000; // 1 Second Timer Interval
  int lastFire = 0;
  TimerFunction tfx;
}

void timer(Timer t) {
  // Check if the specified interval has passed
  if (millis() - t.lastFire > t.interval) {
    t.lastFire = millis();
    t.tfx.timeout();
  }
}
