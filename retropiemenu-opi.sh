#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="retropiemenu-opi"
rp_module_desc="RetroPie configuration menu for EmulationStation"
rp_module_repo="git https://github.com/microplay-hub/retropiemenu-opi.git master"
rp_module_section="core"
rp_module_flags="noinstclean !rpi"

function _update_hook_retropiemenu-opi() {
    # to show as installed when upgrading to retropie-setup 4.x
    if ! rp_isInstalled "$md_id" && [[ -f "$home/.emulationstation/gamelists/retropie/gamelist.xml" ]]; then
        mkdir -p "$md_inst"
        # to stop older scripts removing when launching from retropie menu in ES due to not using exec or exiting after running retropie-setup from this module
        touch "$md_inst/.retropie"
    fi
}

function depends_retropiemenu-opi() {
    local depends=(cmake)
     getDepends "${depends[@]}"
}

function sources_retropiemenu-opi() {
    if [[ -d "$md_inst" ]]; then
        git -C "$md_inst" reset --hard  # ensure that no local changes exist
    fi
    gitPullOrClone "$md_inst"
}

function install_retropiemenu-opi() {
    local rpmsetup="$scriptdir/scriptmodules/supplementary"
	
    cd "$md_inst"
	
	cp -r "retropiemenu-opi.sh" "$rpmsetup/retropiemenu-opi.sh"
    chown -R $user:$user "$rpmsetup/retropiemenu-opi.sh"
	chmod 755 "$rpmsetup/retropiemenu-opi.sh"
	rm -r "retropiemenu-opi.sh"
	
}

function configure_retropiemenu-opi()
{
    [[ "$md_mode" == "remove" ]] && return

    local rpdir="$home/RetroPie/retropiemenu"
    mkdir -p "$rpdir"
    cp -Rv "$md_inst/icons_modern" "$rpdir/icons"
    chown -R $user:$user "$rpdir"
	chmod 755 "$rpdir/icons"

    isPlatform "rpi" && rm -f "$rpdir/dispmanx.rp"

    # add the gameslist / icons
    local files=(
        'audiosettings'
        'bluetooth'
        'configedit'
        'esthemes'
        'mpthemes'
        'filemanager'
        'raspiconfig'
        'orangepiconfig'
        'armbianconfig'		
        'retroarch'
        'retronetplay'
        'rpsetup'
        'runcommand'
        'log'
        'showip'
        'splashscreen'
        'opiwifi'
        'wifi'
    )

    local names=(
        'Audio'
        'Bluetooth'
        'Configuration Editor'
        'ES Themes'
        'MP Themes'
        'File Manager'
        'Raspi-Config'
        'Orangepi-Config'
        'Armbian-Config'
        'Retroarch'
        'RetroArch Net Play'
        'RetroPie Setup'
        'Run Command Configuration'
        'Run Command Logs'
        'Show IP'
        'Splash Screens'
        'On Board WiFi'
        'WiFi'
    )

    local descs=(
        'Configure audio settings. Choose default of auto, 3.5mm jack, or HDMI. Mixer controls, and apply default settings.'
        'Register and connect to Bluetooth devices. Unregister and remove devices, and display registered and connected devices.'
        'Change common RetroArch options, and manually edit RetroArch configs, global configs, and non-RetroArch configs.'
        'Install, uninstall, or update EmulationStation themes. Most themes can be previewed at https://retropie.org.uk/docs/Themes/.'
        'Install, uninstall, or update Microplay-hub EmulationStation themes.'
        'Basic ASCII file manager for Linux allowing you to browse, copy, delete, and move files.'
        'Change user password, boot options, internationalization, camera, add your Pi to Rastrack, overclock, overscan, memory split, SSH and more.'
        'Change user password, boot options, internationalization, camera, overclock, overscan, memory split, SSH and more.'
        'Change user password, boot options, internationalization, camera, overclock, overscan, memory split, SSH and more.'
        'Launches the RetroArch GUI so you can change RetroArch options. Note: Changes will not be saved unless you have enabled the "Save Configuration On Exit" option.'
        'Set up RetroArch Netplay options, choose host or client, port, host IP, delay frames, and your nickname.'
        'Install RetroPie from binary or source, install experimental packages, additional drivers, edit Samba shares, custom scraper, as well as other RetroPie-related configurations.'
        'Change what appears on the runcommand screen. Enable or disable the menu, enable or disable box art, and change CPU configuration.'
        'Show last Runcommand Logfile'
        'Displays your current IP address, as well as other information provided by the command "ip addr show."'
        'Enable or disable the splashscreen on RetroPie boot. Choose a splashscreen, download new splashscreens, and return splashscreen to default.'
        'Connect to or disconnect from a WiFi network and configure WiFi settings.'
        'Connect to or disconnect from a WiFi network and configure WiFi settings.'
    )

    setESSystem "RetroPie" "retropie" "$rpdir" ".rp .sh" "sudo $scriptdir/retropie_packages.sh retropiemenu launch %ROM% </dev/tty >/dev/tty" "" "retropie"

    local file
    local name
    local desc
    local image
    local i
    for i in "${!files[@]}"; do
        case "${files[i]}" in
            audiosettings|raspiconfig|splashscreen)
                ! isPlatform "rpi" && continue
				;;
            orangepiconfig|opiwifi)
                ! isPlatform "sun50i-h616" && continue
				;;
            armbianconfig|opiwifi)
                ! isPlatform "sun8i-h3" && continue
                ;;
            wifi)
                [[ "$__os_id" != "Raspbian" ]] && continue
        esac
		
        file="${files[i]}"
        name="${names[i]}"
        desc="${descs[i]}"
        image="$home/RetroPie/retropiemenu/icons/${files[i]}.png"

        touch "$rpdir/$file.rp"

        local function
        for function in $(compgen -A function _add_rom_); do
            "$function" "retropie" "RetroPie" "$file.rp" "$name" "$desc" "$image"
        done
    done
}

