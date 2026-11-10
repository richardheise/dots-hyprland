#!/usr/bin/env python3
"""Load the production battery service and indicators with desktop dependencies mocked."""
from pathlib import Path
import os
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[2]
source = repo / 'dots/.config/quickshell/ii'
with tempfile.TemporaryDirectory(prefix='end4-charging-test-') as directory:
    stage = Path(directory)
    def write(name, content):
        path = stage / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
    def module(name, types):
        folder = name.replace('.', '/')
        entries = [f'module {name}']
        for typename, singleton, content in types:
            entries.append(f'{"singleton " if singleton else ""}{typename} 1.0 {typename}.qml')
            write(f'{folder}/{typename}.qml', content)
        write(f'{folder}/qmldir', '\n'.join(entries) + '\n')
    module('Quickshell', [
        ('Singleton', False, 'import QtQuick\nItem {}'),
        ('Quickshell', True, 'pragma Singleton\nimport QtQml\nQtObject { function execDetached(args) {} }'),
    ])
    module('Quickshell.Io', [('IoStub', False, 'import QtQml\nQtObject {}')])
    module('Quickshell.Services.UPower', [
        ('UPowerDeviceState', True, 'pragma Singleton\nimport QtQml\nQtObject { enum State { Unknown, Charging, Discharging, Empty, FullyCharged, PendingCharge, PendingDischarge } }'),
        ('UPower', True, '''pragma Singleton
import QtQml
QtObject {
    property bool onBattery: true
    property var devices: ({ values: [] })
    property QtObject displayDevice: QtObject {
        property bool isLaptopBattery: true
        property int state: 2
        property real percentage: 0.6
        property real changeRate: 5
        property real timeToEmpty: 3600
        property real timeToFull: 3600
    }
}'''),
    ])
    module('qs.services', [
        ('Battery', True, (source / 'services/Battery.qml').read_text()),
        ('Translation', True, 'pragma Singleton\nimport QtQml\nQtObject { function tr(text) { return text } }'),
    ])
    module('qs.modules.common', [
        ('Config', True, '''pragma Singleton
import QtQml
QtObject { property var options: ({ bar: { borderless: false, tooltips: { clickToShow: false } }, battery: { automaticSuspend: false, low: 20, critical: 10, suspend: 5, full: 100 }, sounds: { battery: false } }) }'''),
        ('Appearance', True, '''pragma Singleton
import QtQml
QtObject {
    property var sizes: ({ barHeight: 32 })
    property var font: ({ pixelSize: { normal: 18, smaller: 12 } })
    property var m3colors: ({ m3error: "red" })
    property var colors: ({ colOnSecondaryContainer: "white" })
}'''),
        ('Icons', True, 'pragma Singleton\nimport QtQml\nQtObject { function getBatteryIcon(value) { return "battery_android_full" } }'),
    ])
    module('qs.modules.common.widgets', [
        ('MaterialSymbol', False, 'import QtQuick\nText { property int fill: 0; property int iconSize: 18; property bool animateChange: false; font.pixelSize: iconSize }'),
        ('StyledText', False, 'import QtQuick\nText {}'),
        ('ClippedProgressBar', False, '''import QtQuick
Item {
    property bool vertical: false
    property real valueBarWidth: 30
    property real valueBarHeight: 18
    property real value: 0
    property color highlightColor
    property font font
    property string text: Math.round(value * 100)
    default property Item textMask
    implicitWidth: valueBarWidth
    implicitHeight: valueBarHeight
}'''),
    ])
    module('qs.modules.ii.bar', [('BatteryPopup', False, 'import QtQuick\nItem { property Item hoverTarget }')])
    for folder, filename in [('horizontal', 'modules/ii/bar/BatteryIndicator.qml'), ('vertical', 'modules/ii/verticalBar/BatteryIndicator.qml')]:
        write(f'{folder}/Indicator.qml', (source / filename).read_text())
    write('horizontal/BatteryPopup.qml', 'import QtQuick\nItem { property Item hoverTarget }')
    write('tst_battery.qml', (repo / 'tests/charging-indicator/tst_battery.qml').read_text())
    env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QPA_PLATFORMTHEME='', QT_QUICK_BACKEND='software', DBUS_SESSION_BUS_ADDRESS='unix:path=/nonexistent')
    result = subprocess.run(['/usr/lib/qt6/bin/qmltestrunner', '-import', str(stage), '-input', str(stage)], env=env)
    raise SystemExit(result.returncode)
