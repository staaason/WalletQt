#include "model.h"

Model::Model(QObject *parent)
    : QAbstractListModel(parent)
{
}

void Model::initialize(QString address)
{
  Admin_ admin;
  QVector<Transaction> temp =  QVector<Transaction>(admin.getLogData(address));
  for(int i=0;i<m_data.length();)
  {
      beginRemoveRows(QModelIndex(), i, i);
      m_data.removeAt(i);
      endRemoveRows();
  }
  for(int i=0;i<temp.length();i++)
  {
      beginInsertRows(QModelIndex(), m_data.length(), m_data.length());
      m_data.insert(m_data.length(), temp.at(i));
      endInsertRows();
  }
}

QVariant Model::data(const QModelIndex& index, int role) const
{
    if ( !index.isValid())
    {
        return QVariant();
    }
    const Transaction& modelEntry = m_data.at(index.row());
    if (role == date)
    {
        return modelEntry.date;
    }
    else if (role == from)
    {
        return modelEntry.from;
    }
    else if (role == to)
    {
        return modelEntry.to;
    }
    else if (role == etherValue)
    {
        return modelEntry.etherValue;
    }
    else if (role == tokenValue)
    {
        return modelEntry.tokenValue;
    }
    return QVariant();
}

int Model::rowCount(const QModelIndex& /*parent*/) const
{
    return static_cast<int>(m_data.count());
}

QHash<int, QByteArray> Model::roleNames() const
{
  static QHash<int, QByteArray> roles{
    {date , "date"},
    {from, "from"},
    {to , "to"},
    {etherValue, "etherValue"},
    {tokenValue, "tokenValue"}
  };
    return roles;
}

