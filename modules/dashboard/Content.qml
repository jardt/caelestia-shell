pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components

Item {
    id: root

    required property DrawerVisibilities visibilities
    readonly property bool needsKeyboard: media.needsKeyboard
    readonly property real nonAnimWidth: media.implicitWidth + Tokens.padding.large * 2
    readonly property real nonAnimHeight: media.implicitHeight + Tokens.padding.large * 2

    implicitWidth: nonAnimWidth
    implicitHeight: nonAnimHeight

    MediaWrapper {
        id: media

        visibilities: root.visibilities
        anchors.centerIn: parent
    }

    Behavior on implicitWidth {
        Anim {
            type: Anim.EmphasizedLarge
        }
    }

    Behavior on implicitHeight {
        Anim {
            type: Anim.EmphasizedLarge
        }
    }
}
