// Time.qml - Time singleton using SystemClock
// Based on quickshell documentation examples
pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root
  
  // Format the time using SystemClock for better performance
  readonly property string time: {
    // Format matches the default output of the `date` command
    Qt.formatDateTime(clock.date, "ddd MMM d hh:mm:ss AP t yyyy")
  }

  SystemClock {
    id: clock
    // Use seconds precision for live updates
    // Change to Minutes if you don't show seconds to save battery
    precision: SystemClock.Seconds
  }
}