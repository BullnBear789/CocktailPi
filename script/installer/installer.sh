#!/bin/bash

langsel=$1


# 1 = CocktailPi
# 2 = CocktailPi + Touchscreen without keyboard
# 3 = CocktailPi + Touchscreen + Keyboard
modsel=$2


function color {
    if [ "$1" = "c" ]; then
        txt_color=6
    fi  
    if [ "$1" = "g" ]; then
        txt_color=2
    fi
    if [ "$1" = "r" ]; then
        txt_color=1
    fi
    if [ "$1" = "y" ]; then
        txt_color=3
    fi
    if [ "$2" = "n" ]; then
        echo -n "$(tput setaf $txt_color)$3"
    else
        echo "$(tput setaf $txt_color)$3"   
    fi
    tput sgr0
}

function select_lang {
    clear
    echo "CocktailPi Installer"
    echo ""
    echo "(1) German"
    echo "(2) English"
    echo "(3) Exit"
    echo ""

    if [ "$langsel" = "" ]; then
        echo "Bitte waehlen Sie ihre Sprache."
        echo -n "Please select your language: "
    else
        color r x "Bitte geben Sie entweder 1,2 oder 3 ein!"
        color r n "Please enter only 1,2 or 3: "
    fi

    read -n 1 langsel
	langselsize=${#langsel} 
	if [ "$langselsize" = "0" ]; then
	    langsel=99
        clear
        select_lang
	fi

    for i in $langsel; do
    case "$i" in
        '1')
            clear
        ;;
        '2')
            clear
        ;;
        '3')
            clear
            exit 0
        ;;
        *)
            langsel=99
            clear
            select_lang
        ;;
    esac
    done
}


function select_mode {
    clear
    if [ "$langsel" = "1" ]; then
        echo "Installations Auswahl"
        echo ""
        echo "Wählen sie 1, 2 oder 3 um die entsprechende Installation durchzuführen."
        echo ""
        echo "(1) CocktailPi"
        echo "(2) CocktailPi + Touchscreen ohne Bildschirmtastatur"
        echo "(3) CocktailPi + Touchscreen mit Bildschirmtastatur"
        echo "(4) Konfiguration: Größe der Touchscreen UI ändern"
		echo "(5) Router"
		echo "(6) Backup Database"
		echo "(7) Restore Database"
        echo ""
		echo "(9) Reboot"
        echo "(0) Exit"
    else
        echo "Installation selection"
        echo ""
        echo "Choose 1 or 2 or 3 to carry out the corresponding installation."
        echo ""
        echo "(1) CocktailPi"
        echo "(2) CocktailPi + Touchscreen without on-screen keyboard"
        echo "(3) CocktailPi + Touchscreen with on-screen keyboard"
        echo "(4) Configuration: Change size of Touchscreen UI"
		echo "(5) Router"
		echo "(6) Backup Database"
		echo "(7) Restore Database"
		echo ""
		echo "(9) Reboot"
        echo "(0) Exit"
    fi
    echo ""

    if [ "$langsel" = "1" ]; then
        if [ "$modsel" = "" ]; then
            echo -n "Bitte geben Sie ihre Auswahl an: "
        else
            color r n "Bitte geben Sie entweder 1,2,3,4,5,6,7,8 oder 0 ein: "
        fi
    else
        if [ "$modsel" = "" ]; then
            echo -n "Please enter your selection: "
        else
            color r n "Please enter either 1,2,3,4,5,6,7,8 or 0: "
        fi
    fi

    read -n 1 modsel
	  modselsize=${#modsel}
	  if [ "$modselsize" = "0" ]; then
	      modsel=99
        clear
        select_mode
	fi

    for i in $modsel; do
    case "$i" in
        '1')
            clear
        ;;
        '2')
            clear
        ;;
        '3')
            clear
        ;;
        '4')
            clear
        ;;
        '5')
            clear
		;;
        '6')
            clear
		;;
        '7')
            clear
        ;;
        '9')
            clear
        ;;		
        '0')
            clear
            exit 0
        ;;
        *)
            modsel=99
            clear
            select_mode
        ;;
    esac
    done
}

