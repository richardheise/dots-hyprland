import QtQuick
import QtTest
import Quickshell.Services.UPower
import qs.services
import "horizontal" as Horizontal
import "vertical" as Vertical

TestCase {
    id: tests
    name: "ChargingIndicator"
    width: 200
    height: 100
    visible: true
    when: windowShown

    Component { id: horizontalComponent; Horizontal.Indicator {} }
    Component { id: verticalComponent; Vertical.Indicator {} }

    function init() {
        UPower.onBattery = true
        UPower.displayDevice.state = UPowerDeviceState.Discharging
        UPower.displayDevice.percentage = 0.6
    }

    function test_powerSource_data() {
        return [
            { tag: "discharging", onBattery: true, state: UPowerDeviceState.Discharging, percentage: 0.6, plugged: false, icon: "power" },
            { tag: "charging", onBattery: false, state: UPowerDeviceState.Charging, percentage: 0.6, plugged: true, icon: "bolt" },
            { tag: "fully-charged", onBattery: false, state: UPowerDeviceState.FullyCharged, percentage: 1, plugged: true, icon: "power" },
            { tag: "charge-limited", onBattery: false, state: UPowerDeviceState.PendingCharge, percentage: 0.8, plugged: true, icon: "power" },
            { tag: "charging-at-100", onBattery: false, state: UPowerDeviceState.Charging, percentage: 1, plugged: true, icon: "bolt" },
            { tag: "ac-with-unknown-charge-state", onBattery: false, state: UPowerDeviceState.Unknown, percentage: 0.6, plugged: true, icon: "power" },
            { tag: "unplugged-at-100", onBattery: true, state: UPowerDeviceState.FullyCharged, percentage: 1, plugged: false, icon: "power" },
        ]
    }

    function test_powerSource(data) {
        UPower.displayDevice.state = data.state
        UPower.displayDevice.percentage = data.percentage
        UPower.onBattery = data.onBattery
        compare(Battery.isPluggedIn, data.plugged)
        compare(Battery.isCharging, data.state === UPowerDeviceState.Charging)
        const horizontal = createTemporaryObject(horizontalComponent, tests)
        verify(horizontal !== null)
        const icon = findChild(horizontal, "powerSourceIcon")
        verify(icon !== null)
        compare(icon.visible, data.plugged)
        compare(icon.text, data.icon)
        verify(horizontal.implicitWidth >= 30)
        const vertical = createTemporaryObject(verticalComponent, tests)
        verify(vertical !== null)
        const verticalIcon = findChild(vertical, "powerSourceIcon")
        verify(verticalIcon !== null)
        compare(verticalIcon.text, data.plugged ? data.icon : "battery_android_full")
    }

    function test_plugUnplugUpdatesExistingIndicator() {
        const horizontal = createTemporaryObject(horizontalComponent, tests)
        const icon = findChild(horizontal, "powerSourceIcon")
        compare(icon.visible, false)
        UPower.onBattery = false
        compare(icon.visible, true)
        compare(icon.text, "power")
        UPower.displayDevice.state = UPowerDeviceState.Charging
        compare(icon.text, "bolt")
        UPower.displayDevice.state = UPowerDeviceState.FullyCharged
        UPower.displayDevice.percentage = 1
        compare(icon.visible, true)
        compare(icon.text, "power")
        UPower.onBattery = true
        compare(icon.visible, false)
    }
}
