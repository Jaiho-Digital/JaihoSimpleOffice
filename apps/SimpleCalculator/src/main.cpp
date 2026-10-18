#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCoreApplication>
#include <QDir>
#include <QtQml>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("Jaiho Digital");
    QCoreApplication::setApplicationName("SimpleCalculator");
    QGuiApplication::setApplicationDisplayName("Jaiho SimpleCalculator");

    QQmlApplicationEngine engine;

    const QString appDir = QCoreApplication::applicationDirPath();
    engine.addImportPath(QDir(appDir).filePath("qml"));

    engine.loadFromModule("Jaiho.SimpleCalculator", "Main");

    if (engine.rootObjects().isEmpty())
        return 1;

    return app.exec();
}