function clean_install {
	clear
	service cocktailpi stop
	sudo cp -r /root/cocktailpi /home/pi/backup_cocktailpi
	sudo rm -rf /home/pi/cocktailpi-installer.sh
	sudo rm -rf /root/cocktailpi-installer.sh
	sudo rm -rf /root/cocktailpi
	sudo rm -rf /var/log/cocktailpi.log
	sudo rm -rf /etc/init.d/cocktailpi
}

function restore_cocktailpi {
    clear
	service cocktailpi stop
	sudo cp -r /home/pi/backup_cocktailpi/cocktailpi-data.db /root/cocktailpi
	sudo rm -rf /home/pi/backup_cocktailpi
	service cocktailpi start
}

function backup_database {
    clear
	echo "Please wait..."
	echo ""
	service cocktailpi stop
	if [ -f /root/cocktailpi/cocktailpi-data.db ]; then
		mkdir -p /home/pi/Backup_cocktailpi-data
		cp -r /root/cocktailpi/cocktailpi-data.db /home/pi
		cp -r -b /root/cocktailpi/cocktailpi-data.db /home/pi/Backup_cocktailpi-data/backup_$(date +%d-%m-%Y)_cocktailpi-data.db 
		color g n "Backup completed successfully"
		echo ""
        echo ""
		sleep 1
	else
		color r n "No such file(cocktailpi-data.db)"
		echo ""
        echo ""
		sleep 1
	fi
	service cocktailpi start
}

