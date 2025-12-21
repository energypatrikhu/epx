function __epx_fish_d_containers
  docker ps -a --format '{{.Names}}'
end

complete -c d.attach -a '(__epx_fish_d_containers)'
complete -c d.exec -a '(__epx_fish_d_containers)'
complete -c d.inspect -a '(__epx_fish_d_containers)'
complete -c d.i -a '(__epx_fish_d_containers)'
complete -c d.logs -a '(__epx_fish_d_containers)'
complete -c d.log -a '(__epx_fish_d_containers)'
complete -c d.shell -a '(__epx_fish_d_containers)'

function __epx_fish_d_containers_with_all
  echo "all"
  docker ps -a --format '{{.Names}}'
end

complete -c d.remove -a '(__epx_fish_d_containers_with_all)'
complete -c d.rm -a '(__epx_fish_d_containers_with_all)'
complete -c d.restart -a '(__epx_fish_d_containers_with_all)'
complete -c d.start -a '(__epx_fish_d_containers_with_all)'
complete -c d.stop -a '(__epx_fish_d_containers_with_all)'
complete -c d.stats -a '(__epx_fish_d_containers_with_all)'
complete -c d.stat -a '(__epx_fish_d_containers_with_all)'

complete -c d.list -a 'created restarting running removing paused exited dead'
complete -c d.ls -a 'created restarting running removing paused exited dead'

complete -c d.prune -a 'all images containers volumes networks build'

function __epx_fish_d_container_templates
  find "$EPX_HOME"/.templates/docker/dockerfile -maxdepth 1 -type f -name '*.template' -exec basename {} .template \;
end

complete -c d.make -a '(__epx_fish_d_container_templates)'
complete -c d.mk -a '(__epx_fish_d_container_templates)'

if test -f "$EPX_HOME/.config/docker.config"
  function __epx_fish_d_container_directories
    set -l config_file "$EPX_HOME/.config/docker.config"
    set -l containers_dir (grep '^CONTAINERS_DIR=' $config_file | cut -d'=' -f2 | tr -d '"' | tr -d "'")

    for d in $containers_dir/*
      if test -d "$d" -a -f "$d/docker-compose.yml"
        basename "$d"
      end
    end
  end

  complete -c d.up -a '(__epx_fish_d_container_directories)'
  complete -c d.pull -a '(__epx_fish_d_container_directories)'
end
