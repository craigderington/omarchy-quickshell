import QtQuick
import QtQuick.Layouts

Item {
    id: hex
    required property var root

    property int wsId: 0
    property string label: ""
    property bool active: false
    property bool present: false
    property color accentColor: root.accent
    property color activeTextColor: root.bg
    signal activated()

    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: 22
    Layout.preferredHeight: root.barHeight

    readonly property bool hovered: mouse.containsMouse

    Canvas {
        id: hexCanvas
        anchors.centerIn: parent
        width: 20
        height: 18

        Connections {
            target: hex
            function onActiveChanged() { hexCanvas.requestPaint() }
            function onPresentChanged() { hexCanvas.requestPaint() }
            function onHoveredChanged() { hexCanvas.requestPaint() }
            function onAccentColorChanged() { hexCanvas.requestPaint() }
        }

        Connections {
            target: hex.root
            function onInkChanged() { hexCanvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var cx = width / 2, cy = height / 2, r = 8;
            ctx.beginPath();
            for (var i = 0; i < 6; i++) {
                var a = i * Math.PI / 3;
                var px = cx + r * Math.cos(a);
                var py = cy + r * Math.sin(a);
                if (i === 0) ctx.moveTo(px, py);
                else ctx.lineTo(px, py);
            }
            ctx.closePath();

            var ac = hex.accentColor;
            var ik = hex.root.ink;

            if (hex.active) {
                ctx.fillStyle = Qt.rgba(ac.r, ac.g, ac.b, 0.9);
                ctx.fill();
                ctx.strokeStyle = Qt.rgba(ac.r, ac.g, ac.b, 1);
            } else if (hex.present && hex.hovered) {
                ctx.fillStyle = Qt.rgba(ac.r, ac.g, ac.b, 0.15);
                ctx.fill();
                ctx.strokeStyle = Qt.rgba(ac.r, ac.g, ac.b, 0.6);
            } else if (hex.present) {
                ctx.strokeStyle = Qt.rgba(ac.r, ac.g, ac.b, 0.4);
            } else if (hex.hovered) {
                ctx.strokeStyle = Qt.rgba(ik.r, ik.g, ik.b, 0.2);
            } else {
                ctx.strokeStyle = Qt.rgba(ik.r, ik.g, ik.b, 0.1);
            }

            ctx.lineWidth = 1;
            ctx.stroke();
        }
    }

    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -1
        text: hex.label
        color: hex.active ? hex.activeTextColor
             : hex.present ? hex.accentColor
             : hex.root.inkDeep
        opacity: hex.active ? 1.0 : (hex.present ? 0.8 : 0.3)
        font.family: hex.root.mono
        font.pixelSize: 9
        font.weight: hex.active ? Font.Bold : Font.Medium
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: hex.activated()
    }
}
