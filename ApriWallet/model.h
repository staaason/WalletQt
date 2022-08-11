#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <admin.h>



class Model : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit Model(QObject *parent = nullptr);
    enum DataRoles
    {
        date = Qt::UserRole,
        from,
        to,
        etherValue,
        tokenValue
    };
    virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Q_INVOKABLE void initialize(QString address);
    virtual int rowCount(const QModelIndex &parent) const override;
    virtual QHash<int,QByteArray> roleNames() const override;

private:

    QVector<Transaction> m_data;
};
