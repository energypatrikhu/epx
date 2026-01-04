source "$EPX_HOME/helpers/check-compose-file.fish"

function __epx_fish_d_containers
  docker ps -a --format '{{.Names}}'
end

complete -c d.attach -f -a '(__epx_fish_d_containers)'
complete -c d.exec -f -a '(__epx_fish_d_containers)'
complete -c d.inspect -f -a '(__epx_fish_d_containers)'
complete -c d.i -f -a '(__epx_fish_d_containers)'
complete -c d.logs -f -a '(__epx_fish_d_containers)'
complete -c d.log -f -a '(__epx_fish_d_containers)'
complete -c d.shell -f -a '(__epx_fish_d_containers)'

function __epx_fish_d_containers_with_all
  echo "all"
  docker ps -a --format '{{.Names}}'
end

complete -c d.remove -f -a '(__epx_fish_d_containers_with_all)'
complete -c d.rm -f -a '(__epx_fish_d_containers_with_all)'
complete -c d.restart -f -a '(__epx_fish_d_containers_with_all)'
complete -c d.start -f -a '(__epx_fish_d_containers_with_all)'
complete -c d.stop -f -a '(__epx_fish_d_containers_with_all)'
complete -c d.stats -f -a '(__epx_fish_d_containers_with_all)'
complete -c d.stat -f -a '(__epx_fish_d_containers_with_all)'

complete -c d.list -f -a 'created restarting running removing paused exited dead'
complete -c d.ls -f -a 'created restarting running removing paused exited dead'

complete -c d.prune -f -a 'all images containers volumes networks build'

function __epx_fish_d_container_templates
  find "$EPX_HOME"/.templates/docker/dockerfile -maxdepth 1 -type f -name '*.template' -exec basename {} .template \;
end

complete -c d.make -f -a '(__epx_fish_d_container_templates)'
complete -c d.mk -f -a '(__epx_fish_d_container_templates)'

if test -f "$EPX_HOME/.config/docker.config"
  function __epx_fish_d_container_directories
    set -l config_file "$EPX_HOME/.config/docker.config"
    set -l containers_dir (grep '^CONTAINERS_DIR=' $config_file | cut -d'=' -f2 | tr -d '"' | tr -d "'")

    for d in $containers_dir/*
    if test -d "$d" && check-compose-file "$d"
        basename "$d"
      end
    end
  end

  complete -c d.up -f -a '(__epx_fish_d_container_directories)'
  complete -c d.pull -f -a '(__epx_fish_d_container_directories)'
end