function remove_retropiemenu-opi() {
    rm -rf "$home/RetroPie/retropiemenu"
    rm -rf "$home/.emulationstation/gamelists/retropie"
	rm -rf "$md_inst"
    delSystem retropie
}

function launch_retropiemenu-opi() {
    clear
    local command="$1"
    local basename="${command##*/}"
    local no_ext="${basename%.rp}"
    joy2keyStart
    case "$basename" in
        retroarch.rp)
            joy2keyStop
            cp "$configdir/all/retroarch.cfg" "$configdir/all/retroarch.cfg.bak"
            chown $user:$user "$configdir/all/retroarch.cfg.bak"
            su $user -c "XDG_RUNTIME_DIR=/run/user/$SUDO_UID \"$emudir/retroarch/bin/retroarch\" --menu --config \"$configdir/all/retroarch.cfg\""
            iniConfig " = " '"' "$configdir/all/retroarch.cfg"
            iniSet "config_save_on_exit" "false"
            ;;
        rpsetup.rp)
            rp_callModule setup gui
            ;;
        raspiconfig.rp)
            raspi-config
            ;;
        orangepiconfig.rp)
            orangepi-config
            ;;
        armbianconfig.rp)
            armbian-config
            ;;
        filemanager.rp)
            mc
            ;;
        opiwifi.rp)
            sudo nmtui
            ;;
		log.rp)
            printMsgs "dialog" "Your runcommand.log is:\n\n$(cat /dev/shm/runcommand.log)"
            ;;
        showip.rp)
            local ip="$(getIPAddress)"
            printMsgs "dialog" "Your IP is: ${ip:-(unknown)}\n\nOutput of 'ip addr show':\n\n$(ip addr show)"
            ;;
        *.rp)
            rp_callModule $no_ext depends
            if fnExists gui_$no_ext; then
                rp_callModule $no_ext gui
            else
                rp_callModule $no_ext configure
            fi
            ;;
        *.sh)
            cd "$home/RetroPie/retropiemenu"
            sudo -u "$user" bash "$command"
            ;;
    esac
    joy2keyStop
    clear
}