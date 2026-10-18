import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 900
    height: 680
    minimumWidth: 720
    minimumHeight: 560
    title: "Jaiho SimpleConvert"
    color: "#F3F5F9"

    property string category: "Length"
    property string fromUnit: ""
    property string toUnit: ""
    property string inputValue: "1"
    property var history: []

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

    function units() {
        return unitSets[category]
    }

    function convert(value, from, to) {
        if (from === to)
            return value

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
            "Length": {
                "Millimeters": 0.001, "Centimeters": 0.01, "Meters": 1,
                "Kilometers": 1000, "Inches": 0.0254, "Feet": 0.3048,
                "Yards": 0.9144, "Miles": 1609.344
            },
            "Mass": {
                "Milligrams": 0.000001, "Grams": 0.001, "Kilograms": 1,
                "Metric Tons": 1000, "Ounces": 0.028349523125, "Pounds": 0.45359237
            },
            "Area": {
                "Square Meters": 1, "Square Kilometers": 1000000,
                "Square Feet": 0.09290304, "Square Yards": 0.83612736,
                "Acres": 4046.8564224, "Hectares": 10000
            },
            "Volume": {
                "Milliliters": 0.001, "Liters": 1, "Cubic Meters": 1000,
                "US Gallons": 3.785411784, "Cups": 0.2365882365
            },
            "Speed": {
                "Meters/second": 1, "Kilometers/hour": 1 / 3.6,
                "Miles/hour": 0.44704, "Knots": 0.5144444444
            },
            "Time": {
                "Milliseconds": 0.001, "Seconds": 1, "Minutes": 60,
                "Hours": 3600, "Days": 86400
            },
            "Digital Storage": {
                "Bytes": 1, "Kilobytes": 1000, "Megabytes": 1000000,
                "Gigabytes": 1000000000, "Terabytes": 1000000000000
            }
        }

        const table = factors[category]
        if (!table || table[from] === undefined || table[to] === undefined)
            return NaN

        return value * table[from] / table[to]
    }

    function formattedResult() {
        if (inputValue.trim() === "" || !isFinite(Number(inputValue)))
            return "Enter a valid number"

        const result = convert(Number(inputValue), fromUnit, toUnit)
        if (!isFinite(result))
            return "Conversion unavailable"

        return Number(result.toPrecision(12)).toLocaleString(
            Qt.locale("en_US"), "g", 12
        )
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
        if (inputValue.trim() === "" || !isFinite(Number(inputValue)))
            return

        const entry = inputValue + " " + fromUnit + " = " +
                      formattedResult() + " " + toUnit

        let updated = [entry].concat(history)
        history = updated.slice(0, 10)
    }

    Component.onCompleted: resetUnits()

    Shortcut {
        sequence: "Ctrl+L"
        onActivated: inputField.forceActiveFocus()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 20

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                width: 46
                height: 46
                radius: 13
                color: "#3158C8"

                Text {
                    anchors.centerIn: parent
                    text: "↔"
                    color: "white"
                    font.pixelSize: 28
                }
            }

            ColumnLayout {
                spacing: 2

                Label {
                    text: "simple convert"
                    color: "#20283A"
                    font.pixelSize: 25
                    font.bold: true
                }

                Label {
                    text: "EVERYDAY CONVERSIONS, MADE SIMPLE"
                    color: "#7D8799"
                    font.pixelSize: 10
                    font.letterSpacing: 1.5
                }
            }

            Item { Layout.fillWidth: true }

            ComboBox {
                id: categoryBox
                model: Object.keys(root.unitSets)
                currentIndex: 0
                implicitWidth: 170
                onActivated: {
                    root.category = currentText
                    root.resetUnits()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 22
            color: "white"
            border.color: "#E2E7F0"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 22

                Label {
                    text: "CONVERT"
                    color: "#7D8799"
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 2
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 18
                    rowSpacing: 8

                    Label {
                        text: "FROM"
                        color: "#7D8799"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    Label {
                        text: "TO"
                        color: "#7D8799"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    TextField {
                        id: inputField
                        Layout.fillWidth: true
                        text: root.inputValue
                        placeholderText: "Enter a value"
                        font.pixelSize: 25
                        color: "#20283A"
                        selectByMouse: true
                        validator: DoubleValidator {
                            notation: DoubleValidator.ScientificNotation
                        }
                        onTextEdited: root.inputValue = text
                    }

                    ComboBox {
                        id: toBox
                        Layout.fillWidth: true
                        model: root.units()
                        currentIndex: Math.max(0, root.units().indexOf(root.toUnit))
                        onActivated: root.toUnit = currentText
                    }

                    ComboBox {
                        id: fromBox
                        Layout.fillWidth: true
                        model: root.units()
                        currentIndex: Math.max(0, root.units().indexOf(root.fromUnit))
                        onActivated: root.fromUnit = currentText
                    }

                    Button {
                        Layout.fillWidth: true
                        text: "⇄  Swap units"
                        onClicked: root.swapUnits()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 190
                    radius: 16
                    color: "#F0F4FF"
                    border.color: "#DCE5FF"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 10

                        Label {
                            text: "RESULT"
                            color: "#6477A8"
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 2
                        }

                        Label {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: root.formattedResult()
                            color: "#2449B0"
                            font.pixelSize: 32
                            font.bold: true
                            minimumPixelSize: 16
                            fontSizeMode: Text.Fit
                            wrapMode: Text.WrapAnywhere
                            verticalAlignment: Text.AlignVCenter
                        }

                        Label {
                            text: root.toUnit
                            color: "#6477A8"
                            font.pixelSize: 12
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        text: "Save to history"
                        onClicked: root.saveHistory()
                    }

                    Button {
                        text: "Copy result"
                        onClicked: {
                            Qt.application.clipboard.setText(root.formattedResult())
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Clear history"
                        enabled: root.history.length > 0
                        onClicked: root.history = []
                    }
                }

                Label {
                    text: "RECENT CONVERSIONS"
                    color: "#7D8799"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1.5
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.history
                    spacing: 4

                    delegate: Label {
                        required property string modelData
                        width: ListView.view.width
                        text: modelData
                        color: "#49546A"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    Label {
                        anchors.centerIn: parent
                        visible: root.history.length === 0
                        text: "Your saved conversions will appear here."
                        color: "#8A94A6"
                        font.pixelSize: 12
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: "Developed by Jaiho Digital"
            color: "#8992A2"
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
