#ifndef ADMIN_H
#define ADMIN_H

#include <QObject>
#include <QJsonObject>
#include <iostream>
#include <QJsonDocument>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QtMath>
#include <QVariantMap>
#include <QUrlQuery>
#include <QEventLoop>
#include <QJSEngine>
#include <QFile>
#include <QThread>
#include <QTimer>

struct Transaction{
public:
    Transaction(){}
    Transaction(QString date_,
    QString from_,
    QString to_,
    QString etherValue_,
    QString tokenValue_): date(date_), from(from_), to(to_), etherValue(etherValue_), tokenValue(tokenValue_){};
    QString date = "";
    QString from = "";
    QString to = "";
    QString etherValue = "";
    QString tokenValue = "";

};

class Admin_ : public QObject{
    Q_OBJECT

public:
    Admin_(){};

    Q_INVOKABLE QVector<Transaction> t;
    Q_INVOKABLE QString getTokenBalance(QString sender);
    Q_INVOKABLE QString getCurentAmountEtherum(QString tokenAmount, QString exchangeRate);
    Q_INVOKABLE QString getEtherBalance(QString sender);
    Q_INVOKABLE void transferFrom(QString sender, QString senderPrivateKey, QString receiver, QString tokenToTransfer);
    Q_INVOKABLE void buyTokens(QString sender, QString senderPrivateKey, QString tokensToBuy, QString ethersToSend);
    Q_INVOKABLE bool balanceChanged(QString address);
    Q_INVOKABLE void sellTokens(QString seller, QString sellerPrivateKey, QString tokensToSell, QString ethersToGet);
    Q_INVOKABLE QString getExchangeRate();
    Q_INVOKABLE QString informationAboutTransaction(QString from,QString to,bool isAdmin,bool isTransfer, bool isGetting);
    Q_INVOKABLE void updateUserDatabase(QString userAddress);
    Q_INVOKABLE void setExchangeRate(QString exchangeRate);
    Q_INVOKABLE QVector<Transaction> getLogData(QString address);
    Q_INVOKABLE bool validateAdress(QString address);
signals:
    void signalError(QString error);
private:

    QByteArray getWithData(QNetworkReply *reply, int time = 10000);
    QNetworkAccessManager *manager = new QNetworkAccessManager();

};



#endif // ADMIN_H
