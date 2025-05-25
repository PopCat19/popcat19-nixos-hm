function sillytavern --wraps='ngrok http --url=usable-sailfish-merely.ngrok-free.app 8000 & ~/SillyTavern-Launcher/SillyTavern/start.sh' --wraps='ngrok http --url=usable-sailfish-merely.ngrok-free.app 8000 & sleep 3 & ~/SillyTavern-Launcher/SillyTavern/start.sh' --wraps='nohup ngrok http --url=usable-sailfish-merely.ngrok-free.app 8000 & ~/SillyTavern-Launcher/SillyTavern/start.sh' --description 'alias sillytavern nohup ngrok http --url=usable-sailfish-merely.ngrok-free.app 8000 & ~/SillyTavern-Launcher/SillyTavern/start.sh'
  nohup ngrok http --url=usable-sailfish-merely.ngrok-free.app 8000 & ~/SillyTavern-Launcher/SillyTavern/start.sh $argv
        
end
