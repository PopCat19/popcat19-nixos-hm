// ClockWidget.qml - Clock display component
// Based on quickshell documentation examples with Rose Pine theming
import QtQuick

Rectangle {
  width: 200
  height: 30
  color: "#26233a"
  radius: 8

  Text {
    anchors.centerIn: parent
    
    // Directly access the time property from the Time singleton
    text: Time.time
    
    // Rose Pine text styling
    color: "#e0def4"
    font.family: "Noto Sans"
    font.pixelSize: 14
    font.weight: Font.Medium
  }
}