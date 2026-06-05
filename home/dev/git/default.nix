{ ... }:

{
  programs.git = {
    enable = true;
    signing.format = null;
    settings = {
      user.name = "EyalLitvin";
      user.email = "eyalitvin@gmail.com";
    };
  };

}
