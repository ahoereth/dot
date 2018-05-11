#!/usr/bin/env python3
import sys

from requests.exceptions import ConnectionError
from toggl24 import TogglUser

def main(token):
    try:
        time_entry = TogglUser(token).get_current_time_entry()
    except ConnectionError:
        return
    if time_entry is None:
        print('No active task')
        return
    project = time_entry.pname
    description = time_entry.description
    if project and description:
        print('{}\n{}'.format(description, project))
    elif project:
        print('{}\nUnnamed task'.format(project))
    elif description:
        print(description)
    else:
        print('Unspecified task active...')

if __name__ == '__main__':
    assert len(sys.argv) > 1
    main(sys.argv[1])
