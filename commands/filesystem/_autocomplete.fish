function __fish_trash_dirs_complete
  set -l trash_config "$EPX_HOME/.config/trash.config"

  if test -f $trash_config
    set -l trash_dirs (grep -o 'TRASH_DIRS="[^"]*"' $trash_config | cut -d'"' -f2)

    if test -n "$trash_dirs"
      string split ':' $trash_dirs | while read -l dir
        if test -n "$dir"
          set -l clean_dir (string replace -a '\\' '' "$dir")
          echo -E "$clean_dir"
        end
      end
    end
  end
end

complete -c fs.cleartrash -n "__fish_seen_subcommand_from" -f
complete -c fs.cleartrash -f -s f -l force -d "Clear all trash directories without confirmation"
complete -c fs.cleartrash -f -a "(__fish_trash_dirs_complete)" -d "Trash directory path"

complete -c fs.lstrash -n "__fish_seen_subcommand_from" -f
complete -c fs.lstrash -f -a "(__fish_trash_dirs_complete)" -d "Trash directory path"
