

import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class CheckLanguageEvent{
  // 是否刷新
  bool? check = false;
  CheckLanguageEvent({this.check});
}
