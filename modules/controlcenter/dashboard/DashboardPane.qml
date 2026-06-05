pragma ComponentBehavior: Bound

import ".."
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects

Item {
    id: root

    required property Session session

    property bool enabled: Config.dashboard.enabled ?? true
    property bool showOnHover: Config.dashboard.showOnHover ?? true
    property bool showBongocat: Config.dashboard.showBongocat ?? true
    property int mediaUpdateInterval: GlobalConfig.dashboard.mediaUpdateInterval ?? 500
    property int dragThreshold: Config.dashboard.dragThreshold ?? 50

    function saveConfig() {
        GlobalConfig.dashboard.enabled = root.enabled;
        GlobalConfig.dashboard.showOnHover = root.showOnHover;
        GlobalConfig.dashboard.showBongocat = root.showBongocat;
        GlobalConfig.dashboard.mediaUpdateInterval = root.mediaUpdateInterval;
        GlobalConfig.dashboard.dragThreshold = root.dragThreshold;
    }

    anchors.fill: parent

    ClippingRectangle {
        id: dashboardClippingRect

        anchors.fill: parent
        anchors.margins: Tokens.padding.normal
        anchors.leftMargin: 0
        anchors.rightMargin: Tokens.padding.normal

        radius: dashboardBorder.innerRadius
        color: "transparent"

        StyledFlickable {
            id: dashboardFlickable

            anchors.fill: parent
            anchors.margins: Tokens.padding.large + Tokens.padding.normal
            anchors.leftMargin: Tokens.padding.large
            anchors.rightMargin: Tokens.padding.large

            flickableDirection: Flickable.VerticalFlick
            contentHeight: dashboardLayout.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: dashboardFlickable
            }

            ColumnLayout {
                id: dashboardLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                spacing: Tokens.spacing.normal

                StyledText {
                    text: qsTr("Media Dashboard")
                    font.pointSize: Tokens.font.size.large
                    font.weight: 500
                }

                GeneralSection {
                    rootItem: root
                }
            }
        }
    }

    InnerBorder {
        id: dashboardBorder

        leftThickness: 0
        rightThickness: Tokens.padding.normal
    }
}
