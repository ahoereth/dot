export DOT_PATH=~/repos/dot

### SYMLINKS
# Link dotfiles to their proper locations.
function lnifnotexists() {
    [ -L "${HOME}/$1" ] || (mkdir -p "${HOME}/$(dirname $1)" && ln -s "${DOT_PATH}/$1" "${HOME}/$1")
}

for link in \
    '.antigenrc' \
    '.Brewfile' \
    '.gitconfig' \
    '.gitignore' \
    '.zshrc' \
    ; do
    lnifnotexists $link
done
ln -s "${DOTFILES_DIR}/.gitignore" "${HOME}/.gitignore_global"
