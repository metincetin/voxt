


if(NOT ANDROID)
    add_executable(voxt main.cpp resources.qrc)

    install(TARGETS voxt DESTINATION ${CMAKE_INSTALL_BINDIR})
    install(FILES voxt.desktop DESTINATION ${CMAKE_INSTALL_DATADIR}/applications )

elseif(ANDROID)
  add_library(voxt SHARED)
  find_package(Qt5 REQUIRED AndroidExtras)
  target_link_libraries(voxt PRIVATE Qt5::AndroidExtras)

  set_target_properties(voxt PROPERTIES LIBRARY_OUTPUT_NAME ${PROJECT_NAME})
  add_dependencies(apk voxt)

endif()

    target_link_libraries(voxt Qt5::Quick Qt5::Qml Qt5::Gui Qt5::QuickControls2 Qt5::Widgets KF5::Kirigami2 KF5::I18n)
