#ifndef GAME_H
#define GAME_H
#include <QObject>
#include <QDebug>
#include <QQmlContext>
#include <QDesktopServices>
#include <QGuiApplication>
#include "field.h"
#include "player.h"

class Game : public QObject
{
    Q_OBJECT

private:
    Field field;
    Player p1;
    Player p2;
    bool running;
    bool AImode;
    bool AIgoFirst;
    int winLength;
    int movesCount;
    FigureType nextMove;
    QVector<QVector<FigureType> > board;
    double difficulty;
    double agression;
    bool AIvsAI;

    void refreshBoard(int size);
    bool checkWin(int x, int y, FigureType currentFigure);
    void AImove(FigureType AIfigure);
    void delay(int millisecondsToWait);
    void showResult(QList<int> positions, FigureType winner);

public:
    Game(QObject *QMLObject);

signals:

public slots:
    void start();
    void restart();
    void move(int, int);

    void setAImode(bool val);
    void setAIgoFirst(bool val);
    void setDifficulty(double val);
    bool getAIgoFirst();
    double getDifficulty();
    int getFieldSize();
    void setFieldSize(int val);
    void setTheme(QString val);

    void aiBattleStart(int);
    void doAImove();

protected:
    QObject *viewer;
};

#endif // GAME_H
