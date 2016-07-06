#ifndef FIGURE_H
#define FIGURE_H

#include <QObject>
#include <QDebug>
#include <QQmlContext>
#include <QDesktopServices>
#include <QGuiApplication>

class Figure : public QObject
{
    Q_OBJECT

private:
    int positionX;
    int positionY;

public:
    Figure(QObject *QMLObject) : viewer(QMLObject) {}

    Figure(int x, int y) {
        positionX = x;
        positionY = y;
    }

    Figure() {}

    void setPositionX(int);
    void setPositionY(int);

    int getPositionX() const;
    int getPositionY() const;
    QObject* getViewer() const;

signals:

public slots:
    virtual void draw(int, int) = 0;

protected:
    QObject *viewer;
};

#endif // FIGURE_H
