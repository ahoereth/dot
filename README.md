# dot files and other configurations

- Global dependencies should always be on `latest` -- if not, they should not be global. `pip` annoyingly makes [upgrading all packages hard](https://github.com/pypa/pip/issues/59).

    sudo pip install -r dependencies-pip3.txt -U
