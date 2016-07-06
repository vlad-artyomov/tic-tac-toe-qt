#include "game.h"
#include "cross.h"
#include "zero.h"
#include <QTime>
#include <QtCore/qmath.h>
#include <QSettings>

Game::Game(QObject *QMLObject) : viewer(QMLObject) {
    qsrand(QTime::currentTime().msec());
    QSettings settings("DonNTU", "TicTacToe");

    field.setSize(settings.value("size", 5).toInt());
    viewer->findChild<QObject*>("field")->setProperty("size", field.getSize());
    if (field.getSize() == 3) winLength = 3;
    else if (field.getSize() == 5) winLength = 4;
    else winLength = 5;

    running = false;
    nextMove = X;
    movesCount = 0;
    AImode = false;
    AIvsAI = false;
    agression = 0.8;

    difficulty = settings.value("difficulty", 0.75).toDouble();
    AIgoFirst = settings.value("AIgoFirst", false).toBool();

    p1.setFigureType(X);
    p2.setFigureType(O);
    p1.setName("Игрок 1");
    p2.setName("Игрок 2");

    viewer->setProperty("difficulty", difficulty);
    viewer->setProperty("aiGoFirst", AIgoFirst);
    viewer->setProperty("fieldSize", field.getSize());
    viewer->setProperty("language", settings.value("language", "Русский").toString());

    if (settings.value("theme", "2048").toString() == "Habrahabr") {
        QMetaObject::invokeMethod(viewer, "setThemeHabrahabr");
    }
    else if (settings.value("theme", "2048").toString() == "Dark side") {
        QMetaObject::invokeMethod(viewer, "setThemeDarkside");
    }
    else {
        QMetaObject::invokeMethod(viewer, "setThemeDefault");
    }

    refreshBoard(field.getSize());
}

void Game::refreshBoard(int size) {
    board.resize(size);
    for(int i=0; i<size; i++) {
        board[i].resize(size);
        board[i].fill(BLANK);
    }
    movesCount = 0;
}

void Game::setAImode(bool val) {
    AImode = val;
}

void Game::setTheme(QString val) {
    QSettings settings("DonNTU", "TicTacToe");
    settings.setValue("theme", val);
}

void Game::setAIgoFirst(bool val) {
    AIgoFirst = val;
    QSettings settings("DonNTU", "TicTacToe");
    settings.setValue("AIgoFirst", val);
}

void Game::setDifficulty(double val) {
    difficulty = val;
    QSettings settings("DonNTU", "TicTacToe");
    settings.setValue("difficulty", val);
}

double Game::getDifficulty() {
    return difficulty;
}

bool Game::getAIgoFirst() {
    return AIgoFirst;
}

void Game::start() {
    running = true;
    movesCount = 0;

    p1.setWinCount(0);
    p1.setLooseCount(0);
    p2.setWinCount(0);
    p2.setLooseCount(0);

    restart();

    QMetaObject::invokeMethod(viewer->findChild<QObject*>("stats"), "updateStats",
                              Q_ARG(QVariant, p1.getWinCount()),
                              Q_ARG(QVariant, p2.getWinCount()));
}

void Game::restart() {
    field.clearField();
    nextMove = X;
    movesCount = 0;
    refreshBoard(field.getSize());
    QMetaObject::invokeMethod(viewer->findChild<QObject*>("stats"), "restart");

    qDebug() << "Game restarted!";
}

void Game::delay(int millisecondsToWait) {
    QTime dieTime = QTime::currentTime().addMSecs(millisecondsToWait);
    while(QTime::currentTime() < dieTime)
    {
        QCoreApplication::processEvents(QEventLoop::AllEvents, 100);
    }
}

void Game::doAImove() {
    if (AIgoFirst && AImode) {
        AImove(X);
        nextMove = O;
    }
}

