extends Object
class_name EventBus

var listeners := {}

func subscribe(event_name: String, callback: Callable):
	if not listeners.has(event_name):
		listeners[event_name] = []
	listeners[event_name].append(callback)

func emit(event_name: String, data = null):
	if listeners.has(event_name):
		for callback in listeners[event_name]:
			callback.call(data)
