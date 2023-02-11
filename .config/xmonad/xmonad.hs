-- IMPORTS
import XMonad
import Data.Monoid
import Data.Ratio
import Data.Maybe

import System.Exit

import XMonad.Util.Run
import XMonad.Util.EZConfig(additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.SpawnOnce
import XMonad.Util.NamedWindows

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.UrgencyHook

import XMonad.Layout.IndependentScreens
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Spiral
import XMonad.Layout.Grid
import XMonad.Layout.Renamed
import XMonad.Layout.SimplestFloat
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Fullscreen

import XMonad.Actions.CopyWindow
import XMonad.Actions.FloatKeys
import XMonad.Actions.Promote
import XMonad.Actions.MouseResize

import qualified XMonad.StackSet as W
import qualified Data.Map        as M


-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "alacritty"

myTextColor = "#646464"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 4

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
myppCurrent = "#98971a"
myppVisible = "#458588"
myppHidden = "#b16286"
myppHiddenNoWindows = "#689d6a"
myppTitle = "#d79921"
myppUrgent = "#cc241d"
myWorkspaces    = ["dev","web","video","float","5","6","teams","chat","music"]
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#928374"
myFocusedBorderColor = "#cc241d"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- close focused window
    [ ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_m ), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm .|. shiftMask , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm  .|. shiftMask , xK_period), sendMessage (IncMasterN (-1)))

    -- Tag window to all workspaces
    , ((modm  .|. shiftMask , xK_u), windows copyToAll)
    -- move resize floating windows
    , ((modm .|. shiftMask, xK_minus     ), withFocused (keysResizeWindow (-20,-20) (1,1)))
    , ((modm .|. shiftMask, xK_equal     ), withFocused (keysResizeWindow (20,20) (1,1)))
    , ((modm .|. shiftMask, xK_h     ), withFocused (keysMoveWindow(-20,0)))
    , ((modm .|. shiftMask, xK_j     ), withFocused (keysMoveWindow(0,20)))
    , ((modm .|. shiftMask, xK_k     ), withFocused (keysMoveWindow(0,-20)))
    , ((modm .|. shiftMask, xK_l     ), withFocused (keysMoveWindow(20,0)))
    -- Spotify handler
    -- , ((modm, xK_u, xK_space     ), spawn "playerctl -p spotify toggle")
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    , ((modm              , xK_b     ), sendMessage ToggleStruts)
    , ((modm              , xK_t     ), withFocused toggleFloat)

    -- Quit xmonad
    -- , ((modm .|. shiftMask, xK_c     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm .|. shiftMask, xK_r     ), spawn "killall xmobar; xmonad --recompile; xmonad --restart")

    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_period, xK_comma, xK_slash] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++

    [((modm .|.  shiftMask, xK_f), namedScratchpadAction myScratchPads "filemanager")
    , ((modm .|.  shiftMask, xK_e), namedScratchpadAction myScratchPads "mail") 
    , ((modm .|.  shiftMask, xK_q), namedScratchpadAction myScratchPads "calc") 
    , ((modm .|.  shiftMask, xK_t), namedScratchpadAction myScratchPads "terminal") 
    , ((modm .|.  shiftMask, xK_w), namedScratchpadAction myScratchPads "task") 
    ]
    where
            toggleFloat w = windows (\s -> if M.member w (W.floating s)
                            then W.sink w s
                            else (W.float w (W.RationalRect (1/4) (1/4) (1/2) (1/2)) s))


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- UrgencyHook
data LibNotifyUrgencyHook = LibNotifyUrgencyHook deriving (Read, Show)

instance UrgencyHook LibNotifyUrgencyHook where
    urgencyHook LibNotifyUrgencyHook w = do
        name     <- getName w
        Just idx <- fmap (W.findTag w) $ gets windowset
        safeSpawn "notify-send" [show name, "workspace " ++ idx]
-----------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
--
--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

tall     = renamed [Replace "tall"]
           $ smartBorders
           $ avoidStruts
           $ mySpacing 8
           $ ResizableTall 1 (5/100) (11/20) []
