import QtQuick
import QtQuick.Layouts

Item {
    id: wsCell
    required property var root

    property int wsId: 0
    property string label: ""
    property bool active: false
    property bool present: false
    signal activated()

    Layout.alignment: root.isHorizontal ? Qt.AlignVCenter : Qt.AlignHCenter
    Layout.preferredWidth:  root.isHorizontal ? 20 : root.barHeight
    Layout.preferredHeight: root.isHorizontal ? root.barHeight : 20

    onActiveChanged: {
        if (active && root.lastDirection !== 0) {
            slideHome.stop();
            if (root.isHorizontal) {
                kanji.slideX = root.lastDirection * 2;
                kanji.slideY = 0;
            } else {
                kanji.slideY = root.lastDirection * 2;
                kanji.slideX = 0;
            }
            slideHome.start();
        }
    }

    NumberAnimation {
        id: slideHome
        target: kanji
        properties: "slideX,slideY"
        to: 0
        duration: 180
        easing.type: Easing.OutCubic
    }

    Bloom { id: bloom; root: wsCell.root }

    Text {
        id: kanji
        property real slideX: 0
        property real slideY: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: slideX
        anchors.verticalCenter: parent.verticalCenter
        // -1 lift matches Module.qml so kanji optically align with icons.
        anchors.verticalCenterOffset: slideY - 1
        text: wsCell.label
        color: wsCell.active ? wsCell.root.seal : (wsCell.present ? wsCell.root.ink : wsCell.root.inkDeep)
        opacity: wsCell.active ? 1.0 : (wsCell.present ? 0.75 : 0.35)
        font.family: wsCell.root.wsFont
        font.pixelSize: wsCell.active ? 15 : 13
        font.weight: Font.Light
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on opacity { NumberAnimation { duration: 120 } }
        Behavior on font.pixelSize { NumberAnimation { duration: 120 } }
    }

    Rectangle {
        id: underline
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.isHorizontal ? 2 : 0
        width: root.isHorizontal ? 10 : 2
        height: root.isHorizontal ? 2 : 10
        radius: 1
        color: wsCell.root.accent
        opacity: wsCell.active ? 0.9 : 0
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

        states: State {
            when: !wsCell.root.isHorizontal
            AnchorChanges {
                target: underline
                anchors.bottom: undefined
                anchors.horizontalCenter: undefined
                anchors.left: wsCell.left
                anchors.verticalCenter: wsCell.verticalCenter
            }
            PropertyChanges { target: underline; anchors.leftMargin: 2 }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: bloom.fire(mouseX, mouseY)
        onClicked: wsCell.activated()
    }
}
