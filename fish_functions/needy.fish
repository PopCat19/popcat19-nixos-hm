function needy --wraps='yay -Sy --needed' --wraps='yay -Sy --needed --noconfirm' --description 'alias needy yay -Sy --needed --noconfirm'
  yay -Sy --needed --noconfirm $argv
        
end
