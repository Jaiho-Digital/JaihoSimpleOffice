#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QDir>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("Jaiho Digital");
    QCoreApplication::setApplicationName("SimpleConvert");
    QGuiApplication::setApplicationDisplayName("Jaiho SimpleConvert");

    QQmlApplicationEngine engine;

    const QString appDir = QCoreApplication::applicationDirPath();
    engine.addImportPath(QDir(appDir).filePath("qml"));

    engine.loadFromModule("Jaiho.SimpleConvert", "Main");

    if (engine.rootObjects().isEmpty())
        return 1;

    return app.exec();
}
