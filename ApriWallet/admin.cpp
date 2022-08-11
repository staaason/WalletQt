#include "admin.h"

QString Admin_::getTokenBalance(QString sender)
{
    QEventLoop eventloop;
    QUrl url("https://servertest.valieriiakropiv.repl.co/get-token-balance");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject jsonRequest;
    jsonRequest.insert("address", sender);
    QJsonDocument doc(jsonRequest);
    QByteArray data = doc.toJson();
    QNetworkReply *reply = manager->post(request, data);
    QJsonDocument doc_(QJsonDocument::fromJson(getWithData(reply)));
    QJsonObject json = doc_.object();
    return QString::number(json["balance"].toInt());;
}
QString Admin_::informationAboutTransaction(QString from,QString to, bool isAdmin,bool isTransfer, bool isGetting)
{
    QString result = "";
    if(isAdmin && isTransfer)
        return from + " send tokens to " + to;
    else
      {
        if(isAdmin && !isTransfer && isGetting)
          return to + " buy tokens";
        if(isAdmin && !isTransfer && !isGetting)
          return from + " sell tokens";
      }
    if(!isAdmin && isTransfer && isGetting)
      return "get token from " + from;
    else
      {
        if(!isAdmin && isTransfer && !isGetting)
          return "send token to " + to;
        if(!isAdmin && !isTransfer && isGetting)
          return "buy tokens";
        if(!isAdmin && !isTransfer && !isGetting)
          return "sell tokens";
      }
    return result;
}