void Game::AImove(FigureType AIfigure) {
    int x = 0;
    int y = 0;
    QSet<QPair<int, int> > freeCells;
    QPair<int, int> cell;
    FigureType opponentFigure = X;

    if (AIfigure == X) {
        opponentFigure = O;
    }

    int worryLength = 2;
    if (winLength == 5) worryLength = 3;
    if (winLength == 4) worryLength = 2;

    //Получаем позиции свободных ячеек, находящихся рядом со всеми занятыми ячейками, исключив повторы
    for(int i=0; i<field.getFiguresCount(); i++) {
        x = field.getFigure(i)->getPositionX();
        y = field.getFigure(i)->getPositionY();

        //top left
        if ((x - 1) >= 0 && (y - 1) >= 0) {
            cell.first = (x - 1);
            cell.second = (y - 1);
            if (board[cell.first][cell.second] == BLANK)
                freeCells.insert(cell);
        }

        //top
        if ((x - 1) >= 0) {
            cell.first = (x - 1);
            cell.second = y;
            if (board[cell.first][cell.second] == BLANK)
                freeCells.insert(cell);
        }

        //top right
        if ((x - 1) >= 0 && (y + 1) < board.length()) {
            cell.first = (x - 1);
            cell.second = (y + 1);
            if (board[cell.first][cell.second] == BLANK)
                freeCells.insert(cell);
        }

        //right
        if ((y + 1) < board.length()) {
            cell.first = x;
            cell.second = (y + 1);
            if (board[cell.first][cell.second] == BLANK)
                freeCells.insert(cell);
        }

        //right bottom
        if ((x + 1) < board.length() && (y + 1) < board.length()) {
            cell.first = (x + 1);
            cell.second = (y + 1);
            if (board[cell.first][cell.second] == BLANK)
                freeCells.insert(cell);
        }

        //bottom
        if ((x + 1) < board.length()) {
            cell.first = (x + 1);
            cell.second = y;
            if (board[cell.first][cell.second] == BLANK)
                freeCells.insert(cell);
        }

        //left bottom
        if ((x + 1) < board.length() && (y - 1) >= 0) {
            cell.first = (x + 1);
            cell.second = (y - 1);
            if (board[cell.first][cell.second] == BLANK)
                freeCells.insert(cell);
        }

        //left
        if ((y - 1) >= 0) {
            cell.first = x;
            cell.second = (y - 1);
            if (board[cell.first][cell.second] == BLANK)
                freeCells.insert(cell);
        }
    }


    //Получаем оценку каждой ячейки, из выбранных выше
    QList<QPair<int, int> > checkList = freeCells.toList();
    QMap<double, QPair<int, int> > ratings;


    for(int i=0; i < checkList.length(); i++) {

        int minX;
        int maxX;
        int minY;
        int maxY;
        double thisPrice = 0;
        double opponentPrice = 0;
        x = checkList[i].first;
        y = checkList[i].second;
        double horizontalPrice = 0;
        double verticalPrice = 0;
        double diagonalPrice = 0;
        double antiDiagonalPrice = 0;
        int stopAttack = false;

        //Оценка горизонтали
        minX = x - (winLength - 1);
        if (minX < 0) minX = 0;
        maxX = x + (winLength - 1);
        if (maxX >= board.size()) maxX = board.size() - 1;

        for(int j=minX; j<=maxX; j++) {
            if (j + winLength > maxX + 1) {
                break;
            }
            else {
                thisPrice = 0;
                stopAttack = false;
                for(int k=j; k<j+winLength; k++) {
                    if (board[k][y] != AIfigure && board[k][y] != BLANK) {
                        thisPrice = 0;
                        break;
                    }
                    if (board[k][y] == AIfigure) {
                        thisPrice++;
                    }
                    else {
                        thisPrice += 0.2;
                    }
                }

                //BUG FIX start
                if (board[j][y] == BLANK && board[j+winLength-1][y] == BLANK) {
                    stopAttack = true;
                    if (thisPrice >= worryLength) {
                        horizontalPrice += 2000;
                    }
                }
                //BUG FIX end

                if (thisPrice >= winLength - 1) {
                    horizontalPrice += 10000;
                }
                if (thisPrice > 0 && thisPrice < winLength) {
                    horizontalPrice += qPow(3, thisPrice);
                }
            }
        }

        for(int j=minX; j<=maxX; j++) {
            if (j + winLength > maxX + 1) {
                break;
            }
            else {
                opponentPrice = 0;
                stopAttack = false;
                for(int k=j; k<j+winLength; k++) {
                    if (board[k][y] != AIfigure && board[k][y] != BLANK) {
                        opponentPrice++;
                    }
                    if (board[k][y] == AIfigure) {
                        opponentPrice = 0;
                        break;
                    }
                }

                //BUG FIX start
                if (board[j][y] == BLANK && board[j+winLength-1][y] == BLANK) {
                    stopAttack = true;
                    if (opponentPrice >= worryLength) {
                        horizontalPrice += 2000*agression;
                    }
                }
                //BUG FIX end

                if (opponentPrice >= winLength - 1) {
                    horizontalPrice += 3500*agression;
                }
                if (opponentPrice > 0 && opponentPrice < winLength) {
                    horizontalPrice += agression * qPow(3, opponentPrice);
                }
            }
        }

        //Просчет вариант с выгодным ходом, гарантирующим победу на след. ходу
        if (winLength == 5) {
            bool fl = false;
            if (x-3 >= 0 && x+2 <= board.length()) {
                if (board[x-3][y] == BLANK && board[x-2][y] == AIfigure && board[x-1][y] == AIfigure && board[x+1][y] == AIfigure &&
                        board[x+2][y] == BLANK) {
                    horizontalPrice += 2000;
                    fl = true;
                }
            }
            if (x-2 >= 0 && x+3 <= board.length()) {
                if (board[x-2][y] == BLANK && board[x-1][y] == AIfigure && board[x+1][y] == AIfigure && board[x+2][y] == AIfigure &&
                        board[x+3][y] == BLANK) {
                    horizontalPrice += 2000;
                    fl = true;
                }
            }
            if (x-3 >= 0 && x+2 <= board.length()) {
                if (board[x-3][y] == BLANK && board[x-2][y] == opponentFigure && board[x-1][y] == opponentFigure
                        && board[x+1][y] == opponentFigure && board[x+2][y] == BLANK) {
                    horizontalPrice += 2000*agression;;
                    fl = true;
                }
            }
            if (x-2 >= 0 && x+3 <= board.length()) {
                if (board[x-2][y] == BLANK && board[x-1][y] == opponentFigure && board[x+1][y] == opponentFigure
                        && board[x+2][y] == opponentFigure && board[x+3][y] == BLANK) {
                    horizontalPrice += 2000*agression;;
                    fl = true;
                }
            }
            if (fl) qDebug() << "Выгодный ход сделан/блокирован - горизонталь";
        }
        //qDebug() <<  "Horizontal price =" << horizontalPrice;


        //Оценка вертикали
        minY = y - (winLength - 1);
        if (minY < 0) minY = 0;
        maxY = y + (winLength - 1);
        if (maxY >= board.size()) maxY = board.size() - 1;

        for(int j=minY; j<=maxY; j++) {
            if (j + winLength > maxY + 1) {
                break;
            }
            else {
                thisPrice = 0;
                stopAttack = false;
                for(int k=j; k<j+winLength; k++) {
                    if (board[x][k] != AIfigure && board[x][k] != BLANK) {
                        thisPrice = 0;
                        break;
                    }
                    if (board[x][k] == AIfigure) {
                        thisPrice++;
                    }
                    else {
                        thisPrice += 0.2;
                    }
                }

                //BUG FIX start
                if (board[x][j] == BLANK && board[x][j+winLength-1] == BLANK) {
                    stopAttack = true;
                    if (thisPrice >= worryLength) {
                        verticalPrice += 2000;
                    }
                }
                //BUG FIX end

                if (thisPrice >= winLength - 1) {
                    verticalPrice += 10000;
                }
                if (thisPrice > 0 && thisPrice < winLength) {
                    verticalPrice += qPow(3, thisPrice);
                }
            }
        }

        for(int j=minY; j<=maxY; j++) {
            if (j + winLength > maxY + 1) {
                break;
            }
            else {
                opponentPrice = 0;
                stopAttack = false;
                for(int k=j; k<j+winLength; k++) {
                    if (board[x][k] != AIfigure && board[x][k] != BLANK) {
                        opponentPrice++;
                    }
                    if (board[x][k] == AIfigure) {
                        opponentPrice = 0;
                        break;
                    }
                }

                //BUG FIX start
                if (board[x][j] == BLANK && board[x][j+winLength-1] == BLANK) {
                    stopAttack = true;
                    if (opponentPrice >= worryLength) {
                        verticalPrice += 2000*agression;
                    }
                }
                //BUG FIX end

                if (opponentPrice >= winLength - 1) {
                    verticalPrice += 3500*agression;
                }
                if (opponentPrice > 0 && opponentPrice < winLength) {
                    verticalPrice += agression * qPow(3, opponentPrice);
                }
            }
        }
        //Просчет вариант с выгодным ходом, гарантирующим победу на след. ходу
        if (winLength == 5) {
            bool fl = false;
            if (y-3 >= 0 && y+2 <= board.length()) {
                if (board[x][y-3] == BLANK && board[x][y-2] == AIfigure && board[x][y-1] == AIfigure && board[x][y+1] == AIfigure &&
                        board[x][y+2] == BLANK) {
                    verticalPrice += 2000;
                    fl = true;
                }
            }
            if (y-2 >= 0 && y+3 <= board.length()) {
                if (board[x][y-2] == BLANK && board[x][y-1] == AIfigure && board[x][y+1] == AIfigure && board[x][y+2] == AIfigure &&
                        board[x][y+3] == BLANK) {
                    verticalPrice += 2000;
                    fl = true;
                }
            }
            if (y-3 >= 0 && y+2 <= board.length()) {
                if (board[x][y-3] == BLANK && board[x][y-2] == opponentFigure && board[x][y-1] == opponentFigure
                        && board[x][y+1] == opponentFigure && board[x][y+2] == BLANK) {
                    verticalPrice += 2000*agression;
                    fl = true;
                }
            }
            if (y-2 >= 0 && y+3 <= board.length()) {
                if (board[x][y-2] == BLANK && board[x][y-1] == opponentFigure && board[x][y+1] == opponentFigure
                        && board[x][y+2] == opponentFigure && board[x][y+3] == BLANK) {
                    verticalPrice += 2000*agression;
                    fl = true;
                }
            }
            if (fl) qDebug() << "Выгодный ход сделан/блокирован - вертикаль";
        }


       //Оценка диагонали (верхний левый в нижний правый)
        minX = x;
        maxX = x;
        minY = y;
        maxY = y;
        for(int j=0; j<winLength; j++) {
            if (minX > 0 && minY > 0) {
                minX--;
                minY--;
            }
            if (maxX < board.size() - 1 && maxY < board.size() - 1) {
                maxX++;
                maxY++;
            }
        }

        for(int j=minX, l=minY; j<=maxX, l<=maxY; j++, l++) {
            if (j + winLength > maxX + 1 || l + winLength > maxY + 1) {
                continue;
            }
            else {
                stopAttack = false;
                thisPrice = 0;
                int h = l;
                for(int k=j; k<j+winLength; k++) {
                    if (board[k][h] != AIfigure && board[k][h] != BLANK) {
                        thisPrice = 0;
                        break;
                    }
                    if (board[k][h] == AIfigure) {
                        thisPrice++;
                    }
                    else {
                        thisPrice += 0.2;
                    }
                    h++;
                }

                //BUG FIX start
                if (board[j][l] == BLANK && board[j+winLength-1][l+winLength-1] == BLANK ) {
                    stopAttack = true;
                    if (thisPrice >= worryLength) {
                        diagonalPrice += 2000;
                    }
                }
                //BUG FIX end

                if (thisPrice >= winLength - 1) {
                    diagonalPrice += 10000;
                }
                if (thisPrice > 0 && thisPrice < winLength) {
                    diagonalPrice += qPow(3, thisPrice);
                }
            }
        }

        for(int j=minX, l=minY; j<=maxX, l<=maxY; j++, l++) {
            if (j + winLength > maxX + 1 || l + winLength > maxY + 1) {
                continue;
            }
            else {
                stopAttack = false;
                opponentPrice = 0;
                int h = l;
                for(int k=j; k<j+winLength; k++) {
                    if (board[k][h] != AIfigure && board[k][h] != BLANK) {
                        opponentPrice++;
                    }
                    if (board[k][h] == AIfigure) {
                        opponentPrice = 0;
                        break;
                    }
                    h++;
                }

                //BUG FIX start
                if (board[j][l] == BLANK && board[j+winLength-1][l+winLength-1] == BLANK ) {
                    stopAttack = true;
                    if (opponentPrice >= worryLength) {
                        diagonalPrice += 2000*agression;
                    }
                }
                //BUG FIX end

                if (opponentPrice >= winLength - 1) {
                    diagonalPrice += 3500*agression;
                }
                if (opponentPrice > 0 && opponentPrice < winLength) {
                    diagonalPrice += agression * qPow(3, opponentPrice);
                }
            }
        }

        //First AI move fix for 5x5 game
        if (field.getSize() == 5 && field.getFiguresCount() == 1 && field.getLastFigure()->getPositionX() == 2 && field.getLastFigure()->getPositionY() == 2) {
            if ( (minX == 0 && minY == 0 && maxX == 4 && maxY == 4) ||
                 (minX == 0 && minY == 2 && maxX == 2 && maxY == 4) ||
                 (minX == 2 && minY == 0 && maxX == 4 && maxY == 2) ) {

                diagonalPrice += qrand() % ((500 + 1) - 200) + 200;
            }
        }

        //Оценка контр-диагонали (нижний левый в верхний правый)
        minX = x;
        maxX = x;
        minY = y;
        maxY = y;
        for(int j=0; j<winLength; j++) {
            if (minX > 0 && maxY < board.size() - 1) {
                minX--;
                maxY++;
            }
            if (maxX < board.size() - 1 && minY > 0) {
                minY--;
                maxX++;
            }
        }

        for(int j=minX, l=maxY; j<=maxX, l>=0; j++, l--) {
            if (j + winLength > maxX + 1 || l + 1 - winLength < 0) {
                continue;
            }
            else {
                stopAttack = false;
                thisPrice = 0;
                int h = l;
                for(int k=j; k<j+winLength; k++) {
                    if (board[k][h] != AIfigure && board[k][h] != BLANK) {
                        thisPrice = 0;
                        break;
                    }
                    if (board[k][h] == AIfigure) {
                        thisPrice++;
                    }
                    else {
                        thisPrice += 0.2;
                    }
                    h--;
                }

                //BUG FIX start
                if (board[j][l] == BLANK && board[j+winLength-1][l-winLength+1] == BLANK ) {
                    stopAttack = true;
                    if (thisPrice >= worryLength) {
                        antiDiagonalPrice += 2000;
                    }
                }
                //BUG FIX end

                if (thisPrice >= winLength - 1) {
                    antiDiagonalPrice += 10000;
                }
                if (thisPrice > 0 && thisPrice < winLength) {
                    antiDiagonalPrice += qPow(3, thisPrice);
                }
            }
        }

        for(int j=minX, l=maxY; j<=maxX, l>=0; j++, l--) {
            if (j + winLength > maxX + 1 || l + 1 - winLength < 0) {
                continue;
            }
            else {
                stopAttack = false;
                opponentPrice = 0;
                int h = l;
                for(int k=j; k<j+winLength; k++) {
                    if (board[k][h] != AIfigure && board[k][h] != BLANK) {
                        opponentPrice++;
                    }
                    if (board[k][h] == AIfigure) {
                        opponentPrice = 0;
                        break;
                    }
                    h--;
                }

                //BUG FIX start
                if (board[j][l] == BLANK && board[j+winLength-1][l-winLength+1] == BLANK ) {
                    stopAttack = true;
                    if (opponentPrice >= worryLength) {
                        antiDiagonalPrice += 2000*agression;
                    }
                }
                //BUG FIX end

                if (opponentPrice >= winLength - 1) {
                    antiDiagonalPrice += 3500*agression;
                }
                if (opponentPrice > 0 && opponentPrice < winLength) {
                    antiDiagonalPrice += agression * qPow(3, opponentPrice);
                }
            }
        }

        cell.first = x;
        cell.second = y;
        ratings.insert(horizontalPrice + verticalPrice + diagonalPrice + antiDiagonalPrice, cell);
    }

    //For AIvsAI battle
    if (checkList.isEmpty()) {
        x = field.getSize()/2;
        y = x;
    }

    //For AIvsPlayer mode
    else {
        double randomNumber = (double)qrand()/(RAND_MAX);

        if (randomNumber > 0.5 + difficulty/2) {
            int pos = qrand() % checkList.length();
            x = checkList.at(pos).first;
            y = checkList.at(pos).second;
            qDebug() << "Move like an idiot :D";
        }
        else {
            x = ratings.last().first;
            y = ratings.last().second;
            qDebug() << "Normal move";
        }

        qDebug() << x << y << "Move rating =" << ratings.lastKey();
    }

    if (AIfigure == X) {
        Cross cross(viewer);
        cross.setPositionX(x);
        cross.setPositionY(y);
        field.addFigure(&cross);
        cross.draw(x, y);
        board[x][y] = X;
        checkWin(x, y, X);
    }
    else {
        Zero zero(viewer);
        zero.setPositionX(x);
        zero.setPositionY(y);
        field.addFigure(&zero);
        zero.draw(x, y);
        board[x][y] = O;
        checkWin(x, y, O);
    }
}

