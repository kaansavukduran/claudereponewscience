cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Cap the GLib API at 2.64 (Ubuntu 20.04 / Debian 11 level). Without this the
# GLib >= 2.80 headers of a newer build host make G_DEFINE_TYPE emit
# g_once_init_enter_pointer, and the runner fails on Ubuntu 22.04 (GLib 2.72)
# and Debian 12 (2.74) with "undefined symbol" (FORGE F030L-1, D-010).
target_compile_definitions(${BINARY_NAME} PRIVATE
  GLIB_VERSION_MIN_REQUIRED=GLIB_VERSION_2_64
  GLIB_VERSION_MAX_ALLOWED=GLIB_VERSION_2_64
)

# Add dependency libraries. Add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
