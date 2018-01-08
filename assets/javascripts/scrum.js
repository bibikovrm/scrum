function touchHandler(event) {
	var touch = event.changedTouches[0];
	var simulatedEvent = document.createEvent("MouseEvent");
	simulatedEvent.initMouseEvent({
		touchstart: "mousedown",
		touchmove: "mousemove",
		touchend: "mouseup"
	}[event.type], true, true, window, 1,
		touch.screenX, touch.screenY,
		touch.clientX, touch.clientY, false,
		false, false, false, 0, null);
	touch.target.dispatchEvent(simulatedEvent);
	if (!event) {
		event = window.event;
	}
	var sender = event.srcElement || event.target;
	if (sender &&
		sender.nodeName.toLowerCase() != "a" &&
		sender.nodeName.toLowerCase() != "input") {
		event.preventDefault();
	}
}

function draggableOnTouchScreen(element_id) {
	var element = document.getElementById(element_id);
	if (element) {
		element.addEventListener("touchstart", touchHandler, true);
		element.addEventListener("touchmove", touchHandler, true);
		element.addEventListener("touchend", touchHandler, true);
		element.addEventListener("touchcancel", touchHandler, true);
	}
}

// Hide or show lost Tasks cells depending if lost Tasks exist
function toggle_lost_tasks_cells() {
  var lost_tasks_cells = $('.lost-task');

  if (lost_tasks_cells.length == 0)
    return;

  var lost_tasks = $('.sprint-task.lost-task');

  if (lost_tasks.length == 0) {
    lost_tasks_cells.addClass('no-lost-task');
  } else {
    lost_tasks_cells.removeClass('no-lost-task');
  }
};
