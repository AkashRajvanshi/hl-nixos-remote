{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    history = {
      extended = true;
      size = 100000;
      save = 100000;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };
    initContent = ''
      bindkey '^w' forward-word
      bindkey '^b' backward-kill-word
      bindkey '^f' autosuggest-accept
      bindkey '^p' history-substring-search-up
      bindkey '^n' history-substring-search-down
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration\n$character";
      directory = {
        style = "blue";
      };
      git_branch = {
        format = "[$branch]($style) ";
        style = "purple";
      };
      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](228) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "";
        untracked = "";
        modified = "";
        staged = "";
        renamed = "";
        deleted = "";
        stashed = "≡";
      };
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };
    };
  };

  home.username = "hacstac";
  home.homeDirectory = "/home/hacstac";
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    openssl
    git
    tree
    bat
    fzf
    htop
    jq
    vim
  ];
}
