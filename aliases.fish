function __epx_load_aliases
  for element in $argv[1]/*
    if test -d "$element"
      __epx_load_aliases "$element"
      continue
    end

    if test -f "$element"; and string match -q '*.sh' "$element"
      if string match -q '*_alias.sh' "$element"
        # echo "Loading alias from $element"
        source "$element"
      end
    end
  end
end

__epx_load_aliases "$EPX_HOME/commands"
