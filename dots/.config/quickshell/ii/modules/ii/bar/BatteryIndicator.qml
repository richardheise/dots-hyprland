import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property bool borderless: Config.options.bar.borderless
    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isLow: percentage <= Config.options.battery.low / 100

    implicitWidth: indicatorRow.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    RowLayout {
        id: indicatorRow
        anchors.centerIn: parent
        spacing: 4

        MaterialSymbol {
            objectName: "powerSourceIcon"
            Layout.alignment: Qt.AlignVCenter
            fill: 1
            text: root.isCharging ? "bolt" : "power"
            iconSize: Appearance.font.pixelSize.normal
            visible: root.isPluggedIn
        }

        ClippedProgressBar {
            id: batteryProgress
            Layout.alignment: Qt.AlignVCenter
            value: root.percentage
            highlightColor: (root.isLow && !root.isCharging) ? Appearance.m3colors.m3error : Appearance.colors.colOnSecondaryContainer
        }
    }

    BatteryPopup {
        id: batteryPopup
        hoverTarget: root
    }
}
