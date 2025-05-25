function update --wraps='yay -Syuu --needed --noconfirm && flatpak update --noninteractive' --description 'alias update yay -Syuu --needed --noconfirm && flatpak update --noninteractive'
  yay -Syuu --needed --noconfirm && flatpak update --noninteractive $argv
        
end
