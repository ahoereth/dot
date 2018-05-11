#!/usr/bin/env python3
import sys

from toggl24 import TogglUser

def main(token):
    time_entry = TogglUser(token).get_current_time_entry()
    if time_entry is None:
        print('No active task')
        return
    project = time_entry.pname
    description = time_entry.description
    if project and description:
        print('{}\n{}'.format(project, description))
    elif project:
        print('{}\nUnnamed task'.format(project))
    elif description:
        print(description)
    else:
        print('Unspecified task active...')

if __name__ == '__main__':
    assert len(sys.argv) > 1
    main(sys.argv[1])


"""
{
  "BTTTriggerType" : 643,
  "BTTTriggerTypeDescription" : "Named Trigger: toggl-new",
  "BTTTriggerClass" : "BTTTriggerTypeOtherTriggers",
  "BTTPredefinedActionType" : 128,
  "BTTPredefinedActionName" : "Send Shortcut to Specific App",
  "BTTShortcutApp" : "\/Applications\/TogglDesktop.app",
  "BTTShortcutAppUnderCursor" : "com.toggl.toggldesktop.TogglDesktop",
  "BTTShortcutToSend" : "55,45",
  "BTTTriggerName" : "toggl-new",
  "BTTEnabled2" : 1,
  "BTTEnabled" : 1,
  "BTTOrder" : 0
}

{
  "BTTWidgetName" : "Toggl Current",
  "BTTTriggerType" : 642,
  "BTTTriggerTypeDescription" : "Shell Script \/ Task Widget",
  "BTTTriggerClass" : "BTTTriggerTypeTouchBar",
  "BTTPredefinedActionType" : 128,
  "BTTPredefinedActionName" : "Send Shortcut to Specific App",
  "BTTShortcutApp" : "\/Applications\/TogglDesktop.app",
  "BTTShortcutAppUnderCursor" : "com.toggl.toggldesktop.TogglDesktop",
  "BTTShortcutToSend" : "55,14",
  "BTTShellScriptWidgetGestureConfig" : "BINENVPYTHON3:::DOTPATH\/tools\/bettertouchtool\/toggl.py TOGGLTOKEN",
  "BTTEnabled2" : 1,
  "BTTEnabled" : 1,
  "BTTOrder" : 0,
  "BTTTriggerConfig" : {
    "BTTTouchBarItemIconHeight" : 22,
    "BTTTouchBarItemIconWidth" : 22,
    "BTTTouchBarItemPadding" : 0,
    "BTTTouchBarFreeSpaceAfterButton" : "5.000000",
    "BTTTouchBarButtonColor" : "75.323769, 75.323769, 75.323769, 255.000000",
    "BTTTouchBarAlwaysShowButton" : "0",
    "BTTTouchBarAlternateBackgroundColor" : "128.829533, 128.829533, 128.829533, 255.000000",
    "BTTTouchBarScriptUpdateInterval" : 9.7412004470825195,
    "BTTTouchBarLongPressActionName" : "toggl-new"
  }
}
"""