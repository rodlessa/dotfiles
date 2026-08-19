//
// shell.qml — Quickshell entry point
// Reproduces the Waybar bar (workspaces, window title, clock, exchange rate,
// pulseaudio/pipewire, network, cpu, memory, temperature, tray) as a floating
// bar on DP-3, Catppuccin Mocha palette.
//
// Install: ~/.config/quickshell/shell.qml
// Run:     quickshell
// Autostart from hyprland.lua: hl.exec_cmd("quickshell") inside your
//   hl.on("hyprland.start", ...) block, replacing the waybar line.
//
// NOTE: cpu/memory/network/temperature use polling Process calls (same
// mechanism Waybar used under the hood) rather than a native Quickshell
// service, since Quickshell doesn't ship one for those. Workspaces/window
// and audio use real Quickshell services (Hyprland, Pipewire) which are
// event-driven, not polled.

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    // ---- Theme (Catppuccin Mocha, matching your style.css) ----
    readonly property color colBg: "#1e1e2e"      // base
    readonly property color colFg: "#cdd6f4"      // text
    readonly property color colBlue: "#89b4fa"    // accent / active border
    readonly property color colGreen: "#a6e3a1"   // exchange rate
    readonly property color colRed: "#f38ba8"     // urgent / critical
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13

    // ---- State ----
    property string clockText: ""
    property string exchangeText: "…"
    property real cpuUsage: 0
    property real memUsage: 0
    property real tempC: 0
    property string netText: "⚠ Disconnected"

    // ---- Calendar popup state ----
    readonly property var calMonthNames: ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"]
    readonly property var calMonthNamesShort: ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    property int viewYear: (new Date()).getFullYear()
    property int viewMonth: (new Date()).getMonth() // 0-based
    property string viewState: "days" // "days" | "months" | "years"
    property bool calendarPinned: false
    readonly property int calDaysInMonth: new Date(viewYear, viewMonth + 1, 0).getDate()
    readonly property int calFirstWeekday: new Date(viewYear, viewMonth, 1).getDay()
    readonly property int calYearRangeStart: Math.floor(viewYear / 12) * 12
    readonly property int todayYear: (new Date()).getFullYear()
    readonly property int todayMonth: (new Date()).getMonth()
    readonly property int todayDay: (new Date()).getDate()

    // Chevrons: step by month in day view, by year in month view, by
    // 12-year page in year view — mirrors how GTK's calendar widget behaves.
    function calNavigate(delta) {
        if (root.viewState === "years") {
            root.viewYear += delta * 12;
            return;
        }
        if (root.viewState === "months") {
            root.viewYear += delta;
            return;
        }
        let m = root.viewMonth + delta;
        let y = root.viewYear;
        if (m < 0) { m = 11; y -= 1; }
        if (m > 11) { m = 0; y += 1; }
        root.viewMonth = m;
        root.viewYear = y;
    }

    PanelWindow {
        id: bar
        // Pin to your ultrawide only. If you ever want it on both monitors,
        // swap this single PanelWindow for a Variants{model: Quickshell.screens}
        // loop like the Quickshell docs show, filtering modelData.name.
        screen: Quickshell.screens.find(s => s.name === "DP-3") ?? Quickshell.screens[0]

        anchors {
            top: true
            left: true
            right: true
        }
        // Matches your CSS: floating bar, not edge-to-edge (2560 wide,
        // centered horizontally on the 3440px monitor, 8px top margin).
        implicitHeight: 51
        margins {
            top: 8
            left: 440    // (3440 - 2560) / 2 -> centers the 2560px bar
            right: 440
        }
        color: "transparent"
        exclusiveZone: implicitHeight // reserve space like Waybar did

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0.1176, 0.1176, 0.1804, 0.9) // rgba(30,30,46,0.9)
            radius: 15
            border.color: root.colBlue
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10

                // ---------------- LEFT: workspaces + window title ----------------
                RowLayout {
                    spacing: 4
                    Repeater {
                        model: Hyprland.workspaces.values
                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool active: Hyprland.focusedWorkspace?.id === modelData.id
                            implicitWidth: label.implicitWidth + 14
                            implicitHeight: 26
                            radius: 6
                            color: "transparent"
                            border.width: active ? 2 : 0
                            border.color: root.colBlue

                            Text {
                                id: label
                                anchors.centerIn: parent
                                text: modelData.name
                                color: active ? root.colBlue : root.colFg
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize
                            }
                            MouseArea {
                                anchors.fill: parent
                                // Hyprland 0.55's Lua config no longer accepts the old
                                // "workspace <id>" string over IPC — it now expects an
                                // actual Lua dispatcher call.
                                onClicked: Hyprland.dispatch("hl.dsp.focus({workspace = " + modelData.id + "})")
                            }
                        }
                    }
                }

                Text {
                    text: Hyprland.activeToplevel?.title ?? ""
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    elide: Text.ElideRight
                    Layout.maximumWidth: 400
                }

                Item { Layout.fillWidth: true } // spacer -> pushes everything right of it to the right edge

                // ---------------- RIGHT: exchange, audio, net, cpu, mem, temp, tray ----------------
                Text {
                    text: root.exchangeText
                    color: root.colGreen
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                Text {
                    readonly property var sink: Pipewire.defaultAudioSink
                    text: {
                        if (!sink || !sink.audio) return "";
                        if (sink.audio.muted) return "";
                        return " " + Math.round(sink.audio.volume * 100) + "%";
                    }
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                Text {
                    text: root.netText
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                Text {
                    text: " " + Math.round(root.cpuUsage) + "%"
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                Text {
                    text: " " + Math.round(root.memUsage) + "%"
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                Text {
                    text: " " + root.tempC.toFixed(0) + "°C"
                    color: root.tempC >= 85 ? root.colRed : root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                RowLayout {
                    spacing: 8
                    Repeater {
                        model: SystemTray.items
                        delegate: Image {
                            required property var modelData
                            source: modelData.icon
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton && modelData.hasMenu)
                                        modelData.display();
                                    else
                                        modelData.activate();
                                }
                            }
                        }
                    }
                }
            }

            // ---------------- CENTER: clock ----------------
            // Deliberately a sibling of the RowLayout, not part of it — anchored
            // to the Rectangle's true center so it never shifts when the window
            // title or any other left/right content changes width.
            Item {
                id: clockArea
                anchors.centerIn: parent
                width: clockLabel.implicitWidth
                height: clockLabel.implicitHeight

                Text {
                    id: clockLabel
                    text: root.clockText
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                HoverHandler {
                    id: clockHover
                    onHoveredChanged: {
                        // Reset to the current month whenever the popup is
                        // freshly opened by hover (not when hovering back in
                        // from the popup itself — that's popupHover).
                        // Skip the reset if it's pinned open, so re-hovering
                        // an already-pinned calendar doesn't jump you away
                        // from wherever you navigated to.
                        if (clockHover.hovered && !root.calendarPinned) {
                            root.viewYear = root.todayYear;
                            root.viewMonth = root.todayMonth;
                            root.viewState = "days";
                        }
                    }
                }

                TapHandler {
                    onTapped: root.calendarPinned = !root.calendarPinned
                }
            }

            PopupWindow {
                id: calendarPopup
                anchor.window: bar
                anchor.rect.x: bar.width / 2 - implicitWidth / 2
                anchor.rect.y: bar.height
                implicitWidth: 260
                implicitHeight: 260
                color: "transparent"
                // Pinned (clicked) -> always visible, immune to mouse movement.
                // Not pinned -> classic hover peek, closes as soon as the
                // cursor leaves both the clock and the popup itself.
                visible: root.calendarPinned || clockHover.hovered || popupHover.hovered

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0.1176, 0.1176, 0.1804, 0.97)
                    radius: 12
                    border.color: root.colBlue
                    border.width: 2

                    HoverHandler { id: popupHover }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        // ---- Header: ‹ Month  Year › — click Month or Year to navigate ----
                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "‹"
                                color: root.colFg
                                font.pixelSize: 16
                                MouseArea { anchors.fill: parent; onClicked: root.calNavigate(-1) }
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: root.calMonthNames[root.viewMonth]
                                color: root.colBlue
                                font.family: root.fontFamily
                                font.bold: true
                                font.pixelSize: root.fontSize
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.viewState = (root.viewState === "months" ? "days" : "months")
                                }
                            }
                            Text { text: " "; color: root.colFg }
                            Text {
                                text: root.viewYear
                                color: root.colBlue
                                font.family: root.fontFamily
                                font.bold: true
                                font.pixelSize: root.fontSize
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.viewState = (root.viewState === "years" ? "days" : "years")
                                }
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "›"
                                color: root.colFg
                                font.pixelSize: 16
                                MouseArea { anchors.fill: parent; onClicked: root.calNavigate(1) }
                            }
                        }

                        // ---- Days grid ----
                        GridLayout {
                            visible: root.viewState === "days"
                            columns: 7
                            rowSpacing: 4
                            columnSpacing: 4
                            Layout.fillWidth: true

                            Repeater {
                                model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                                delegate: Text {
                                    required property var modelData
                                    text: modelData
                                    color: root.colFg
                                    opacity: 0.6
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.preferredWidth: 28
                                    font.pixelSize: 11
                                }
                            }
                            Repeater {
                                model: 42
                                delegate: Rectangle {
                                    required property int index
                                    readonly property int dayNum: index - root.calFirstWeekday + 1
                                    readonly property bool valid: dayNum >= 1 && dayNum <= root.calDaysInMonth
                                    readonly property bool isToday: valid
                                        && root.viewYear === root.todayYear
                                        && root.viewMonth === root.todayMonth
                                        && dayNum === root.todayDay
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 24
                                    radius: 4
                                    color: isToday ? root.colBlue : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: valid ? dayNum : ""
                                        color: isToday ? root.colBg : root.colFg
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        // ---- Month picker ----
                        GridLayout {
                            visible: root.viewState === "months"
                            columns: 3
                            rowSpacing: 6
                            columnSpacing: 6
                            Layout.fillWidth: true

                            Repeater {
                                model: root.calMonthNamesShort
                                delegate: Rectangle {
                                    required property var modelData
                                    required property int index
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 30
                                    radius: 6
                                    color: index === root.viewMonth ? root.colBlue : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.modelData
                                        color: parent.index === root.viewMonth ? root.colBg : root.colFg
                                        font.pixelSize: 12
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: { root.viewMonth = parent.index; root.viewState = "days"; }
                                    }
                                }
                            }
                        }

                        // ---- Year picker ----
                        GridLayout {
                            visible: root.viewState === "years"
                            columns: 4
                            rowSpacing: 6
                            columnSpacing: 6
                            Layout.fillWidth: true

                            Repeater {
                                model: 12
                                delegate: Rectangle {
                                    required property int index
                                    readonly property int yr: root.calYearRangeStart + index
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 30
                                    radius: 6
                                    color: yr === root.viewYear ? root.colBlue : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.yr
                                        color: parent.yr === root.viewYear ? root.colBg : root.colFg
                                        font.pixelSize: 12
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: { root.viewYear = parent.yr; root.viewState = "days"; }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------------- Data sources ----------------

    // Pipewire needs one of its nodes tracked to stay bound/reactive.
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    // Clock — plain QML timer, no process spawn needed.
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const d = new Date();
            root.clockText = "󰃭 " + Qt.formatDateTime(d, "dd/MM hh:mm");
        }
    }

    // Exchange rate — same script you already had, run every 10 min.
    Process {
        id: exchangeProc
        command: ["python3", Quickshell.env("HOME") + "/scripts/exchange_rate.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text);
                    root.exchangeText = data.text ?? this.text.trim();
                } catch (e) {
                    root.exchangeText = this.text.trim();
                }
            }
        }
    }
    Timer {
        interval: 600000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: exchangeProc.running = true
    }

    // CPU usage — reads /proc/stat twice, diffs it.
    property var _prevCpu: null
    Process {
        id: cpuProc
        command: ["sh", "-c", "grep '^cpu ' /proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(/\s+/).slice(1).map(Number);
                const idle = parts[3] + parts[4];
                const total = parts.reduce((a, b) => a + b, 0);
                if (root._prevCpu) {
                    const dIdle = idle - root._prevCpu.idle;
                    const dTotal = total - root._prevCpu.total;
                    root.cpuUsage = dTotal > 0 ? 100 * (1 - dIdle / dTotal) : 0;
                }
                root._prevCpu = { idle, total };
            }
        }
    }
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: cpuProc.running = true
    }

    // Memory usage — /proc/meminfo.
    Process {
        id: memProc
        command: ["sh", "-c", "grep -E '^(MemTotal|MemAvailable):' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n");
                const vals = {};
                for (const l of lines) {
                    const [k, v] = l.split(":");
                    vals[k.trim()] = parseInt(v);
                }
                if (vals.MemTotal)
                    root.memUsage = 100 * (1 - vals.MemAvailable / vals.MemTotal);
            }
        }
    }
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: memProc.running = true
    }

    // Temperature — same hwmon path as your Waybar config. If that index
    // ever drifts after a kernel update, update it here too.
    Process {
        id: tempProc
        command: ["cat", "/sys/class/hwmon/hwmon4/temp1_input"]
        stdout: StdioCollector {
            onStreamFinished: root.tempC = parseInt(this.text.trim()) / 1000
        }
    }
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: tempProc.running = true
    }

    // Network — quick nmcli check. Wifi gets a signal-strength icon tier,
    // same as the one NetworkManager's own applet/tray icon uses, instead
    // of a single static glyph.
    function wifiIcon(signal) {
        if (signal >= 80) return "󰤨";
        if (signal >= 60) return "󰤥";
        if (signal >= 40) return "󰤢";
        if (signal >= 20) return "󰤟";
        return "󰤯";
    }
    Process {
        id: netProc
        command: ["sh", "-c",
            "nmcli -t -f TYPE,STATE,CONNECTION dev status | grep -m1 ':connected:'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = this.text.trim();
                if (!line) {
                    root.netText = "󰤭 Disconnected";
                    return;
                }
                const [type, , conn] = line.split(":");
                if (type === "wifi") {
                    signalProc.running = true;
                    root._pendingConn = conn; // filled in once signalProc returns
                } else {
                    root.netText = "󰈀 " + conn;
                }
            }
        }
    }
    property string _pendingConn: ""
    Process {
        id: signalProc
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi list | grep '^\\*' | cut -d: -f2"]
        stdout: StdioCollector {
            onStreamFinished: {
                const signal = parseInt(this.text.trim()) || 0;
                root.netText = root.wifiIcon(signal) + " " + root._pendingConn;
            }
        }
    }
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netProc.running = true
    }
}
