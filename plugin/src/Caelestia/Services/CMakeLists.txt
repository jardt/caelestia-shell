qml_module(caelestia-services
    URI Caelestia.Services
    SOURCES
        service.hpp service.cpp
        serviceref.hpp serviceref.cpp
        beattracker.hpp beattracker.cpp
        audiocollector.hpp audiocollector.cpp
        audioprovider.hpp audioprovider.cpp
    LIBRARIES
        PkgConfig::Pipewire
        PkgConfig::Aubio
)
