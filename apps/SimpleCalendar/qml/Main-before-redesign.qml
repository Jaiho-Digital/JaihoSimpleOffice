import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.settings

ApplicationWindow {
    id: window
    width: 1180
    height: 760
    minimumWidth: 900
    minimumHeight: 620
    visible: true
    title: "Jaiho SimpleCalendar"
    color: bgColor

    property string selectedTheme: "Warm Paper"
    property date visibleMonth: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
    property date selectedDate: new Date()
    property string savedEvents: "[]"
    property var events: []
    property string eventTitle: ""
    property string eventNotes: ""

    property var palette: ({
        "Warm Paper":  { bg:"#F6F1E9", panel:"#FFFCF7", card:"#F0E7DA", text:"#392F2A", muted:"#8A7B70", accent:"#B96645", line:"#E4D7C8" },
        "Midnight Ink":{ bg:"#171923", panel:"#222532", card:"#2D3140", text:"#F3F0F8", muted:"#A5A6B8", accent:"#B49AFF", line:"#3D4252" },
        "Sage Garden": { bg:"#EDF2E9", panel:"#FAFCF7", card:"#E0E9D9", text:"#293D30", muted:"#758675", accent:"#568365", line:"#D4DFD0" },
        "Rose Clay":   { bg:"#F8EEEE", panel:"#FFF9F8", card:"#F2DEDF", text:"#493036", muted:"#947C82", accent:"#BB6D7E", line:"#E9D1D5" },
        "Ocean Mist":  { bg:"#EAF3F6", panel:"#FAFDFE", card:"#DCEBF0", text:"#253A43", muted:"#718A94", accent:"#3E829A", line:"#D0E2E8" }
    })

    property color bgColor: palette[selectedTheme].bg
    property color panelColor: palette[selectedTheme].panel
    property color cardColor: palette[selectedTheme].card
    property color textColor: palette[selectedTheme].text
    property color mutedColor: palette[selectedTheme].muted
    property color accentColor: palette[selectedTheme].accent
    property color lineColor: palette[selectedTheme].line

    Settings {
        id: settings
        category: "Calendar"
        property string eventsJson: "[]"
        property string themeName: "Warm Paper"
    }

    function dateKey(d) {
        return d.getFullYear() + "-" +
               String(d.getMonth() + 1).padStart(2, "0") + "-" +
               String(d.getDate()).padStart(2, "0")
    }

    function sameDay(a, b) {
        return dateKey(a) === dateKey(b)
    }

    function monthLabel(d) {
        return Qt.formatDate(d, "MMMM yyyy")
    }

    function calendarDate(index) {
        var first = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth(), 1)
        var offset = (first.getDay() + 6) % 7
        return new Date(visibleMonth.getFullYear(), visibleMonth.getMonth(), index - offset + 1)
    }

    function eventsForDate(d) {
        return events.filter(function(e) { return e.date === dateKey(d) })
    }

    function saveEvents() {
        settings.eventsJson = JSON.stringify(events)
    }

    function addEvent() {
        var title = eventTitle.trim()
        if (!title.length)
            return

        var updated = events.slice()
        updated.push({
            "id": Date.now().toString(),
            "title": title,
            "date": dateKey(selectedDate),
            "notes": eventNotes.trim()
        })
        events = updated
        saveEvents()
        eventTitle = ""
        eventNotes = ""
    }

    function deleteEvent(id) {
        events = events.filter(function(e) { return e.id !== id })
        saveEvents()
    }

    Component.onCompleted: {
        selectedTheme = settings.themeName
        try {
            events = JSON.parse(settings.eventsJson || "[]")
        } catch (e) {
            events = []
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 225
            Layout.fillHeight: true
            color: panelColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 20

                RowLayout {
                    spacing: 10
                    Rectangle {
                        width: 42
                        height: 42
                        radius: 13
                        color: accentColor
                        Text {
                            anchors.centerIn: parent
                            text: "J"
                            color: "#FFFFFF"
                            font.pixelSize: 24
                            font.bold: true
                        }
                    }
                    ColumnLayout {
                        spacing: 1
                        Text { text: "JAIHO"; color: textColor; font.bold: true; font.pixelSize: 16 }
                        Text { text: "SimpleCalendar"; color: mutedColor; font.pixelSize: 11 }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: lineColor
                }

                Text {
                    text: "YOUR CALENDAR"
                    color: mutedColor
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1.5
                }

                Button {
                    Layout.fillWidth: true
                    text: "＋   Today"
                    onClicked: {
                        visibleMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1)
                        selectedDate = new Date()
                    }
                    background: Rectangle {
                        radius: 10
                        color: cardColor
                        border.color: lineColor
                    }
                    contentItem: Text {
                        text: parent.text
                        color: textColor
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text { text: "MONTHLY VIEW"; color: mutedColor; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.3 }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: monthLabel(visibleMonth)
                        color: textColor
                        font.bold: true
                        font.pixelSize: 14
                    }
                    ToolButton {
                        text: "‹"
                        onClicked: visibleMonth = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() - 1, 1)
                    }
                    ToolButton {
                        text: "›"
                        onClicked: visibleMonth = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() + 1, 1)
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    rowSpacing: 5
                    columnSpacing: 2
                    Repeater {
                        model: ["M","T","W","T","F","S","S"]
                        Text {
                            required property string modelData
                            text: modelData
                            color: mutedColor
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                        }
                    }
                    Repeater {
                        model: 35
                        delegate: Rectangle {
                            required property int index
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                            radius: 6
                            property date d: new Date(visibleMonth.getFullYear(), visibleMonth.getMonth(), index + 1 - ((new Date(visibleMonth.getFullYear(), visibleMonth.getMonth(), 1).getDay() + 6) % 7))
                            color: sameDay(d, selectedDate) ? accentColor : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: d.getDate()
                                color: sameDay(d, selectedDate) ? "#FFFFFF" : (d.getMonth() === visibleMonth.getMonth() ? textColor : mutedColor)
                                font.pixelSize: 10
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    selectedDate = d
                                    visibleMonth = new Date(d.getFullYear(), d.getMonth(), 1)
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Text { text: "APPEARANCE"; color: mutedColor; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.3 }

                ComboBox {
                    id: themePicker
                    Layout.fillWidth: true
                    model: ["Warm Paper", "Midnight Ink", "Sage Garden", "Rose Clay", "Ocean Mist"]
                    currentIndex: model.indexOf(selectedTheme)
                    onActivated: {
                        selectedTheme = currentText
                        settings.themeName = selectedTheme
                    }
                }

                Text {
                    text: "Made for calmer days."
                    color: mutedColor
                    font.pixelSize: 11
                    Layout.bottomMargin: 4
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: bgColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        spacing: 4
                        Text { text: "Your time, thoughtfully planned."; color: mutedColor; font.pixelSize: 12 }
                        Text { text: monthLabel(visibleMonth); color: textColor; font.pixelSize: 30; font.bold: true }
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: "＋  Add event"
                        onClicked: titleInput.forceActiveFocus()
                        background: Rectangle { radius: 10; color: accentColor }
                        contentItem: Text {
                            text: parent.text
                            color: "#FFFFFF"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                            rightPadding: 12
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 16
                    color: panelColor
                    border.color: lineColor

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            ToolButton {
                                text: "‹"
                                onClicked: visibleMonth = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() - 1, 1)
                            }
                            Text {
                                Layout.fillWidth: true
                                text: monthLabel(visibleMonth)
                                color: textColor
                                font.pixelSize: 17
                                font.bold: true
                            }
                            ToolButton {
                                text: "›"
                                onClicked: visibleMonth = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() + 1, 1)
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            columns: 7
                            rowSpacing: 5
                            columnSpacing: 5

                            Repeater {
                                model: ["MON","TUE","WED","THU","FRI","SAT","SUN"]
                                Text {
                                    required property string modelData
                                    text: modelData
                                    color: mutedColor
                                    font.pixelSize: 10
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 22
                                }
                            }

                            Repeater {
                                model: 42
                                delegate: Rectangle {
                                    required property int index
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: 45
                                    radius: 9
                                    property date d: calendarDate(index)
                                    property bool inMonth: d.getMonth() === visibleMonth.getMonth()
                                    property bool chosen: sameDay(d, selectedDate)
                                    color: chosen ? cardColor : "transparent"
                                    border.width: chosen ? 1 : 0
                                    border.color: accentColor

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        spacing: 4
                                        Text {
                                            text: d.getDate()
                                            color: chosen ? accentColor : (inMonth ? textColor : mutedColor)
                                            font.pixelSize: 12
                                            font.bold: chosen || sameDay(d, new Date())
                                        }
                                        Item { Layout.fillHeight: true }
                                        Row {
                                            spacing: 3
                                            Repeater {
                                                model: Math.min(3, eventsForDate(d).length)
                                                Rectangle {
                                                    required property int index
                                                    width: 5
                                                    height: 5
                                                    radius: 3
                                                    color: accentColor
                                                }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            selectedDate = d
                                            if (!inMonth)
                                                visibleMonth = new Date(d.getFullYear(), d.getMonth(), 1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 210
                        radius: 16
                        color: panelColor
                        border.color: lineColor

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 10

                            Text { text: "EVENTS"; color: mutedColor; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.3 }
                            Text { text: Qt.formatDate(selectedDate, "dddd, d MMMM yyyy"); color: textColor; font.pixelSize: 16; font.bold: true }

                            ListView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                spacing: 6
                                model: eventsForDate(selectedDate)
                                delegate: Rectangle {
                                    required property var modelData
                                    width: ListView.view.width
                                    height: 48
                                    radius: 9
                                    color: cardColor
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: 8
                                        spacing: 8
                                        Rectangle { width: 4; height: 25; radius: 2; color: accentColor }
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            Text { text: modelData.title; color: textColor; font.pixelSize: 12; font.bold: true; elide: Text.ElideRight }
                                            Text { text: modelData.notes || "No additional notes"; color: mutedColor; font.pixelSize: 10; elide: Text.ElideRight }
                                        }
                                        ToolButton {
                                            text: "×"
                                            onClicked: deleteEvent(modelData.id)
                                        }
                                    }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    visible: parent.count === 0
                                    text: "Nothing planned yet. Add an event to get started."
                                    color: mutedColor
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 285
                        Layout.preferredHeight: 210
                        radius: 16
                        color: panelColor
                        border.color: lineColor

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 9
                            Text { text: "NEW EVENT"; color: mutedColor; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.3 }
                            TextField {
                                id: titleInput
                                Layout.fillWidth: true
                                placeholderText: "Event title"
                                text: eventTitle
                                onTextChanged: eventTitle = text
                            }
                            TextField {
                                Layout.fillWidth: true
                                placeholderText: "Notes (optional)"
                                text: eventNotes
                                onTextChanged: eventNotes = text
                            }
                            Item { Layout.fillHeight: true }
                            Button {
                                Layout.fillWidth: true
                                text: "Save event"
                                onClicked: addEvent()
                                background: Rectangle { radius: 9; color: accentColor }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#FFFFFF"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
