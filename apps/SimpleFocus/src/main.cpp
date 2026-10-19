#include <QGuiApplication>
#include <QFile>
#include <QDir>
#include <QTextStream>
#include <QDateTime>
#include <QStandardPaths>
#include <QQmlError>
#include <windows.h>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include <QSettings>
#include <QObject>
#include <QString>

class FocusController final : public QObject {
    Q_OBJECT
    Q_PROPERTY(int remainingSeconds READ remainingSeconds NOTIFY changed)
    Q_PROPERTY(bool running READ running NOTIFY changed)
    Q_PROPERTY(bool focusMode READ focusMode NOTIFY changed)
    Q_PROPERTY(int completedSessions READ completedSessions NOTIFY changed)
    Q_PROPERTY(int focusedMinutes READ focusedMinutes NOTIFY changed)
    Q_PROPERTY(QString taskTitle READ taskTitle WRITE setTaskTitle NOTIFY changed)
    Q_PROPERTY(bool darkTheme READ darkTheme WRITE setDarkTheme NOTIFY changed)

public:
    explicit FocusController(QObject *parent = nullptr)
        : QObject(parent), settings(QStringLiteral("Jaiho Digital"),
                                   QStringLiteral("SimpleFocus")) {
        sessions = settings.value("completedSessions", 0).toInt();
        minutes = settings.value("focusedMinutes", 0).toInt();
        dark = settings.value("darkTheme", false).toBool();
        task = settings.value("taskTitle", QString()).toString();
        timer.setInterval(1000);
        connect(&timer, &QTimer::timeout, this, [this] {
            if (seconds > 0) --seconds;
            if (seconds == 0) finishSession();
            emit changed();
        });
    }

    int remainingSeconds() const { return seconds; }
    bool running() const { return timer.isActive(); }
    bool focusMode() const { return focus; }
    int completedSessions() const { return sessions; }
    int focusedMinutes() const { return minutes; }
    QString taskTitle() const { return task; }
    bool darkTheme() const { return dark; }

    void setTaskTitle(const QString &value) {
        if (task == value) return;
        task = value;
        settings.setValue("taskTitle", task);
        emit changed();
    }

    void setDarkTheme(bool value) {
        if (dark == value) return;
        dark = value;
        settings.setValue("darkTheme", dark);
        emit changed();
    }

    Q_INVOKABLE void toggleTimer() {
        if (timer.isActive()) timer.stop();
        else timer.start();
        emit changed();
    }

    Q_INVOKABLE void resetTimer() {
        timer.stop();
        seconds = focus ? focusDuration * 60 : breakDuration * 60;
        emit changed();
    }

    Q_INVOKABLE void setMode(bool useFocus) {
        timer.stop();
        focus = useFocus;
        seconds = focus ? focusDuration * 60 : breakDuration * 60;
        emit changed();
    }

    Q_INVOKABLE void setDurations(int focusMinutesValue, int breakMinutesValue) {
        focusDuration = qBound(1, focusMinutesValue, 180);
        breakDuration = qBound(1, breakMinutesValue, 60);
        resetTimer();
    }

signals:
    void changed();
    void sessionFinished(bool wasFocus);

private:
    void finishSession() {
        timer.stop();
        const bool finishedFocus = focus;
        if (finishedFocus) {
            ++sessions;
            minutes += focusDuration;
            settings.setValue("completedSessions", sessions);
            settings.setValue("focusedMinutes", minutes);
        }
        focus = !focus;
        seconds = focus ? focusDuration * 60 : breakDuration * 60;
        emit sessionFinished(finishedFocus);
    }

    QTimer timer;
    QSettings settings;
    int seconds = 25 * 60;
    int focusDuration = 25;
    int breakDuration = 5;
    int sessions = 0;
    int minutes = 0;
    bool focus = true;
    bool dark = false;
    QString task;
};

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QGuiApplication::setOrganizationName(QStringLiteral("Jaiho Digital"));
    QGuiApplication::setApplicationName(QStringLiteral("SimpleFocus"));
    QGuiApplication::setApplicationDisplayName(QStringLiteral("Jaiho SimpleFocus"));

    const QString logDir = QStandardPaths::writableLocation(
        QStandardPaths::AppLocalDataLocation);
    QDir().mkpath(logDir);
    const QString logPath = logDir + QStringLiteral("/SimpleFocus-startup.log");

    QFile::remove(logPath);
    auto log = [&logPath](const QString &message) {
        QFile file(logPath);
        if (file.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
            QTextStream out(&file);
            out << QDateTime::currentDateTime().toString(Qt::ISODate)
                << "  " << message << Qt::endl;
        }
    };

    log(QStringLiteral("Startup began"));
    log(QStringLiteral("Application directory: ") + QCoreApplication::applicationDirPath());

    FocusController controller;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(
        QStringLiteral("focusController"), &controller);

    QObject::connect(&engine, &QQmlApplicationEngine::warnings, &engine,
        [&log](const QList<QQmlError> &warnings) {
            for (const auto &warning : warnings)
                log(QStringLiteral("QML WARNING: ") + warning.toString());
        });

    log(QStringLiteral("Loading QML module Jaiho.SimpleFocus / Main"));
    engine.loadFromModule(QStringLiteral("Jaiho.SimpleFocus"),
                          QStringLiteral("Main"));

    log(QStringLiteral("Root object count: ") +
        QString::number(engine.rootObjects().size()));

    if (engine.rootObjects().isEmpty()) {
        log(QStringLiteral("FATAL: QML root object was not created"));
        MessageBoxW(nullptr,
            L"SimpleFocus could not create its window. Startup details are saved in the log.",
            L"Jaiho SimpleFocus - Startup Error",
            MB_OK | MB_ICONERROR);
        return 1;
    }

    log(QStringLiteral("Window created; entering event loop"));
    return app.exec();
}

#include "main.moc"

