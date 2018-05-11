import datetime
import simplejson as json
from urllib.parse import urljoin
import logging
logger = logging.getLogger()

import pytz
import parsedatetime
import requests

BASE_API_URL = 'https://www.toggl.com/api/v8/'
REPORTS_API_URL = 'https://toggl.com/reports/api/v8/'


def pick(dictionary, *keys):
    """Create a dictionary composed of the picked dictionary keys.

    >>> d = {'a': 1, 'b': 2, 'c': 3}
    >>> pick(d, 'b')
    {'b': 2}
    >>> pick(d, 'b', 'a')
    {'b': 2, 'a': 1}
    """
    dict_keys = dictionary.keys()
    return {key: dictionary[key] for key in keys if key in dict_keys}


def flatten(alist):
    return [item for sublist in alist for item in sublist]


def first(generator):
    try:
        return next(generator)
    except StopIteration:
        return None


def parse_iso_datetime(dt_str):
    if ':' == dt_str[-3:-2]:
        dt_str = dt_str[:-3] + dt_str[-2:]
    return datetime.datetime.strptime(dt_str, '%Y-%m-%dT%H:%M:%S%z')


def parse_h_datetime(datetime_string):
    cal = parsedatetime.Calendar()
    datetime_obj, _ = cal.parseDT(datetimeString=datetime_string,
                                  tzinfo=pytz.utc)
    return datetime_obj


def isoformat(dt_obj):
    if isinstance(dt_obj, str):
        return dt_obj
    return dt_obj.isoformat(timespec='seconds')


def query(token, path, params=None, data=None, method='get'):
    if path[0] == '/':
        path = path[1:]
    url = urljoin(BASE_API_URL, path)

    logger.info('toggl api request: {} {} {}'.format(method, path, params,
                                                     data))
    if params is None:
        params = {}

    if data is not None:
        data = json.dumps(data)

    func = getattr(requests, method)
    response = func(url,
                    auth=(token, 'api_token'),
                    headers={'content-type': 'application/json'},
                    params=params,
                    data=data)

    if response.status_code != requests.codes.ok:
        response.raise_for_status()

    return response.json()


class TimeEntry:
    core_attributes = ['id', 'description', 'wid', 'pid', 'tid', 'billable',
                       'start', 'stop', 'duration', 'created_with', 'tags',
                       'duronly', 'at']

    additional_attributes = {
        'project': ('_project',),
        'pname': ('_project', 'name'),
        'workspace': ('_workspace',),
        'wname': ('_workspace', 'name'),
    }

    stores = {
        '_project': ('/projects/%d', 'pid'),
        '_workspace': ('/workspaces/%d', 'wid'),
    }

    getmap = {
        'start': parse_iso_datetime,
        'stop': parse_iso_datetime,
        'at': parse_iso_datetime,
    }

    setmap = {
        'start': isoformat,
        'stop': isoformat,
    }

    _id = None
    _api = None
    _core = None
    _project = None
    _workspace = None

    def __init__(self, api, entry):
        self._api = api
        if isinstance(entry, int):
            self._id = entry
        else:
            self._core = entry.copy()
            for key, mapper in self.setmap.items():
                if key in self._core:
                    self._core[key] = mapper(self._core[key])
            self._id = entry['id'] if 'id' in entry else None

    def __getattr__(self, attr):
        self.fetch()
        value = 'AttributeError'
        if attr in self.core_attributes:
            value = self._core[attr] if attr in self._core else None
        if attr in self.additional_attributes:
            store, *subkeys = self.additional_attributes[attr]
            if getattr(self, store) is None:
                path, ident = self.stores[store]
                ident = getattr(self, ident)
                if ident is not None:
                    data = self._api.get(path % ident)['data']
                    setattr(self, store, data)
            value = getattr(self, store)
            if subkeys is not None and value is not None:
                for subkey in subkeys:
                    value = value[subkey]
        if value == 'AttributeError':
            raise AttributeError()
        if attr in self.getmap:
            value = self.getmap[attr](value)
        return value

    def __setattr__(self, attr, value):
        if attr in self.core_attributes:
            if self._core is None:
                self._core = {}
            if attr in self.setmap:
                self._core[attr] = self.setmap[attr](value)
            else:
                self._core[attr] = value
        if attr in self.additional_attributes:
            raise AttributeError()
        object.__setattr__(self, attr, value)

    def save(self):
        if 'id' in self.data:
            return self._api.put('time_entries/%d' % self._id,
                                 {'time_entry': self.data})
        return self._api.post('time_entries', {'time_entry': self.data})

    def get_mock(self):
        data = {attr: getattr(self, attr)
                for attr in ['description', 'start', 'stop', 'duration']}
        return TimeEntry(self._api, data)

    def fetch(self):
        if self._core is None:
            response = self._api.get('time_entries/%d' % self._id)
            self._core = response['data']

    @property
    def data(self):
        self.fetch()
        return self._core

    @staticmethod
    def join(api, *time_entries):
        data = dict(pair for time_entry in time_entries
                    for pair in time_entry.data.items())
        return TimeEntry(api, data)


