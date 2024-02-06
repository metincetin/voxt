#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <KLocalizedContext>
#include <KLocalizedString>
#include "qquickstyle.h"

int main(int argc, char *argv[])
{

    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(QStringLiteral("org.kde.breeze"));    
        QQuickStyle::setFallbackStyle(QStringLiteral("Fusion"));
    }


    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("voxt");
    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("metin.org"));
    QCoreApplication::setApplicationName(QStringLiteral("Voxt"));

    QQmlApplicationEngine engine;

    qDebug()<<"Your local data will be stored at: "<<engine.offlineStoragePath();

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));


    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}

