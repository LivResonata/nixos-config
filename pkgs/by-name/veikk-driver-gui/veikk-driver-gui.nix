# WARNING: if you want to install this driver for the Veikk, make sure to either run it as root (to avoid issues with udev rules)
# or (to get udev rule loaded) to add it in `services.udev.packages. For now, all models seems to use the same file, but in case of doubt double check here
# https://www.veikk.com/support/download.html
# Make sure to run a single instance.
{
  stdenv,
  lib,
  fetchurl,
  dpkg,
  libusb1,
  autoPatchelfHook,
  libGL,
  glib,
  fontconfig,
  libXi,
  libX11,
  libXrandr,
  dbus,
  makeWrapper,
  xkeyboard_config,
}:
stdenv.mkDerivation rec {
  name = "veikk-driver-gui-${version}";
  version = "3.5.10-2";

  # This is like 20M, so it can take some time
  src = fetchurl {
    url = "https://macdriver.oss-us-west-1.aliyuncs.com/vktablet-3.5.10-2.x86_64.1.deb";
    sha256 = "sha256-AgyyzRWJYLQMLUIgKD6qfwqPIERMHHuTc5sYpyzPS5Y=";
  };

  buildInputs = [
    dpkg
    libusb1
    autoPatchelfHook
    libGL
    stdenv.cc.cc.lib
    glib
    libX11
    libXi
    libXrandr
    dbus
    fontconfig
    makeWrapper
    xkeyboard_config
  ];

  unpackPhase = ''
    echo "Unpacking";
    dpkg -x "$src" .
  '';

  installPhase = ''
    mkdir -p $out
    mv usr/lib $out/opt # contains the main executable
    mv usr/share $out/share # Contains the desktop file
    mv lib $out/lib # Contains udev rules
    substituteInPlace $out/share/applications/vktablet.desktop \
      --replace-warn "Exec=/usr/lib/vktablet/vktablet" "Exec=$out/opt/vktablet/vktablet" \
      --replace-warn "Icon=/usr/share/icons/hicolor/256x256/apps/vktablet.png" "Icon=$out/share/icons/hicolor/256x256/apps/vktablet.png"
    makeWrapper $out/opt/vktablet/vktablet $out/bin/vktablet \
      --set QT_XKB_CONFIG_ROOT "${xkeyboard_config}/share/X11/xkb"

    mkdir -p $out/opt/vktablet/conf/usr
    cat <<'EOF' > $out/opt/vktablet/conf/usr/comm.xml
    <?xml version="1.0" encoding="utf-8"?>
    <Configure version="3">
        <Pen>
            <Hotkey app="true">
                <Button id="1">
                    <Action type="keyboard" tip="Space" mode="hotkey">Space</Action>
                </Button>
                <Button id="2">
                    <Action type="mouse" event="3" tip="Right Click"/>
                </Button>
            </Hotkey>
            <Curve enable="true" param="0.000,0.125,0.125,1.000"/>
            <Pointer relative="false" step="5" capacity="0" gamesupport="false" ink="true"/>
        </Pen>
        <Tablet model="VK1200" pid="0x1005" vid="0x2feb">
            <Hotkey feature="key" app="true" dial-sensitivity="true">
                <Key id="1" virtual="false">
                    <Action type="keyboard" tip="Redo (Ctrl+Shift+Z)" mode="hotkey">Ctrl+Shift+Z</Action>
                </Key>
                <Key id="2" virtual="false">
                    <Action type="keyboard" tip="Undo (Ctrl+Z)" mode="hotkey">Ctrl+Z</Action>
                </Key>
                <Key id="3" virtual="false">
                    <Action type="keyboard" tip="Eye Dropper (Ctrl)" mode="hotkey">Ctrl</Action>
                </Key>
                <Key id="4" virtual="false">
                    <Action type="keyboard" tip="Hand (Space)" mode="hotkey">Space</Action>
                </Key>
                <Key id="5" virtual="false">
                    <Action type="keyboard" tip="Zoom In (+)" mode="text">+</Action>
                </Key>
                <Key id="6" virtual="false">
                    <Action type="keyboard" tip="Zoom Out (-)" mode="hotkey">-</Action>
                </Key>
            </Hotkey>
            <Mapping>
                <Screen kcx="1.00313" kcy="1.01667" index="0" kx="0.99740" part="0,0,1920,1080" ky="1.00289">
                    <Identify code="56-4b-4b-31-31-36-30" id="0" flag="0"/>
                    <Addition absrect="0,0,1920,1080" dpirect="0,0,0,0" desktopsize="1920,1080" dpidesktopsize="0,0"/>
                </Screen>
                <Work rotation="0" part="0,0,100,100"/>
            </Mapping>
        </Tablet>
    </Configure>
    EOF

    cp -v $out/opt/vktablet/conf/usr/comm.xml $out/opt/vktablet/conf/usr/VK1200.xml
  '';

  meta = {
    description = "Official drivers for Veikk tablets (provides pen configuration, pressure map, key mapping, screen mapping...)";
    homepage = "https://www.veikk.com/support/download.html";
    license = lib.licenses.unfree; # Supposed to be open source (GPL), but source can't be found online even when requested by users.
    maintainers = [ lib.maintainers.tobiasBora ];
    platforms = lib.platforms.linux;
  };
}
