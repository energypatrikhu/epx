function __fish_trash_dirs_complete
  set -l trash_config "$EPX_HOME/.config/trash.config"

  if test -f $trash_config
    source $trash_config

    if test -n "$TRASH_DIRS"
      string split ':' $TRASH_DIRS | while read -l dir
        if test -n "$dir"
          basename "$dir"
        end
      end
    end
  end
end

complete -c fs.cleartrash -n "__fish_seen_subcommand_from" -f
complete -c fs.cleartrash -f -s f -l force -d "Clear all trash directories without confirmation"
complete -c fs.cleartrash -f -a "(__fish_trash_dirs_complete)" -d "Trash directory name"

complete -c fs.lstrash -n "__fish_seen_subcommand_from" -f
complete -c fs.lstrash -f -a "(__fish_trash_dirs_complete)" -d "Trash directory name"
