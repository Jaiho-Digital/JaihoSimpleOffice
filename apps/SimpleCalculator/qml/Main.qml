import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 420
    height: 650
    minimumWidth: 340
    minimumHeight: 520
    title: "Jaiho SimpleCalculator"
    color: "#F4F5F7"

    property string displayValue: "0"
    property string storedValue: ""
    property string pendingOperator: ""
    property bool startNewNumber: true

    function inputDigit(digit) {
        if (startNewNumber) {
            displayValue = digit
            startNewNumber = false
        } else if (displayValue.length < 16) {
            displayValue = displayValue === "0" ? digit : displayValue + digit
        }
    }

    function clearAll() {
        displayValue = "0"
        storedValue = ""
        pendingOperator = ""
        startNewNumber = true
    }

    function chooseOperator(op) {
        storedValue = displayValue
        pendingOperator = op
        startNewNumber = true
    }

    function calculate() {
        if (storedValue === "" || pendingOperator === "")
            return

        let a = Number(storedValue)
        let b = Number(displayValue)
        let result = 0

        if (pendingOperator === "+") result = a + b
        else if (pendingOperator === "−") result = a - b
        else if (pendingOperator === "×") result = a * b
        else if (pendingOperator === "÷") {
            if (b === 0) {
                displayValue = "Cannot divide by zero"
                storedValue = ""
                pendingOperator = ""
                startNewNumber = true
                return
            }
            result = a / b
        }

        if (!Number.isFinite(result)) {
            displayValue = "Error"
        } else {
            displayValue = String(Number(result.toPrecision(12)))
        }

        storedValue = ""
        pendingOperator = ""
        startNewNumber = true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        Label {
            text: "JAIHO DIGITAL"
            font.pixelSize: 11
            font.letterSpacing: 2
            color: "#777D89"
        }

        Item { Layout.fillHeight: true }

        Label {
            text: "SimpleCalculator"
            color: "#242833"
            font.pixelSize: 22
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            radius: 16
            color: "#FFFFFF"
            border.color: "#E4E6EB"

            Text {
                anchors.fill: parent
                anchors.margins: 18
                text: root.displayValue
                color: "#20242D"
                font.pixelSize: root.displayValue.length > 14 ? 22 : 36
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideLeft
                minimumPixelSize: 16
                fontSizeMode: Text.Fit
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 4
            rowSpacing: 10
            columnSpacing: 10

            Repeater {
                model: [
                    {label:"AC", kind:"utility"}, {label:"±", kind:"utility"},
                    {label:"%", kind:"utility"}, {label:"÷", kind:"operator"},
                    {label:"7", kind:"number"}, {label:"8", kind:"number"},
                    {label:"9", kind:"number"}, {label:"×", kind:"operator"},
                    {label:"4", kind:"number"}, {label:"5", kind:"number"},
                    {label:"6", kind:"number"}, {label:"−", kind:"operator"},
                    {label:"1", kind:"number"}, {label:"2", kind:"number"},
                    {label:"3", kind:"number"}, {label:"+", kind:"operator"},
                    {label:"⌫", kind:"utility"}, {label:"0", kind:"number"},
                    {label:".", kind:"number"}, {label:"=", kind:"equals"}
                ]

                delegate: Button {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 48
                    text: modelData.label
                    font.pixelSize: 20

                    background: Rectangle {
                        radius: 12
                        color: modelData.kind === "operator" ? "#E2E8F8"
                             : modelData.kind === "equals" ? "#3659C9"
                             : modelData.kind === "utility" ? "#E7E9EF"
                             : "#FFFFFF"
                        border.color: "#E1E4EA"
                    }

                    contentItem: Text {
                        text: parent.text
                        color: modelData.kind === "equals" ? "#FFFFFF" : "#252A35"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        const key = modelData.label

                        if (key >= "0" && key <= "9") {
                            root.inputDigit(key)
                        } else if (key === ".") {
                            if (root.startNewNumber) {
                                root.displayValue = "0."
                                root.startNewNumber = false
                            } else if (!root.displayValue.includes(".")) {
                                root.displayValue += "."
                            }
                        } else if (key === "AC") {
                            root.clearAll()
                        } else if (key === "±") {
                            if (root.displayValue !== "0")
                                root.displayValue = String(-Number(root.displayValue))
                        } else if (key === "%") {
                            root.displayValue = String(Number(root.displayValue) / 100)
                        } else if (key === "⌫") {
                            if (!root.startNewNumber) {
                                root.displayValue = root.displayValue.length > 1
                                    ? root.displayValue.slice(0, -1) : "0"
                            }
                        } else if (key === "=") {
                            root.calculate()
                        } else {
                            root.chooseOperator(key)
                        }
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: "Made with care · Jaiho Digital"
            color: "#858B97"
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