void Game::move(int x, int y) {
    Cross cross(viewer);
    Zero zero(viewer);

    if (nextMove == X) {
        cross.setPositionX(x);
        cross.setPositionY(y);
        field.addFigure(&cross);
        cross.draw(x, y);
        board[x][y] = X;
        if (checkWin(x, y, X) == true) return;

        delay (200);
        if (AImode) {
            AImove(O);
        }
        else nextMove = O;
    }
    else {
        zero.setPositionX(x);
        zero.setPositionY(y);
        field.addFigure(&zero);
        zero.draw(x, y);
        board[x][y] = O;
        if (checkWin(x, y, O) == true) return;

        delay (200);
        if (AImode)
            AImove(X);
        else nextMove = X;
    }
}

bool Game::checkWin(int x, int y, FigureType currentFigure) {

    QList<int> positions;

    if (++movesCount == board.length()*board.length()) {
        showResult(positions, BLANK);
        return true;
        qDebug() << "Nobody wins :(";
    }


    //horizontal check
    int first_part = 0;
    int second_part = 0;
    bool first_search = true;
    bool second_search = true;
    positions.push_back(x + y*board.length());

    for(int i=1; i<board.length(); i++) {
        if (first_search == true && (x + i) < board.length()) {
            if (board[x + i][y] == currentFigure) {
                first_part++;
                positions.push_back((x + i) + y*board.length());
            }
            else {
                first_search = false;
            }
        }
        if (second_search == true && (x - i) >= 0) {
            if (board[x - i][y] == currentFigure) {
                second_part++;
                positions.push_back((x - i) + y*board.length());
            }
            else {
                second_search = false;
            }
        }

        if (first_search == false && second_search == false) {
            break;
        }

        if ((first_part + second_part + 1) == winLength) {
            showResult(positions, currentFigure);
            qDebug() << "Horizontal winner";
            return true;
        }
    }

    //vertical check
    first_part = 0;
    second_part = 0;
    first_search = true;
    second_search = true;
    positions.clear();
    positions.push_back(x + y*board.length());

    for(int i=1; i<board.length(); i++) {
        if (first_search == true && (y + i) < board.length()) {
            if (board[x][y+i] == currentFigure) {
                first_part++;
                positions.push_back(x + (y+i)*board.length());
            }
            else {
                first_search = false;
            }
        }
        if (second_search == true && (y - i) >= 0) {
            if (board[x][y-i] == currentFigure) {
                second_part++;
                positions.push_back(x + (y-i)*board.length());
            }
            else {
                second_search = false;
            }
        }

        if (first_search == false && second_search == false) {
            break;
        }

        if ((first_part + second_part + 1) == winLength) {
            showResult(positions, currentFigure);
            qDebug() << "Vertical winner";
            return true;
        }
    }

    //diagonal (top left to right bottom)
    first_part = 0;
    second_part = 0;
    first_search = true;
    second_search = true;
    positions.clear();
    positions.push_back(x + y*board.length());

    for(int i=1; i<board.length(); i++) {
        if (first_search == true && (y + i) < board.length() && (x + i) < board.length()) {
            if (board[x+i][y+i] == currentFigure) {
                first_part++;
                positions.push_back((x+i) + (y+i)*board.length());
            }
            else {
                first_search = false;
            }
        }
        if (second_search == true && (y - i) >= 0 && (x - i) >= 0) {
            if (board[x-i][y-i] == currentFigure) {
                second_part++;
                positions.push_back((x-i) + (y-i)*board.length());
            }
            else {
                second_search = false;
            }
        }

        if (first_search == false && second_search == false) {
            break;
        }

        if ((first_part + second_part + 1) == winLength) {
            showResult(positions, currentFigure);
            qDebug() << "Diagonal winner";
            return true;
        }
    }

    //anti diagonal (bottom left to right top)
    first_part = 0;
    second_part = 0;
    first_search = true; // to top right
    second_search = true; // to left bottom
    positions.clear();
    positions.push_back(x + y*board.length());

    for(int i=1; i<board.length(); i++) {
        if (first_search == true && (y - i) >= 0 && (x + i) < board.length()) {
            if (board[x+i][y-i] == currentFigure) {
                first_part++;
                positions.push_back((x+i) + (y-i)*board.length());
            }
            else {
                first_search = false;
            }
        }
        if (second_search == true && (y + i) < board.length() && (x - i) >= 0) {
            if (board[x-i][y+i] == currentFigure) {
                second_part++;
                positions.push_back((x-i) + (y+i)*board.length());
            }
            else {
                second_search = false;
            }
        }

        if (first_search == false && second_search == false) {
            break;
        }

        if ((first_part + second_part + 1) == winLength) {
            showResult(positions, currentFigure);
            qDebug() << "Anti diagonal winner";
            return true;
        }
    }
    return false;
}

