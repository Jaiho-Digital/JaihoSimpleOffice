import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root

    visible: true
    width: 1200
    height: 780
    minimumWidth: 900
    minimumHeight: 600
    title: "Jaiho SimpleNotes"

    property string themeName: "Warm Paper"
    property int selectedId: 0

    readonly property var themes: ({
        "Warm Paper": {
            bg: "#F5F0E6",
            sidebar: "#FAF7F0",
            paper: "#FFFCF5",
            text: "#34362F",
            muted: "#858477",
            border: "#E4DDCF",
            accent: "#B86F52",
            selected: "#EFE5D7",
            rule: "#EDE5D8"
        },
        "Midnight Ink": {
            bg: "#20211F",
            sidebar: "#252622",
            paper: "#2D2E29",
            text: "#EAE3D6",
            muted: "#A5A394",
            border: "#41423A",
            accent: "#D59A79",
            selected: "#39372F",
            rule: "#414039"
        },
        "Sage Garden": {
            bg: "#EEF0E5",
            sidebar: "#F5F5EC",
            paper: "#FAF9F1",
            text: "#354638",
            muted: "#7B8875",
            border: "#D9DFD0",
            accent: "#71836A",
            selected: "#E2E8DA",
            rule: "#E6E9DF"
        },
        "Rose Clay": {
            bg: "#F5E9E5",
            sidebar: "#FAF1ED",
            paper: "#FFFAF7",
            text: "#603F46",
            muted: "#94777A",
            border: "#E8D6D1",
            accent: "#B87678",
            selected: "#F0DEDA",
            rule: "#F0E3DE"
        },
        "Ocean Mist": {
            bg: "#E9EFF0",
            sidebar: "#F2F6F5",
            paper: "#FAFCFB",
            text: "#304850",
            muted: "#788E92",
            border: "#D5E0E1",
            accent: "#668B96",
            selected: "#DCE8E9",
            rule: "#E4ECEC"
        }
    })

    readonly property var palette:
        themes[themeName] || themes["Warm Paper"]

    readonly property color backgroundColor: palette.bg
    readonly property color sidebarColor: palette.sidebar
    readonly property color paperColor: palette.paper
    readonly property color textColor: palette.text
    readonly property color mutedColor: palette.muted
    readonly property color borderColor: palette.border
    readonly property color accentColor: palette.accent
    readonly property color selectedColor: palette.selected
    readonly property color ruleColor: palette.rule

    color: backgroundColor

    function clearEditor() {
        selectedId = 0
        titleField.text = ""
        bodyField.text = ""
        statusText.text = "A fresh page"
        titleField.forceActiveFocus()
    }

    function saveCurrentNote() {
        const id = notesStore.saveNote(
            selectedId,
            titleField.text,
            bodyField.text
        )

        if (id > 0) {
            selectedId = id
            statusText.text = "Saved to your library"
        } else {
            statusText.text = notesStore.isReady()
                ? "Write something before saving"
                : "Storage unavailable"
        }
    }

    Shortcut {
        sequence: "Ctrl+S"
        onActivated: root.saveCurrentNote()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Editorial header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 76
            color: root.sidebarColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 30
                anchors.rightMargin: 30
                spacing: 13

                // Brand monogram removed

                ColumnLayout {
                    spacing: 1

                    Label {
                        text: "simple notes"
                        color: root.textColor
                        font.pixelSize: 21
                        font.family: "Georgia"
                    }

                    Label {
                        text: "A QUIET PLACE FOR YOUR THOUGHTS"
                        color: root.mutedColor
                        font.pixelSize: 9
                        font.letterSpacing: 1.4
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                ComboBox {
                    id: themeSelector

                    model: [
                        "Warm Paper",
                        "Midnight Ink",
                        "Sage Garden",
                        "Rose Clay",
                        "Ocean Mist"
                    ]

                    currentIndex: Math.max(
                        0, indexOfValue(root.themeName)
                    )

                    implicitWidth: 155
                    implicitHeight: 38

                    onActivated: {
                        root.themeName = currentText
                    }

                    contentItem: Text {
                        leftPadding: 12
                        rightPadding: 28
                        text: themeSelector.displayText
                        color: root.textColor
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        radius: 7
                        color: root.paperColor
                        border.color: root.borderColor
                    }

                    delegate: ItemDelegate {
                        width: themeSelector.width
                        highlighted:
                            themeSelector.highlightedIndex === index

                        contentItem: Text {
                            text: modelData
                            color: root.textColor
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: parent.highlighted
                                ? root.selectedColor
                                : root.sidebarColor
                        }
                    }

                    popup.background: Rectangle {
                        color: root.sidebarColor
                        border.color: root.borderColor
                        radius: 8
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 28
                    color: root.borderColor
                }

                Label {
                    text: "YOUR PERSONAL SPACE"
                    color: root.mutedColor
                    font.pixelSize: 9
                    font.letterSpacing: 1
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: root.borderColor
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Sidebar / Notes library
            Rectangle {
                Layout.preferredWidth: 300
                Layout.minimumWidth: 250
                Layout.fillHeight: true
                color: root.sidebarColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 23
                    anchors.rightMargin: 23
                    anchors.topMargin: 29
                    anchors.bottomMargin: 20
                    spacing: 19

                    Label {
                        text: "YOUR LIBRARY"
                        color: root.mutedColor
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.8
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "All notes"
                            color: root.textColor
                            font.pixelSize: 20
                            font.family: "Georgia"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Label {
                            text: notesStore.notes.length
                            color: root.mutedColor
                            font.pixelSize: 12
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 43
                        text: "+    Create a note"
                        onClicked: root.clearEditor()

                        background: Rectangle {
                            radius: 7
                            color: root.accentColor
                        }

                        contentItem: Label {
                            text: parent.text
                            color: "#FFFCF5"
                            font.pixelSize: 13
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    TextField {
                        id: searchField

                        Layout.fillWidth: true
                        placeholderText: "Find a thought..."
                        selectByMouse: true
                        color: root.textColor
                        font.pixelSize: 12

                        onTextChanged: {
                            notesStore.searchQuery = text
                        }

                        background: Rectangle {
                            radius: 7
                            color: root.backgroundColor
                            border.color: searchField.activeFocus
                                ? root.accentColor
                                : root.borderColor
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: root.borderColor
                    }

                    ListView {
                        id: notesList

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 9
                        model: notesStore.notes

                        ScrollBar.vertical: ScrollBar {}

                        delegate: ItemDelegate {
                            id: noteDelegate

                            required property var modelData

                            width: ListView.view.width
                            height: 91
                            padding: 12
                            highlighted:
                                root.selectedId === modelData.id

                            background: Rectangle {
                                radius: 7

                                color: noteDelegate.highlighted
                                    ? root.selectedColor
                                    : noteDelegate.hovered
                                        ? root.backgroundColor
                                        : "transparent"

                                border.color:
                                    noteDelegate.highlighted
                                    ? root.borderColor
                                    : "transparent"
                            }

                            contentItem: Column {
                                spacing: 7

                                Label {
                                    width: parent.width
                                    text: noteDelegate.modelData.title
                                    color: root.textColor
                                    font.pixelSize: 14
                                    font.family: "Georgia"
                                    elide: Text.ElideRight
                                }

                                Label {
                                    width: parent.width
                                    text: noteDelegate.modelData.body
                                        .replace(/\n/g, " ")
                                    color: root.mutedColor
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                }
                            }

                            onClicked: {
                                root.selectedId = modelData.id
                                titleField.text = modelData.title
                                bodyField.text = modelData.body
                                statusText.text = "Editing your note"
                            }
                        }

                        Label {
                            anchors.centerIn: parent
                            width: parent.width
                            visible: notesList.count === 0
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            color: root.mutedColor
                            font.pixelSize: 12

                            text: searchField.text.length
                                ? "Nothing found.\nTry another search."
                                : "Your story starts here.\nCreate your first note."
                        }
                    }

                    // Jaiho Digital branding footer
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: root.borderColor
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Label {
                            text: "Developed by Jaiho Digital"
                            color: root.textColor
                            font.pixelSize: 11
                            font.family: "Georgia"
                        }

                        Label {
                            text: "OPEN SOURCE  ·  MADE WITH CARE"
                            color: root.mutedColor
                            font.pixelSize: 9
                            font.letterSpacing: 1.1
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: root.borderColor
            }

            // Writing studio
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.backgroundColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 35
                    anchors.rightMargin: 35
                    anchors.topMargin: 27
                    anchors.bottomMargin: 23
                    spacing: 17

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "THE WRITING ROOM"
                            color: root.mutedColor
                            font.pixelSize: 9
                            font.letterSpacing: 1.8
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "Delete"
                            enabled: root.selectedId > 0

                            onClicked: {
                                if (notesStore.deleteNote(root.selectedId))
                                    root.clearEditor()
                                else
                                    statusText.text =
                                        "Could not delete note"
                            }

                            background: Rectangle {
                                color: "transparent"
                            }

                            contentItem: Label {
                                text: parent.text
                                color: parent.enabled
                                    ? root.accentColor
                                    : root.mutedColor
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: "Save note"
                            onClicked: root.saveCurrentNote()

                            background: Rectangle {
                                radius: 6
                                color: root.textColor
                            }

                            contentItem: Label {
                                text: parent.text
                                color: root.backgroundColor
                                font.pixelSize: 12
                                font.bold: true
                                leftPadding: 13
                                rightPadding: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // Paper surface
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: root.paperColor
                        radius: 5
                        border.color: root.borderColor

                        Rectangle {
                            width: 3
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            color: root.accentColor
                            opacity: 0.65
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 43
                            anchors.rightMargin: 36
                            anchors.topMargin: 32
                            anchors.bottomMargin: 22
                            spacing: 12

                            Label {
                                text: root.selectedId > 0
                                    ? "A NOTE FROM YOUR COLLECTION"
                                    : "A NEW PAGE"
                                color: root.accentColor
                                font.pixelSize: 9
                                font.bold: true
                                font.letterSpacing: 1.5
                            }

                            TextField {
                                id: titleField

                                Layout.fillWidth: true
                                placeholderText:
                                    "Give this thought a name..."
                                selectByMouse: true
                                color: root.textColor
                                font.family: "Georgia"
                                font.pixelSize: 29
                                font.bold: false
                                leftPadding: 0
                                rightPadding: 0

                                background: Rectangle {
                                    color: "transparent"
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: root.borderColor
                            }

                            TextArea {
                                id: bodyField

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                placeholderText:
                                    "Let your thoughts find their way onto the page..."
                                selectByMouse: true
                                persistentSelection: true
                                wrapMode: TextEdit.Wrap
                                color: root.textColor
                                font.pixelSize: 15
                                font.family: "Georgia"
                                leftPadding: 9
                                rightPadding: 8
                                topPadding: 13
                                bottomPadding: 10

                                background: Rectangle {
                                    color: "transparent"
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: root.borderColor
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Label {
                                    id: statusText

                                    text: notesStore.isReady()
                                        ? "Your words stay on this device"
                                        : "Storage unavailable"
                                    color: root.mutedColor
                                    font.pixelSize: 10
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Label {
                                    text: "CTRL  +  S"
                                    color: root.mutedColor
                                    font.pixelSize: 10
                                    font.letterSpacing: 1
                                }
                            }
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: "A little space to think. A little room to grow."
                        color: root.mutedColor
                        font.family: "Georgia"
                        font.italic: true
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
