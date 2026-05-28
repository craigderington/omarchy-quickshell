import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: bar
    required property var root

    readonly property color cyan: "#00e5ff"
    readonly property color darkBg: "#08080f"
    readonly property color hotOrange: "#FF6600"

    color: "transparent"
    anchors { top: true; left: true; right: true }
    implicitHeight: bar.root.barHeight
    exclusiveZone: bar.root.barHeight

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "omarchy-menu"

    onVisibleChanged: {
        if (visible) bar.root.calendarAnchorItem = clockSection;
    }

    Rectangle {
        anchors.fill: parent
        color: bar.darkBg
        opacity: bar.root.isIdle ? 0.85 : 1.0
        Behavior on opacity {
            NumberAnimation {
                duration: bar.root.isIdle ? 6000 : 60
                easing.type: bar.root.isIdle ? Easing.OutQuart : Easing.OutQuad
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: bar.cyan
            opacity: 0.25
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 0

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "ssh@root"
                color: bar.cyan
                opacity: 0.6
                font.family: bar.root.mono
                font.pixelSize: 14
                font.letterSpacing: 2
                font.weight: Font.Medium
            }

            Item { Layout.preferredWidth: 8 }

            Module {
                root: bar.root
                glyph: bar.root.icoOmarchy
                tooltip: "Menu"
                color: bar.cyan
                fontFamily: "omarchy"
                fontSize: 15
                onActivated: bar.root.paletteToggleRequested()
                onRightActivated: bar.root.run("xdg-terminal-exec")
            }

            Item { Layout.preferredWidth: 8 }

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 1; height: 10
                color: bar.cyan; opacity: 0.2
            }

            Item { Layout.preferredWidth: 10 }

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 3

                Repeater {
                    model: 10
                    delegate: HexWorkspace {
                        required property int index
                        root: bar.root
                        wsId: index + 1
                        label: String(index + 1)
                        accentColor: bar.cyan
                        activeTextColor: bar.darkBg
                        active: bar.root.activeWs === (index + 1)
                        present: bar.root.existingWs.indexOf(index + 1) !== -1
                        onActivated: bar.root.run("hyprctl dispatch workspace " + (index + 1))
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Item {
                id: clockSection
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: clockRow.implicitWidth + 16
                implicitHeight: clockRow.implicitHeight + 8
                z: 10

                Row {
                    id: clockRow
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: bar.root.hh + ":" + bar.root.mm
                        color: clockMouse.containsMouse ? bar.cyan : "#c8d0dc"
                        font.family: bar.root.mono
                        font.pixelSize: 14
                        font.letterSpacing: 2
                        font.weight: Font.Medium
                        Behavior on color { ColorAnimation { duration: 180 } }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 5; height: 5; radius: 2.5
                        color: bar.cyan

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.3; duration: 2000; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 0.3; to: 1.0; duration: 2000; easing.type: Easing.InOutSine }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            bar.root.dd; bar.root.mon;
                            const days = ["SUN","MON","TUE","WED","THU","FRI","SAT"];
                            const d = new Date();
                            return days[d.getDay()] + " " + bar.root.dd + " " + bar.root.mon;
                        }
                        color: clockMouse.containsMouse ? bar.cyan : "#c8d0dc"
                        font.family: bar.root.mono
                        font.pixelSize: 14
                        font.letterSpacing: 1.5
                        font.weight: Font.Medium
                        Behavior on color { ColorAnimation { duration: 180 } }
                    }
                }

                MouseArea {
                    id: clockMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (bar.root.calendarVisible) bar.root.calendarVisible = false;
                        else bar.root.openCalendar();
                    }
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 14

                Item {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: cpuRow.width
                    Layout.preferredHeight: bar.root.barHeight
                    Row {
                        id: cpuRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "CPU"
                            color: bar.cyan; opacity: 0.5
                            font.family: bar.root.mono; font.pixelSize: 9
                            font.letterSpacing: 1
                        }
                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            Repeater {
                                model: 5
                                Rectangle {
                                    required property int index
                                    width: 4; height: 10; radius: 1
                                    color: {
                                        const filled = Math.round(bar.root.cpuVal / 20);
                                        if (index < filled)
                                            return bar.root.cpuVal > 80 ? bar.root.seal : bar.cyan;
                                        return Qt.rgba(bar.cyan.r, bar.cyan.g, bar.cyan.b, 0.1);
                                    }
                                    Behavior on color { ColorAnimation { duration: 300 } }
                                }
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: bar.root.run("omarchy-launch-or-focus-tui btop")
                    }
                }

                Item {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: memRow.width
                    Layout.preferredHeight: bar.root.barHeight
                    Row {
                        id: memRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "MEM"
                            color: bar.cyan; opacity: 0.5
                            font.family: bar.root.mono; font.pixelSize: 9
                            font.letterSpacing: 1
                        }
                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            Repeater {
                                model: 5
                                Rectangle {
                                    required property int index
                                    width: 4; height: 10; radius: 1
                                    color: {
                                        const filled = Math.round(bar.root.memVal / 20);
                                        if (index < filled)
                                            return bar.root.memVal > 85 ? bar.root.seal : bar.cyan;
                                        return Qt.rgba(bar.cyan.r, bar.cyan.g, bar.cyan.b, 0.1);
                                    }
                                    Behavior on color { ColorAnimation { duration: 300 } }
                                }
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: bar.root.run("omarchy-launch-or-focus-tui btop")
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    width: 1; height: 10
                    color: bar.cyan; opacity: 0.15
                }

                Module {
                    root: bar.root
                    glyph: bar.root.btIcon
                    tooltip: {
                        if (!bar.root.btPowered) return "Bluetooth off";
                        return bar.root.btCount > 0
                            ? "Bluetooth · " + bar.root.btCount + " connected"
                            : "Bluetooth on";
                    }
                    color: bar.cyan
                    onActivated: bar.root.run("omarchy-launch-bluetooth")
                }

                Module {
                    root: bar.root
                    glyph: bar.root.netIcon
                    tooltip: {
                        if (bar.root.netKind === "eth") return "Ethernet";
                        if (bar.root.netKind === "wifi") {
                            const name = bar.root.wifiSsid || "(hidden)";
                            return "Wi-Fi · " + name + " · " + bar.root.wifiSignal + "%";
                        }
                        return "Offline";
                    }
                    onActivated: bar.root.run("omarchy-launch-wifi")
                }

                Module {
                    root: bar.root
                    glyph: bar.root.audioDeviceType === "headset"
                           ? bar.root.icoHeadset
                           : bar.root.audioIcon
                    tooltip: {
                        const dev = bar.root.audioDeviceType === "headset" ? "Headset" : "Speaker";
                        if (bar.root.audioMuted) return dev + " muted · " + bar.root.audioVol + "%";
                        return dev + " " + bar.root.audioVol + "%";
                    }
                    color: bar.root.audioMuted ? "#505868" : bar.cyan
                    onActivated: bar.root.run("omarchy-launch-audio")
                    onRightActivated: bar.root.run("pamixer -t")
                }

                Module {
                    root: bar.root
                    glyph: bar.root.batteryIcon()
                    tooltip: {
                        let s = "Battery " + bar.root.batVal + "%";
                        if (bar.root.batPower >= 0.05) {
                            const sign = bar.root.batState === "Charging" ? "+"
                                       : bar.root.batState === "Discharging" ? "-"
                                       : "";
                            s += "  " + sign + bar.root.batPower.toFixed(1) + " W";
                        }
                        return s;
                    }
                    color: bar.root.batVal <= 10 ? bar.root.seal
                         : bar.root.batVal <= 20 ? bar.root.indigo
                         : bar.cyan
                    onActivated: bar.root.run("omarchy-menu power")
                }
            }

            Item { Layout.preferredWidth: 10 }

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 1; height: 10
                color: bar.cyan; opacity: 0.2
            }

            Item { Layout.preferredWidth: 14 }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "@sublevel4"
                color: bar.hotOrange
                opacity: 0.9
                font.family: bar.root.mono
                font.pixelSize: 14
                font.letterSpacing: 2
                font.weight: Font.Bold
            }
        }
    }
}
