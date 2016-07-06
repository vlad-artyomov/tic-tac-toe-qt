#ifndef TRANSLATOR_H
#define TRANSLATOR_H
#include <QObject>
#include <QDebug>
#include <QQmlContext>
#include <QDesktopServices>
#include <QGuiApplication>
#include <QTranslator>
#include <QSettings>

class Translator : public QObject
{
    Q_OBJECT

public:
    Translator (QGuiApplication *app) {
        application = app;
        english.load("languages/lang_en_EN", ":/");
    }

    void setApp(QGuiApplication *app) {
        application = app;
    }

    void setViewer(QObject *value) {
        viewer = value;
        viewer->setProperty("emptyString", "");

        if (QLocale::system().name() != "ru_RU") {
            viewer->setProperty("language", "English");
        }
        else {
            viewer->setProperty("language", "Русский");
        }

    }

    void setSystemLanguage() {
        QSettings settings("DonNTU", "TicTacToe");

        if (settings.contains("language")) {
            if (settings.value("language") == "English") {
                application->installTranslator(&english);
            }
        }

        else {
            if (QLocale::system().name() != "ru_RU") {
                application->installTranslator(&english);
                settings.setValue("language", "English");
            }
            else {
                settings.setValue("language", "Русский");
            }
        }
    }

signals:

public slots:
    void changeLanguage(QString lang) {
        QSettings settings("DonNTU", "TicTacToe");

        if (lang == "Русский") {
            application->removeTranslator(&english);
            viewer->setProperty("language", "Русский");
            settings.setValue("language", "Русский");
        }
        else {
            application->installTranslator(&english);
            viewer->setProperty("language", "English");
            settings.setValue("language", "English");
        }
        viewer->setProperty("emptyString", " ");
        viewer->setProperty("emptyString", "");
    }

protected:
    QObject *viewer;
    QGuiApplication *application;
    QTranslator english;
};

#endif // TRANSLATOR_H
