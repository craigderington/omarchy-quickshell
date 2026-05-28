import QtQuick
import QtQuick.Effects
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
    Layout.preferredWidth:  root.isHorizontal ? 24 : root.barHeight
    Layout.preferredHeight: root.isHorizontal ? root.barHeight : 24

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
        if (active) glowPulse.restart();
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

    // Ghost layer: accent-colored duplicate fed into MultiEffect blur
    // to produce the HUD halo. Sits behind the crisp kanji text.
    Text {
        id: ghost
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: kanji.slideX
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: kanji.slideY - 1
        text: wsCell.label
        color: wsCell.root.accent
        opacity: 0
        font.family: wsCell.root.wsFont
        font.pixelSize: kanji.font.pixelSize
        font.weight: Font.Light
        layer.enabled: wsCell.active || wsCell.present
        visible: false
    }

    MultiEffect {
        id: glow
        anchors.fill: ghost
        anchors.margins: -glowRadius
        source: ghost
        visible: wsCell.active || wsCell.present
        blurEnabled: true
        blur: 1.0
        blurMax: glowRadius
        opacity: wsCell.active ? glowOpacity : (wsCell.present ? glowOpacity * 0.4 : 0)
        property real glowRadius: wsCell.active ? 12 : 6
        property real glowOpacity: 0.8

        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on glowRadius { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
    }

    // Activation pulse: briefly flares the glow then settles.
    SequentialAnimation {
        id: glowPulse
        NumberAnimation {
            target: glow; property: "glowOpacity"
            from: 1.0; to: 0.8
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Text {
        id: kanji
        property real slideX: 0
        property real slideY: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: slideX
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: slideY - 1
        text: wsCell.label
        color: wsCell.active  ? wsCell.root.accent
             : wsCell.present ? Qt.rgba(wsCell.root.accent.r, wsCell.root.accent.g, wsCell.root.accent.b, 0.7)
             : wsCell.root.inkDeep
        opacity: wsCell.active ? 1.0 : (wsCell.present ? 0.75 : 0.35)
        font.family: wsCell.root.wsFont
        font.pixelSize: wsCell.active ? 15 : 13
        font.weight: Font.Light
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on opacity { NumberAnimation { duration: 120 } }
        Behavior on font.pixelSize { NumberAnimation { duration: 120 } }
    }

    // Active indicator: thin accent underline beneath the glyph.
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
    }

    // Vertical bar: indicator sits on the leading edge instead.
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

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: bloom.fire(mouseX, mouseY)
        onClicked: wsCell.activated()
    }
}