function restore_database {
    clear
	source_dir="/home/pi"
	count_backup=$(find "$source_dir" -maxdepth 1 -type f -name "*cocktailpi-data.db" | wc -l)
	total_backup=$(find "$source_dir" -type f -name "*cocktailpi-data.db" | wc -l)
	echo "Please wait..."
	echo "finding '/home/pi/cocktailpi-data.db'"
	echo ""
	service cocktailpi stop
	if [ -f /home/pi/cocktailpi-data.db ]; then
		cp -r /home/pi/cocktailpi-data.db /root/cocktailpi
		color g n "Database restored successfully"
		echo ""
		echo ""
		sleep 1
	else
		if [ "$count_backup" = 1 ]; then
			cp -r -b /home/pi/*cocktailpi-data.db /root/cocktailpi/cocktailpi-data.db
			color g n "Database restored successfully"
			echo ""
			echo ""
			sleep 1
		else
			if [ $total_backup -gt 1 ]; then
				color y x "file: *cocktailpi-data.db"
				color y n "There are $total_backup files in the '$source_dir' directory."
				echo ""
				echo ""
				sleep 1
			else
				if [ "$total_backup" = 1 ]; then
					find -type f -name "*cocktailpi-data.db" -exec sh -c 'cp -r -b {} /root/cocktailpi/cocktailpi-data.db' \;
					color c n "Database restored successfully"
					echo ""
					echo ""
					sleep 1
				else
					color r x "Raspberry cannot find '/home/pi/cocktailpi-data.db'."
					color r n "Make sure you typed the name correctly, and then try again."
					echo ""
					echo ""
					sleep 1
				fi
			fi
		fi
	fi
	service cocktailpi start
}

function rasp_router {
    clear
	apt-get update && sudo apt-get -y upgrade
	sudo apt-get install dhcpcd5 -n
	sudo apt install hostapd dnsmasq
	sudo systemctl stop hostapd dnsmasq

	if [ -f /etc/dhcpcd.conf ]; then
		rm -r /etc/dhcpcd.conf
		sudo -u pi touch /etc/dhcpcd.conf
		echo "interface wlan0" >> /etc/dhcpcd.conf
		echo "static ip_address=192.168.1.4/24" >> /etc/dhcpcd.conf
		echo "nohook wpa_supplicant" >> /etc/dhcpcd.conf
	fi

	if [ -f /etc/dnsmasq.conf ]; then
		sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
		rm -r /etc/dnsmasq.conf
		sudo touch /etc/dnsmasq.conf
		echo "interface=wlan0"  >> /etc/dnsmasq.conf
		echo "dhcp-range=192.168.1.5,192.168.1.45,24h"  >> /etc/dnsmasq.conf
		echo "server=8.8.8.8"  >> /etc/dnsmasq.conf
		echo "server=8.8.4.4"  >> /etc/dnsmasq.conf
	fi

	if [ -f /etc/hostapd/hostapd.conf ]; then
		rm -r /etc/hostapd/hostapd.conf
		sudo touch /etc/hostapd/hostapd.conf
		echo "interface=wlan0"  >> /etc/hostapd/hostapd.conf
		echo "driver=nl80211"  >> /etc/hostapd/hostapd.conf
		echo "ssid=RaspberrySweet"  >> /etc/hostapd/hostapd.conf
		echo "hw_mode=g"  >> /etc/hostapd/hostapd.conf
		echo "channel=7"  >> /etc/hostapd/hostapd.conf
		echo "wmm_enabled=0"  >> /etc/hostapd/hostapd.conf
		echo "macaddr_acl=0"  >> /etc/hostapd/hostapd.conf
		echo "auth_algs=1"  >> /etc/hostapd/hostapd.conf
		echo "ignore_broadcast_ssid=0"  >> /etc/hostapd/hostapd.conf
		echo "wpa=2"  >> /etc/hostapd/hostapd.conf
		echo "wpa_passphrase=1234567890"  >> /etc/hostapd/hostapd.conf
		echo "wpa_key_mgmt=WPA-PSK"  >> /etc/hostapd/hostapd.conf
		echo "wpa_pairwise=TKIP CCMP"  >> /etc/hostapd/hostapd.conf
		echo "rsn_pairwise=CCMP"  >> /etc/hostapd/hostapd.conf
		echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" >> /etc/hostapd/hostapd.conf
		echo "update_config=1" >> /etc/hostapd/hostapd.conf	
	fi

	if [ -f /etc/default/hostapd ]; then
		rm -r /etc/default/hostapd
		sudo touch /etc/default/hostapd
		echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd
	fi

	sudo systemctl unmask hostapd
	sudo systemctl enable hostapd
	sudo systemctl start hostapd
	sudo systemctl enable dhcpcd
	sudo systemctl start dhcpcd

	sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.sav 
	sudo cp /dev/null /etc/wpa_supplicant/wpa_supplicant.conf
	
	if [ -f /etc/sysctl.conf ]; then
		rm -r /etc/sysctl.conf
		sudo touch /etc/sysctl.conf
		echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
	fi
	sudo sysctl -p

	sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
	sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
	sudo apt install netfilter-persistent iptables-persistent
	sudo netfilter-persistent save

	sudo systemctl restart hostapd
	sudo systemctl restart dnsmasq
	sudo systemctl restart dhcpcd
	sudo reboot
}

function select_confirm {
    clear
    echo -e "$1"
    echo ""
    if [ "$langsel" = "1" ]; then
        echo "(1) Bestätigen - Weiter"
    else
        echo "(1) Confirm - Continue"
    fi
    echo ""

    if [ "$langsel" = "1" ]; then
        if [ "$confirmsel" = "" ]; then
            echo -n "Bitte geben Sie ihre Auswahl an: "
        else
            color r n "Bitte bestätigen Sie mit 1: "
        fi
    else
        if [ "$confirmsel" = "" ]; then
            echo -n "Please enter your selection: "
        else
            color r n "Please confirm with 1: "
        fi
    fi

    read -n 1 confirmsel
	  confirmselsize=${#confirmsel}
  	if [ "$confirmselsize" = "0" ]; then
	      confirmsel=99
        clear
        select_confirm "$1"
	  fi

    for i in $confirmsel; do
    case "$i" in
        '1')
            clear
        ;;
        *)
            confirmsel=99
            clear
            select_confirm "$1"
        ;;
    esac
    done
}

function select_confirm_exit {
    clear
    echo -e "$1"
    echo ""
    if [ "$langsel" = "1" ]; then
        echo "(1) Bestätigen - Weiter"
		echo "(2) Beenden"
    else
        echo "(1) Confirm - Continue"
		echo "(2) Exit"
    fi
    echo ""

    if [ "$langsel" = "1" ]; then
        if [ "$confirmsel" = "" ]; then
            echo -n "Bitte geben Sie ihre Auswahl an: "
        else
            color r n "Bitte geben Sie entweder 1 oder 2 ein: "
        fi
    else
        if [ "$confirmsel" = "" ]; then
            echo -n "Please enter your selection: "
        else
            color r n "Please enter either 1 or 2: "
        fi
    fi

    read -n 1 confirmsel
	confirmselsize=${#confirmsel} 
	if [ "$confirmselsize" = "0" ]; then
	    confirmsel=99
        clear
        select_confirm_exit "$1"
	fi

    for i in $confirmsel; do
    case "$i" in
        '1')
            clear
        ;;
		'2')
            clear
            exit 0
        ;;
        *)
            confirmsel=99
            clear
            select_confirm_exit "$1"
        ;;
    esac
    done
}


if [ ! -n "$langsel" ]; then
    select_lang
fi

if [ "$(id -u)" != "0" ]; then
    clear
    if [ "$langsel" = "1" ]; then
        color r x "Sie benötigen root Rechte. Wechseln sie zum root-Benutzer mit \"sudo -i\""
    else
        color r x "You need root privileges. Switch to the roor-User using \"sudo -i\""
    fi
    exit 1
fi


if [ ! -n "$modsel" ]; then
    select_mode
fi

if [ "$modsel" = "9" ]; then
    clear
	sudo reboot
	exit 0
fi

if [ "$modsel" = "7" ]; then
    clear
	restore_database
	wget https://raw.githubusercontent.com/BullnBear789/CocktailPi/refs/heads/master/script/installer/installer.sh -O cocktailpi-installer.sh && chmod +x cocktailpi-installer.sh && ./cocktailpi-installer.sh
	exit 1
fi

if [ "$modsel" = "6" ]; then
    clear
	backup_database
	wget https://raw.githubusercontent.com/BullnBear789/CocktailPi/refs/heads/master/script/installer/installer.sh -O cocktailpi-installer.sh && chmod +x cocktailpi-installer.sh && ./cocktailpi-installer.sh
	exit 1
fi

if [ "$modsel" = "5" ]; then
    clear
	rasp_router
	exit 1
fi

if [ "$modsel" = "4" ]; then
  if ! [ -d "/home/pi/.config/chromium-profile/" ]; then
    if [ "$langsel" = "1" ]; then
        color r x "Touchscreen UI ist nicht installiert. Bitte installieren Sie diese zuerst und starten Sie dann das Skript neu!"
    else
        color r x "Touchscreen UI is not installed. Please install it first and restart the script afterwards!"
    fi
    exit 1
  fi

  while true; do
    if [ "$langsel" = "1" ]; then
        read -p "Geben Sie den Skalierungsfaktor an (positive ganze Zahl, oder Kommazahl): " zoomsel
    else
        read -p "Enter default scaling level (positive number, may be floating point number): " zoomsel
    fi
    # Check if input is a positive number (integer or float)
    if [[ "$zoomsel" =~ ^[+]?[0-9]+([.][0-9]+)?$ ]] && awk "BEGIN { exit ($zoomsel > 0 ? 0 : 1) }"; then
      break
    else
      if [ "$langsel" = "1" ]; then
          color r x "Ungültige Eingabe. Bitte geben Sie eine positive Zahl (z.B. 0.5, 1.0, 3.2, 5) an."
      else
          color r x "Invalid input. Please enter a positive number (e.g., 0.5, 1.0, 3.2, 5)."
      fi
    fi
  done
  WAYFIRE_CMD="wayfire -c ~/.config/wayfire.ini"
  WAYFIRE_EXEC=$(basename $(echo "$WAYFIRE_CMD" | awk '{print $1}'))
  FILE="/home/pi/.config/chromium-profile/Default/Preferences"
  NEW_JSON="{\"partition\": {\"default_zoom_level\": {\"x\": $zoomsel}}}"

  pkill -f wayfire

  sudo -u pi mkdir -p "$(dirname "$FILE")"
  if [ ! -f "$FILE" ]; then
    # File does not exist — create with NEW_JSON
    sudo -u pi echo "$NEW_JSON" > "$FILE"
  else
    # File exists — merge NEW_JSON into it
    TMP_FILE='TempPreferences'
    touch "$TMP_FILE"
    echo "$NEW_JSON" | sudo -u pi jq -s '.[0] * .[1]' "$FILE" - > "$TMP_FILE"
    mv -f "$TMP_FILE" "$FILE"
    chown pi:pi "$FILE"
    chmod 600 "$FILE"

  fi
  PI_ID=$(id -u pi)
  sudo -u pi XDG_RUNTIME_DIR=/run/user/$PI_ID \
    nohup wayfire -c /home/pi/.config/wayfire.ini > /dev/null 2>&1 < /dev/null & disown

  exit 0
fi

if [ "$modsel" = "3" ]; then
    clear
	confirmsel=""
	if [ "$langsel" = "1" ]; then
        select_confirm_exit "Sie haben ausgewählt, dass der Touchscreen mit Bildschirmtastatur installiert werden soll. Hierzu muss zwingend bereits während der Installation ein Bildschirm an dem Raspberry Pi angeschlossen sein. Bitte bestätigen Sie, dass ein Bildschirm an den Raspberry Pi angeschlossen ist."
	else
        select_confirm_exit "You have selected that the touchscreen and an on-screen keyboard should be installed. To do this, a screen must be connected to the Raspberry Pi during installation. Please confirm that a screen is connected to the Raspberry Pi."
	fi
fi

is_ssh=""
if [[ $(who am i) =~ \([0-9a-z\:\.]+\)$ ]]; then
    is_ssh=1
else
    is_ssh=0;
fi

users=($(cat /etc/passwd | grep "/bin/bash" | sed 's/:.*//'))
pi_user_found=0
for user in "${users[@]}"; do
    if [ "$user" = "pi" ]; then
      pi_user_found=1
      break
    fi
done

if [ "$pi_user_found" == "0" ]; then
  clear
  	if [ "$langsel" = "1" ]; then
        echo "Der \"pi\"-Benutzer konnte nicht gefunden werden!"
        echo "Bitte flashen Sie Ihr Betriebssystem erneut und setzen Sie den Standardbenutzer auf \"pi\", bevor Sie den Flashvorgang starten!"
  	else
        echo "The \"pi\"-user could not be found!"
        echo "Please re-flash your operating system and set the default user to \"pi\" before starting the flashing process!"
  	fi
  exit 1
fi

wget -q --spider http://google.com
if [ $? -ne 0 ]; then
    clear
    if [ "$langsel" = "1" ]; then
        echo "Keine Internetverbindung! Bitte verbinde den Raspberry Pi mit dem Internet und starte das Skript erneut!"
    else
        echo "No internet connection! Please connect the Raspberry Pi to the internet and restart the script!"
    fi
    exit 1
fi

if [ "$langsel" = "1" ]; then
    echo "Update system..."
else
    echo "Updating system..."
fi
sleep 2

apt-get update && sudo apt-get -y upgrade
sudo apt-get install systemd
sudo apt install mtools
sudo apt install e2fsprogs
clean_install

clear
serviceRunning=$(systemctl is-active cocktailpi)
if [ "$serviceRunning" != "inactive" ]; then
    if [ "$langsel" = "1" ]; then
        echo "Stoppe laufende CocktailPi Instanz..."
    else
        echo "Stopping running CocktailPi instance..."
    fi
    service cocktailpi stop
fi

clear
if [ "$langsel" = "1" ]; then
        echo "Installiere benötigte Software..."
    else
        echo "Installing dependencies..."
    fi
sleep 2
apt install --no-install-recommends -y openjdk-17-jdk i2c-tools python3-full python3-pip pigpio wget libjna-java alsa-utils python3-pip nano curl

clear
if [ "$langsel" = "1" ]; then
    echo "Installiere CocktailPi nach /root/cocktailpi"
else
    echo "Installing CocktailPi into /root/cocktailpi"
fi

mkdir -p /root/cocktailpi
wget -q --show-progress https://github.com/alex9849/CocktailPi/releases/latest/download/server.jar -O /root/cocktailpi/cocktailpi.jar
if [ -f /etc/init.d/cocktailpi ]; then
    unlink /etc/init.d/cocktailpi
fi
ln -s /root/cocktailpi/cocktailpi.jar /etc/init.d/cocktailpi
chmod +x /etc/init.d/cocktailpi

clear
if [ "$langsel" = "1" ]; then
    echo "Füge CocktailPi zu Autostart hinzu..."
else
    echo "Adding CocktailPi to the autostart..."
fi
systemctl daemon-reload
update-rc.d cocktailpi defaults
restore_cocktailpi

if [ "$langsel" = "1" ]; then
    echo "Starte CocktailPi Service..."
else
    echo "Starting CocktailPi service..."
fi
service cocktailpi start


if [ "$modsel" = "1" ]; then
    clear
	if [ "$langsel" = "1" ]; then
	    echo "CocktailPi ist installiert! Das Webinterface sollte unter der IP-Adresse Ihres Raspberry Pi über Ihr Heimnetzwerk erreichbar sein!"
        echo "Bitte beachten Sie, dass es je nach verwendetem Raspberry Pi einige Zeit dauern kann, bis die Software vollständig im Hintergrund gestartet ist und die Website erreichbar ist."
    else
	    echo "CocktailPi has been installed! The webinterface should be reachable under the IP-Address of your Raspberry Pi through your home."
        echo "Please note that depending on which Raspberry Pi you use it can take some time till the software completely booted in the background and the website becomes reachable."
    fi
    exit 0
fi

clear
if [ "$langsel" = "1" ]; then
    echo "Installiere touchscreen software..."
else
    echo "Installing touchscreen dependencies..."
fi

if [ -d /home/pi/wait-for-app-html ]; then
    rm -r /home/pi/wait-for-app-html
fi

sudo -u pi wget -q --show-progress https://github.com/alex9849/CocktailPi/releases/latest/download/wait-for-app.tar -O /home/pi/wait-for-app.tar

sudo -u pi tar -xf /home/pi/wait-for-app.tar -C /home/pi/
sudo -u pi rm /home/pi/wait-for-app.tar

if [ "$langsel" = "1" ]; then
    echo "Bitte warten..."
else
    echo "Please wait..."
fi
raspi-config nonint do_boot_behaviour B2

apt install --no-install-recommends -y chromium-browser rpi-chromium-mods
apt install --no-install-recommends -y wayfire seatd xdg-user-dirs jq

raspi-config nonint do_wayland W2

if ! cat /home/pi/.bashrc | grep -q "wayfire -c ~/.config/wayfire.ini"; then
    echo "if [ \"\$(tty)\" = \"/dev/tty1\" ]; then" >> /home/pi/.bashrc
    echo "    wayfire -c ~/.config/wayfire.ini" >> /home/pi/.bashrc
    echo "fi" >> /home/pi/.bashrc
fi

sudo -u pi mkdir -p /home/pi/.config

if [ "$modsel" = "3" ]; then
    pkill -f wayfire
    confirmsel=""
    if [ "$is_ssh" = "1" ]; then
        if [ "$langsel" = "1" ]; then
            select_confirm "Um fortfahren zu können muss ein Bildschirm an dem Raspberry Pi angeschlossen sein. Stellen Sie sicher, dass ein Bildschirm angeschlossen ist."
        else
            select_confirm "To continue, a screen must be connected to the Raspberry Pi. Make sure that a screen is connected."
        fi
    else
        if [ "$langsel" = "1" ]; then
            select_confirm "Im nächsten Schritt wird sich ein Browser auf ihrem Bildschirm öffnen und eine Chrome-Erweiterung anzeigen (Bildschirmtastatur), welche Sie installieren müssen. Sobald Sie auf \"Bestätigen\" drücken haben Sie 100 Sekunden Zeit um die Erweiterung zu installieren, bevor das setup den Browser schließt und die Installation fortsetzt."
        else
            select_confirm "In the next step, a browser will open on your screen and display a Chrome extension (on-screen keyboard), which you must install (Add to chrome). As soon as you press \"Confirm\", you have 100 seconds to install the extension before the setup closes the browser and continues the installation."
        fi
    fi
    if [ -f /home/pi/.config/wayfire.ini ]; then
        rm -r /home/pi/.config/wayfire.ini
    fi
    sudo -u pi touch /home/pi/.config/wayfire.ini
    echo "[autostart]" >> /home/pi/.config/wayfire.ini
    echo "chromium = chromium-browser https://chromewebstore.google.com/detail/chrome-simple-keyboard-a/cjabmkimbcmhhepelfhjhbhonnapiipj --kiosk --noerrdialogs --enable-extensions --disable-component-update --check-for-update-interval=31536000 --disable-infobars --no-first-run --ozone-platform=wayland --enable-features=OverlayScrollbar --disable-features=OverscrollHistoryNavigation --start-maximized --user-data-dir=/home/pi/.config/chromium-profile" >> /home/pi/.config/wayfire.ini
    echo "screensaver = false" >> /home/pi/.config/wayfire.ini
    echo "dpms = false" >> /home/pi/.config/wayfire.ini

    confirmsel=""
    PI_ID=$(id -u pi)
    sudo -u pi XDG_RUNTIME_DIR=/run/user/$PI_ID \
      nohup wayfire -c /home/pi/.config/wayfire.ini > /dev/null 2>&1 < /dev/null & disown
    if [ "$is_ssh" = "1" ]; then
        if [ "$langsel" = "1" ]; then
            select_confirm "Auf dem Bildschirm sollte sich jetzt der Chrome Webstore öffnen. Fügen Sie die angezeigte Erweiterung zu Chrome hinzu. Kehren Sie nach dem hinzufügen hierher zurück und setzen Sie das Skript mit 1 fort."
        else
            select_confirm "The Chrome Webstore should now open on the screen. Add the displayed extension to Chrome. After adding, return here and continue the script with 1."
        fi
        for i in {1..20}
        do
            echo "Waiting $((20-$i)) seconds..."
            sleep 1
        done
    else
        sleep 100
    fi

    pkill -f wayfire

fi

if [ -f /home/pi/.config/wayfire.ini ]; then
    rm -r /home/pi/.config/wayfire.ini
fi
sudo -u pi touch /home/pi/.config/wayfire.ini
echo "[autostart]" >> /home/pi/.config/wayfire.ini
echo "chromium = chromium-browser /home/pi/wait-for-app-html/index.html --kiosk --noerrdialogs --enable-extensions --disable-component-update --check-for-update-interval=31536000 --disable-infobars --no-first-run --ozone-platform=wayland --enable-features=OverlayScrollbar --disable-features=OverscrollHistoryNavigation --start-maximized --user-data-dir=/home/pi/.config/chromium-profile" >> /home/pi/.config/wayfire.ini
echo "screensaver = false" >> /home/pi/.config/wayfire.ini
echo "dpms = false" >> /home/pi/.config/wayfire.ini


clear
service cocktailpi start
if [ "$modsel" = "3" ] || [ "$modsel" = "2" ]; then
  PI_ID=$(id -u pi)
  sudo -u pi XDG_RUNTIME_DIR=/run/user/$PI_ID \
    nohup wayfire -c /home/pi/.config/wayfire.ini > /dev/null 2>&1 < /dev/null & disown
fi

sudo reboot