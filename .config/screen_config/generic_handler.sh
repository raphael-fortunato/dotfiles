#!/bin/sh

case ${MONS_NUMBER} in
    1)
        mons -o
        xmonad --restart
        feh --no-fehbg --bg-scale  ~/Pictures/wallpaper.jpeg
        sleep 2
        ~/.config/polybar/launch.sh

        ;;
    2)
        mons -e left
        xmonad --restart
        feh --no-fehbg --bg-scale  ~/Pictures/wallpaper.jpeg
        sleep 2
        ~/.config/polybar/launch.sh
        ;;
    *)
        # Handle it manually
        ;;
esac
