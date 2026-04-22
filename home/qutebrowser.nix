{ ... }:

{
  programs.qutebrowser = {
    enable = true;

    settings = {
      tabs.position = "left";
      statusbar.show = "in-mode";
      scrolling.smooth = true;
      content.blocking.enabled = true;
      # fonts.default_family = "FiraCode Nerd Font";
      # fonts.default_size = "11pt";
    };

    searchEngines = {
      DEFAULT = "https://www.google.com/search?q={}";
      g = "https://www.google.com/search?q={}";
      yt = "https://www.youtube.com/results?search_query={}";
      gh = "https://github.com/search?q={}";
    };

    keyBindings = {
      normal = {
        "<Space>b" = "set tabs.position bottom";
        "<Space>l" = "set tabs.position left";
      };
    };
  };
}
