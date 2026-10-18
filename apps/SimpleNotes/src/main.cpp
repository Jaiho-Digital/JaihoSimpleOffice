#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QTextStream>
#include <QVariantList>
#include <QVariantMap>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QDebug>
#include <QObject>
#include <QDateTime>
#include <QMessageLogContext>

#ifdef Q_OS_WIN
#  define WIN32_LEAN_AND_MEAN
#  include <windows.h>
#endif

namespace {
QString startupLogPath;

void startupMessageHandler(QtMsgType type,
                          const QMessageLogContext &context,
                          const QString &message)
{
    Q_UNUSED(context);

    QFile file(startupLogPath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        QTextStream out(&file);
        QString level;
        switch (type) {
        case QtDebugMsg:    level = QStringLiteral("DEBUG"); break;
        case QtInfoMsg:     level = QStringLiteral("INFO"); break;
        case QtWarningMsg:  level = QStringLiteral("WARNING"); break;
        case QtCriticalMsg: level = QStringLiteral("CRITICAL"); break;
        case QtFatalMsg:    level = QStringLiteral("FATAL"); break;
        }
        out << QDateTime::currentDateTime().toString(Qt::ISODateWithMs)
            << " [" << level << "] " << message << Qt::endl;
    }

#ifdef Q_OS_WIN
    OutputDebugStringW((message + QLatin1Char('\n')).toStdWString().c_str());
#endif

    if (type == QtFatalMsg)
        abort();
}

void showStartupError(const QString &message)
{
#ifdef Q_OS_WIN
    const QString title = QStringLiteral("Jaiho SimpleNotes could not start");
    MessageBoxW(nullptr, message.toStdWString().c_str(),
                title.toStdWString().c_str(),
                MB_OK | MB_ICONERROR | MB_TASKMODAL);
#else
    qCritical().noquote() << message;
#endif
}
}

class NotesStore final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList notes READ notes NOTIFY notesChanged)
    Q_PROPERTY(QString searchQuery READ searchQuery
               WRITE setSearchQuery NOTIFY notesChanged)

public:
    explicit NotesStore(QObject *parent = nullptr)
        : QObject(parent)
    {
        const QString dataDirectory =
            QStandardPaths::writableLocation(
                QStandardPaths::AppLocalDataLocation);

        if (!QDir().mkpath(dataDirectory)) {
            qWarning() << "Cannot create notes data directory:" << dataDirectory;
            return;
        }

        m_database = QSqlDatabase::addDatabase(
            QStringLiteral("QSQLITE"),
            QStringLiteral("SimpleNotesConnection"));
        m_database.setDatabaseName(dataDirectory + QStringLiteral("/notes.db"));

        if (!m_database.open()) {
            qWarning() << "Database open failed:" << m_database.lastError().text();
            return;
        }

        QSqlQuery query(m_database);
        if (!query.exec(R"(
            CREATE TABLE IF NOT EXISTS notes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                body TEXT NOT NULL DEFAULT '',
                updated_at TEXT NOT NULL DEFAULT (datetime('now'))
            )
        )")) {
            qWarning() << "Database initialization failed:" << query.lastError().text();
            return;
        }

        m_ready = true;
        qInfo() << "Notes database ready at" << m_database.databaseName();
    }

    QVariantList notes() const
    {
        QVariantList result;
        if (!m_ready)
            return result;

        QSqlQuery query(m_database);
        query.prepare(R"(
            SELECT id, title, body, updated_at
            FROM notes
            WHERE title LIKE ? OR body LIKE ?
            ORDER BY updated_at DESC, id DESC
        )");
        const QString pattern = QStringLiteral("%") + m_searchQuery + QStringLiteral("%");
        query.addBindValue(pattern);
        query.addBindValue(pattern);

        if (!query.exec()) {
            qWarning() << "Reading notes failed:" << query.lastError().text();
            return result;
        }

        while (query.next()) {
            QVariantMap note;
            note.insert("id", query.value(0));
            note.insert("title", query.value(1));
            note.insert("body", query.value(2));
            note.insert("updatedAt", query.value(3));
            result.append(note);
        }
        return result;
    }

    QString searchQuery() const { return m_searchQuery; }

    void setSearchQuery(const QString &query)
    {
        if (m_searchQuery == query)
            return;
        m_searchQuery = query;
        emit notesChanged();
    }

    Q_INVOKABLE qint64 saveNote(qint64 id, const QString &title, const QString &body)
    {
        if (!m_ready)
            return 0;

        QString cleanTitle = title.trimmed();
        const QString cleanBody = body.trimmed();
        if (cleanTitle.isEmpty() && cleanBody.isEmpty())
            return 0;
        if (cleanTitle.isEmpty())
            cleanTitle = cleanBody.left(40);

        QSqlQuery query(m_database);
        if (id > 0) {
            query.prepare(R"(
                UPDATE notes SET title = ?, body = ?, updated_at = datetime('now')
                WHERE id = ?
            )");
            query.addBindValue(cleanTitle);
            query.addBindValue(body);
            query.addBindValue(id);

            if (!query.exec()) {
                qWarning() << "Updating note failed:" << query.lastError().text();
                return 0;
            }
            if (query.numRowsAffected() == 0) {
                QSqlQuery check(m_database);
                check.prepare("SELECT id FROM notes WHERE id = ?");
                check.addBindValue(id);
                if (!check.exec() || !check.next())
                    return 0;
            }
            emit notesChanged();
            return id;
        }

        query.prepare("INSERT INTO notes (title, body) VALUES (?, ?)");
        query.addBindValue(cleanTitle);
        query.addBindValue(body);
        if (!query.exec()) {
            qWarning() << "Creating note failed:" << query.lastError().text();
            return 0;
        }

        const qint64 newId = query.lastInsertId().toLongLong();
        emit notesChanged();
        return newId;
    }

    Q_INVOKABLE bool deleteNote(qint64 id)
    {
        if (!m_ready || id <= 0)
            return false;

        QSqlQuery query(m_database);
        query.prepare("DELETE FROM notes WHERE id = ?");
        query.addBindValue(id);
        if (!query.exec() || query.numRowsAffected() != 1) {
            qWarning() << "Deleting note failed:" << query.lastError().text();
            return false;
        }
        emit notesChanged();
        return true;
    }

    Q_INVOKABLE bool isReady() const { return m_ready; }

