# Crush overlay - provides crush from charmbracelet NUR repository
# https://github.com/charmbracelet/crush

final: prev: {
  crush = final.nur.repos.charmbracelet.crush;
}