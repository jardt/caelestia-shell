#pragma once

#include "configobject.hpp"

namespace caelestia::config {

class DashboardConfig : public ConfigObject {
    Q_OBJECT
    QML_ANONYMOUS

    CONFIG_PROPERTY(bool, enabled, true)
    CONFIG_PROPERTY(bool, showOnHover, true)
    CONFIG_PROPERTY(bool, showBongocat, true)
    CONFIG_GLOBAL_PROPERTY(int, mediaUpdateInterval, 500)
    CONFIG_PROPERTY(int, dragThreshold, 50)

public:
    explicit DashboardConfig(QObject* parent = nullptr)
        : ConfigObject(parent) {}
};

} // namespace caelestia::config
