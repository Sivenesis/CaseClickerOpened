using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.Compression;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;
using Microsoft.Win32;

namespace CaseClicker
{
    static class Program
    {
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        static extern bool SetWindowText(IntPtr hWnd, string lpString);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

        [DllImport("user32.dll", SetLastError = true)]
        static extern IntPtr SetClassLongPtr(IntPtr hWnd, int nIndex, IntPtr dwNewLong);

        [DllImport("user32.dll", SetLastError = true)]
        static extern int SetClassLong(IntPtr hWnd, int nIndex, int dwNewLong);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

        [DllImport("user32.dll", SetLastError = true)]
        static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool IsWindowVisible(IntPtr hWnd);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);

        [DllImport("user32.dll")]
        static extern IntPtr GetMenu(IntPtr hWnd);

        [DllImport("user32.dll")]
        static extern bool SetMenu(IntPtr hWnd, IntPtr hMenu);

        [DllImport("user32.dll")]
        static extern bool DrawMenuBar(IntPtr hWnd);

        [DllImport("user32.dll")]
        static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

        private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

        const uint WM_SETICON = 0x0080;
        const int ICON_SMALL = 0;
        const int ICON_BIG = 1;
        const int GCLP_HICON = -14;
        const int GCLP_HICONSM = -34;

        const uint SWP_NOMOVE = 0x0002;
        const uint SWP_NOSIZE = 0x0001;
        const uint SWP_NOZORDER = 0x0004;
        const uint SWP_FRAMECHANGED = 0x0020;

        static IntPtr SetClassLongPtrHelper(IntPtr hWnd, int nIndex, IntPtr dwNewLong)
        {
            if (IntPtr.Size == 8)
                return SetClassLongPtr(hWnd, nIndex, dwNewLong);
            else
                return new IntPtr(SetClassLong(hWnd, nIndex, dwNewLong.ToInt32()));
        }

