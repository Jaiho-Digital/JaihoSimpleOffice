#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QDebug>
#include <QQmlError>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("Jaiho Digital");
    QCoreApplication::setApplicationName("SimpleCalendar");
    QGuiApplication::setApplicationDisplayName("Jaiho SimpleCalendar");

    QQmlApplicationEngine engine;

    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
                     [](const QList<QQmlError> &warnings) {
        for (const QQmlError &error : warnings)
            qCritical().noquote() << error.toString();
    });

    engine.loadFromModule("Jaiho.SimpleCalendar", "Main");

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "SimpleCalendar failed to load its QML window.";
        return 1;
    }

    return app.exec();
}