signals:
    void notesChanged();

private:
    QSqlDatabase m_database;
    QString m_searchQuery;
    bool m_ready = false;
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Keep deployed builds independent of machine-wide Qt environment paths.
    const QString applicationDirectory = QCoreApplication::applicationDirPath();
    QCoreApplication::addLibraryPath(applicationDirectory);

    QCoreApplication::setOrganizationName("Jaiho Digital");
    QCoreApplication::setApplicationName("SimpleNotes");
    QGuiApplication::setApplicationDisplayName("Jaiho SimpleNotes");

    const QString dataDirectory =
        QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    QDir().mkpath(dataDirectory);
    startupLogPath = dataDirectory + QStringLiteral("/startup.log");

    // Start each diagnostic run with a fresh log.
    QFile::remove(startupLogPath);
    qInstallMessageHandler(startupMessageHandler);
    qInfo() << "SimpleNotes startup; Qt version:" << qVersion();
    qInfo() << "Application directory:" << QCoreApplication::applicationDirPath();
    qInfo() << "Startup log:" << startupLogPath;

    NotesStore notesStore;
    QQmlApplicationEngine engine;
    engine.addImportPath(QDir(applicationDirectory).filePath(QStringLiteral("qml")));
    engine.rootContext()->setContextProperty("notesStore", &notesStore);

    qInfo() << "Loading QML module Jaiho.SimpleNotes / Main";
    engine.loadFromModule("Jaiho.SimpleNotes", "Main");

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "QML engine did not create a root window.";
        QFile logFile(startupLogPath);
        QString details;
        if (logFile.open(QIODevice::ReadOnly | QIODevice::Text))
            details = QString::fromUtf8(logFile.readAll());

        if (details.isEmpty())
            details = QStringLiteral("No Qt diagnostic messages were recorded.");

        showStartupError(
            QStringLiteral("SimpleNotes could not load its main window.\n\n"
                           "A startup log was saved here:\n%1\n\n"
                           "Recent details:\n%2")
                .arg(startupLogPath, details.right(3500)));
        return 1;
    }

    qInfo() << "Main window created successfully.";
    return app.exec();
}

#include "main.moc"
