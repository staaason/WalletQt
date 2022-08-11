#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "admin.h"
#include "model.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
  QGuiApplication app(argc, argv);
  qmlRegisterType<Admin_>("Admin_", 1, 0, "Admin_");
  Model model;
  QQmlApplicationEngine engine;
  engine.rootContext()->setContextProperty("_myModel", &model);
  const QUrl url(QStringLiteral("qrc:/main.qml"));
  QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                   &app, [url](QObject *obj, const QUrl &objUrl) {
    if (!obj && url == objUrl)
      QCoreApplication::exit(-1);
  }, Qt::QueuedConnection);
  QObject::connect(&engine, &QQmlApplicationEngine::quit, &QGuiApplication::quit);
  engine.load(url);

  return app.exec();
}
