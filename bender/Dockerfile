FROM ubuntu:24.04

WORKDIR /app

# Turn off auto-updates & prompts for oh-my-zsh
RUN echo "DISABLE_AUTO_UPDATE=true" >> $HOME/.zshrc.local
RUN echo "DISABLE_UPDATE_PROMPT=true" >> $HOME/.zshrc.local

CMD ["sleep", "infinity"]
