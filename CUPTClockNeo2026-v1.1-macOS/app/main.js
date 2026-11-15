const { app, BrowserWindow, Menu } = require('electron');
const path = require('path');
const fs = require('fs');

const APP_DIR = __dirname;
const HTML = path.join(APP_DIR, 'CUPTClockNeo2026-v1.1.html');
const SNAP = process.env.CUPT_SNAP === '1';
const SNAP_DISPLAY = process.env.CUPT_SNAP_DISPLAY === '1';
const LOG = path.join(APP_DIR, 'boot.log');
function log(m) { try { fs.appendFileSync(LOG, new Date().toISOString() + ' ' + m + '\n'); } catch (e) {} }
log('module loaded');

function createConsole() {
  const win = new BrowserWindow({
    width: 1520,
    height: 900,
    minWidth: 1120,
    minHeight: 680,
    backgroundColor: '#0A0C0F',
    autoHideMenuBar: true,
    title: 'CUPTClockNeo 2026',
    icon: path.join(__dirname, 'icon.ico'),
    show: false,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      backgroundThrottling: false,
      spellcheck: false
    }
  });

  win.setMenuBarVisibility(false);
  if (SNAP_DISPLAY) {
    win.loadFile(HTML, { search: 'display=1&demo=1' });
    win.setFullScreen(true);
  } else {
    win.loadFile(HTML);
  }
  win.once('ready-to-show', () => { log('ready to show'); win.show(); });
  win.webContents.on('did-fail-load', (e, code, desc) => log('load fail ' + code + ' ' + desc));
  win.webContents.on('render-process-gone', (e, d) => log('render gone ' + JSON.stringify(d)));

  if (SNAP) {
    win.webContents.once('did-finish-load', () => {
      setTimeout(async () => {
        try {
          const img = await win.webContents.capturePage();
          fs.writeFileSync(path.join(APP_DIR, SNAP_DISPLAY ? 'snap-display.png' : 'snap-console.png'), img.toPNG());
        } catch (e) {}
        app.quit();
      }, 1800);
    });
  }

  win.webContents.setWindowOpenHandler(() => ({
    action: 'allow',
    overrideBrowserWindowOptions: {
      width: 1366,
      height: 768,
      backgroundColor: '#05070A',
      autoHideMenuBar: true,
      title: 'CUPTClockNeo 2026 · 展示窗',
      icon: path.join(__dirname, 'icon.ico'),
      webPreferences: {
        contextIsolation: true,
        nodeIntegration: false,
        backgroundThrottling: false,
        spellcheck: false
      }
    }
  }));

  return win;
}

app.whenReady().then(() => {
  log('app ready');
  Menu.setApplicationMenu(null);
  createConsole();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createConsole();
  });
});

app.on('window-all-closed', () => {
  app.quit();
});