class TogglApiClient:
    def __init__(self, token):
        self._token = token
        self.__cache = {}
        self.__projects_cache = {}

    def get(self, path, params=None, caching=True):
        key = path + '|' + str(params)
        if not caching or key not in self.__cache:
            self.__cache[key] = query(self._token, path, params, method='get')
        return self.__cache[key]

    def post(self, path, item):
        return query(self._token, path, data=item, method='post')

    def put(self, path, item):
        return query(self._token, path, data=item, method='put')

    def get_clients(self, wid):
        return self.get('workspaces/%d/clients' % wid)

    def get_projects(self, wid, pid=None):
        projects = self.get('workspaces/%d/projects' % wid)
        if pid:
            projects = first(p for p in projects if p['id'] == pid)
        return projects

    @property
    def projects(self):
        projects_by_ws = [get_projects(ws['id']) for ws in self.workspaces]
        for project in flatten(projects_by_ws):
            self.__projects_cache[project['id']] = project
        return {p['id']: p for ps in projects_by_ws for p in ps}

    def get_time_entries(self, start='yesterday 5am', stop='now', wid=None,
                         pids=None):
        if isinstance(start, str):
            start = parse_h_datetime(start).replace(second=0, microsecond=0)
            start = isoformat(start)
        if isinstance(stop, str):
            stop = parse_h_datetime(stop).replace(second=0, microsecond=0)
            stop = isoformat(stop)
        if isinstance(pids, str):
            pids = [pids]
        time_entries = self.get('time_entries', params={'start_date': start,
                                                        'end_date': stop})
        time_entries = [TimeEntry(self, time_entry)
                        for time_entry in time_entries
                        if 'stop' in time_entry  # ignore running time entries
                        if 'pid' in time_entry  # entries need project
                        if wid is None or time_entry['wid'] == wid
                        if pids is None or time_entry['pid'] in pids]
        return time_entries

    def get_project(self, pid):
        if pid in self.__projects_cache:
            project = self.__projects_cache[pid]
        else:
            project = self.get('projects/%d' % pid)['data']
            self.__projects_cache[pid] = project
        return project

    def get_time_entry(self, eid):
        return TimeEntry(self, eid)

    def get_current_time_entry(self):
        data = self.get('time_entries/current', caching=False)['data']
        if data is None:
            return None
        return TimeEntry(self, data)


    @property
    def workspaces(self):
        return self.get('workspaces')

    @property
    def is_valid(self):
        try:
            self.get('workspaces')
        except requests.exceptions.HTTPError:
            return False
        else:
            return True


class TogglUser(TogglApiClient):

    @property
    def me(self):
        """The user's details."""
        return self.get('me')['data']

    @property
    def wid(self):
        return self.me['default_wid']

    @property
    def workspaces(self):
        """The user's workspaces, the default workspace first."""
        return sorted(super().workspaces, key=lambda w: w['id'] != self.wid)

    def start_workspace_client_sync(self, wid=None, cid=None):
        if wid is None:
            wid = self.wid
        return WorkspaceClientSync(self, wid, cid)

    def sync_entries(self, left_id, right_id):
        sync = start_workspace_client_sync()

    def get_time_entries(self, start='yesterday 5am', stop='now', wid=None,
                         pids=None):
        if wid is None:
            wid = self.wid
        return super().get_time_entries(start, stop, wid, pids)


