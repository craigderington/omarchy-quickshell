import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// GhostBar — a minimal, near-invisible HUD strip that shows nothing but the
// workspace indicators. The window background is fully transparent so the
// segments appear to float directly over the wallpaper. Each workspace is a
// thin horizontal tick that elongates and glows when active, shrinks to a
// faint dot when merely present, and all but vanishes when empty.
//
// Selected via barMode === "ghost" (see Navbar.cycleBarMode / IPC handler).
PanelWindow {
    id: bar
    required property var root

    // High-tech accent. Falls back to the theme accent but leans cyan so the
    // glow reads as a heads-up display rather than a normal status bar.
    readonly property color accent: bar.root.accent
    readonly property color ink:    bar.root.ink

    color: "transparent"
    anchors { top: true; left: true; right: true }
    implicitHeight: bar.root.barHeight
    // Reserve the same strut as the other modes so toggling between them
    // doesn't reflow windows. The surface itself stays transparent.
    exclusiveZone: bar.root.barHeight

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "omarchy-menu"

    // Left-aligned cluster of indicators — no panel, no border, no fill.
    Row {
        id: cluster
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 7

        Repeater {
            model: 10

            delegate: Item {
                id: ws
                required property int index
                readonly property int wsId: index + 1
                readonly property bool active:  bar.root.activeWs === wsId
                readonly property bool present: bar.root.existingWs.indexOf(wsId) !== -1

                width: 20
                height: bar.root.barHeight
                anchors.verticalCenter: parent.verticalCenter

                // Soft glow halo behind the active tick. A blurred-looking
                // wash achieved cheaply with a low-opacity rounded rect.
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: tick.y - 3.5
                    width: tick.width + 10
                    height: 9
                    radius: 4.5
                    color: bar.accent
                    opacity: ws.active ? 0.18 : 0.0
                    visible: opacity > 0.001
                    Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                }

                // The tick itself: a thin pill that grows with importance.
                Rectangle {
                    id: tick
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: parent.height / 2 + 4
                    height: 2
                    radius: 1
                    // Only the currently selected workspace gets an indicator.
                    width: ws.active ? 16 : 0
                    color: bar.accent
                    opacity: ws.active ? 1.0 : 0.0
                    Behavior on width   { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 180 } }

                    // Breathing pulse on the active workspace — subtle life.
                    SequentialAnimation on opacity {
                        running: ws.active
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.65; duration: 1800; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.65; to: 1.0; duration: 1800; easing.type: Easing.InOutSine }
                    }
                }

                // Muted workspace number sitting above the tick. Brightens with
                // state but stays whisper-quiet so the strip reads as a HUD.
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: tick.top
                    anchors.bottomMargin: 3
                    text: String(ws.wsId)
                    color: bar.accent
                    opacity: ws.active ? 1.0
                           : ws.present ? 0.75
                           : (mouse.containsMouse ? 0.7 : 0.5)
                    font.family: bar.root.mono
                    font.pixelSize: 8
                    font.letterSpacing: 1
                    font.weight: ws.active ? Font.Bold : Font.Medium
                    Behavior on opacity { NumberAnimation { duration: 180 } }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: bar.root.run("hyprctl dispatch workspace " + ws.wsId)
                }
            }
        }
    }
}
