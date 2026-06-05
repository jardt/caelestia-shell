pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components

Item {
    id: root

    required property DrawerVisibilities visibilities
    readonly property bool needsKeyboard: (content.item as Content)?.needsKeyboard ?? false
    readonly property real nonAnimHeight: state === "visible" ? ((content.item as Content)?.nonAnimHeight ?? 0) : 0
    readonly property bool shouldBeActive: visibilities.dashboard && Config.dashboard.enabled
    property real offsetScale: shouldBeActive ? 0 : 1

    visible: offsetScale < 1
    anchors.topMargin: (-implicitHeight - 5) * offsetScale
    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth || 640
    opacity: 1 - offsetScale

    Behavior on offsetScale {
        Anim {
            type: Anim.DefaultSpatial
        }
    }

    Loader {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        active: root.shouldBeActive || root.visible

        sourceComponent: Content {
            visibilities: root.visibilities
        }
    }
}
