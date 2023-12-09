

import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class CheckLanguageEvent{
  // Refresh or not
  bool? check = false;
  CheckLanguageEvent({this.check});
}