void Game::showResult(QList<int> positions, FigureType winner) {
    AIvsAI = false;

    if (winner == O) {
        QMetaObject::invokeMethod(viewer->findChild<QObject*>("field"), "showWinner",
                                  Q_ARG(QVariant, QVariant::fromValue(positions)),
                                  Q_ARG(QVariant, tr("Победа 0!")));
        p2.setWinCount(p2.getWinCount() + 1);
        p1.setLooseCount(p1.getLooseCount() + 1);
    }

    else if (winner == X) {
        QMetaObject::invokeMethod(viewer->findChild<QObject*>("field"), "showWinner",
                                  Q_ARG(QVariant, QVariant::fromValue(positions)),
                                  Q_ARG(QVariant, tr("Победа X!")));
        p1.setWinCount(p1.getWinCount() + 1);
        p2.setLooseCount(p2.getLooseCount() + 1);
    }

    else {
        QMetaObject::invokeMethod(viewer->findChild<QObject*>("field"), "showWinner",
                                  Q_ARG(QVariant, QVariant::fromValue(positions)),
                                  Q_ARG(QVariant, tr("Ничья!")));
    }

    QMetaObject::invokeMethod(viewer->findChild<QObject*>("stats"), "updateStats",
                              Q_ARG(QVariant, p1.getWinCount()),
                              Q_ARG(QVariant, p2.getWinCount()));
}

int Game::getFieldSize() {
    return field.getSize();
}

void Game::setFieldSize(int val) {
    field.setSize(val);
    if (field.getSize() == 3) winLength = 3;
    else if (field.getSize() == 5) winLength = 4;
    else winLength = 5;

    QSettings settings("DonNTU", "TicTacToe");
    settings.setValue("size", val);

    refreshBoard(field.getSize());
    viewer->setProperty("fieldSize", field.getSize());

    qDebug() << "New field size = " << field.getSize() << "To win = " << winLength;
}

void Game::aiBattleStart(int time) {
    if (!AIvsAI) {
        AIvsAI = true;

        while(true) {
            AImove(X);
            delay(time);
            if (!AIvsAI) return;
            AImove(O);
            delay(time);
            if (!AIvsAI) return;
        }
    }
}
