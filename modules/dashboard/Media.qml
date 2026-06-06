pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.components.controls
import qs.services
import qs.utils

Item {
    id: root

    required property DrawerVisibilities visibilities
    readonly property bool needsKeyboard: false

    readonly property real nonAnimHeight: Math.max(cover.implicitHeight, details.implicitHeight, Config.dashboard.showBongocat ? bongocat.implicitHeight : 0) + Tokens.padding.large * 2

    property real playerProgress: {
        const active = Players.active;
        return active?.length ? (active.position % active.length) / active.length : 0;
    }

    function lengthStr(length: int): string {
        if (length < 0)
            return "-1:-1";

        const hours = Math.floor(length / 3600);
        const mins = Math.floor((length % 3600) / 60);
        const secs = Math.floor(length % 60).toString().padStart(2, "0");

        if (hours > 0)
            return `${hours}:${mins.toString().padStart(2, "0")}:${secs}`;
        return `${mins}:${secs}`;
    }

    implicitWidth: cover.implicitWidth + details.implicitWidth + details.anchors.leftMargin + (Config.dashboard.showBongocat ? bongocat.implicitWidth + bongocat.anchors.leftMargin * 2 : 0) + Tokens.padding.large * 2
    implicitHeight: nonAnimHeight

    Behavior on implicitHeight {
        Anim {}
    }

    Behavior on playerProgress {
        Anim {
            type: Anim.StandardLarge
        }
    }

    Timer {
        running: Players.active?.isPlaying ?? false
        interval: GlobalConfig.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: {
            if (!Players.active)
                return;
            Players.active?.positionChanged();
        }
    }

    StyledClippingRect {
        id: cover

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Tokens.padding.large

        implicitWidth: Tokens.sizes.dashboard.mediaCoverArtSize
        implicitHeight: Tokens.sizes.dashboard.mediaCoverArtSize

        color: Colours.tPalette.m3surfaceContainerHigh
        radius: Infinity

        MaterialIcon {
            anchors.centerIn: parent

            grade: 200
            text: "art_track"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: (parent.width * 0.4) || 1
        }

        Image {
            id: image

            anchors.fill: parent

            source: Players.getArtUrl(Players.active)
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            sourceSize: {
                const dpr = (QsWindow.window as QsWindow)?.devicePixelRatio ?? 1;
                return Qt.size(width * dpr, height * dpr);
            }
        }
    }

    ColumnLayout {
        id: details

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: cover.right
        anchors.leftMargin: Tokens.spacing.normal

        spacing: Tokens.spacing.small

        StyledText {
            id: title

            Layout.fillWidth: true
            Layout.maximumWidth: parent.implicitWidth

            animate: true
            horizontalAlignment: Text.AlignHCenter
            text: (Players.active?.trackTitle ?? qsTr("No media")) || qsTr("Unknown title")
            color: Players.active ? Colours.palette.m3primary : Colours.palette.m3onSurface
            font.pointSize: Tokens.font.size.normal
            elide: Text.ElideRight
        }

        StyledText {
            id: album

            Layout.fillWidth: true
            Layout.maximumWidth: parent.implicitWidth

            animate: true
            horizontalAlignment: Text.AlignHCenter
            visible: !!Players.active
            text: Players.active?.trackAlbum || qsTr("Unknown album")
            color: Colours.palette.m3outline
            font.pointSize: Tokens.font.size.small
            elide: Text.ElideRight
        }

        StyledText {
            id: artist

            Layout.fillWidth: true
            Layout.maximumWidth: parent.implicitWidth

            animate: true
            horizontalAlignment: Text.AlignHCenter
            text: (Players.active?.trackArtist ?? qsTr("Play some music for stuff to show up here!")) || qsTr("Unknown artist")
            color: Players.active ? Colours.palette.m3secondary : Colours.palette.m3outline
            elide: Text.ElideRight
            wrapMode: Players.active ? Text.NoWrap : Text.WordWrap
        }

        RowLayout {
            id: controls

            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Tokens.spacing.small
            Layout.bottomMargin: Tokens.spacing.smaller

            spacing: Tokens.spacing.small

            PlayerControl {
                type: IconButton.Text
                icon: Players.active?.shuffle ? "shuffle_on" : "shuffle"
                font.pointSize: Math.round(Tokens.font.size.large)
                disabled: !Players.active?.shuffleSupported
                onClicked: Players.active.shuffle = !Players.active?.shuffle
            }

            PlayerControl {
                type: IconButton.Text
                icon: "skip_previous"
                font.pointSize: Math.round(Tokens.font.size.large * 1.5)
                disabled: !Players.active?.canGoPrevious
                onClicked: Players.active?.previous()
            }

            PlayerControl {
                icon: Players.active?.isPlaying ? "pause" : "play_arrow"
                label.animate: true
                toggle: true
                padding: Tokens.padding.small / 2
                checked: Players.active?.isPlaying ?? false
                font.pointSize: Math.round(Tokens.font.size.large * 1.5)
                disabled: !Players.active?.canTogglePlaying
                onClicked: Players.active?.togglePlaying()
            }

            PlayerControl {
                type: IconButton.Text
                icon: "skip_next"
                font.pointSize: Math.round(Tokens.font.size.large * 1.5)
                disabled: !Players.active?.canGoNext
                onClicked: Players.active?.next()
            }
        }

        StyledSlider {
            id: slider

            enabled: !!Players.active
            implicitWidth: 280
            implicitHeight: Tokens.padding.normal * 3

            onMoved: {
                const active = Players.active;
                if (active?.canSeek && active?.positionSupported)
                    active.position = value * active.length;
            }

            Binding {
                target: slider
                property: "value"
                value: root.playerProgress
                when: !slider.pressed
            }

            CustomMouseArea {
                function onWheel(event: WheelEvent) {
                    const active = Players.active;
                    if (!active?.canSeek || !active?.positionSupported)
                        return;

                    event.accepted = true;
                    const delta = event.angleDelta.y > 0 ? 10 : -10;    // Time 10 seconds
                    Qt.callLater(() => {
                        active.position = Math.max(0, Math.min(active.length, active.position + delta));
                    });
                }

                anchors.fill: parent
                acceptedButtons: Qt.NoButton
            }
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: Math.max(position.implicitHeight, length.implicitHeight)

            StyledText {
                id: position

                anchors.left: parent.left

                text: root.lengthStr(Players.active ? Players.active.position % Players.active.length : -1)
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.small
            }

            StyledText {
                id: length

                anchors.right: parent.right

                text: root.lengthStr(Players.active?.length ?? -1)
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Tokens.font.size.small
            }
        }
    }

    ColumnLayout {
        id: leftSection

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: details.right
        anchors.leftMargin: Tokens.spacing.normal

        visible: Config.dashboard.showBongocat
        opacity: Config.dashboard.showBongocat ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Tokens.anim.durations.normal
                easing.type: Easing.OutCubic
            }
        }

        Item {
            id: bongocat

            implicitWidth: Config.dashboard.showBongocat ? cover.width : 0
            implicitHeight: Config.dashboard.showBongocat ? cover.height : 0

            AnimatedImage {
                anchors.centerIn: parent

                width: cover.width * 0.75
                height: cover.height * 0.75

                playing: Players.active?.isPlaying ?? false
                speed: 1
                source: Paths.absolutePath(Config.paths.mediaGif)
                asynchronous: true
                fillMode: AnimatedImage.PreserveAspectFit
            }
        }
    }

    RowLayout {
        id: playerChanger

        parent: details
        Layout.alignment: Qt.AlignHCenter
        spacing: Tokens.spacing.small

        PlayerControl {
            type: IconButton.Text
            icon: "move_up"
            inactiveOnColour: Colours.palette.m3secondary
            padding: Tokens.padding.small
            font.pointSize: Tokens.font.size.large
            disabled: !Players.active?.canRaise
            onClicked: {
                Players.active?.raise();
                root.visibilities.dashboard = false;
            }
        }

        SplitButton {
            id: playerSelector

            disabled: !Players.list.length
            active: menuItems.find(m => m.modelData === Players.active) ?? menuItems[0] ?? null
            menu.onItemSelected: item => Players.manualActive = (item as PlayerItem).modelData

            menuItems: playerList.instances
            fallbackIcon: "music_off"
            fallbackText: qsTr("No players")

            label.Layout.maximumWidth: slider.implicitWidth * 0.28
            label.elide: Text.ElideRight

            stateLayer.disabled: true
            menuOnTop: true

            Variants {
                id: playerList

                model: Players.list

                PlayerItem {}
            }
        }

        PlayerControl {
            type: IconButton.Text
            icon: "delete"
            inactiveOnColour: Colours.palette.m3error
            padding: Tokens.padding.small
            font.pointSize: Tokens.font.size.large
            disabled: !Players.active?.canQuit
            onClicked: Players.active?.quit()
        }
    }

    component PlayerItem: MenuItem {
        required property MprisPlayer modelData

        icon: modelData === Players.active ? "check" : ""
        text: Players.getIdentity(modelData)
        activeIcon: "animated_images"
    }

    component PlayerControl: IconButton {
        Layout.preferredWidth: implicitWidth + (stateLayer.pressed ? Tokens.padding.large : internalChecked ? Tokens.padding.smaller : 0)
        radius: stateLayer.pressed ? Tokens.rounding.small / 2 : internalChecked ? Tokens.rounding.small : implicitHeight / 2
        radiusAnim.duration: Tokens.anim.durations.expressiveFastSpatial
        radiusAnim.easing: Tokens.anim.expressiveFastSpatial

        Behavior on Layout.preferredWidth {
            Anim {
                type: Anim.FastSpatial
            }
        }
    }
}
