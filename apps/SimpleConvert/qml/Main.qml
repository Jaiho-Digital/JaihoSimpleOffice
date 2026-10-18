import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1120
    height: 760
    minimumWidth: 900
    minimumHeight: 640
    title: "Jaiho SimpleConvert"

    property string category: "Length"
    property string fromUnit: ""
    property string toUnit: ""
    property string inputValue: "1"
    property string themeName: "Warm Paper"
    property var history: []

    readonly property var themes: ({
        "Warm Paper": {
            bg: "#F5F0E6", sidebar: "#F8F2E8", panel: "#FFFCF5",
            field: "#FBF6ED", text: "#35352F", muted: "#858174", border: "#E4DCCB",
            accent: "#B86F52", accentText: "#FFFFFF", soft: "#F5E5D9",
            softBorder: "#E9D0BE", resultText: "#914E38", row: "#FBF3E9"
        },
        "Midnight Ink": {
            bg: "#171A24", sidebar: "#1D202C", panel: "#222633",
            field: "#191D29", text: "#F0F1F5", muted: "#A0A6B8", border: "#383E50",
            accent: "#9B8AFB", accentText: "#171526", soft: "#302C49",
            softBorder: "#4B426F", resultText: "#D1C8FF", row: "#292D3C"
        },
        "Sage Garden": {
            bg: "#EAF0E7", sidebar: "#F0F5ED", panel: "#F8FBF5",
            field: "#EFF5EB", text: "#303D32", muted: "#7A897B", border: "#D5E0D2",
            accent: "#64866A", accentText: "#FFFFFF", soft: "#E2EDE0",
            softBorder: "#C8DCC7", resultText: "#426C49", row: "#EFF5EB"
        },
        "Rose Clay": {
            bg: "#F5E9E7", sidebar: "#FAF0EE", panel: "#FFF9F8",
            field: "#F9EFED", text: "#493633", muted: "#9A817D", border: "#E8D5D1",
            accent: "#B96F78", accentText: "#FFFFFF", soft: "#F4E1E2",
            softBorder: "#E9C9CD", resultText: "#98505A", row: "#FBF0EF"
        },
        "Ocean Mist": {
            bg: "#E8F0F3", sidebar: "#EEF5F7", panel: "#F8FCFD",
            field: "#EDF5F7", text: "#2F4149", muted: "#7C929B", border: "#D2E1E6",
            accent: "#4D8799", accentText: "#FFFFFF", soft: "#DDECF1",
            softBorder: "#C4DDE5", resultText: "#356F82", row: "#EEF6F8"
        }
    })
    readonly property var palette: themes[themeName] || themes["Warm Paper"]

    color: palette.bg

    readonly property var unitSets: ({
        "Length": ["Millimeters", "Centimeters", "Meters", "Kilometers", "Inches", "Feet", "Yards", "Miles"],
        "Mass": ["Milligrams", "Grams", "Kilograms", "Metric Tons", "Ounces", "Pounds"],
        "Temperature": ["Celsius", "Fahrenheit", "Kelvin"],
        "Area": ["Square Meters", "Square Kilometers", "Square Feet", "Square Yards", "Acres", "Hectares"],
        "Volume": ["Milliliters", "Liters", "Cubic Meters", "US Gallons", "Cups"],
        "Speed": ["Meters/second", "Kilometers/hour", "Miles/hour", "Knots"],
        "Time": ["Milliseconds", "Seconds", "Minutes", "Hours", "Days"],
        "Digital Storage": ["Bytes", "Kilobytes", "Megabytes", "Gigabytes", "Terabytes"]
    })

    readonly property var categoryDescriptions: ({
        "Length": "Convert between metric and imperial length units.",
        "Mass": "Convert weights and mass measurements.",
        "Temperature": "Convert Celsius, Fahrenheit and Kelvin.",
        "Area": "Convert surface area measurements.",
        "Volume": "Convert liquids and volume measurements.",
        "Speed": "Convert travel and motion speeds.",
        "Time": "Convert time units from milliseconds to days.",
        "Digital Storage": "Convert digital storage measurements."
    })

    function units() { return unitSets[category] }

    function convert(value, from, to) {
        if (from === to) return value
        if (category === "Temperature") {
            let celsius
            if (from === "Celsius") celsius = value
            else if (from === "Fahrenheit") celsius = (value - 32) * 5 / 9
            else celsius = value - 273.15
            if (to === "Celsius") return celsius
            if (to === "Fahrenheit") return celsius * 9 / 5 + 32
            return celsius + 273.15
        }
        const factors = {
            "Length": {"Millimeters": 0.001, "Centimeters": 0.01, "Meters": 1, "Kilometers": 1000, "Inches": 0.0254, "Feet": 0.3048, "Yards": 0.9144, "Miles": 1609.344},
            "Mass": {"Milligrams": 0.000001, "Grams": 0.001, "Kilograms": 1, "Metric Tons": 1000, "Ounces": 0.028349523125, "Pounds": 0.45359237},
            "Area": {"Square Meters": 1, "Square Kilometers": 1000000, "Square Feet": 0.09290304, "Square Yards": 0.83612736, "Acres": 4046.8564224, "Hectares": 10000},
            "Volume": {"Milliliters": 0.001, "Liters": 1, "Cubic Meters": 1000, "US Gallons": 3.785411784, "Cups": 0.2365882365},
            "Speed": {"Meters/second": 1, "Kilometers/hour": 1 / 3.6, "Miles/hour": 0.44704, "Knots": 0.5144444444},
            "Time": {"Milliseconds": 0.001, "Seconds": 1, "Minutes": 60, "Hours": 3600, "Days": 86400},
            "Digital Storage": {"Bytes": 1, "Kilobytes": 1000, "Megabytes": 1000000, "Gigabytes": 1000000000, "Terabytes": 1000000000000}
        }
        const table = factors[category]
        if (!table || table[from] === undefined || table[to] === undefined) return NaN
        return value * table[from] / table[to]
    }

    function formattedResult() {
        if (inputValue.trim() === "" || !isFinite(Number(inputValue))) return "Enter a valid number"
        const result = convert(Number(inputValue), fromUnit, toUnit)
        if (!isFinite(result)) return "Conversion unavailable"
        return Number(result.toPrecision(12)).toLocaleString(Qt.locale("en_US"), "g", 12)
    }

    function resetUnits() {
        const list = units()
        fromUnit = list[0]
        toUnit = list.length > 1 ? list[1] : list[0]
    }

    function swapUnits() {
        const oldFrom = fromUnit
        fromUnit = toUnit
        toUnit = oldFrom
    }

    function saveHistory() {
        if (inputValue.trim() === "" || !isFinite(Number(inputValue))) return
        const entry = inputValue + " " + fromUnit + " = " + formattedResult() + " " + toUnit
        history = [entry].concat(history).slice(0, 10)
    }

    function categoryGlyph(name) {
        const glyphs = {"Length": "↗", "Mass": "◈", "Temperature": "℃", "Area": "▦", "Volume": "◇", "Speed": "⌁", "Time": "◷", "Digital Storage": "▤"}
        return glyphs[name] || "•"
    }

    Component.onCompleted: resetUnits()

    component Eyebrow: Label {
        property var appRoot
        color: appRoot.palette.muted
        font.pixelSize: 10
        font.bold: true
        font.letterSpacing: 1.7
    }

    component ActionButton: Button {
        id: actionButton
        property var appRoot
        property bool primary: false
        font.pixelSize: 12
        font.weight: Font.DemiBold
        implicitHeight: 42
        contentItem: Text {
            text: actionButton.text
            font: actionButton.font
            color: actionButton.primary ? actionButton.appRoot.palette.accentText : actionButton.appRoot.palette.text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            radius: 11
            color: actionButton.primary
                   ? (actionButton.down ? actionButton.appRoot.palette.resultText : actionButton.appRoot.palette.accent)
                   : (actionButton.down ? actionButton.appRoot.palette.softBorder : actionButton.hovered ? actionButton.appRoot.palette.soft : actionButton.appRoot.palette.field)
            border.color: actionButton.primary ? actionButton.appRoot.palette.accent : actionButton.appRoot.palette.border
        }
    }

    component ThemedComboBox: ComboBox {
        id: combo
        property var appRoot
        font.pixelSize: 12
        implicitHeight: 42
        contentItem: Text {
            leftPadding: 12
            rightPadding: combo.indicator.width + 8
            text: combo.displayText
            font: combo.font
            color: combo.appRoot.palette.text
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            radius: 11
            color: combo.appRoot.palette.field
            border.color: combo.activeFocus ? combo.appRoot.palette.accent : combo.appRoot.palette.border
        }
        indicator: Text {
            x: combo.width - width - 12
            y: (combo.height - height) / 2
            text: "⌄"
            color: combo.appRoot.palette.muted
            font.pixelSize: 17
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar: category navigation, styled like the SimpleNotes theme family.
        Rectangle {
            Layout.preferredWidth: 205
            Layout.fillHeight: true
            color: root.palette.sidebar
            border.color: root.palette.border
            border.width: 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 17
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Rectangle {
                        Layout.preferredWidth: 43
                        Layout.preferredHeight: 43
                        radius: 14
                        color: root.palette.accent
                        Text {
                            anchors.centerIn: parent
                            text: "↔"
                            color: root.palette.accentText
                            font.pixelSize: 25
                        }
                    }
                    ColumnLayout {
                        spacing: 0
                        Label {
                            text: "simple"
                            color: root.palette.text
                            font.pixelSize: 21
                            font.bold: true
                        }
                        Label {
                            text: "convert"
                            color: root.palette.resultText
                            font.pixelSize: 21
                            font.bold: true
                        }
                    }
                }

                Label {
                    Layout.leftMargin: 3
                    Layout.topMargin: 2
                    text: "EVERYDAY CONVERSIONS,\nMADE SIMPLE"
                    color: root.palette.muted
                    font.pixelSize: 8
                    font.letterSpacing: 1.25
                    lineHeight: 1.25
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 7
                    Layout.bottomMargin: 5
                    height: 1
                    color: root.palette.border
                }

                Eyebrow { appRoot: root; text: "CATEGORIES"; Layout.leftMargin: 3 }

                Repeater {
                    model: Object.keys(root.unitSets)
                    delegate: Item {
                        required property string modelData
                        Layout.fillWidth: true
                        implicitHeight: 43

                        Rectangle {
                            anchors.fill: parent
                            radius: 11
                            color: root.category === modelData ? root.palette.soft : "transparent"
                            border.color: root.category === modelData ? root.palette.softBorder : "transparent"
                        }
                        Rectangle {
                            width: 3
                            height: parent.height - 12
                            anchors.left: parent.left
                            anchors.leftMargin: 1
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 2
                            color: root.category === modelData ? root.palette.accent : "transparent"
                        }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 8
                            spacing: 10
                            Label {
                                text: root.categoryGlyph(modelData)
                                color: root.category === modelData ? root.palette.resultText : root.palette.muted
                                font.pixelSize: 19
                                Layout.preferredWidth: 22
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                text: modelData
                                color: root.category === modelData ? root.palette.resultText : root.palette.text
                                font.pixelSize: 12
                                font.weight: root.category === modelData ? Font.DemiBold : Font.Normal
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.category = modelData
                                root.resetUnits()
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: root.palette.border
                }
                Label {
                    text: "Jaiho Digital"
                    color: root.palette.text
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    Layout.leftMargin: 3
                }
                Label {
                    text: "SIMPLE TOOLS FOR EVERYDAY"
                    color: root.palette.muted
                    font.pixelSize: 8
                    font.letterSpacing: 1.1
                    Layout.leftMargin: 3
                    Layout.bottomMargin: 4
                }
            }
        }

        // Main workspace
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20
            spacing: 15

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    spacing: 3
                    Layout.fillWidth: true
                    Label {
                        text: root.category
                        color: root.palette.text
                        font.pixelSize: 29
                        font.weight: Font.DemiBold
                    }
                    Label {
                        text: root.categoryDescriptions[root.category]
                        color: root.palette.muted
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }

                ColumnLayout {
                    spacing: 4
                    Eyebrow { appRoot: root; text: "APPEARANCE" }
                    ThemedComboBox {
                        appRoot: root
                        id: themeBox
                        Layout.preferredWidth: 155
                        model: ["Warm Paper", "Midnight Ink", "Sage Garden", "Rose Clay", "Ocean Mist"]
                        currentIndex: Math.max(0, model.indexOf(root.themeName))
                        onActivated: root.themeName = currentText
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                // Converter column
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 600
                    spacing: 13

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 58
                        radius: 14
                        color: root.palette.panel
                        border.color: root.palette.border

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 17
                            anchors.rightMargin: 17
                            spacing: 10
                            ColumnLayout {
                                spacing: 3
                                Eyebrow { appRoot: root; text: "CONVERT" }
                                Label {
                                    text: root.categoryDescriptions[root.category]
                                    color: root.palette.text
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                radius: 8
                                color: root.palette.soft
                                implicitWidth: categoryTag.implicitWidth + 18
                                implicitHeight: 27
                                Label {
                                    id: categoryTag
                                    anchors.centerIn: parent
                                    text: root.category.toUpperCase()
                                    color: root.palette.resultText
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 0.7
                                }
                            }
                        }
                    }

                    // From / To cards
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 176
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 15
                            color: root.palette.panel
                            border.color: root.palette.border
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 9
                                Eyebrow { appRoot: root; text: "FROM" }
                                TextField {
                                    id: inputField
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    implicitHeight: 56
                                    text: root.inputValue
                                    placeholderText: "Enter value"
                                    font.pixelSize: 27
                                    font.weight: Font.Medium
                                    color: root.palette.text
                                    selectByMouse: true
                                    leftPadding: 12
                                    background: Rectangle {
                                        radius: 10
                                        color: root.palette.field
                                        border.color: inputField.activeFocus ? root.palette.accent : root.palette.border
                                    }
                                    validator: DoubleValidator { notation: DoubleValidator.ScientificNotation }
                                    onTextEdited: root.inputValue = text
                                }
                                ThemedComboBox {
                                    appRoot: root
                                    Layout.fillWidth: true
                                    model: root.units()
                                    currentIndex: Math.max(0, root.units().indexOf(root.fromUnit))
                                    onActivated: root.fromUnit = currentText
                                }
                            }
                        }

                        Button {
                            Layout.preferredWidth: 45
                            Layout.preferredHeight: 45
                            Layout.alignment: Qt.AlignVCenter
                            text: "⇄"
                            font.pixelSize: 23
                            contentItem: Text {
                                text: "⇄"
                                color: root.palette.accentText
                                font.pixelSize: 23
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: width / 2
                                color: parent.down ? root.palette.resultText : root.palette.accent
                            }
                            onClicked: root.swapUnits()
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 15
                            color: root.palette.panel
                            border.color: root.palette.border
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 9
                                Eyebrow { appRoot: root; text: "TO" }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    implicitHeight: 56
                                    radius: 10
                                    color: root.palette.field
                                    border.color: root.palette.border
                                    clip: true
                                    Label {
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: 10
                                        text: root.formattedResult()
                                        color: root.palette.text
                                        font.pixelSize: 24
                                        font.weight: Font.Medium
                                        minimumPixelSize: 13
                                        fontSizeMode: Text.Fit
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }
                                }
                                ThemedComboBox {
                                    appRoot: root
                                    Layout.fillWidth: true
                                    model: root.units()
                                    currentIndex: Math.max(0, root.units().indexOf(root.toUnit))
                                    onActivated: root.toUnit = currentText
                                }
                            }
                        }
                    }

                    // Result card
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 145
                        radius: 17
                        color: root.palette.soft
                        border.color: root.palette.softBorder

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 5
                            Eyebrow {
                                text: "RESULT"
                                color: root.palette.resultText
                            }
                            Label {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: root.formattedResult()
                                color: root.palette.resultText
                                font.pixelSize: 43
                                font.weight: Font.DemiBold
                                minimumPixelSize: 17
                                fontSizeMode: Text.Fit
                                wrapMode: Text.WrapAnywhere
                                verticalAlignment: Text.AlignVCenter
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Label {
                                    text: root.toUnit
                                    color: root.palette.text
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                }
                                Item { Layout.fillWidth: true }
                                Button {
                                    text: "▢  Copy result"
                                    font.pixelSize: 11
                                    implicitHeight: 35
                                    contentItem: Text {
                                        text: parent.text
                                        color: root.palette.text
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        radius: 9
                                        color: root.palette.field
                                        border.color: root.palette.border
                                    }
                                    onClicked: Qt.application.clipboard.setText(root.formattedResult())
                                }
                            }
                        }
                    }

                    // Actions
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ActionButton {
                            appRoot: root
                            Layout.fillWidth: true
                            text: "⇄  Swap units"
                            primary: true
                            onClicked: root.swapUnits()
                        }
                        ActionButton {
                            appRoot: root
                            Layout.fillWidth: true
                            text: "▢  Copy result"
                            onClicked: Qt.application.clipboard.setText(root.formattedResult())
                        }
                        ActionButton {
                            appRoot: root
                            Layout.fillWidth: true
                            text: "♡  Save history"
                            onClicked: root.saveHistory()
                        }
                        ActionButton {
                            appRoot: root
                            Layout.fillWidth: true
                            text: "Clear"
                            enabled: root.history.length > 0
                            onClicked: root.history = []
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: "Tip: Enter a value, choose units, or press Ctrl + L to focus the input."
                        color: root.palette.muted
                        font.pixelSize: 10
                        wrapMode: Text.WordWrap
                    }
                }

                // Dedicated history panel
                Rectangle {
                    Layout.preferredWidth: 250
                    Layout.minimumWidth: 215
                    Layout.fillHeight: true
                    radius: 16
                    color: root.palette.panel
                    border.color: root.palette.border

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 13
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            Eyebrow { appRoot: root; text: "RECENT CONVERSIONS" }
                            Item { Layout.fillWidth: true }
                            Label {
                                text: root.history.length + "/10"
                                color: root.palette.resultText
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: root.palette.border
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ListView {
                                id: historyList
                                anchors.fill: parent
                                clip: true
                                model: root.history
                                spacing: 7
                                delegate: Rectangle {
                                    required property string modelData
                                    width: ListView.view.width
                                    height: 56
                                    radius: 10
                                    color: root.palette.row
                                    border.color: root.palette.border
                                    Text {
                                        anchors.fill: parent
                                        anchors.margins: 9
                                        text: modelData
                                        color: root.palette.text
                                        font.pixelSize: 10
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 3
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                            Label {
                                anchors.centerIn: parent
                                width: parent.width - 20
                                visible: root.history.length === 0
                                text: "Your saved conversions will appear here."
                                color: root.palette.muted
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        ActionButton {
                            appRoot: root
                            Layout.fillWidth: true
                            text: "Clear history"
                            enabled: root.history.length > 0
                            onClicked: root.history = []
                        }
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: "Jaiho Digital   ·   SimpleConvert"
                color: root.palette.muted
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+L"
        onActivated: inputField.forceActiveFocus()
    }
}
