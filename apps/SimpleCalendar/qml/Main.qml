import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.settings

ApplicationWindow {
    id: window
    width: 1240
    height: 800
    minimumWidth: 980
    minimumHeight: 680
    visible: true
    title: "Jaiho SimpleCalendar"
    color: bgColor

    property string selectedTheme: "Warm Paper"
    property date visibleMonth: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
    property date selectedDate: new Date()
    property var events: []
    property string eventTitle: ""
    property string eventNotes: ""
    property bool showNewEvent: false

    property var palette: ({
        "Warm Paper":   { bg:"#F5F0E8", panel:"#FFFCF7", card:"#F0E6D8", text:"#342C27", muted:"#89796E", accent:"#B96645", line:"#E5D8C9", soft:"#F8EEE5" },
        "Midnight Ink": { bg:"#171923", panel:"#222532", card:"#2D3140", text:"#F3F0F8", muted:"#A5A6B8", accent:"#B49AFF", line:"#3D4252", soft:"#292B3A" },
        "Sage Garden":  { bg:"#EDF2E9", panel:"#FCFDF9", card:"#E0E9D9", text:"#293D30", muted:"#758675", accent:"#568365", line:"#D4DFD0", soft:"#F1F5EE" },
        "Rose Clay":    { bg:"#F8EEEE", panel:"#FFFAF9", card:"#F2DEDF", text:"#493036", muted:"#947C82", accent:"#BB6D7E", line:"#E9D1D5", soft:"#F9F0F1" },
        "Ocean Mist":   { bg:"#EAF3F6", panel:"#FCFEFF", card:"#DCEBF0", text:"#253A43", muted:"#718A94", accent:"#3E829A", line:"#D0E2E8", soft:"#F0F7F9" }
    })
    property color bgColor: palette[selectedTheme].bg
    property color panelColor: palette[selectedTheme].panel
    property color cardColor: palette[selectedTheme].card
    property color textColor: palette[selectedTheme].text
    property color mutedColor: palette[selectedTheme].muted
    property color accentColor: palette[selectedTheme].accent
    property color lineColor: palette[selectedTheme].line
    property color softColor: palette[selectedTheme].soft

    Settings {
        id: settings
        category: "Calendar"
        property string eventsJson: "[]"
        property string themeName: "Warm Paper"
    }

    function dateKey(d) {
        return d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0") + "-" + String(d.getDate()).padStart(2, "0")
    }
    function sameDay(a, b) { return dateKey(a) === dateKey(b) }
    function monthLabel(d) { return Qt.formatDate(d, "MMMM yyyy") }
    function calendarDate(index) {
        var first = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth(), 1)
        var offset = (first.getDay() + 6) % 7
        return new Date(visibleMonth.getFullYear(), visibleMonth.getMonth(), index - offset + 1)
    }
    function eventsForDate(d) {
        return events.filter(function(e) { return e.date === dateKey(d) })
    }
    function saveEvents() { settings.eventsJson = JSON.stringify(events) }
    function addEvent() {
        var title = eventTitle.trim()
        if (!title.length) return
        var updated = events.slice()
        updated.push({ "id": Date.now().toString(), "title": title, "date": dateKey(selectedDate), "notes": eventNotes.trim() })
        events = updated
        saveEvents()
        eventTitle = ""
        eventNotes = ""
        showNewEvent = false
    }
    function deleteEvent(id) {
        events = events.filter(function(e) { return e.id !== id })
        saveEvents()
    }
    function goToday() {
        selectedDate = new Date()
        visibleMonth = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)
    }

    Component.onCompleted: {
        selectedTheme = settings.themeName
        try { events = JSON.parse(settings.eventsJson || "[]") } catch (e) { events = [] }
    }

    // Shared button appearance
    component QuietButton: Button {
        property color fillColor: cardColor
        property color inkColor: textColor
        background: Rectangle { radius: 10; color: parent.down ? Qt.darker(parent.fillColor, 1.05) : parent.fillColor; border.color: lineColor }
        contentItem: Text { text: parent.text; color: parent.inkColor; font.pixelSize: 13; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; leftPadding: 10; rightPadding: 10 }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        Rectangle {
            Layout.preferredWidth: 238
            Layout.fillHeight: true
            color: panelColor
            border.color: lineColor
            border.width: 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 11
                    Rectangle {
                        width: 42; height: 42; radius: 13; color: accentColor
                        Text { anchors.centerIn: parent; text: "J"; color: "#FFFFFF"; font.pixelSize: 23; font.bold: true }
                    }
                    ColumnLayout {
                        spacing: 2
                        Text { text: "JAIHO"; color: textColor; font.pixelSize: 15; font.bold: true; font.letterSpacing: 1 }
                        Text { text: "SimpleCalendar"; color: mutedColor; font.pixelSize: 11 }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: lineColor }

                Button {
                    Layout.fillWidth: true
                    implicitHeight: 42
                    text: "＋     Today"
                    onClicked: goToday()
                    background: Rectangle { radius: 11; color: softColor; border.color: lineColor }
                    contentItem: Text { text: parent.text; color: textColor; font.pixelSize: 13; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "QUICK CALENDAR"; color: mutedColor; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.2; Layout.fillWidth: true }
                    Text { text: Qt.formatDate(visibleMonth, "MMM"); color: accentColor; font.pixelSize: 11; font.bold: true }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    rowSpacing: 7
                    columnSpacing: 3
                    Repeater {
                        model: ["M","T","W","T","F","S","S"]
                        Text { required property string modelData; text: modelData; color: mutedColor; font.pixelSize: 10; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                    }
                    Repeater {
                        model: 35
                        delegate: Item {
                            required property int index
                            Layout.fillWidth: true
                            Layout.preferredHeight: 25
                            property date d: calendarDate(index)
                            Rectangle {
                                anchors.centerIn: parent
                                width: 25; height: 25; radius: 8
                                color: sameDay(d, selectedDate) ? accentColor : "transparent"
                            }
                            Text {
                                anchors.centerIn: parent
                                text: d.getDate()
                                color: sameDay(d, selectedDate) ? "#FFFFFF" : (d.getMonth() === visibleMonth.getMonth() ? textColor : mutedColor)
                                font.pixelSize: 10
                                font.bold: sameDay(d, selectedDate)
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    selectedDate = d
                                    if (d.getMonth() !== visibleMonth.getMonth())
                                        visibleMonth = new Date(d.getFullYear(), d.getMonth(), 1)
                                }
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: lineColor }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 9
                    Text { text: "APPEARANCE"; color: mutedColor; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.2 }
                    ComboBox {
                        id: themePicker
                        Layout.fillWidth: true
                        model: ["Warm Paper", "Midnight Ink", "Sage Garden", "Rose Clay", "Ocean Mist"]
                        currentIndex: model.indexOf(selectedTheme)
                        onActivated: { selectedTheme = currentText; settings.themeName = selectedTheme }
                        contentItem: Text { leftPadding: 12; rightPadding: 28; text: themePicker.displayText; color: textColor; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                        background: Rectangle { radius: 9; color: bgColor; border.color: lineColor }
                    }
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 12
                    color: softColor
                    border.color: lineColor
                    implicitHeight: 72
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10
                        Rectangle { width: 34; height: 34; radius: 10; color: cardColor; Text { anchors.centerIn: parent; text: "✦"; color: accentColor; font.pixelSize: 17 } }
                        ColumnLayout {
                            spacing: 3
                            Text { text: "Make room for what matters."; color: textColor; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            Text { text: "A calmer day starts here."; color: mutedColor; font.pixelSize: 9 }
                        }
                    }
                }
            }
        }

        // Main content
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 25
            spacing: 17

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    spacing: 4
                    Text { text: "YOUR PERSONAL SPACE"; color: mutedColor; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.5 }
                    Text { text: monthLabel(visibleMonth); color: textColor; font.pixelSize: 29; font.bold: true }
                    Text { text: Qt.formatDate(selectedDate, "dddd, d MMMM yyyy"); color: mutedColor; font.pixelSize: 12 }
                }
                Item { Layout.fillWidth: true }
                QuietButton {
                    text: "‹"
                    implicitWidth: 42; implicitHeight: 40
                    onClicked: visibleMonth = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() - 1, 1)
                }
                QuietButton {
                    text: "›"
                    implicitWidth: 42; implicitHeight: 40
                    onClicked: visibleMonth = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() + 1, 1)
                }
                Button {
                    text: "＋  New event"
                    implicitHeight: 40
                    onClicked: showNewEvent = !showNewEvent
                    background: Rectangle { radius: 11; color: accentColor }
                    contentItem: Text { text: parent.text; color: "#FFFFFF"; font.pixelSize: 12; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; leftPadding: 13; rightPadding: 13 }
                }
            }

            // Monthly grid
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 360
                radius: 17
                color: panelColor
                border.color: lineColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 5

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 7
                        columnSpacing: 5
                        rowSpacing: 5
                        Repeater {
                            model: ["MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY","SUNDAY"]
                            Rectangle {
                                required property string modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 27
                                color: "transparent"
                                Text { anchors.centerIn: parent; text: parent.parent.modelData; color: mutedColor; font.pixelSize: 9; font.bold: true; font.letterSpacing: 0.5 }
                            }
                        }
                        Repeater {
                            model: 42
                            delegate: Rectangle {
                                required property int index
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 42
                                radius: 10
                                property date d: calendarDate(index)
                                property bool inMonth: d.getMonth() === visibleMonth.getMonth()
                                property bool chosen: sameDay(d, selectedDate)
                                property bool today: sameDay(d, new Date())
                                color: chosen ? softColor : "transparent"
                                border.width: chosen ? 1 : 0
                                border.color: accentColor

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 4
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: d.getDate()
                                            color: chosen || today ? accentColor : (inMonth ? textColor : mutedColor)
                                            font.pixelSize: 12
                                            font.bold: chosen || today
                                        }
                                        Item { Layout.fillWidth: true }
                                        Rectangle { visible: today; width: 5; height: 5; radius: 3; color: accentColor }
                                    }
                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 3
                                        Repeater {
                                            model: eventsForDate(d).slice(0, 2)
                                            Rectangle {
                                                required property var modelData
                                                width: parent.width
                                                height: 17
                                                radius: 5
                                                color: cardColor
                                                Text { anchors.fill: parent; anchors.leftMargin: 5; anchors.rightMargin: 3; text: modelData.title; color: textColor; font.pixelSize: 9; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                            }
                                        }
                                    }
                                    Item { Layout.fillHeight: true }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        selectedDate = d
                                        if (!inMonth) visibleMonth = new Date(d.getFullYear(), d.getMonth(), 1)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Agenda and event creation panels
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: showNewEvent ? 205 : 175
                spacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 16
                    color: panelColor
                    border.color: lineColor
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 9
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "AGENDA"; color: mutedColor; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.3 }
                            Item { Layout.fillWidth: true }
                            Text { text: eventsForDate(selectedDate).length + (eventsForDate(selectedDate).length === 1 ? " event" : " events"); color: accentColor; font.pixelSize: 10; font.bold: true }
                        }
                        Text { text: Qt.formatDate(selectedDate, "dddd, d MMMM"); color: textColor; font.pixelSize: 16; font.bold: true }
                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 6
                            model: eventsForDate(selectedDate)
                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view.width
                                height: 42
                                radius: 9
                                color: softColor
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 5
                                    spacing: 9
                                    Rectangle { width: 3; height: 23; radius: 2; color: accentColor }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text { text: modelData.title; color: textColor; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight }
                                        Text { text: modelData.notes || "No additional notes"; color: mutedColor; font.pixelSize: 9; elide: Text.ElideRight }
                                    }
                                    ToolButton {
                                        text: "×"
                                        onClicked: deleteEvent(modelData.id)
                                        contentItem: Text { text: parent.text; color: mutedColor; font.pixelSize: 18; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    }
                                }
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: parent.count === 0
                                text: "A little breathing room. Nothing planned yet."
                                color: mutedColor
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                Rectangle {
                    visible: showNewEvent
                    Layout.preferredWidth: 300
                    Layout.fillHeight: true
                    radius: 16
                    color: panelColor
                    border.color: lineColor
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 8
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "NEW EVENT"; color: mutedColor; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.2; Layout.fillWidth: true }
                            ToolButton { text: "×"; onClicked: showNewEvent = false }
                        }
                        TextField {
                            Layout.fillWidth: true
                            placeholderText: "What are you planning?"
                            text: eventTitle
                            onTextChanged: eventTitle = text
                            color: textColor
                            background: Rectangle { radius: 8; color: bgColor; border.color: lineColor }
                            leftPadding: 10
                        }
                        TextField {
                            Layout.fillWidth: true
                            placeholderText: "Notes (optional)"
                            text: eventNotes
                            onTextChanged: eventNotes = text
                            color: textColor
                            background: Rectangle { radius: 8; color: bgColor; border.color: lineColor }
                            leftPadding: 10
                        }
                        Item { Layout.fillHeight: true }
                        Button {
                            Layout.fillWidth: true
                            text: "Save event"
                            onClicked: addEvent()
                            background: Rectangle { radius: 9; color: accentColor }
                            contentItem: Text { text: parent.text; color: "#FFFFFF"; font.pixelSize: 11; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                    }
                }
            }
        }
    }
}
