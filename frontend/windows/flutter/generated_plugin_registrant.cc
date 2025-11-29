//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <file_selector_windows/file_selector_windows.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>
<<<<<<< HEAD
#include <share_plus/share_plus_windows_plugin_c_api.h>
#include <url_launcher_windows/url_launcher_windows.h>
=======
#include <speech_to_text_windows/speech_to_text_windows.h>
>>>>>>> 7dc016bbbf803371b13e78ee9d96053de58324fe

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
<<<<<<< HEAD
  SharePlusWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SharePlusWindowsPluginCApi"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
=======
  SpeechToTextWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SpeechToTextWindows"));
>>>>>>> 7dc016bbbf803371b13e78ee9d96053de58324fe
}