        [STAThread]
        static void Main(string[] args)
        {
            try
            {
                string appDir = AppDomain.CurrentDomain.BaseDirectory;
                string enginePath = Path.Combine(appDir, "engine.exe");
                string mainLuaPath = Path.Combine(appDir, "main.lua");

                if (!File.Exists(enginePath))
                {
                    enginePath = Path.Combine(appDir, "Solar2D.exe");
                }

                // If engine or main.lua is not found in the executable directory (e.g. run directly from Downloads),
                // extract embedded GamePackage to %LOCALAPPDATA%\CaseClickerOpened\ or use existing installation.
                if (!File.Exists(enginePath) || !File.Exists(mainLuaPath))
                {
                    string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
                    string installDir = Path.Combine(localAppData, "CaseClickerOpened");
                    string localEngine = Path.Combine(installDir, "engine.exe");
                    string localMain = Path.Combine(installDir, "main.lua");

                    var asm = System.Reflection.Assembly.GetExecutingAssembly();
                    using (var stream = asm.GetManifestResourceStream("GamePackage"))
                    {
                        if (stream != null)
                        {
                            if (!File.Exists(localEngine) || !File.Exists(localMain))
                            {
                                Form splash = null;
                                try
                                {
                                    splash = new Form()
                                    {
                                        Text = "Case Clicker Opened",
                                        StartPosition = FormStartPosition.CenterScreen,
                                        FormBorderStyle = FormBorderStyle.FixedDialog,
                                        MaximizeBox = false,
                                        MinimizeBox = false,
                                        ClientSize = new Size(380, 90),
                                        TopMost = true
                                    };
                                    var lbl = new Label()
                                    {
                                        Text = "Preparing Case Clicker Opened for first run...\nPlease wait a moment.",
                                        TextAlign = ContentAlignment.MiddleCenter,
                                        Dock = DockStyle.Fill,
                                        Font = new Font("Segoe UI", 10, FontStyle.Regular)
                                    };
                                    splash.Controls.Add(lbl);
                                    splash.Show();
                                    splash.Refresh();
                                }
                                catch { }

                                try
                                {
                                    Directory.CreateDirectory(installDir);
                                    using (var archive = new ZipArchive(stream, ZipArchiveMode.Read))
                                    {
                                        foreach (var entry in archive.Entries)
                                        {
                                            string safeRel = entry.FullName.Replace('/', Path.DirectorySeparatorChar);
                                            string destPath = Path.Combine(installDir, safeRel);
                                            if (string.IsNullOrEmpty(entry.Name))
                                            {
                                                Directory.CreateDirectory(destPath);
                                            }
                                            else
                                            {
                                                string dir = Path.GetDirectoryName(destPath);
                                                if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
                                                {
                                                    Directory.CreateDirectory(dir);
                                                }
                                                entry.ExtractToFile(destPath, true);
                                            }
                                        }
                                    }
                                }
                                catch { }
                                finally
                                {
                                    if (splash != null)
                                    {
                                        try { splash.Dispose(); } catch { }
                                    }
                                }
                            }

                            if (File.Exists(localEngine) && File.Exists(localMain))
                            {
                                appDir = installDir;
                                enginePath = localEngine;
                                mainLuaPath = localMain;
                            }
                        }
                    }

                    if ((!File.Exists(enginePath) || !File.Exists(mainLuaPath)) && File.Exists(localEngine) && File.Exists(localMain))
                    {
                        appDir = installDir;
                        enginePath = localEngine;
                        mainLuaPath = localMain;
                    }

                    if (!File.Exists(enginePath))
                    {
                        string[] candidates = new string[]
                        {
                            @"C:\Program Files (x86)\Corona Labs\Corona SDK\Corona Simulator.exe",
                            @"C:\Program Files\Corona Labs\Corona SDK\Corona Simulator.exe",
                            @"C:\Program Files\Solar2D\Solar2D Simulator.exe",
                            @"C:\Program Files (x86)\Solar2D\Solar2D Simulator.exe"
                        };
                        foreach (var c in candidates)
                        {
                            if (File.Exists(c))
                            {
                                enginePath = c;
                                break;
                            }
                        }
                    }
                }

                if (!File.Exists(enginePath))
                {
                    MessageBox.Show(
                        "Could not locate the Solar2D runtime engine (engine.exe or Solar2D.exe).\n\n" +
                        "If running from a zip download, please extract the full zip archive first before launching.\n" +
                        "Alternatively, run the self-contained CaseClickerOpened.exe package.",
                        "Case Clicker - Startup Error",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error
                    );
                    return;
                }

                if (!File.Exists(mainLuaPath))
                {
                    MessageBox.Show(
                        "Could not locate main.lua in:\n" + appDir + "\n\nPlease ensure all game files are extracted before running.",
                        "Case Clicker - Startup Error",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error
                    );
                    return;
                }

                try
                {
                    using (RegistryKey prefKey = Registry.CurrentUser.CreateSubKey(@"Software\Ansca Corona\Corona Simulator\Preferences"))
                    {
                        if (prefKey != null)
                        {
                            prefKey.SetValue("Device", "Desktop");
                            prefKey.SetValue("Rotation", 0);
                        }
                    }
                }
                catch { }

                Icon appIcon = null;
                string iconPath = Path.Combine(appDir, "app.ico");
                if (File.Exists(iconPath))
                {
                    try { appIcon = new Icon(iconPath); } catch { }
                }

                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = enginePath;
                psi.Arguments = "\"" + mainLuaPath + "\"";
                psi.WorkingDirectory = appDir;
                psi.UseShellExecute = false;

                using (Process proc = Process.Start(psi))
                {
                    if (proc != null)
                    {
                        // Background watcher to customize window title and icon
                        Thread watcher = new Thread(() =>
                        {
                            IntPtr hIconBig = appIcon != null ? appIcon.Handle : IntPtr.Zero;
                            IntPtr hIconSmall = IntPtr.Zero;
                            if (appIcon != null)
                            {
                                try { hIconSmall = (new Icon(appIcon, 32, 32)).Handle; } catch { hIconSmall = hIconBig; }
                            }

                            while (!proc.HasExited)
                            {
                                try
                                {
                                    EnumWindows((hWnd, lParam) =>
                                    {
                                        uint pid;
                                        GetWindowThreadProcessId(hWnd, out pid);
                                        if (pid == proc.Id)
                                        {
                                            IntPtr hMenu = GetMenu(hWnd);
                                            if (hMenu != IntPtr.Zero)
                                            {
                                                SetMenu(hWnd, IntPtr.Zero);
                                                DrawMenuBar(hWnd);
                                                SetWindowPos(hWnd, IntPtr.Zero, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
                                            }

                                            System.Text.StringBuilder sb = new System.Text.StringBuilder(256);
                                            GetWindowText(hWnd, sb, 256);
                                            string currentTitle = sb.ToString();

                                            if (currentTitle != "Case Clicker Opened")
                                            {
                                                SetWindowText(hWnd, "Case Clicker Opened");
                                            }

                                            if (hIconBig != IntPtr.Zero)
                                            {
                                                SendMessage(hWnd, WM_SETICON, (IntPtr)ICON_BIG, hIconBig);
                                                SendMessage(hWnd, WM_SETICON, (IntPtr)ICON_SMALL, hIconSmall);
                                                SetClassLongPtrHelper(hWnd, GCLP_HICON, hIconBig);
                                                SetClassLongPtrHelper(hWnd, GCLP_HICONSM, hIconSmall);
                                            }
                                        }
                                        return true;
                                    }, IntPtr.Zero);
                                }
                                catch { }
                                Thread.Sleep(250);
                            }
                        });
                        watcher.IsBackground = true;
                        watcher.Start();

                        proc.WaitForExit();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "An error occurred while launching Case Clicker:\n\n" + ex.Message,
                    "Case Clicker - Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
            }
        }
    }
}