class WorkspaceClientSync:

    def __init__(self, api, wid, cid=None):
        self._api = api
        self._wid = wid
        self._cid = cid

    @property
    def client_workspace_map(self):
        clients = self._api.get_clients(self._wid)
        client_workspace_map = {}
        for ws in self._api.workspaces:
            cid = first(client['id'] for client in clients
                        if client['name'] == ws['name'])
            if cid is not None:
                client_workspace_map[cid] = ws
        return client_workspace_map

    @property
    def clients(self):
        return [client for client in self._api.get_clients(self._wid)
                if first(ws for ws in self._api.workspaces
                         if ws['name'] == client['name'])]

    @property
    def projects(self):
        projects = [(p['name'], p['id'])
                    for p in self._api.get_projects(self._wid)
                    if 'cid' in p and p['cid'] == self._cid]
        target_pids = {p['name']: p['id']
                       for p in self._api.get_projects(self.target_wid)}
        return [(name, pid, target_pids[name] if name in target_pids else None)
                for name, pid in projects]

    def get_project_by_name(self, wid, name):
        return first(project for project in self._api.get_projects(wid)
                     if project['name'] == name)

    def set_cid(self, cid):
        self._cid = cid
        self.target_wid = self.client_workspace_map[self._cid]['id']

    def get_time_entries_to_sync(self, start='a week ago', stop='now',
                                 cid=None):
        """Find time entries to sync from left workspace to right workspace.

        Note
        ----
        Entries need to have the exact same description and project name and
        also lie on the same day to match. Entries will always be matched to
        the first possible partner in chronological order.

        """
        if self._cid is None:
            assert cid is not None
            self.set_cid(cid)

        _, pids, target_pids = zip(*self.projects)
        entries_left = self._api.get_time_entries(start, stop, self._wid,
                                                  pids=pids)
        entries_right = self._api.get_time_entries(start, stop,
                                                   self.target_wid,
                                                   pids=target_pids)

        entry_pairs = []
        for left in entries_left:
            if not hasattr(left, 'description') or not hasattr(left, 'stop'):
                continue
            # Find a matching id in the *right* workspace by looking for
            # either the same name or the same start and stop time.
            right = first(right for right in entries_right
                          if left.pname == right.pname
                          #   if left.description == right.description
                          if left.start == right.start
                          if left.stop == right.stop)
            if right is None or left.description != right.description:
                if right is not None:
                    # Remove entry from right list to prevent matching it again.
                    entries_right = [r for r in entries_right
                                     if r.id != right.id]
                entry_pairs.append((left, right))
        return entry_pairs

    def sync_time_entries(self, *entry_pairs):
        """Merge the left into the right entries and push to the target ws.

        Note
        ----
        Use the special tag `$$` to mark entries as billable in the client
        workspace. This is even more useful when using a starter account
        for the private workspace where one cannot mark entries as billable.
        Single `$` billable for yourself, `$$` billable for your client, too.

        """
        synced_entries = []
        for left, right in entry_pairs:
            if isinstance(left, (int, str)):
                left = self._api.get_time_entry(left)
            if isinstance(right, (int, str)):
                right = self._api.get_time_entry(right)

            mock = left.get_mock()
            if left.tags is not None and '$$' in left.tags:
                mock.billable = True

            logger.info(right)
            if right is None:
                right = mock
                right.wid = self.target_wid
                project = self.get_project_by_name(right.wid, left.pname)
                right.pid = project['id']
                right.created_with = 'ahoereth/toggl24'
            else:
                right = TimeEntry.join(self._api, right, left)

            right.save()
            synced_entries.append(right)

        return synced_entries


def main(token):
    user = TogglUser(token)

    print('Sync entries to a clients workspace. [0] is always the default.')
    print()

    ws = user.workspaces
    print('Which workspace do you want to sync from?')
    print(' '.join(['[%d] %s' % (i, ws['name']) for i, ws in enumerate(ws)]))
    wid = ws[int(input() or '0')]['id']

    sync = user.start_workspace_client_sync(wid)
    print('Which client do you want to sync?')
    print(' '.join('[%d] %s' % (i, c['name'])
                   for i, c in enumerate(sync.clients)))
    cid = sync.clients[int(input() or 0)]['id']

    ts = ['last week - this morning', 'this morning - now',
          'yesterday morning - this morning']
    print('Which timespan would you like to sync?')
    print('\n'.join(['[%d] %s' % (i, t) for i, t in enumerate(ts)]))
    ts = ts[int(input() or 0)]
    start, stop = ts.split('-')

    pairs = sync.get_time_entries_to_sync(start, stop, cid=cid)
    print('Items to be synced:')
    for pair in pairs:
        print(pair[0].description)

    input('Continue? CTRL+C to stop.')

    sync.sync_time_entries(*pairs)
    print('\nDone.')


if __name__ == '__main__':
    import sys
    token = sys.argv[1]
    main(token)
