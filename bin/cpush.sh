#
# Continuously upload files to one or many remote servers using rsync, whenever
# the change.
#
#

src=
dsts=()
args=
while [ "$1" != "" ]; do
  case $1 in
    -d | --delete ) shift
                    args+=--delete-after
                    ;;
    * )
      if [ -z "$src" ]; then
        src=$1
      else
        dsts+=($1)
      fi
      shift
  esac
done

# If only one directory was provided, use it as the destination and the current
# directory as the source.
if [ ${#dsts[@]} -eq 0 ]; then
  dsts+=($src)
  src=.
fi

echo "Continuously pushing from $src to $dsts..."


function do_rsync() {
  for dst in "${dsts[@]}"; do
    echo "->" $dst
    rsync -azih $args --include='**.gitignore' --exclude="/.git" --filter=":- .gitignore" $src $dst
  done
}


function run_rsync() {
  local file=$1
  local events=$2
  ignored=`git check-ignore $file`
  # echo "Update: $file $events $ignored"
  if [ ! -z "$file" ] && [ "$file" != "EOF" ] && [ -z "$ignored" ]; then
    for event in "${events[@]}"; do
      case $event in
        #*OwnerModified|*AttributeModified|
        *Created|*Updated|*Removed|*Renamed|*MovedFrom|*MovedTo|*OwnerModified )
          echo $file $event
          do_rsync
          break
      esac
    done
  fi
}


do_rsync

fswatch -e ".git" --batch-marker=EOF --event-flags $src | while read file events; do run_rsync $file $events; done

