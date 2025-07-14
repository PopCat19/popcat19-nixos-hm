function get --wraps='git clone' --description 'alias get git clone with optional -cd to enter repo'
  set -l cd_into_repo false
  set -l args

  # Parse arguments
  for arg in $argv
    if test "$arg" = "-cd"
      set cd_into_repo true
    else
      set -a args $arg
    end
  end

  # Clone the repository
  git clone $args

  # If -cd was specified, change into the cloned directory
  if test $cd_into_repo = true
    # Extract directory name from last argument (repo URL)
    set -l repo_url $args[-1]
    set -l repo_name (string replace -r '^.*/([^/]+?)(\.git)?$' '$1' $repo_url)
    cd $repo_name
  end
end