threeRow = renamed [Replace "threeRow"]
           $ smartBorders
           $ avoidStruts
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
threeColMid = renamed [Replace "threeColMid"]
           $ smartBorders
           $ avoidStruts
           $ mySpacing 8
           $ ThreeColMid 1 (5/100) (1/2)

myLayout = tall ||| threeColMid ||| avoidStruts(smartBorders(Full)) ||| threeRow
------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.

-- from https://github.com/xmonad/xmonad/issues/300
willFloat::Query Bool
willFloat = ask >>= \w -> liftX $ withDisplay $ \d -> do
  sh <- io $ getWMNormalHints d w
  let isFixedSize = isJust (sh_min_size sh) && sh_min_size sh == sh_max_size sh
  isTransient <- isJust <$> io (getTransientForHint d w)
  return (isFixedSize || isTransient)
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "mpv"            --> doRectFloat (W.RationalRect (1 % 4) (1 % 4) (1 % 2) (1 % 2))
    , className =? "mpv"            --> doShift ( myWorkspaces !! 2)
    , className =? "vlc"            --> doShift ( myWorkspaces !! 2)
    , resource =? "vlc"             --> doRectFloat (W.RationalRect (1 % 4) (1 % 4) (1 % 2) (1 % 2))
    , className =? "Gimp"           --> doFloat
    --, className =? "jetbrains-pycharm" --> doFloat
    , className =? "Nm-connection-editor"--> doFloat
    , className =? "Matplotlib"     --> doCenterFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , fmap not willFloat            --> insertPosition Below Newer
    , willFloat                     --> insertPosition Above Newer
    , className =? "firefox" --> doShift( myWorkspaces !! 1 )
    , className =? "jetbrains-pycharm" --> doShift( myWorkspaces !! 2 )
    , className =? "spotify"        --> doShift ( myWorkspaces !! 8 ) 
    , className =? "Signal"         --> doShift ( myWorkspaces !! 7 ) 
    , className =? "Whatsapp-for-linux" --> doShift ( myWorkspaces !! 7 )
    , className =? "Microsoft Teams - Preview" --> doShift ( myWorkspaces !! 6 ) 
    , isFullscreen --> doFloat
    , isDialog        --> doCenterFloat
    ]<+> namedScratchpadManageHook myScratchPads

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
-- bring clicked floating window to the front
floatClickFocusHandler :: Event -> X All
floatClickFocusHandler ButtonEvent { ev_window = w } = do
    withWindowSet $ \s -> do
        if isFloat w s
            then (focus w >> promote)
        else return ()
    return (All True)
    where isFloat w ss = M.member w $ W.floating ss
floatClickFocusHandler _ = return (All True)

myEventHook = floatClickFocusHandler

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
-- myLogHook = dynamicLogWithPP $ xmobarPP
--         { ppOutput = \x -> hPutStrLn xmproc0 x   -- xmobar on monitor 1
--                           >> hPutStrLn xmproc1 x   -- xmobar on monitor 2
--         -- mapM_ (\x -> ppOutput = hPutStrLn x) xmprocs
--         , ppCurrent = xmobarColor myppCurrent "" . wrap "[" "]" . clickable
--         , ppVisible = xmobarColor myppVisible "" . wrap "[" "]" . clickable            -- Visible but not current workspace 
--         , ppHidden = xmobarColor myppHidden "" . wrap ("<box type=Bottom width=2 mt=2 color=" ++ myppHidden ++ ">") "</box>"
--         -- , ppHiddenNoWindows = xmobarColor  myppHiddenNoWindows ""        -- Hidden workspaces (no windows)
--         , ppTitle = xmobarColor myppTitle "" . shorten 25
--         , ppSep =  "<fc=#586E75> | </fc>"                     -- Separators in xmobar
--         , ppUrgent = xmobarColor  myppUrgent "" . wrap "!" "!"  . clickable-- Urgent workspace 
--         , ppExtras  = [windowCount]                           -- # of windows current workspace
--         , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
--         }
------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.

myStartupHook :: X ()
myStartupHook = return()
    -- spawnOnce ("trayer --monitor 1 --edge top --align right --width 5 --height 22 " ++
    --     "--SetDockType true --SetPartialStrut true --transparent true --alpha 250")
