import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: root
    
    property int sessionIndex: sessionModel.lastIndex
    property int userIndex: userModel.lastIndex
    property var phrases: [
        "import happiness",
        "Home is where the ~ is",
        "I think therefore I RAM",
        "Cache me if you can",
        "Shell we begin?",
        "// TODO: login",
        "There's no place like 127.0.0.1",
        "SELECT * FROM dreams"
    ]
    property string welcomeText: phrases[Math.floor(Math.random() * phrases.length)]
    
    // Persistent settings
    property bool isDark: true
    property string savedTheme: ""
    property int savedSession: sessionModel.lastIndex
    property bool capsLockOn: false
    property int currentLayout: 0
    property var layouts: ["EN", "RU", "DE", "FR"]
    
    // Light theme colors
    property string lightBgColor: "#F8F9FA"
    property string lightFgColor: "#495057"
    property string lightAccentColor: "#9BB1FF"
    property string lightOne: "#E9ECEF"
    property string lightTwo: "#DEE2E6"
    property string lightGrayOne: "#6C757D"
    property string lightGrayZero: "#ADB5BD"
    property string lightGrayFour: "#212529"
    
    // Dark theme colors
    property string darkBgColor: "#212529"
    property string darkFgColor: "#E9ECEF"
    property string darkAccentColor: "#ABC4FF"
    property string darkOne: "#343A40"
    property string darkTwo: "#495057"
    property string darkGrayOne: "#ADB5BD"
    property string darkGrayZero: "#6C757D"
    property string darkGrayFour: "#F8F9FA"
    
    // Current theme colors
    property string bgColor: isDark ? darkBgColor : lightBgColor
    property string fgColor: isDark ? darkFgColor : lightFgColor
    property string accentColor: isDark ? darkAccentColor : lightAccentColor
    property string grayOne: isDark ? darkGrayOne : lightGrayOne
    property string grayZero: isDark ? darkGrayZero : lightGrayZero
    property string grayFour: isDark ? darkGrayFour : lightGrayFour
    property string containerColor: isDark ? darkOne : lightOne
    property string borderColor: isDark ? darkTwo : lightTwo
    
    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
    
    Connections {
        target: sddm
        onLoginSucceeded: {
            errorMessage.color = "#22bb22"
            errorMessage.text = qsTr("Login succeeded!")
        }
        onLoginFailed: {
            password.text = ""
            errorMessage.color = "#ff4444"
            errorMessage.text = qsTr("Login failed!")
            password.focus = true
        }
    }
    
    FontLoader {
        id: sandyHouseFont
        source: "fonts/Sandy House.ttf"
    }
    
    FontLoader {
        id: agaveFont
        source: "fonts/Agave.ttf"
    }
    
    // Minimalist solid background
    color: bgColor
    
    // Welcome text with Sandy House font - responsive size
    Text {
        id: welcomeTitle
        text: welcomeText
        font.family: sandyHouseFont.name
        font.pixelSize: Math.min(parent.width * 0.20, parent.height * 0.15)
        font.letterSpacing: parent.width * 0.002
        color: grayOne
        renderType: Text.NativeRendering
        antialiasing: true
        width: parent.width * 0.40
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        lineHeight: 0.9
        maximumLineCount: 2
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: loginContainer.top
            bottomMargin: parent.height * 0.19
        }
    }
    
    // Main login container
    Item {
        id: loginContainer
        width: Math.min(parent.width * 0.4, parent.height * 0.4)
        height: childrenRect.height
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: parent.height * 0.15
        }
        
        Column {
            width: parent.width
            spacing: parent.height * 0.04
            
            // User picker - same as session picker
            Column {
                width: parent.width
                spacing: parent.height * 0.006
                
                Text {
                    text: "USER"
                    font.family: agaveFont.name
                    antialiasing: true
                    font.pixelSize: Math.max(parent.width * 0.03, 8)
                    font.letterSpacing: parent.width * 0.004
                    color: grayZero
                }
                
                Rectangle {
                    id: userButton
                    width: parent.width
                    height: Math.max(parent.width * 0.12, 30)
                    color: "transparent"
                    border.color: userPopup.visible ? accentColor : borderColor
                    border.width: Math.max(parent.width * 0.003, 1)
                    
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: parent.width * 0.04
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: agaveFont.name
                    antialiasing: true
                        font.pixelSize: Math.max(parent.width * 0.04, 12)
                        color: fgColor
                        text: {
                            if (typeof userModel !== 'undefined' && userIndex >= 0 && userIndex < userModel.count) {
                                return userModel.data(userModel.index(userIndex, 0), Qt.UserRole + 1)
                            }
                            return "User"
                        }
                    }
                    
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: parent.width * 0.04
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: agaveFont.name
                    antialiasing: true
                        font.pixelSize: Math.max(parent.width * 0.03, 8)
                        color: grayOne
                        text: userPopup.visible ? "▲" : "▼"
                        rotation: 0
                    }
                    
                    MouseArea {
                        id: userMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            userPopup.visible = !userPopup.visible
                        }
                    }
                }
            }
            
            // Password field - smaller
            Column {
                width: parent.width
                spacing: parent.height * 0.006
                
                Text {
                    text: "PASSWORD"
                    font.family: agaveFont.name
                    antialiasing: true
                    font.pixelSize: Math.max(parent.width * 0.03, 8)
                    font.letterSpacing: parent.width * 0.004
                    color: grayZero
                }
                
                Rectangle {
                    width: parent.width
                    height: Math.max(parent.width * 0.12, 30)
                    color: "transparent"
                    border.color: password.focus ? accentColor : borderColor
                    border.width: Math.max(parent.width * 0.003, 1)
                    
                    TextInput {
                        id: password
                        anchors.fill: parent
                        anchors.leftMargin: parent.width * 0.04
                        anchors.rightMargin: parent.width * 0.04
                        font.family: agaveFont.name
                    antialiasing: true
                        font.pixelSize: Math.max(parent.width * 0.04, 12)
                        color: fgColor
                        echoMode: TextInput.Password
                        verticalAlignment: TextInput.AlignVCenter
                        focus: true
                        
                        Keys.onEnterPressed: {
                            var selectedUser = userModel.data(userModel.index(userIndex, 0), Qt.UserRole + 1)
                            sddm.login(selectedUser, password.text, sessionIndex)
                        }
                        Keys.onReturnPressed: {
                            var selectedUser = userModel.data(userModel.index(userIndex, 0), Qt.UserRole + 1)
                            sddm.login(selectedUser, password.text, sessionIndex)
                        }
                    }
                }
            }
            
            // Session picker - improved
            Column {
                width: parent.width
                spacing: parent.height * 0.006
                
                Text {
                    text: "SESSION"
                    font.family: agaveFont.name
                    antialiasing: true
                    font.pixelSize: Math.max(parent.width * 0.03, 8)
                    font.letterSpacing: parent.width * 0.004
                    color: grayZero
                }
                
                Rectangle {
                    id: sessionButton
                    width: parent.width
                    height: Math.max(parent.width * 0.12, 30)
                    color: "transparent"
                    border.color: sessionPopup.visible ? accentColor : borderColor
                    border.width: Math.max(parent.width * 0.003, 1)
                    
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: parent.width * 0.04
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: agaveFont.name
                    antialiasing: true
                        font.pixelSize: Math.max(parent.width * 0.04, 12)
                        color: fgColor
                        text: sessionModel.data(sessionModel.index(sessionIndex, 0), Qt.UserRole + 4)
                    }
                    
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: parent.width * 0.04
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: agaveFont.name
                    antialiasing: true
                        font.pixelSize: Math.max(parent.width * 0.03, 8)
                        color: grayOne
                        text: sessionPopup.visible ? "▲" : "▼"
                        rotation: 0
                    }
                    
                    MouseArea {
                        id: sessionMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            sessionPopup.visible = !sessionPopup.visible
                        }
                    }
                }
            }
            
            // Error message
            Text {
                id: errorMessage
                width: parent.width
                horizontalAlignment: Text.AlignLeft
                font.family: agaveFont.name
                antialiasing: true
                font.pixelSize: Math.max(parent.width * 0.035, 10)
                color: "transparent"
                wrapMode: Text.WordWrap
                height: Math.max(parent.width * 0.05, 16)
            }
            
            // Button row
            Row {
                width: parent.width
                spacing: parent.width * 0.03
                
                // Login button
                Rectangle {
                    width: parent.width - parent.width * 0.28
                    height: Math.max(parent.width * 0.12, 30)
                    color: grayFour
                    radius: Math.max(parent.width * 0.01, 2)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "LOGIN"
                        font.family: agaveFont.name
                    antialiasing: true
                        font.pixelSize: Math.max(parent.width * 0.035, 9)
                        font.letterSpacing: parent.width * 0.004
                        color: bgColor
                    }
                    
                    MouseArea {
                        id: loginButtonMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var selectedUser = userModel.data(userModel.index(userIndex, 0), Qt.UserRole + 1)
                            sddm.login(selectedUser, password.text, sessionIndex)
                        }
                    }
                }
                
                // Reboot button - circular
                Rectangle {
                    width: Math.max(parent.width * 0.12, 30)
                    height: Math.max(parent.width * 0.12, 30)
                    color: grayFour
                    radius: Math.max(parent.width * 0.06, 15)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "↻"
                        font.pixelSize: Math.min(Math.max(parent.width * 0.4, 16), 22)
                        color: bgColor
                    }
                    
                    MouseArea {
                        id: rebootMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.reboot()
                    }
                }
                
                // Shutdown button - circular
                Rectangle {
                    width: Math.max(parent.width * 0.12, 30)
                    height: Math.max(parent.width * 0.12, 30)
                    color: grayFour
                    radius: Math.max(parent.width * 0.06, 15)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⏻"
                        font.pixelSize: Math.min(Math.max(parent.width * 0.4, 16), 22)
                        color: bgColor
                    }
                    
                    MouseArea {
                        id: shutdownMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.powerOff()
                    }
                }
            }
        }
    }
    
    // User popup - properly positioned below user field
    Rectangle {
        id: userPopup
        visible: false
        width: loginContainer.width
        height: Math.min(userModel.count * loginContainer.height * 0.11 + loginContainer.height * 0.006, loginContainer.height * 0.56)
        anchors {
            left: loginContainer.left
            top: loginContainer.top
            topMargin: loginContainer.height * 0.225
        }
        color: bgColor
        border.color: accentColor
        border.width: Math.max(loginContainer.width * 0.003, 1)
        z: 1000
        
        ListView {
            id: userList
            anchors.fill: parent
            anchors.margins: 1
            model: userModel
            currentIndex: userIndex
            clip: true
            
            delegate: Rectangle {
                width: parent.width
                height: loginContainer.height * 0.11
                color: userDelegateMouse.containsMouse ? containerColor : (index === userIndex ? borderColor : "transparent")
                
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.04
                    anchors.verticalCenter: parent.verticalCenter
                    text: name
                    font.family: agaveFont.name
                    antialiasing: true
                    font.pixelSize: Math.max(parent.width * 0.04, 11)
                    color: fgColor
                }
                
                MouseArea {
                    id: userDelegateMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        userIndex = index
                        userPopup.visible = false
                    }
                }
            }
        }
    }
    
    // Session popup - properly positioned below session field
    Rectangle {
        id: sessionPopup
        visible: false
        width: loginContainer.width
        height: Math.min(sessionModel.count * loginContainer.height * 0.11 + loginContainer.height * 0.006, loginContainer.height * 0.56)
        anchors {
            left: loginContainer.left
            top: loginContainer.top
            topMargin: loginContainer.height * 0.335
        }
        color: bgColor
        border.color: accentColor
        border.width: Math.max(loginContainer.width * 0.003, 1)
        z: 1000
        
        ListView {
            id: sessionList
            anchors.fill: parent
            anchors.margins: 1
            model: sessionModel
            currentIndex: sessionIndex
            clip: true
            
            delegate: Rectangle {
                width: parent.width
                height: loginContainer.height * 0.11
                color: delegateMouse.containsMouse ? containerColor : (index === sessionIndex ? borderColor : "transparent")
                
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.04
                    anchors.verticalCenter: parent.verticalCenter
                    text: name
                    font.family: agaveFont.name
                    antialiasing: true
                    font.pixelSize: Math.max(parent.width * 0.04, 11)
                    color: fgColor
                }
                
                MouseArea {
                    id: delegateMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sessionIndex = index
                        sessionPopup.visible = false
                    }
                }
            }
        }
    }
    
    // Status indicators and controls
    Column {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: parent.height * 0.04
        }
        spacing: parent.height * 0.015
        
        // Top row - indicators and theme toggle
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: parent.width * 0.015
        
        
            // Caps Lock indicator
            Rectangle {
                width: Math.max(root.width * 0.07, 70)
                height: Math.max(root.height * 0.04, 35)
                color: capsLockOn ? accentColor : "transparent"
                border.color: capsLockOn ? accentColor : borderColor
                border.width: Math.max(root.width * 0.001, 1)
                radius: Math.max(root.width * 0.004, 3)
                opacity: capsLockOn ? 1.0 : 0.5
                
                Text {
                    anchors.centerIn: parent
                    text: "CAPS"
                    font.family: agaveFont.name
                    antialiasing: true
                    font.pixelSize: Math.min(Math.max(parent.width * 0.25, 12), 16)
                    font.letterSpacing: parent.width * 0.02
                    color: capsLockOn ? bgColor : grayZero
                }
            }
            
            // Theme toggle button
            Rectangle {
                width: Math.max(root.width * 0.05, 50)
                height: Math.max(root.height * 0.04, 35)
                color: grayFour
                radius: Math.max(root.width * 0.004, 3)
                
                Text {
                    anchors.centerIn: parent
                    text: isDark ? "☀" : "🌙"
                    font.pixelSize: Math.min(Math.max(parent.width * 0.4, 16), 22)
                    color: bgColor
                }
                
                MouseArea {
                    id: themeToggleMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: isDark = !isDark
                }
            }
        }
        
        // Clock - bottom row
        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: agaveFont.name
                antialiasing: true
            font.pixelSize: Math.max(root.width * 0.014, 14)
            color: grayOne
            
            function updateTime() {
                text = new Date().toLocaleString(Qt.locale(), "dddd, MMMM d • hh:mm")
            }
            
            Timer {
                interval: 1000
                repeat: true
                running: true
                triggeredOnStart: true
                onTriggered: clock.updateTime()
            }
        }
    }
    
    
    
    // Settings persistence functions
    function saveSettings() {
        try {
            var settings = {
                "theme": isDark ? "dark" : "light",
                "session": sessionIndex
            }
            // Используем встроенный механизм SDDM для сохранения настроек
            if (typeof sddm !== 'undefined' && sddm.configuration) {
                sddm.configuration.setValue("theme", settings.theme)
                sddm.configuration.setValue("sessionIndex", settings.session)
            }
        } catch (e) {
            console.log("Could not save settings: " + e)
        }
    }
    
    function loadSettings() {
        try {
            // Загружаем настройки из конфигурации SDDM
            if (typeof sddm !== 'undefined' && sddm.configuration) {
                var savedTheme = sddm.configuration.value("theme", "dark")
                var savedSession = sddm.configuration.value("sessionIndex", sessionModel.lastIndex)
                
                isDark = (savedTheme === "dark")
                if (savedSession >= 0 && savedSession < sessionModel.count) {
                    sessionIndex = savedSession
                }
            }
        } catch (e) {
            console.log("Could not load settings: " + e)
            // Используем значения по умолчанию
            isDark = true
            sessionIndex = sessionModel.lastIndex
        }
    }
    
    // Keyboard event handlers and layout detection
    Keys.onPressed: {
        if (event.key === Qt.Key_CapsLock) {
            capsLockOn = !capsLockOn
        }
    }
    
    // Keyboard layout detection
    function updateCurrentLayout() {
        try {
            // Попытка получить текущую раскладку из системы
            if (typeof keyboard !== 'undefined' && keyboard.layouts) {
                var currentIdx = keyboard.currentLayout
                if (currentIdx >= 0 && currentIdx < layouts.length) {
                    currentLayout = currentIdx
                    return
                }
            }
            
            // Резервный метод - получение раскладки через Qt
            if (typeof Qt !== 'undefined' && Qt.locale) {
                var locale = Qt.locale().name
                if (locale.startsWith("ru")) currentLayout = 1
                else if (locale.startsWith("de")) currentLayout = 2
                else if (locale.startsWith("fr")) currentLayout = 3
                else currentLayout = 0 // EN по умолчанию
            }
        } catch (e) {
            // Если ничего не работает, оставляем EN
            currentLayout = 0
        }
    }
    
    // Watch for theme changes
    onIsDarkChanged: saveSettings()
    onSessionIndexChanged: saveSettings()
    
    Component.onCompleted: {
        loadSettings()
        password.focus = true
        root.focus = true  // Needed to catch keyboard events
    }
}