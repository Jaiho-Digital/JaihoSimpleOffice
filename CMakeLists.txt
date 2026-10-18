
cmake_minimum_required(VERSION 3.21)

project(JaihoSimpleOffice
    VERSION 0.1.0
    DESCRIPTION "Jaiho Simple Office desktop applications"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.10 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    Sql
)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(SimpleNotes
    apps/SimpleNotes/src/main.cpp
)

qt_add_qml_module(SimpleNotes
    URI Jaiho.SimpleNotes
    VERSION 1.0
    QML_FILES
        apps/SimpleNotes/qml/Main.qml
)

target_link_libraries(SimpleNotes PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Sql
)

# Add the Windows application icon block here
if(WIN32)
    enable_language(RC)

    set(SIMPLE_NOTES_ICON
        "${CMAKE_CURRENT_SOURCE_DIR}/apps/SimpleNotes/assets/SimpleNotes.ico"
    )

    if(EXISTS "${SIMPLE_NOTES_ICON}")
        file(TO_CMAKE_PATH
            "${SIMPLE_NOTES_ICON}"
            SIMPLE_NOTES_ICON_PATH
        )

        configure_file(
            "${CMAKE_CURRENT_SOURCE_DIR}/apps/SimpleNotes/assets/SimpleNotes.rc.in"
            "${CMAKE_CURRENT_BINARY_DIR}/SimpleNotes.rc"
            @ONLY
        )

        target_sources(SimpleNotes PRIVATE
            "${CMAKE_CURRENT_BINARY_DIR}/SimpleNotes.rc"
        )
    else()
        message(WARNING
            "SimpleNotes.ico not found; using the default application icon."
        )
    endif()
endif()

# Keep this section after the icon block
set_target_properties(SimpleNotes PROPERTIES
    WIN32_EXECUTABLE TRUE
)

install(TARGETS SimpleNotes
    RUNTIME DESTINATION .
)

# ---------------- SimpleCalculator ----------------

qt_add_executable(SimpleCalculator
    apps/SimpleCalculator/src/main.cpp
)

qt_add_qml_module(SimpleCalculator
    URI Jaiho.SimpleCalculator
    VERSION 1.0
    QML_FILES
        apps/SimpleCalculator/qml/Main.qml
)

target_link_libraries(SimpleCalculator PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

set_target_properties(SimpleCalculator PROPERTIES
    WIN32_EXECUTABLE TRUE
)

if(WIN32)
    set(CALCULATOR_ICON
        "${CMAKE_CURRENT_SOURCE_DIR}/apps/SimpleCalculator/assets/SimpleCalculator.ico"
    )

    if(EXISTS "${CALCULATOR_ICON}")
        file(TO_CMAKE_PATH "${CALCULATOR_ICON}" CALCULATOR_ICON_PATH)

        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/SimpleCalculator.rc"
            "IDI_ICON1 ICON \"${CALCULATOR_ICON_PATH}\"\n"
        )

        target_sources(SimpleCalculator PRIVATE
            "${CMAKE_CURRENT_BINARY_DIR}/SimpleCalculator.rc"
        )
    else()
        message(WARNING "SimpleCalculator.ico not found.")
    endif()
endif()

install(TARGETS SimpleCalculator
    RUNTIME DESTINATION .
)

# ---------------- SimpleConvert ----------------

qt_add_executable(SimpleConvert
    apps/SimpleConvert/src/main.cpp
)

qt_add_qml_module(SimpleConvert
    URI Jaiho.SimpleConvert
    VERSION 1.0
    QML_FILES
        apps/SimpleConvert/qml/Main.qml
)

target_link_libraries(SimpleConvert PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

set_target_properties(SimpleConvert PROPERTIES
    WIN32_EXECUTABLE TRUE
)

install(TARGETS SimpleConvert
    RUNTIME DESTINATION .
)

# SimpleConvert Windows application icon
if(WIN32 AND TARGET SimpleConvert)
    set(SIMPLECONVERT_ICON_PATH "${CMAKE_CURRENT_SOURCE_DIR}/apps/SimpleConvert/assets/SimpleConvert.ico")
    if(EXISTS "${SIMPLECONVERT_ICON_PATH}")
        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/SimpleConvert.rc"
            "IDI_ICON1 ICON \"${SIMPLECONVERT_ICON_PATH}\"\n")
        target_sources(SimpleConvert PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/SimpleConvert.rc")
    else()
        message(FATAL_ERROR "SimpleConvert icon not found: ${SIMPLECONVERT_ICON_PATH}")
    endif()
endif()