QString Admin_::getEtherBalance(QString sender)
{
    QEventLoop eventloop;
    QUrl url("https://servertest.valieriiakropiv.repl.co/get-ether-balance");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject jsonRequest;
    jsonRequest.insert("address", sender);
    QJsonDocument doc(jsonRequest);
    QByteArray data = doc.toJson();
    QNetworkReply *reply = manager->post(request, data);
    QJsonDocument doc_(QJsonDocument::fromJson(getWithData(reply)));
    QJsonObject json = doc_.object();

    return json["eth_balance"].toString().remove(8,json["eth_balance"].toString().length()-1);
}
QString Admin_::getExchangeRate()
{
    QNetworkRequest request;
    QEventLoop eventloop;
    QUrl url("https://servertest.valieriiakropiv.repl.co/get-exchange-rate");
    request.setUrl(url);
    QNetworkReply *reply = manager->get(request);
    connect(reply, SIGNAL(finished()), &eventloop, SLOT(quit()));
    eventloop.exec();
    QJsonDocument doc_(QJsonDocument::fromJson(reply->readAll()));
    QJsonObject json = doc_.object();

    return json["exchange_rate"].toString();
}
void Admin_::transferFrom(QString sender, QString senderPrivateKey, QString receiver, QString tokenToTransfer)
{
  const QUrl url(QStringLiteral("https://servertest.valieriiakropiv.repl.co/transfer-from"));
          QNetworkRequest request(url);
          request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
          QJsonObject jsonRequest;
          jsonRequest.insert("from", sender);
          jsonRequest.insert("privateKey", senderPrivateKey);
          jsonRequest.insert("to", receiver);
          jsonRequest.insert("value", tokenToTransfer);
          QJsonDocument doc(jsonRequest);
          QByteArray data = doc.toJson();
          QNetworkReply *reply = manager->post(request, data);
          QString err = QString::fromUtf8(getWithData(reply,50000));
          if(!err.isEmpty()){
                   signalError(err);
          }
}
void Admin_::buyTokens(QString sender, QString senderPrivateKey, QString tokensToBuy, QString ethersToSend)
{
    const QUrl url(QStringLiteral("https://servertest.valieriiakropiv.repl.co/buy-tokens"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject jsonRequest;
    jsonRequest.insert("buyer", sender);
    jsonRequest.insert("privateKey", senderPrivateKey);
    jsonRequest.insert("tokensToBuy", tokensToBuy);
    jsonRequest.insert("ethersToPay", ethersToSend);
    QJsonDocument doc(jsonRequest);
    QByteArray data = doc.toJson();
    QNetworkReply *reply = manager->post(request, data);
    QString err = QString::fromUtf8(getWithData(reply,50000));
    if(!err.isEmpty()){
             signalError(err);
    }
}
QString Admin_::getCurentAmountEtherum(QString tokenAmount, QString exchangeRate)
{
   double result = tokenAmount.toDouble()*exchangeRate.toDouble();
  return QString::number(result);
}
void Admin_::sellTokens(QString seller, QString sellerPrivateKey, QString tokensToSell, QString ethersToGet)
{
    const QUrl url(QStringLiteral("https://servertest.valieriiakropiv.repl.co/sell-tokens"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject jsonRequest;
    jsonRequest.insert("seller", seller);
    jsonRequest.insert("sellerPrivateKey", sellerPrivateKey);
    jsonRequest.insert("tokensToSell", tokensToSell);
    jsonRequest.insert("ethersToGet", ethersToGet);
    QJsonDocument doc(jsonRequest);
    QByteArray data = doc.toJson();
    QNetworkReply *reply = manager->post(request, data);
    QString err = QString::fromUtf8(getWithData(reply,50000));
    if(!err.isEmpty()){
             signalError(err);
    }
}
QByteArray Admin_::getWithData(QNetworkReply *reply, int time)
{
    QTimer timer;
    timer.setSingleShot(true);

    QEventLoop loop;
    connect(&timer, SIGNAL(timeout()), &loop, SLOT(quit()));
    connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    timer.start(time);
    loop.exec();
    QByteArray buffer;

    if(timer.isActive())
    {
        timer.stop();
        if(reply->error() == QNetworkReply::NoError)
        {
            buffer = reply->readAll();
        }
        else
        {
            QString  error = reply->errorString();
            qDebug() << error;
            buffer =  error.toUtf8();
        }
    }
    else
    {
        disconnect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
        reply->abort();
    }

    reply->deleteLater();
    return buffer;
}
bool Admin_::validateAdress(QString address)
{
    const QUrl url(QStringLiteral("https://servertest.valieriiakropiv.repl.co/is-address"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject jsonRequest;
    jsonRequest.insert("address", address);
    QJsonDocument doc(jsonRequest);
    QByteArray data = doc.toJson();
    QNetworkReply *reply = manager->post(request, data);
    QTimer timer;
    timer.setSingleShot(true);

    QEventLoop loop;
    connect(&timer, SIGNAL(timeout()), &loop, SLOT(quit()));
    connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    timer.start(10000);
    loop.exec();
    QByteArray buffer;
    if(timer.isActive())
    {
        timer.stop();
        if(reply->error() == QNetworkReply::NoError)
        {
            buffer = reply->readAll();
        }
        else
        {
            QString  error = reply->errorString();
            qDebug() << error;
            buffer =  QByteArray();
        }
    }
    else
    {
        disconnect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
        reply->abort();
    }
    reply->deleteLater();
    QJsonDocument doc_(QJsonDocument::fromJson(buffer));
    QJsonObject json = doc_.object();
    QVariantMap map = json.toVariantMap();
    return map.value("isAddress").toBool();
}
bool Admin_::balanceChanged(QString address)
{
    const QUrl url(QStringLiteral("https://servertest.valieriiakropiv.repl.co/get-user-data"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject jsonRequest;
    jsonRequest.insert("address", address);
    QJsonDocument doc(jsonRequest);
    QByteArray data = doc.toJson();
    QNetworkReply *reply = manager->post(request, data);
    QJsonDocument doc_(QJsonDocument::fromJson(getWithData(reply)));
    QJsonObject json = doc_.object();
    QVariantMap map = json.toVariantMap();
    return map.value("isChanged").toBool();
}
QVector<Transaction> Admin_::getLogData(QString address)
{
    QVector<Transaction> dataVec;
    const QUrl url(QStringLiteral("https://servertest.valieriiakropiv.repl.co/get-tx-data"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject jsonRequest;
    jsonRequest.insert("address", address);
    QJsonDocument doc(jsonRequest);
    QByteArray data = doc.toJson();
    QNetworkReply *reply = manager->post(request, data);
    QJsonDocument doc_(QJsonDocument::fromJson(getWithData(reply)));
    QJsonObject object = doc_.object();
    QJsonValue value = object.value("txList");
    QJsonArray array = value.toArray();

    foreach (const QJsonValue & v, array){
        dataVec.append(Transaction(v.toObject().value("date").toString().remove(18,v.toObject().value("date").toString().length()-1),
                                   v.toObject().value("from").toString(),
                                   v.toObject().value("to").toString(),
                                   v.toObject().value("ether_value").toString(),
                                   v.toObject().value("token_value").toString()));
   }
    return dataVec;
}
void Admin_::setExchangeRate(QString exchangeRate)
{
    const QUrl url(QStringLiteral("https://servertest.valieriiakropiv.repl.co/set-exchange-rate"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject jsonRequest;
    jsonRequest.insert("exchangeRate", exchangeRate);
    QJsonDocument doc(jsonRequest);
    QByteArray data = doc.toJson();
    QNetworkReply *reply = manager->post(request, data);
}
void Admin_::updateUserDatabase(QString userAddress)
{
    const QUrl url(QStringLiteral("https://servertest.valieriiakropiv.repl.co/update-user-database"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject jsonRequest;
    jsonRequest.insert("userAddress", userAddress);
    QJsonDocument doc(jsonRequest);
    QByteArray data = doc.toJson();
    QNetworkReply *reply = manager->post(request, data);
}
