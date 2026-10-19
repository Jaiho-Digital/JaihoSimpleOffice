import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: window
    width: 1100
    height: 740
    minimumWidth: 850
    minimumHeight: 620
    visible: true
    title: "Jaiho SimpleFocus"
    color: darkTheme ? "#1d211e" : "#f2efe6"

    property bool darkTheme: focusController.darkTheme
    property color ink: darkTheme ? "#f3f0e7" : "#252b25"
    property color muted: darkTheme ? "#a6ada3" : "#777d72"
    property color surface: darkTheme ? "#282d28" : "#fffdf8"
    property color surfaceAlt: darkTheme ? "#323830" : "#e9e7dc"
    property color borderColor: darkTheme ? "#414940" : "#e3dfd3"
    property color accent: darkTheme ? "#9bb391" : "#647d5d"
    property color accentText: "#ffffff"

    component ActionButton: Button {
        id: control
        property color fillColor: window.surface
        property color labelColor: window.ink
        implicitHeight: 44
        implicitWidth: Math.max(88, contentItem.implicitWidth + 30)
        font.pixelSize: 13
        font.weight: Font.Medium

        contentItem: Text {
            text: control.text
            color: control.labelColor
            font: control.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            radius: 12
            color: control.down ? Qt.darker(control.fillColor, 1.08)
                 : control.hovered ? Qt.lighter(control.fillColor, 1.035)
                 : control.fillColor
            border.width: 1
            border.color: window.borderColor
        }
    }

    component Eyebrow: Text {
        color: window.muted
        font.pixelSize: 10
        font.weight: Font.DemiBold
        font.letterSpacing: 1.7
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18

        // Brand header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: 15
                color: window.accent
                Text {
                    anchors.centerIn: parent
                    text: "j."
                    color: "#ffffff"
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                }
            }

            ColumnLayout {
                spacing: 3
                Text {
                    text: "JAIHO  /  SIMPLEFOCUS"
                    color: window.ink
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    font.letterSpacing: 1.1
                }
                Text {
                    text: "Make room for what matters."
                    color: window.muted
                    font.pixelSize: 12
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: statusLabel.implicitWidth + 24
                Layout.preferredHeight: 32
                radius: 16
                color: focusController.running ? window.surfaceAlt : window.surface
                border.color: window.borderColor

                Row {
                    anchors.centerIn: parent
                    spacing: 7
                    Rectangle {
                        width: 7
                        height: 7
                        radius: 4
                        anchors.verticalCenter: parent.verticalCenter
                        color: focusController.running ? window.accent : window.muted
                    }
                    Text {
                        id: statusLabel
                        text: focusController.running ? "IN SESSION" : "READY"
                        color: window.ink
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.8
                    }
                }
            }

            ActionButton {
                text: window.darkTheme ? "☼  Light" : "◐  Dark"
                onClicked: focusController.darkTheme = !focusController.darkTheme
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: window.borderColor
        }

        // Main workspace
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 18

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 480
                radius: 25
                color: window.surface
                border.color: window.borderColor
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true
                        Eyebrow { text: "YOUR FOCUS SPACE" }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: focusController.focusMode ? "01  /  FOCUS" : "02  /  BREAK"
                            color: window.muted
                            font.pixelSize: 10
                            font.letterSpacing: 0.8
                        }
                    }

                    // Mode selector
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 240
                        Layout.preferredHeight: 42
                        radius: 14
                        color: window.darkTheme ? "#202520" : "#f0eee6"
                        border.color: window.borderColor

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 4

                            Button {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: "Focus"
                                onClicked: focusController.setMode(true)
                                contentItem: Text {
                                    text: parent.text
                                    color: focusController.focusMode ? "#ffffff" : window.muted
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    radius: 10
                                    color: focusController.focusMode ? window.accent : "transparent"
                                }
                            }

                            Button {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: "Short break"
                                onClicked: focusController.setMode(false)
                                contentItem: Text {
                                    text: parent.text
                                    color: !focusController.focusMode ? "#ffffff" : window.muted
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    radius: 10
                                    color: !focusController.focusMode ? window.accent : "transparent"
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true; Layout.minimumHeight: 2 }

                    // Circular timer with visible progress
                    Item {
                        id: timerDial
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.min(270, parent.width * 0.66)
                        Layout.preferredHeight: Layout.preferredWidth
                        property real progress: {
                            var total = focusController.focusMode ? 1500 : 300
                            return Math.max(0, Math.min(1,
                                1 - focusController.remainingSeconds / total))
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: window.darkTheme ? "#222722" : "#f8f6ef"
                            border.color: window.borderColor
                            border.width: 1
                        }

                        Canvas {
                            id: progressCanvas
                            anchors.fill: parent
                            rotation: -90
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var cx = width / 2
                                var cy = height / 2
                                var r = Math.min(width, height) / 2 - 10

                                ctx.beginPath()
                                ctx.arc(cx, cy, r, 0, Math.PI * 2)
                                ctx.strokeStyle = window.darkTheme ? "#414940" : "#e4e1d7"
                                ctx.lineWidth = 7
                                ctx.stroke()

                                if (timerDial.progress > 0) {
                                    ctx.beginPath()
                                    ctx.arc(cx, cy, r, 0,
                                            Math.PI * 2 * timerDial.progress)
                                    ctx.strokeStyle = window.accent
                                    ctx.lineWidth = 7
                                    ctx.lineCap = "round"
                                    ctx.stroke()
                                }
                            }

                            Connections {
                                target: focusController
                                function onChanged() { progressCanvas.requestPaint() }
                            }
                            Connections {
                                target: window
                                function onDarkThemeChanged() { progressCanvas.requestPaint() }
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: focusController.focusMode ? "TIME TO FOCUS" : "SLOW DOWN"
                                color: window.muted
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                font.letterSpacing: 1.8
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: {
                                    var m = Math.floor(focusController.remainingSeconds / 60)
                                    var s = focusController.remainingSeconds % 60
                                    return (m < 10 ? "0" : "") + m + ":"
                                         + (s < 10 ? "0" : "") + s
                                }
                                color: window.ink
                                font.family: "Segoe UI"
                                font.pixelSize: 51
                                font.weight: Font.Light
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: focusController.running
                                      ? "Stay with this one thing."
                                      : "A little space to think."
                                color: window.muted
                                font.pixelSize: 12
                            }
                        }
                    }

                    Item { Layout.fillHeight: true; Layout.minimumHeight: 2 }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10

                        ActionButton {
                            text: "↺  Reset"
                            onClicked: focusController.resetTimer()
                        }

                        Button {
                            Layout.preferredWidth: 190
                            Layout.preferredHeight: 48
                            text: focusController.running ? "Ⅱ   Pause session" : "▶   Start focusing"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: 14
                                color: parent.down ? Qt.darker(window.accent, 1.12)
                                                   : window.accent
                            }
                            onClicked: focusController.toggleTimer()
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "25 min focus    ·    5 min break"
                        color: window.muted
                        font.pixelSize: 11
                    }

                    Item { Layout.preferredHeight: 2 }
                }
            }

            // Intention and daily stats
            ColumnLayout {
                Layout.preferredWidth: 270
                Layout.maximumWidth: 310
                Layout.fillHeight: true
                spacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    color: window.surface
                    radius: 22
                    border.color: window.borderColor
                    implicitHeight: intentionColumn.implicitHeight + 36

                    ColumnLayout {
                        id: intentionColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 18
                        spacing: 12

                        Text {
                            text: "A little intention"
                            color: window.ink
                            font.pixelSize: 19
                            font.weight: Font.Medium
                        }

                        Text {
                            text: "What deserves your attention today?"
                            color: window.muted
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        TextField {
                            Layout.fillWidth: true
                            placeholderText: "One thing at a time..."
                            text: focusController.taskTitle
                            onTextEdited: focusController.taskTitle = text
                            color: window.ink
                            font.pixelSize: 13
                            leftPadding: 12
                            rightPadding: 12
                            implicitHeight: 42
                            background: Rectangle {
                                radius: 11
                                color: window.darkTheme ? "#202520" : "#f7f4ec"
                                border.color: parent.activeFocus ? window.accent : window.borderColor
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: window.borderColor
                        }

                        Eyebrow { text: "TODAY, SO FAR" }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 9

                            Repeater {
                                model: [
                                    { label: "Sessions", value: focusController.completedSessions },
                                    { label: "Minutes", value: focusController.focusedMinutes }
                                ]
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 84
                                    radius: 15
                                    color: window.surfaceAlt

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 5
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: modelData.value
                                            color: window.ink
                                            font.pixelSize: 25
                                            font.weight: Font.Medium
                                        }
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: modelData.label
                                            color: window.muted
                                            font.pixelSize: 11
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Small, steady steps count."
                            color: window.muted
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 115
                    radius: 22
                    color: window.surfaceAlt

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 19
                        spacing: 10

                        Text {
                            text: "A gentle reminder"
                            color: window.ink
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "You don't have to do everything. Just give this one thing your attention."
                            color: window.muted
                            font.pixelSize: 13
                            lineHeight: 1.3
                            wrapMode: Text.WordWrap
                        }

                        Item { Layout.fillHeight: true }

                        Text {
                            text: "JAIHO  ·  MAKE SPACE TO THINK"
                            color: window.muted
                            font.pixelSize: 9
                            font.letterSpacing: 1.1
                        }
                    }
                }
            }
        }

        // Quiet footer
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Developed by Jaiho Digital"
                color: window.muted
                font.pixelSize: 11
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "Your focus stays on this device."
                color: window.muted
                font.pixelSize: 11
            }
        }
    }
}
