#include <QApplication>
#include <QQmlApplicationEngine>
#include "game.h"
#include "translator.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    Translator translator(&app);
    translator.setSystemLanguage();

    QQmlApplicationEngine viewer;
    viewer.load(QUrl(QStringLiteral("qrc:///main.qml")));

    QObject *rootObject = viewer.rootObjects().first();
    QObject *qmlObject = rootObject->findChild<QObject*>("window");

    translator.setViewer(qmlObject);
    viewer.rootContext()->setContextProperty("Translator", &translator);

    Game game(qmlObject);
    viewer.rootContext()->setContextProperty("Game", &game);

    return app.exec();
}
