function __epx_fish_load_autocomplete
  for element in $argv[1]/*
    if test -d "$element"
      __epx_fish_load_autocomplete "$element"
      continue
    end

    if test -f "$element"; and string match -q '*.fish' "$element"
      if string match -q '*_autocomplete.fish' "$element"
        # echo "Loading autocomplete from $element"
        source "$element"
      end
    end
  end
end

__epx_fish_load_autocomplete "$EPX_HOME/commands"

complete -c epx -f -a 'self-update mk-cert update-bees backup'
