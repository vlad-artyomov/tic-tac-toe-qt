#ifndef PLAYER_H
#define PLAYER_H
#include "figure.h"

enum FigureType {
    X,
    O,
    BLANK
};

class Player
{
private:
    FigureType figureType;
    QString name;
    unsigned int winCount = 0;
    unsigned int looseCount = 0;

public:
    Player();

    Player(FigureType type, QString name) {
        figureType = type;
        this->name = name;
    }

    FigureType getFigureType() { return figureType; }
    QString getName() { return name; }
    unsigned int getWinCount() { return winCount; }
    unsigned int getLooseCount() { return looseCount; }

    void setFigureType(FigureType type) { figureType = type; }
    void setName(QString n) { name = n; }
    void setWinCount(unsigned int w) { winCount = w; }
    void setLooseCount(unsigned int l) { looseCount = l; }
};

#endif // PLAYER_H