------------------------------------------------------------------------
-- NamedScratchpad
myScratchPads :: [NamedScratchpad]
myScratchPads = [   NS "filemanager" spawnlf classlf sizelf 
                ,   NS "mail" spawnmutt classmutt sizemutt 
                ,   NS "calc" spawncalc classcalc sizecalc 
                ,   NS "terminal" spawnterm classterm sizeterm 
                ,   NS "task" spawntask classtask sizetask 
                ]
    where 
        spawnlf = "alacritty --class filemanager -e lfrun"
        classlf   = resource =? "filemanager"
        sizelf = customFloating $ W.RationalRect l t w h
           where
             h = 0.7
             w = 0.7
             t = 0.85 - h
             l = 0.85 - w
        spawnmutt = "alacritty --class mail -e neomutt"
        classmutt = resource =? "mail"
        sizemutt = customFloating $ W.RationalRect l t w h
           where
             h = 0.7
             w = 0.9
             t = 0.85 - h
             l = 0.95 - w
        spawncalc = "alacritty --class calc -e python"
        classcalc = resource =? "calc"
        sizecalc = customFloating $ W.RationalRect l t w h
           where
             h = 0.7
             w = 0.33
             t = 0.85 - h
             l = (1 % 3)
        spawnterm = "alacritty --class terminal"
        classterm   = resource =? "terminal"
        sizeterm = customFloating $ W.RationalRect l t w h
           where
             h = 0.7
             w = 0.7
             t = 0.85 - h
             l = 0.85 - w
        spawntask = "alacritty --class task -e taskwarrior-tui"
        classtask   = resource =? "task"
        sizetask = customFloating $ W.RationalRect l t w h
           where
             h = 0.85
             w = 0.85
             t = 0.925 - h
             l = 0.925 - w
------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
main = do
    -- n <- countScreens
    -- xmprocs <- mapM (\i -> spawnPipe $ "xmobar ~/.config/xmobar/xmobarrc " ++ show i ++ " -x " ++ show i) [0..n-1]
    xmproc0 <- spawnPipe  "xmobar -x 0 ~/.config/xmobar/xmobarrc1"
    xmproc1 <- spawnPipe  "xmobar -x 1 ~/.config/xmobar/xmobarrc1"
    xmonad $ docks $ ewmhFullscreen $ ewmh $ withUrgencyHook LibNotifyUrgencyHook def
        { layoutHook = mouseResize $ onWorkspace "float" simplestFloat $ myLayout
        , logHook = dynamicLogWithPP $ filterOutWsPP [scratchpadWorkspaceTag] $ xmobarPP
            { ppOutput = \x -> hPutStrLn xmproc0 x   -- xmobar on monitor 1
                              >> hPutStrLn xmproc1 x   -- xmobar on monitor 2
            -- mapM_ (\x -> ppOutput = hPutStrLn x) xmprocs
            , ppCurrent = xmobarColor myppCurrent "" . wrap "[" "]" . clickable
            , ppVisible = xmobarColor myppVisible "" . wrap "" "" . clickable            -- Visible but not current workspace 
            , ppHidden = xmobarColor myppHidden "" . wrap  "" "" . clickable
            -- , ppHiddenNoWindows = xmobarColor  myppHiddenNoWindows ""        -- Hidden workspaces (no windows)
            , ppTitle = xmobarColor myppTitle "" . shorten 25
            , ppSep =  "<fc=#586E75> | </fc>"                     -- Separators in xmobar
            , ppUrgent = xmobarColor  myppUrgent "" . wrap "!" "!"  . clickable-- Urgent workspace 
            , ppExtras  = [windowCount]                           -- # of windows current workspace
            , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
            }
        , handleEventHook = handleEventHook def <+> myEventHook
        , manageHook= namedScratchpadManageHook myScratchPads <+> manageDocks <+> myManageHook
        , startupHook = myStartupHook
        , terminal           = myTerminal
        , focusFollowsMouse  = myFocusFollowsMouse
        , clickJustFocuses   = myClickJustFocuses
        , borderWidth        = myBorderWidth
        , modMask            = myModMask
        , workspaces         = myWorkspaces
        , keys               = myKeys
        }
