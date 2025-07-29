// Bar.qml - Main bar/panel component
// Based on quickshell documentation examples with Rose Pine theming
import Quickshell
import QtQuick

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 40
      
      // Rose Pine background color
      color: "#191724"

      Row {
        anchors.centerIn: parent
        spacing: 20

        // Workspaces indicator (placeholder)
        Rectangle {
          width: 100
          height: 30
          color: "#26233a"
          radius: 8
          
          Text {
            anchors.centerIn: parent
            text: "Workspaces"
            color: "#e0def4"
            font.family: "Noto Sans"
            font.pixelSize: 12
          }
        }

        // Clock widget - no need to pass time property since it accesses singleton directly
        ClockWidget {
        }

        // System info placeholder
        Rectangle {
          width: 80
          height: 30
          color: "#26233a"
          radius: 8
          
          Text {
            anchors.centerIn: parent
            text: "System"
            color: "#e0def4"
            font.family: "Noto Sans"
            font.pixelSize: 12
          }
        }
      }
    }
  }
}