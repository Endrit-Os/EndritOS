using System;
using System.Linq;
using System.Text.Json;
using System.IO;
using System.Threading.Tasks;

namespace AtlasToolbox.Utils
{
    public class ToolboxUpdateHelper
    {
        const string RELEASE_URL = "https://data.jsdelivr.com/v1/packages/gh/atlas-os/atlas-toolbox";
        const string DOWNLOAD_URL = $"https://cdn.jsdelivr.net/atlas/toolbox/";
        public static string commandUpdate;
        public static JsonDocument result;
        public static string version = "";
        public static bool CheckUpdates()
        {
            try
            {
                // get the api result
                string htmlContent = CommandPromptHelper.ReturnRunCommand("curl " + RELEASE_URL);
                result = JsonDocument.Parse(htmlContent);
                JsonElement versions = result.RootElement.GetProperty("versions");
                version = versions[0].GetProperty("version").ToString();

                // Format everything to compare 
                int currentVersion = int.Parse(RegistryHelper.GetValue($@"HKLM\SOFTWARE\AtlasOS\Toolbox", "Version").ToString().Replace(".", ""));

                if (int.Parse(version.Replace(".", "").Replace("v", "")) > currentVersion)
                {
                    return true;
                }
            }catch (Exception e)
            {
                App.logger.Error(e, "Failed to check for updates");
                return false;
            }
            return false;
        }

        public static void InstallUpdate()
        {
            // Call the installer and close Toolbox
            // get the download link and create a temporary directory
            string downloadUrl = DOWNLOAD_URL + version + "/AtlasToolbox-Setup.exe";
            string tempDirectory = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName());
            Directory.CreateDirectory(tempDirectory);

            CommandPromptHelper.RunCommand($"cd {tempDirectory} && curl -LSs {downloadUrl} -O \"setup.exe\"");
            commandUpdate = $"{tempDirectory}\\{downloadUrl.Split('/').Last()} /silent /install";
            CommandPromptHelper.RunCommandToUpdate(commandUpdate);
        }
    }
}
