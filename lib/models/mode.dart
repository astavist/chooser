enum Mode {
  single,
  group,
  order;

  Mode next() {
    switch (this) {
      case Mode.single:
        return Mode.group;
      case Mode.group:
        return Mode.order;
      case Mode.order:
        return Mode.single;
    }
  }

  int initialCount() {
    switch (this) {
      case Mode.single:
      case Mode.order:
        return 1;
      case Mode.group:
        return 2;
    }
  }

  int nextCount(int count) {
    switch (this) {
      case Mode.single:
        return (count % 5) + 1;
      case Mode.group:
        return ((count - 1) % 4) + 2;
      case Mode.order:
        return 1;
    }
  }
} 